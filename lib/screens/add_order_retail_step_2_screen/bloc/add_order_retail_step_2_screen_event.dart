part of 'add_order_retail_step_2_screen_bloc.dart';

abstract class AddOrderRetailStep2ScreenEvent extends Equatable {
  const AddOrderRetailStep2ScreenEvent();

  @override
  List<Object?> get props => [];
}

class SalutationChanged extends AddOrderRetailStep2ScreenEvent {
  final String? salutation;

  const SalutationChanged(this.salutation);

  @override
  List<Object?> get props => [salutation];
}

class PaymentMethodChanged extends AddOrderRetailStep2ScreenEvent {
  final String paymentMethod;

  const PaymentMethodChanged(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class PaymentStatusChanged extends AddOrderRetailStep2ScreenEvent {
  final String paymentStatus;

  const PaymentStatusChanged(this.paymentStatus);

  @override
  List<Object> get props => [paymentStatus];
}

class OrderStatusChanged extends AddOrderRetailStep2ScreenEvent {
  final String orderStatus;

  const OrderStatusChanged(this.orderStatus);

  @override
  List<Object> get props => [orderStatus];
}

class LastNameChanged extends AddOrderRetailStep2ScreenEvent {
  final String lastName;

  const LastNameChanged(this.lastName);

  @override
  List<Object> get props => [lastName];
}

class FirstNameChanged extends AddOrderRetailStep2ScreenEvent {
  final String firstName;

  const FirstNameChanged(this.firstName);

  @override
  List<Object> get props => [firstName];
}

class EmailChanged extends AddOrderRetailStep2ScreenEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class NotesChanged extends AddOrderRetailStep2ScreenEvent {
  final String notes;

  const NotesChanged(this.notes);

  @override
  List<Object> get props => [notes];
}

class InitializeForm extends AddOrderRetailStep2ScreenEvent {
  final String? defaultSalutation;
  final String defaultPaymentMethod;

  const InitializeForm({
    this.defaultSalutation,
    required this.defaultPaymentMethod,
  });

  @override
  List<Object?> get props => [defaultSalutation, defaultPaymentMethod];
}
