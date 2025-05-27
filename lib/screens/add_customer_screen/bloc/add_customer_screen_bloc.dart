import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_customer_screen_event.dart';
part 'add_customer_screen_state.dart';

class AddCustomerScreenBloc
    extends Bloc<AddCustomerScreenEvent, AddCustomerScreenState> {
  AddCustomerScreenBloc() : super(const AddCustomerScreenState()) {
    on<InitializeForm>(_onInitializeForm);
    on<SalutationChanged>(_onSalutationChanged);
    on<LastNameChanged>(_onLastNameChanged);
    on<FirstNameChanged>(_onFirstNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<NotesChanged>(_onNotesChanged);
    on<ResetForm>(_onResetForm);
    on<SaveCustomer>(_onSaveCustomer);
  }

  void _onInitializeForm(
    InitializeForm event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(const AddCustomerScreenState());
  }

  void _onSalutationChanged(
    SalutationChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(selectedSalutation: event.salutation));
  }

  void _onLastNameChanged(
    LastNameChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(lastName: event.lastName));
  }

  void _onFirstNameChanged(
    FirstNameChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(firstName: event.firstName));
  }

  void _onEmailChanged(
    EmailChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  void _onPhoneChanged(
    PhoneChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onNotesChanged(
    NotesChanged event,
    Emitter<AddCustomerScreenState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onResetForm(ResetForm event, Emitter<AddCustomerScreenState> emit) {
    emit(const AddCustomerScreenState());
  }

  void _onSaveCustomer(
    SaveCustomer event,
    Emitter<AddCustomerScreenState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));

    // Có thể thêm logic lưu khách hàng vào API ở đây

    // Giả lập thành công
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isSaving: false, isSuccess: true));
  }
}
