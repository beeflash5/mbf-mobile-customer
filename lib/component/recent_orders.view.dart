import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/order.list_item.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import "package:fuodz/pages/order/orders_details.page.dart";
import 'package:fuodz/providers/recent_order_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RecentOrdersView extends ConsumerWidget {
  const RecentOrdersView({super.key, this.vendorType, this.emptyView});

  final VendorType? vendorType;
  final Widget? emptyView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = AuthServices.authenticated();
    if (!isAuth) {
      return VStack([
        'Recent Orders'.tr().text.make(),
        UiSpacer.verticalSpace(),
        EmptyState(
          auth: true,
          showAction: true,
          actionPressed:
              () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => LoginPage())),
        ).py12().centered(),
      ]).px20();
    }

    final args = vendorType?.id ?? 0;
    final asyncOrders = ref.watch(recentOrdersControllerProvider(args));
    final orders = asyncOrders.valueOrNull ?? const [];

    return VStack([
      'Recent Orders'.tr().text.make(),
      UiSpacer.verticalSpace(),
      CustomListView(
        isLoading: asyncOrders.isLoading,
        noScrollPhysics: true,
        dataSet: orders,
        emptyWidget: emptyView,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderListItem(
            order: order,
            orderPressed:
                () => context.pushWidget(OrderDetailsPage(order: order)),
            onPayPressed: () {
              final link = order.paymentLink;
              if (link.isNotEmpty) launchUrlString(link);
            },
          );
        },
        separatorBuilder: (context, index) => UiSpacer.verticalSpace(space: 2),
      ),
    ]).px20();
  }
}
