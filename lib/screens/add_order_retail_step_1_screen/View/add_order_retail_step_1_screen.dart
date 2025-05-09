import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_calendar_add_booking.dart';
import 'package:app_pickleball/screens/widgets/custom_button.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/bloc/add_order_retail_step_1_screen_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/View/add_order_retail_step_2_view.dart';

class AddOrderRetailStep1Screen extends StatefulWidget {
  const AddOrderRetailStep1Screen({Key? key}) : super(key: key);

  @override
  State<AddOrderRetailStep1Screen> createState() =>
      _AddOrderRetailStep1ScreenState();
}

class _AddOrderRetailStep1ScreenState extends State<AddOrderRetailStep1Screen> {
  late final AddOrderRetailStep1ScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AddOrderRetailStep1ScreenBloc();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<
        AddOrderRetailStep1ScreenBloc,
        AddOrderRetailStep1ScreenState
      >(
        builder: (context, state) {
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
                  _buildStepIndicator(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dịch vụ
                        _buildServiceDropdown(context, state),
                        const SizedBox(height: 16),

                        // Số sân
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('courtCount'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildCourtCountSelector(context, state),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Lịch (Calendar)
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('selectDateAndTime'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCalendarAddBooking(
                          onDatesSelected: (dates) {
                            context.read<AddOrderRetailStep1ScreenBloc>().add(
                              DatesSelected(dates),
                            );
                          },
                          allowSelectPastDates:
                              false, // Chỉ cho phép chọn ngày hiện tại và tương lai
                        ),
                        const SizedBox(height: 16),

                        // Thời gian bắt đầu và kết thúc
                        _buildTimeSelectors(context, state),
                        const SizedBox(height: 16),

                        // Hiển thị đặt sân đã chọn
                        _buildSelectedBookings(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(context, state),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
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

  Widget _buildServiceDropdown(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    return CustomDropdown(
      title: AppLocalizations.of(context).translate('serviceName'),
      options: state.servicesList,
      selectedValue:
          state.selectedService.isEmpty
              ? state.servicesList.first
              : state.selectedService,
      menuMaxHeight: 200,
      onChanged: (String? newValue) {
        if (newValue != null) {
          context.read<AddOrderRetailStep1ScreenBloc>().add(
            ServiceSelected(newValue),
          );
        }
      },
    );
  }

  Widget _buildCourtCountSelector(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              state.courtCount > 1
                  ? () {
                    context.read<AddOrderRetailStep1ScreenBloc>().add(
                      CourtCountChanged(state.courtCount - 1),
                    );
                  }
                  : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${state.courtCount}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            context.read<AddOrderRetailStep1ScreenBloc>().add(
              CourtCountChanged(state.courtCount + 1),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    final bloc = context.read<AddOrderRetailStep1ScreenBloc>();

    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            title: AppLocalizations.of(context).translate('fromTime'),
            options: bloc.fullTimeOptions,
            selectedValue: state.selectedFromTime,
            dropdownHeight: 50,
            itemFontSize: 14,
            menuMaxHeight: 200,
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<AddOrderRetailStep1ScreenBloc>().add(
                  FromTimeSelected(newValue),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomDropdown(
            title: AppLocalizations.of(context).translate('toTime'),
            options: bloc.getValidToTimeOptions(state.selectedFromTime),
            selectedValue: state.selectedToTime,
            dropdownHeight: 50,
            itemFontSize: 14,
            menuMaxHeight: 200,
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<AddOrderRetailStep1ScreenBloc>().add(
                  ToTimeSelected(newValue),
                );
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
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${state.numberOfHours.toStringAsFixed(1)}',
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

  Widget _buildSelectedBookings(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    if (state.selectedDates.isEmpty) {
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
              ...state.selectedDates.asMap().entries.map((entry) {
                final int index = entry.key;
                final DateTime date = entry.value;
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
                        '#${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Text('${DateFormat('E, dd/MM/yyyy').format(date)}'),
                      const Spacer(),
                      Text(
                        '${state.selectedFromTime} - ${state.selectedToTime}',
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (state.selectedService.isNotEmpty)
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
                            Text('${state.selectedService}'),
                          ],
                        ),
                      ),
                      Text(
                        '${state.courtCount} ${AppLocalizations.of(context).translate('courts')}',
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

  Widget _buildBottomBar(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
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
              backgroundColor: Colors.white,
              textColor: Colors.black,
              borderColor: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomElevatedButton(
              text: AppLocalizations.of(context).translate('next'),
              onPressed:
                  state.isFormComplete
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const AddOrderRetailStep2View(),
                          ),
                        );
                      }
                      : () {},
              backgroundColor:
                  state.isFormComplete ? Colors.green : Colors.white,
              textColor: state.isFormComplete ? Colors.white : Colors.black,
              borderColor: state.isFormComplete ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
