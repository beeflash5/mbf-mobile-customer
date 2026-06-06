import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/delivery_address_picker.bottomsheet.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/providers/search_filter_providers.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SearchFilterBottomSheet extends ConsumerStatefulWidget {
  const SearchFilterBottomSheet({
    super.key,
    required this.onSubmitted,
    required this.search,
  });

  final Search? search;
  final Function(Search) onSubmitted;

  @override
  ConsumerState<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState
    extends ConsumerState<SearchFilterBottomSheet> {
  int _refreshKey = 0;

  void _pickAddress() async {
    DeliveryAddress? selected;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryAddressPicker(
        onSelectDeliveryAddress: (addr) {
          selected = addr;
          Navigator.of(context).pop();
        },
      ),
    );
    if (selected != null) {
      setState(() {
        widget.search?.deliveryAddress = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vtId = widget.search?.vendorType?.id ?? 0;
    final asyncState = ref.watch(searchFilterControllerProvider(vtId));
    final loading = asyncState.isLoading;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.percentHeight * 90),
        child: VStack([
          UiSpacer.swipeIndicator(),
          UiSpacer.vSpace(),
          if (loading)
            BusyIndicator().centered().p20()
          else
            VStack([
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.close).onInkTap(() => context.pop()),
                  const SizedBox(width: 6),
                  "Refine Your Search".text.lg.semiBold.make(),
                  const Spacer(),
                  "Clear"
                      .text
                      .sm
                      .semiBold
                      .color(const Color(0xff1B8A9E))
                      .make()
                      .onInkTap(() {
                    setState(() {
                      widget.search?.deliveryAddress = null;
                      widget.search?.minPrice = "0";
                      widget.search?.maxPrice = "1000000";
                      widget.search?.ratting = null;
                      _refreshKey++;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: context.screenWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Location".text.lg.semiBold.make(),
                    const SizedBox(height: 8),
                    "Choose your preferred area for convenience and accessibility"
                        .text
                        .color(const Color(0xff828282))
                        .make(),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE3E3E3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          widget.search?.deliveryAddress != null
                              ? VStack([
                                  "${widget.search?.deliveryAddress?.address}"
                                      .text
                                      .overflow(TextOverflow.ellipsis)
                                      .semiBold
                                      .make(),
                                ]).expand()
                              : "Choose location"
                                  .text
                                  .color(const Color(0xff879092))
                                  .make()
                                  .expand(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ).onTap(_pickAddress),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: context.screenWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Price Range".text.lg.semiBold.make(),
                    const SizedBox(height: 8),
                    "Set your budget to find options that match your price range"
                        .text
                        .color(const Color(0xff828282))
                        .make(),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbColor: const Color(0xffEEC860),
                        inactiveTrackColor: Colors.grey.shade300,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: FormBuilderRangeSlider(
                        key: ValueKey(
                          "${widget.search?.minPrice}-${widget.search?.maxPrice}-$_refreshKey",
                        ),
                        name: "price",
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        initialValue: RangeValues(
                          (double.tryParse(widget.search?.minPrice ?? "0") ?? 0)
                              .clamp(0, 1000000)
                              .toDouble(),
                          (double.tryParse(widget.search?.maxPrice ?? "1000000") ??
                                  1000000)
                              .clamp(0, 1000000)
                              .toDouble(),
                        ),
                        min: 0,
                        max: 1000000,
                        onChanged: (values) {
                          widget.search?.minPrice =
                              values?.start.toInt().toString();
                          widget.search?.maxPrice =
                              values?.end.toInt().toString();
                        },
                      ).wFull(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: context.screenWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Rating".text.lg.semiBold.make(),
                    16.heightBox,
                    DropdownButtonFormField<int>(
                      key: ValueKey("${widget.search?.ratting}-$_refreshKey"),
                      value: widget.search?.ratting,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE3E3E3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE3E3E3)),
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
                        setState(() => widget.search?.ratting = value);
                      },
                    ),
                  ],
                ),
              ),
              CustomButton(
                title: "Submit".tr(),
                onPressed: () {
                  widget.onSubmitted(widget.search!);
                  context.pop();
                },
              ).centered().py16(),
              const SizedBox(height: 20),
            ]).scrollVertical().expand(),
        ])
            .p20()
            .box
            .topRounded()
            .color(context.theme.colorScheme.surface)
            .make(),
      ),
    );
  }
}
