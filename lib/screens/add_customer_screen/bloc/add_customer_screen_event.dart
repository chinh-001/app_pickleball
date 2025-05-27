part of 'add_customer_screen_bloc.dart';

abstract class AddCustomerScreenEvent extends Equatable {
  const AddCustomerScreenEvent();

  @override
  List<Object> get props => [];
}

class InitializeForm extends AddCustomerScreenEvent {}

class SalutationChanged extends AddCustomerScreenEvent {
  final String salutation;

  const SalutationChanged(this.salutation);

  @override
  List<Object> get props => [salutation];
}

class LastNameChanged extends AddCustomerScreenEvent {
  final String lastName;

  const LastNameChanged(this.lastName);

  @override
  List<Object> get props => [lastName];
}

class FirstNameChanged extends AddCustomerScreenEvent {
  final String firstName;

  const FirstNameChanged(this.firstName);

  @override
  List<Object> get props => [firstName];
}

class EmailChanged extends AddCustomerScreenEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PhoneChanged extends AddCustomerScreenEvent {
  final String phone;

  const PhoneChanged(this.phone);

  @override
  List<Object> get props => [phone];
}

class NotesChanged extends AddCustomerScreenEvent {
  final String notes;

  const NotesChanged(this.notes);

  @override
  List<Object> get props => [notes];
}

class ResetForm extends AddCustomerScreenEvent {
  const ResetForm();
}

class SaveCustomer extends AddCustomerScreenEvent {
  const SaveCustomer();
}
