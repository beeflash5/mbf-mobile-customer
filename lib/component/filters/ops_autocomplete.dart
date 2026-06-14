import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/address.dart';
import 'package:fuodz/providers/ops_map_providers.dart';

class OPSAutocompleteTextField extends ConsumerWidget {
  const OPSAutocompleteTextField({
    super.key,
    required this.onselected,
    this.textEditingController,
    this.inputDecoration,
    required this.debounceTime,
  });

  final Function(Address) onselected;
  final TextEditingController? textEditingController;
  final InputDecoration? inputDecoration;
  final int debounceTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(opsMapControllerProvider.notifier);
    return TypeAheadField<Address>(
      controller: textEditingController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration:
              inputDecoration ??
              InputDecoration(hintText: 'Search address'.tr()),
        );
      },
      debounceDuration: Duration(milliseconds: debounceTime),
      suggestionsCallback: notifier.fetchPlaces,
      retainOnLoading: false,
      emptyBuilder: (ctx) => "No Address found".tr().text.make().p12(),
      itemBuilder:
          (context, suggestion) => ListTile(
            title: "${suggestion.addressLine}".text.base.semiBold.make(),
            subtitle: "${suggestion.adminArea}".text.sm.make(),
          ),
      onSelected: (address) async {
        final mAddress = await notifier.fetchPlaceDetails(address);
        onselected(mAddress);
      },
    );
  }
}
