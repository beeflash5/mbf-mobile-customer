import 'dart:convert';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

extension NumberParsing on dynamic {
  //
  String currencyFormat([String? currencySymbol]) {
    final uiConfig = AppStrings.uiConfig;
    final currencyConfig = uiConfig != null ? uiConfig["currency"] : null;
    
    final thousandSeparator = currencyConfig?["format"] ?? ".";
    final decimalSeparator = currencyConfig?["decimal_format"] ?? ",";
    final currencylOCATION = currencyConfig?["location"] ?? 'left';

    if (this.toString().contains(AppStrings.currentCurrencySymbol)) {
      currencySymbol = AppStrings.currentCurrencySymbol;
    }
    
    String valStr = this.toString().replaceAll(" ", "");
    String targetSymbol = currencySymbol ?? AppStrings.currencySymbol;
    
    String numberPart = valStr;
    if (valStr.contains(targetSymbol)) {
      numberPart = valStr.replaceAll(targetSymbol, "");
    }

    String cleanNumberPart = numberPart.replaceAll(RegExp(r'[^0-9.-]'), '');
    num? parsedValue = double.tryParse(cleanNumberPart);
    if (parsedValue != null) {
      if (parsedValue == parsedValue.toInt()) {
        parsedValue = parsedValue.toInt();
      }
    }

    CurrencyFormat currencySettings = CurrencyFormat(
      symbol: targetSymbol,
      symbolSide:
          currencylOCATION.toLowerCase() == "left"
              ? SymbolSide.left
              : SymbolSide.right,
      thousandSeparator: thousandSeparator,
      decimalSeparator: decimalSeparator,
    );

    return CurrencyFormatter.format(
      parsedValue ?? numberPart,
      currencySettings,
      decimal: 0,
      enforceDecimals: false,
    );
  }

  //
  String currencyValueFormat() {
    final uiConfig = AppStrings.uiConfig;
    final currencyConfig = uiConfig != null ? uiConfig["currency"] : null;
    
    final thousandSeparator = currencyConfig?["format"] ?? ".";
    final decimalSeparator = currencyConfig?["decimal_format"] ?? ",";
    String values = this.toString().replaceAll(" ", "");

    String cleanValues = values.replaceAll(RegExp(r'[^0-9.-]'), '');
    num? parsedValue = double.tryParse(cleanValues);
    if (parsedValue != null) {
      if (parsedValue == parsedValue.toInt()) {
        parsedValue = parsedValue.toInt();
      }
    }

    CurrencyFormat currencySettings = CurrencyFormat(
      symbol: "",
      symbolSide: SymbolSide.right,
      thousandSeparator: thousandSeparator,
      decimalSeparator: decimalSeparator,
    );
    
    return CurrencyFormatter.format(
      parsedValue ?? values,
      currencySettings,
      decimal: 0,
      enforceDecimals: false,
    );
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
