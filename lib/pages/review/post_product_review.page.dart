import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/order_product.dart';
import 'package:fuodz/providers/product_review_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PostProductReviewPage extends ConsumerStatefulWidget {
  const PostProductReviewPage(this.orderProduct, {super.key});

  final OrderProduct orderProduct;

  @override
  ConsumerState<PostProductReviewPage> createState() =>
      _PostProductReviewPageState();
}

class _PostProductReviewPageState extends ConsumerState<PostProductReviewPage> {
  final TextEditingController _reviewTEC = TextEditingController();
  double _rating = 3;
  bool _submitting = false;

  @override
  void dispose() {
    _reviewTEC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final args = (product: widget.orderProduct.product!, summary: false);
    final result = await ref
        .read(productReviewControllerProvider(args).notifier)
        .submitReview(
          rating: _rating,
          review: _reviewTEC.text,
          orderId: widget.orderProduct.orderId,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case ProductReviewSubmissionSuccess():
        await AlertService.success(
          title: "Product Review".tr(),
          text: "Product Review submitted successfully".tr(),
        );
        if (mounted) Navigator.of(context).pop(true);
        break;
      case ProductReviewSubmissionFailure(:final message):
        ToastService.toastError(message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.orderProduct.product!;
    return BasePage(
      showAppBar: true,
      title: "Product Review".tr(),
      showLeadingAction: true,
      body: VStack(
        [
          HStack([
            CustomImage(imageUrl: product.photo, width: 40, height: 40),
            UiSpacer.hSpace(12),
            product.name.text.maxLines(3).ellipsis.semiBold.lg.make().expand(),
          ]).p12(),
          UiSpacer.divider().py8(),
          VxRating(
            value: _rating,
            size: 42,
            selectionColor: AppColor.ratingColor,
            normalColor: Vx.gray400,
            maxRating: 5.0,
            stepInt: true,
            onRatingUpdate: (v) => setState(() => _rating = double.parse(v)),
          ),
          UiSpacer.vSpace(),
          "Enter review below:".tr().text.make().py4().wFull(context),
          UiSpacer.vSpace(5),
          CustomTextFormField(
            minLines: 3,
            maxLines: 5,
            hintText: "Review".tr(),
            textEditingController: _reviewTEC,
            keyboardType: TextInputType.multiline,
          ),
          UiSpacer.vSpace(),
          CustomButton(
            title: "Submit".tr(),
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
        crossAlignment: CrossAxisAlignment.center,
      ).scrollVertical(padding: const EdgeInsets.all(20)),
    );
  }
}
