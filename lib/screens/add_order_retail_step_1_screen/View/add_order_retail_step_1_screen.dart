import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/calendar/custom_calendar_add_booking.dart';
import 'package:app_pickleball/screens/widgets/input/custom_dropdown.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_step_indicator.dart';
import 'package:app_pickleball/screens/widgets/input/custom_court_count_selector.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_booking_date_card.dart';
import 'package:app_pickleball/screens/widgets/summary/custom_booking_summary.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/bloc/add_order_retail_step_1_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';
import 'package:app_pickleball/services/repositories/courts_for_product_repository.dart';
import 'package:app_pickleball/services/repositories/available_cour_for_booking_repository.dart';
import 'package:app_pickleball/models/available_cour_for_booking_model.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/View/add_order_retail_step_2_view.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_action_button.dart';

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
    _bloc = AddOrderRetailStep1ScreenBloc(
      workTimeRepository: WorkTimeRepository(),
      chooseRepository: ChooseRepository(),
      courtsForProductRepository: CourtsForProductRepository(),
      availableCourRepository: AvailableCourForBookingRepository(),
      context: context,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update context in bloc whenever it changes (e.g., language switch)
    _bloc.add(SetContextEvent(context));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // Helper method to get localized product name
  String getLocalizedProductName(String productId, String originalName) {
    return _bloc.getLocalizedProductName(productId, originalName);
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
            body:
                state.isLoading
                    ? const CustomLoadingIndicator()
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomStepIndicator(
                            currentStep: 1,
                            stepKeys: [
                              'courtInformation',
                              'customerInformation',
                              'completeBooking',
                            ],
                          ),
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
                                    CustomCourtCountSelector(
                                      value: state.courtCount,
                                      maxValue: state.maxCourtCount,
                                      onChanged: (value) {
                                        context
                                            .read<
                                              AddOrderRetailStep1ScreenBloc
                                            >()
                                            .add(CourtCountChanged(value));
                                      },
                                    ),
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
                                    context
                                        .read<AddOrderRetailStep1ScreenBloc>()
                                        .add(DatesSelected(dates));
                                  },
                                  allowSelectPastDates: false,
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

  Widget _buildServiceDropdown(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    // Prepare list of service names with localization applied
    List<String> localizedServices = [];

    if (state.productItems.isEmpty) {
      localizedServices = state.servicesList;
    } else {
      // Apply localization to each service name
      for (var product in state.productItems) {
        String localizedName = getLocalizedProductName(
          product.id,
          product.name,
        );
        localizedServices.add(localizedName);
      }
    }

    // Determine the selected value with localization applied
    String selectedValue = state.selectedService;
    if (state.selectedServiceId.isNotEmpty) {
      // Find the product with the matching ID
      final matchingProducts =
          state.productItems
              .where((p) => p.id == state.selectedServiceId)
              .toList();
      if (matchingProducts.isNotEmpty) {
        final product = matchingProducts.first;
        selectedValue = getLocalizedProductName(product.id, product.name);
      }
    }

    // If no selection yet and we have services, use the first one
    if (selectedValue.isEmpty && localizedServices.isNotEmpty) {
      selectedValue = localizedServices.first;
    }

    return CustomDropdown(
      title: AppLocalizations.of(context).translate('serviceName'),
      options: localizedServices,
      selectedValue: selectedValue,
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
                  horizontal: 35,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
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

    // Get localized service name if needed
    String displayServiceName = state.selectedService;
    if (state.selectedServiceId.isNotEmpty) {
      // Find the product with this ID
      final matchingProducts =
          state.productItems
              .where((p) => p.id == state.selectedServiceId)
              .toList();
      if (matchingProducts.isNotEmpty) {
        final product = matchingProducts.first;
        displayServiceName = getLocalizedProductName(product.id, product.name);
      }
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
                final String dateKey = DateFormat('yyyy-MM-dd').format(date);
                final List<String> selectedCourtsForThisDate =
                    state.selectedCourtsByDate[dateKey] ?? [];

                return CustomBookingDateCard(
                  index: index,
                  date: date,
                  fromTime: state.selectedFromTime,
                  toTime: state.selectedToTime,
                  availableCourts: _getAvailableCourtsForDate(state, date),
                  selectedCourtIds: selectedCourtsForThisDate,
                  maxCourtSelections: state.courtCount,
                  isCheckingAvailability: state.isCheckingAvailability,
                  onCourtSelected: (courtId, isSelected, bookingDate) {
                    context.read<AddOrderRetailStep1ScreenBloc>().add(
                      CourtSelected(
                        courtId: courtId,
                        isSelected: isSelected,
                        bookingDate: bookingDate,
                      ),
                    );
                  },
                );
              }).toList(),

              if (state.selectedService.isNotEmpty)
                CustomBookingSummary(
                  serviceName: displayServiceName,
                  courtCount: state.courtCount,
                  totalPayment: state.totalPayment,
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
            child: CustomActionButton(
              text: AppLocalizations.of(context).translate('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomActionButton(
              text: AppLocalizations.of(context).translate('next'),
              onPressed: () {
                if (state.isFormComplete) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddOrderRetailStep2View(
                            totalPayment: state.totalPayment,
                            serviceName: state.selectedService,
                            selectedDates: state.selectedDates,
                            fromTime: state.selectedFromTime,
                            toTime: state.selectedToTime,
                            numberOfHours: state.numberOfHours,
                            selectedCourtsByDate: state.selectedCourtsByDate,
                            courtCount: state.courtCount,
                            courtNamesById: state.courtNamesById,
                            productId: state.selectedServiceId,
                          ),
                    ),
                  );
                } else {
                  // Kiểm tra lý do không thể tiếp tục
                  String errorMessage;

                  if (state.selectedDates.isEmpty) {
                    errorMessage = AppLocalizations.of(
                      context,
                    ).translate('pleaseSelectDate');
                  } else if (state.selectedService.isEmpty) {
                    errorMessage = AppLocalizations.of(
                      context,
                    ).translate('pleaseSelectService');
                  } else {
                    // Kiểm tra xem có ngày nào chưa chọn sân hay không
                    List<String> datesWithoutCourts = [];

                    for (final DateTime date in state.selectedDates) {
                      final String dateKey = DateFormat(
                        'yyyy-MM-dd',
                      ).format(date);
                      final List<String>? courtsForThisDate =
                          state.selectedCourtsByDate[dateKey];

                      if (courtsForThisDate == null ||
                          courtsForThisDate.isEmpty) {
                        // Thêm ngày vào danh sách ngày chưa chọn sân
                        String formattedDate = DateFormat(
                          'dd/MM/yyyy',
                        ).format(date);
                        datesWithoutCourts.add(formattedDate);
                      }
                    }

                    if (datesWithoutCourts.isNotEmpty) {
                      if (datesWithoutCourts.length == 1) {
                        errorMessage = AppLocalizations.of(context)
                            .translate('pleaseSelectCourtForDate')
                            .replaceAll('{date}', datesWithoutCourts.first);
                      } else {
                        errorMessage = AppLocalizations.of(context)
                            .translate('pleaseSelectCourtForDates')
                            .replaceAll(
                              '{dates}',
                              datesWithoutCourts.join(', '),
                            );
                      }
                    } else {
                      errorMessage = AppLocalizations.of(
                        context,
                      ).translate('pleaseCompleteAllInfo');
                    }
                  }

                  // Hiển thị SnackBar thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              isPrimary: true,
              isEnabled: state.isFormComplete,
            ),
          ),
        ],
      ),
    );
  }

  List<Court> _getAvailableCourtsForDate(
    AddOrderRetailStep1ScreenState state,
    DateTime date,
  ) {
    return _bloc.getAvailableCourtsForDate(date);
  }
}
