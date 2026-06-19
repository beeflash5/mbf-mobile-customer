import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/list/delivery_address.list_item.dart';
import 'package:fuodz/component/states/delivery_address.empty.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';

class ServiceDeliveryAddressPickerView extends StatelessWidget {
  const ServiceDeliveryAddressPickerView({
    super.key,
    required this.service,
    required this.deliveryAddress,
    required this.deliveryAddressOutOfRange,
    required this.onPickAddress,
  });

  final Service service;
  final DeliveryAddress? deliveryAddress;
  final bool deliveryAddressOutOfRange;
  final VoidCallback onPickAddress;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: service.location,
      child: VStack([
            HStack([
              VStack([
                "Booking address".tr().text.semiBold.xl.make(),
                "Please select %s address/location"
                    .tr()
                    .fill(["booking".tr()])
                    .text
                    .make(),
              ]).expand(),
              CustomButton(title: "Select".tr(), onPressed: onPickAddress),
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
                        isBooking: true,
                      ).py12().opacity(value: 0.90),
            ).wFull(context).py12().onInkTap(onPickAddress),
            Visibility(
              visible: deliveryAddressOutOfRange,
              child:
                  "Schedule Order address is out of vendor service range"
                      .tr()
                      .text
                      .sm
                      .red500
                      .make(),
            ),
          ])
          .p12()
          .box
          .roundedSM
          .border(color: Colors.grey)
          .make()
          .pOnly(bottom: Vx.dp20),
    );
  }
}
