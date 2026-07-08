import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:go_router/go_router.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/order.request.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/services/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/chat.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:singleton/singleton.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_token.service.dart';

class FirebaseService {
  //
  /// Factory method that reuse same instance automatically
  factory FirebaseService() => Singleton.lazy(() => FirebaseService._());

  /// Private constructor
  FirebaseService._() {}

  //
  NotificationModel? notificationModel;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Map? notificationPayloadData;

  setUpFirebaseMessaging() async {
    //Request for notification permission
    /*NotificationSettings settings = */
    bool isPermanentlyDenied =
        await Permission.notification.isPermanentlyDenied;
    if (isPermanentlyDenied) {
      return;
    }
    bool isGranted = await Permission.notification.isGranted;
    if (!isGranted) {
      return;
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    //subscribing to all topic
    firebaseMessaging.subscribeToTopic("all");
    FirebaseTokenService().handleDeviceTokenSync();

    //on notification tap tp bring app back to life
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      saveNewNotification(message);
      selectNotification("From onMessageOpenedApp");
      //
      refreshOrdersList(message);
    });

    //normal notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      saveNewNotification(message);

      if (Platform.isAndroid) {
        showNotification(message);
      }

      //
      refreshOrdersList(message);
    });
  }

  //write to notification list
  saveNewNotification(RemoteMessage? message, {String? title, String? body}) {
    //
    notificationPayloadData = message != null ? message.data : null;
    if (message?.notification == null &&
        message?.data["title"] == null &&
        title == null) {
      return;
    }

    String? bodyStr =
        (message?.notification?.body ?? body ?? message?.data["body"])
            ?.toString()
            .toLowerCase();
    String? titleStr =
        (message?.notification?.title ?? title ?? message?.data["title"])
            ?.toString()
            .toLowerCase();
    if ((bodyStr != null &&
            (bodyStr.contains("konfirmasi pesanan") ||
                bodyStr.contains("harap konfirmasi"))) ||
        (titleStr != null &&
            (titleStr.contains("konfirmasi pesanan") ||
                titleStr.contains("harap konfirmasi")))) {
      return;
    }

    //Saving the notification
    notificationModel = NotificationModel();
    notificationModel!.title =
        message?.notification?.title ?? title ?? message?.data["title"] ?? "";
    notificationModel!.body =
        message?.notification?.body ?? body ?? message?.data["body"] ?? "";
    //

    final imageUrl =
        message?.data["image"] ??
        (Platform.isAndroid
            ? message?.notification?.android?.imageUrl
            : message?.notification?.apple?.imageUrl);
    notificationModel!.image = imageUrl;

    //
    notificationModel!.timeStamp = DateTime.now().millisecondsSinceEpoch;

    //add to database/shared pref
    NotificationService.addNotification(notificationModel!);
  }

  //
  showNotification(RemoteMessage message) async {
    if (message.notification == null && message.data["title"] == null) {
      return;
    }

    String? bodyStr =
        (message.notification?.body ?? message.data["body"])
            ?.toString()
            .toLowerCase();
    String? titleStr =
        (message.notification?.title ?? message.data["title"])
            ?.toString()
            .toLowerCase();
    if ((bodyStr != null &&
            (bodyStr.contains("konfirmasi pesanan") ||
                bodyStr.contains("harap konfirmasi"))) ||
        (titleStr != null &&
            (titleStr.contains("konfirmasi pesanan") ||
                titleStr.contains("harap konfirmasi")))) {
      return;
    }

    //
    notificationPayloadData = message.data;

    //
    try {
      //
      String? imageUrl;

      try {
        imageUrl =
            message.data["image"] ??
            (Platform.isAndroid
                ? message.notification?.android?.imageUrl
                : message.notification?.apple?.imageUrl);
      } catch (error) {
        print("error getting notification image");
      }

      //
      if (imageUrl != null) {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            bigPicture: imageUrl,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.BigPicture,
            payload: Map<String, String>.from(message.data),
          ),
        );
      } else {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.Default,
            payload: Map<String, String>.from(message.data),
          ),
        );
      }

      ///
    } catch (error) {
      print("Notification Show error ===> ${error}");
    }
  }

  //handle on notification selected
  Future selectNotification(String? payload) async {
    if (payload == null) {
      return;
    }
    try {
      log("NotificationPaylod ==> ${jsonEncode(notificationPayloadData)}");
      //
      if (notificationPayloadData != null && notificationPayloadData is Map) {
        //

        //
        final isChat = notificationPayloadData!.containsKey("is_chat");
        final isOrder =
            notificationPayloadData!.containsKey("is_order") &&
            (notificationPayloadData?["is_order"].toString() == "1" ||
                (notificationPayloadData?["is_order"] is bool &&
                    notificationPayloadData?["is_order"]));

        ///
        final hasProduct = notificationPayloadData!.containsKey("product");
        final hasVendor = notificationPayloadData!.containsKey("vendor");
        final hasService = notificationPayloadData!.containsKey("service");
        final hasUpdateApps = notificationPayloadData!.containsKey(
          "update_application",
        );

        //
        if (isChat) {
          String chatPath = notificationPayloadData!['path'] ?? "";
          final parts = chatPath.split('/');
          if (parts.length >= 3) {
            final orderCode = parts[1];
            final chatType = parts[2];

            // Wait for context to be available
            BuildContext? context = AppService().navigatorKey.currentContext;
            int retries = 0;
            while (context == null && retries < 10) {
              await Future.delayed(const Duration(milliseconds: 200));
              context = AppService().navigatorKey.currentContext;
              retries++;
            }

            if (context != null) {
              GoRouter.of(context).push(
                AppRoutes.chatRoute,
                extra: {
                  'orderCode': orderCode,
                  'chatType': chatType,
                  'receiverId': 0, // Backend will auto-resolve
                },
              );
            }
          }
        }
        //order
        else if (isOrder) {
          try {
            int orderId = int.parse("${notificationPayloadData!['order_id']}");
            Order order = await OrderRequest().getOrderDetails(id: orderId);
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).push('${AppRoutes.orderDetailsRoute}/${order.id}', extra: order);
          } catch (error) {
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).go(AppRoutes.homeRoute);
            AppService().changeHomePageIndex();
          }
        }
        //vendor type of notification
        else if (hasVendor) {
          Vendor? vendor;
          final vendorData = notificationPayloadData?['vendor'];
          try {
            vendor = Vendor.fromJson(jsonDecode(vendorData));
          } catch (error) {
            final vendorJsonData = jsonDecode(vendorData);
            final vendorId = vendorJsonData["id"];
            if (vendorId != null) {
              AlertService.loading();
              try {
                vendor = await VendorRequest().vendorDetails(vendorId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).push('${AppRoutes.vendorDetails}/${vendor?.id}', extra: vendor);
          } catch (error) {
            ToastService.toastError("Unable to fetch vendor details".tr());
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).go(AppRoutes.homeRoute);
          }

          //
        }
        //product type of notification
        else if (hasProduct) {
          //
          Product? product;
          final productData = notificationPayloadData?['product'];
          try {
            product = Product.fromJson(jsonDecode(productData));
          } catch (error) {
            final productJsonData = jsonDecode(productData);
            final productId = productJsonData["id"];
            if (productId != null) {
              AlertService.loading();
              try {
                product = await ProductRequest().productDetails(productId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).push('${AppRoutes.product}/${product?.id}', extra: product);
          } catch (error) {
            ToastService.toastError("Unable to fetch product details".tr());
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).go(AppRoutes.homeRoute);
          }
        }
        //service type of notification
        else if (hasService) {
          Service? service;
          final serviceData = notificationPayloadData?['service'];
          try {
            service = Service.fromJson(jsonDecode(serviceData));
            //
          } catch (error) {
            final serviceJsonData = jsonDecode(serviceData);
            final serviceId = serviceJsonData["id"];
            if (serviceId != null) {
              AlertService.loading();
              try {
                service = await ServiceRequest().serviceDetails(serviceId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            GoRouter.of(AppService().navigatorKey.currentContext!).push(
              '${AppRoutes.serviceDetails}/${service?.id}',
              extra: service,
            );
          } catch (error) {
            ToastService.toastError("Unable to fetch service details".tr());
            GoRouter.of(
              AppService().navigatorKey.currentContext!,
            ).go(AppRoutes.homeRoute);
          }
        } else if (hasUpdateApps) {
          print("Opening app store for update");
          try {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            if (Platform.isAndroid) {
              // Google Play
              final packageName = packageInfo.packageName;

              await launchUrl(
                Uri.parse("market://details?id=$packageName"),
                mode: LaunchMode.externalApplication,
              );
            } else if (Platform.isIOS) {
              // App Store

              const appStoreId = "id6781575289";

              await launchUrl(
                Uri.parse("https://apps.apple.com/app/id$appStoreId"),
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (error) {
            ToastService.toastError("Unable to open the app store".tr());
          }
        }
        //regular notifications
        else {
          GoRouter.of(
            AppService().navigatorKey.currentContext!,
          ).push(AppRoutes.notificationDetailsRoute, extra: notificationModel);
        }
      } else {
        GoRouter.of(
          AppService().navigatorKey.currentContext!,
        ).push(AppRoutes.notificationDetailsRoute, extra: notificationModel);
      }
    } catch (error) {
      print("Error opening Notification ==> $error");
    }
  }

  //refresh orders list if the notification is about assigned order
  void refreshOrdersList(RemoteMessage message) async {
    if (message.data["is_order"] != null) {
      await Future.delayed(Duration(seconds: 3));
      AppService().refreshAssignedOrders.add(true);
    }
  }
}
