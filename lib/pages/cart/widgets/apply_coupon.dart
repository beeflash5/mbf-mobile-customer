import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/cart_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ApplyCoupon extends ConsumerStatefulWidget {
  const ApplyCoupon({super.key});

  @override
  ConsumerState<ApplyCoupon> createState() => _ApplyCouponState();
}

class _ApplyCouponState extends ConsumerState<ApplyCoupon> {
  final TextEditingController _couponTEC = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _couponTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);
    final notifier = ref.read(cartControllerProvider.notifier);
    return VStack([
      "Add Coupon".tr().text.semiBold.xl.make(),
      UiSpacer.verticalSpace(space: 10),
      AuthServices.authenticated()
          ? CustomTextFormField(
              hintText: "Coupon Code".tr(),
              textEditingController: _couponTEC,
              errorText: state.couponError ?? "",
              onChanged: notifier.couponCodeChange,
              suffixIcon: CustomButton(
                child: const Icon(Icons.check),
                isFixedHeight: true,
                loading: _busy,
                onPressed: state.canApplyCoupon
                    ? () async {
                        setState(() => _busy = true);
                        await notifier.applyCoupon(_couponTEC.text);
                        if (mounted) setState(() => _busy = false);
                      }
                    : null,
              ).w(62).p8(),
            )
          : VStack([
              EmptyState(
                auth: true,
                showImage: false,
                actionPressed: () => context.pushWidget(LoginPage()),
              ),
            ]),
    ]);
  }
}
