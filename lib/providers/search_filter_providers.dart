import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/search_data.dart';
import 'package:fuodz/services/search.request.dart';

final _searchRequestProvider =
    Provider<SearchRequest>((_) => SearchRequest());

class SearchFilterState {
  const SearchFilterState({
    this.searchData,
    this.selectedDeliveryAddress,
    this.rating,
    this.selectedTagId = 2,
    this.filterByProducts = true,
  });
  final SearchData? searchData;
  final DeliveryAddress? selectedDeliveryAddress;
  final int? rating;
  final int selectedTagId;
  final bool filterByProducts;

  SearchFilterState copyWith({
    SearchData? searchData,
    DeliveryAddress? selectedDeliveryAddress,
    int? rating,
    int? selectedTagId,
    bool? filterByProducts,
    bool clearAddress = false,
    bool clearRating = false,
  }) =>
      SearchFilterState(
        searchData: searchData ?? this.searchData,
        selectedDeliveryAddress: clearAddress
            ? null
            : (selectedDeliveryAddress ?? this.selectedDeliveryAddress),
        rating: clearRating ? null : (rating ?? this.rating),
        selectedTagId: selectedTagId ?? this.selectedTagId,
        filterByProducts: filterByProducts ?? this.filterByProducts,
      );
}

/// Search filter state keyed by vendorTypeId (0 = no filter).
class SearchFilterController
    extends FamilyAsyncNotifier<SearchFilterState, int> {
  @override
  Future<SearchFilterState> build(int arg) async {
    final data = await ref
        .read(_searchRequestProvider)
        .getSearchFilterData(vendorTypeId: arg == 0 ? null : arg);
    return SearchFilterState(searchData: data);
  }

  void setAddress(DeliveryAddress address) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(selectedDeliveryAddress: address));
  }

  void setRating(int? value) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(rating: value, clearRating: value == null));
  }

  void clearFilter() {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(clearAddress: true, clearRating: true));
  }
}

final searchFilterControllerProvider = AsyncNotifierProvider.family<
    SearchFilterController, SearchFilterState, int>(
  SearchFilterController.new,
);
