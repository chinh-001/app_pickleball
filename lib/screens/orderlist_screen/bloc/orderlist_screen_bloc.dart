import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/bookingList_repository.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/model/bookingList_model.dart';

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
        bookingOrderList: null,
      ),
    );
  }

  void _onSearchOrderList(
    SearchOrderListEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    if (state is OrderListScreenLoaded) {
      final currentState = state as OrderListScreenLoaded;

      // Lọc dữ liệu dựa trên tên khách hàng
      List<Map<String, String>> filteredItems;

      if (currentState.bookingOrderList != null) {
        // Sử dụng BookingOrderList để lọc nếu có
        filteredItems =
            currentState.bookingOrderList!.orders
                .where(
                  (order) => order.customerName.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ),
                )
                .map((order) => order.toJson())
                .toList();
      } else {
        // Sử dụng danh sách items nếu không có BookingOrderList
        filteredItems =
            currentState.items
                .where(
                  (item) =>
                      item['customerName']?.toLowerCase().contains(
                        event.query.toLowerCase(),
                      ) ??
                      false,
                )
                .toList();
      }

      emit(
        OrderListScreenLoaded(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
          items: filteredItems,
          bookingOrderList: currentState.bookingOrderList,
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
          bookingOrderList: null,
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

      emit(
        OrderListScreenLoading(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
        ),
      );

      // Sử dụng model để lấy dữ liệu
      final bookingOrderList = await _bookingListRepository.getAllBookings(
        channelToken: event.channelToken,
        date: event.date,
      );

      // Kiểm tra kết quả
      if (bookingOrderList.orders.isEmpty) {
        log.log('Không có đơn đặt sân nào');
        emit(
          OrderListScreenLoaded(
            selectedChannel: state.selectedChannel,
            availableChannels: _availableChannels,
            items: const [],
            bookingOrderList: bookingOrderList,
          ),
        );
        return;
      }

      log.log('Tìm thấy ${bookingOrderList.orders.length} đơn đặt sân');

      // Chuyển đổi dữ liệu sang định dạng cũ để tương thích ngược
      final transformedItems = bookingOrderList.toSimpleMapList();

      emit(
        OrderListScreenLoaded(
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
          items: transformedItems,
          bookingOrderList: bookingOrderList,
        ),
      );
    } catch (e, stackTrace) {
      log.log('Error fetching bookings: $e');
      log.log('Stack trace: $stackTrace');

      emit(
        OrderListScreenError(
          message: 'Không thể tải danh sách đặt sân: $e',
          selectedChannel: state.selectedChannel,
          availableChannels: _availableChannels,
        ),
      );
    }
  }
}
