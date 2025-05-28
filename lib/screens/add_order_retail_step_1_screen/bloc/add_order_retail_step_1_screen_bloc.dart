import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';
import 'package:app_pickleball/services/repositories/courts_for_product_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
// Import ProductItem để sử dụng trong Bloc và State
import 'package:app_pickleball/models/productWithCourts_Model.dart'
    show ProductItem;
import 'package:app_pickleball/models/courtsForProduct_model.dart'
    show CourtItem;
import 'package:app_pickleball/models/available_cour_for_booking_model.dart'
    show AvailableCourForBookingModel, AvailableCourInputModel, Court;
import 'package:app_pickleball/services/repositories/available_cour_for_booking_repository.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'add_order_retail_step_1_screen_event.dart';
part 'add_order_retail_step_1_screen_state.dart';

class AddOrderRetailStep1ScreenBloc
    extends
        Bloc<AddOrderRetailStep1ScreenEvent, AddOrderRetailStep1ScreenState> {
  // Tạo danh sách đầy đủ thời gian
  final List<String> fullTimeOptions = [];
  final WorkTimeRepository _workTimeRepository;
  final ChooseRepository _chooseRepository;
  final CourtsForProductRepository _courtsForProductRepository;
  final AvailableCourForBookingRepository _availableCourRepository;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  BuildContext? _context;

  AddOrderRetailStep1ScreenBloc({
    WorkTimeRepository? workTimeRepository,
    ChooseRepository? chooseRepository,
    CourtsForProductRepository? courtsForProductRepository,
    AvailableCourForBookingRepository? availableCourRepository,
    BuildContext? context,
  }) : _workTimeRepository = workTimeRepository ?? WorkTimeRepository(),
       _chooseRepository = chooseRepository ?? ChooseRepository(),
       _courtsForProductRepository =
           courtsForProductRepository ?? CourtsForProductRepository(),
       _availableCourRepository =
           availableCourRepository ?? AvailableCourForBookingRepository(),
       _context = context,
       super(AddOrderRetailStep1ScreenState()) {
    on<InitializeTimeOptionsEvent>(_onInitializeTimeOptions);
    on<InitializeProductsEvent>(_onInitializeProducts);
    on<ServiceSelected>(_onServiceSelected);
    on<CourtCountChanged>(_onCourtCountChanged);
    on<DatesSelected>(_onDatesSelected);
    on<FromTimeSelected>(_onFromTimeSelected);
    on<ToTimeSelected>(_onToTimeSelected);
    on<SetContextEvent>(_onSetContext);
    on<CourtSelected>(_onCourtSelected);
    on<CheckAvailableCourts>(_onCheckAvailableCourts);

    // Initialize data based on API
    add(InitializeTimeOptionsEvent());
    add(InitializeProductsEvent());
  }

  void _onSetContext(
    SetContextEvent event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    _context = event.context;
  }

  String _getLocalizedProductName(ProductItem product) {
    // If context is not available or product ID is not in localized list, return original name
    if (_context == null || !state.localizedProductIds.contains(product.id)) {
      return product.name;
    }

    // Try to get localized string
    final localKey = 'product_${product.id}';
    final localizedName = AppLocalizations.of(_context!).translate(localKey);

    // If translation exists, return it; otherwise, return original name
    return localizedName != localKey ? localizedName : product.name;
  }

  /// Xác định các ID sản phẩm cần bản địa hóa dựa trên dữ liệu từ API
  List<String> _determineLocalizedProductIds(List<ProductItem> products) {
    // TODO: Trong tương lai, triển khai API endpoint riêng để lấy danh sách sản phẩm cần được bản địa hóa
    // hoặc thêm trường đánh dấu trong response của API getProductsWithCourts

    // Giả lập việc lấy danh sách từ API dựa trên những sản phẩm có sẵn
    final Set<String> localizedProductIdsSet = {};

    // Phát hiện các ID cần localize dựa trên tên sản phẩm
    // Ví dụ: các sản phẩm có tên bắt đầu bằng "Pickleball" hoặc "Pikachu"
    for (var product in products) {
      if (product.name.toLowerCase().contains('pickleball') ||
          product.name.toLowerCase().contains('pikachu')) {
        localizedProductIdsSet.add(product.id);
      }
    }

    return localizedProductIdsSet.toList();
  }

  Future<void> _onInitializeProducts(
    InitializeProductsEvent event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Fetch products data from repository
      final productsData = await _chooseRepository.getProductsWithCourts();
      log.log('Products data from API: ${productsData.totalItems} items');

      if (productsData.items.isNotEmpty) {
        // Store original product items
        List<ProductItem> productItems = productsData.items;

        // Xác định danh sách ID cần bản địa hóa từ API
        final localizedProductIds = _determineLocalizedProductIds(productItems);
        log.log('Localized product IDs from API: $localizedProductIds');

        // Apply localization if context is available
        if (_context != null) {
          // Find a product with a localized ID to use as the default selection
          ProductItem? localizedProduct;
          for (var product in productItems) {
            if (localizedProductIds.contains(product.id)) {
              localizedProduct = product;
              break;
            }
          }

          // If we found a localized product, use it as default, otherwise use the first one
          final firstProduct = localizedProduct ?? productItems.first;

          emit(
            state.copyWith(
              productItems: productItems,
              selectedService: _getLocalizedProductName(firstProduct),
              selectedServiceId: firstProduct.id,
              isLoading: false,
              localizedProductIds: localizedProductIds,
            ),
          );
          log.log(
            'Selected product: ${_getLocalizedProductName(firstProduct)} (${firstProduct.id})',
          );

          // Fetch courts for this product ID
          await _fetchCourtsForProduct(firstProduct.id, emit);
        } else {
          // No context available, use original names
          final firstProduct = productItems.first;
          emit(
            state.copyWith(
              productItems: productItems,
              selectedService: firstProduct.name,
              selectedServiceId: firstProduct.id,
              isLoading: false,
              localizedProductIds: localizedProductIds,
            ),
          );
          log.log(
            'Selected first product: ${firstProduct.name} (${firstProduct.id})',
          );

          // Fetch courts for this product ID
          await _fetchCourtsForProduct(firstProduct.id, emit);
        }
      } else {
        log.log('No products found, using default values');
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      log.log('Error fetching products: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _fetchCourtsForProduct(
    String productId,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    if (productId.isEmpty) {
      log.log('Cannot fetch courts: Product ID is empty');
      // Nếu không có product ID, cập nhật state với danh sách rỗng
      emit(state.copyWith(availableCourts: []));
      return;
    }

    try {
      log.log('Fetching courts for product ID: $productId');
      final courtsResponse = await _courtsForProductRepository
          .getCourtsForProduct(productId: productId);

      log.log('Courts for product ID $productId:');
      for (var court in courtsResponse.courts) {
        log.log('- Court: ${court.name} (${court.id})');
      }

      // Cập nhật state với danh sách sân vừa lấy được
      emit(state.copyWith(availableCourts: courtsResponse.courts));
    } catch (e) {
      log.log('Error fetching courts for product: $e');
      // Nếu có lỗi, cập nhật state với danh sách rỗng
      emit(state.copyWith(availableCourts: []));
    }
  }

  Future<void> _onInitializeTimeOptions(
    InitializeTimeOptionsEvent event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Get channel token for current selected channel
      final selectedChannel = _channelSyncService.selectedChannel;
      // String? channelToken;

      if (selectedChannel.isNotEmpty) {
        log.log('Getting work time for channel: $selectedChannel');

        // Get work time data from repository
        final workTimeData = await _workTimeRepository.getStartAndEndTime();
        log.log('Work time data from API: $workTimeData');

        // Parse start and end times
        final startTimeParts = workTimeData.startTime.split(':');
        final endTimeParts = workTimeData.endTime.split(':');

        if (startTimeParts.length >= 2 && endTimeParts.length >= 2) {
          final startHour = int.parse(startTimeParts[0]);
          final startMinute = int.parse(startTimeParts[1]);
          final endHour = int.parse(endTimeParts[0]);
          final endMinute = int.parse(endTimeParts[1]);

          // Generate time options in 30-minute intervals
          fullTimeOptions.clear();

          // Format for consistent display
          final formattedStartTime =
              '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final formattedEndTime =
              '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

          log.log('Formatted start time: $formattedStartTime');
          log.log('Formatted end time: $formattedEndTime');

          // Generate time slots with 30-minute intervals
          int currentHour = startHour;
          int currentMinute = startMinute;

          // Handle if start minute is not aligned to 30-minute intervals
          if (currentMinute % 30 != 0) {
            currentMinute = (currentMinute ~/ 30) * 30;
          }

          while (true) {
            final timeString =
                '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
            fullTimeOptions.add(timeString);

            // Increment by 30 minutes
            currentMinute += 30;
            if (currentMinute >= 60) {
              currentHour += 1;
              currentMinute = 0;
            }

            // Check if we've reached or passed the end time
            if (currentHour > endHour ||
                (currentHour == endHour && currentMinute > endMinute)) {
              break;
            }
          }

          // Add end time if it's not already in the list and is a valid time
          if (!fullTimeOptions.contains(formattedEndTime) &&
              (endHour > startHour ||
                  (endHour == startHour && endMinute > startMinute))) {
            fullTimeOptions.add(formattedEndTime);
          }

          // If we have at least two time options, set the first as fromTime and second as toTime
          if (fullTimeOptions.length >= 2) {
            emit(
              state.copyWith(
                selectedFromTime: fullTimeOptions.first,
                selectedToTime: fullTimeOptions[1],
                numberOfHours: _calculateHours(
                  fullTimeOptions.first,
                  fullTimeOptions[1],
                ),
                isLoading: false,
              ),
            );
          } else if (fullTimeOptions.isNotEmpty) {
            // Handle case where there's only one time option
            emit(
              state.copyWith(
                selectedFromTime: fullTimeOptions.first,
                selectedToTime: fullTimeOptions.first,
                numberOfHours: 0,
                isLoading: false,
              ),
            );
          } else {
            // Fall back to default values if no time options
            _initDefaultTimeOptions();
            emit(state.copyWith(isLoading: false));
          }

          return;
        }
      }

      // Fall back to default time options if there's an issue
      _initDefaultTimeOptions();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      log.log('Error initializing time options: $e');
      // Fall back to default time options
      _initDefaultTimeOptions();
      emit(state.copyWith(isLoading: false));
    }
  }

  void _initDefaultTimeOptions() {
    fullTimeOptions.clear();
    // Create default time options from 6:00 to 23:30 with 30-minute intervals
    for (int hour = 6; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final String hourStr = hour.toString().padLeft(2, '0');
        final String minuteStr = minute.toString().padLeft(2, '0');
        fullTimeOptions.add('$hourStr:$minuteStr');
      }
    }
  }

  List<String> getValidToTimeOptions(String fromTime) {
    final int fromIndex = fullTimeOptions.indexOf(fromTime);
    if (fromIndex >= 0 && fromIndex < fullTimeOptions.length - 1) {
      return fullTimeOptions.sublist(fromIndex + 1);
    }
    return fullTimeOptions;
  }

  // Xử lý khi kiểm tra sân có sẵn
  Future<void> _onCheckAvailableCourts(
    CheckAvailableCourts event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    log.log('\n=== BẮT ĐẦU KIỂM TRA SÂN CÓ SẴN ===');

    // Kiểm tra xem đã có đủ thông tin cần thiết chưa
    if (state.selectedDates.isEmpty) {
      log.log('Thiếu thông tin: Chưa chọn ngày');
      return;
    }

    if (state.selectedFromTime.isEmpty) {
      log.log('Thiếu thông tin: Chưa chọn giờ bắt đầu');
      return;
    }

    if (state.selectedToTime.isEmpty) {
      log.log('Thiếu thông tin: Chưa chọn giờ kết thúc');
      return;
    }

    if (state.selectedServiceId.isEmpty) {
      log.log('Thiếu thông tin: Chưa chọn dịch vụ hoặc dịch vụ không có ID');
      return;
    }

    try {
      // Báo hiệu đang kiểm tra
      emit(state.copyWith(isCheckingAvailability: true));

      // Chuyển đổi các ngày thành định dạng "YYYY-MM-DD"
      List<String> formattedDates =
          state.selectedDates.map((date) {
            return DateFormat('yyyy-MM-dd').format(date);
          }).toList();

      log.log('=== THÔNG TIN ĐỂ KIỂM TRA SÂN CÓ SẴN ===');
      log.log('Ngày: $formattedDates');
      log.log('Thời gian: ${state.selectedFromTime} - ${state.selectedToTime}');
      log.log('Sản phẩm ID: ${state.selectedServiceId}');
      log.log('Số lượng sân: ${state.courtCount}');

      // Tạo input cho API
      final input = AvailableCourInputModel(
        bookingDates: formattedDates,
        startTime: state.selectedFromTime,
        endTime: state.selectedToTime,
        productId: state.selectedServiceId,
        quantityCourt: state.courtCount,
      );

      log.log('=== GỌI API KIỂM TRA SÂN CÓ SẴN ===');
      log.log('Input JSON: ${input.toJson()}');

      log.log('Channel hiện tại: ${_channelSyncService.selectedChannel}');

      // Gọi API kiểm tra sân có sẵn
      final availableCourts = await _availableCourRepository
          .getAvailableCourForBooking(input);

      // Log đầy đủ response JSON
      log.log('=== RESPONSE ĐẦY ĐỦ TỪ API getAvailableCourtForBooking ===');
      for (var item in availableCourts) {
        log.log('Ngày ${item.bookingDate}:');
        log.log('  Số sân: ${item.courts.length}');
        for (var court in item.courts) {
          log.log(
            '    - ${court.name} (${court.id}): ${court.status}, giá: ${court.price}',
          );
          log.log('      Thời gian: ${court.startTime} - ${court.endTime}');
        }
      }

      // Log kết quả chi tiết theo cấu trúc
      log.log('=== KẾT QUẢ CHI TIẾT TỪ API getAvailableCourtForBooking ===');
      log.log('Số phần tử nhận được: ${availableCourts.length}');
      if (availableCourts.isEmpty) {
        log.log('KHÔNG CÓ DỮ LIỆU SÂN TRẢ VỀ TỪ API!');
      }

      for (var item in availableCourts) {
        // Đếm số sân có status "available"
        final availableCourtCount =
            item.courts.where((court) => court.status == "available").length;

        log.log('- Ngày ${item.bookingDate}:');
        log.log(
          '  - Số sân có sẵn: ${availableCourtCount}/${item.courts.length} (available/total)',
        );
        for (var court in item.courts) {
          log.log(
            '    + ${court.name} (${court.id}): ${court.status}, giá: ${court.price}',
          );
          log.log('    + Thời gian: ${court.startTime} - ${court.endTime}');
        }
      }

      // Cập nhật state với kết quả và xóa các lựa chọn sân cũ
      emit(
        state.copyWith(
          availableCourtsByDate: availableCourts,
          isCheckingAvailability: false,
          // Xóa danh sách sân đã chọn cũ bằng cách tạo Map rỗng mới
          selectedCourtsByDate: const {},
          // Reset tổng tiền về 0
          totalPayment: 0.0,
        ),
      );

      log.log('=== CẬP NHẬT STATE THÀNH CÔNG ===\n');
    } catch (e) {
      log.log('=== LỖI KHI KIỂM TRA SÂN CÓ SẴN ===');
      log.log('Chi tiết lỗi: $e');
      emit(
        state.copyWith(
          isCheckingAvailability: false,
          availableCourtsByDate: [],
        ),
      );
    }
  }

  // Việc kiểm tra sân có sẵn nên được gọi khi người dùng thay đổi các thông tin liên quan
  void _onServiceSelected(
    ServiceSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    log.log('\n=== ServiceSelected Event ===');
    log.log('Dịch vụ đã chọn: ${event.service}');

    // Find the product with matching name or localized name to get its ID
    ProductItem? selectedProduct;

    for (var product in state.productItems) {
      // Check against both original name and localized name
      String localizedName = _getLocalizedProductName(product);
      if (product.name == event.service || localizedName == event.service) {
        selectedProduct = product;
        break;
      }
    }

    // If no match found, create a fallback
    selectedProduct ??= ProductItem(id: '', name: event.service);

    log.log('ID sản phẩm đã tìm thấy: ${selectedProduct.id}');

    emit(
      _updateFormCompleteness(
        state.copyWith(
          selectedService: event.service,
          selectedServiceId: selectedProduct.id,
        ),
      ),
    );

    log.log(
      'Selected service: ${event.service} with ID: ${selectedProduct.id}',
    );

    // Fetch courts for this product ID
    await _fetchCourtsForProduct(selectedProduct.id, emit);

    // Kiểm tra sân có sẵn nếu đủ thông tin
    if (state.selectedDates.isNotEmpty &&
        state.selectedFromTime.isNotEmpty &&
        state.selectedToTime.isNotEmpty) {
      log.log(
        'Đủ thông tin, kích hoạt CheckAvailableCourts từ ServiceSelected',
      );
      await _onCheckAvailableCourts(const CheckAvailableCourts(), emit);
    } else {
      log.log('Thiếu thông tin sau khi chọn dịch vụ:');
      if (state.selectedDates.isEmpty) log.log('- Chưa chọn ngày');
      if (state.selectedFromTime.isEmpty) log.log('- Chưa chọn giờ bắt đầu');
      if (state.selectedToTime.isEmpty) log.log('- Chưa chọn giờ kết thúc');
    }
  }

  void _onCourtCountChanged(
    CourtCountChanged event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    emit(_updateFormCompleteness(state.copyWith(courtCount: event.courtCount)));

    // Kiểm tra sân có sẵn nếu đủ thông tin
    if (state.selectedDates.isNotEmpty &&
        state.selectedFromTime.isNotEmpty &&
        state.selectedToTime.isNotEmpty &&
        state.selectedServiceId.isNotEmpty) {
      await _onCheckAvailableCourts(const CheckAvailableCourts(), emit);
    }
  }

  void _onDatesSelected(
    DatesSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    log.log('\n=== DatesSelected Event ===');
    log.log('Số ngày đã chọn: ${event.dates.length}');
    if (event.dates.isNotEmpty) {
      log.log('Ngày đầu tiên đã chọn: ${event.dates.first}');
    }

    emit(_updateFormCompleteness(state.copyWith(selectedDates: event.dates)));

    // Kiểm tra sân có sẵn nếu đủ thông tin
    if (event.dates.isNotEmpty &&
        state.selectedFromTime.isNotEmpty &&
        state.selectedToTime.isNotEmpty &&
        state.selectedServiceId.isNotEmpty) {
      log.log('Đủ thông tin, kích hoạt CheckAvailableCourts từ DatesSelected');
      await _onCheckAvailableCourts(const CheckAvailableCourts(), emit);
    } else {
      log.log('Thiếu thông tin sau khi chọn ngày:');
      if (event.dates.isEmpty) log.log('- Chưa chọn ngày');
      if (state.selectedFromTime.isEmpty) log.log('- Chưa chọn giờ bắt đầu');
      if (state.selectedToTime.isEmpty) log.log('- Chưa chọn giờ kết thúc');
      if (state.selectedServiceId.isEmpty)
        log.log('- Chưa chọn dịch vụ hoặc dịch vụ không có ID');
    }
  }

  void _onFromTimeSelected(
    FromTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    log.log('\n=== FromTimeSelected Event ===');
    log.log('Giờ bắt đầu đã chọn: ${event.fromTime}');

    final String fromTime = event.fromTime;
    String toTime = state.selectedToTime;

    // Check if toTime is before fromTime
    final int fromIndex = fullTimeOptions.indexOf(fromTime);
    final int toIndex = fullTimeOptions.indexOf(toTime);

    if (toIndex <= fromIndex) {
      // If toTime is before or same as fromTime, set it to next 30 min slot
      int newToIndex = fromIndex + 1;
      if (newToIndex < fullTimeOptions.length) {
        toTime = fullTimeOptions[newToIndex];
        log.log('Tự động cập nhật giờ kết thúc thành: $toTime');
      }
    }

    final double hours = _calculateHours(fromTime, toTime);
    log.log('Số giờ: $hours');

    emit(
      _updateFormCompleteness(
        state.copyWith(
          selectedFromTime: fromTime,
          selectedToTime: toTime,
          numberOfHours: hours,
        ),
      ),
    );

    // Kiểm tra sân có sẵn nếu đủ thông tin
    if (state.selectedDates.isNotEmpty &&
        fromTime.isNotEmpty &&
        toTime.isNotEmpty &&
        state.selectedServiceId.isNotEmpty) {
      log.log(
        'Đủ thông tin, kích hoạt CheckAvailableCourts từ FromTimeSelected',
      );
      await _onCheckAvailableCourts(const CheckAvailableCourts(), emit);
    } else {
      log.log('Thiếu thông tin sau khi chọn giờ bắt đầu:');
      if (state.selectedDates.isEmpty) log.log('- Chưa chọn ngày');
      if (fromTime.isEmpty) log.log('- Chưa chọn giờ bắt đầu');
      if (toTime.isEmpty) log.log('- Chưa chọn giờ kết thúc');
      if (state.selectedServiceId.isEmpty)
        log.log('- Chưa chọn dịch vụ hoặc dịch vụ không có ID');
    }
  }

  void _onToTimeSelected(
    ToTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) async {
    log.log('\n=== ToTimeSelected Event ===');
    log.log('Giờ kết thúc đã chọn: ${event.toTime}');

    final double hours = _calculateHours(state.selectedFromTime, event.toTime);
    log.log('Số giờ: $hours');

    emit(
      _updateFormCompleteness(
        state.copyWith(selectedToTime: event.toTime, numberOfHours: hours),
      ),
    );

    // Kiểm tra sân có sẵn nếu đủ thông tin
    if (state.selectedDates.isNotEmpty &&
        state.selectedFromTime.isNotEmpty &&
        event.toTime.isNotEmpty &&
        state.selectedServiceId.isNotEmpty) {
      log.log('Đủ thông tin, kích hoạt CheckAvailableCourts từ ToTimeSelected');
      await _onCheckAvailableCourts(const CheckAvailableCourts(), emit);
    } else {
      log.log('Thiếu thông tin sau khi chọn giờ kết thúc:');
      if (state.selectedDates.isEmpty) log.log('- Chưa chọn ngày');
      if (state.selectedFromTime.isEmpty) log.log('- Chưa chọn giờ bắt đầu');
      if (event.toTime.isEmpty) log.log('- Chưa chọn giờ kết thúc');
      if (state.selectedServiceId.isEmpty)
        log.log('- Chưa chọn dịch vụ hoặc dịch vụ không có ID');
    }
  }

  double _calculateHours(String fromTime, String toTime) {
    // Parse the time strings to calculate hours
    final fromParts = fromTime.split(':');
    final toParts = toTime.split(':');

    if (fromParts.length == 2 && toParts.length == 2) {
      final fromHour = int.parse(fromParts[0]);
      final fromMinute = int.parse(fromParts[1]);
      final toHour = int.parse(toParts[0]);
      final toMinute = int.parse(toParts[1]);

      final fromMinutes = fromHour * 60 + fromMinute;
      final toMinutes = toHour * 60 + toMinute;

      // Ensure we don't have negative values
      final diffMinutes = toMinutes > fromMinutes ? toMinutes - fromMinutes : 0;
      return diffMinutes / 60;
    }

    return 0;
  }

  AddOrderRetailStep1ScreenState _updateFormCompleteness(
    AddOrderRetailStep1ScreenState state,
  ) {
    // Kiểm tra nếu có ít nhất một sân được chọn
    bool hasSelectedCourts = false;
    if (state.selectedCourtsByDate.isNotEmpty) {
      for (var courtsList in state.selectedCourtsByDate.values) {
        if (courtsList.isNotEmpty) {
          hasSelectedCourts = true;
          break;
        }
      }
    }

    final bool isComplete =
        state.selectedDates.isNotEmpty &&
        state.selectedService.isNotEmpty &&
        hasSelectedCourts;

    return state.copyWith(isFormComplete: isComplete);
  }

  // Xử lý khi người dùng chọn hoặc bỏ chọn một sân
  void _onCourtSelected(
    CourtSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    // Định dạng ngày để làm khóa cho Map
    final String dateKey = DateFormat('yyyy-MM-dd').format(event.bookingDate);

    // Tạo một bản sao của Map lưu trữ sân theo ngày
    Map<String, List<String>> updatedSelectedCourtsByDate =
        Map<String, List<String>>.from(state.selectedCourtsByDate);

    // Tạo một bản sao của Map lưu tên sân theo ID
    Map<String, String> updatedCourtNames = Map<String, String>.from(
      state.courtNamesById,
    );

    // Lấy danh sách sân hiện tại cho ngày này (hoặc tạo mới nếu chưa có)
    List<String> courtsForDate = List.from(
      updatedSelectedCourtsByDate[dateKey] ?? [],
    );

    // Biến để kiểm tra xem có thay đổi gì không
    bool hasChanges = false;

    // Tìm tên sân từ ID trong danh sách sân có sẵn
    String courtName = '';
    for (var dateData in state.availableCourtsByDate) {
      if (dateData.bookingDate == dateKey) {
        for (var court in dateData.courts) {
          if (court.id == event.courtId) {
            courtName = court.name;
            break;
          }
        }
        break;
      }
    }

    if (event.isSelected) {
      // Nếu là chọn sân và ID chưa có trong danh sách
      if (!courtsForDate.contains(event.courtId)) {
        // Kiểm tra số lượng sân đã chọn có vượt quá giới hạn không
        if (courtsForDate.length < state.courtCount) {
          // Nếu chưa đạt giới hạn thì thêm sân mới
          courtsForDate.add(event.courtId);

          // Lưu tên sân theo ID
          if (courtName.isNotEmpty) {
            updatedCourtNames[event.courtId] = courtName;
          }

          hasChanges = true;
          log.log(
            'Thêm sân ${courtName.isNotEmpty ? courtName : event.courtId} vào ngày $dateKey (${courtsForDate.length}/${state.courtCount} sân)',
          );
        } else {
          // Đã đạt giới hạn, log thông báo
          log.log(
            'Không thể thêm sân: Đã đạt giới hạn ${state.courtCount} sân cho ngày $dateKey',
          );
        }
      }
    } else {
      // Nếu là bỏ chọn sân, xóa ID khỏi danh sách
      if (courtsForDate.contains(event.courtId)) {
        courtsForDate.remove(event.courtId);
        hasChanges = true;
        log.log(
          'Bỏ chọn sân ${courtName.isNotEmpty ? courtName : event.courtId} khỏi ngày $dateKey (${courtsForDate.length}/${state.courtCount} sân)',
        );
      }
    }

    // Chỉ cập nhật nếu có thay đổi
    if (hasChanges) {
      // Cập nhật lại danh sách cho ngày cụ thể
      updatedSelectedCourtsByDate[dateKey] = courtsForDate;

      // Log thông tin để debug
      log.log('Cập nhật sân cho ngày $dateKey:');
      log.log(
        '- Sân ID: ${event.courtId}, Tên: ${courtName}, Trạng thái: ${event.isSelected ? 'Đã chọn' : 'Đã bỏ chọn'}',
      );
      log.log('- Danh sách sân hiện tại: ${courtsForDate.join(', ')}');

      // Cập nhật state với Map mới và tính lại tổng tiền
      emit(
        _updateFormCompleteness(
          state.copyWith(
            selectedCourtsByDate: updatedSelectedCourtsByDate,
            courtNamesById: updatedCourtNames,
          ),
        ),
      );

      // Tính và cập nhật tổng tiền
      final updatedState = state.copyWith(
        selectedCourtsByDate: updatedSelectedCourtsByDate,
        courtNamesById: updatedCourtNames,
      );
      final double newTotalPayment = _calculateTotalPaymentForState(
        updatedState,
      );
      emit(
        _updateFormCompleteness(
          updatedState.copyWith(totalPayment: newTotalPayment),
        ),
      );
    }
  }

  // Tính tổng tiền cho một state cụ thể (để tránh vấn đề state chưa được cập nhật)
  double _calculateTotalPaymentForState(
    AddOrderRetailStep1ScreenState currentState,
  ) {
    double total = 0.0;

    // Duyệt qua từng ngày đã chọn sân
    currentState.selectedCourtsByDate.forEach((dateKey, courtIds) {
      // Tìm thông tin ngày này trong dữ liệu có sẵn
      for (var dateData in currentState.availableCourtsByDate) {
        if (dateData.bookingDate == dateKey) {
          // Với mỗi sân được chọn, tìm thông tin giá và cộng vào tổng
          for (var courtId in courtIds) {
            for (var court in dateData.courts) {
              if (court.id == courtId) {
                total += court.price;
                log.log(
                  'Thêm giá của sân ${court.name} (${court.id}): ${court.price} VND',
                );
                break;
              }
            }
          }
          break;
        }
      }
    });

    log.log('Tổng giá tiền đã tính: $total VND');
    return total;
  }

  // Lấy danh sách sân có sẵn cho một ngày cụ thể
  List<Court> getAvailableCourtsForDate(DateTime date) {
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

  // Phương thức localize tên sản phẩm cho người dùng sử dụng từ bên ngoài bloc
  String getLocalizedProductName(String productId, String originalName) {
    // Kiểm tra xem ID sản phẩm có nằm trong danh sách cần localize không
    if (_context != null && state.localizedProductIds.contains(productId)) {
      final localKey = 'product_$productId';
      final localizedName = AppLocalizations.of(_context!).translate(localKey);

      // Nếu có bản dịch, trả về bản dịch; nếu không, trả về tên gốc
      return localizedName != localKey ? localizedName : originalName;
    }

    return originalName;
  }
}
