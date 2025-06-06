import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/input/custom_search_text_field.dart';
import 'package:app_pickleball/screens/widgets/lists/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/widgets/lists/custom_order_listview.dart';
import 'package:app_pickleball/screens/widgets/input/custom_dropdown.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_floating_action_button.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_scroll_to_top_button.dart';
import 'package:app_pickleball/screens/orderlist_screen/bloc/orderlist_screen_bloc.dart';
import 'package:app_pickleball/screens/order_detail_screen/View/order_detail_screen.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/services/repositories/bookingList_repository.dart';
import 'package:app_pickleball/utils/auth_helper.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/calendar/custom_calendar_update.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';
import 'package:intl/intl.dart';
// import 'dart:convert';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key, required this.token});
  final String token;

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with AutomaticKeepAliveClientMixin {
  OrderListScreenBloc? _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _createBloc();
  }

  void _createBloc() {
    _bloc = OrderListScreenBloc(
      bookingListRepository: BookingListRepository(),
      permissionsRepository: UserPermissionsRepository(),
    );
    log.log('New OrderListScreenBloc created');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Close the bloc when the widget is disposed
    _bloc?.close();
    _scrollController.dispose();
    super.dispose();
  }

  // Xử lý khi người dùng chọn ngày từ lịch
  void _handleDateSelected(List<DateTime> dates) {
    if (dates.isNotEmpty) {
      // Gọi event để lọc dữ liệu
      _bloc?.add(FilterByDateRangeEvent(selectedDates: dates));

      log.log(
        'Đã chọn ${dates.length} ngày: ${dates.map((d) => DateFormat('dd/MM/yyyy').format(d)).join(", ")}',
      );
    } else {
      // Nếu không có ngày nào được chọn, xóa bộ lọc
      _bloc?.add(const ClearDateFilterEvent());
    }
  }

  // Mở lịch dạng bottom sheet
  void _showCalendar() {
    // Lấy danh sách ngày đã chọn từ state hiện tại
    List<DateTime>? initialSelectedDates;
    if (_bloc?.state is OrderListScreenLoaded) {
      initialSelectedDates =
          (_bloc?.state as OrderListScreenLoaded).selectedDates;
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

    // Check if we need to reset the bloc (user logged out and in again)
    if (AuthHelper.shouldResetBlocs()) {
      if (_bloc != null) {
        _bloc!.close();
        _bloc = null;
      }
      _createBloc();
      log.log('OrderListScreenBloc recreated after login/logout');
    }

    return BlocProvider.value(
      value: _bloc!,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomSearchTextField(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('searchHint'),
                          prefixIcon: const Icon(Icons.search),
                          height: 40,
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          onChanged: (query) {
                            context.read<OrderListScreenBloc>().add(
                              SearchOrderListEvent(query),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {
                        // Xử lý khi nhấn vào icon filter
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('bookingList'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                        size: 22,
                      ),
                      onPressed: _showCalendar,
                      tooltip: AppLocalizations.of(context).translate('filter'),
                    ),
                  ],
                ),
              ),
              BlocBuilder<OrderListScreenBloc, OrderListScreenState>(
                builder: (context, state) {
                  if (state is OrderListScreenLoaded &&
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
                                    ? '${state.selectedDates!.length} ${AppLocalizations.of(context).translate('daysSelected').replaceAll('{count}', '')}'
                                    : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(state.selectedDates!.first),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _bloc?.add(const ClearDateFilterEvent());
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
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppLocalizations.of(context).translate('selectChannel'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BlocBuilder<
                        OrderListScreenBloc,
                        OrderListScreenState
                      >(
                        builder: (context, state) {
                          return CustomDropdown(
                            titleFontSize: 12,
                            itemFontSize: 12,
                            title: '',
                            options: state.availableChannels,
                            selectedValue: state.selectedChannel,
                            dropdownHeight: 40,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                context.read<OrderListScreenBloc>().add(
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
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<OrderListScreenBloc, OrderListScreenState>(
                  builder: (context, state) {
                    if (state is OrderListScreenLoading) {
                      return const Center(child: CustomLoadingIndicator());
                    }

                    if (state is OrderListScreenError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state is OrderListScreenLoaded) {
                      if (state.items.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('noBookings'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return CustomOrderListView(
                        scrollController: _scrollController,
                        items: state.items,
                        onItemTap: (item) {
                          // Log the exact data being passed to OrderDetailScreen
                          log.log('\n=== PASSING TO ORDER DETAIL SCREEN ===');
                          log.log('Item keys: ${item.keys.join(", ")}');
                          log.log('Code value: "${item['code']}"');
                          log.log(
                            'NoteCustomer value: "${item['noteCustomer']}"',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderDetailScreen(item: item),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 80,
              right: 0,
              child: CustomScrollToTopButton(
                scrollController: _scrollController,
              ),
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: CustomFloatingActionButton(),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
      ),
    );
  }
}
