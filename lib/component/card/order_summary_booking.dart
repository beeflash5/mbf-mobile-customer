import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/fee.dart';
import 'package:fuodz/models/guest_model.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';

class OrderSummaryBooking extends StatelessWidget {
  const OrderSummaryBooking({
    super.key,
    required this.total,
    this.deliverySlotDate,
    this.deliverySlotTime,
    this.guests = const [],
    this.duration,
    this.durationQty = 1,
    this.guidSelected,
    this.selectedPaymentMethod,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.deliveryDiscount,
    this.tax,
    this.vendorTax,
    this.fees = const [],
    this.driverTip = 0.00,
    this.mCurrencySymbol,
    this.customWidget,
    this.allowConvert = false,
  });

  final double total;
  final String? deliverySlotDate;
  final String? deliverySlotTime;
  final List<GuestModel> guests;
  final String? duration;
  final int durationQty;
  final String? guidSelected;
  final PaymentMethod? selectedPaymentMethod;
  final double? subTotal;
  final double? discount;
  final double? deliveryFee;
  final double? deliveryDiscount;
  final double? tax;
  final String? vendorTax;
  final List<Fee> fees;
  final double? driverTip;
  final String? mCurrencySymbol;
  final Widget? customWidget;
  final bool allowConvert;

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        mCurrencySymbol ?? AppStrings.currentCurrencySymbol;

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
      const SizedBox(height: 10),
      if ((deliverySlotDate ?? '').isNotEmpty &&
          (deliverySlotTime ?? '').isNotEmpty)
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Check-in".tr().text.make(),
                "${DateFormat('dd/MM/yyyy').format(DateTime.parse(deliverySlotDate!))}, "
                    "${DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(deliverySlotTime!))}"
                    .text
                    .color(const Color(0xff808080))
                    .semiBold
                    .make(),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      if (guests.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Guest".text.semiBold.make(),
                "${guests.fold<double>(0, (total, guest) => total + (guest.qty * guest.price))}"
                    .currencyValueFormat()
                    .text
                    .color(const Color(0xff808080))
                    .semiBold
                    .make(),
              ],
            ),
            const SizedBox(height: 10),
            ...guests
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
                ),
            const SizedBox(height: 5),
          ],
        ),
      if (duration != null && duration != "fixed")
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Stay Duration".tr().text.make(),
                "$durationQty ${duration!.capitalize()}"
                    .text
                    .color(const Color(0xff808080))
                    .semiBold
                    .make(),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      if (guidSelected != null)
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Guide".tr().text.make(),
                guidSelected!.text
                    .color(const Color(0xff808080))
                    .semiBold
                    .make(),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      const SizedBox(height: 8),
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
      const SizedBox(height: 8),
      if (selectedPaymentMethod != null)
        "Powered by ${selectedPaymentMethod!.name} · Your payment is encrypted and protected"
            .text
            .color(const Color(0xff808080))
            .make(),
    ]);
  }
}

extension _StringCapitalize on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
