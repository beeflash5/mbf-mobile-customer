import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/order_summary_booking.dart';
import 'package:fuodz/component/currency_conversion_notice.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/pages/checkout/widgets/payment_methods.view.dart';
import 'package:fuodz/pages/checkout/widgets/schedule_order.view.dart';
import 'package:fuodz/pages/service/widgets/service_delivery_address.view.dart';
import 'package:fuodz/pages/service/widgets/service_discount_section.dart';
import 'package:fuodz/providers/service_booking_summary_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ServiceBookingSummaryPage extends ConsumerStatefulWidget {
  const ServiceBookingSummaryPage(this.service, {super.key});

  final Service service;

  @override
  ConsumerState<ServiceBookingSummaryPage> createState() =>
      _ServiceBookingSummaryPageState();
}

class _ServiceBookingSummaryPageState
    extends ConsumerState<ServiceBookingSummaryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
            serviceBookingSummaryControllerProvider(widget.service).notifier,
          )
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      serviceBookingSummaryControllerProvider(widget.service),
    );
    final controller = ref.read(
      serviceBookingSummaryControllerProvider(widget.service).notifier,
    );
    final service = state.service;
    final vendor = state.vendor;

    return BasePage(
      appBarItemColor: Colors.black,
      appBarColor: Colors.white,
      showAppBar: true,
      title: Text(
        "Booking Summary".tr(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      showLeadingAction: true,
      body:
          Column(
            children: [
              Container(
                height: 130,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: HStack([
                  CustomImage(
                    imageUrl:
                        service.photos.isNotEmpty ? service.photos.first : null,
                    width: 130,
                    height: 130,
                    boxFit: BoxFit.cover,
                  ),
                  VStack([
                    service.name.text.xl2
                        .maxLines(2)
                        .color(Colors.white)
                        .bold
                        .ellipsis
                        .make(),
                    service.vendor.name.text.xl
                        .maxLines(2)
                        .color(Colors.white)
                        .sm
                        .ellipsis
                        .make(),
                  ]).px12().expand(),
                ]),
              ),
              VStack([
                VStack([
                      if (service.selectedOptions.isNotEmpty)
                        VStack([
                          "Selected Options".tr().text.semiBold.make(),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children:
                                service.selectedOptions.map((option) {
                                  return HStack([
                                    option.name.text.make().expand(),
                                    10.widthBox,
                                    "${AppStrings.currentCurrencySymbol} ${option.price.convertCurrency}"
                                        .currencyFormat()
                                        .text
                                        .bold
                                        .make(),
                                  ]);
                                }).toList(),
                          ),
                          Sizes.paddingSizeSmall.heightBox,
                        ]).px(Sizes.paddingSizeDefault),
                    ], spacing: Sizes.paddingSizeSmall).box
                    .color(context.theme.colorScheme.surface)
                    .outerShadow
                    .withRounded(value: Sizes.radiusDefault)
                    .clip(Clip.antiAlias)
                    .make(),
                Divider(thickness: 1, height: 1, color: Vx.zinc300).py12(),
                const SizedBox(height: 4),

                if (state.banner != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.red],
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 10,
                              ),
                              3.widthBox,
                              "SPECIAL CAMPAIGN".text.white
                                  .size(9)
                                  .semiBold
                                  .make(),
                            ],
                          ),
                        ),
                        ClipRRect(
                          child: Image.network(
                            state.banner?.imageUrl ?? "",
                            width: double.infinity,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "${state.banner?.campaignTitle ?? '-'}".text
                                  .size(11)
                                  .semiBold
                                  .maxLines(1)
                                  .ellipsis
                                  .make(),
                              2.heightBox,
                              "${state.banner?.campaignDesc ?? '-'}".text
                                  .size(9)
                                  .color(Colors.grey)
                                  .maxLines(2)
                                  .ellipsis
                                  .make(),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child:
                                        "Promo Active".text
                                            .size(8)
                                            .semiBold
                                            .color(Colors.orange.shade700)
                                            .make(),
                                  ),
                                  5.widthBox,
                                  "Limited Offer".text
                                      .size(8)
                                      .color(Colors.grey)
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (state.vendorTypeId == 13)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Schedule Date & Time (always required for tattoo) ---
                      Text(
                        "Schedule",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Do you want to schedule this order?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  final dateStr =
                                      picked.toIso8601String().substring(0, 10);
                                  controller.setTattooScheduleDate(dateStr);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.checkout.deliverySlotDate
                                                .isNotEmpty
                                            ? state.checkout.deliverySlotDate
                                            : "Schedule Date",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              state.checkout.deliverySlotDate
                                                      .isNotEmpty
                                                  ? Colors.black87
                                                  : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  final h = picked.hour
                                      .toString()
                                      .padLeft(2, '0');
                                  final m = picked.minute
                                      .toString()
                                      .padLeft(2, '0');
                                  controller.setTattooScheduleTime(
                                    '$h:$m:00',
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.checkout.deliverySlotTime
                                                .isNotEmpty
                                            ? state.checkout.deliverySlotTime
                                            : "Schedule Time",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              state.checkout.deliverySlotTime
                                                      .isNotEmpty
                                                  ? Colors.black87
                                                  : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Tattoo Type ---
                      DropdownButtonFormField<String>(
                        value: state.selectTattoType,
                        items: const [
                          DropdownMenuItem(
                            value: "Black / Grey",
                            child: Text("Black / Grey"),
                          ),
                          DropdownMenuItem(
                            value: "Full Colour",
                            child: Text("Full Colour"),
                          ),
                        ],
                        onChanged: controller.onSelectTattooType,
                        decoration: const InputDecoration(
                          labelText: "Tatto Type",
                          hintText: "Select",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextFormField(
                        labelText: "Tatto Placement".tr(),
                        textEditingController: controller.tattooPlacementTEC,
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        labelText: "Tatto Size".tr(),
                        textEditingController: controller.tattooSizeTEC,
                      ),
                      const SizedBox(height: 10),
                      VStack([
                        "Please upload references of designs or themes you are interested in"
                            .text
                            .make(),
                        Stack(
                          children: [
                            state.newPhoto != null
                                ? Image.file(state.newPhoto!, fit: BoxFit.cover)
                                    .wh(Vx.dp64 * 1.3, Vx.dp64 * 1.3)
                                    .box
                                    .rounded
                                    .clip(Clip.antiAlias)
                                    .make()
                                : Image.asset(AppImages.noImage),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: const Icon(Icons.camera_alt, size: 16)
                                  .p8()
                                  .box
                                  .color(context.theme.colorScheme.surface)
                                  .roundedFull
                                  .shadow
                                  .make()
                                  .onInkTap(controller.changePhoto),
                            ),
                          ],
                        ).box.makeCentered(),
                      ]).py(10),
                    ],
                  ),

                CustomTextFormField(
                  labelText: "Note".tr(),
                  textEditingController: controller.noteTEC,
                ),
                UiSpacer.verticalSpace(),

                // ScheduleOrderView shown for non-tattoo services only
                if (vendor != null && state.vendorTypeId != 13)
                  ScheduleOrderView(
                    vendor: vendor,
                    isScheduled: state.isScheduled,
                    onToggleScheduled: controller.toggleScheduledOrder,
                    selectedDate: state.checkout.deliverySlotDate,
                    selectedTime: state.checkout.deliverySlotTime,
                    availableTimeSlots: state.availableTimeSlots,
                    dateFull: state.dateFull,
                    timeFull: state.timeFull,
                    onSelectDate: controller.changeSelectedDeliveryDate,
                    onSelectTime: controller.changeSelectedDeliveryTime,
                    loadingTime: state.loadingTime,
                    loadingTables: state.loadingTables,
                    tables: state.tables,
                    tableSelected: state.tableSelected,
                    guestCountController: controller.guestCountTEC,
                    onSelectTable: controller.selectTableSelecte,
                  ),

                if (service.duration != "fixed")
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffD9D9D9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            "Stay Duration".text.bold.lg.make(),
                            "Choose how long you’ll stay".text
                                .color(const Color(0xff808080))
                                .make(),
                          ],
                        ).expand(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: controller.decrementDuration,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "${state.durationQty}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.incrementDuration,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                if (service.agebasePrice != null &&
                    service.agebasePrice!.isNotEmpty)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffD9D9D9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        "Guest".text.bold.lg.make(),
                        state.guests
                            .where((g) => g.qty > 0)
                            .map((g) => "${g.qty} ${g.name}")
                            .join(", ")
                            .text
                            .color(context.primaryColor)
                            .make(),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffD9D9D9)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.guests.length,
                            itemBuilder: (context, index) {
                              final agePrice = state.guests[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            agePrice.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            agePrice.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => controller.decrementGuest(
                                            agePrice.id,
                                          ),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        "${agePrice.qty}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => controller.incrementGuest(
                                            agePrice.id,
                                          ),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                if (service.guide != null && service.guide!.isNotEmpty)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffD9D9D9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        "Guide".text.bold.lg.make(),
                        "Enhance your trip with a local guide".text
                            .color(const Color(0xff808080))
                            .make(),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.guidSelected,
                              hint: const Text(
                                "Select Language",
                                style: TextStyle(fontSize: 16),
                              ),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              items:
                                  service.guide
                                      ?.map(
                                        (lang) => DropdownMenuItem<String>(
                                          value: lang.lang,
                                          child: Text(lang.lang),
                                        ),
                                      )
                                      .toList(),
                              onChanged: controller.setGuide,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                if (service.location &&
                    service.vendor.vendorType.slug.toLowerCase() != 'tattoo')
                  ServiceDeliveryAddressPickerView(
                    service: service,
                    deliveryAddress: state.deliveryAddress,
                    deliveryAddressOutOfRange: state.deliveryAddressOutOfRange,
                    onPickAddress:
                        () => controller.pickDeliveryAddress(context),
                  ),
                Divider(thickness: 1, height: 1, color: Vx.zinc300).py12(),

                if (state.vendorTypeId != 13)
                  DottedBorder(
                    dashPattern: const [5, 1],
                    color: AppColor.accentColor,
                    child:
                        ServiceDiscountSection(
                              couponController: controller.couponTEC,
                              canApply: state.canApplyCoupon,
                              applying: state.couponBusy,
                              onChanged: controller.couponCodeChange,
                              onApply: controller.applyCoupon,
                              errorText: state.couponError?.toString(),
                            )
                            .p20()
                            .box
                            .color(AppColor.accentColor.withOpacity(0.10))
                            .clip(Clip.antiAlias)
                            .roundedSM
                            .make(),
                    radius: const Radius.circular(10),
                    borderType: BorderType.RRect,
                    padding: const EdgeInsets.all(0),
                  ).py12(),
                const DottedLine().py12(),

                if (service.ageRestricted)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.ageConfirmed,
                          onChanged: controller.toggleAgeConfirmed,
                          activeColor: AppColor.primaryColor,
                        ),
                        Expanded(
                          child:
                              "I confirm that I meet the age requirement to purchase this service. (Saya menyetujui bahwa saya cukup umur untuk membeli layanan ini)"
                                  .text
                                  .size(12)
                                  .color(Colors.orange.shade800)
                                  .make(),
                        ),
                      ],
                    ),
                  ),

                if (state.vendorTypeId != 13)
                  PaymentMethodsView(
                    paymentMethods: state.paymentMethods,
                    selectedPaymentMethod: state.selectedPaymentMethod,
                    onSelected: controller.changeSelectedPaymentMethod,
                  ),

                LoadingShimmer(
                  loading: state.isBusy,
                  child: OrderSummaryBooking(
                    total: state.checkout.total,
                    deliverySlotDate: state.checkout.deliverySlotDate,
                    deliverySlotTime: state.checkout.deliverySlotTime,
                    guests: state.guests,
                    duration: service.duration,
                    durationQty: state.durationQty,
                    guidSelected: state.guidSelected,
                    selectedPaymentMethod: state.selectedPaymentMethod,
                    subTotal: state.checkout.subTotal,
                    discount: state.checkout.discount,
                    deliveryFee:
                        service.location ? state.checkout.deliveryFee : null,
                    tax: state.checkout.tax,
                    vendorTax: vendor?.tax,
                    fees: vendor?.fees ?? const [],
                    allowConvert: true,
                  ),
                ),
                if (AppCurrencySystemService().currentCurrencyCode !=
                        AppStrings.currencyCode &&
                    !state.isBusy)
                  CurrencyConversionNotice(
                    convertedAmount:
                        state.checkout.totalWithTip.convertCurrency,
                    originalAmount: state.checkout.totalWithTip,
                    baseCurrency: AppStrings.currencyCode,
                  ).py(Sizes.paddingSizeDefault),
                Divider(thickness: 1, height: 1, color: Vx.zinc300).py12(),

                CustomButton(
                  title: "Book Now".tr().padRight(14),
                  icon: Icons.credit_card,
                  loading: state.isBusy,
                  onPressed: () => controller.placeOrder(context),
                ).wFull(context),
              ]).p20(),
            ],
          ).scrollVertical(),
    );
  }
}
