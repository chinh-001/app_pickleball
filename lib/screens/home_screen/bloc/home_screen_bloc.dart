import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';

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
      emit(HomeScreenLoading());

      print('Fetching orders with channel token: ${event.channelToken}');

      final stats = await bookingRepository.getBookingStats(
        channelToken: event.channelToken,
      );
      final totalOrders = stats['totalBookings'] ?? 0;
      final totalSales = stats['totalRevenue'] ?? 0.0;

      print('Total Orders: $totalOrders');
      print('Total Sales: $totalSales');
      print('Channel token used: ${event.channelToken}');

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

      emit(
        HomeScreenLoaded(
          items: courtItems,
          totalOrders: totalOrders,
          totalSales: totalSales,
        ),
      );
    } catch (e) {
      print('Error fetching orders: $e');
      emit(HomeScreenError('Failed to fetch orders'));
    }
  }
}
