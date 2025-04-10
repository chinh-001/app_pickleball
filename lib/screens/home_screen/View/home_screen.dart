import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/Widgets/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/Widgets/custom_floating_action_button.dart';
import 'package:app_pickleball/screens/Widgets/custom_list_view.dart';
import 'package:app_pickleball/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:app_pickleball/services/repositories/booking_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              HomeScreenBloc(bookingRepository: BookingRepository())
                ..add(FetchOrdersEvent()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Logo và Icon Bell
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo_app_tach_nen.png',
                      height: 70,
                    ),
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
              // Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomSearchTextField(
                  hintText: 'Tìm kiếm',
                  prefixIcon: const Icon(Icons.search),
                  height: 40,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                ),
              ),
              const SizedBox(height: 20),
              // Khối thông tin
              Padding(
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
                            children: const [
                              Text(
                                'Số đơn hôm nay: 88',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tổng doanh số: 13499444',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
