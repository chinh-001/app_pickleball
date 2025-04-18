import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/Widgets/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/Widgets/custom_order_listview.dart';
import 'package:app_pickleball/screens/Widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/orderlist_screen/bloc/orderlist_screen_bloc.dart';
import 'package:app_pickleball/screens/order_detail_screen/View/order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key, required this.token});
  final String token;

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderListScreenBloc()..add(LoadOrderListEvent()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomSearchTextField(
                          hintText: 'Tìm kiếm',
                          prefixIcon: const Icon(Icons.search),
                          height: 40,
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          onChanged: (query) {
                            context.read<OrderListScreenBloc>().add(
                              SearchOrderListEvent(query),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Danh sách đặt sân:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Chọn kênh:",
                        style: TextStyle(
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
                      return const Center(child: CircularProgressIndicator());
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
                        return const Center(
                          child: Text(
                            'Không có booking',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return CustomOrderListView(
                        items: state.items,
                        onItemTap: (item) {
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
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
      ),
    );
  }
}
