import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'complete_booking_screen_event.dart';
part 'complete_booking_screen_state.dart';

class CompleteBookingScreenBloc
    extends Bloc<CompleteBookingScreenEvent, CompleteBookingScreenState> {
  CompleteBookingScreenBloc() : super(CompleteBookingScreenInitial()) {
    on<LoadCompleteBookingData>(_onLoadCompleteBookingData);
  }

  void _onLoadCompleteBookingData(
    LoadCompleteBookingData event,
    Emitter<CompleteBookingScreenState> emit,
  ) {
    emit(
      CompleteBookingScreenLoaded(
        customerName: event.customerName,
        customerEmail: event.customerEmail,
        customerPhone: event.customerPhone,
        bookingCode: event.bookingCode,
        bookingDetails: event.bookingDetails,
        price: event.price,
      ),
    );
  }
}
