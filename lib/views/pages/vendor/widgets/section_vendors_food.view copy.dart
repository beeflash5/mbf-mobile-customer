import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/view_models/vendor/section_vendors.vm.dart';
import 'package:fuodz/widgets/card_vendor.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/states/vendor.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionVendorsFoodView extends StatefulWidget {
  const SectionVendorsFoodView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = SearchFilterType.sales,
    this.itemWidth,
    this.viewType,
    this.separator,
    this.byLocation = false,
    this.itemsPadding,
    this.titlePadding,
    this.hideEmpty = false,
    this.onSeeAllPressed,
    this.itemBuilder,
    this.spacer,
    Key? key,
  }) : super(key: key);

  final VendorType? vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final bool hideEmpty;
  final Function? onSeeAllPressed;
  final Widget Function(BuildContext, int, Vendor)? itemBuilder;
  final double? spacer;

  @override
  State<SectionVendorsFoodView> createState() => _SectionVendorsViewState();
}

class _SectionVendorsViewState extends State<SectionVendorsFoodView> {
  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<SectionVendorsViewModel>.reactive(
        viewModelBuilder:
            () => SectionVendorsViewModel(
              context,
              widget.vendorType,
              type: widget.type,
              byLocation: widget.byLocation,
            ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          Widget listView = CustomListView(
            scrollDirection: Axis.vertical,
            dataSet: model.vendors,
            isLoading: model.isBusy,

            noScrollPhysics: true,
            itemBuilder:
                widget.itemBuilder != null
                    ? (ctx, index) {
                      return widget.itemBuilder!(
                        ctx,
                        index,
                        model.vendors[index],
                      );
                    }
                    : (context, index) {
                      final vendor = model.vendors[index];

                      return CardVendor(
                        vendor: vendor,
                        onPressed: model.vendorSelected,
                      ).px(16).wFull(context);
                    },

            emptyWidget: EmptyVendor(),
          );

          return Visibility(
            visible: !widget.hideEmpty || model.vendors.isNotEmpty,
            child: VStack([
              listView.h(230),
              listView.wFull(context),
            ], spacing: widget.spacer ?? 0),
          );
        },
      ),
    );
  }
}
