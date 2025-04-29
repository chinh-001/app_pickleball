import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/widgets/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/widgets/custom_floating_action_button.dart';
import 'package:app_pickleball/screens/widgets/custom_list_view.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'dart:developer' as log;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  static HomeScreenBloc? _cachedBloc;

  HomeScreenBloc get _homeBloc {
    _cachedBloc ??= HomeScreenBloc(bookingRepository: BookingRepository())
      ..add(const FetchOrdersEvent(channelToken: 'demo-channel'));
    return _cachedBloc!;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Don't close the bloc here as it's cached
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: SafeArea(
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
                        hintText: 'Tìm kiếm',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
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
                child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    return CustomDropdown(
                      title: 'Chọn kênh :',
                      options: state.availableChannels,
                      dropdownHeight: 40,
                      dropdownWidth: 400,
                      selectedValue: state.selectedChannel,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          // log.log('\n+++++ HOME SCREEN: CHANNEL CHANGED +++++');
                          log.log(
                            'Channel changed from "${state.selectedChannel}" to "$newValue"',
                          );

                          _homeBloc.add(
                            ChangeChannelEvent(channelName: newValue),
                          );

                          // log.log(
                          //   '+++++ END HOME SCREEN CHANNEL CHANGE +++++\n',
                          // );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<HomeScreenBloc, HomeScreenState>(
                builder: (context, state) {
                  log.log('Current state: $state');
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
                                    'Tổng đặt chỗ: ${state is HomeScreenLoaded ? state.totalOrders : 0}',
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Doanh số kì vọng: ${state is HomeScreenLoaded ? state.totalSales.toInt().toCommaSeparated() : 0} VNĐ',
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
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Các sân có sẵn:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    if (state is HomeScreenLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is HomeScreenLoaded) {
                      return CustomListView(
                        items:
                            state.items.map((item) {
                              return {
                                'id': item['id'].toString(),
                                'name': item['name'].toString(),
                                'status': item['status'].toString(),
                                'price': item['price'].toString(),
                                'star': item['star'].toString(),
                              };
                            }).toList(),
                      );
                    } else if (state is HomeScreenError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text('Không có dữ liệu'));
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: const CustomFloatingActionButton(),
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
      ),
    );
  }
}
