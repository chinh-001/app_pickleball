import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/lists/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/profile_screen/bloc/profile_screen_bloc.dart';
import 'package:app_pickleball/screens/login_screen/View/login_screen.dart';
import 'package:app_pickleball/screens/widgets/dialogs/custom_confirm_logout_dialog.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ProfileScreenBloc();
        bloc.add(LoadProfileEvent());
        log.log('ProfileScreen: Bloc created and LoadProfileEvent added');
        return bloc;
      },
      child: BlocListener<ProfileScreenBloc, ProfileScreenState>(
        listener: (context, state) {
          if (state is ProfileLoggedOutState) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          } else if (state is ProfileScreenError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).translate('personalInfo')),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<ProfileScreenBloc, ProfileScreenState>(
                builder: (context, state) {
                  log.log(
                    'ProfileScreen: Current state - ${state.runtimeType}',
                  );
                  final bloc = context.read<ProfileScreenBloc>();

                  // Kiểm tra kiểu của state
                  if (state is ProfileEditableState ||
                      state is ProfileReadOnlyState) {
                    final isEditable = state is ProfileEditableState;

                    // Lấy giá trị từ state
                    final name =
                        state is ProfileEditableState
                            ? state.name
                            : (state as ProfileReadOnlyState).name;
                    final email =
                        state is ProfileEditableState
                            ? state.email
                            : (state as ProfileReadOnlyState).email;

                    log.log('ProfileScreen: Name - $name, Email - $email');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trường Tên
                        buildInfoField(
                          context: context,
                          title: AppLocalizations.of(context).translate('name'),
                          controller: TextEditingController(text: name),
                          isEditable: isEditable,
                        ),
                        const SizedBox(height: 20),

                        // Trường Email
                        buildInfoField(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).translate('email'),
                          controller: TextEditingController(text: email),
                          isEditable: isEditable,
                        ),
                        const SizedBox(height: 30),

                        // Nút Lưu và Sửa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nút Lưu
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isEditable
                                        ? () {
                                          log.log(
                                            'ProfileScreen: Save button pressed - Name: $name, Email: $email',
                                          );
                                          bloc.add(
                                            SaveInfoEvent(
                                              name: name,
                                              email: email,
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).translate('infoSaved'),
                                              ),
                                            ),
                                          );
                                        }
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isEditable ? Colors.green : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('save'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Nút Sửa
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  log.log('ProfileScreen: Edit button pressed');
                                  bloc.add(EnableEditEvent());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).translate('editModeEnabled'),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('edit'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Nút Đăng xuất
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              log.log('ProfileScreen: Logout button pressed');
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return CustomConfirmLogoutDialog(
                                    title: AppLocalizations.of(
                                      context,
                                    ).translate('logoutConfirmTitle'),
                                    content: AppLocalizations.of(
                                      context,
                                    ).translate('logoutConfirmMessage'),
                                    onConfirm: () {
                                      context.read<ProfileScreenBloc>().add(
                                        const LogoutEvent(),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context).translate('logout'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: CustomLoadingIndicator());
                },
              ),
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
        ),
      ),
    );
  }

  // Hàm xây dựng trường thông tin
  Widget buildInfoField({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: !isEditable,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(
              context,
            ).translate('enterYour').replaceAll('{field}', title.toLowerCase()),
            filled: true,
            fillColor:
                isEditable
                    ? Colors.white
                    : const Color.fromARGB(255, 222, 216, 216),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
