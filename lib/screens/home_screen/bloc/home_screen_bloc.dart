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

      final stats = await bookingRepository.getBookingStats();
      final totalOrders = stats['totalBookings'] ?? 0;
      final totalSales = stats['totalRevenue'] ?? 0.0;

      print('Total Orders: $totalOrders');
      print('Total Sales: $totalSales');

      final courtItems =
          [
            {
              'id': '1',
              'name': 'Sân 1',
              'status': 'available',
              'price': '200.000đ/giờ',
            },
            {
              'id': '2',
              'name': 'Sân 2',
              'status': 'available',
              'price': '200.000đ/giờ',
            },
            {
              'id': '3',
              'name': 'Sân 3',
              'status': 'available',
              'price': '200.000đ/giờ',
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
