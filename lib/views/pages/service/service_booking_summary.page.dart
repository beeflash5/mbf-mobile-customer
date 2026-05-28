import 'package:dartx/dartx.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/service_booking_summary.vm.dart';
import 'package:fuodz/views/pages/checkout/widgets/payment_methods.view.dart';
import 'package:fuodz/views/pages/checkout/widgets/schedule_order.view.dart';
import 'package:fuodz/views/pages/service/widgets/service_delivery_address.view.dart';
import 'package:fuodz/views/pages/service/widgets/service_details_price.section.dart';
import 'package:fuodz/views/pages/service/widgets/service_discount_section.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/order_summary.dart';
import 'package:fuodz/widgets/cards/order_summary_booking.dart';
import 'package:fuodz/widgets/currency_conversion_notice.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceBookingSummaryPage extends StatelessWidget {
  const ServiceBookingSummaryPage(this.service, {Key? key}) : super(key: key);

  //
  final Service service;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ServiceBookingSummaryViewModel>.reactive(
      viewModelBuilder: () => ServiceBookingSummaryViewModel(context, service),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          appBarItemColor: Colors.black,
          appBarColor: Colors.white,
          showAppBar: true,
          title: Text(
            "Booking Summary".tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          showLeadingAction: true,
          body:
              Column(
                children: [
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/bg.png"),
                        fit: BoxFit.cover,
                      ),
                    ),

                    child: HStack([
                      //service logo
                      CustomImage(
                        // imageUrl: vm.service!.photos.first,
                        imageUrl:
                            vm.service!.photos.isNotEmpty
                                ? vm.service!.photos.first
                                : null,
                        width: 130,
                        height: 130,
                        boxFit: BoxFit.cover,
                      ),
                      //service details
                      VStack([
                        vm.service!.name.text.xl2
                            .maxLines(2)
                            .color(Colors.white)
                            .bold
                            .ellipsis
                            .make(),
                        // 2.heightBox,
                        vm.service!.vendor.name.text.xl
                            .maxLines(2)
                            .color(Colors.white)
                            .sm
                            .ellipsis
                            .make(),
                        //price
                        // ServiceDetailsPriceSectionView(
                        //   service,
                        //   onlyPrice: true,
                        //   showDiscount: true,
                        // ),
                        //selected hours
                        // if (!vm.service!.isFixed)
                        //   HStack([
                        //     "${vm.service!.duration.capitalize().tr()}:".text
                        //         // .sm
                        //         .make(),
                        //     //
                        //     "${vm.service!.selectedQty}"
                        //         .text
                        //         // .sm
                        //         .bold
                        //         .make(),
                        //   ], spacing: 5),
                      ]).px12().expand(),
                    ]),
                  ),
                  VStack([
                    VStack([
                          //service details in summary page
                          // HStack([
                          //   //service logo
                          //   CustomImage(
                          //     imageUrl: vm.service!.photos.first,
                          //     width: context.percentWidth * 18,
                          //     height: 80,
                          //     boxFit: BoxFit.contain,
                          //   ),
                          //   //service details
                          //   VStack([
                          //     vm.service!.name.text.xl
                          //         .maxLines(2)
                          //         .ellipsis
                          //         .make(),
                          //     5.heightBox,
                          //     //price
                          //     ServiceDetailsPriceSectionView(
                          //       service,
                          //       onlyPrice: true,
                          //       showDiscount: true,
                          //     ),
                          //     //selected hours
                          //     if (!vm.service!.isFixed)
                          //       HStack([
                          //         "${vm.service!.duration.capitalize().tr()}:"
                          //             .text
                          //             // .sm
                          //             .make(),
                          //         //
                          //         "${vm.service!.selectedQty}"
                          //             .text
                          //             // .sm
                          //             .bold
                          //             .make(),
                          //       ], spacing: 5),
                          //   ]).px12().expand(),
                          // ]),
                          //selected options if any
                          if (vm.service!.selectedOptions.isNotEmpty)
                            VStack([
                              "Selected Options".tr().text.semiBold.make(),
                              ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                children:
                                    vm.service!.selectedOptions.map((option) {
                                      return HStack([
                                        "${option.name}".text.make().expand(),
                                        10.widthBox,
                                        //price
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

                    //
                    //
                    Divider(thickness: 1, height: 1, color: Vx.zinc300).py12(),
                    SizedBox(height: 4),

                    if (vm.banner != null)
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
                            // Header
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

                            // Small Banner Image
                            ClipRRect(
                              child: Image.network(
                                vm.banner?.imageUrl ?? "",
                                width: double.infinity,
                                height: 65,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "${vm.banner?.campaignTitle ?? '-'}".text
                                      .size(11)
                                      .semiBold
                                      .maxLines(1)
                                      .ellipsis
                                      .make(),

                                  2.heightBox,

                                  "${vm.banner?.campaignDesc ?? '-'}".text
                                      .size(9)
                                      .color(Colors.grey)
                                      .maxLines(2)
                                      .ellipsis
                                      .make(),

                                  // 6.heightBox,
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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

                    vm.vendor_type_id == 13
                        ? Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: vm.selectTattoType,
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
                              onChanged: (value) {
                                vm.onselectTypeTato(value);
                              },
                              decoration: InputDecoration(
                                labelText: "Tatto Type",
                                hintText: "Select",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),

                            SizedBox(height: 14),
                            CustomTextFormField(
                              labelText: "Tatto Placement".tr(),
                              textEditingController: vm.tatto_placement,
                            ),
                            SizedBox(height: 10),
                            CustomTextFormField(
                              labelText: "Tatto Size".tr(),
                              textEditingController: vm.tatto_size,
                            ),
                            SizedBox(height: 10),

                            VStack([
                              "Please upload references of designs or themes you are interested in"
                                  .text
                                  .make(),
                              Stack(
                                children: [
                                  //
                                  vm.newPhoto != null
                                      ? Image.file(
                                            vm.newPhoto!,
                                            fit: BoxFit.cover,
                                          )
                                          .wh(Vx.dp64 * 1.3, Vx.dp64 * 1.3)
                                          .box
                                          .rounded
                                          .clip(Clip.antiAlias)
                                          .make()
                                      : Image.asset(AppImages.noImage),

                                  //
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Icon(
                                          FlutterIcons.camera_ant,
                                          size: 16,
                                        )
                                        .p8()
                                        .box
                                        .color(
                                          context.theme.colorScheme.surface,
                                        )
                                        .roundedFull
                                        .shadow
                                        .make()
                                        .onInkTap(vm.changePhoto),
                                  ),
                                ],
                              ).box.makeCentered(),
                            ]).py(10),
                          ],
                        )
                        : SizedBox(),

                    //note
                    CustomTextFormField(
                      labelText: "Note".tr(),
                      textEditingController: vm.noteTEC,
                    ),
                    UiSpacer.verticalSpace(),

                    //pickup time slot
                    ScheduleOrderView(vm),

                    vm.service?.duration == "fixed"
                        ? SizedBox()
                        : Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xffD9D9D9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      "Stay Duration".text.bold.lg.make(),
                                      "Choose how long you’ll stay".text
                                          .color(Color(0xff808080))
                                          .make(),
                                    ],
                                  ).expand(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          vm.decrementDuration();
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
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

                                      /// COUNT
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          "${vm.durationQty}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          vm.incrementDuration();
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
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
                                ],
                              ),
                              SizedBox(height: 10),
                              Divider(color: Color(0xffD9D9D9)),
                              SizedBox(height: 10),
                              "Guest".text.bold.lg.make(),
                              "${vm.guests.where((guest) => guest.qty > 0).map((guest) => "${guest.qty} ${guest.name}").join(", ")}"
                                  .text
                                  .color(context.primaryColor)
                                  .make(),

                              SizedBox(height: 10),

                              Container(
                                padding: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xffD9D9D9)),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: vm.guests.length,
                                  itemBuilder: (context, index) {
                                    final agePrice = vm.guests[index];
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              /// LEFT
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${agePrice.name}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 4),

                                                    Text(
                                                      "${agePrice.description}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// MINUS BUTTON
                                              GestureDetector(
                                                onTap: () {
                                                  vm.decrement(agePrice.id);
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
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

                                              /// COUNT
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                child: Text(
                                                  "${agePrice.qty}",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () {
                                                  vm.increment(agePrice.id);
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 10),
                              Divider(color: Color(0xffD9D9D9)),

                              "Guide".text.bold.lg.make(),
                              "Enhance your trip with a local guide".text
                                  .color(Color(0xff808080))
                                  .make(),

                              SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  // color: const Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: vm.guidSelected,
                                    hint: Text(
                                      "Select Language",
                                      style: TextStyle(
                                        fontSize: 16,
                                        // color: Colors.grey.shade600,
                                      ),
                                    ),

                                    isExpanded: true,

                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),

                                    borderRadius: BorderRadius.circular(16),

                                    items:
                                        vm.service?.guide!
                                            .map(
                                              (lang) =>
                                                  DropdownMenuItem<String>(
                                                    value: lang.lang,
                                                    child: Text(lang.lang),
                                                  ),
                                            )
                                            .toList(),

                                    onChanged: (value) {
                                      vm.setGuide(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                    //address
                    if (vm.service!.location)
                      ServiceDeliveryAddressPickerView(vm, service: service),
                    Divider(thickness: 1, height: 1, color: Vx.zinc300).py12(),

                    vm.vendor_type_id == 13
                        ? SizedBox()
                        : DottedBorder(
                          dashPattern: [5, 1],
                          color: AppColor.accentColor,
                          child:
                              ServiceDiscountSection(vm)
                                  .p20()
                                  .box
                                  .color(AppColor.accentColor.withOpacity(0.10))
                                  .clip(Clip.antiAlias)
                                  .roundedSM
                                  .make(),
                          radius: Radius.circular(10),
                          borderType: BorderType.RRect,
                          padding: EdgeInsets.all(0),
                        ).py12(),
                    DottedLine().py12(),

                    vm.vendor_type_id == 13
                        ? SizedBox()
                        : Column(
                          children: [
                            PaymentMethodsView(vm),
                            //order final price preview
                            LoadingShimmer(
                              loading: vm.isBusy,
                              child: OrderSummaryBooking(
                                vm: vm,
                                subTotal: vm.checkout?.subTotal,
                                discount: vm.checkout?.discount,
                                deliveryFee:
                                    vm.service!.location
                                        ? vm.checkout?.deliveryFee
                                        : null,
                                tax: vm.checkout?.tax,
                                vendorTax: vm.vendor?.tax,
                                total: vm.checkout!.total,
                                fees: vm.vendor?.fees ?? [],
                                allowConvert: true,
                              ),
                            ),

                            if (AppCurrencySystemService()
                                        .currentCurrencyCode !=
                                    AppStrings.currencyCode &&
                                !vm.isBusy)
                              CurrencyConversionNotice(
                                convertedAmount:
                                    vm.checkout!.totalWithTip.convertCurrency,
                                originalAmount: vm.checkout!.totalWithTip,
                                baseCurrency: AppStrings.currencyCode,
                              ).py(Sizes.paddingSizeDefault),

                            //
                            Divider(
                              thickness: 1,
                              height: 1,
                              color: Vx.zinc300,
                            ).py12(),

                            //payment options
                          ],
                        ),

                    //checkout button
                    CustomButton(
                      title: "Book Now".tr().padRight(14),
                      icon: FlutterIcons.credit_card_fea,
                      loading: vm.isBusy,
                      onPressed: vm.placeOrder,
                    ).wFull(context),
                  ]).p20(),
                ],
              ).scrollVertical(),
        );
      },
    );
  }
}
