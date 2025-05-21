import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_tab_button.dart';
import 'package:app_pickleball/screens/widgets/custom_selection_tile.dart';

class CustomCalendarUpdate extends StatefulWidget {
  final Function(List<DateTime>) onDatesSelected;
  final List<DateTime>? initialSelectedDates;

  const CustomCalendarUpdate({
    Key? key,
    required this.onDatesSelected,
    this.initialSelectedDates,
  }) : super(key: key);

  // Hàm hiện calendar dưới dạng bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(List<DateTime>) onDatesSelected,
    List<DateTime>? initialSelectedDates,
  }) {
    return showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CustomCalendarUpdate(
            onDatesSelected: onDatesSelected,
            initialSelectedDates: initialSelectedDates,
          ),
    );
  }

  @override
  State<CustomCalendarUpdate> createState() => _CustomCalendarUpdateState();
}

class _CustomCalendarUpdateState extends State<CustomCalendarUpdate>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};
  late final DateTime _firstDay;
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365 * 2));
  int _selectedViewIndex = 0;
  int _selectedListItem = 0; // Theo dõi mục được chọn trong danh sách
  int? _pendingListItem; // Mục đang chờ xác nhận Apply

  // Màu sắc chính cho thiết kế
  final Color _primaryColor = Colors.green;
  final Color _primaryLightColor = Colors.green.shade50;
  final Color _textColor = Color(0xFF333333);
  final Color _lightGrayColor = Color(0xFFF5F5F5);
  final Color _mediumGrayColor = Color(0xFFE0E0E0);
  final Color _todayHighlightColor = Colors.green.withOpacity(0.15);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedViewIndex = _tabController.index;
        });
      }
    });

    // Khởi tạo firstDay là ngày đầu tiên của năm hiện tại
    _firstDay = DateTime(DateTime.now().year - 1, 1, 1);

    if (widget.initialSelectedDates != null) {
      _selectedDays = Set.from(
        widget.initialSelectedDates!.map(
          (date) => DateTime(date.year, date.month, date.day),
        ),
      );
    }

    // Nếu có ngày được chọn, focus vào ngày gần đây nhất
    if (_selectedDays.isNotEmpty) {
      _focusedDay = _selectedDays.reduce((a, b) => a.isAfter(b) ? a : b);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Xử lý khi nhấn nút Apply
  void _handleApply() {
    // Nếu có mục đang chờ xác nhận từ tab danh sách
    if (_pendingListItem != null) {
      setState(() {
        _selectedListItem = _pendingListItem!;
        _pendingListItem = null;
      });

      // Áp dụng mục được chọn
      _applySelectedListItem();
    }

    widget.onDatesSelected(_selectedDays.toList());
    Navigator.pop(context);
  }

  // Áp dụng mục được chọn trong danh sách vào lịch
  void _applySelectedListItem() {
    final now = DateTime.now();
    final today = _normalizeDate(now);

    switch (_selectedListItem) {
      case 0: // Today
        _selectedDays = {today};
        break;
      case 1: // This Week
        // Tính toán ngày đầu tuần (thứ 2) và cuối tuần (chủ nhật)
        final thisWeekMonday = now.subtract(Duration(days: now.weekday - 1));

        // Chọn tất cả các ngày trong tuần này
        _selectedDays = {};
        for (int i = 0; i <= 6; i++) {
          _selectedDays.add(
            _normalizeDate(thisWeekMonday.add(Duration(days: i))),
          );
        }
        _focusedDay = thisWeekMonday;
        break;
      case 2: // Next Week
        final nextWeekMonday = now.add(Duration(days: 7 - now.weekday + 1));

        // Chọn tất cả các ngày trong tuần sau
        _selectedDays = {};
        for (int i = 0; i <= 6; i++) {
          _selectedDays.add(
            _normalizeDate(nextWeekMonday.add(Duration(days: i))),
          );
        }
        _focusedDay = nextWeekMonday;
        break;
      case 3: // This Month
        // Chọn tất cả các ngày trong tháng hiện tại
        _selectedDays = {};
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

        for (int i = 0; i < lastDayOfMonth.day; i++) {
          _selectedDays.add(
            _normalizeDate(firstDayOfMonth.add(Duration(days: i))),
          );
        }
        _focusedDay = firstDayOfMonth;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Thanh chỉ báo kéo xuống
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _mediumGrayColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Tab chuyển đổi giữa Lịch và Danh sách
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              decoration: BoxDecoration(
                color: _lightGrayColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Animated selector background
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left:
                        _selectedViewIndex == 0
                            ? 0
                            : MediaQuery.of(context).size.width / 2 - 16,
                    top: 3,
                    bottom: 3,
                    width: (MediaQuery.of(context).size.width - 32) / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab buttons
                  Row(
                    children: [
                      _buildTabButton(
                        0,
                        Icons.calendar_today,
                        AppLocalizations.of(context).translate('calendar'),
                      ),
                      _buildTabButton(
                        1,
                        Icons.list_alt,
                        AppLocalizations.of(context).translate('listView'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // TabBarView với chiều cao linh hoạt
            Flexible(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildCalendarTab(), _buildListTab()],
              ),
            ),

            // Separator line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: _mediumGrayColor),
            ),

            // Nút Hủy và Áp dụng
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: _textColor,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _mediumGrayColor),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('cancel'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_selectedDays.isEmpty && _pendingListItem == null)
                              ? null
                              : _handleApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('apply'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String title) {
    return CustomTabButton(
      icon: icon,
      title: title,
      isSelected: _selectedViewIndex == index,
      onTap: () {
        setState(() {
          _selectedViewIndex = index;
          _tabController.animateTo(index);
        });
      },
      selectedColor: _primaryColor,
      unselectedColor: Colors.grey,
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header với chuyển đổi tháng
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút tháng trước
              IconButton(
                icon: Icon(Icons.chevron_left, color: _textColor, size: 20),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      _focusedDay.day,
                    );
                  });
                },
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),

              // Hiển thị tháng năm
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Có thể thêm chức năng hiển thị date picker ở đây
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _primaryLightColor,
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('monthFormat')
                          .replaceAll(
                            '{month}',
                            DateFormat('MM yyyy').format(_focusedDay),
                          ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // Nút tháng sau
              IconButton(
                icon: Icon(Icons.chevron_right, color: _textColor, size: 20),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                      _focusedDay.day,
                    );
                  });
                },
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),

        // Lịch
        Expanded(
          child: TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            availableGestures: AvailableGestures.horizontalSwipe,

            // Style ngày trong tuần
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: _textColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Colors.red.shade400,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Style calendar
            calendarStyle: CalendarStyle(
              // Text styles
              defaultTextStyle: TextStyle(color: _textColor, fontSize: 12),
              weekendTextStyle: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
              outsideTextStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),

              // Decoration cho ngày được chọn
              selectedDecoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),

              // Decoration cho ngày hiện tại
              todayDecoration: BoxDecoration(
                color: _todayHighlightColor,
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 1),
              ),
              todayTextStyle: TextStyle(
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),

              // Hiệu ứng hover và cell spacing
              cellMargin: EdgeInsets.all(1),
              cellPadding: EdgeInsets.zero,
              rangeHighlightColor: _primaryLightColor,
              markersMaxCount: 3,
            ),

            // Chiều cao dòng - giảm chiều cao để khắc phục tràn
            rowHeight: 28,

            // Xử lý ngày được chọn
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
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 4),
      physics: BouncingScrollPhysics(),
      children: [
        // Hôm nay
        _buildQuickSelectionItem(
          index: 0,
          icon: Icons.today,
          title: AppLocalizations.of(context).translate('today'),
          subtitle: DateFormat(
            'dd/MM/yyyy, EEEE',
            'vi_VN',
          ).format(DateTime.now()),
          onTap: () {
            setState(() {
              // Chỉ đánh dấu là đang chờ, chưa áp dụng ngay
              _pendingListItem = 0;
            });
          },
        ),

        // Tuần này
        _buildQuickSelectionItem(
          index: 1,
          icon: Icons.view_week,
          title: AppLocalizations.of(context).translate('thisWeek'),
          subtitle: AppLocalizations.of(
            context,
          ).translate('selectDaysInThisWeek'),
          onTap: () {
            setState(() {
              _pendingListItem = 1;
            });
          },
        ),

        // Tuần sau
        _buildQuickSelectionItem(
          index: 2,
          icon: Icons.next_week,
          title: AppLocalizations.of(context).translate('nextWeek'),
          subtitle: AppLocalizations.of(
            context,
          ).translate('selectDaysInNextWeek'),
          onTap: () {
            setState(() {
              _pendingListItem = 2;
            });
          },
        ),

        // Tháng này
        _buildQuickSelectionItem(
          index: 3,
          icon: Icons.calendar_month,
          title: AppLocalizations.of(context).translate('thisMonth'),
          subtitle: AppLocalizations.of(
            context,
          ).translate('selectDaysInThisMonth'),
          onTap: () {
            setState(() {
              _pendingListItem = 3;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickSelectionItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // Mục được chọn là mục đang chờ nếu có, nếu không thì là mục đã được chọn
    final bool isSelected =
        _pendingListItem == index ||
        (_pendingListItem == null && _selectedListItem == index);

    return CustomSelectionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
      primaryColor: _primaryColor,
      textColor: _textColor,
    );
  }
}
