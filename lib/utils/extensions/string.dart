import 'dart:convert';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:supercharged/supercharged.dart';

extension NumberParsing on dynamic {
  //
  String currencyFormat([String? currencySymbol]) {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      //
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      final decimalsValue = "".padLeft(decimals.toString().toInt()!, "0");

      //
      if (this.toString().contains(AppStrings.currentCurrencySymbol)) {
        currencySymbol = AppStrings.currentCurrencySymbol;
      }
      //
      final values = this
          .toString()
          .split(" ")
          .join("")
          .split(currencySymbol ?? AppStrings.currencySymbol);

      //
      CurrencyFormat currencySettings = CurrencyFormat(
        symbol: currencySymbol ?? AppStrings.currencySymbol,
        symbolSide:
            currencylOCATION.toLowerCase() == "left"
                ? SymbolSide.left
                : SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );

      final double? parsedVal = double.tryParse(values[1]);
      int decimalCount = decimalsValue.length;
      if (parsedVal != null && parsedVal % 1 == 0) {
        decimalCount = 0;
      }

      return CurrencyFormatter.format(
        values[1],
        currencySettings,
        decimal: decimalCount,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }

  //
  String currencyValueFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final decimalsValue = "".padLeft(decimals.toString().toInt()!, "0");
      final values = this.toString().split(" ").join("");

      //
      CurrencyFormat currencySettings = CurrencyFormat(
        symbol: "",
        symbolSide: SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );
      final double? parsedVal = double.tryParse(values);
      int decimalCount = decimalsValue.length;
      if (parsedVal != null && parsedVal % 1 == 0) {
        decimalCount = 0;
      }

      return CurrencyFormatter.format(
        values,
        currencySettings,
        decimal: decimalCount,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }

  bool get isNotDefaultImage {
    return !this.toString().contains("default");
  }

  String maskString({int start = 3, int? end, String mask = "*"}) {
    final String value = this.toString();
    // make sure start and end are within the string length
    if (start < 0) {
      start = 0;
    }

    int endPoint = end ?? value.length;
    if (endPoint > value.length) {
      endPoint = value.length;
    }

    // get the front and end of the string
    final String frontString = start == 0 ? "" : value.substring(0, start);
    final String endString = value.substring(endPoint);
    final String maskedString = "$mask".padLeft(
      value.substring(start, endPoint).length,
      "$mask",
    );
    return "$frontString$maskedString$endString";
  }

  String parseLocalized() {
    String value = this.toString();
    if (value.startsWith('{"') && value.contains('}')) {
      try {
        final Map map = jsonDecode(value);
        final lang = translator.activeLocale.languageCode;
        if (map.containsKey(lang)) {
          return map[lang].toString();
        } else if (map.containsKey('en')) {
          return map['en'].toString();
        } else if (map.isNotEmpty) {
          return map.values.first.toString();
        }
      } catch (e) {
        // ignore
      }
    }
    return value;
  }
}
