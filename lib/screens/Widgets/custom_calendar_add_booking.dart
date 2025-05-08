import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class CustomCalendarAddBooking extends StatefulWidget {
  final Function(List<DateTime>) onDatesSelected;
  final List<DateTime>? initialSelectedDates;

  const CustomCalendarAddBooking({
    Key? key,
    required this.onDatesSelected,
    this.initialSelectedDates,
  }) : super(key: key);

  @override
  State<CustomCalendarAddBooking> createState() =>
      _CustomCalendarAddBookingState();
}

class _CustomCalendarAddBookingState extends State<CustomCalendarAddBooking> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};
  final DateTime _firstDay = DateTime.now();
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedDates != null) {
      _selectedDays = widget.initialSelectedDates!.toSet();
    }
  }

  bool _isValidFocusedDay(DateTime day) {
    // Kiểm tra xem ngày có nằm trong khoảng hợp lệ không
    return day.isAtSameMomentAs(_firstDay) ||
        day.isAfter(_firstDay) &&
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
          ),
          headerVisible: false,
          selectedDayPredicate: (day) {
            return _selectedDays.contains(_normalizeDate(day));
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              final normalizedDay = _normalizeDate(selectedDay);
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
                  // Tính toán tháng trước
                  final previousMonth = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                    1,
                  );

                  // Kiểm tra xem tháng trước có hợp lệ không
                  if (previousMonth.isAfter(_firstDay) ||
                      previousMonth.year == _firstDay.year &&
                          previousMonth.month == _firstDay.month) {
                    _safelyUpdateFocusedDay(
                      DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        _focusedDay.day,
                      ),
                    );
                  }
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
