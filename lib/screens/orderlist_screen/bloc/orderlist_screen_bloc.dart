import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/bookingList_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/model/bookingList_model.dart';

part 'orderlist_screen_event.dart';
part 'orderlist_screen_state.dart';

class OrderListScreenBloc
    extends Bloc<OrderListScreenEvent, OrderListScreenState> {
  final BookingListRepository _bookingListRepository;
  final UserPermissionsRepository _permissionsRepository;

  // Kênh dự phòng nếu không có kênh từ quyền hạn
  final List<String> _fallbackChannels = ['Default channel', 'Demo-channel'];

  OrderListScreenBloc({
    BookingListRepository? bookingListRepository,
    UserPermissionsRepository? permissionsRepository,
  }) : _bookingListRepository =
           bookingListRepository ?? BookingListRepository(),
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository(),
       super(
         const OrderListScreenInitial(
           selectedChannel: '',
           availableChannels: [],
         ),
       ) {
    on<LoadOrderListEvent>(_onLoadOrderList);
    on<SearchOrderListEvent>(_onSearchOrderList);
    on<ChangeChannelEvent>(_onChangeChannel);
    on<FetchBookingsEvent>(_onFetchBookings);
    on<InitializeOrderListScreenEvent>(_onInitializeOrderListScreen);

    // Khởi tạo danh sách kênh từ quyền hạn người dùng
    add(InitializeOrderListScreenEvent());
  }

  // Phương thức khởi tạo để lấy danh sách kênh từ quyền hạn người dùng
  Future<void> _onInitializeOrderListScreen(
    InitializeOrderListScreenEvent event,
    Emitter<OrderListScreenState> emit,
  ) async {
    try {
      log.log('Initializing OrderListScreen bloc...');
      emit(OrderListScreenLoading(selectedChannel: '', availableChannels: []));

      // Always force a fresh API call to get user permissions
      await _permissionsRepository.getUserPermissions();

      // Luôn truy xuất trực tiếp từ repository để có dữ liệu mới nhất
      // Lấy danh sách kênh từ quyền hạn người dùng
      final userChannels = await _permissionsRepository.getAvailableChannels();
      log.log('Fetched user channels: $userChannels');

      if (userChannels.isEmpty) {
        log.log(
          'Không tìm thấy kênh từ quyền hạn người dùng, sử dụng kênh dự phòng',
        );
        emit(
          OrderListScreenLoaded(
            selectedChannel: _fallbackChannels.first,
            availableChannels: _fallbackChannels,
            items: const [],
            bookingOrderList: null,
          ),
        );
        return;
      }

      log.log(
        'Đã tìm thấy ${userChannels.length} kênh từ quyền hạn người dùng',
      );

      // Emit state mới với kênh từ quyền hạn người dùng
      final selectedChannel = userChannels.first;
      emit(
        OrderListScreenLoaded(
          selectedChannel: selectedChannel,
          availableChannels: userChannels,
          items: const [],
          bookingOrderList: null,
        ),
      );

      // Nếu có kênh Pikachu, gọi API lấy danh sách booking
      if (selectedChannel == 'Pikachu Pickleball Xuân Hoà') {
        add(FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()));
      } else {
        // Lấy token từ UserPermissionsRepository
        final channelToken = await _permissionsRepository.getChannelToken(
          selectedChannel,
        );
        if (channelToken.isNotEmpty) {
          add(
            FetchBookingsEvent(
              channelToken: channelToken,
              date: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      log.log('Lỗi khi khởi tạo OrderListScreen: $e');
      emit(
        OrderListScreenError(
          message: 'Không thể khởi tạo màn hình danh sách đặt sân',
          selectedChannel: '',
          availableChannels: _fallbackChannels,
        ),
      );
    }
  }

  void _onLoadOrderList(
    LoadOrderListEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    // Không càn emit state loading và loaded ở đây nữa
    // vì đã được xử lý trong InitializeOrderListScreenEvent
    // Chỉ cần gọi InitializeOrderListScreenEvent
    add(InitializeOrderListScreenEvent());
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
          availableChannels: state.availableChannels,
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
    // Log the channel selection
    log.log('\n===== CHANNEL SELECTED: "${event.channelName}" =====');

    emit(
      OrderListScreenLoading(
        selectedChannel: event.channelName,
        availableChannels: state.availableChannels,
      ),
    );

    if (event.channelName == 'Pikachu Pickleball Xuân Hoà') {
      log.log(
        'Using special "pikachu" token for Pikachu Pickleball Xuân Hoà channel',
      );
      add(FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()));
    } else {
      // Lấy token từ UserPermissionsRepository
      _permissionsRepository.getChannelToken(event.channelName).then((token) {
        if (token.isNotEmpty) {
          log.log(
            'Got channel token: "$token" for channel: "${event.channelName}"',
          );
          add(FetchBookingsEvent(channelToken: token, date: DateTime.now()));
        } else {
          log.log(
            'No channel token found for channel: "${event.channelName}", returning empty result',
          );
          // Nếu không tìm thấy token, emit state loaded với danh sách trống
          emit(
            OrderListScreenLoaded(
              selectedChannel: event.channelName,
              availableChannels: state.availableChannels,
              items: const [],
              bookingOrderList: null,
            ),
          );
        }
      });
    }
  }

  Future<void> _onFetchBookings(
    FetchBookingsEvent event,
    Emitter<OrderListScreenState> emit,
  ) async {
    try {
      log.log(
        'Fetching bookings with token: "${event.channelToken}" for date: ${event.date.toIso8601String()}',
      );

      emit(
        OrderListScreenLoading(
          selectedChannel: state.selectedChannel,
          availableChannels: state.availableChannels,
        ),
      );

      // First get the raw API response to log the complete data
      await _bookingListRepository.getAllBookingsRaw(
        channelToken: event.channelToken,
        date: event.date,
      );

      // Then use the model to get the structured data
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
            availableChannels: state.availableChannels,
            items: const [],
            bookingOrderList: bookingOrderList,
          ),
        );
        return;
      }

      log.log('Tìm thấy ${bookingOrderList.orders.length} đơn đặt sân');

      // Check if code and noteCustomer fields are present in the data
      if (bookingOrderList.orders.isNotEmpty) {
        final firstOrder = bookingOrderList.orders.first;
        log.log('First order code: "${firstOrder.code}"');
        log.log('First order noteCustomer: "${firstOrder.noteCustomer}"');
      }

      // Chuyển đổi dữ liệu sang định dạng cũ để tương thích ngược
      final transformedItems = bookingOrderList.toSimpleMapList();

      emit(
        OrderListScreenLoaded(
          selectedChannel: state.selectedChannel,
          availableChannels: state.availableChannels,
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
          availableChannels: state.availableChannels,
        ),
      );
    }
  }
}
