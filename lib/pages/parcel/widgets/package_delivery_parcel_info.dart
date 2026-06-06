import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PackageDeliveryParcelInfo extends StatelessWidget {
  const PackageDeliveryParcelInfo({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    final rules = state.requireParcelInfo ? "required|gt:0" : '';
    return Form(
      key: controller.packageInfoFormKey,
      child: VStack(
        [
          VStack(
            [
              "Package Parameters".tr().text.xl.medium.make().py20(),
              ("Weight".tr() + " (kg)").text.make(),
              CustomTextFormField(
                underline: true,
                hintText: "Enter package weight".tr(),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textEditingController: controller.packageWeightTEC,
                validator: (value) => FormValidator.validateCustom(
                  value,
                  name: "Weight".tr(),
                  rules: rules,
                ),
              ),
              UiSpacer.formVerticalSpace(),
              ("Length".tr() + " (cm)").text.make(),
              CustomTextFormField(
                underline: true,
                hintText: "Enter package length".tr(),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textEditingController: controller.packageLengthTEC,
                validator: (value) => FormValidator.validateCustom(
                  value,
                  name: "Length".tr(),
                  rules: rules,
                ),
              ),
              UiSpacer.formVerticalSpace(),
              ("Width".tr() + " (cm)").text.make(),
              CustomTextFormField(
                underline: true,
                hintText: "Enter package width".tr(),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textEditingController: controller.packageWidthTEC,
                validator: (value) => FormValidator.validateCustom(
                  value,
                  name: "Width".tr(),
                  rules: rules,
                ),
              ),
              UiSpacer.formVerticalSpace(),
              ("Height".tr() + " (cm)").text.make(),
              CustomTextFormField(
                underline: true,
                hintText: "Enter package height".tr(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                textEditingController: controller.packageHeightTEC,
                validator: (value) => FormValidator.validateCustom(
                  value,
                  name: "Height".tr(),
                  rules: rules,
                ),
              ),
              UiSpacer.formVerticalSpace(),
            ],
          ).scrollVertical().expand(),
          FormStepController(
            onPreviousPressed: () => controller.nextForm(3),
            onNextPressed: () => controller.validateDeliveryParcelInfo(context),
          ),
        ],
      ),
    );
  }
}
