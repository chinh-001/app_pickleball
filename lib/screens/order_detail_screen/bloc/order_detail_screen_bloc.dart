import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer' as log;
part 'order_detail_screen_event.dart';
part 'order_detail_screen_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final ImagePicker _picker = ImagePicker();

  OrderDetailBloc() : super(OrderDetailInitial()) {
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<UpdatePaymentStatusEvent>(_onUpdatePaymentStatus);
    on<SelectTimeEvent>(_onSelectTimeEvent);
    on<SubmitOrderDetailEvent>(_onSubmitOrderDetail);
    on<PickImageEvent>(_onPickImage);
  }

  void _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    emit(StatusUpdatedState(event.status));
  }

  void _onUpdatePaymentStatus(
    UpdatePaymentStatusEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    emit(PaymentStatusUpdatedState(event.paymentStatus));
  }

  void _onSelectTimeEvent(
    SelectTimeEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: event.context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final formattedTime = selectedTime.format(event.context);
      emit(TimeSelectedState(formattedTime));
    }
  }

  void _onSubmitOrderDetail(
    SubmitOrderDetailEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    // TODO: Implement submit logic
    log.log(
      'Submitting order details: ${event.customerName}, ${event.courtName}, ${event.time}, ${event.status}, ${event.paymentStatus}, ${event.note}',
    );
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        emit(ImagePickedState(File(pickedFile.path)));
      }
    } catch (e) {
      log.log('Lỗi khi chọn ảnh: $e');
    }
  }
}
