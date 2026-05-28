import 'package:flutter/material.dart' hide RadioGroup;
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_cancellation.view_model.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderCancellationBottomSheet extends StatefulWidget {
  OrderCancellationBottomSheet({
    required this.onSubmit,
    required this.order,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  final Order order;
  @override
  _OrderCancellationBottomSheetState createState() =>
      _OrderCancellationBottomSheetState();
}

class _OrderCancellationBottomSheetState
    extends State<OrderCancellationBottomSheet> {
  String _selectedReason = "";
  TextEditingController reasonTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> getRefundStatus(DateTime createdAt) {
      final now = DateTime.now();
      final hours = now.difference(createdAt).inHours;

      if (hours <= 12) {
        return {
          'time': 12,
          'status': 'cancelled_by_guest',
          'refund': 0,
          'label': 'Cancellation within 12 hours is non-refundable.',
        };
      }

      if (hours <= 24) {
        return {
          'time': 24,
          'status': 'partial_refund',
          'refund': 50,
          'label':
              'You will receive a 50% refund for cancellations within 24 hours.',
        };
      }

      return {'status': 'full_refund', 'refund': 100, 'label': null};
    }

    return ViewModelBuilder<OrderCancellationViewModel>.reactive(
      viewModelBuilder: () => OrderCancellationViewModel(context, widget.order),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, vm, child) {
        return VStack([
              //
              "Order Cancellation".tr().text.semiBold.xl.make(),
              widget.order.vendor?.vendorType.slug == 'food'
                  ? "${getRefundStatus(vm.order.createdAt)['label']}".text
                      .make()
                  : SizedBox(),
              SizedBox(height: 10),
              "Please state why you want to cancel order".tr().text.make(),

              //default reasons
              // VStack([
              //   (vm.isBusy || vm.busy(vm.reasons))
              //       ? BusyIndicator().p(12).centered()
              //       : RadioGroup<String>.builder(
              //         spacebetween: Vx.dp48,
              //         groupValue: _selectedReason,
              //         onChanged:
              //             (value) => setState(() {
              //               _selectedReason = value ?? "";
              //             }),
              //         items: vm.reasons,
              //         itemBuilder:
              //             (item) => RadioButtonBuilder(item.tr().capitalized),
              //       ).py12(),
              //   //custom
              //   // _selectedReason == "custom"
              //   // ?

              //   // : UiSpacer.emptySpace(),
              // ]).py(10),
              CustomTextFormField(
                minLines: 6,
                labelText: "Reason".tr(),
                textEditingController: reasonTEC,
                validator: FormValidator.validateEmpty,
              ).py12(),

              //
              SizedBox(height: 20),
              CustomButton(
                title: "Submit".tr(),
                onPressed: () {
                  // if (_selectedReason == "custom") {
                  //   _selectedReason = reasonTEC.text;
                  // }
                  _selectedReason = reasonTEC.text;

                  if (_selectedReason.trim().isEmpty) {
                    ToastService.toastError(
                      "Reason is required",
                      title: "Error",
                    );
                    return;
                  }

                  widget.onSubmit(_selectedReason);
                  // if (_selectedReason.isEmptyOrNull) {
                  //   context.showToast(msg: "error", bgColor: Colors.red);
                  // } else {
                  //   widget.onSubmit(_selectedReason);
                  // }
                  //
                },
              ),
            ])
            .p20()
            .scrollVertical()
            .pOnly(bottom: context.mq.viewInsets.bottom)
            .h(
              //80% of screen height
              context.percentHeight * 80,
            );
      },
    );
  }
}
