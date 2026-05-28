import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/tag.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/search_filter.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class SearchFilterBottomSheet extends StatelessWidget {
  const SearchFilterBottomSheet({
    Key? key,
    required this.onSubmitted,
    required this.vm,
    required this.search,
  }) : super(key: key);

  //
  final Search? search;
  final SearchFilterViewModel vm;
  final Function(Search) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchFilterViewModel>.reactive(
      viewModelBuilder: () => vm,
      onViewModelReady: (vm) => vm.fetchSearchData(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: context.percentHeight * 90),
            child:
                VStack([
                  UiSpacer.swipeIndicator(),
                  UiSpacer.vSpace(),

                  //
                  (vm.busy(vm.searchData))
                      ? BusyIndicator().centered().p20()
                      : VStack([
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.close).onInkTap(() {
                              context.pop();
                            }),
                            SizedBox(width: 6),
                            "Refine Your Search".text.lg.semiBold.make(),
                            Spacer(),
                            "Clear".text.sm.semiBold
                                .color(const Color(0xff1B8A9E))
                                .make()
                                .onInkTap(() {
                                  search?.deliveryAddress = null;
                                  search?.minPrice = "0";
                                  search?.maxPrice = "1000000";
                                  search?.ratting = null;

                                  vm.ratting = null;

                                  vm.notifyListeners();
                                }),
                          ],
                        ),

                        SizedBox(height: 16),
                        Container(
                          width: context.screenWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFE3E3E3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              "Location".text.lg.semiBold.make(),
                              SizedBox(height: 8),
                              "Choose your preferred area for convenience and accessibility"
                                  .text
                                  .color(Color(0xff828282))
                                  .make(),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFE3E3E3)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    search?.deliveryAddress != null
                                        ? VStack([
                                          "${search?.deliveryAddress?.address}"
                                              .text
                                              .overflow(TextOverflow.ellipsis)
                                              .semiBold
                                              .make(),
                                        ]).expand()
                                        : "Choose location".text
                                            .color(Color(0xff879092))
                                            .make()
                                            .expand(),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ).onTap(() {
                                vm.pickDeliveryAddress2(
                                  onselected: (address) {
                                    search?.deliveryAddress = address;
                                  },
                                );
                              }),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        Container(
                          width: context.screenWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFE3E3E3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              "Price Range".text.lg.semiBold.make(),
                              SizedBox(height: 8),
                              "Set your budget to find options that match your price range"
                                  .text
                                  .color(Color(0xff828282))
                                  .make(),

                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbColor: Color(
                                    0xffEEC860,
                                  ), // warna bulatan
                                  // activeTrackColor: Colors.red, // garis aktif
                                  inactiveTrackColor:
                                      Colors.grey.shade300, // garis non aktif
                                  // overlayColor: Colors.red.withOpacity(0.2),
                                  rangeThumbShape:
                                      const RoundRangeSliderThumbShape(
                                        enabledThumbRadius: 10,
                                      ),
                                ),
                                child: FormBuilderRangeSlider(
                                  key: ValueKey(
                                    "${search?.minPrice}-${search?.maxPrice}",
                                  ),
                                  name: "price",
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),

                                  initialValue: RangeValues(
                                    ((double.tryParse(
                                              search?.minPrice ?? "0",
                                            ) ??
                                            0)
                                        .clamp(0, 1000000)).toDouble(),

                                    ((double.tryParse(
                                              search?.maxPrice ?? "1000000",
                                            ) ??
                                            1000000)
                                        .clamp(0, 1000000)).toDouble(),
                                  ),
                                  // initialValue: const RangeValues(0, 10000000),
                                  min: 0,
                                  max: 1000000,

                                  onChanged: (values) {
                                    search?.minPrice =
                                        values?.start.toInt().toString();

                                    search?.maxPrice =
                                        values?.end.toInt().toString();
                                  },
                                ).wFull(context),
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 14),
                                      onChanged: (val) {
                                        search?.minPrice = val.toString();
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,

                                        hintText: "Rp 0",

                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: context.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      "-",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 14),
                                      onChanged: (val) {
                                        search?.maxPrice = val.toString();
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,

                                        hintText: "Rp 1000.000",

                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: context.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: context.screenWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFE3E3E3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              "Rating".text.lg.semiBold.make(),

                              16.heightBox,

                              DropdownButtonFormField<int>(
                                key: ValueKey(search?.ratting),
                                value: search?.ratting,

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE3E3E3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE3E3E3),
                                    ),
                                  ),
                                ),

                                hint: const Text("Select rating"),

                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,

                                items: List.generate(5, (index) {
                                  final rating = index + 1;

                                  return DropdownMenuItem<int>(
                                    value: rating,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFF9800),
                                          size: 18,
                                        ),
                                        8.widthBox,
                                        Text("$rating+"),
                                      ],
                                    ),
                                  );
                                }),

                                onChanged: (value) {
                                  search?.ratting = value;

                                  vm.notifyListeners();
                                },
                              ),
                            ],
                          ),
                        ),

                        //Layout type
                        // "Layout Type".tr().text.semiBold.lg.make(),
                        // FormBuilderRadioGroup(
                        //   name: "view_type",
                        //   decoration: InputDecoration(border: InputBorder.none),
                        //   initialValue: search?.layoutType ?? "grid",
                        //   options: [
                        //     FormBuilderFieldOption(
                        //       value: "grid",
                        //       child: "GridView".tr().text.make(),
                        //     ),
                        //     FormBuilderFieldOption(
                        //       value: "list",
                        //       child: "ListView".tr().text.make(),
                        //     )
                        //   ],
                        //   onChanged: (String? value) {
                        //     search?.layoutType = value;
                        //   },
                        // ),
                        // UiSpacer.divider().py(6),
                        //sort
                        // "Sort by".tr().text.semiBold.lg.make(),
                        // FormBuilderRadioGroup(
                        //   name: "sort",
                        //   decoration: InputDecoration(border: InputBorder.none),
                        //   initialValue: search?.sort ?? "asc",
                        //   options: [
                        //     FormBuilderFieldOption(
                        //       value: "asc",
                        //       child: "Ascending (A-Z)".tr().text.make(),
                        //     ),
                        //     FormBuilderFieldOption(
                        //       value: "desc",
                        //       child: "Descending (Z-A)".tr().text.make(),
                        //     ),
                        //   ],
                        //   onChanged: (String? value) {
                        //     search?.sort = value;
                        //   },
                        // ),

                        // UiSpacer.vSpace(10),
                        // UiSpacer.divider(),
                        // UiSpacer.vSpace(10),
                        //price
                        // "Price".tr().text.semiBold.lg.make(),
                        // FormBuilderRangeSlider(
                        //   name: "price",
                        //   decoration: InputDecoration(border: InputBorder.none),
                        //   initialValue: RangeValues(
                        //     vm.searchData?.priceRange?[0] ?? 0.00,
                        //     vm.searchData?.priceRange?[1] ?? 100.00,
                        //   ),
                        //   min: vm.searchData?.priceRange?[0] ?? 0.00,
                        //   max: vm.searchData?.priceRange?[1] ?? 100.00,
                        //   onChanged: (values) {
                        //     search?.minPrice = values?.start.toString();
                        //     search?.maxPrice = values?.end.toString();
                        //   },
                        // ).wFull(context),
                        // UiSpacer.vSpace(10),
                        // UiSpacer.divider(),
                        // UiSpacer.vSpace(10),
                        //tags
                        // CustomVisibilty(
                        //   visible: (vm.searchData?.tags ?? []).isNotEmpty,
                        //   child: VStack([
                        //     "Filter by".tr().text.semiBold.lg.make(),
                        //     FormBuilderCheckboxGroup<Tag>(
                        //       name: "tag",
                        //       initialValue: search?.tags ?? [],
                        //       wrapDirection: Axis.vertical,
                        //       decoration: InputDecoration(
                        //         border: InputBorder.none,
                        //       ),
                        //       options:
                        //           (vm.searchData?.tags ?? []).map((e) {
                        //             return FormBuilderFieldOption<Tag>(
                        //               value: e,
                        //               child: e.name.text.make(),
                        //             );
                        //           }).toList(),
                        //       onChanged: (List<Tag>? values) {
                        //         search?.tags = values;
                        //       },
                        //     ),
                        //     UiSpacer.vSpace(10),
                        //     UiSpacer.divider(),
                        //     UiSpacer.vSpace(10),
                        //   ]),
                        // ),

                        //filter by location or not
                        // HStack([
                        //   Checkbox(
                        //     value: search?.byLocation,
                        //     onChanged: (value) {
                        //       search?.byLocation = value;
                        //       vm.notifyListeners();
                        //     },
                        //   ),
                        //   UiSpacer.smHorizontalSpace(),
                        //   "Filter by location".tr().text.make().expand(),
                        // ]).onInkTap(() {
                        //   search?.byLocation = !(search?.byLocation ?? true);
                        //   vm.notifyListeners();
                        // }),
                        //tags

                        //
                        CustomButton(
                          title: "Submit".tr(),
                          onPressed: () {
                            onSubmitted(search!);
                            context.pop();
                          },
                        ).centered().py16(),
                        SizedBox(height: 20),
                      ]).scrollVertical().expand(),
                ]).p20().box.topRounded().color(context.theme.colorScheme.surface).make(),
          ),
        );
        // .h(context.percentHeight * 90);
      },
    );
  }
}
