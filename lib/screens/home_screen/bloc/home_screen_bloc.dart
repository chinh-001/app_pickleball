import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/models/bookingStatus_model.dart';
import 'package:app_pickleball/models/bookingList_model.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final BookingRepository bookingRepository;
  final UserPermissionsRepository _permissionsRepository;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;

  // Khởi tạo biến lưu trữ dữ liệu gốc trước khi lọc
  BookingList? _originalBookingList;

  // Kênh dự phòng nếu không có kênh từ quyền hạn
  final List<String> fallbackChannels = ['Default channel', 'Demo-channel'];

  HomeScreenBloc({
    required this.bookingRepository,
    UserPermissionsRepository? permissionsRepository,
  }) : _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository(),
       super(HomeScreenInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<ChangeChannelEvent>(_onChangeChannel);
    on<InitializeHomeScreenEvent>(_onInitializeHomeScreen);
    on<SyncChannelEvent>(_onSyncChannel);
    on<FilterByDateRangeEvent>(_onFilterByDateRange);
    on<ClearDateFilterEvent>(_onClearDateFilter);

    // Register as a listener for channel changes
    _channelSyncService.addListener('home_screen_bloc', (newChannel) {
      log.log(
        'HomeScreenBloc received channel change notification: $newChannel',
      );
      // Only update if the channel is different from current selected channel
      if (state.selectedChannel != newChannel) {
        add(SyncChannelEvent(channelName: newChannel));
      }
    });

    // Thêm event để khởi tạo dữ liệu từ SharedPreferences
    add(InitializeHomeScreenEvent());
  }

  // Handle notification from channel sync service
  void _onSyncChannel(SyncChannelEvent event, Emitter<HomeScreenState> emit) {
    log.log('\n***** HOME SCREEN BLOC: _onSyncChannel *****');
    log.log('Syncing to channel: ${event.channelName}');

    // Ensure channelName is not empty
    final channelName =
        event.channelName.isNotEmpty ? event.channelName : 'Default channel';

    // Đảm bảo danh sách available channels không rỗng
    List<String> availableChannels = state.availableChannels;
    if (availableChannels.isEmpty) {
      availableChannels = ['Default channel'];
    }

    // Đảm bảo channel được chọn có trong danh sách
    if (!availableChannels.contains(channelName) &&
        !fallbackChannels.contains(channelName)) {
      availableChannels.add(channelName);
    }

    // Only update if the channel is different and is in available channels
    if (state.selectedChannel != channelName) {
      emit(
        HomeScreenLoading(
          selectedChannel: channelName,
          availableChannels: availableChannels,
        ),
      );

      // Lấy token từ UserPermissionsRepository
      _permissionsRepository.getChannelToken(channelName).then((token) {
        if (token.isEmpty) {
          // Use fallback token if needed
          final fallbackToken = bookingRepository.getChannelToken(channelName);
          add(FetchOrdersEvent(channelToken: fallbackToken));
        } else {
          add(FetchOrdersEvent(channelToken: token));
        }
      });
    }
  }

  @override
  Future<void> close() {
    // Unregister the listener when the bloc is closed
    _channelSyncService.removeListener('home_screen_bloc');
    return super.close();
  }

  // Xử lý lọc theo khoảng ngày
  void _onFilterByDateRange(
    FilterByDateRangeEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    log.log(
      'Lọc dữ liệu theo khoảng ngày: ${event.selectedDates.length} ngày được chọn',
    );

    if (state is HomeScreenLoaded) {
      final currentState = state as HomeScreenLoaded;

      // Lưu lại dữ liệu gốc nếu chưa có
      _originalBookingList ??= currentState.bookingList;

      // Lọc dữ liệu dựa trên khoảng ngày được chọn
      final filteredBookingList = _originalBookingList!.filterByDateRange(
        event.selectedDates,
      );

      // Emit state mới với dữ liệu đã lọc
      emit(
        HomeScreenLoaded(
          totalOrders: currentState.totalOrders,
          totalSales: currentState.totalSales,
          bookingList: filteredBookingList,
          selectedChannel: currentState.selectedChannel,
          availableChannels: currentState.availableChannels,
          bookingStatus: currentState.bookingStatus,
          selectedDates: event.selectedDates,
        ),
      );
    }
  }

  // Xử lý xóa bộ lọc ngày
  void _onClearDateFilter(
    ClearDateFilterEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    log.log('Xóa bộ lọc ngày');

    if (state is HomeScreenLoaded) {
      final currentState = state as HomeScreenLoaded;

      // Khôi phục lại dữ liệu gốc
      emit(
        HomeScreenLoaded(
          totalOrders: currentState.totalOrders,
          totalSales: currentState.totalSales,
          bookingList: _originalBookingList ?? currentState.bookingList,
          selectedChannel: currentState.selectedChannel,
          availableChannels: currentState.availableChannels,
          bookingStatus: currentState.bookingStatus,
          selectedDates: null,
        ),
      );

      // Đặt lại dữ liệu gốc
      _originalBookingList = null;
    }
  }

  // Xử lý event khởi tạo để lấy channels từ quyền hạn người dùng
  Future<void> _onInitializeHomeScreen(
    InitializeHomeScreenEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      log.log('Initializing HomeScreen...');
      emit(
        HomeScreenLoading(
          selectedChannel: 'Default channel',
          availableChannels: ['Default channel'],
        ),
      );

      // Lấy danh sách channel từ quyền hạn người dùng
      final userChannels = await _permissionsRepository.getAvailableChannels();

      if (userChannels.isEmpty) {
        log.log(
          'Không tìm thấy channel từ quyền hạn người dùng, sử dụng channels dự phòng',
        );

        String selectedChannel = fallbackChannels.first;

        // Check if there's a synchronized channel
        if (_channelSyncService.selectedChannel.isNotEmpty &&
            fallbackChannels.contains(_channelSyncService.selectedChannel)) {
          selectedChannel = _channelSyncService.selectedChannel;
          log.log('Using synchronized channel: $selectedChannel');
        } else {
          // Set the default channel to synchronize
          _channelSyncService.selectedChannel = selectedChannel;
        }

        emit(
          HomeScreenLoaded(
            bookingList: BookingList.empty(),
            totalOrders: 0,
            totalSales: 0,
            selectedChannel: selectedChannel,
            availableChannels: fallbackChannels,
            bookingStatus: BookingStatus(totalBookings: 0, totalRevenue: 0),
          ),
        );

        // Sử dụng channel đã chọn để fetch dữ liệu
        final channelToken = await bookingRepository.getChannelToken(
          selectedChannel,
        );
        add(FetchOrdersEvent(channelToken: channelToken));
        return;
      }

      log.log(
        'Đã tìm thấy ${userChannels.length} channel từ quyền hạn người dùng',
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

      // Đảm bảo selectedChannel không rỗng
      if (selectedChannel.isEmpty && userChannels.isNotEmpty) {
        selectedChannel = userChannels.first;
      } else if (selectedChannel.isEmpty) {
        selectedChannel = 'Default channel';
        // Đảm bảo availableChannels có Default channel
        if (!userChannels.contains(selectedChannel)) {
          userChannels.add(selectedChannel);
        }
      }

      // Lấy token của channel
      final channelToken = await _permissionsRepository.getChannelToken(
        selectedChannel,
      );

      // Emit state mới với channels từ quyền hạn người dùng
      emit(
        HomeScreenLoading(
          selectedChannel: selectedChannel,
          availableChannels: userChannels,
        ),
      );

      // Fetch dữ liệu với channel đã chọn
      add(FetchOrdersEvent(channelToken: channelToken));
    } catch (e) {
      log.log('Lỗi khi khởi tạo HomeScreen: $e');

      // Sử dụng giá trị mặc định an toàn
      final safeChannels =
          fallbackChannels.isEmpty ? ['Default channel'] : fallbackChannels;

      emit(
        HomeScreenError(
          message: 'Không thể khởi tạo màn hình chính',
          selectedChannel: safeChannels.first,
          availableChannels: safeChannels,
        ),
      );
    }
  }

  void _onChangeChannel(
    ChangeChannelEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    log.log('\n***** HOME SCREEN BLOC: _onChangeChannel *****');
    log.log('Changing channel to: ${event.channelName}');

    // Update the synchronized channel
    _channelSyncService.selectedChannel = event.channelName;

    emit(
      HomeScreenLoading(
        selectedChannel: event.channelName,
        availableChannels: state.availableChannels,
      ),
    );

    // Lấy token từ UserPermissionsRepository thay vì BookingRepository
    _permissionsRepository.getChannelToken(event.channelName).then((token) {
      if (token.isEmpty) {
        // Nếu không tìm thấy token từ UserPermissionsRepository, sử dụng token từ BookingRepository
        final fallbackToken = bookingRepository.getChannelToken(
          event.channelName,
        );
        add(FetchOrdersEvent(channelToken: fallbackToken));
      } else {
        add(FetchOrdersEvent(channelToken: token));
      }
    });
  }

  Future<void> _onFetchOrders(
    FetchOrdersEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      // log.log('\n***** HOME SCREEN BLOC: _onFetchOrders *****');
      // log.log(
      //   'Event: ${event.runtimeType} with channel token: ${event.channelToken}',
      // );
      // log.log('Current state: ${state.runtimeType}');

      emit(
        HomeScreenLoading(
          selectedChannel: state.selectedChannel,
          availableChannels: state.availableChannels,
        ),
      );
      // log.log('Emitted: HomeScreenLoading');

      // Lấy dữ liệu booking stats thông qua BookingStatus model
      // log.log(
      //   'Calling bookingRepository.getBookingStats with token: ${event.channelToken}',
      // );
      final bookingStatus = await bookingRepository.getBookingStats(
        channelToken: event.channelToken,
      );

      final totalOrders = bookingStatus.totalBookings;
      final totalSales = bookingStatus.totalRevenue;

      // log.log(
      //   'Stats received: totalOrders=$totalOrders, totalSales=$totalSales',
      // );

      // Lấy danh sách court thông qua BookingList model
      // log.log(
      //   'Calling bookingRepository.getCourtItems with token: ${event.channelToken}',
      // );
      BookingList bookingList;
      try {
        bookingList = await bookingRepository.getCourtItems(
          channelToken: event.channelToken,
        );

        if (bookingList.courts.isEmpty) {
          // Nếu không có dữ liệu, sử dụng danh sách rỗng
          // log.log('No courts available from API, using empty list');
          bookingList = BookingList.empty(channelToken: event.channelToken);
        }
      } catch (e) {
        log.log('Error fetching courts, using empty list: $e');
        bookingList = BookingList.empty(channelToken: event.channelToken);
      }

      final newState = HomeScreenLoaded(
        bookingList: bookingList,
        totalOrders: totalOrders,
        totalSales: totalSales,
        selectedChannel: state.selectedChannel,
        availableChannels: state.availableChannels,
        bookingStatus: bookingStatus,
      );

      // log.log(
      //   'Emitting: HomeScreenLoaded with totalOrders=$totalOrders, totalSales=$totalSales',
      // );
      emit(newState);
      // log.log('***** END HOME SCREEN BLOC *****\n');
    } catch (e) {
      log.log('Error in _onFetchOrders: $e');
      log.log('Emitting: HomeScreenError');
      emit(
        HomeScreenError(
          message: 'Failed to fetch orders',
          selectedChannel: state.selectedChannel,
          availableChannels: state.availableChannels,
        ),
      );
      log.log('***** END HOME SCREEN BLOC WITH ERROR *****\n');
    }
  }
}
