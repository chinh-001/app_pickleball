part of 'add_order_retail_step_2_screen_bloc.dart';

class AddOrderRetailStep2ScreenState extends Equatable {
  final String? selectedSalutation;
  final String? paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final String notes;

  const AddOrderRetailStep2ScreenState({
    required this.selectedSalutation,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.notes,
  });

  AddOrderRetailStep2ScreenState copyWith({
    String? selectedSalutation,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    String? notes,
  }) {
    return AddOrderRetailStep2ScreenState(
      selectedSalutation: selectedSalutation ?? this.selectedSalutation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    selectedSalutation,
    paymentMethod,
    paymentStatus,
    orderStatus,
    lastName,
    firstName,
    email,
    phone,
    notes,
  ];
}
