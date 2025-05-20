import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension CurrencyFormat on num {
  /// Định dạng số thành tiền tệ dựa trên locale hiện tại
  ///
  /// Ví dụ: 10000 -> 10,000 VND
  String toCurrency(BuildContext context, {int decimalDigits = 0}) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return '${formatter.format(this)} VND';
  }
}
