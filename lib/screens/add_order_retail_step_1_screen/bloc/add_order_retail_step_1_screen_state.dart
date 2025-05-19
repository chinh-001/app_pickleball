part of 'add_order_retail_step_1_screen_bloc.dart';

class AddOrderRetailStep1ScreenState extends Equatable {
  final String selectedService;
  final String selectedServiceId;
  final int courtCount;
  final List<DateTime> selectedDates;
  final String selectedFromTime;
  final String selectedToTime;
  final double numberOfHours;
  final List<ProductItem> productItems;
  final bool isFormComplete;
  final bool isLoading;
  final List<CourtItem> availableCourts;
  final Map<String, List<String>> selectedCourtsByDate;
  final List<AvailableCourForBookingModel> availableCourtsByDate;
  final bool isCheckingAvailability;
  final double totalPayment;

  const AddOrderRetailStep1ScreenState({
    this.selectedService = '',
    this.selectedServiceId = '',
    this.courtCount = 1,
    this.selectedDates = const [],
    this.selectedFromTime = '19:30',
    this.selectedToTime = '20:00',
    this.numberOfHours = 0.5,
    this.productItems = const [],
    this.isFormComplete = false,
    this.isLoading = false,
    this.availableCourts = const [],
    this.selectedCourtsByDate = const {},
    this.availableCourtsByDate = const [],
    this.isCheckingAvailability = false,
    this.totalPayment = 0.0,
  });

  List<String> get selectedCourtIds {
    final allSelectedCourts = <String>[];
    selectedCourtsByDate.forEach(
      (_, courts) => allSelectedCourts.addAll(courts),
    );
    return allSelectedCourts;
  }

  List<String> get servicesList {
    if (productItems.isEmpty) {
      return const [
        'Pikachu Pickleball Xuân Hòa',
        'Bao sân',
        'Demo',
        'Pickleball TADA Sport Thanh Đa',
        'Pickleball TADA Sport Bình Lợi',
        'Pickleball TADA Sport D2',
        'Điều hòa',
        'Mái che',
      ];
    }

    // Return the product names from the model
    // The localization will be handled in the View
    return productItems.map((item) => item.name).toList();
  }

  AddOrderRetailStep1ScreenState copyWith({
    String? selectedService,
    String? selectedServiceId,
    int? courtCount,
    List<DateTime>? selectedDates,
    String? selectedFromTime,
    String? selectedToTime,
    double? numberOfHours,
    List<ProductItem>? productItems,
    bool? isFormComplete,
    bool? isLoading,
    List<CourtItem>? availableCourts,
    Map<String, List<String>>? selectedCourtsByDate,
    List<AvailableCourForBookingModel>? availableCourtsByDate,
    bool? isCheckingAvailability,
    double? totalPayment,
  }) {
    return AddOrderRetailStep1ScreenState(
      selectedService: selectedService ?? this.selectedService,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      courtCount: courtCount ?? this.courtCount,
      selectedDates: selectedDates ?? this.selectedDates,
      selectedFromTime: selectedFromTime ?? this.selectedFromTime,
      selectedToTime: selectedToTime ?? this.selectedToTime,
      numberOfHours: numberOfHours ?? this.numberOfHours,
      productItems: productItems ?? this.productItems,
      isFormComplete: isFormComplete ?? this.isFormComplete,
      isLoading: isLoading ?? this.isLoading,
      availableCourts: availableCourts ?? this.availableCourts,
      selectedCourtsByDate: selectedCourtsByDate ?? this.selectedCourtsByDate,
      availableCourtsByDate:
          availableCourtsByDate ?? this.availableCourtsByDate,
      isCheckingAvailability:
          isCheckingAvailability ?? this.isCheckingAvailability,
      totalPayment: totalPayment ?? this.totalPayment,
    );
  }

  @override
  List<Object> get props => [
    selectedService,
    selectedServiceId,
    courtCount,
    selectedDates,
    selectedFromTime,
    selectedToTime,
    numberOfHours,
    productItems,
    isFormComplete,
    isLoading,
    availableCourts,
    selectedCourtsByDate,
    availableCourtsByDate,
    isCheckingAvailability,
    totalPayment,
  ];
}
