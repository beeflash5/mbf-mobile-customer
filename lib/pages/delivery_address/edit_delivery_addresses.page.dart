import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/pages/delivery_address/widgets/address_search.view.dart';
import 'package:fuodz/pages/delivery_address/widgets/what3words.view.dart';
import 'package:fuodz/providers/new_delivery_address_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/delivery_address.helper.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class EditDeliveryAddressesPage extends ConsumerStatefulWidget {
  const EditDeliveryAddressesPage({this.deliveryAddress, super.key});

  final DeliveryAddress? deliveryAddress;

  @override
  ConsumerState<EditDeliveryAddressesPage> createState() =>
      _EditDeliveryAddressesPageState();
}

class _EditDeliveryAddressesPageState
    extends ConsumerState<EditDeliveryAddressesPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameTEC = TextEditingController(
    text: widget.deliveryAddress?.name ?? '',
  );
  late final _addressTEC = TextEditingController(
    text: widget.deliveryAddress?.address ?? '',
  );
  late final _descriptionTEC = TextEditingController(
    text: widget.deliveryAddress?.description ?? '',
  );
  final _what3wordsTEC = TextEditingController();
  final _placeSearchTEC = TextEditingController();
  late bool _isDefault = widget.deliveryAddress?.isDefault == 1;
  bool _submitting = false;
  late final DeliveryAddress _deliveryAddress =
      widget.deliveryAddress ?? DeliveryAddress();

  @override
  void dispose() {
    _nameTEC.dispose();
    _addressTEC.dispose();
    _descriptionTEC.dispose();
    _what3wordsTEC.dispose();
    _placeSearchTEC.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => AddressSearchView(
        placeSearchTEC: _placeSearchTEC,
        addressSelected: (prediction) async {
          await DeliveryAddressHelper.applyPickerResult(
            prediction,
            _deliveryAddress,
            _addressTEC,
          );
          if (mounted) setState(() {});
        },
        selectOnMap: _pickOnMap,
      ),
    );
  }

  Future<void> _pickOnMap() async {
    final result = await DeliveryAddressHelper.newPlacePicker(context);
    if (result == null) return;
    await DeliveryAddressHelper.applyPickerResult(
      result,
      _deliveryAddress,
      _addressTEC,
    );
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _deliveryAddress.name = _nameTEC.text;
    _deliveryAddress.description = _descriptionTEC.text;
    _deliveryAddress.isDefault = _isDefault ? 1 : 0;
    setState(() => _submitting = true);
    final result = await ref
        .read(editDeliveryAddressControllerProvider.notifier)
        .submit(_deliveryAddress);
    if (!mounted) return;
    setState(() => _submitting = false);
    AlertService.dynamic(
      type: switch (result) {
        DeliveryAddressSaveSuccess() => AlertType.success,
        DeliveryAddressSaveFailure() => AlertType.error,
      },
      title: "Update Delivery Address".tr(),
      text: switch (result) {
        DeliveryAddressSaveSuccess(:final message) => message,
        DeliveryAddressSaveFailure(:final message) => message,
      },
      onConfirm: switch (result) {
        DeliveryAddressSaveSuccess() => () => Navigator.of(context).pop(true),
        DeliveryAddressSaveFailure() => null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Update Delivery Address".tr(),
      body: Form(
        key: _formKey,
        child: VStack([
          CustomTextFormField(
            labelText: "Name".tr(),
            textEditingController: _nameTEC,
            validator: FormValidator.validateName,
          ),
          What3wordsView(
            what3wordsTEC: _what3wordsTEC,
            onSubmitted: (value) async {
              final ok = await DeliveryAddressHelper.validateWhat3words(
                context,
                value,
                _deliveryAddress,
                addressTEC: _addressTEC,
              );
              if (ok && mounted) setState(() {});
            },
            onShare: DeliveryAddressHelper.shareWhat3words,
          ),
          CustomTextFormField(
            labelText: "Address".tr(),
            isReadOnly: true,
            textEditingController: _addressTEC,
            validator: (value) => FormValidator.validateEmpty(
              value,
              errorTitle: "Address".tr(),
            ),
            onTap: _openLocationPicker,
          ).py2(),
          UiSpacer.verticalSpace(),
          CustomTextFormField(
            labelText: "Description".tr(),
            textEditingController: _descriptionTEC,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            textInputAction: TextInputAction.newline,
          ).py2(),
          HStack([
            Checkbox(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v ?? false),
            ),
            "Default".tr().text.make(),
          ])
              .onInkTap(() => setState(() => _isDefault = !_isDefault))
              .wFull(context)
              .py12(),
          CustomButton(
            isFixedHeight: true,
            height: Vx.dp48,
            title: "Save".tr(),
            onPressed: _save,
            loading: _submitting,
          ).centered(),
        ]).p20().scrollVertical(),
      ),
    );
  }
}
