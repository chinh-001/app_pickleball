import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/Widgets/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/Widgets/custom_floating_action_button.dart';
import 'package:app_pickleball/screens/Widgets/custom_list_view.dart';
import 'package:app_pickleball/screens/Widgets/custom_dropdown.dart'; // Import CustomDropdown
import 'package:app_pickleball/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedChannel = 'Default channel'; // Giá trị mặc định
  final List<String> channels = [
    'Default channel',
    'Pikachu Pickleball Xuân Hoà',
    'Demo-channel',
    'Stamina 106 Hoàng Quốc Việt',
    'TADA Sport CN1 - Thanh Đa',
    'TADA Sport CN2 - Bình Lợi',
    'TADA Sport CN3 - D2(Ung Văn Khiêm)',
  ];

  late HomeScreenBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeScreenBloc(bookingRepository: BookingRepository());
    _homeBloc.add(FetchOrdersEvent(channelToken: 'demo-channel'));
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Logo, Icon Bell và Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo_app_tach_nen.png',
                      height: 60,
                      width: 60,
                    ),
                    // Thanh tìm kiếm
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomSearchTextField(
                          hintText: 'Tìm kiếm',
                          prefixIcon: const Icon(
                            Icons.search,
                          ), // Thêm tham số prefixIcon
                          height: 45, // Thêm chiều cao
                          width: double.infinity, // Thêm chiều rộng
                          margin: const EdgeInsets.fromLTRB(
                            5,
                            5,
                            5,
                            0,
                          ), // Thêm margin
                          onChanged: (query) {
                            // Xử lý tìm kiếm
                          },
                        ),
                      ),
                    ),
                    // Icon Bell
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        // Handle notifications
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // CustomDropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    return CustomDropdown(
                      title: 'Chọn kênh :',
                      options: channels,
                      selectedValue: selectedChannel,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedChannel = newValue;
                          });

                          // Xác định giá trị token dựa trên kênh đã chọn
                          String channelToken;
                          if (newValue == 'Demo-channel') {
                            channelToken = 'demo-channel';
                          } else if (newValue ==
                              'Pikachu Pickleball Xuân Hoà') {
                            channelToken = 'pikachu';
                          } else {
                            channelToken = 'demo-channel'; // Mặc định
                          }

                          print('Selected channel: $newValue');
                          print('Using channel token: $channelToken');

                          // Kích hoạt sự kiện để lấy dữ liệu mới với token đã chọn
                          context.read<HomeScreenBloc>().add(
                            FetchOrdersEvent(channelToken: channelToken),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Khối thông tin
              BlocBuilder<HomeScreenBloc, HomeScreenState>(
                builder: (context, state) {
                  print('Current state: $state');
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
                                    'Doanh số kì vọng: ${state is HomeScreenLoaded ? state.totalSales.toStringAsFixed(0) : 0} VNĐ',
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
              // Tiêu đề danh sách sân
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Các sân có sẵn:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Danh sách sân
              Expanded(
                child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                  builder: (context, state) {
                    if (state is HomeScreenLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is HomeScreenLoaded) {
                      return CustomListView(
                        items:
                            state.items
                                .map((item) => Map<String, String>.from(item))
                                .toList(),
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
