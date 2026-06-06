import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/providers/apply_discount_providers.dart';

class ApplyDiscountPage extends ConsumerStatefulWidget {
  const ApplyDiscountPage({super.key, this.coupon, this.vendorTypeId});

  final Coupon? coupon;
  final int? vendorTypeId;

  @override
  ConsumerState<ApplyDiscountPage> createState() => _ApplyDiscountPageState();
}

class _ApplyDiscountPageState extends ConsumerState<ApplyDiscountPage> {
  final _codeCtrl = TextEditingController();
  bool _canApply = false;

  @override
  void initState() {
    super.initState();
    // Seed coupon awal kalau ada (saat user navigate ke page).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(applyDiscountControllerProvider.notifier)
          .setInitialCoupon(widget.coupon);
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final coupon = await ref
        .read(applyDiscountControllerProvider.notifier)
        .apply(code: _codeCtrl.text, vendorTypeId: widget.vendorTypeId);
    if (!mounted) return;
    if (coupon != null) {
      Navigator.of(context).pop(coupon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applyDiscountControllerProvider);

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Apply Discount'.tr(),
      elevation: 0.5,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Save on your ride! Enter your discount code below to enjoy a reduced fare on your upcoming trip. Whether you're commuting to work, heading to the airport, or just exploring the city, we've got you covered with great savings. Don't miss out on this opportunity to travel smart and save big!"
                  .tr(),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              hintText: 'Coupon Code'.tr(),
              textEditingController: _codeCtrl,
              errorText: state.error,
              onChanged: (v) =>
                  setState(() => _canApply = v.trim().isNotEmpty),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: CustomButton(
                title: 'Apply'.tr(),
                isFixedHeight: true,
                loading: state.isBusy,
                onPressed: (_canApply && !state.isBusy) ? _apply : null,
              ),
            ),
            if (state.coupon != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Coupon Applied'.tr()),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: CustomButton(
                  title: 'Remove Coupon'.tr(),
                  isFixedHeight: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
