import 'package:flutter/material.dart';
import 'package:fuodz/services/app_colors.dart';

/// Tombol reusable (filled / outlined). Mirror dari mbf-mobile.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.color,
    this.textColor,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.borderRadius = 8,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColor.primaryColor;
    final fg = textColor ?? (outlined ? bg : Colors.white);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: outlined ? BorderSide(color: bg, width: 1.2) : BorderSide.none,
    );
    final pad =
        padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 16);

    final child =
        loading
            ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
            : Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: fg, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ],
            );

    final btn =
        outlined
            ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                padding: pad,
                shape: shape,
                side: BorderSide(color: bg, width: 1.2),
              ),
              child: child,
            )
            : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                padding: pad,
                shape: shape,
                elevation: 0,
              ),
              child: child,
            );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
