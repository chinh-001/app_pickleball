import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'orderlist_screen_event.dart';
part 'orderlist_screen_state.dart';

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final List<Map<String, String>> _allItems = [
    {
      "customerName": "Nguyen Van A",
      "courtName": "Sân 1",
      "time": "10:00 AM - 11:00 AM",
      "status": "Đã đặt",
      "paymentStatus": "Chưa thanh toán",
      "type": "Định kỳ", // Thêm trường này
    },
    {
      "customerName": "Tran Thi B",
      "courtName": "Sân 2",
      "time": "11:00 AM - 12:00 PM",
      "status": "Đã đặt",
      "paymentStatus": "Đã thanh toán",
      "type": "Loại lẻ", // Thêm trường này
    },
    {
      "customerName": "Tran Thi B",
      "courtName": "Sân 2",
      "time": "11:00 AM - 12:00 PM",
      "status": "Đã đặt",
      "paymentStatus": "Đã thanh toán",
      "type": "Loại lẻ", // Thêm trường này
    },
    {
      "customerName": "Le Van C",
      "courtName": "Sân 3",
      "time": "12:00 PM - 01:00 PM",
      "status": "Đã đặt",
      "paymentStatus": "Chưa thanh toán",
      "type": "Định kỳ", // Thêm trường này
    },
  ];

  OrderListBloc() : super(OrderListInitial()) {
    on<LoadOrderListEvent>(_onLoadOrderList);
    on<SearchOrderListEvent>(_onSearchOrderList);
  }

  void _onLoadOrderList(
    LoadOrderListEvent event,
    Emitter<OrderListState> emit,
  ) {
    emit(OrderListLoading());
    try {
      emit(OrderListLoaded(_allItems));
    } catch (e) {
      emit(OrderListError('Lỗi khi tải danh sách đặt sân: $e'));
    }
  }

 void _onSearchOrderList(
  SearchOrderListEvent event,
  Emitter<OrderListState> emit,
) {
  emit(OrderListLoading());
  try {
    final filteredItems = _allItems
        .where((item) =>
            item["customerName"]!.toLowerCase().contains(event.query.toLowerCase()) ||
            item["courtName"]!.toLowerCase().contains(event.query.toLowerCase()) ||
            item["type"]!.toLowerCase().contains(event.query.toLowerCase())) // Thêm tìm kiếm theo "type"
        .toList();
    emit(OrderListLoaded(filteredItems));
  } catch (e) {
    emit(OrderListError('Lỗi khi tìm kiếm: $e'));
  }
}
}
