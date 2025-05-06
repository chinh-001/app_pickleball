part of 'order_detail_screen_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailDataLoaded extends OrderDetailState {
  final String selectedType;
  final String selectedStatus;
  final String selectedPaymentStatus;
  final String selectedTime;
  final List<String> typeOptions;
  final List<String> statusOptions;
  final List<String> paymentStatusOptions;
  final String formattedTotalPrice;

  const OrderDetailDataLoaded({
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedPaymentStatus,
    required this.selectedTime,
    required this.typeOptions,
    required this.statusOptions,
    required this.paymentStatusOptions,
    required this.formattedTotalPrice,
  });

  @override
  List<Object?> get props => [
    selectedType,
    selectedStatus,
    selectedPaymentStatus,
    selectedTime,
    typeOptions,
    statusOptions,
    paymentStatusOptions,
    formattedTotalPrice,
  ];

  OrderDetailDataLoaded copyWith({
    String? selectedType,
    String? selectedStatus,
    String? selectedPaymentStatus,
    String? selectedTime,
    List<String>? typeOptions,
    List<String>? statusOptions,
    List<String>? paymentStatusOptions,
    String? formattedTotalPrice,
  }) {
    return OrderDetailDataLoaded(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPaymentStatus:
          selectedPaymentStatus ?? this.selectedPaymentStatus,
      selectedTime: selectedTime ?? this.selectedTime,
      typeOptions: typeOptions ?? this.typeOptions,
      statusOptions: statusOptions ?? this.statusOptions,
      paymentStatusOptions: paymentStatusOptions ?? this.paymentStatusOptions,
      formattedTotalPrice: formattedTotalPrice ?? this.formattedTotalPrice,
    );
  }
}

class TypeUpdatedState extends OrderDetailState {
  final String type;

  const TypeUpdatedState(this.type);

  @override
  List<Object?> get props => [type];
}

class StatusUpdatedState extends OrderDetailState {
  final String status;

  const StatusUpdatedState(this.status);

  @override
  List<Object?> get props => [status];
}

class PaymentStatusUpdatedState extends OrderDetailState {
  final String paymentStatus;

  const PaymentStatusUpdatedState(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class TimeSelectedState extends OrderDetailState {
  final String time;

  const TimeSelectedState(this.time);

  @override
  List<Object?> get props => [time];
}

class PriceFormattedState extends OrderDetailState {
  final String formattedPrice;

  const PriceFormattedState(this.formattedPrice);

  @override
  List<Object?> get props => [formattedPrice];
}

class ImagePickedState extends OrderDetailState {
  final File image;

  const ImagePickedState(this.image);

  @override
  List<Object?> get props => [image];
}

class UIValuesTranslatedState extends OrderDetailState {
  final String type;
  final String status;
  final String paymentStatus;

  const UIValuesTranslatedState({
    required this.type,
    required this.status,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [type, status, paymentStatus];
}

class SubmitValuesTranslatedState extends OrderDetailState {
  final String type;
  final String status;
  final String paymentStatus;
  final String? timeToSubmit;

  const SubmitValuesTranslatedState({
    required this.type,
    required this.status,
    required this.paymentStatus,
    this.timeToSubmit,
  });

  @override
  List<Object?> get props => [type, status, paymentStatus, timeToSubmit];
}

class OrderDetailSuccess extends OrderDetailState {}

class OrderDetailFailure extends OrderDetailState {
  final String error;

  const OrderDetailFailure(this.error);

  @override
  List<Object?> get props => [error];
}
