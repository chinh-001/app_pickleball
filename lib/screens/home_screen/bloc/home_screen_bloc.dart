import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'dart:developer' as log;

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final BookingRepository bookingRepository;
  final List<String> channels = [
    'Default channel',
    'Pikachu Pickleball Xuân Hoà',
    'Demo-channel',
    'Stamina 106 Hoàng Quốc Việt',
    'TADA Sport CN1 - Thanh Đa',
    'TADA Sport CN2 - Bình Lợi',
    'TADA Sport CN3 - D2(Ung Văn Khiêm)',
  ];

  // Mock data for courts
  final List<Map<String, dynamic>> mockCourts = [
    {
      'id': '1',
      'name': 'Sân 1',
      'status': 'available',
      'price': 100000,
      'star': 4.5,
    },
    {
      'id': '2',
      'name': 'Sân 2',
      'status': 'available',
      'price': 120000,
      'star': 4.8,
    },
    {
      'id': '3',
      'name': 'Sân 3',
      'status': 'booked',
      'price': 150000,
      'star': 5.0,
    },
  ];

  HomeScreenBloc({required this.bookingRepository})
    : super(HomeScreenInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<ChangeChannelEvent>(_onChangeChannel);
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
        availableChannels: channels,
      ),
    );

    final channelToken = bookingRepository.getChannelToken(event.channelName);
    add(FetchOrdersEvent(channelToken: channelToken));

    log.log('***** END HOME SCREEN BLOC: _onChangeChannel *****\n');
  }

  Future<void> _onFetchOrders(
    FetchOrdersEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      log.log('\n***** HOME SCREEN BLOC: _onFetchOrders *****');
      log.log(
        'Event: ${event.runtimeType} with channel token: ${event.channelToken}',
      );
      log.log('Current state: ${state.runtimeType}');

      emit(
        HomeScreenLoading(
          selectedChannel: state.selectedChannel,
          availableChannels: channels,
        ),
      );
      log.log('Emitted: HomeScreenLoading');

      log.log(
        'Calling bookingRepository.getBookingStats with token: ${event.channelToken}',
      );
      final stats = await bookingRepository.getBookingStats(
        channelToken: event.channelToken,
      );

      final totalOrders = stats['totalBookings'] ?? 0;
      final totalSales = stats['totalRevenue'] ?? 0.0;

      log.log(
        'Stats received: totalOrders=$totalOrders, totalSales=$totalSales',
      );

      // Use mock data instead of API call
      final courtItems = mockCourts;

      final newState = HomeScreenLoaded(
        items: courtItems,
        totalOrders: totalOrders,
        totalSales: totalSales,
        selectedChannel: state.selectedChannel,
        availableChannels: channels,
      );

      log.log(
        'Emitting: HomeScreenLoaded with totalOrders=$totalOrders, totalSales=$totalSales',
      );
      emit(newState);
      log.log('***** END HOME SCREEN BLOC *****\n');
    } catch (e) {
      log.log('Error in _onFetchOrders: $e');
      log.log('Emitting: HomeScreenError');
      emit(
        HomeScreenError(
          message: 'Failed to fetch orders',
          selectedChannel: state.selectedChannel,
          availableChannels: channels,
        ),
      );
      log.log('***** END HOME SCREEN BLOC WITH ERROR *****\n');
    }
  }
}
