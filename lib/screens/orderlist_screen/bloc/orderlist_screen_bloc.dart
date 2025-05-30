import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/bookingList_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/models/bookingList_model.dart';
import 'package:intl/intl.dart';

part 'orderlist_screen_event.dart';
part 'orderlist_screen_state.dart';

class OrderListScreenBloc
    extends Bloc<OrderListScreenEvent, OrderListScreenState> {
  final BookingListRepository _bookingListRepository;
  final UserPermissionsRepository _permissionsRepository;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;

  // Kênh dự phòng nếu không có kênh từ quyền hạn
  final List<String> _fallbackChannels = ['Default channel', 'Demo-channel'];

  // Lưu trữ dữ liệu gốc cho tính năng lọc
  BookingOrderList? _originalBookingList;
  List<Map<String, String>>? _originalItems;

  OrderListScreenBloc({
    BookingListRepository? bookingListRepository,
    UserPermissionsRepository? permissionsRepository,
  }) : _bookingListRepository =
           bookingListRepository ?? BookingListRepository(),
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository(),
       super(const OrderListScreenInitial()) {
    on<LoadOrderListEvent>(_onLoadOrderList);
    on<SearchOrderListEvent>(_onSearchOrderList);
    on<ChangeChannelEvent>(_onChangeChannel);
    on<FetchBookingsEvent>(_onFetchBookings);
    on<InitializeOrderListScreenEvent>(_onInitializeOrderListScreen);
    on<SyncChannelEvent>(_onSyncChannel);
    on<FilterByDateRangeEvent>(_onFilterByDateRange);
    on<ClearDateFilterEvent>(_onClearDateFilter);

    // Register as a listener for channel changes
    _channelSyncService.addListener('orderlist_screen_bloc', (newChannel) {
      log.log(
        'OrderListScreenBloc received channel change notification: $newChannel',
      );
      // Only update if the channel is different from current selected channel
      if (state.selectedChannel != newChannel) {
        add(SyncChannelEvent(channelName: newChannel));
      }
    });

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
      emit(
        OrderListScreenLoading(
          selectedChannel: 'Default channel',
          availableChannels: ['Default channel'],
        ),
      );

      // Always force a fresh API call to get user permissions
      await _permissionsRepository.getUserPermissions();

      // Luôn truy xuất trực tiếp từ repository để có dữ liệu mới nhất
      // Lấy danh sách kênh từ quyền hạn người dùng
      final userChannels = await _permissionsRepository.getAvailableChannels();
      // log.log('Fetched user channels: $userChannels');

      if (userChannels.isEmpty) {
        log.log(
          'Không tìm thấy kênh từ quyền hạn người dùng, sử dụng kênh dự phòng',
        );

        // Determine which channel to use
        String selectedChannel = _fallbackChannels.first;

        // Check if there's a synchronized channel
        if (_channelSyncService.selectedChannel.isNotEmpty &&
            _fallbackChannels.contains(_channelSyncService.selectedChannel)) {
          selectedChannel = _channelSyncService.selectedChannel;
          log.log('Using synchronized channel: $selectedChannel');
        } else {
          // Set the default channel to synchronize
          _channelSyncService.selectedChannel = selectedChannel;
        }

        emit(
          OrderListScreenLoaded(
            selectedChannel: selectedChannel,
            availableChannels: _fallbackChannels,
            items: const [],
            bookingOrderList: null,
          ),
        );

        // Get data for the selected channel
        if (selectedChannel == 'Pikachu Pickleball Xuân Hoà') {
          add(
            FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()),
          );
        } else {
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

        return;
      }

      log.log(
        'Đã tìm thấy ${userChannels.length} kênh từ quyền hạn người dùng',
      );

      // Determine which channel to use (synced or first available)
      String selectedChannel;
      if (_channelSyncService.selectedChannel.isNotEmpty &&
          userChannels.contains(_channelSyncService.selectedChannel)) {
        selectedChannel = _channelSyncService.selectedChannel;
        log.log('Using synchronized channel: $selectedChannel');
      } else {
        selectedChannel = userChannels.first;
        // Set the default channel to synchronize
        _channelSyncService.selectedChannel = selectedChannel;
        log.log('Setting synchronized channel: $selectedChannel');
      }

      // Emit state mới với kênh từ quyền hạn người dùng
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
          selectedChannel: _fallbackChannels.first,
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
    // Đảm bảo channelName không rỗng
    final channelName =
        event.channelName.isNotEmpty ? event.channelName : 'Default channel';

    // Log the channel selection
    log.log(
      '\n===== ORDERLIST SCREEN: CHANNEL SELECTED: "${channelName}" =====',
    );

    // Đảm bảo availableChannels không rỗng
    List<String> availableChannels = List.from(state.availableChannels);
    if (availableChannels.isEmpty) {
      availableChannels = List.from(_fallbackChannels);
      if (availableChannels.isEmpty) {
        availableChannels = ['Default channel'];
      }
    }

    // Đảm bảo channelName có trong danh sách availableChannels
    if (!availableChannels.contains(channelName) &&
        !_fallbackChannels.contains(channelName)) {
      availableChannels.add(channelName);
    }

    // Update the synchronized channel
    _channelSyncService.selectedChannel = channelName;

    emit(
      OrderListScreenLoading(
        selectedChannel: channelName,
        availableChannels: availableChannels,
      ),
    );

    if (channelName == 'Pikachu Pickleball Xuân Hoà') {
      log.log(
        'Using special "pikachu" token for Pikachu Pickleball Xuân Hoà channel',
      );
      add(FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()));
    } else {
      // Lấy token từ UserPermissionsRepository
      _permissionsRepository.getChannelToken(channelName).then((token) {
        if (token.isNotEmpty) {
          log.log('Got channel token: "$token" for channel: "${channelName}"');
          add(FetchBookingsEvent(channelToken: token, date: DateTime.now()));
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

      // Đảm bảo danh sách availableChannels không rỗng
      List<String> availableChannels = List.from(state.availableChannels);
      if (availableChannels.isEmpty) {
        availableChannels = List.from(_fallbackChannels);
        if (availableChannels.isEmpty) {
          availableChannels = ['Default channel'];
        }
      }

      // Đảm bảo selectedChannel không rỗng
      String selectedChannel = state.selectedChannel;
      if (selectedChannel.isEmpty) {
        selectedChannel = availableChannels.first;
      }

      // Đảm bảo selectedChannel có trong availableChannels
      if (!availableChannels.contains(selectedChannel)) {
        availableChannels.add(selectedChannel);
      }

      emit(
        OrderListScreenLoading(
          selectedChannel: selectedChannel,
          availableChannels: availableChannels,
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
            selectedChannel: selectedChannel,
            availableChannels: availableChannels,
            items: const [],
            bookingOrderList: bookingOrderList,
          ),
        );
        return;
      }

      // log.log('Tìm thấy ${bookingOrderList.orders.length} đơn đặt sân');

      // Check if code and noteCustomer fields are present in the data
      if (bookingOrderList.orders.isNotEmpty) {
        // final firstOrder = bookingOrderList.orders.first;
        // log.log('First order code: "${firstOrder.code}"');
        // log.log('First order noteCustomer: "${firstOrder.noteCustomer}"');
      }

      // Chuyển đổi dữ liệu sang định dạng cũ để tương thích ngược
      final transformedItems = bookingOrderList.toSimpleMapList();

      emit(
        OrderListScreenLoaded(
          selectedChannel: selectedChannel,
          availableChannels: availableChannels,
          items: transformedItems,
          bookingOrderList: bookingOrderList,
        ),
      );
    } catch (e, stackTrace) {
      log.log('Error fetching bookings: $e');
      log.log('Stack trace: $stackTrace');

      // Đảm bảo danh sách availableChannels không rỗng khi có lỗi
      List<String> availableChannels = List.from(state.availableChannels);
      if (availableChannels.isEmpty) {
        availableChannels = List.from(_fallbackChannels);
        if (availableChannels.isEmpty) {
          availableChannels = ['Default channel'];
        }
      }

      // Đảm bảo selectedChannel không rỗng
      String selectedChannel = state.selectedChannel;
      if (selectedChannel.isEmpty) {
        selectedChannel = availableChannels.first;
      }

      emit(
        OrderListScreenError(
          message: 'Không thể tải danh sách đặt sân: $e',
          selectedChannel: selectedChannel,
          availableChannels: availableChannels,
        ),
      );
    }
  }

  // Handle notification from channel sync service
  void _onSyncChannel(
    SyncChannelEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    log.log('\n***** ORDERLIST SCREEN BLOC: _onSyncChannel *****');
    log.log('Syncing to channel: ${event.channelName}');

    // Đảm bảo channelName không rỗng
    final channelName =
        event.channelName.isNotEmpty ? event.channelName : 'Default channel';

    // Đảm bảo availableChannels không rỗng
    List<String> availableChannels = List.from(state.availableChannels);
    if (availableChannels.isEmpty) {
      availableChannels = List.from(_fallbackChannels);
      if (availableChannels.isEmpty) {
        availableChannels = ['Default channel'];
      }
    }

    // Đảm bảo channelName có trong danh sách availableChannels
    if (!availableChannels.contains(channelName) &&
        !_fallbackChannels.contains(channelName)) {
      availableChannels.add(channelName);
    }

    // Cập nhật chỉ khi kênh khác với kênh hiện tại
    if (state.selectedChannel != channelName) {
      emit(
        OrderListScreenLoading(
          selectedChannel: channelName,
          availableChannels: availableChannels,
        ),
      );

      if (channelName == 'Pikachu Pickleball Xuân Hoà') {
        log.log(
          'Using special "pikachu" token for Pikachu Pickleball Xuân Hoà channel',
        );
        add(FetchBookingsEvent(channelToken: 'pikachu', date: DateTime.now()));
      } else {
        // Lấy token từ UserPermissionsRepository
        _permissionsRepository.getChannelToken(channelName).then((token) {
          if (token.isNotEmpty) {
            log.log(
              'Got channel token: "$token" for channel: "${channelName}"',
            );
            add(FetchBookingsEvent(channelToken: token, date: DateTime.now()));
          }
        });
      }
    }
  }

  // Xử lý lọc theo khoảng ngày
  void _onFilterByDateRange(
    FilterByDateRangeEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    if (state is OrderListScreenLoaded) {
      final currentState = state as OrderListScreenLoaded;

      log.log('Đang lọc dữ liệu theo ${event.selectedDates.length} ngày');

      // Lưu dữ liệu gốc nếu chưa có
      if (_originalBookingList == null) {
        _originalBookingList = currentState.bookingOrderList;
        _originalItems = List.from(currentState.items);
      }

      if (_originalBookingList == null || _originalItems == null) {
        log.log('Không có dữ liệu gốc để lọc');
        return;
      }

      // Tạo bản sao của dữ liệu để lọc
      List<Map<String, String>> filteredItems = [];

      // Chuyển danh sách ngày thành chuỗi để so sánh
      final selectedDateStrings =
          event.selectedDates
              .map((date) => DateFormat('yyyy-MM-dd').format(date))
              .toList();

      log.log('Các ngày được chọn: $selectedDateStrings');

      // Lọc dữ liệu theo ngày
      for (var item in _originalItems!) {
        if (item.containsKey('booking_date')) {
          final bookingDate = item['booking_date'] ?? '';
          // Kiểm tra xem booking_date có thuộc về một trong những ngày được chọn không
          if (selectedDateStrings.any((date) => bookingDate.contains(date))) {
            filteredItems.add(item);
          }
        }
      }

      log.log(
        'Đã lọc ${filteredItems.length} mục từ ${_originalItems!.length} mục',
      );

      // Emit state mới với dữ liệu đã lọc
      emit(
        currentState.copyWith(
          items: filteredItems,
          selectedDates: event.selectedDates,
        ),
      );
    }
  }

  // Xử lý xóa bộ lọc
  void _onClearDateFilter(
    ClearDateFilterEvent event,
    Emitter<OrderListScreenState> emit,
  ) {
    if (state is OrderListScreenLoaded) {
      final currentState = state as OrderListScreenLoaded;

      log.log('Đang xóa bộ lọc ngày');

      // Khôi phục dữ liệu gốc
      if (_originalItems != null) {
        emit(currentState.copyWith(items: _originalItems, selectedDates: null));

        // Đặt lại dữ liệu gốc
        _originalBookingList = null;
        _originalItems = null;
      }
    }
  }

  @override
  Future<void> close() {
    // Unregister the listener when the bloc is closed
    _channelSyncService.removeListener('orderlist_screen_bloc');
    return super.close();
  }
}
