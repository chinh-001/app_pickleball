part of 'add_order_retail_step_1_screen_bloc.dart';

class AddOrderRetailStep1ScreenState extends Equatable {
  final String selectedService;
  final int courtCount;
  final List<DateTime> selectedDates;
  final String selectedFromTime;
  final String selectedToTime;
  final double numberOfHours;
  final List<String> servicesList;
  final bool isFormComplete;

  const AddOrderRetailStep1ScreenState({
    this.selectedService = '',
    this.courtCount = 1,
    this.selectedDates = const [],
    this.selectedFromTime = '19:30',
    this.selectedToTime = '20:00',
    this.numberOfHours = 0.5,
    this.servicesList = const [
      'Pikachu Pickleball Xuân Hòa',
      'Bao sân',
      'Demo',
      'Pickleball TADA Sport Thanh Đa',
      'Pickleball TADA Sport Bình Lợi',
      'Pickleball TADA Sport D2',
      'Điều hòa',
      'Mái che',
    ],
    this.isFormComplete = false,
  });

  AddOrderRetailStep1ScreenState copyWith({
    String? selectedService,
    int? courtCount,
    List<DateTime>? selectedDates,
    String? selectedFromTime,
    String? selectedToTime,
    double? numberOfHours,
    List<String>? servicesList,
    bool? isFormComplete,
  }) {
    return AddOrderRetailStep1ScreenState(
      selectedService: selectedService ?? this.selectedService,
      courtCount: courtCount ?? this.courtCount,
      selectedDates: selectedDates ?? this.selectedDates,
      selectedFromTime: selectedFromTime ?? this.selectedFromTime,
      selectedToTime: selectedToTime ?? this.selectedToTime,
      numberOfHours: numberOfHours ?? this.numberOfHours,
      servicesList: servicesList ?? this.servicesList,
      isFormComplete: isFormComplete ?? this.isFormComplete,
    );
  }

  @override
  List<Object> get props => [
    selectedService,
    courtCount,
    selectedDates,
    selectedFromTime,
    selectedToTime,
    numberOfHours,
    servicesList,
    isFormComplete,
  ];
}
