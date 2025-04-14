import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'dart:developer' as log;

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final BookingRepository bookingRepository;

  HomeScreenBloc({required this.bookingRepository})
    : super(HomeScreenInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
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

      emit(HomeScreenLoading());
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

      final courtItems =
          [
            {
              'id': '1',
              'name': 'Sân 1',
              'status': 'có sẵn',
              'price': '200.000đ/giờ',
              'star': '3', // Thêm số sao
            },
            {
              'id': '2',
              'name': 'Sân 2',
              'status': 'available',
              'price': '200.000đ/giờ',
              'star': '5', // Thêm số sao
            },
            {
              'id': '3',
              'name': 'Sân 3',
              'status': 'available',
              'price': '200.000đ/giờ',
              'star': '4', // Thêm số sao
            },
          ].map((item) => Map<String, String>.from(item)).toList();

      final newState = HomeScreenLoaded(
        items: courtItems,
        totalOrders: totalOrders,
        totalSales: totalSales,
      );

      log.log(
        'Emitting: HomeScreenLoaded with totalOrders=$totalOrders, totalSales=$totalSales',
      );
      emit(newState);
      log.log('***** END HOME SCREEN BLOC *****\n');
    } catch (e) {
      log.log('Error in _onFetchOrders: $e');
      log.log('Emitting: HomeScreenError');
      emit(HomeScreenError('Failed to fetch orders'));
      log.log('***** END HOME SCREEN BLOC WITH ERROR *****\n');
    }
  }
}
