import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/services/repositories/customer_repository.dart';
import 'package:app_pickleball/models/customer_model.dart';
import 'dart:developer' as log;

part 'search_screen_event.dart';
part 'search_screen_state.dart';

class SearchScreenBloc extends Bloc<SearchScreenEvent, SearchScreenState> {
  final CustomerRepository _customerRepository;
  Timer? _debounceTimer;
  String _lastQuery = '';

  SearchScreenBloc({required CustomerRepository customerRepository})
    : _customerRepository = customerRepository,
      super(SearchScreenInitial()) {
    on<ClearSearch>(_onClearSearch);
    on<SearchCustomers>(_onSearchCustomers);
    on<SearchItemsFound>(_onSearchItemsFound);
    on<ExecuteSearch>(_onExecuteSearch);
    on<SearchError>(_onSearchError);
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchScreenState> emit) {
    emit(SearchScreenInitial());
  }

  void _onSearchItemsFound(
    SearchItemsFound event,
    Emitter<SearchScreenState> emit,
  ) {
    emit(SearchResults(event.results));
  }

  void _onSearchCustomers(
    SearchCustomers event,
    Emitter<SearchScreenState> emit,
  ) async {
    // Hủy bỏ timer trước đó nếu có
    _debounceTimer?.cancel();

    try {
      if (event.query.isEmpty) {
        emit(SearchScreenInitial());
        _lastQuery = '';
        return;
      }

      // Chỉ tìm kiếm khi có ít nhất 3 ký tự
      if (event.query.length < 3) {
        emit(SearchScreenInitial());
        _lastQuery = event.query;
        return;
      }

      // Lưu trữ query hiện tại
      _lastQuery = event.query;

      // Hiển thị trạng thái đang tìm kiếm
      emit(SearchLoading());

      // Tạo debounce để không gọi tìm kiếm liên tục
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        // Add event mới để xử lý tìm kiếm thay vì gọi emit trực tiếp từ callback
        add(
          ExecuteSearch(query: event.query, channelToken: event.channelToken),
        );
      });
    } catch (error) {
      log.log('Lỗi khi xử lý tìm kiếm: $error');
      if (!emit.isDone) {
        emit(SearchErrorState('Đã xảy ra lỗi khi tìm kiếm khách hàng'));
      }
    }
  }

  Future<void> _onExecuteSearch(
    ExecuteSearch event,
    Emitter<SearchScreenState> emit,
  ) async {
    // Kiểm tra xem query có khớp với query cuối cùng không
    if (event.query != _lastQuery) return;

    log.log('Thực hiện tìm kiếm với từ khóa: "${event.query}"');

    try {
      if (event.channelToken.isEmpty ||
          event.channelToken == 'your_channel_token_here') {
        log.log('Lỗi: Channel token không hợp lệ: "${event.channelToken}"');
        emit(
          SearchErrorState(
            'Token kênh không hợp lệ. Vui lòng chọn kênh ở màn hình Home.',
          ),
        );
        return;
      }

      final CustomerResponse response = await _customerRepository.getCustomers(
        channelToken: event.channelToken,
        searchQuery: event.query,
      );

      // Log kết quả tìm kiếm
      log.log(
        'Kết quả tìm kiếm: ${response.items.length} khách hàng được tìm thấy',
      );

      if (response.items.isEmpty) {
        emit(const SearchResults([]));
      } else {
        emit(SearchResults(response.items));
      }
    } catch (error) {
      log.log('Lỗi khi tìm kiếm: $error');
      emit(SearchErrorState('Đã xảy ra lỗi khi tìm kiếm khách hàng'));

      // Sử dụng dữ liệu mẫu cho mục đích phát triển khi có lỗi
      _useDemoDataForDevelopment(event.query, emit);
    }
  }

  void _useDemoDataForDevelopment(
    String query,
    Emitter<SearchScreenState> emit,
  ) {
    // Tạo danh sách khách hàng mẫu
    final demoCustomers = [
      Customer(
        id: '1',
        firstName: 'Nguyen',
        lastName: 'Van A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phoneNumber: '0123456789',
        emailAddress: 'nguyenvana@example.com',
      ),
      Customer(
        id: '2',
        firstName: 'Tran',
        lastName: 'Thi B',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phoneNumber: '0987654321',
        emailAddress: 'tranthib@example.com',
      ),
    ];

    // Lọc danh sách dựa trên từ khóa tìm kiếm
    final filteredCustomers =
        demoCustomers.where((customer) {
          final fullName =
              '${customer.firstName} ${customer.lastName}'.toLowerCase();
          final phone = customer.phoneNumber?.toLowerCase() ?? '';
          final email = customer.emailAddress?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return fullName.contains(searchLower) ||
              phone.contains(searchLower) ||
              email.contains(searchLower);
        }).toList();

    // Cập nhật state qua bloc
    if (!emit.isDone) {
      emit(SearchResults(filteredCustomers));
    }
  }

  void _onSearchError(SearchError event, Emitter<SearchScreenState> emit) {
    emit(SearchErrorState(event.message));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
