import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomButtonLight extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final double? iconSize;
  final Widget? child;
  final TextStyle? titleStyle;
  final Function? onPressed;
  final OutlinedBorder? shape;
  final bool isFixedHeight;
  final double? height;
  final bool loading;
  final double? shapeRadius;
  final Color? color;
  final Color? iconColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;

  const CustomButtonLight({
    this.title,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.child,
    this.onPressed,
    this.shape,
    this.isFixedHeight = false,
    this.height,
    this.loading = false,
    this.shapeRadius = Vx.dp4,
    this.color,
    this.titleStyle,
    this.elevation,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      padding: EdgeInsets.all(0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: this.padding,
          elevation: this.elevation,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Colors.white,
          // disabledBackgroundColor: this.loading ? AppColor.primaryColor : null,
          shape:
              this.loading
                  ? null
                  : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: AppColor.primaryColor, // warna border
                      width: 1, // ketebalan border
                    ),
                  ),
        ),
        onPressed:
            (this.loading || this.onPressed == null)
                ? null
                : () {
                  //remove focus from any input field
                  FocusScope.of(context).unfocus();
                  this.onPressed!();
                },
        child:
            this.loading
                ? BusyIndicator(color: context.primaryColor)
                : Container(
                  padding: this.padding,
                  width: null, //double.infinity,
                  height:
                      this.isFixedHeight ? Vx.dp48 : (this.height ?? Vx.dp48),
                  child:
                      this.child ??
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          this.icon != null
                              ? Icon(
                                this.icon,
                                color: this.iconColor ?? Colors.white,
                                size: this.iconSize ?? 20,
                                textDirection:
                                    translator.activeLocale.languageCode == "ar"
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                              ).pOnly(
                                right:
                                    translator.activeLocale.languageCode == "ar"
                                        ? Vx.dp0
                                        : Vx.dp5,
                                left:
                                    translator.activeLocale.languageCode != "ar"
                                        ? Vx.dp0
                                        : Vx.dp5,
                              )
                              : UiSpacer.emptySpace(),
                          this.title.isNotEmptyAndNotNull
                              ? Text(
                                "${this.title}",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ).centered()
                              : UiSpacer.emptySpace(),
                        ],
                      ),
                ),
      ),
    );
  }
}
