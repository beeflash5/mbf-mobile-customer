import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/review.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/service_option.dart';
import 'package:fuodz/models/service_option_group.dart';
import 'package:fuodz/requests/service.request.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/login.page.dart';
import 'package:fuodz/views/pages/service/service_booking_summary.page.dart';
import 'package:fuodz/widgets/bottomsheets/age_restriction.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/constants/app_strings.dart';

class ServiceDetailsViewModel extends MyBaseViewModel {
  //
  ServiceDetailsViewModel(BuildContext context, this.service) {
    this.viewContext = context;
  }

  //
  ServiceRequest serviceRequest = ServiceRequest();
  VendorRequest _vendorRequest = VendorRequest();

  Service service;
  List<ServiceOption> selectedOptions = [];
  List<int> selectedOptionsIDs = [];
  double subTotal = 0.0;
  double total = 0.0;
  int queryPage = 1;

  List<Review> reviews = [];
  final currencySymbol = AppStrings.currencySymbol;

  void getServiceDetails() async {
    //
    setBusy(true);

    try {
      final oldProductHeroTag = service.heroTag;
      service = await serviceRequest.serviceDetails(service.id);
      service.heroTag = oldProductHeroTag;

      await getVendorReviews();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  getVendorReviews({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mReviews = await _vendorRequest.getReviews(
        page: queryPage,
        vendorId: service.vendorId,
      );
      if (!initialLoading) {
        reviews.addAll(mReviews);
        refreshController.loadComplete();
      } else {
        reviews = mReviews;
      }
      clearErrors();
    } catch (error) {
      print("mReviews Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  void openVendorPage() {
    Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.vendorDetails, arguments: service.vendor);
  }

  //
  isOptionSelected(ServiceOption option) {
    return selectedOptionsIDs.contains(option.id);
  }

  //
  toggleOptionSelection(ServiceOptionGroup optionGroup, ServiceOption option) {
    //
    if (selectedOptionsIDs.contains(option.id)) {
      selectedOptionsIDs.remove(option.id);
      selectedOptions.remove(option);
    } else {
      //if it allows only one selection
      if (optionGroup.multiple == 0) {
        //
        final foundOption = selectedOptions.firstOrNullWhere(
          (option) => option.serviceOptionGroupId == optionGroup.id,
        );
        selectedOptionsIDs.remove(foundOption?.id);
        selectedOptions.remove(foundOption);
      }

      selectedOptionsIDs.add(option.id);
      selectedOptions.add(option);
    }

    //
    notifyListeners();
  }

  bookService() async {
    //if has options, and no option is selected but there is option group with required option
    if (service.optionGroups != null &&
        service.optionGroups!.isNotEmpty &&
        selectedOptions.isEmpty &&
        service.optionGroups!.any((optionGroup) => optionGroup.required == 1)) {
      AlertService.warning(
        title: "Aditional Option".tr(),
        text: "Please select an additional option".tr(),
      );
      return;
    }
    //check for age restriction
    if (service.ageRestricted) {
      bool? ageVerified = await showModalBottomSheet(
        context: viewContext,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AgeRestrictionBottomSheet();
        },
      );
      //
      if (ageVerified == null || !ageVerified) {
        return;
      }
    }

    if (!AuthServices.authenticated()) {
      final result = await viewContext.push((context) => LoginPage());
      //
      if (result == null || !(result is bool)) {
        return;
      }
    }

    //
    service.selectedOptions = selectedOptions;
    viewContext.push((context) => ServiceBookingSummaryPage(service));
  }
}
