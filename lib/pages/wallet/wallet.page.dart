import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_easy_refresh_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/finance/wallet_management.view.dart';
import 'package:fuodz/component/list/wallet_transaction.list_item.dart';
import 'package:fuodz/providers/wallet_providers.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(walletControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(walletControllerProvider);
    final notifier = ref.read(walletControllerProvider.notifier);
    final s = asyncState.valueOrNull;
    final transactions = s?.transactions ?? const [];

    return BasePage(
      title: "Wallet".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: CustomEasyRefreshView(
        refreshOnStart: false,
        onRefresh: () => notifier.refresh(),
        onLoad: () => notifier.loadMore(),
        dataset: const [],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        separator: 0.heightBox,
        loading: asyncState.isLoading && s == null,
        child: SingleChildScrollView(
          child: VStack([
            const WalletManagementView(breif: false),
            VStack([
              "Wallet Transactions".tr().text.bold.xl.make(),
              CustomListView(
                noScrollPhysics: true,
                isLoading: asyncState.isLoading && transactions.isEmpty,
                dataSet: transactions,
                itemBuilder:
                    (context, index) =>
                        WalletTransactionListItem(transactions[index]),
                separatorBuilder: (_, __) => 10.heightBox,
              ),
            ], spacing: 10).px20(),
          ], spacing: 10),
        ),
      ),
    );
  }
}
