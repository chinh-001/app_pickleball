part of 'language_screen_bloc.dart';

abstract class LanguageScreenEvent extends Equatable {
  const LanguageScreenEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguageEvent extends LanguageScreenEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
