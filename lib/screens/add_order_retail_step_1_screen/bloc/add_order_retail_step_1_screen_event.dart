part of 'add_order_retail_step_1_screen_bloc.dart';

abstract class AddOrderRetailStep1ScreenEvent extends Equatable {
  const AddOrderRetailStep1ScreenEvent();

  @override
  List<Object> get props => [];
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
