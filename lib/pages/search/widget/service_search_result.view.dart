import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/component/states/search.empty.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/main_search_providers.dart';

class ServiceSearchResultView extends ConsumerStatefulWidget {
  const ServiceSearchResultView({super.key});

  @override
  ConsumerState<ServiceSearchResultView> createState() =>
      _ServiceSearchResultViewState();
}

class _ServiceSearchResultViewState
    extends ConsumerState<ServiceSearchResultView> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(mainSearchControllerProvider);
    final notifier = ref.read(mainSearchControllerProvider.notifier);
    final state = asyncState.valueOrNull;
    final services = state?.services ?? const [];
    final isLoading = asyncState.isLoading;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return CustomMasonryGridView(
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(vertical: 10),
      refreshController: _refreshController,
      canPullUp: true,
      canRefresh: true,
      onRefresh: () => notifier.startSearch(),
      onLoading: notifier.loadMoreServices,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      isLoading: isLoading,
      childAspectRatio: (MediaQuery.of(context).size.width / 2.5) / 80,
      emptyWidget: EmptySearch(type: 'service'),
      items:
          services
              .map(
                (s) => HomeServicesListItem(
                  height: 290,
                  width: double.infinity,
                  service: s,
                  onPressed:
                      (svc) => context.pushWidget(ServiceDetailsPage(svc)),
                ),
              )
              .toList(),
    );
  }
}
