import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/services/repositories/customer_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/models/payment_methods_model.dart';
import 'package:app_pickleball/services/repositories/payment_methods_repository.dart';
import 'package:app_pickleball/models/payment_status_model.dart';
import 'package:app_pickleball/services/repositories/payment_status_repository.dart';
import 'package:app_pickleball/models/multiple_bookings_model.dart';
import 'package:app_pickleball/services/repositories/multiple_bookings_repository.dart';

part 'add_order_retail_step_2_screen_event.dart';
part 'add_order_retail_step_2_screen_state.dart';

class AddOrderRetailStep2ScreenBloc
    extends
        Bloc<AddOrderRetailStep2ScreenEvent, AddOrderRetailStep2ScreenState> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final UserPermissionsRepository _permissionsRepository =
      UserPermissionsRepository();
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  final PaymentStatusRepository _paymentStatusRepository =
      PaymentStatusRepository();

  AddOrderRetailStep2ScreenBloc()
    : super(
        const AddOrderRetailStep2ScreenState(
          selectedSalutation: null,
          paymentMethod: null,
          paymentStatus: 'Chưa thanh toán',
          orderStatus: 'Mới',
          lastName: '',
          firstName: '',
          email: '',
          phone: '',
          notes: '',
        ),
      ) {
    on<SalutationChanged>(_onSalutationChanged);
    on<PaymentMethodChanged>(_onPaymentMethodChanged);
    on<PaymentStatusChanged>(_onPaymentStatusChanged);
    on<OrderStatusChanged>(_onOrderStatusChanged);
    on<LastNameChanged>(_onLastNameChanged);
    on<FirstNameChanged>(_onFirstNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<NotesChanged>(_onNotesChanged);
    on<ShowAddCustomerForm>(_onShowAddCustomerForm);
    on<HideAddCustomerForm>(_onHideAddCustomerForm);
    on<InitializeForm>(_onInitializeForm);
    on<SearchCustomers>(_onSearchCustomers);
    on<ResetForm>(_onResetForm);
    on<SetTotalPayment>(_onSetTotalPayment);
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<LoadPaymentStatus>(_onLoadPaymentStatus);
    on<CustomerIdChanged>(_onCustomerIdChanged);
  }

  Future<void> _onLoadPaymentStatus(
    LoadPaymentStatus event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingPaymentStatus: true));

      log.log('Đang tải trạng thái thanh toán...');

      final PaymentStatusResult result =
          await _paymentStatusRepository.getAllPaymentStatus();

      log.log('Đã tải ${result.items.length} trạng thái thanh toán');

      emit(
        state.copyWith(
          paymentStatusList: result.items,
          isLoadingPaymentStatus: false,
        ),
      );

      // Nếu có trạng thái thanh toán và đang sử dụng trạng thái mặc định
      if (result.items.isNotEmpty && state.paymentStatus == 'Chưa thanh toán') {
        // Tìm trạng thái 'Chưa thanh toán' hoặc trạng thái tương đương trong API
        final unpaidStatus = result.items.firstWhere((item) {
          return item.name.toLowerCase().contains('chưa') ||
              item.code.toLowerCase().contains('unpaid');
        }, orElse: () => result.items.first);

        emit(state.copyWith(paymentStatus: unpaidStatus.name));
      }
    } catch (e) {
      log.log('Lỗi khi tải trạng thái thanh toán: $e');
      emit(state.copyWith(isLoadingPaymentStatus: false));
    }
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingPaymentMethods: true));

      log.log('Đang tải phương thức thanh toán...');

      final PaymentMethodsResult result =
          await _paymentMethodsRepository.getPaymentMethods();

      log.log('Đã tải ${result.items.length} phương thức thanh toán');

      emit(
        state.copyWith(
          paymentMethods: result.items,
          isLoadingPaymentMethods: false,
        ),
      );

      if (result.items.isNotEmpty && state.paymentMethod == null) {
        emit(state.copyWith(paymentMethod: result.items.first.name));
      }
    } catch (e) {
      log.log('Lỗi khi tải phương thức thanh toán: $e');
      emit(state.copyWith(isLoadingPaymentMethods: false));
    }
  }

  void _onSalutationChanged(
    SalutationChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(selectedSalutation: event.salutation));
  }

  void _onPaymentMethodChanged(
    PaymentMethodChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  void _onPaymentStatusChanged(
    PaymentStatusChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(paymentStatus: event.paymentStatus));
  }

  void _onOrderStatusChanged(
    OrderStatusChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(orderStatus: event.orderStatus));
  }

  void _onLastNameChanged(
    LastNameChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(lastName: event.lastName));
  }

  void _onFirstNameChanged(
    FirstNameChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(firstName: event.firstName));
  }

  void _onEmailChanged(
    EmailChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  void _onPhoneChanged(
    PhoneChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onNotesChanged(
    NotesChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onShowAddCustomerForm(
    ShowAddCustomerForm event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(showAddCustomerForm: true));
  }

  void _onHideAddCustomerForm(
    HideAddCustomerForm event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(showAddCustomerForm: false));
  }

  void _onInitializeForm(
    InitializeForm event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(
      state.copyWith(
        selectedSalutation: event.defaultSalutation,
        paymentMethod: event.defaultPaymentMethod,
        totalPayment: event.totalPayment,
      ),
    );

    add(const LoadPaymentMethods());
    add(const LoadPaymentStatus());
  }

  void _onSetTotalPayment(
    SetTotalPayment event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(totalPayment: event.totalPayment));
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) async {
    final String searchQuery = event.searchQuery;

    emit(state.copyWith(searchQuery: searchQuery));

    if (searchQuery.length < 3) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    emit(state.copyWith(isSearching: true));

    try {
      final currentChannel = _channelSyncService.selectedChannel;
      log.log(
        'SearchCustomers - Kênh hiện tại từ ChannelSyncService: "$currentChannel"',
      );

      if (currentChannel.isEmpty) {
        log.log(
          'SearchCustomers - ERROR: Chưa chọn kênh. Vui lòng chọn kênh ở màn hình Home trước',
        );
        emit(state.copyWith(searchResults: [], isSearching: false));
        return;
      }

      log.log('SearchCustomers - Đang lấy token cho kênh: "$currentChannel"');
      final channelToken = await _permissionsRepository.getChannelToken(
        currentChannel,
      );

      String maskedToken = channelToken;
      if (channelToken.length > 10) {
        maskedToken =
            "${channelToken.substring(0, 5)}...${channelToken.substring(channelToken.length - 5)}";
      } else if (channelToken.isEmpty) {
        maskedToken = "<empty token>";
      }
      log.log('SearchCustomers - Token đã lấy được: $maskedToken');

      if (channelToken.isEmpty) {
        log.log(
          'SearchCustomers - ERROR: Không tìm thấy token cho kênh "$currentChannel". Vui lòng đăng nhập lại',
        );
        emit(state.copyWith(searchResults: [], isSearching: false));
        return;
      }

      log.log('SearchCustomers - Đang tìm kiếm với từ khóa: "$searchQuery"');

      final CustomerResponse response = await _customerRepository.getCustomers(
        channelToken: channelToken,
        searchQuery: searchQuery,
      );

      log.log(
        'SearchCustomers result: ${response.items.length} customers found for query "$searchQuery"',
      );
      if (response.items.isNotEmpty) {
        log.log('Customer details: ${response.items}');
      }

      emit(state.copyWith(searchResults: response.items, isSearching: false));
    } catch (e) {
      log.log('SearchCustomers - ERROR: Lỗi khi tìm kiếm khách hàng: $e');
      emit(state.copyWith(searchResults: [], isSearching: false));
    }
  }

  void _onResetForm(
    ResetForm event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(
      state.copyWith(
        selectedSalutation: null,
        lastName: '',
        firstName: '',
        email: '',
        phone: '',
        notes: '',
      ),
    );
  }

  Future<String?> getChannelToken() async {
    try {
      final currentChannel = ChannelSyncService.instance.selectedChannel;
      log.log('Lấy channel từ ChannelSyncService: "$currentChannel"');

      if (currentChannel.isEmpty) {
        log.log('Không có kênh nào được chọn!');
        return null;
      }

      final userPermissionsRepository = UserPermissionsRepository();
      final channelToken = await userPermissionsRepository.getChannelToken(
        currentChannel,
      );

      if (channelToken.isNotEmpty) {
        String maskedToken = channelToken;
        if (channelToken.length > 10) {
          maskedToken =
              "${channelToken.substring(0, 5)}...${channelToken.substring(channelToken.length - 5)}";
        }
        log.log('Channel token đã lấy được: $maskedToken');
      } else {
        log.log('Không thể lấy token cho kênh!');
      }

      return channelToken;
    } catch (e) {
      log.log('Lỗi khi lấy channel token: $e');
      return null;
    }
  }

  Future<List<MultipleBookingsResponse>> createMultipleBookings({
    required String customerId,
    required String productId,
    required Map<String, List<String>> selectedCourtsByDate,
    required String startTime,
    required String endTime,
    required double totalPrice,
    required String paymentMethodName,
    required String paymentStatusId,
  }) async {
    try {
      // Lấy channel token
      final channelToken = await getChannelToken();
      if (channelToken == null || channelToken.isEmpty) {
        log.log('Không thể tạo booking: Không có channel token');
        return [];
      }

      // Log các tham số input
      log.log('===== THÔNG TIN INPUT CREATE MULTIPLE BOOKINGS =====');
      log.log('1. start_time: $startTime');
      log.log('2. end_time: $endTime');
      log.log('3. status: 1 (mặc định)');
      log.log('4. customer ID: $customerId');
      log.log('5. booking_date: ${selectedCourtsByDate.keys.join(", ")}');
      log.log('6. total_price: $totalPrice');
      log.log('7. product ID: $productId');
      log.log(
        '8. court IDs: ${selectedCourtsByDate.values.expand((courts) => courts).toList()}',
      );
      log.log('9. payment_method: $paymentMethodName');
      log.log('10. payment_status ID: $paymentStatusId');
      log.log('=================================================');

      // Tính số lượng sân để phân chia giá
      int totalCourts = 0;
      selectedCourtsByDate.forEach((date, courts) {
        totalCourts += courts.length;
      });

      final pricePerCourt =
          totalCourts > 0 ? totalPrice / totalCourts : totalPrice;
      log.log('Tổng số sân: $totalCourts, Giá mỗi sân: $pricePerCourt');

      // Danh sách lưu tất cả các booking đã tạo
      final List<MultipleBookingsResponse> allBookings = [];

      // Repository để thực hiện mutation
      final repository = MultipleBookingsRepository();

      // Tạo booking cho từng ngày và sân riêng biệt
      for (final entry in selectedCourtsByDate.entries) {
        final String dateString = entry.key;
        final List<String> courtIds = entry.value;

        for (final courtId in courtIds) {
          // Tạo input cho một booking
          final booking = BookingInput(
            startTime: startTime,
            product: productId,
            endTime: endTime,
            totalPrice: pricePerCourt,
            paymentStatus: paymentStatusId,
            bookingDate: dateString,
            court: courtId,
            paymentMethod: paymentMethodName,
            status: "1", // Mặc định là "1"
            customer: customerId,
          );

          // Log thông tin booking
          log.log('Tạo booking mới:');
          log.log('- Ngày: $dateString');
          log.log('- Sân: $courtId');
          log.log('- Giá: $pricePerCourt VND');

          // Tạo input cho mutation
          final input = MultipleBookingsInput(bookings: [booking]);

          // Thực hiện mutation cho một booking
          try {
            final result = await repository.createMultipleBookings(
              channelToken: channelToken,
              input: input,
            );

            // Log kết quả
            log.log('===== KẾT QUẢ TẠO BOOKING =====');
            log.log('ID: ${result.id}');
            log.log('Code: ${result.code}');
            log.log('Booking date: ${result.bookingDate}');
            log.log('Thời gian: ${result.startTime} - ${result.endTime}');
            log.log('Sân: ${result.court.name}');
            log.log('===============================');

            // Thêm vào danh sách kết quả
            allBookings.add(result);
          } catch (e) {
            log.log(
              'Lỗi khi tạo booking cho ngày $dateString và sân $courtId: $e',
            );
          }
        }
      }

      log.log('Đã tạo thành công ${allBookings.length}/${totalCourts} booking');

      return allBookings;
    } catch (e) {
      log.log('Lỗi khi tạo multiple bookings: $e');
      return [];
    }
  }

  void _onCustomerIdChanged(
    CustomerIdChanged event,
    Emitter<AddOrderRetailStep2ScreenState> emit,
  ) {
    emit(state.copyWith(customerId: event.customerId));
  }
}
