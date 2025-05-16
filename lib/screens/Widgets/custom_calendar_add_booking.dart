import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class CustomCalendarAddBooking extends StatefulWidget {
  final Function(List<DateTime>) onDatesSelected;
  final List<DateTime>? initialSelectedDates;
  final bool allowSelectPastDates;

  const CustomCalendarAddBooking({
    super.key,
    required this.onDatesSelected,
    this.initialSelectedDates,
    this.allowSelectPastDates = true,
  });

  @override
  State<CustomCalendarAddBooking> createState() =>
      _CustomCalendarAddBookingState();
}

class _CustomCalendarAddBookingState extends State<CustomCalendarAddBooking> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};
  late final DateTime _firstDay;
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    // Set first day based on allowSelectPastDates property
    _firstDay =
        widget.allowSelectPastDates
            ? DateTime.now().subtract(const Duration(days: 365))
            : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ).subtract(
              const Duration(days: 365 * 5),
            ); // Cho phép xem nhiều năm trước đó

    if (widget.initialSelectedDates != null) {
      // Filter out past dates if not allowed
      if (!widget.allowSelectPastDates) {
        _selectedDays =
            widget.initialSelectedDates!
                .where(
                  (date) =>
                      date.isAtSameMomentAs(_firstDay) ||
                      date.isAfter(_firstDay),
                )
                .toSet();
      } else {
        _selectedDays = widget.initialSelectedDates!.toSet();
      }
    }
  }

  bool _isValidFocusedDay(DateTime day) {
    // Phải đảm bảo ngày tập trung nằm trong khoảng được phép của TableCalendar
    return (day.isAtSameMomentAs(_firstDay) || day.isAfter(_firstDay)) &&
        (day.isAtSameMomentAs(_lastDay) || day.isBefore(_lastDay));
  }

  void _safelyUpdateFocusedDay(DateTime newFocusedDay) {
    if (_isValidFocusedDay(newFocusedDay)) {
      setState(() {
        _focusedDay = newFocusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        TableCalendar(
          firstDay: _firstDay,
          lastDay: _lastDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekVisible: true,
          rowHeight: 40, // Đặt chiều cao dòng
          daysOfWeekHeight: 30, // Đặt chiều cao dòng của ngày trong tuần
          sixWeekMonthsEnforced: true, // Luôn hiển thị 6 tuần
          availableGestures: AvailableGestures.none, // Tắt cử chỉ vuốt
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            cellMargin: const EdgeInsets.all(1), // Thu nhỏ margin
            // Style for disabled (past) dates
            disabledTextStyle: const TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.none,
            ),
            disabledDecoration: const BoxDecoration(shape: BoxShape.circle),
          ),
          headerVisible: false,
          selectedDayPredicate: (day) {
            return _selectedDays.contains(_normalizeDate(day));
          },
          enabledDayPredicate: (day) {
            // Only allow selecting current and future dates if allowSelectPastDates is false
            if (!widget.allowSelectPastDates) {
              final today = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );
              return day.isAtSameMomentAs(today) || day.isAfter(today);
            }
            return true;
          },
          onDaySelected: (selectedDay, focusedDay) {
            final normalizedDay = _normalizeDate(selectedDay);

            // Check if the day is selectable
            final today = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );
            final isPastDay = normalizedDay.isBefore(today);

            if (!widget.allowSelectPastDates && isPastDay) {
              // Don't allow selecting past days
              return;
            }

            setState(() {
              if (_selectedDays.contains(normalizedDay)) {
                _selectedDays.remove(normalizedDay);
              } else {
                _selectedDays.add(normalizedDay);
              }
              _focusedDay = focusedDay;

              // Trigger callback
              widget.onDatesSelected(_selectedDays.toList());
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _safelyUpdateFocusedDay(focusedDay);
          },
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: const TextStyle(fontSize: 12),
            weekendStyle: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _safelyUpdateFocusedDay(DateTime.now());
              },
              child: Text(
                AppLocalizations.of(context).translate('today'),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ],
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  // Sửa: Luôn cho phép xem tháng trước, không phụ thuộc vào _firstDay
                  _safelyUpdateFocusedDay(
                    DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      _focusedDay.day > 28 ? 28 : _focusedDay.day,
                    ),
                  );
                },
              ),
              Text(
                '${DateFormat.yMMM().format(_focusedDay)}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final nextMonth = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                    1,
                  );

                  if (nextMonth.isBefore(_lastDay) ||
                      nextMonth.year == _lastDay.year &&
                          nextMonth.month == _lastDay.month) {
                    _safelyUpdateFocusedDay(
                      DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        _focusedDay.day,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context).translate('month'),
                  style: TextStyle(
                    color:
                        _calendarFormat == CalendarFormat.month
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _calendarFormat = CalendarFormat.month;
                  });
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context).translate('week'),
                  style: TextStyle(
                    color:
                        _calendarFormat == CalendarFormat.week
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _calendarFormat = CalendarFormat.week;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
