import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:quickalert/quickalert.dart';

import 'package:fuodz/services/app_colors.dart';
import 'package:fuodz/utils/app.service.dart';

/// Alert dialog wrapper di atas QuickAlert. Tidak butuh BuildContext —
/// memanfaatkan navigatorKey global dari [AppService].
class AlertService {
  AlertService._();

  static Future<bool> success({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    String cancelBtnText = 'Cancel',
    VoidCallback? onConfirm,
  }) async {
    bool result = false;
    final context = AppService().navigatorKey.currentContext;
    if (context == null) return result;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      cancelBtnText: cancelBtnText.tr(),
      confirmBtnColor: AppColor.primaryColor,
      onConfirmBtnTap: () {
        result = true;
        Navigator.of(context).maybePop();
        onConfirm?.call();
      },
    );
    return result;
  }

  static Future<bool> error({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    VoidCallback? onConfirm,
  }) async {
    bool result = false;
    final context = AppService().navigatorKey.currentContext;
    if (context == null) return result;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      confirmBtnColor: AppColor.primaryColor,
      onConfirmBtnTap: () {
        result = true;
        Navigator.of(context).maybePop();
        onConfirm?.call();
      },
    );
    return result;
  }

  static Future<bool> confirm({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    String cancelBtnText = 'Cancel',
  }) async {
    bool result = false;
    final context = AppService().navigatorKey.currentContext;
    if (context == null) return result;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      cancelBtnText: cancelBtnText.tr(),
      confirmBtnColor: AppColor.primaryColor,
      onConfirmBtnTap: () {
        result = true;
        Navigator.of(context).maybePop();
      },
    );
    return result;
  }
}
