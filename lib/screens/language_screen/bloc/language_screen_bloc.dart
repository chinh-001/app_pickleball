import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'language_screen_event.dart';
part 'language_screen_state.dart';

class LanguageScreenBloc
    extends Bloc<LanguageScreenEvent, LanguageScreenState> {
  LanguageScreenBloc()
    : super(const LanguageScreenState(selectedLanguage: 'vi')) {
    on<ChangeLanguageEvent>((event, emit) {
      emit(LanguageScreenState(selectedLanguage: event.languageCode));
    });
  }
}
