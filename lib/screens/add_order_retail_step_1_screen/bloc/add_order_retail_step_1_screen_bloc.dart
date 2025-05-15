import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';
import 'package:app_pickleball/services/repositories/courts_for_product_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/models/productWithCourts_Model.dart';
import 'package:app_pickleball/models/courtsForProduct_model.dart';
// Import ProductItem để sử dụng trong Bloc và State
import 'package:app_pickleball/models/productWithCourts_Model.dart'
    show ProductItem;
import 'dart:developer' as log;
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:flutter/material.dart';

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
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  BuildContext? _context;

  // List of product IDs that need localization
  final List<String> _localizedProductIds = ['73', '75', '77', '78'];

  AddOrderRetailStep1ScreenBloc({
    WorkTimeRepository? workTimeRepository,
    ChooseRepository? chooseRepository,
    CourtsForProductRepository? courtsForProductRepository,
    BuildContext? context,
  }) : _workTimeRepository = workTimeRepository ?? WorkTimeRepository(),
       _chooseRepository = chooseRepository ?? ChooseRepository(),
       _courtsForProductRepository =
           courtsForProductRepository ?? CourtsForProductRepository(),
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
    if (_context == null || !_localizedProductIds.contains(product.id)) {
      return product.name;
    }

    // Try to get localized string
    final localKey = 'product_${product.id}';
    final localizedName = AppLocalizations.of(_context!).translate(localKey);

    // If translation exists, return it; otherwise, return original name
    return localizedName != localKey ? localizedName : product.name;
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

        // Apply localization if context is available
        if (_context != null) {
          // Find a product with a localized ID to use as the default selection
          ProductItem? localizedProduct;
          for (var product in productItems) {
            if (_localizedProductIds.contains(product.id)) {
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
            ),
          );
          log.log(
            'Selected product: ${_getLocalizedProductName(firstProduct)} (${firstProduct.id})',
          );

          // Fetch courts for this product ID
          _fetchCourtsForProduct(firstProduct.id);
        } else {
          // No context available, use original names
          final firstProduct = productItems.first;
          emit(
            state.copyWith(
              productItems: productItems,
              selectedService: firstProduct.name,
              selectedServiceId: firstProduct.id,
              isLoading: false,
            ),
          );
          log.log(
            'Selected first product: ${firstProduct.name} (${firstProduct.id})',
          );

          // Fetch courts for this product ID
          _fetchCourtsForProduct(firstProduct.id);
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

  Future<void> _fetchCourtsForProduct(String productId) async {
    if (productId.isEmpty) {
      log.log('Cannot fetch courts: Product ID is empty');
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
    } catch (e) {
      log.log('Error fetching courts for product: $e');
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

  void _onServiceSelected(
    ServiceSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
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
    _fetchCourtsForProduct(selectedProduct.id);
  }

  void _onCourtCountChanged(
    CourtCountChanged event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    emit(_updateFormCompleteness(state.copyWith(courtCount: event.courtCount)));
  }

  void _onDatesSelected(
    DatesSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    emit(_updateFormCompleteness(state.copyWith(selectedDates: event.dates)));
  }

  void _onFromTimeSelected(
    FromTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
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
      }
    }

    final double hours = _calculateHours(fromTime, toTime);
    emit(
      _updateFormCompleteness(
        state.copyWith(
          selectedFromTime: fromTime,
          selectedToTime: toTime,
          numberOfHours: hours,
        ),
      ),
    );
  }

  void _onToTimeSelected(
    ToTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    final double hours = _calculateHours(state.selectedFromTime, event.toTime);
    emit(
      _updateFormCompleteness(
        state.copyWith(selectedToTime: event.toTime, numberOfHours: hours),
      ),
    );
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
    final bool isComplete =
        state.selectedDates.isNotEmpty && state.selectedService.isNotEmpty;
    return state.copyWith(isFormComplete: isComplete);
  }
}
