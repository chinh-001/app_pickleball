import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_menu_item.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/View/add_order_retail_step_1_screen.dart';
import 'package:app_pickleball/screens/menu_function_screen/bloc/menu_function_screen_bloc.dart';
import 'package:app_pickleball/screens/scanQrCode_screen/View/scanQr_screen.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';

class MenuFunctionScreen extends StatelessWidget {
  const MenuFunctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuFunctionScreenBloc(),
      child: BlocConsumer<MenuFunctionScreenBloc, MenuFunctionScreenState>(
        listener: (context, state) {
          if (state is PeriodicBookingSelectedState) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('periodicBookingSelected'),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is RetailBookingSelectedState) {
            // Hide loading indicator if shown
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddOrderRetailStep1Screen(),
              ),
            );
          } else if (state is ScanQrCodeSelectedState) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanQrScreen()),
            );
          } else if (state is MenuFunctionScreenLoading) {
            // Show loading dialog without background and text
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Center(child: CustomLoadingIndicator(size: 40.0)),
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context).translate('bookingType'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green,
              elevation: 0,
              centerTitle: true,
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('selectBookingType'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Danh sách các mục chức năng
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Item "định kì"
                      _buildMenuItem(
                        context: context,
                        icon: Icons.repeat,
                        text: AppLocalizations.of(
                          context,
                        ).translate('booking_type_periodic'),
                        onTap: () {
                          context.read<MenuFunctionScreenBloc>().add(
                            SelectPeriodicBookingEvent(),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Item "loại lẻ"
                      _buildMenuItem(
                        context: context,
                        icon: Icons.calendar_today,
                        text: AppLocalizations.of(
                          context,
                        ).translate('booking_type_retail'),
                        onTap: () {
                          context.read<MenuFunctionScreenBloc>().add(
                            SelectRetailBookingEvent(),
                          );
                        },
                      ),
                    ],
                  ),

                  // Tiêu đề cho "Chức năng khác"
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: Text(
                      AppLocalizations.of(context).translate('otherFunctions'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Danh sách chức năng khác
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Item "quét mã qr"
                      _buildMenuItem(
                        context: context,
                        icon: Icons.qr_code_scanner,
                        text: AppLocalizations.of(
                          context,
                        ).translate('scanQrCode'),
                        onTap: () {
                          context.read<MenuFunctionScreenBloc>().add(
                            SelectScanQrCodeEvent(),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.green,
  }) {
    return CustomMenuItem(
      icon: icon,
      iconColor: iconColor,
      text: text,
      onTap: onTap,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderRadius: 8,
      height: 70,
      fontSize: 16,
      iconSize: 28,
    );
  }
}
