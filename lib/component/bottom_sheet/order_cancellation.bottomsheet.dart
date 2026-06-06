import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/services/validator.service.dart';

class OrderCancellationBottomSheet extends StatefulWidget {
  const OrderCancellationBottomSheet({
    required this.onSubmit,
    required this.order,
    super.key,
  });

  final Function(String) onSubmit;
  final Order order;

  @override
  State<OrderCancellationBottomSheet> createState() =>
      _OrderCancellationBottomSheetState();
}

class _OrderCancellationBottomSheetState
    extends State<OrderCancellationBottomSheet> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getRefundStatus(DateTime createdAt) {
    final hours = DateTime.now().difference(createdAt).inHours;
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

  void _submit() {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ToastService.toastError('Reason is required', title: 'Error');
      return;
    }
    widget.onSubmit(reason);
  }

  @override
  Widget build(BuildContext context) {
    final isFood = widget.order.vendor?.vendorType.slug == 'food';
    return VStack([
      'Order Cancellation'.tr().text.semiBold.xl.make(),
      if (isFood)
        '${_getRefundStatus(widget.order.createdAt)['label']}'.text.make()
      else
        const SizedBox(),
      const SizedBox(height: 10),
      'Please state why you want to cancel order'.tr().text.make(),
      CustomTextFormField(
        minLines: 6,
        labelText: 'Reason'.tr(),
        textEditingController: _reasonCtrl,
        validator: FormValidator.validateEmpty,
      ).py12(),
      const SizedBox(height: 20),
      CustomButton(
        title: 'Submit'.tr(),
        onPressed: _submit,
      ),
    ])
        .p20()
        .scrollVertical()
        .pOnly(bottom: MediaQuery.of(context).viewInsets.bottom)
        .h(context.percentHeight * 80);
  }
}
