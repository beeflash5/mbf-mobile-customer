import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/filters/ops_autocomplete.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/utils/app_map_settings.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/input.styles.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class AddressSearchView extends StatefulWidget {
  const AddressSearchView({
    super.key,
    required this.placeSearchTEC,
    this.addressSelected,
    this.selectOnMap,
  });

  final TextEditingController placeSearchTEC;
  final Function(dynamic)? addressSelected;
  final Function? selectOnMap;

  @override
  State<AddressSearchView> createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return VStack([
      CustomVisibilty(
        visible: AppMapSettings.useGoogleOnApp,
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: widget.placeSearchTEC,
          googleAPIKey: AppStrings.googleMapApiKey.isNotEmpty 
              ? AppStrings.googleMapApiKey 
              : "AIzaSyD98jX5-thKKT7e0YY-OxE_Q_eowEgGIxI",
          inputDecoration: InputDecoration(
            hintText: "Enter your address...".tr(),
            enabledBorder: InputStyles.inputUnderlineEnabledBorder(),
            errorBorder: InputStyles.inputUnderlineEnabledBorder(),
            focusedErrorBorder: InputStyles.inputUnderlineFocusBorder(),
            focusedBorder: InputStyles.inputUnderlineFocusBorder(),
            prefixIcon: const Icon(Icons.search, size: 18),
            labelStyle: Theme.of(context).textTheme.bodyLarge,
            contentPadding: const EdgeInsets.all(10),
          ),
          debounceTime: 800,
          countries: null,
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            setState(() => isLoading = false);
            context.pop();
            widget.addressSelected?.call(prediction);
            widget.placeSearchTEC.clear();
          },
          itemClick: (Prediction prediction) {
            widget.placeSearchTEC.text = prediction.description ?? '';
            widget.placeSearchTEC.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
            setState(() => isLoading = true);
          },
        ),
      ),
      CustomVisibilty(
        visible: !AppMapSettings.useGoogleOnApp,
        child: OPSAutocompleteTextField(
          textEditingController: widget.placeSearchTEC,
          inputDecoration: InputDecoration(
            hintText: "Enter your address...".tr(),
            enabledBorder: InputStyles.inputUnderlineEnabledBorder(),
            errorBorder: InputStyles.inputUnderlineEnabledBorder(),
            focusedErrorBorder: InputStyles.inputUnderlineFocusBorder(),
            focusedBorder: InputStyles.inputUnderlineFocusBorder(),
            prefixIcon: const Icon(Icons.search, size: 18),
            labelStyle: Theme.of(context).textTheme.bodyLarge,
            contentPadding: const EdgeInsets.all(10),
          ),
          debounceTime: 800,
          onselected: (Address prediction) {
            widget.addressSelected?.call(prediction);
            context.pop();
          },
        ),
      ),
      isLoading ? BusyIndicator().centered().p20() : UiSpacer.emptySpace(),
      UiSpacer.expandedSpace(),
      CustomButton(
        title: "Pick On Map".tr(),
        onPressed: () {
          context.pop();
          widget.selectOnMap?.call();
        },
      ),
    ]).p20().h(context.percentHeight * 90).scrollVertical();
  }
}
