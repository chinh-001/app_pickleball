import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'package:app_pickleball/utils/date_format_utils.dart';
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
      final String originalStatusId = item['statusId'] ?? '';
      final String originalPaymentStatus = item['paymentStatus'] ?? '';
      final String selectedTime = item['time'] ?? '';

      // Khởi tạo danh sách các tùy chọn đã được dịch
      final List<String> typeOptions = [
        AppLocalizations.of(context).translate('booking_type_retail'),
        AppLocalizations.of(context).translate('booking_type_periodic'),
      ];

      final List<String> statusOptions = [
        AppLocalizations.of(context).translate('status_1'), // Mới
        AppLocalizations.of(context).translate('status_2'), // Đặt sân
        AppLocalizations.of(context).translate('status_3'), // Trùng giờ
        AppLocalizations.of(context).translate('status_4'), // Xác nhận
        AppLocalizations.of(context).translate('status_5'), // Check-in
        AppLocalizations.of(context).translate('status_6'), // Check-out
        AppLocalizations.of(context).translate('status_7'), // Admin hủy đặt
        AppLocalizations.of(context).translate('status_8'), // Khách hủy đặt
        AppLocalizations.of(context).translate('status_9'), // Hoàn thành
      ];

      final List<String> paymentStatusOptions = [
        AppLocalizations.of(
          context,
        ).translate('payment_status_1'), // Chưa thanh toán
        AppLocalizations.of(
          context,
        ).translate('payment_status_2'), // Đã thanh toán
        AppLocalizations.of(
          context,
        ).translate('payment_status_3'), // Hoàn thành
        AppLocalizations.of(context).translate('payment_status_4'), // Đặt cọc
        AppLocalizations.of(
          context,
        ).translate('payment_status_5'), // Đã hoàn trả
        AppLocalizations.of(context).translate('payment_status_6'), // Đã hủy
      ];

      // Dịch các giá trị cho UI
      String selectedType = originalType;
      String selectedStatus = originalStatus;
      String selectedPaymentStatus = originalPaymentStatus;

      // Ánh xạ giá trị gốc sang giá trị đã dịch dựa trên statusId
      if (originalStatusId.isNotEmpty) {
        // Nếu có statusId, sử dụng nó để lấy bản dịch
        selectedStatus = AppLocalizations.of(
          context,
        ).translate('status_$originalStatusId');
      }

      // Ánh xạ giá trị gốc sang giá trị đã dịch
      if (originalType == 'retail' || originalType.isEmpty) {
        selectedType = AppLocalizations.of(
          context,
        ).translate('booking_type_retail');
      } else if (originalType == 'periodic') {
        selectedType = AppLocalizations.of(
          context,
        ).translate('booking_type_periodic');
      }

      // Use paymentStatusId if available
      if (item['paymentStatusId']?.isNotEmpty == true) {
        final paymentStatusId = item['paymentStatusId']!;
        selectedPaymentStatus = AppLocalizations.of(
          context,
        ).translate('payment_status_$paymentStatusId');
      } else {
        // Fallback to name-based mapping
        if (originalPaymentStatus == 'Đã thanh toán') {
          selectedPaymentStatus = AppLocalizations.of(
            context,
          ).translate('payment_status_2');
        } else if (originalPaymentStatus == 'Chưa thanh toán') {
          selectedPaymentStatus = AppLocalizations.of(
            context,
          ).translate('payment_status_1');
        } else if (originalPaymentStatus == 'Đặt cọc') {
          selectedPaymentStatus = AppLocalizations.of(
            context,
          ).translate('payment_status_4');
        }
      }

      // Định dạng tổng tiền sử dụng localization
      final String rawTotalPrice = item['total_price'] ?? '';
      final String formattedTotalPrice = _formatTotalPrice(
        rawTotalPrice,
        context,
      );

      // Định dạng thời gian nếu cần
      final String formattedTime =
          selectedTime.isNotEmpty
              ? DateTimeFormatter.formatTimeString(context, selectedTime)
              : selectedTime;

      // Emit trạng thái đã tải dữ liệu
      emit(
        OrderDetailDataLoaded(
          selectedType: selectedType,
          selectedStatus: selectedStatus,
          selectedPaymentStatus: selectedPaymentStatus,
          selectedTime: formattedTime,
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
    final formattedPrice = _formatTotalPrice(event.price, event.context);
    emit(PriceFormattedState(formattedPrice));
  }

  String _formatTotalPrice(String price, BuildContext context) {
    if (price.isEmpty) return '';

    try {
      // Chuyển chuỗi thành số và định dạng sử dụng extension CurrencyFormat
      final priceNumber = int.tryParse(price.replaceAll(RegExp(r'[^\d]'), ''));
      if (priceNumber == null) return price;

      // Loại bỏ "VND" ở cuối vì đã có suffix trong TextField
      return priceNumber.toCurrency(context).replaceAll(' VND', '');
    } catch (e) {
      log.log('Error formatting price: $e');
      return price;
    }
  }

  void _onSelectTimeEvent(
    SelectTimeEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    // Lưu context vào biến local trước khi gọi async
    final context = event.context;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final formattedTime = selectedTime.format(context);
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
    if (event.type == 'retail') {
      translatedType = AppLocalizations.of(
        context,
      ).translate('booking_type_retail');
    } else if (event.type == 'periodic') {
      translatedType = AppLocalizations.of(
        context,
      ).translate('booking_type_periodic');
    }

    // Try to determine if status is an ID
    if (event.status.length <= 2 && int.tryParse(event.status) != null) {
      // If status is a numeric ID, use the ID-based translation
      translatedStatus = AppLocalizations.of(
        context,
      ).translate('status_${event.status}');
    }

    // Try to determine if payment status is an ID
    if (event.paymentStatus.length <= 2 &&
        int.tryParse(event.paymentStatus) != null) {
      // If payment status is a numeric ID, use the ID-based translation
      translatedPaymentStatus = AppLocalizations.of(
        context,
      ).translate('payment_status_${event.paymentStatus}');
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
      originalType = 'retail';
    } else if (event.type ==
        AppLocalizations.of(context).translate('periodicType')) {
      originalType = 'periodic';
    }

    // Ánh xạ ngược status dựa trên ID
    for (int i = 1; i <= 9; i++) {
      if (event.status == AppLocalizations.of(context).translate('status_$i')) {
        // Store the status ID instead of the name
        originalStatus = i.toString();
        break;
      }
    }

    // Ánh xạ ngược payment status dựa trên ID
    for (int i = 1; i <= 6; i++) {
      if (event.paymentStatus ==
          AppLocalizations.of(context).translate('payment_status_$i')) {
        // Store the payment status ID
        originalPaymentStatus = i.toString();
        break;
      }
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
