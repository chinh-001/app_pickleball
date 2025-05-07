import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'dart:io';
import 'dart:developer' as log;
part 'order_detail_screen_event.dart';
part 'order_detail_screen_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final ImagePicker _picker = ImagePicker();

  OrderDetailBloc() : super(OrderDetailInitial()) {
    on<InitializeOrderDetailEvent>(_onInitializeOrderDetail);
    on<UpdateTypeEvent>(_onUpdateType);
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<UpdatePaymentStatusEvent>(_onUpdatePaymentStatus);
    on<SelectTimeEvent>(_onSelectTimeEvent);
    on<FormatPriceEvent>(_onFormatPrice);
    on<TranslateValuesForUIEvent>(_onTranslateValuesForUI);
    on<TranslateValuesForSubmitEvent>(_onTranslateValuesForSubmit);
    on<SubmitOrderDetailEvent>(_onSubmitOrderDetail);
    on<PickImageEvent>(_onPickImage);
  }

  void _onInitializeOrderDetail(
    InitializeOrderDetailEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    try {
      emit(OrderDetailLoading());

      final Map<String, String> item = event.orderData;
      final BuildContext context = event.context;

      // Lấy thông tin từ dữ liệu đầu vào
      final String originalType = item['type'] ?? '';
      final String originalStatus = item['status'] ?? '';
      final String originalPaymentStatus = item['paymentStatus'] ?? '';
      final String selectedTime = item['time'] ?? '';

      // Khởi tạo danh sách các tùy chọn đã được dịch
      final List<String> typeOptions = [
        AppLocalizations.of(context).translate('singleType'),
        AppLocalizations.of(context).translate('periodicType'),
      ];

      final List<String> statusOptions = [
        AppLocalizations.of(context).translate('new'),
        AppLocalizations.of(context).translate('booked'),
        AppLocalizations.of(context).translate('customer_canceled'),
        AppLocalizations.of(context).translate('completed'),
      ];

      final List<String> paymentStatusOptions = [
        AppLocalizations.of(context).translate('paid'),
        AppLocalizations.of(context).translate('unpaid'),
        AppLocalizations.of(context).translate('deposit'),
      ];

      // Dịch các giá trị cho UI
      String selectedType = originalType;
      String selectedStatus = originalStatus;
      String selectedPaymentStatus = originalPaymentStatus;

      // Ánh xạ giá trị gốc sang giá trị đã dịch
      if (originalType == 'Loại lẻ' || originalType.isEmpty) {
        selectedType = AppLocalizations.of(context).translate('singleType');
      } else if (originalType == 'Định kì') {
        selectedType = AppLocalizations.of(context).translate('periodicType');
      }

      if (originalStatus == 'Mới' || originalStatus.isEmpty) {
        selectedStatus = AppLocalizations.of(context).translate('new');
      } else if (originalStatus == 'Đặt sân') {
        selectedStatus = AppLocalizations.of(context).translate('booked');
      } else if (originalStatus == 'Khách hủy đặt') {
        selectedStatus = AppLocalizations.of(
          context,
        ).translate('customer_canceled');
      } else if (originalStatus == 'Hoàn thành') {
        selectedStatus = AppLocalizations.of(context).translate('completed');
      }

      if (originalPaymentStatus == 'Đã thanh toán' ||
          originalPaymentStatus.isEmpty) {
        selectedPaymentStatus = AppLocalizations.of(context).translate('paid');
      } else if (originalPaymentStatus == 'Chưa thanh toán') {
        selectedPaymentStatus = AppLocalizations.of(
          context,
        ).translate('unpaid');
      } else if (originalPaymentStatus == 'Đặt cọc') {
        selectedPaymentStatus = AppLocalizations.of(
          context,
        ).translate('deposit');
      }

      // Định dạng tổng tiền
      final String rawTotalPrice = item['total_price'] ?? '';
      final String formattedTotalPrice = _formatTotalPrice(rawTotalPrice);

      // Emit trạng thái đã tải dữ liệu
      emit(
        OrderDetailDataLoaded(
          selectedType: selectedType,
          selectedStatus: selectedStatus,
          selectedPaymentStatus: selectedPaymentStatus,
          selectedTime: selectedTime,
          typeOptions: typeOptions,
          statusOptions: statusOptions,
          paymentStatusOptions: paymentStatusOptions,
          formattedTotalPrice: formattedTotalPrice,
        ),
      );
    } catch (e) {
      emit(OrderDetailFailure('Lỗi khi khởi tạo dữ liệu: $e'));
    }
  }

  void _onUpdateType(UpdateTypeEvent event, Emitter<OrderDetailState> emit) {
    if (state is OrderDetailDataLoaded) {
      final currentState = state as OrderDetailDataLoaded;
      emit(currentState.copyWith(selectedType: event.type));
    }
  }

  void _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    if (state is OrderDetailDataLoaded) {
      final currentState = state as OrderDetailDataLoaded;
      emit(currentState.copyWith(selectedStatus: event.status));
    }
  }

  void _onUpdatePaymentStatus(
    UpdatePaymentStatusEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    if (state is OrderDetailDataLoaded) {
      final currentState = state as OrderDetailDataLoaded;
      emit(currentState.copyWith(selectedPaymentStatus: event.paymentStatus));
    }
  }

  void _onFormatPrice(FormatPriceEvent event, Emitter<OrderDetailState> emit) {
    final formattedPrice = _formatTotalPrice(event.price);
    emit(PriceFormattedState(formattedPrice));
  }

  String _formatTotalPrice(String price) {
    if (price.isEmpty) return '';

    try {
      // Chuyển chuỗi thành số và định dạng
      final priceNumber = int.tryParse(price.replaceAll(RegExp(r'[^\d]'), ''));
      if (priceNumber == null) return price;

      return priceNumber.toCommaSeparated();
    } catch (e) {
      log.log('Error formatting price: $e');
      return price;
    }
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
      if (state is OrderDetailDataLoaded) {
        final currentState = state as OrderDetailDataLoaded;
        emit(currentState.copyWith(selectedTime: formattedTime));
      }
      emit(TimeSelectedState(formattedTime));
    }
  }

  void _onTranslateValuesForUI(
    TranslateValuesForUIEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    final context = event.context;
    String translatedType = event.type;
    String translatedStatus = event.status;
    String translatedPaymentStatus = event.paymentStatus;

    // Ánh xạ type
    if (event.type == 'Loại lẻ') {
      translatedType = AppLocalizations.of(context).translate('singleType');
    } else if (event.type == 'Định kì') {
      translatedType = AppLocalizations.of(context).translate('periodicType');
    }

    // Ánh xạ status
    if (event.status == 'Mới') {
      translatedStatus = AppLocalizations.of(context).translate('new');
    } else if (event.status == 'Đặt sân') {
      translatedStatus = AppLocalizations.of(context).translate('booked');
    } else if (event.status == 'Khách hủy đặt') {
      translatedStatus = AppLocalizations.of(
        context,
      ).translate('customer_canceled');
    } else if (event.status == 'Hoàn thành') {
      translatedStatus = AppLocalizations.of(context).translate('completed');
    }

    // Ánh xạ payment status
    if (event.paymentStatus == 'Đã thanh toán') {
      translatedPaymentStatus = AppLocalizations.of(context).translate('paid');
    } else if (event.paymentStatus == 'Chưa thanh toán') {
      translatedPaymentStatus = AppLocalizations.of(
        context,
      ).translate('unpaid');
    } else if (event.paymentStatus == 'Đặt cọc') {
      translatedPaymentStatus = AppLocalizations.of(
        context,
      ).translate('deposit');
    }

    emit(
      UIValuesTranslatedState(
        type: translatedType,
        status: translatedStatus,
        paymentStatus: translatedPaymentStatus,
      ),
    );
  }

  void _onTranslateValuesForSubmit(
    TranslateValuesForSubmitEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    final context = event.context;
    String originalType = event.type;
    String originalStatus = event.status;
    String originalPaymentStatus = event.paymentStatus;

    // Ánh xạ ngược type
    if (event.type == AppLocalizations.of(context).translate('singleType')) {
      originalType = 'Loại lẻ';
    } else if (event.type ==
        AppLocalizations.of(context).translate('periodicType')) {
      originalType = 'Định kì';
    }

    // Ánh xạ ngược status
    if (event.status == AppLocalizations.of(context).translate('new')) {
      originalStatus = 'Mới';
    } else if (event.status ==
        AppLocalizations.of(context).translate('booked')) {
      originalStatus = 'Đặt sân';
    } else if (event.status ==
        AppLocalizations.of(context).translate('customer_canceled')) {
      originalStatus = 'Khách hủy đặt';
    } else if (event.status ==
        AppLocalizations.of(context).translate('completed')) {
      originalStatus = 'Hoàn thành';
    }

    // Ánh xạ ngược payment status
    if (event.paymentStatus == AppLocalizations.of(context).translate('paid')) {
      originalPaymentStatus = 'Đã thanh toán';
    } else if (event.paymentStatus ==
        AppLocalizations.of(context).translate('unpaid')) {
      originalPaymentStatus = 'Chưa thanh toán';
    } else if (event.paymentStatus ==
        AppLocalizations.of(context).translate('deposit')) {
      originalPaymentStatus = 'Đặt cọc';
    }

    // Truyền timeToSubmit vào state
    emit(
      SubmitValuesTranslatedState(
        type: originalType,
        status: originalStatus,
        paymentStatus: originalPaymentStatus,
        timeToSubmit: event.timeToSubmit,
      ),
    );
  }

  void _onSubmitOrderDetail(
    SubmitOrderDetailEvent event,
    Emitter<OrderDetailState> emit,
  ) {
    // TODO: Implement submit logic
    log.log(
      'Submitting order details: ${event.customerName}, ${event.courtName}, ${event.time}, ${event.status}, ${event.paymentStatus}, ${event.note}',
    );

    // Sau khi gửi dữ liệu thành công, emit trạng thái thành công
    emit(OrderDetailSuccess());
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
      emit(OrderDetailFailure('Lỗi khi chọn ảnh: $e'));
    }
  }
}
