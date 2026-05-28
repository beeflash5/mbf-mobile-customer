import 'package:flutter/material.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ResechuldeViewModel extends MyBaseViewModel {
  //
  VendorRequest vendorRequest = VendorRequest();
  Order order;
  Function onSubmitted;
  int rating = 1;
  TextEditingController reviewTEC = TextEditingController();
  String? deliverySlotDate;
  String? deliverySlotTime;
  List<String> availableTimeSlots = [];
  List<Map<String, dynamic>> tables = [];

  Vendor? currentOrderVendor;
  String? tableSelected;

  changeSelectedDeliveryDate(String string, int index) {
    print("testing ${string}");
    deliverySlotDate = string;
    availableTimeSlots = currentOrderVendor!.deliverySlots[index].times;
    getTableUse();
    notifyListeners();
  }

  changeSelectedDeliveryTime(String time) {
    deliverySlotTime = time;
    notifyListeners();
  }

  void selectTableSelecte(String selected) {
    tableSelected = selected;
    notifyListeners();
  }

  void initialise() async {
    await fetchVendorDetails();
  }

  getTableUse() async {
    //
    setBusyForObject(getTableUse, true);
    try {
      final response = await vendorRequest.vendorGetTableUse(
        currentOrderVendor!.id,
        deliverySlotDate!,
        order.id,
      );

      print("testing ${response.body}");

      // final List tableIsi = [3, 4];
      tables.clear();
      final List<int> tableIsi = List<int>.from(response.body);
      for (int i = 1; i <= currentOrderVendor!.qty_tables!; i++) {
        tables.add({"name": "$i", "available": !tableIsi.contains(i)});
      }
      notifyListeners();
    } catch (error) {
      print("Error Getting Vendor Details ==> $error");
    }
    setBusyForObject(getTableUse, false);
  }

  fetchVendorDetails() async {
    //
    //
    setBusy(true);
    try {
      currentOrderVendor = await vendorRequest.vendorDetails(
        order.vendorId!,
        params: {"type": "brief"},
      );
    } catch (error) {
      print("Error Getting Vendor Details ==> $error");
    }
    setBusy(false);
    notifyListeners();
  }

  //
  ResechuldeViewModel(BuildContext context, this.order, this.onSubmitted) {
    this.viewContext = context;
  }

  void updateRating(String value) {
    rating = double.parse(value).ceil();
  }

  reschudule() async {
    setBusy(true);
    //
    final apiResponse = await vendorRequest.vendorReschulde(
      schedule_date: deliverySlotDate!,
      schedule_time: deliverySlotTime!,
      selected_table_id: tableSelected!,
      order_id: order.id,
    );
    setBusy(false);

    //
    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Reschedule".tr(),
      text: apiResponse.message,
      onConfirm:
          apiResponse.allGood
              ? () {
                onSubmitted();
              }
              : null,
    );
  }
}
