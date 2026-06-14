import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/loyalty_point_report.list_item.dart';
import 'package:fuodz/component/states/loading_indicator.dart';
import 'package:fuodz/component/states/loyalty_point.empty.dart';
import 'package:fuodz/pages/loyalty/widgets/loyalty_point_withdrawal_entry.bottomsheet.dart';
import 'package:fuodz/providers/loyalty_point_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_finance_settings.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class LoyaltyPointPage extends ConsumerWidget {
  const LoyaltyPointPage({super.key});

  void _showAmountEntry(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => LoyaltyPointWithdrawalEntryBottomSheet(
            onSubmit: (String points) async {
              Navigator.of(context).pop();
              final result = await ref
                  .read(loyaltyPointControllerProvider.notifier)
                  .withdrawPoints(points);
              if (!context.mounted) return;
              switch (result) {
                case WithdrawSuccess(:final message):
                  AlertService.success(
                    title: "Loyalty Points".tr(),
                    text: message,
                  );
                  break;
                case WithdrawFailure(:final message):
                  AlertService.error(
                    title: "Loyalty Points".tr(),
                    text: message,
                  );
                  break;
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(loyaltyPointControllerProvider);
    final state = asyncState.valueOrNull;
    final isBusy = asyncState.isLoading;
    final loyaltyPoint = state?.loyaltyPoint;
    final estimatedAmount = state?.estimatedAmount ?? 0;
    final reports = state?.reports ?? const [];

    return BasePage(
      title: "Loyalty Points".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body:
          VStack([
            UiSpacer.vSpace(),
            LoadingIndicator(
              loading: isBusy,
              child: GlassContainer(
                height: 130,
                margin: EdgeInsets.zero,
                width: context.screenWidth,
                borderColor: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor.withOpacity(0.35),
                    AppColor.primaryColor.withOpacity(0.50),
                    AppColor.primaryColor.withOpacity(0.80),
                    AppColor.primaryColor.withOpacity(0.99),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.30, 0.60, 1.0],
                ),
                blur: 5.0,
                isFrostedGlass: true,
                frostedOpacity: 0.50,
                shadowColor: AppColor.primaryColor.withOpacity(0.50),
                child:
                    HStack([
                      HStack(
                        [
                          "${loyaltyPoint?.points ?? 0}".text.xl6.semiBold
                              .shadow(0.0, 0.0, 2.0, AppColor.primaryColor)
                              .color(Utils.textColorByTheme())
                              .make(),
                          "Points"
                              .tr()
                              .text
                              .xl
                              .shadow(0.0, 0.0, 2.0, AppColor.primaryColor)
                              .color(Utils.textColorByTheme())
                              .make()
                              .px4()
                              .pOnly(bottom: 15)
                              .expand(),
                        ],
                        crossAlignment: CrossAxisAlignment.end,
                        alignment: MainAxisAlignment.end,
                      ).p12().expand(),
                      VStack([
                        ("~ " +
                                "${AppStrings.currencySymbol}$estimatedAmount"
                                    .currencyFormat())
                            .text
                            .semiBold
                            .xl
                            .color(Utils.textColorByTheme())
                            .make(),
                        "Exchange Rate"
                            .tr()
                            .text
                            .sm
                            .color(Utils.textColorByTheme())
                            .make(),
                        ("1 point".tr() +
                                " = " +
                                "${AppStrings.currencySymbol} ${AppFinanceSettings.loyaltyPointsToAmount}"
                                    .currencyFormat())
                            .text
                            .medium
                            .color(Utils.textColorByTheme())
                            .make(),
                      ]),
                    ]).p12(),
              ),
            ).px20(),
            UiSpacer.vSpace(5),
            CustomButton(
              title: "Withdraw To Wallet".tr(),
              loading: isBusy,
              onPressed: () => _showAmountEntry(context, ref),
            ).px24().wFull(context),
            UiSpacer.divider().px20().py20(),
            "Recent report".tr().text.semiBold.lg.make().px20(),
            UiSpacer.vSpace(10),
            CustomListView(
              isLoading: isBusy && reports.isEmpty,
              dataSet: reports,
              noScrollPhysics: true,
              itemBuilder:
                  (ctx, index) => LoyaltyPointReportListItem(reports[index]),
              separatorBuilder: (ctx, index) => UiSpacer.vSpace(10),
              emptyWidget: EmptyLoyaltyPointReport(),
            ).px20(),
            UiSpacer.vSpace(),
          ]).scrollVertical(),
    );
  }
}
