import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/services/repositories/customer_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';

part 'add_order_retail_step_2_screen_event.dart';
part 'add_order_retail_step_2_screen_state.dart';

class AddOrderRetailStep2ScreenBloc
    extends
        Bloc<AddOrderRetailStep2ScreenEvent, AddOrderRetailStep2ScreenState> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final UserPermissionsRepository _permissionsRepository =
      UserPermissionsRepository();
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;

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

    // Cập nhật query vào state
    emit(state.copyWith(searchQuery: searchQuery));

    // Chỉ tìm kiếm khi nhập ít nhất 3 ký tự
    if (searchQuery.length < 3) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    // Cập nhật trạng thái đang tìm kiếm
    emit(state.copyWith(isSearching: true));

    try {
      // Lấy channel hiện tại từ ChannelSyncService
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

      // Lấy token từ UserPermissionsRepository dựa vào channel
      log.log('SearchCustomers - Đang lấy token cho kênh: "$currentChannel"');
      final channelToken = await _permissionsRepository.getChannelToken(
        currentChannel,
      );

      // Log token (đã che một phần)
      String maskedToken = channelToken;
      if (channelToken.length > 10) {
        maskedToken =
            "${channelToken.substring(0, 5)}...${channelToken.substring(channelToken.length - 5)}";
      } else if (channelToken.isEmpty) {
        maskedToken = "<empty token>";
      }
      log.log('SearchCustomers - Token đã lấy được: $maskedToken');

      // Nếu không có token, hiển thị lỗi
      if (channelToken.isEmpty) {
        log.log(
          'SearchCustomers - ERROR: Không tìm thấy token cho kênh "$currentChannel". Vui lòng đăng nhập lại',
        );
        emit(state.copyWith(searchResults: [], isSearching: false));
        return;
      }

      log.log('SearchCustomers - Đang tìm kiếm với từ khóa: "$searchQuery"');

      // Gọi repository để thực hiện tìm kiếm với searchQuery
      final CustomerResponse response = await _customerRepository.getCustomers(
        channelToken: channelToken,
        searchQuery: searchQuery,
      );

      // Log kết quả tìm kiếm
      log.log(
        'SearchCustomers result: ${response.items.length} customers found for query "$searchQuery"',
      );
      if (response.items.isNotEmpty) {
        log.log('Customer details: ${response.items}');
      }

      // Cập nhật state với kết quả tìm kiếm
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
    // Giữ lại thông tin thanh toán và trạng thái, chỉ reset thông tin khách hàng
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
}
