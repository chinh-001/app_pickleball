import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../screens/widgets/custom_choice_item.dart';
import '../bloc/language_screen_bloc.dart';
import '../../../services/localization/app_localizations.dart';
import '../../../services/localization/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => LanguageScreenBloc(context),
      child: BlocBuilder<LanguageScreenBloc, LanguageScreenState>(
        builder: (context, state) {
          // Mặc định chọn tiếng Việt
          final selectedLanguage = state.selectedLanguage;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                localizations.translate('selectLanguage'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Áp dụng ngôn ngữ đã chọn
                    Provider.of<LanguageProvider>(
                      context,
                      listen: false,
                    ).changeLanguage(selectedLanguage);

                    // Hiện thông báo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedLanguage == 'vi'
                              ? 'Đã chuyển sang Tiếng Việt'
                              : 'Switched to English',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Quay lại màn hình trước
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Tiếng Việt
                        CustomChoiceItem(
                          title: localizations.translate('vietnamese'),
                          isSelected: selectedLanguage == 'vi',
                          onTap: () {
                            BlocProvider.of<LanguageScreenBloc>(
                              context,
                            ).add(const ChangeLanguageEvent('vi'));
                          },
                        ),
                        // English
                        CustomChoiceItem(
                          title: localizations.translate('english'),
                          isSelected: selectedLanguage == 'en',
                          onTap: () {
                            BlocProvider.of<LanguageScreenBloc>(
                              context,
                            ).add(const ChangeLanguageEvent('en'));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
