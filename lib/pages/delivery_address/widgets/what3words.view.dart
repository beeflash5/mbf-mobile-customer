import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class What3wordsView extends StatelessWidget {
  const What3wordsView({
    super.key,
    required this.what3wordsTEC,
    required this.onSubmitted,
    required this.onShare,
  });

  final TextEditingController what3wordsTEC;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return (AppStrings.isWhat3wordsApiKey
            ? VStack([
                CustomTextFormField(
                  labelText: "What3words " + "Name".tr(),
                  textEditingController: what3wordsTEC,
                  onFieldSubmitted: onSubmitted,
                ),
                "Get What3words name from this link"
                    .tr()
                    .text
                    .sm
                    .underline
                    .make()
                    .py2()
                    .onInkTap(onShare),
              ])
            : UiSpacer.emptySpace())
        .py16();
  }
}
