import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_calendar_add_booking.dart';
import 'package:app_pickleball/screens/widgets/custom_button.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/bloc/add_order_retail_step_1_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';
import 'package:app_pickleball/services/repositories/courts_for_product_repository.dart';
import 'package:app_pickleball/services/repositories/available_cour_for_booking_repository.dart';
// import 'package:app_pickleball/models/courtsForProduct_model.dart';
import 'package:app_pickleball/models/available_cour_for_booking_model.dart';
// import 'package:app_pickleball/models/productWithCourts_Model.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/View/add_order_retail_step_2_view.dart';
import 'dart:developer' as log;
import 'package:intl/number_symbols.dart';

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
    // List of product IDs that need localization
    List<String> localizedProductIds = ['73', '75', '77', '78'];

    if (localizedProductIds.contains(productId)) {
      final localKey = 'product_$productId';
      final localizedName = AppLocalizations.of(context).translate(localKey);

      // If translation exists, return it; otherwise, return original name
      return localizedName != localKey ? localizedName : originalName;
    }

    return originalName;
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
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
                                    context
                                        .read<AddOrderRetailStep1ScreenBloc>()
                                        .add(DatesSelected(dates));
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

  Widget _buildCourtCountSelector(
    BuildContext context,
    AddOrderRetailStep1ScreenState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap:
                state.courtCount > 1
                    ? () {
                      context.read<AddOrderRetailStep1ScreenBloc>().add(
                        CourtCountChanged(state.courtCount - 1),
                      );
                    }
                    : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.courtCount > 1 ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              '${state.courtCount}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<AddOrderRetailStep1ScreenBloc>().add(
                CourtCountChanged(state.courtCount + 1),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: const Text(
                '+',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 8),

                      // Hiển thị trạng thái đang kiểm tra
                      if (state.isCheckingAvailability)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Đang kiểm tra sân có sẵn...'),
                              ],
                            ),
                          ),
                        )
                      // Hiển thị thông báo khi không có sân hoặc danh sách các sân có sẵn
                      else if (_getAvailableCourtsForDate(state, date).isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Không có sân',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _getAvailableCourtsForDate(state, date).map((
                                court,
                              ) {
                                // Lấy danh sách sân đã chọn cho ngày cụ thể này
                                final String dateKey = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(date);
                                final List<String> selectedCourtsForThisDate =
                                    state.selectedCourtsByDate[dateKey] ?? [];

                                // Kiểm tra xem sân có được chọn cho ngày này không
                                final bool isSelected =
                                    selectedCourtsForThisDate.contains(
                                      court.id,
                                    );

                                // Kiểm tra xem đã đạt giới hạn số lượng sân chọn chưa
                                final bool reachedLimit =
                                    selectedCourtsForThisDate.length >=
                                    state.courtCount;

                                // Chỉ vô hiệu hóa nếu đạt giới hạn VÀ sân hiện tại chưa được chọn
                                final bool isDisabled =
                                    reachedLimit && !isSelected;

                                return ElevatedButton(
                                  onPressed:
                                      isDisabled
                                          ? null // Vô hiệu hóa nút nếu đã đạt giới hạn và sân này chưa được chọn
                                          : () {
                                            // Khi nhấn nút, thay đổi trạng thái chọn của sân
                                            context
                                                .read<
                                                  AddOrderRetailStep1ScreenBloc
                                                >()
                                                .add(
                                                  CourtSelected(
                                                    courtId: court.id,
                                                    isSelected:
                                                        !isSelected, // Đảo ngược trạng thái hiện tại
                                                    bookingDate:
                                                        date, // Thêm ngày đặt sân
                                                  ),
                                                );
                                          },
                                  style: ElevatedButton.styleFrom(
                                    // Sân được chọn -> màu xanh, chưa chọn -> màu xám
                                    // Sân vô hiệu hóa -> màu xám nhạt
                                    backgroundColor:
                                        isDisabled
                                            ? Colors.grey[300]
                                            : (isSelected
                                                ? Colors.green
                                                : Colors.grey),
                                    foregroundColor:
                                        isDisabled
                                            ? Colors.black38
                                            : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(60, 36),
                                  ),
                                  child: Text(
                                    court.name,
                                    style: TextStyle(
                                      color:
                                          isDisabled
                                              ? Colors.black38
                                              : Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
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
                            Text('${displayServiceName}'),
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
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VNĐ',
                        decimalDigits: 0,
                      ).format(state.totalPayment),
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

  List<Court> _getAvailableCourtsForDate(
    AddOrderRetailStep1ScreenState state,
    DateTime date,
  ) {
    // Định dạng ngày để so sánh (YYYY-MM-DD)
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    // Tìm dữ liệu cho ngày cụ thể trong danh sách kết quả từ API
    for (var item in state.availableCourtsByDate) {
      if (item.bookingDate == dateString) {
        // Lọc sân chỉ lấy những sân có status là "available"
        return item.courts
            .where((court) => court.status == "available")
            .toList();
      }
    }

    // Nếu không tìm thấy, trả về danh sách rỗng
    return [];
  }
}
