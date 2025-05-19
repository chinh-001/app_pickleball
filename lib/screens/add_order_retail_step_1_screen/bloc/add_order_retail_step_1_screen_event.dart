part of 'add_order_retail_step_1_screen_bloc.dart';

abstract class AddOrderRetailStep1ScreenEvent extends Equatable {
  const AddOrderRetailStep1ScreenEvent();

  @override
  List<Object> get props => [];
}

class InitializeTimeOptionsEvent extends AddOrderRetailStep1ScreenEvent {
  const InitializeTimeOptionsEvent();
}

class InitializeProductsEvent extends AddOrderRetailStep1ScreenEvent {
  const InitializeProductsEvent();
}

class SetContextEvent extends AddOrderRetailStep1ScreenEvent {
  final BuildContext context;

  const SetContextEvent(this.context);

  @override
  List<Object> get props => [context];
}

class ServiceSelected extends AddOrderRetailStep1ScreenEvent {
  final String service;

  const ServiceSelected(this.service);

  @override
  List<Object> get props => [service];
}

class CourtCountChanged extends AddOrderRetailStep1ScreenEvent {
  final int courtCount;

  const CourtCountChanged(this.courtCount);

  @override
  List<Object> get props => [courtCount];
}

class DatesSelected extends AddOrderRetailStep1ScreenEvent {
  final List<DateTime> dates;

  const DatesSelected(this.dates);

  @override
  List<Object> get props => [dates];
}

class FromTimeSelected extends AddOrderRetailStep1ScreenEvent {
  final String fromTime;

  const FromTimeSelected(this.fromTime);

  @override
  List<Object> get props => [fromTime];
}

class ToTimeSelected extends AddOrderRetailStep1ScreenEvent {
  final String toTime;

  const ToTimeSelected(this.toTime);

  @override
  List<Object> get props => [toTime];
}

class CourtSelected extends AddOrderRetailStep1ScreenEvent {
  final String courtId;
  final bool isSelected;

  const CourtSelected({required this.courtId, required this.isSelected});

  @override
  List<Object> get props => [courtId, isSelected];
}

// Event mới để kiểm tra sân có sẵn
class CheckAvailableCourts extends AddOrderRetailStep1ScreenEvent {
  const CheckAvailableCourts();
}
