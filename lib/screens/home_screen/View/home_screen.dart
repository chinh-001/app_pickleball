import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/input/custom_search_text_field.dart';
import 'package:app_pickleball/screens/widgets/lists/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_floating_action_button.dart';
import 'package:app_pickleball/screens/widgets/input/custom_dropdown.dart';
import 'package:app_pickleball/screens/widgets/calendar/custom_calendar_update.dart';
import 'package:app_pickleball/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/utils/auth_helper.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'dart:developer' as log;
import 'package:intl/intl.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Thêm phương thức static để reset bloc từ bên ngoài
  static void resetBloc() {
    _HomeScreenState.resetBloc();
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  static HomeScreenBloc? _cachedBloc;

  // Reset bloc khi có flag đánh dấu cần reset
  static void resetBloc() {
    if (_cachedBloc != null) {
      _cachedBloc!.close();
      _cachedBloc = null;
      log.log('HomeScreenBloc đã được reset');
    }
  }

  HomeScreenBloc get _homeBloc {
    // Kiểm tra xem có cần reset bloc không
    if (AuthHelper.shouldResetBlocs()) {
      resetBloc();
    }

    _cachedBloc ??= HomeScreenBloc(
      bookingRepository: BookingRepository(),
      permissionsRepository: UserPermissionsRepository(),
    );
    return _cachedBloc!;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Don't close the bloc here as it's cached
    super.dispose();
  }

  // Xử lý khi người dùng chọn ngày từ lịch
  void _handleDateSelected(List<DateTime> dates) {
    if (dates.isNotEmpty) {
      // Gọi event để lọc dữ liệu
      _homeBloc.add(FilterByDateRangeEvent(selectedDates: dates));

      log.log(
        'Đã chọn ${dates.length} ngày: ${dates.map((d) => DateFormat('dd/MM/yyyy').format(d)).join(", ")}',
      );
    } else {
      // Nếu không có ngày nào được chọn, xóa bộ lọc
      _homeBloc.add(const ClearDateFilterEvent());
    }
  }

  // Mở lịch dạng bottom sheet
  void _showCalendar() {
    // Lấy danh sách ngày đã chọn từ state hiện tại
    List<DateTime>? initialSelectedDates;
    if (_homeBloc.state is HomeScreenLoaded) {
      initialSelectedDates =
          (_homeBloc.state as HomeScreenLoaded).selectedDates;
    }

    CustomCalendarUpdate.show(
      context,
      onDatesSelected: _handleDateSelected,
      initialSelectedDates: initialSelectedDates,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomSearchTextField(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('searchHint'),
                          prefixIcon: const Icon(
                            Icons.menu,
                            size: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          height: 40,
                          width: double.infinity,
                          margin: EdgeInsets.zero,
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          onChanged: (query) {
                            // Xử lý tìm kiếm
                          },
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.black,
                        ),
                        iconSize: 24,
                        onPressed: () {
                          // Handle notifications
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: AppLocalizations.of(
                                context,
                              ).translate('selectChannel'),
                              options: state.availableChannels,
                              dropdownHeight: 40,
                              dropdownWidth: 400,
                              selectedValue: state.selectedChannel,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  log.log(
                                    'Channel changed from "${state.selectedChannel}" to "$newValue"',
                                  );

                                  _homeBloc.add(
                                    ChangeChannelEvent(channelName: newValue),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    if (state is HomeScreenLoaded &&
                        state.selectedDates != null &&
                        state.selectedDates!.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 8.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.selectedDates!.length > 1
                                      ? '${state.selectedDates!.length} ngày đã chọn'
                                      : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(state.selectedDates!.first),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _homeBloc.add(const ClearDateFilterEvent());
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    // log.log('Current state: $state');
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  const Color.fromARGB(
                                    255,
                                    105,
                                    96,
                                    96,
                                  ).withOpacity(0.5),
                                  BlendMode.darken,
                                ),
                                child: Image.asset(
                                  'assets/images/grass_bg.png',
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('totalBookings')
                                          .replaceAll(
                                            '{count}',
                                            state is HomeScreenLoaded
                                                ? state.totalOrders.toString()
                                                : '0',
                                          ),
                                      style: const TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('expectedRevenue')
                                          .replaceAll(
                                            '{amount}',
                                            state is HomeScreenLoaded
                                                ? state.totalSales
                                                    .toCurrency(context)
                                                    .replaceAll(' VND', '')
                                                : 0
                                                    .toCurrency(context)
                                                    .replaceAll(' VND', ''),
                                          ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (state is HomeScreenLoading)
                              const Center(child: CustomLoadingIndicator()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).translate('availableCourts'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.green,
                        ),
                        iconSize: 24,
                        onPressed: _showCalendar,
                        tooltip: AppLocalizations.of(
                          context,
                        ).translate('filter'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Hiển thị text thông báo không có sân nào thay vì danh sách courts
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate('noCourts'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const CustomFloatingActionButton(),
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
      ),
    );
  }
}
