import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/models/bookingStatus_model.dart';
import 'package:app_pickleball/models/bookingList_model.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final BookingRepository bookingRepository;
  final UserPermissionsRepository _permissionsRepository;

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

    // Thêm event để khởi tạo dữ liệu từ SharedPreferences
    add(InitializeHomeScreenEvent());
  }

  // Xử lý event khởi tạo để lấy channels từ quyền hạn người dùng
  Future<void> _onInitializeHomeScreen(
    InitializeHomeScreenEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      log.log('Initializing HomeScreen...');
      emit(HomeScreenLoading(selectedChannel: '', availableChannels: []));

      // Lấy danh sách channel từ quyền hạn người dùng
      final userChannels = await _permissionsRepository.getAvailableChannels();

      if (userChannels.isEmpty) {
        log.log(
          'Không tìm thấy channel từ quyền hạn người dùng, sử dụng channels dự phòng',
        );
        emit(
          HomeScreenLoaded(
            bookingList: BookingList.empty(),
            totalOrders: 0,
            totalSales: 0,
            selectedChannel: fallbackChannels.first,
            availableChannels: fallbackChannels,
            bookingStatus: BookingStatus(totalBookings: 0, totalRevenue: 0),
          ),
        );

        // Sử dụng channel đầu tiên để fetch dữ liệu
        if (fallbackChannels.isNotEmpty) {
          final channelToken = await bookingRepository.getChannelToken(
            fallbackChannels.first,
          );
          add(FetchOrdersEvent(channelToken: channelToken));
        }
        return;
      }

      log.log(
        'Đã tìm thấy ${userChannels.length} channel từ quyền hạn người dùng',
      );

      // Lấy token của channel đầu tiên
      final selectedChannel = userChannels.first;
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

      // Fetch dữ liệu với channel đầu tiên
      add(FetchOrdersEvent(channelToken: channelToken));
    } catch (e) {
      log.log('Lỗi khi khởi tạo HomeScreen: $e');
      emit(
        HomeScreenError(
          message: 'Không thể khởi tạo màn hình chính',
          selectedChannel: '',
          availableChannels: fallbackChannels,
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
