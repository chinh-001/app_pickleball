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
  final Map<String, String> courtNamesById;
  final List<AvailableCourForBookingModel> availableCourtsByDate;
  final bool isCheckingAvailability;
  final double totalPayment;
  final List<String> localizedProductIds;

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
    this.courtNamesById = const {},
    this.availableCourtsByDate = const [],
    this.isCheckingAvailability = false,
    this.totalPayment = 0.0,
    this.localizedProductIds = const [],
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

  int get maxCourtCount {
    // Nếu chưa có ngày nào được chọn hoặc chưa có dữ liệu từ API, giới hạn mặc định là 10
    if (selectedDates.isEmpty || availableCourtsByDate.isEmpty) {
      return 10;
    }

    // Tìm số lượng sân tối đa có thể chọn cho tất cả các ngày đã chọn
    int maxCourts = 100; // Giá trị ban đầu đủ lớn

    for (var selectedDate in selectedDates) {
      final String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      bool foundDate = false;

      // Tìm thông tin cho ngày này từ danh sách kết quả API
      for (var item in availableCourtsByDate) {
        if (item.bookingDate == dateKey) {
          // Đếm số sân có trạng thái "available"
          final availableCount =
              item.courts.where((court) => court.status == "available").length;

          // Lấy giá trị tối thiểu giữa maxCourts hiện tại và số sân có sẵn trong ngày này
          maxCourts = availableCount < maxCourts ? availableCount : maxCourts;
          foundDate = true;
          break;
        }
      }

      // Nếu không tìm thấy thông tin cho ngày này, đặt maxCourts = 0 để thể hiện rằng không có sân nào
      if (!foundDate) {
        maxCourts = 0;
        break; // Dừng lại vì nếu một ngày không có sân, thì không thể chọn sân cho tất cả các ngày
      }
    }

    // Trả về tối thiểu là 1 sân
    return maxCourts > 0 ? maxCourts : 1;
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
    Map<String, String>? courtNamesById,
    List<AvailableCourForBookingModel>? availableCourtsByDate,
    bool? isCheckingAvailability,
    double? totalPayment,
    List<String>? localizedProductIds,
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
      courtNamesById: courtNamesById ?? this.courtNamesById,
      availableCourtsByDate:
          availableCourtsByDate ?? this.availableCourtsByDate,
      isCheckingAvailability:
          isCheckingAvailability ?? this.isCheckingAvailability,
      totalPayment: totalPayment ?? this.totalPayment,
      localizedProductIds: localizedProductIds ?? this.localizedProductIds,
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
    courtNamesById,
    availableCourtsByDate,
    isCheckingAvailability,
    totalPayment,
    localizedProductIds,
  ];
}
