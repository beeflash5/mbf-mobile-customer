import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/views/pages/order/widgets/order.bottomsheet.dart';
import 'package:fuodz/views/pages/order/widgets/order_address.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_attachment.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_driver_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_items.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_vendor_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_status.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/cards/order_details_summary.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:fuodz/extensions/context.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.order,
    this.isOrderTracking = false,
    Key? key,
  }) : super(key: key);

  final Order order;
  final bool isOrderTracking;

  @override
  Widget build(BuildContext context) {
    Widget actionRequired({
      required Order order,
      required String orderId,
      required String message,
      required VoidCallback onCancel,
      required VoidCallback onContinue,
    }) {
      final status = order.confirmation_customer;

      if (status == null || status == 0) {
        return SizedBox();
      }

      // 🎨 Default (status 1 = pending)
      Color bgColor = Color(0xFFFFF8E1);
      Color headerColor = Color(0xFFFFECB3);
      Color textColor = Colors.orange.shade800;

      String title = 'Action Required';
      String description =
          'Please review the partner message and confirm your action.';

      // ✅ status 2 = confirmed
      if (status == 2) {
        bgColor = Color(0xFFE8F5E9);
        headerColor = Color(0xFFC8E6C9);
        textColor = Colors.green.shade800;

        title = 'Confirmed';
        description = 'You have confirmed to proceed with the order.';
      }

      // ❌ status 3 = cancelled
      if (status == 3) {
        bgColor = Color(0xFFFFEBEE);
        headerColor = Color(0xFFFFCDD2);
        textColor = Colors.red.shade800;

        title = 'Cancelled';
        description = 'You have cancelled this order.';
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Order #$orderId',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // 🔹 CONTENT
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      color:
                          status == 2
                              ? Colors.green
                              : status == 3
                              ? Colors.red
                              : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),

                  // message box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(message.isNotEmpty ? message : '-'),
                  ),

                  SizedBox(height: 16),

                  // 🔥 ACTIONS (ONLY STATUS 1)
                  if (status == 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onCancel,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Continue'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    //
    return Scaffold(
      body: ViewModelBuilder<OrderDetailsViewModel>.reactive(
        viewModelBuilder: () => OrderDetailsViewModel(context, order),
        disposeViewModel: true,
        createNewViewModelOnInsert: true,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            title: "Order Details".tr(),
            showAppBar: true,
            showLeadingAction: true,
            isLoading: vm.isBusy,
            onBackPressed: () {
              context.pop(vm.order);
            },
            //share button for parcel delivery order
            actions:
                vm.order.isPackageDelivery
                    ? [
                      Icon(
                        FlutterIcons.share_2_fea,
                        color: Colors.white,
                      ).p8().onInkTap(vm.shareOrderDetails).p8(),
                    ]
                    : [],
            body:
                vm.isBusy
                    ? BusyIndicator().centered()
                    : SmartRefresher(
                      controller: vm.refreshController,
                      onRefresh: vm.fetchOrderDetails,
                      child: Stack(
                        children: [
                          //vendor details
                          Positioned(
                            child: Stack(
                              children: [
                                //vendor feature image
                                CustomImage(
                                  imageUrl: vm.order.vendor!.featureImage,
                                  width: double.infinity,
                                  height: 200,
                                  boxFit: BoxFit.contain,
                                ),
                                //vendor details
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: GlassContainer(
                                    height: 200,
                                    width: context.screenWidth,
                                    color: Colors.black54,
                                    borderGradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.60),
                                        Colors.white.withOpacity(0.10),
                                        AppColor.primaryColor.withOpacity(0.05),
                                        AppColor.primaryColor.withOpacity(0.6),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 0.39, 0.40, 1.0],
                                    ),
                                    blur: 2.0,
                                    borderWidth: 0,
                                    elevation: 0,
                                    isFrostedGlass: true,
                                    shadowColor: Colors.black.withOpacity(0.20),
                                    alignment: Alignment.center,
                                    frostedOpacity: 0.30,
                                    padding: EdgeInsets.all(8.0),
                                    child: VStack([
                                      vm
                                          .order
                                          .vendor!
                                          .name
                                          .text
                                          .center
                                          .white
                                          .xl3
                                          .semiBold
                                          .makeCentered(),
                                      UiSpacer.verticalSpace(space: 40),
                                    ], alignment: MainAxisAlignment.center),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //
                          VStack([
                            UiSpacer.verticalSpace(space: 160),
                            VStack([
                                  //free space
                                  //header view
                                  HStack([
                                    //vendor logo
                                    CustomImage(
                                      imageUrl: vm.order.vendor!.logo,
                                      width: 50,
                                      height: 50,
                                    ).box.roundedSM.clip(Clip.antiAlias).make(),
                                    UiSpacer.horizontalSpace(),
                                    //
                                    VStack([
                                      //
                                      "${vm.order.status.tr().capitalized}"
                                          .text
                                          .semiBold
                                          .xl
                                          .color(
                                            AppColor.getStausColor(
                                              vm.order.status,
                                            ),
                                          )
                                          .make(),
                                      "${Jiffy.parseFromDateTime(vm.order.updatedAt).format(pattern: 'MMM dd, yyyy \| HH:mm')}"
                                          .text
                                          .light
                                          .lg
                                          .make(),
                                      "#${vm.order.code}".text.xs.gray400.light
                                          .make(),
                                    ]).expand(),
                                    //qr code icon
                                    Visibility(
                                      visible:
                                          !vm.order.isTaxi &&
                                          !vm.order.isSerice,
                                      child: Icon(
                                        FlutterIcons.qrcode_ant,
                                        size: 28,
                                      ).onInkTap(vm.showVerificationQRCode),
                                    ),
                                  ]).p20().wFull(context),
                                  //
                                  // UiSpacer.cutDivider(),
                                  UiSpacer.divider(),
                                  //Payment status
                                  OrderPaymentInfoView(vm),
                                  //status
                                  Visibility(
                                    // visible: vm.order.showStatusTracking,
                                    child: VStack([
                                      OrderStatusView(vm).p20(),
                                      UiSpacer.divider(),
                                    ]),
                                  ),
                                  vm.order.confirmation_note != null
                                      ? actionRequired(
                                        order: vm.order,
                                        orderId: vm.order.id.toString(),
                                        message:
                                            vm.order.confirmation_note ?? "",
                                        onCancel: vm.cancelConfirmOrder,
                                        onContinue: vm.confirmOrder,
                                      )
                                      : SizedBox(),
                                  // either products/package details
                                  OrderDetailsItemsView(vm).p20(),
                                  //show package delivery addresses
                                  Visibility(
                                    visible: vm.order.deliveryAddress != null,
                                    child: OrderAddressesView(vm).p20(),
                                  ),
                                  //
                                  OrderAttachmentView(vm),
                                  //
                                  CustomVisibilty(
                                    visible:
                                        (!vm.order.isPackageDelivery &&
                                            vm.order.deliveryAddress == null),
                                    child:
                                        ""
                                            .tr()
                                            .text
                                            .italic
                                            .light
                                            .xl
                                            .medium
                                            .make(),
                                    // .px20()
                                    // .py20(),
                                  ),

                                  //note
                                  "Note".tr().text.semiBold.xl.make().px20(),
                                  "${vm.order.note}".text.light.sm
                                      .make()
                                      .px20(),
                                  UiSpacer.vSpace(5),
                                  UiSpacer.divider(),
                                  //vendor
                                  UiSpacer.vSpace(),
                                  OrderDetailsVendorInfoView(vm),

                                  //driver
                                  OrderDetailsDriverInfoView(vm),

                                  UiSpacer.divider(),
                                  //order summary
                                  OrderDetailsSummary(vm.order)
                                      .wFull(context)
                                      .p20()
                                      .pOnly(bottom: context.percentHeight * 10)
                                      .box
                                      .make(),
                                ]).box
                                .topRounded(value: 15)
                                .clip(Clip.antiAlias)
                                .color(context.theme.colorScheme.surface)
                                .make(),
                            //
                            UiSpacer.vSpace(50),
                          ]).scrollVertical(),
                        ],
                      ),
                    ),

            bottomSheet: isOrderTracking ? null : OrderBottomSheet(vm),
          );
        },
      ),
    );
  }
}
