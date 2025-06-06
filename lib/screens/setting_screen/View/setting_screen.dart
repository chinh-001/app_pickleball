import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/cards/custom_setting_item.dart';
import '../../widgets/lists/custom_bottom_navigation_bar.dart';
import '../../../screens/language_screen/View/language_screen.dart';
import '../bloc/setting_screen_bloc.dart';
import '../../../services/localization/app_localizations.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => SettingScreenBloc(),
      child: BlocBuilder<SettingScreenBloc, SettingScreenState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                localizations.translate('accountSettings'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Nhóm cài đặt tài khoản
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            localizations.translate('account'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Mục ngôn ngữ
                        CustomSettingItem(
                          title: localizations.translate('language'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LanguageScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const CustomBottomNavigationBar(
              currentIndex: 3,
            ),
          );
        },
      ),
    );
  }
}
