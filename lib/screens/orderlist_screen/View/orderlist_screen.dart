import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/Widgets/custom_bottom_navigation_bar.dart';
import 'package:app_pickleball/screens/Widgets/custom_order_listview.dart';
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
      create: (_) => OrderListBloc()..add(LoadOrderListEvent()),
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
                            context
                                .read<OrderListBloc>()
                                .add(SearchOrderListEvent(query));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Danh sách đặt sân:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<OrderListBloc, OrderListState>(
                  builder: (context, state) {
                    if (state is OrderListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OrderListLoaded) {
                      return CustomOrderListView(
                        items: state.items, // Truyền dữ liệu bao gồm trường "type"
                        onItemTap: (item) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailScreen(item: item),
                            ),
                          );
                        },
                      );
                    } else if (state is OrderListError) {
                      return Center(child: Text(state.error));
                    }
                    return const Center(child: Text('Không có dữ liệu'));
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
