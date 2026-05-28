import 'package:dartx/dartx.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/fee.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/view_models/service_booking_summary.vm.dart';
import 'package:fuodz/views/pages/cart/widgets/amount_tile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

class OrderSummaryBooking extends StatelessWidget {
  const OrderSummaryBooking({
    required this.vm,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.deliveryDiscount,
    this.tax,
    this.vendorTax,
    this.fees = const [],
    required this.total,
    this.driverTip = 0.00,
    this.mCurrencySymbol,
    this.customWidget,
    this.allowConvert = false,
    Key? key,
  }) : super(key: key);

  final ServiceBookingSummaryViewModel vm;

  final double? subTotal;
  final double? discount;
  final double? deliveryFee;
  final double? deliveryDiscount;
  final double? tax;
  final String? vendorTax;
  final double total;
  final double? driverTip;
  final String? mCurrencySymbol;
  final List<Fee> fees;
  final Widget? customWidget;
  final bool allowConvert;
  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        mCurrencySymbol != null
            ? mCurrencySymbol
            : AppStrings.currentCurrencySymbol;

    TextStyle totalStyle = context.textTheme.bodyLarge!.copyWith(
      fontSize: Sizes.fontSizeLarge * 0.90,
      fontWeight: FontWeight.w600,
    );
    TextStyle summaryStyle = context.textTheme.bodyLarge!.copyWith(
      fontSize: Sizes.fontSizeLarge,
    );

    //view
    return VStack([
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Total".tr().text.semiBold.xl.make(),
          "$currencySymbol ${total.convertIf(allowConvert)}"
              .currencyFormat(currencySymbol)
              .text
              .semiBold
              .color(context.primaryColor)
              .xl
              .make(),
        ],
      ),
      SizedBox(height: 10),
      vm.checkout?.deliverySlotDate != "" && vm.checkout?.deliverySlotTime != ""
          ? Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Check-in".tr().text.make(),
                  (vm.checkout?.deliverySlotDate != "" &&
                              vm.checkout?.deliverySlotTime != ""
                          ? "${DateFormat('dd/MM/yyyy').format(DateTime.parse(vm.checkout!.deliverySlotDate))}, "
                              "${DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(vm.checkout!.deliverySlotTime))}"
                          : "-")
                      .text
                      .color(const Color(0xff808080))
                      .semiBold
                      .make(),
                ],
              ),
              SizedBox(height: 5),
            ],
          )
          : SizedBox(),

      vm.guests.length == 0
          ? SizedBox()
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Guest".text.semiBold.make(),

                  "${vm.guests.fold<double>(0, (total, guest) => total + (guest.qty * guest.price))}"
                      .currencyValueFormat()
                      .text
                      .color(Color(0xff808080))
                      .semiBold
                      .make(),
                ],
              ),

              const SizedBox(height: 10),

              ...vm.guests
                  .where((guest) => guest.qty > 0)
                  .map(
                    (guest) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "  ${guest.qty}x ${guest.name}".text
                              .color(const Color(0xff808080))
                              .make(),

                          "${guest.price}"
                              .currencyValueFormat()
                              .text
                              .color(const Color(0xff808080))
                              .make(),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              SizedBox(height: 5),
            ],
          ),

      vm.service?.duration == "fixed"
          ? SizedBox()
          : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Stay Duration".tr().text.make(),
                  "${vm.durationQty} ${vm.service?.duration == "fixed" ? '' : vm.service?.duration.capitalize()}"
                      .text
                      .color(Color(0xff808080))
                      .semiBold
                      .make(),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),

      vm.guidSelected == null
          ? SizedBox()
          : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Guide".tr().text.make(),
                  "${vm.guidSelected}".text
                      .color(Color(0xff808080))
                      .semiBold
                      .make(),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),

      SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9C75D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, color: Colors.black, size: 16),

            SizedBox(width: 6),

            Text(
              "Secure Payment",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
      vm.selectedPaymentMethod == null
          ? SizedBox()
          : "Powered by ${vm.selectedPaymentMethod?.name} · Your payment is encrypted and protected"
              .text
              .color(Color(0xff808080))
              .make(),
      //custom details
      // if (customWidget != null) customWidget!,
      // AmountTile(
      //   "Subtotal".tr(),
      //   "$currencySymbol ${(subTotal ?? 0).convertIf(allowConvert)}"
      //       .currencyFormat(currencySymbol),
      //   amountStyle: summaryStyle,
      // ).py2(),
      // Visibility(
      //   visible: discount != null,
      //   child:
      //       AmountTile(
      //         "Discount".tr(),
      //         "- " +
      //             "$currencySymbol ${(discount ?? 0).convertIf(allowConvert)}"
      //                 .currencyFormat(currencySymbol),
      //         amountStyle: summaryStyle,
      //       ).py2(),
      // ),
      // AmountTile(
      //   "Tax (%s)".tr().fill(["${vendorTax ?? 0}%"]),
      //   "+ " +
      //       " $currencySymbol ${(tax ?? 0).convertIf(allowConvert)}"
      //           .currencyFormat(currencySymbol),
      //   amountStyle: summaryStyle,
      // ).py2(),
      //   Visibility(
      //     visible: deliveryFee != null,
      //     child:
      //         VStack([
      //           DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      //           AmountTile(
      //             "Delivery Fee".tr(),
      //             "+ " +
      //                 "$currencySymbol ${(deliveryFee ?? 0).convertIf(allowConvert)}"
      //                     .currencyFormat(currencySymbol),
      //             amountStyle: summaryStyle,
      //           ),
      //           Visibility(
      //             visible: deliveryDiscount != null,
      //             child: AmountTile(
      //               "Delivery Discount".tr(),
      //               "- " +
      //                   "$currencySymbol ${(deliveryDiscount ?? 0).convertIf(allowConvert)}"
      //                       .currencyFormat(currencySymbol),
      //               amountStyle: summaryStyle,
      //             ),
      //           ),
      //         ]).py2(),
      //   ),
      //   DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      //   Visibility(
      //     visible: fees.isNotEmpty,
      //     child: VStack([
      //       ...((fees).map((fee) {
      //         //fixed
      //         if ((fee.percentage != 1)) {
      //           return AmountTile(
      //             "${fee.name}".tr(),
      //             "+ " +
      //                 " $currencySymbol ${fee.value.convertIf(allowConvert)}"
      //                     .currencyFormat(currencySymbol),
      //             amountStyle: summaryStyle,
      //           ).py2();
      //         } else {
      //           //percentage
      //           return AmountTile(
      //             "${fee.name} (%s)".tr().fill(["${fee.value}%"]),
      //             "+ " +
      //                 " $currencySymbol ${fee.getRate(subTotal ?? 0)}"
      //                     .currencyFormat(currencySymbol),
      //             amountStyle: summaryStyle,
      //           ).py2();
      //         }
      //       }).toList()),
      //       DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      //     ]),
      //   ),
      //   Visibility(
      //     visible: driverTip != null && driverTip! > 0,
      //     child: VStack([
      //       AmountTile(
      //         "Driver Tip".tr(),
      //         "+ " +
      //             "$currencySymbol ${(driverTip ?? 0).convertIf(allowConvert)}"
      //                 .currencyFormat(currencySymbol),
      //         amountStyle: summaryStyle,
      //       ).py2(),
      //       DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      //     ]),
      //   ),
      //   AmountTile(
      //     "Total Amount".tr(),
      //     "$currencySymbol ${total.convertIf(allowConvert)}".currencyFormat(
      //       currencySymbol,
      //     ),
      //     amountStyle: totalStyle,
      //   ),
    ]);
  }
}
