import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'dart:async';

part 'add_order_screen_event.dart';
part 'add_order_screen_state.dart';

class AddOrderBloc extends Bloc<AddOrderEvent, AddOrderState> {
  final ImagePicker _picker = ImagePicker();

  AddOrderBloc() : super(AddOrderInitial()) {
    on<AddOrderSubmitEvent>(_onSubmitOrder);
    on<AddOrderSelectTimeEvent>(_onSelectTime);
  }

  Future<void> _onSubmitOrder(
    AddOrderSubmitEvent event,
    Emitter<AddOrderState> emit,
  ) async {
    emit(AddOrderLoading());
    try {
      // Giả lập xử lý gửi đơn hàng
      await Future.delayed(const Duration(seconds: 2));
      emit(AddOrderSuccess());
    } catch (e) {
      emit(AddOrderFailure('Lỗi khi tạo đơn hàng: $e'));
    }
  }

  Future<void> _onSelectTime(
    AddOrderSelectTimeEvent event,
    Emitter<AddOrderState> emit,
  ) async {
    try {
      DateTime? dateTime = await showOmniDateTimePicker(
        context: event.context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        is24HourMode: true,
        isShowSeconds: false,
      );

      if (dateTime != null) {
        final String formattedTime =
            "Giờ: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}  "
            "Ngày: ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
        emit(AddOrderTimeSelected(formattedTime));
      }
    } catch (e) {
      emit(AddOrderFailure('Lỗi khi chọn thời gian: $e'));
    }
  }
}
