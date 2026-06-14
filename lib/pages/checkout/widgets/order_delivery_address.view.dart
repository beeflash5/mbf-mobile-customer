import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/list/delivery_address.list_item.dart';
import 'package:fuodz/component/states/delivery_address.empty.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';

class OrderDeliveryAddressPickerView extends StatelessWidget {
  const OrderDeliveryAddressPickerView({
    super.key,
    required this.vendor,
    required this.isPickup,
    required this.onTogglePickup,
    required this.onPickAddress,
    this.deliveryAddress,
    this.deliveryAddressOutOfRange = false,
    this.showPickView = true,
    this.isBooking = false,
  });

  final Vendor vendor;
  final bool isPickup;
  final ValueChanged<bool?> onTogglePickup;
  final VoidCallback onPickAddress;
  final DeliveryAddress? deliveryAddress;
  final bool deliveryAddressOutOfRange;
  final bool showPickView;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    return VStack([
          Visibility(
            visible: showPickView && !vendor.allowOnlyDelivery,
            child: HStack(
              [
                Checkbox(value: isPickup, onChanged: onTogglePickup),
                VStack([
                  "Pickup Order".tr().text.xl.semiBold.make(),
                  "Please indicate if you would come pickup order at the vendor"
                      .tr()
                      .text
                      .make(),
                ]).expand(),
              ],
              crossAlignment: CrossAxisAlignment.start,
            ).wFull(context).onInkTap(() => onTogglePickup(!isPickup)),
          ),
          Visibility(
            visible: !isPickup && !vendor.allowOnlyPickup,
            child: VStack([
              Visibility(
                visible: showPickView && vendor.pickup == 1,
                child: const Divider(thickness: 1).py4(),
              ),
              HStack([
                VStack([
                  "${!isBooking ? 'Delivery' : 'Booking'} address"
                      .tr()
                      .text
                      .semiBold
                      .xl
                      .make(),
                  "Please select %s address/location"
                      .tr()
                      .fill(["${!isBooking ? 'delivery' : 'booking'}".tr()])
                      .text
                      .make(),
                ]).expand(),
                20.widthBox,
                CustomButton(
                  title: "Select".tr(),
                  onPressed: onPickAddress,
                ).h(40),
              ]),
              DottedBorder(
                borderType: BorderType.RRect,
                color: context.accentColor,
                strokeWidth: 1,
                strokeCap: StrokeCap.round,
                radius: const Radius.circular(5),
                dashPattern: const [3, 6],
                child:
                    deliveryAddress != null
                        ? DeliveryAddressListItem(
                          deliveryAddress: deliveryAddress!,
                          action: false,
                          border: false,
                          showDefault: false,
                        )
                        : EmptyDeliveryAddress(
                          selection: true,
                          isBooking: isBooking,
                        ).py12().opacity(value: 0.60),
              ).wFull(context).py12().onInkTap(onPickAddress),
              Visibility(
                visible: deliveryAddressOutOfRange,
                child:
                    "Delivery address is out of vendor delivery range"
                        .tr()
                        .text
                        .sm
                        .red500
                        .make(),
              ),
            ]),
          ),
        ])
        .p12()
        .box
        .roundedSM
        .border(color: Colors.grey)
        .make()
        .pOnly(bottom: Vx.dp20);
  }
}
