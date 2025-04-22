import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/bookingList_repository.dart';
import 'dart:developer' as log;

part 'orderlist_screen_event.dart';
part 'orderlist_screen_state.dart';

class OrderListScreenBloc
    extends Bloc<OrderListScreenEvent, OrderListScreenState> {
  final BookingListRepository _bookingListRepository;
  final List<String> _availableChannels = [
    'Default channel',
    'Pikachu Pickleball Xuân Hoà',
    'Demo-channel',
    'Stamina 106 Hoàng Quốc Việt',
    'TADA Sport CN1 - Thanh Đa',
    'TADA Sport CN2 - Bình Lợi',
    'TADA Sport CN3 - D2(Ung Văn Khiêm)',
  ];

  OrderListScreenBloc({BookingListRepository? bookingListRepository})
    : _bookingListRepository = bookingListRepository ?? BookingListRepository(),
      super(
        const OrderListScreenInitial(
          selectedChannel: 'Default channel',
          availableChannels: [
            'Default channel',
            'Pikachu Pickleball Xuân Hoà',
            'Demo-channel',
            'Stamina 106 Hoàng Quốc Việt',
            'TADA Sport CN1 - Thanh Đa',
            'TADA Sport CN2 - Bình Lợi',
            'TADA Sport CN3 - D2(Ung Văn Khiêm)',
          ],
        ),
      ) {
    on<LoadOrderListEvent>(_onLoadOrderList);
    on<SearchOrderListEvent>(_onSearchOrderList);
    on<ChangeChannelEvent>(_onChangeChannel);
    on<FetchBookingsEvent>(_onFetchBookings);
  }

  void _onLoadOrderList(
    LoadOrderListEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    emit(
      OrderListScreenLoading(
        selectedChannel: state.selectedChannel,
        availableChannels: _availableChannels,
      ),
    );

    emit(
      OrderListScreenLoaded(
        selectedChannel: state.selectedChannel,
        availableChannels: _availableChannels,
        items: const [],
      ),
    );
  }

  void _onSearchOrderList(
    SearchOrderListEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    if (state is OrderListScreenLoaded) {
      final currentState = state as OrderListScreenLoaded;
      final filteredItems =
          currentState.items
              .where(
                (item) =>
                    item['customerName']?.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();

      emit(
        OrderListScreenLoaded(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
          items: filteredItems,
        ),
      );
    }
  }

  void _onChangeChannel(
    ChangeChannelEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    emit(
      OrderListScreenLoading(
        selectedChannel: event.channelName,
        availableChannels: _availableChannels,
      ),
    );

    if (event.channelName == 'Pikachu Pickleball Xuân Hoà') {
      add(FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()));
    } else {
      emit(
        OrderListScreenLoaded(
          selectedChannel: event.channelName,
          availableChannels: _availableChannels,
          items: const [],
        ),
      );
    }
  }

  Future<void> _onFetchBookings(
    FetchBookingsEvent event,
    Emitter<OrderListScreenState> emit,
  ) async {
    try {
      log.log('Fetching bookings for channel: ${event.channelToken}');

      final response = await _bookingListRepository.getAllBookings(
        channelToken: event.channelToken,
        date: event.date,
      );

      // log.log('Raw API response: $response');

      if (response['data'] == null) {
        log.log('Response or data is null');
        emit(
          OrderListScreenLoaded(
            selectedChannel: state.selectedChannel,
            availableChannels: _availableChannels,
            items: const [],
          ),
        );
        return;
      }

      final getAllBooking = response['data']['getAllBooking'];
      if (getAllBooking == null) {
        log.log('getAllBooking is null');
        emit(
          OrderListScreenLoaded(
            selectedChannel: state.selectedChannel,
            availableChannels: _availableChannels,
            items: const [],
          ),
        );
        return;
      }

      final items = getAllBooking['items'] as List?;
      if (items == null || items.isEmpty) {
        log.log('No booking items found');
        emit(
          OrderListScreenLoaded(
            selectedChannel: state.selectedChannel,
            availableChannels: _availableChannels,
            items: const [],
          ),
        );
        return;
      }

      log.log('Found ${items.length} booking items');
      final transformedItems = <Map<String, String>>[];

      for (final item in items) {
        try {
          // log.log('Processing booking item: $item');

          // Extract customer info
          final customer = item['customer'] as Map? ?? {};
          final firstName = customer['firstName']?.toString() ?? '';
          final lastName = customer['lastName']?.toString() ?? '';
          final customerName =
              firstName.isNotEmpty && lastName.isNotEmpty
                  ? '$firstName $lastName'
                  : 'Không có tên';
          final phoneNumber = customer['phoneNumber']?.toString() ?? '';
          final emailAddress = customer['emailAddress']?.toString() ?? '';

          // Extract court info
          final court = item['court'] as Map? ?? {};
          final courtName = court['name']?.toString() ?? 'Không có tên sân';

          // Extract time info
          final startTime = item['start_time']?.toString() ?? '';
          final endTime = item['end_time']?.toString() ?? '';
          final timeRange =
              startTime.isNotEmpty && endTime.isNotEmpty
                  ? '$startTime - $endTime'
                  : 'Không có thời gian';

          // Extract total price
          final totalPrice = item['total_price']?.toString() ?? '';

          // Extract and map type
          final rawType = item['type']?.toString().toLowerCase() ?? '';
          final type = switch (rawType) {
            'periodic' => 'Định kì',
            'retail' => 'Loại lẻ1111',
            _ => 'Loại lẻ', // default case
          };
          log.log('Booking type: $rawType -> $type');

          final status = 'Đã đặt'; // Default status

          // Extract payment status
          final paymentStatus =
              item['paymentstatus']?['name']?.toString() ?? 'Chưa thanh toán';

          final transformedItem = {
            'customerName': customerName,
            'courtName': courtName,
            'time': timeRange,
            'type': type,
            'status': status,
            'paymentStatus': paymentStatus,
            'phoneNumber': phoneNumber,
            'emailAddress': emailAddress,
            'total_price': totalPrice,
          };

          // log.log('Transformed item: $transformedItem');
          transformedItems.add(transformedItem);
        } catch (e, stackTrace) {
          log.log('Error transforming item: $e');
          log.log('Stack trace: $stackTrace');
          continue;
        }
      }

      // log.log('Final transformed items count: ${transformedItems.length}');
      // log.log('Final transformed items: $transformedItems');

      emit(
        OrderListScreenLoaded(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
          items: transformedItems,
        ),
      );
    } catch (e, stackTrace) {
      log.log('Error fetching bookings: $e');
      log.log('Stack trace: $stackTrace');
      emit(
        OrderListScreenError(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
          message: e.toString(),
        ),
      );
    }
  }
}
