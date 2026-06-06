import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/providers/rating_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';

class VendorRatingBottomSheet extends ConsumerStatefulWidget {
  const VendorRatingBottomSheet({
    super.key,
    required this.onSubmitted,
    required this.order,
  });

  final Order order;
  final Function onSubmitted;

  @override
  ConsumerState<VendorRatingBottomSheet> createState() =>
      _VendorRatingBottomSheetState();
}

class _VendorRatingBottomSheetState
    extends ConsumerState<VendorRatingBottomSheet> {
  final _reviewCtrl = TextEditingController();
  int _rating = 3;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result =
        await ref.read(vendorRatingControllerProvider.notifier).submit(
              rating: _rating,
              review: _reviewCtrl.text,
              orderId: widget.order.id,
              vendorId: widget.order.vendor!.id,
            );
    if (!mounted) return;
    AlertService.dynamic(
      type: result is RatingSuccess ? AlertType.success : AlertType.error,
      title: 'Vendor Rating'.tr(),
      text: switch (result) {
        RatingSuccess(:final message) => message,
        RatingFailure(:final message) => message,
      },
      onConfirm: result is RatingSuccess ? () => widget.onSubmitted() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(vendorRatingControllerProvider).isLoading;
    return BasePage(
      body: VStack([
        Image.asset(AppImages.vendor).centered(),
        'Did you like provided service by %s ?'
            .tr()
            .fill([widget.order.vendor!.name])
            .text
            .center
            .xl
            .semiBold
            .makeCentered()
            .py12(),
        RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              Icon(Icons.star, color: Colors.yellow[700]),
          onRatingUpdate: (r) => _rating = r.toInt(),
        ).centered().py12(),
        CustomTextFormField(
          minLines: 3,
          maxLines: 4,
          textEditingController: _reviewCtrl,
          labelText: 'Comment'.tr(),
        ).py12(),
        SafeArea(
          child: CustomButton(
            title: 'Submit'.tr(),
            onPressed: isBusy ? null : _submit,
            loading: isBusy,
          ).centered().py16(),
        ),
      ]).p20().scrollVertical(),
    )
        .hTwoThird(context)
        .pOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
  }
}
