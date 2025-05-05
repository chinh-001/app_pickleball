import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/localization/language_provider.dart';

part 'language_screen_event.dart';
part 'language_screen_state.dart';

class LanguageScreenBloc
    extends Bloc<LanguageScreenEvent, LanguageScreenState> {
  final BuildContext context;

  LanguageScreenBloc(this.context)
    : super(
        LanguageScreenState(
          selectedLanguage:
              Provider.of<LanguageProvider>(
                context,
                listen: false,
              ).locale.languageCode,
        ),
      ) {
    on<ChangeLanguageEvent>((event, emit) {
      // Chỉ cập nhật trạng thái, không thay đổi ngôn ngữ thực tế
      // Ngôn ngữ chỉ được thay đổi khi nhấn nút check trong language_screen.dart
      emit(LanguageScreenState(selectedLanguage: event.languageCode));
    });
  }
}
