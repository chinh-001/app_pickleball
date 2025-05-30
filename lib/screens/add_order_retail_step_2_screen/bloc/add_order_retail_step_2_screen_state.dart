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
  final bool showAddCustomerForm;
  final String searchQuery;
  final List<dynamic> searchResults;
  final bool isSearching;
  final double totalPayment;
  final List<dynamic> paymentMethods;
  final bool isLoadingPaymentMethods;
  final List<dynamic> paymentStatusList;
  final bool isLoadingPaymentStatus;
  final String customerId;

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
    this.showAddCustomerForm = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.totalPayment = 0.0,
    this.paymentMethods = const [],
    this.isLoadingPaymentMethods = false,
    this.paymentStatusList = const [],
    this.isLoadingPaymentStatus = false,
    this.customerId = '',
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
    bool? showAddCustomerForm,
    String? searchQuery,
    List<dynamic>? searchResults,
    bool? isSearching,
    double? totalPayment,
    List<dynamic>? paymentMethods,
    bool? isLoadingPaymentMethods,
    List<dynamic>? paymentStatusList,
    bool? isLoadingPaymentStatus,
    String? customerId,
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
      showAddCustomerForm: showAddCustomerForm ?? this.showAddCustomerForm,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      totalPayment: totalPayment ?? this.totalPayment,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoadingPaymentMethods:
          isLoadingPaymentMethods ?? this.isLoadingPaymentMethods,
      paymentStatusList: paymentStatusList ?? this.paymentStatusList,
      isLoadingPaymentStatus:
          isLoadingPaymentStatus ?? this.isLoadingPaymentStatus,
      customerId: customerId ?? this.customerId,
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
    showAddCustomerForm,
    searchQuery,
    searchResults,
    isSearching,
    totalPayment,
    paymentMethods,
    isLoadingPaymentMethods,
    paymentStatusList,
    isLoadingPaymentStatus,
    customerId,
  ];
}
