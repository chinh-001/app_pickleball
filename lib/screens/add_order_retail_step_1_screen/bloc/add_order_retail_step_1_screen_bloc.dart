import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_order_retail_step_1_screen_event.dart';
part 'add_order_retail_step_1_screen_state.dart';

class AddOrderRetailStep1ScreenBloc
    extends
        Bloc<AddOrderRetailStep1ScreenEvent, AddOrderRetailStep1ScreenState> {
  // Tạo danh sách đầy đủ thời gian
  final List<String> fullTimeOptions = [];

  AddOrderRetailStep1ScreenBloc() : super(AddOrderRetailStep1ScreenState()) {
    _initTimeOptions();

    on<ServiceSelected>(_onServiceSelected);
    on<CourtCountChanged>(_onCourtCountChanged);
    on<DatesSelected>(_onDatesSelected);
    on<FromTimeSelected>(_onFromTimeSelected);
    on<ToTimeSelected>(_onToTimeSelected);
  }

  void _initTimeOptions() {
    // Tạo danh sách thời gian từ 6:00 đến 23:30 với bước 30 phút
    for (int hour = 6; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final String hourStr = hour.toString().padLeft(2, '0');
        final String minuteStr = minute.toString().padLeft(2, '0');
        fullTimeOptions.add('$hourStr:$minuteStr');
      }
    }
  }

  List<String> getValidToTimeOptions(String fromTime) {
    final int fromIndex = fullTimeOptions.indexOf(fromTime);
    if (fromIndex >= 0 && fromIndex < fullTimeOptions.length - 1) {
      return fullTimeOptions.sublist(fromIndex + 1);
    }
    return fullTimeOptions;
  }

  void _onServiceSelected(
    ServiceSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    emit(
      _updateFormCompleteness(state.copyWith(selectedService: event.service)),
    );
  }

  void _onCourtCountChanged(
    CourtCountChanged event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    emit(_updateFormCompleteness(state.copyWith(courtCount: event.courtCount)));
  }

  void _onDatesSelected(
    DatesSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    emit(_updateFormCompleteness(state.copyWith(selectedDates: event.dates)));
  }

  void _onFromTimeSelected(
    FromTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    final String fromTime = event.fromTime;
    String toTime = state.selectedToTime;

    // Check if toTime is before fromTime
    final int fromIndex = fullTimeOptions.indexOf(fromTime);
    final int toIndex = fullTimeOptions.indexOf(toTime);

    if (toIndex <= fromIndex) {
      // If toTime is before or same as fromTime, set it to next 30 min slot
      int newToIndex = fromIndex + 1;
      if (newToIndex < fullTimeOptions.length) {
        toTime = fullTimeOptions[newToIndex];
      }
    }

    final double hours = _calculateHours(fromTime, toTime);
    emit(
      _updateFormCompleteness(
        state.copyWith(
          selectedFromTime: fromTime,
          selectedToTime: toTime,
          numberOfHours: hours,
        ),
      ),
    );
  }

  void _onToTimeSelected(
    ToTimeSelected event,
    Emitter<AddOrderRetailStep1ScreenState> emit,
  ) {
    final double hours = _calculateHours(state.selectedFromTime, event.toTime);
    emit(
      _updateFormCompleteness(
        state.copyWith(selectedToTime: event.toTime, numberOfHours: hours),
      ),
    );
  }

  double _calculateHours(String fromTime, String toTime) {
    // Parse the time strings to calculate hours
    final fromParts = fromTime.split(':');
    final toParts = toTime.split(':');

    if (fromParts.length == 2 && toParts.length == 2) {
      final fromHour = int.parse(fromParts[0]);
      final fromMinute = int.parse(fromParts[1]);
      final toHour = int.parse(toParts[0]);
      final toMinute = int.parse(toParts[1]);

      final fromMinutes = fromHour * 60 + fromMinute;
      final toMinutes = toHour * 60 + toMinute;

      // Ensure we don't have negative values
      final diffMinutes = toMinutes > fromMinutes ? toMinutes - fromMinutes : 0;
      return diffMinutes / 60;
    }

    return 0;
  }

  AddOrderRetailStep1ScreenState _updateFormCompleteness(
    AddOrderRetailStep1ScreenState state,
  ) {
    final bool isComplete =
        state.selectedDates.isNotEmpty && state.selectedService.isNotEmpty;
    return state.copyWith(isFormComplete: isComplete);
  }
}
