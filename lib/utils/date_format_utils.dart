import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateFormatExtension on DateTime {
  /// Định dạng ngày tháng theo locale hiện tại
  ///
  /// Ví dụ:
  /// - Tiếng Việt: 20/10/2023
  /// - Tiếng Anh: 10/20/2023
  String toLocaleDateString(
    BuildContext context, {
    String pattern = 'dd/MM/yyyy',
  }) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }

  /// Định dạng thời gian theo locale hiện tại
  ///
  /// Ví dụ:
  /// - 24h: 14:30
  /// - 12h: 2:30 PM
  String toLocaleTimeString(
    BuildContext context, {
    bool use24HourFormat = true,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = use24HourFormat ? 'HH:mm' : 'h:mm a';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }

  /// Định dạng ngày tháng năm và thời gian theo locale hiện tại
  ///
  /// Ví dụ: 20/10/2023 14:30
  String toLocaleDateTimeString(
    BuildContext context, {
    bool use24HourFormat = true,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = use24HourFormat ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy h:mm a';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }

  /// Lấy tên tháng theo locale hiện tại
  ///
  /// Ví dụ: Tháng 10, October
  String getMonthName(BuildContext context, {bool isFullName = true}) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = isFullName ? 'MMMM' : 'MMM';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }

  /// Lấy tên thứ trong tuần theo locale hiện tại
  ///
  /// Ví dụ: Thứ Hai, Monday
  String getWeekdayName(BuildContext context, {bool isFullName = true}) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = isFullName ? 'EEEE' : 'EEE';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }
}

/// Class tiện ích để định dạng thời gian
class DateTimeFormatter {
  /// Chuyển đổi chuỗi thời gian thành chuỗi định dạng theo locale
  static String formatTimeString(BuildContext context, String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final timeOfDay = TimeOfDay(hour: hour, minute: minute);
        return timeOfDay.format(context);
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  /// Phân tích chuỗi ngày tháng thành đối tượng DateTime
  static DateTime? parseDate(
    String dateString, {
    String pattern = 'dd/MM/yyyy',
  }) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
