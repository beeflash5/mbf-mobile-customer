import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlTextView extends StatelessWidget {
  const HtmlTextView(
    this.htmlContent, {
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    Key? key,
  }) : super(key: key);

  final String htmlContent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Hide widget entirely if there's no content
    if (htmlContent.trim().isEmpty) return const SizedBox.shrink();

    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: padding,
      child: HtmlWidget(
        htmlContent,
        textStyle: TextStyle(color: textColor),
        onTapImage: (ImageMetadata imageMetadata) {
          try {
            launchUrlString(imageMetadata.sources.first.url);
          } catch (e) {
            print(e);
          }
        },
        onTapUrl: (url) {
          return launchUrlString(url);
        },
      ),
    );
  }
}
