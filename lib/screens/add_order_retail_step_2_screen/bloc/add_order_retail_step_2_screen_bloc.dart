import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_order_retail_step_2_screen_event.dart';
part 'add_order_retail_step_2_screen_state.dart';

class AddOrderRetailStep2ScreenBloc
    extends
        Bloc<AddOrderRetailStep2ScreenEvent, AddOrderRetailStep2ScreenState> {
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
        paymentMethod: event.defaultPaymentMethod,
        selectedSalutation: event.defaultSalutation,
      ),
    );
  }
}
