import 'package:flutter/material.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_calendar_add_booking.dart';
import 'package:app_pickleball/screens/widgets/custom_button.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:intl/intl.dart';

class AddOrderRetailStep1Screen extends StatefulWidget {
  const AddOrderRetailStep1Screen({Key? key}) : super(key: key);

  @override
  State<AddOrderRetailStep1Screen> createState() =>
      _AddOrderRetailStep1ScreenState();
}

class _AddOrderRetailStep1ScreenState extends State<AddOrderRetailStep1Screen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedService = '';
  List<String> servicesList = [
    'Pikachu Pickleball Xuân Hòa',
    'Bao sân',
    'Demo',
    'Pickleball TADA Sport Thanh Đa',
    'Pickleball TADA Sport Bình Lợi',
    'Pickleball TADA Sport D2',
    'Điều hòa',
    'Mái che',
  ];

  int courtCount = 1;
  List<DateTime> selectedDates = [];
  String selectedFromTime = '19:30';
  String selectedToTime = '20:00';
  double? numberOfHours = 0.5;

  // Tạo danh sách đầy đủ thời gian
  final List<String> fullTimeOptions = [];

  @override
  void initState() {
    super.initState();
    // Tạo danh sách thời gian từ 6:00 đến 23:30 với bước 30 phút
    for (int hour = 6; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final String hourStr = hour.toString().padLeft(2, '0');
        final String minuteStr = minute.toString().padLeft(2, '0');
        fullTimeOptions.add('$hourStr:$minuteStr');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('addNew'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dịch vụ
                  _buildServiceDropdown(),
                  const SizedBox(height: 16),

                  // Số sân
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).translate('courtCount'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildCourtCountSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lịch (Calendar)
                  Text(
                    AppLocalizations.of(context).translate('selectDateAndTime'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomCalendarAddBooking(
                    onDatesSelected: (dates) {
                      setState(() {
                        selectedDates = dates;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Thời gian bắt đầu và kết thúc
                  _buildTimeSelectors(),
                  const SizedBox(height: 16),

                  // Hiển thị đặt sân đã chọn
                  _buildSelectedBookings(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStepCircle('1', true),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('courtInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('2', false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('customerInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('3', false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('completeBooking'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String text, bool isActive) {
    return isActive
        ? CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        : Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        );
  }

  Widget _buildServiceDropdown() {
    return CustomDropdown(
      title: AppLocalizations.of(context).translate('serviceName'),
      options: servicesList,
      selectedValue:
          selectedService.isEmpty ? servicesList.first : selectedService,
      menuMaxHeight: 200,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedService = newValue;
          });
        }
      },
    );
  }

  Widget _buildCourtCountSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              courtCount > 1
                  ? () {
                    setState(() {
                      courtCount--;
                    });
                  }
                  : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('$courtCount', style: const TextStyle(fontSize: 16)),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              courtCount++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            title: AppLocalizations.of(context).translate('fromTime'),
            options: fullTimeOptions,
            selectedValue: selectedFromTime,
            dropdownHeight: 50,
            itemFontSize: 14,
            menuMaxHeight: 200,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedFromTime = newValue;
                  _calculateHours();
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomDropdown(
            title: AppLocalizations.of(context).translate('toTime'),
            options: fullTimeOptions,
            selectedValue: selectedToTime,
            dropdownHeight: 50,
            itemFontSize: 14,
            menuMaxHeight: 200,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedToTime = newValue;
                  _calculateHours();
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('hours'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${numberOfHours?.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  void _calculateHours() {
    // Parse the time strings to calculate hours
    final fromParts = selectedFromTime.split(':');
    final toParts = selectedToTime.split(':');

    if (fromParts.length == 2 && toParts.length == 2) {
      final fromHour = int.parse(fromParts[0]);
      final fromMinute = int.parse(fromParts[1]);
      final toHour = int.parse(toParts[0]);
      final toMinute = int.parse(toParts[1]);

      final fromMinutes = fromHour * 60 + fromMinute;
      final toMinutes = toHour * 60 + toMinute;

      final diffMinutes = toMinutes - fromMinutes;
      setState(() {
        numberOfHours = diffMinutes / 60;
      });
    }
  }

  Widget _buildSelectedBookings() {
    if (selectedDates.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('selectedBookings'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...selectedDates.map((date) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#1',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Text('${DateFormat('E, dd/MM/yyyy').format(date)}'),
                      const Spacer(),
                      Text('$selectedFromTime - $selectedToTime'),
                    ],
                  ),
                );
              }).toList(),
              if (selectedService.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('court'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('$selectedService'),
                          ],
                        ),
                      ),
                      Text(
                        '$courtCount ${AppLocalizations.of(context).translate('courts')}',
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('totalPayment'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '0 VNĐ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomElevatedButton(
              text: AppLocalizations.of(context).translate('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomElevatedButton(
              text: AppLocalizations.of(context).translate('next'),
              onPressed:
                  selectedDates.isNotEmpty && selectedService.isNotEmpty
                      ? () {
                        // Navigate to Step 2
                      }
                      : () {},
            ),
          ),
        ],
      ),
    );
  }
}
