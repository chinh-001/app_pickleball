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
}
