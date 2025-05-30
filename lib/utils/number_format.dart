import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension CurrencyFormat on num {
  /// Định dạng số thành tiền tệ với dấu phẩy làm dấu phân cách hàng nghìn
  ///
  /// Ví dụ: 10000 -> 10,000 VND
  String toCurrency(BuildContext context, {int decimalDigits = 0}) {
    // Sử dụng 'en_US' để luôn có dấu phẩy làm dấu phân cách hàng nghìn
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return '${formatter.format(this)} VND';
  }
}
