import 'package:flutter/material.dart';
import 'package:fuodz/models/tax_order_location.history.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiOrderHistoryListItem extends StatelessWidget {
  const TaxiOrderHistoryListItem(
    this.taxiOrderLocationHistory, {
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final TaxiOrderLocationHistory taxiOrderLocationHistory;
  final Function(TaxiOrderLocationHistory) onPressed;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        Icon(
          Icons.location_on,
          size: 24,
          color: Colors.grey.shade600,
        ),
        VStack(
          [
            "${taxiOrderLocationHistory.address}"
                .text
                .semiBold
                .lg
                .maxLines(1)
                .ellipsis
                .make(),
            UiSpacer.vSpace(3),
            "${taxiOrderLocationHistory.latitude},${taxiOrderLocationHistory.longitude}"
                .text
                .maxLines(1)
                .ellipsis
                .sm
                .make(),
          ],
        ).px12().expand(),
        Icon(
          Utils.isArabic
              ? Icons.chevron_left
              : Icons.chevron_right,
          size: 18,
          color: Colors.grey.shade300,
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
    ).py8().onInkTap(
      () {
        onPressed(taxiOrderLocationHistory);
      },
    ).material(color: context.theme.colorScheme.surface);
  }
}
