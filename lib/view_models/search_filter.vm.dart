import 'package:flutter/material.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/search_data.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/requests/search.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class SearchFilterViewModel extends MyBaseViewModel {
  //
  SearchRequest _searchRequest = SearchRequest();
  SearchData? searchData;
  String keyword = "";
  Search? search;
  int selectTagId = 2;
  bool filterByProducts = true;

  DeliveryAddress? selectedDeliveryAddress;
  int? ratting;

  setSelectedDeliveryAddress(DeliveryAddress address) {
    selectedDeliveryAddress = address;
    notifyListeners();
  }
  setRatting(int? value) {
    ratting = value;
    notifyListeners();
  }

  clearFilter() {
    selectedDeliveryAddress = null;
    ratting = null;
    notifyListeners();
  }

  SearchFilterViewModel(BuildContext context, this.search) {
    this.viewContext = context;
    this.vendorType = this.search?.vendorType;
    //
    fetchSearchData();
  }

  fetchSearchData() async {
    //
    if (searchData != null) {
      return;
    }
    //
    try {
      setBusyForObject(searchData, true);
      searchData = await _searchRequest.getSearchFilterData(
        vendorTypeId: vendorType?.id ?? search?.vendorType?.id,
      );
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(searchData, false);
  }
}
