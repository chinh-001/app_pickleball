import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/search_screen/bloc/search_screen_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/services/repositories/customer_repository.dart';
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_contact_item.dart';
import 'dart:developer' as log;

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  final String? channelToken; // Làm cho channelToken có thể là null

  const SearchScreen({
    Key? key,
    this.initialQuery = '',
    this.channelToken, // Không đặt giá trị mặc định
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchScreenBloc _bloc;
  final CustomerRepository _customerRepository = CustomerRepository();
  final UserPermissionsRepository _permissionsRepository =
      UserPermissionsRepository();
  String? _channelToken;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _bloc = SearchScreenBloc(customerRepository: _customerRepository);
    _searchController.text = widget.initialQuery;

    // Add listener để cập nhật UI khi text thay đổi
    _searchController.addListener(() {
      setState(() {}); // Cập nhật UI để hiển thị/ẩn icon clear
      if (_isInitialized) {
        _performSearch(_searchController.text);
      }
    });

    // Lấy token từ các nguồn khác nhau
    _initializeChannelToken();
  }

  Future<void> _initializeChannelToken() async {
    try {
      // Ưu tiên sử dụng channel token được truyền vào
      if (widget.channelToken != null &&
          widget.channelToken!.isNotEmpty &&
          widget.channelToken != 'your_channel_token_here') {
        _channelToken = widget.channelToken;
        log.log('Sử dụng channelToken được truyền vào: $_channelToken');
      } else {
        // Lấy channel hiện tại từ ChannelSyncService
        final currentChannel = ChannelSyncService.instance.selectedChannel;
        log.log('Lấy channel từ ChannelSyncService: "$currentChannel"');

        if (currentChannel.isNotEmpty) {
          // Lấy token từ UserPermissionsRepository
          _channelToken = await _permissionsRepository.getChannelToken(
            currentChannel,
          );
          log.log('Đã lấy token từ channel: "$currentChannel"');
        } else {
          log.log('Không tìm thấy channel đã chọn');
          _channelToken = null;
        }
      }

      // Log thông tin token (đã ẩn một phần)
      if (_channelToken != null && _channelToken!.isNotEmpty) {
        String maskedToken = _channelToken!;
        if (_channelToken!.length > 10) {
          maskedToken =
              "${_channelToken!.substring(0, 5)}...${_channelToken!.substring(_channelToken!.length - 5)}";
        }
        log.log('Channel token đã lấy được: $maskedToken');

        // Tìm kiếm ban đầu nếu có query
        if (widget.initialQuery.isNotEmpty && widget.initialQuery.length >= 3) {
          _performSearch(widget.initialQuery);
        }
      } else {
        log.log('Không thể lấy channel token hợp lệ');

        // Hiển thị thông báo lỗi
        if (mounted) {
          _bloc.add(const ClearSearch());
          // Hiển thị thông báo lỗi mà không cần gửi event
        }
      }
    } catch (e) {
      log.log('Lỗi khi khởi tạo channel token: $e');
    } finally {
      _isInitialized = true;
    }
  }

  void _performSearch(String query) {
    try {
      // Kiểm tra xem có token hay không
      if (_channelToken == null || _channelToken!.isEmpty) {
        log.log('Không thể tìm kiếm: Thiếu channel token');
        return;
      }

      // Khi nhập văn bản, gửi sự kiện SearchCustomers để kích hoạt debounce trong bloc
      _bloc.add(SearchCustomers(query, channelToken: _channelToken!));

      // Log theo dõi
      if (query.isNotEmpty) {
        log.log('Gửi yêu cầu tìm kiếm: "$query"');
      }
    } catch (e) {
      log.log('Lỗi trong _performSearch: $e');
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      setState(() {});
    });
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<SearchScreenBloc, SearchScreenState>(
        builder: (context, state) {
          return Theme(
            // Ghi đè theme để loại bỏ các divider mặc định
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              dividerTheme: const DividerThemeData(
                color: Colors.transparent,
                space: 0,
                thickness: 0,
              ),
            ),
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              ).translate('searchCustomer'),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            // Không cần xử lý onChanged vì đã có listener trong initState
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _performSearch('');
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  actions: const [],
                ),
              ),
              body: Column(
                children: [
                  if (_channelToken == null && _isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('noChannelSelected'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child:
                        state is SearchResults
                            ? _buildSearchResults(state.results)
                            : state is SearchLoading
                            ? const Center(
                              child: CustomLoadingIndicator(size: 30.0),
                            )
                            : state is SearchErrorState
                            ? _buildErrorState(state.message)
                            : _buildEmptyState(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    if (results.isEmpty) {
      return _buildNoResultsFound();
    }

    log.log('Hiển thị ${results.length} kết quả tìm kiếm');

    // Sử dụng một container bao bọc để kiểm soát tốt hơn hiển thị
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header hiển thị số kết quả tìm thấy
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${results.length} ${AppLocalizations.of(context).translate('resultsFound')}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: results.length,
              // Loại bỏ padding mặc định
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final customer = results[index] as Customer;

                // Lấy chữ cái đầu của tên và họ để tạo avatar text
                final String avatarText = _getInitials(
                  customer.firstName,
                  customer.lastName,
                );

                return CustomContactItem(
                  avatarText: avatarText,
                  name: '${customer.firstName} ${customer.lastName}',
                  phone: customer.phoneNumber ?? '',
                  removeDivider: true,
                  onTap: () {
                    log.log(
                      'Đã chọn khách hàng: ${customer.firstName} ${customer.lastName}',
                    );
                    Navigator.pop(context, customer);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Hàm lấy chữ cái đầu tiên của tên và họ
  String _getInitials(String firstName, String lastName) {
    String initials = '';

    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }

    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }

    // Nếu không có chữ cái nào, trả về "?"
    return initials.isNotEmpty ? initials : '?';
  }

  Widget _buildErrorState(String message) {
    log.log('Hiển thị trạng thái lỗi: $message');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsFound() {
    log.log('Hiển thị không tìm thấy kết quả');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('noResultsFound'),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      // Trạng thái ban đầu
      log.log('Hiển thị trạng thái ban đầu');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('startSearching'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else if (_searchController.text.length < 3) {
      // Yêu cầu người dùng nhập thêm ký tự
      log.log('Hiển thị yêu cầu nhập thêm ký tự');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.text_fields, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('enterAtLeast3Chars'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      // Không có kết quả tìm kiếm
      return _buildNoResultsFound();
    }
  }
}
