import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/component/bottom_sheet/wallet_amount_entry.bottomsheet.dart';
import 'package:fuodz/component/finance/wallet_address.bottom_sheet.dart';
import 'package:fuodz/pages/wallet/wallet_transfer.page.dart';
import 'package:fuodz/providers/wallet_providers.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/extensions/context.dart';

class WalletHelper {
  /// Bottom-sheet amount entry → topup → embedded webview for payment.
  static Future<void> showAmountEntry(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WalletAmountEntryBottomSheet(
        onSubmit: (amount) {
          Navigator.of(sheetContext).pop();
          _initiateTopUp(context, ref, amount);
        },
      ),
    );
  }

  static Future<void> _initiateTopUp(
    BuildContext context,
    WidgetRef ref,
    String amount,
  ) async {
    final result =
        await ref.read(walletControllerProvider.notifier).initiateTopUp(amount);
    if (!context.mounted) return;
    switch (result) {
      case WalletTopupSuccess(:final link):
        await PaymentHelper.openWebpageLink(context, link, embeded: true);
        ref.read(walletControllerProvider.notifier).refresh();
        break;
      case WalletTopupFailure(:final message):
        ToastService.toastError(message);
        break;
    }
  }

  static Future<void> showWalletTransferEntry(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final s = ref.read(walletControllerProvider).valueOrNull;
    if (s?.wallet == null) return;
    final result = await context.push(
      (context) => WalletTransferPage(s!.wallet!),
    );
    if (result == null) return;
    ref.read(walletControllerProvider.notifier).refresh();
  }

  static Future<void> showMyWalletAddress(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final apiResponse =
        await ref.read(walletControllerProvider.notifier).fetchMyWalletAddress();
    if (!context.mounted) return;
    if (apiResponse.allGood) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => WalletAddressBottomSheet(apiResponse),
      );
    } else {
      ToastService.toastError(
        apiResponse.message ?? "Error loading wallet address".tr(),
      );
    }
  }
}
