part of 'language_screen_bloc.dart';

class LanguageScreenState extends Equatable {
  final String selectedLanguage;

  const LanguageScreenState({required this.selectedLanguage});

  @override
  List<Object> get props => [selectedLanguage];
}
