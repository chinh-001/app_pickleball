part of 'add_customer_screen_bloc.dart';

class AddCustomerScreenState extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String notes;
  final String? selectedSalutation;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const AddCustomerScreenState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.notes = '',
    this.selectedSalutation,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AddCustomerScreenState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? notes,
    String? selectedSalutation,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AddCustomerScreenState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      selectedSalutation: selectedSalutation ?? this.selectedSalutation,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    notes,
    selectedSalutation,
    isSaving,
    errorMessage,
    isSuccess,
  ];
}
