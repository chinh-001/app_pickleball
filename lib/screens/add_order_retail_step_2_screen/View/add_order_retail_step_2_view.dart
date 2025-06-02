import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_action_button.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/bloc/add_order_retail_step_2_screen_bloc.dart';
import 'package:app_pickleball/screens/complete_booking_screen/View/complete_booking_screen.dart';
import 'package:app_pickleball/screens/complete_booking_screen/bloc/complete_booking_screen_bloc.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_option_item.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_options_container.dart';
import 'package:app_pickleball/screens/widgets/summary/custom_summary_row.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'package:app_pickleball/screens/search_screen/View/search_screen.dart';
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';
import 'package:app_pickleball/screens/add_customer_screen/View/add_customer_screen.dart';
import 'package:app_pickleball/models/payment_methods_model.dart';
import 'package:app_pickleball/models/payment_status_model.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_step_indicator.dart';
import 'dart:developer' as log;

class AddOrderRetailStep2View extends StatefulWidget {
  final double totalPayment;
  final String serviceName;
  final List<DateTime> selectedDates;
  final String fromTime;
  final String toTime;
  final double numberOfHours;
  final Map<String, List<String>> selectedCourtsByDate;
  final int courtCount;
  final Map<String, String> courtNamesById;
  final String? productId;

  const AddOrderRetailStep2View({
    super.key,
    this.totalPayment = 0.0,
    this.serviceName = '',
    this.selectedDates = const [],
    this.fromTime = '',
    this.toTime = '',
    this.numberOfHours = 0.0,
    this.selectedCourtsByDate = const {},
    this.courtCount = 1,
    this.courtNamesById = const {},
    this.productId,
  });

  @override
  State<AddOrderRetailStep2View> createState() =>
      _AddOrderRetailStep2ViewState();
}

class _AddOrderRetailStep2ViewState extends State<AddOrderRetailStep2View> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  late final AddOrderRetailStep2ScreenBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = AddOrderRetailStep2ScreenBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(InitializeForm(totalPayment: widget.totalPayment));

      // Listen for text field changes to update bloc state
      _lastNameController.addListener(() {
        _bloc.add(LastNameChanged(_lastNameController.text));
      });

      _firstNameController.addListener(() {
        _bloc.add(FirstNameChanged(_firstNameController.text));
      });

      _emailController.addListener(() {
        _bloc.add(EmailChanged(_emailController.text));
      });

      _phoneController.addListener(() {
        _bloc.add(PhoneChanged(_phoneController.text));
      });

      _notesController.addListener(() {
        _bloc.add(NotesChanged(_notesController.text));
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<
        AddOrderRetailStep2ScreenBloc,
        AddOrderRetailStep2ScreenState
      >(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sử dụng CustomStepIndicator thay vì _buildAnimatedStepper
                CustomStepIndicator(
                  currentStep: 2,
                  stepKeys: [
                    'courtInformation',
                    'customerInformation',
                    'completeBooking',
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSection(context, state),
                        const SizedBox(height: 24),
                        _buildPaymentMethodSection(context, state),
                        const SizedBox(height: 24),
                        _buildPaymentStatusSection(context, state),
                        const SizedBox(height: 24),
                        _buildPaymentDetailsSection(context, state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context),
          );
        },
      ),
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      title: Text(
        AppLocalizations.of(context).translate('addNew'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 1,
    );
  }

  Widget _buildCustomerSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    // Set initial values if available
    _updateControllerValuesFromState(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context).translate('customer')} *',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSearchBar(context),

        // Hiển thị thông báo nhập 3 ký tự
        if (state.searchQuery.isNotEmpty && state.searchQuery.length < 3)
          _buildMinimumCharsNotice(context),

        // Hiển thị kết quả tìm kiếm
        if (state.searchQuery.length >= 3 && state.searchResults.isNotEmpty)
          _buildSearchResults(context, state),

        // Hiển thị thông báo không tìm thấy kết quả
        if (state.searchQuery.length >= 3 &&
            !state.isSearching &&
            state.searchResults.isEmpty)
          _buildNoResultsFound(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSearchScreen(context),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _navigateToSearchScreen(context),
              child: const Icon(Icons.search, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context).translate('searchCustomer'),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Chuyển đến trang add_customer_screen thay vì hiển thị form
                _navigateToAddCustomerScreen(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add_circle, color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    if (state.searchQuery.isEmpty || state.searchResults.isEmpty)
      return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isSearching
                  ? AppLocalizations.of(context).translate('searching')
                  : '${state.searchResults.length} ${AppLocalizations.of(context).translate('resultsFound')}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final customer = state.searchResults[index] as Customer;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${customer.firstName} ${customer.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        customer.phoneNumber != null
                            ? Text(
                              customer.phoneNumber!,
                              style: const TextStyle(fontSize: 13),
                            )
                            : null,
                    onTap: () {
                      // Cập nhật thông tin khách hàng khi chọn
                      _lastNameController.text = customer.lastName;
                      _firstNameController.text = customer.firstName;
                      _emailController.text = customer.emailAddress ?? '';
                      _phoneController.text = customer.phoneNumber ?? '';

                      // Hiển thị form thông tin khách hàng
                      _bloc.add(const ShowAddCustomerForm());

                      // Clear search field and results
                      _searchController.clear();
                      context.read<AddOrderRetailStep2ScreenBloc>().add(
                        const SearchCustomers(''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateControllerValuesFromState(AddOrderRetailStep2ScreenState state) {
    if (state.lastName.isNotEmpty && _lastNameController.text.isEmpty) {
      _lastNameController.text = state.lastName;
    }

    if (state.firstName.isNotEmpty && _firstNameController.text.isEmpty) {
      _firstNameController.text = state.firstName;
    }

    if (state.email.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = state.email;
    }

    if (state.phone.isNotEmpty && _phoneController.text.isEmpty) {
      _phoneController.text = state.phone;
    }
  }

  Widget _buildMinimumCharsNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context).translate('enterAtLeast3Chars'),
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context).translate('noResultsFound'),
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('paymentMethod'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodOptions(context, state),
      ],
    );
  }

  // Widget hiển thị tổng kết thanh toán thành một phần riêng biệt
  Widget _buildPaymentDetailsSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    // Sử dụng extension CurrencyFormat để định dạng tiền tệ
    final bookingPrice = (state.totalPayment);
    final serviceFee = (state.totalPayment * 0);
    final discount = (state.totalPayment * 0);
    final totalPayment = (state.totalPayment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('paymentDetails'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần thông tin khách hàng
                  if (state.showAddCustomerForm) ...[
                    _buildCustomerInfoSection(context, state),
                    const Divider(height: 24),
                  ],

                  // Phần thông tin đặt sân
                  _buildCourtBookingInfoSection(context),
                  const Divider(height: 24),

                  // Phần thông tin thanh toán
                  CustomSummaryRow(
                    label: AppLocalizations.of(
                      context,
                    ).translate('bookingPrice'),
                    value: bookingPrice.toCurrency(context),
                  ),
                  const SizedBox(height: 8),
                  CustomSummaryRow(
                    label: AppLocalizations.of(context).translate('serviceFee'),
                    value: serviceFee.toCurrency(context),
                  ),
                  const SizedBox(height: 8),
                  CustomSummaryRow(
                    label: AppLocalizations.of(context).translate('discount'),
                    value: discount.toCurrency(context),
                    valueColor: Colors.red,
                  ),
                  const Divider(height: 24),
                  CustomSummaryRow(
                    label: AppLocalizations.of(
                      context,
                    ).translate('totalPayment'),
                    value: totalPayment.toCurrency(context),
                    isTotal: true,
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    final String customerName = '${state.firstName} ${state.lastName}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('customer'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // ID khách hàng (nếu có)
        if (state.customerId.isNotEmpty) ...[
          CustomSummaryRow(
            label: 'ID',
            value: state.customerId,
            valueColor: Colors.black,
          ),
          const SizedBox(height: 8),
        ],

        // Tên khách hàng
        CustomSummaryRow(
          label: AppLocalizations.of(context).translate('name'),
          value: customerName.isEmpty ? '---' : customerName,
          valueColor: Colors.black,
        ),
        const SizedBox(height: 8),

        // Email
        CustomSummaryRow(
          label: AppLocalizations.of(context).translate('email'),
          value: state.email.isEmpty ? '---' : state.email,
          valueColor: Colors.black,
        ),
        const SizedBox(height: 8),

        // Số điện thoại
        CustomSummaryRow(
          label: AppLocalizations.of(context).translate('phoneNumber'),
          value: state.phone.isEmpty ? '---' : state.phone,
          valueColor: Colors.black,
        ),
      ],
    );
  }

  // Widget hiển thị tùy chọn phương thức thanh toán
  Widget _buildPaymentMethodOptions(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    // Nếu đang tải dữ liệu, hiển thị loading indicator
    if (state.isLoadingPaymentMethods) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CustomLoadingIndicator(size: 30.0),
          ),
        ),
      );
    }

    // Nếu không có phương thức thanh toán nào, hiển thị thông báo
    if (state.paymentMethods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context).translate('noPaymentMethodsAvailable'),
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Render danh sách phương thức thanh toán từ API
    return CustomOptionsContainer(
      children:
          state.paymentMethods.map<Widget>((method) {
            final paymentMethod = method as PaymentMethod;

            // Xác định icon và màu sắc dựa trên mã và tên phương thức
            IconData icon;
            Color iconColor;

            // Xác định icon và màu sắc dựa trên thông tin phương thức
            switch (paymentMethod.code.toLowerCase()) {
              case 'cash':
              case 'tien-mat':
                icon = Icons.money;
                iconColor = Colors.green;
                break;
              case 'bank-transfer':
              case 'transfer':
              case 'chuyen-khoan':
                icon = Icons.account_balance;
                iconColor = const Color(0xFF1B7146);
                break;
              case 'momo':
              case 'zalopay':
              case 'vnpay':
                icon = Icons.account_balance_wallet;
                iconColor = const Color(0xFF0068FF);
                break;
              case 'visa':
              case 'mastercard':
              case 'credit-card':
              case 'the-tin-dung':
                icon = Icons.credit_card;
                iconColor = Colors.orange;
                break;
              default:
                // Fallback dựa vào tên nếu code không khớp với bất kỳ trường hợp nào
                final lowerName = paymentMethod.name.toLowerCase();
                if (lowerName.contains('cash') ||
                    lowerName.contains('tiền mặt')) {
                  icon = Icons.money;
                  iconColor = Colors.green;
                } else if (lowerName.contains('bank') ||
                    lowerName.contains('transfer') ||
                    lowerName.contains('chuyển khoản') ||
                    lowerName.contains('ngân hàng')) {
                  icon = Icons.account_balance;
                  iconColor = const Color(0xFF1B7146);
                } else if (lowerName.contains('wallet') ||
                    lowerName.contains('ví') ||
                    lowerName.contains('momo') ||
                    lowerName.contains('zalo')) {
                  icon = Icons.account_balance_wallet;
                  iconColor = const Color(0xFF0068FF);
                } else if (lowerName.contains('card') ||
                    lowerName.contains('thẻ') ||
                    lowerName.contains('visa') ||
                    lowerName.contains('master')) {
                  icon = Icons.credit_card;
                  iconColor = Colors.orange;
                } else {
                  // Nếu không có trường hợp nào khớp
                  icon = Icons.payment;
                  iconColor = Colors.blue;
                }
                break;
            }

            // Xác định tiêu đề hiển thị dựa trên id hoặc code
            String title;
            if (paymentMethod.id == '2') {
              // Nếu là Cash (id=2), sử dụng bản dịch
              title = AppLocalizations.of(context).translate('cash');
            } else if (paymentMethod.id == '4') {
              // Nếu là Transfer (id=4), sử dụng bản dịch
              title = AppLocalizations.of(context).translate('bankTransfer');
            } else {
              // Các trường hợp khác, sử dụng tên từ API
              title = paymentMethod.name;
            }

            // Trả về widget tùy chỉnh cho mỗi phương thức thanh toán
            return CustomOptionItem(
              icon: icon,
              title: title,
              isSelected: state.paymentMethod == paymentMethod.name,
              iconColor: iconColor,
              onTap: () => _bloc.add(PaymentMethodChanged(paymentMethod.name)),
            );
          }).toList(),
    );
  }

  Widget _buildPaymentStatusSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('paymentStatus'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPaymentStatusOptions(context, state),
      ],
    );
  }

  // Widget hiển thị tùy chọn trạng thái thanh toán
  Widget _buildPaymentStatusOptions(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    // Nếu đang tải dữ liệu, hiển thị loading indicator
    if (state.isLoadingPaymentStatus) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CustomLoadingIndicator(size: 30.0),
          ),
        ),
      );
    }

    // Nếu không có trạng thái thanh toán nào, sử dụng dữ liệu mặc định
    if (state.paymentStatusList.isEmpty) {
      return CustomOptionsContainer(
        children: [
          CustomOptionItem(
            icon: Icons.error_outline,
            title: AppLocalizations.of(context).translate('unpaid'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('unpaid'),
            iconColor: Colors.red,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('unpaid'),
                  ),
                ),
          ),
          CustomOptionItem(
            icon: Icons.check_circle_outline,
            title: AppLocalizations.of(context).translate('paid'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('paid'),
            iconColor: Colors.green,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('paid'),
                  ),
                ),
          ),
          CustomOptionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: AppLocalizations.of(context).translate('deposit'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('deposit'),
            iconColor: Colors.orange,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('deposit'),
                  ),
                ),
          ),
        ],
      );
    }

    // Lọc danh sách trạng thái thanh toán để loại bỏ các mục có id = '3', '5', hoặc '6'
    final filteredStatusList =
        state.paymentStatusList.where((status) {
          final paymentStatus = status as PaymentStatus;
          return paymentStatus.id != '3' &&
              paymentStatus.id != '5' &&
              paymentStatus.id != '6';
        }).toList();

    // Render danh sách trạng thái thanh toán từ API (đã lọc)
    return CustomOptionsContainer(
      children:
          filteredStatusList.map<Widget>((status) {
            final paymentStatus = status as PaymentStatus;

            // Xác định icon và màu sắc dựa trên code và tên
            IconData icon;
            Color iconColor;

            // Phân loại trạng thái thanh toán để chọn icon và màu phù hợp
            final lowerCode = paymentStatus.code.toLowerCase();
            final lowerName = paymentStatus.name.toLowerCase();

            if (lowerCode.contains('unpaid') ||
                lowerName.contains('chưa') ||
                lowerName.contains('unpaid')) {
              icon = Icons.error_outline;
              iconColor = Colors.red;
            } else if (lowerCode.contains('paid') ||
                lowerName.contains('đã') ||
                lowerName.contains('paid')) {
              icon = Icons.check_circle_outline;
              iconColor = Colors.green;
            } else if (lowerCode.contains('deposit') ||
                lowerName.contains('cọc') ||
                lowerName.contains('deposit')) {
              icon = Icons.account_balance_wallet_outlined;
              iconColor = Colors.orange;
            } else {
              // Trạng thái khác
              icon = Icons.help_outline;
              iconColor = Colors.blue;
            }

            // Xác định tiêu đề hiển thị dựa trên id
            String title;
            String statusNameForBloc; // Tên trạng thái sẽ được lưu vào bloc

            if (paymentStatus.id == '1') {
              // Nếu là Chưa thanh toán (id=1), sử dụng bản dịch
              title = AppLocalizations.of(context).translate('unpaid');
              statusNameForBloc = title;
            } else if (paymentStatus.id == '2') {
              // Nếu là Đã thanh toán (id=2), sử dụng bản dịch
              title = AppLocalizations.of(context).translate('paid');
              statusNameForBloc = title;
            } else if (paymentStatus.id == '4') {
              // Nếu là Đặt cọc (id=4), sử dụng bản dịch
              title = AppLocalizations.of(context).translate('deposit');
              statusNameForBloc = title;
            } else {
              // Các trường hợp khác, sử dụng tên từ API
              title = paymentStatus.name;
              statusNameForBloc = paymentStatus.name;
            }

            return CustomOptionItem(
              icon: icon,
              title: title,
              isSelected: state.paymentStatus == statusNameForBloc,
              iconColor: iconColor,
              onTap: () => _bloc.add(PaymentStatusChanged(statusNameForBloc)),
            );
          }).toList(),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomActionButton(
            text: AppLocalizations.of(context).translate('cancel'),
            onPressed: () {
              // Handle Cancel
              Navigator.of(context).pop();
            },
            isPrimary: false,
            fontSize: 13.0,
          ),
          const SizedBox(width: 12),
          BlocBuilder<
            AddOrderRetailStep2ScreenBloc,
            AddOrderRetailStep2ScreenState
          >(
            builder: (context, state) {
              bool areRequiredFieldsFilled = _areRequiredFieldsFilled(state);

              return CustomActionButton(
                text: AppLocalizations.of(context).translate('confirm'),
                onPressed: () => _navigateToCompleteBooking(context, state),
                isPrimary: true,
                isEnabled: areRequiredFieldsFilled,
                fontSize: 13.0,
              );
            },
          ),
        ],
      ),
    );
  }

  bool _areRequiredFieldsFilled(AddOrderRetailStep2ScreenState state) {
    return state.lastName.isNotEmpty && state.firstName.isNotEmpty;
  }

  void _navigateToCompleteBooking(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) async {
    // Khởi tạo các giá trị
    final String name = '${state.firstName} ${state.lastName}'.trim();
    final String displayName = name.isEmpty ? 'Khách hàng' : name;
    final String email =
        state.email.isEmpty ? '0123456789@gmail.com' : state.email;
    final String phone = state.phone.isEmpty ? '0123456789' : state.phone;

    // Hiển thị loading dialog
    _showLoadingDialog(context);

    try {
      // 1. Lấy start_time từ fromTime
      final String startTime = widget.fromTime;

      // 2. Lấy end_time từ toTime
      final String endTime = widget.toTime;

      // 3. status mặc định là "1" (được thiết lập trong BookingInput)

      // 4. Lấy customerId từ state (đã lưu khi chọn khách hàng)
      final String customerId = state.customerId;

      if (customerId.isEmpty) {
        log.log('Không tìm thấy ID khách hàng, không thể tạo booking');
        Navigator.pop(context); // Đóng loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('customerNotFound'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 5. booking_date từ selectedDates (đã chuyển đổi sang format chuỗi trong selectedCourtsByDate)
      final Map<String, List<String>> selectedCourtsByDate =
          widget.selectedCourtsByDate;
      if (selectedCourtsByDate.isEmpty) {
        log.log('Không có ngày đặt sân được chọn');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ngày đặt sân'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 6. total_price từ state.totalPayment
      final double totalPayment = state.totalPayment;

      // 7. Lấy productId từ widget.productId
      final String productId = widget.productId ?? '';
      if (productId.isEmpty) {
        log.log('Không có productId, không thể tạo booking');
        Navigator.pop(context); // Đóng loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('productNotFound'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 8. court IDs đã có trong selectedCourtsByDate

      // 9. Lấy paymentMethod từ state
      final String paymentMethodName = state.paymentMethod ?? '';

      // 10. Lấy paymentStatusId từ state.paymentStatusList
      String paymentStatusId = '';
      if (state.paymentStatusList.isNotEmpty) {
        for (final status in state.paymentStatusList) {
          if (status is PaymentStatus && status.name == state.paymentStatus) {
            paymentStatusId = status.id;
            break;
          }
        }
      }

      if (paymentMethodName.isEmpty || paymentStatusId.isEmpty) {
        log.log('Thiếu thông tin payment method hoặc payment status');
        Navigator.pop(context); // Đóng loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('paymentInfoMissing'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Sử dụng bloc để gọi createMultipleBookings
      final results = await _bloc.createMultipleBookings(
        customerId: customerId,
        productId: productId,
        selectedCourtsByDate: selectedCourtsByDate,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPayment,
        paymentMethodName: paymentMethodName,
        paymentStatusId: paymentStatusId,
      );

      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      if (results.isNotEmpty) {
        log.log('===== NHẬN DANH SÁCH KẾT QUẢ TỪ API =====');
        log.log('Số lượng booking: ${results.length}');

        // Tạo danh sách booking details để hiển thị trên màn hình complete
        final bookingDetails =
            results.map((result) {
              // Chỉ truyền giá trị số nguyên, không định dạng ở đây
              final String rawPrice = result.totalPrice.toString();

              return BookingDetail(
                court: result.court.name,
                bookingTime: '${result.startTime} - ${result.endTime}',
                bookingDate: result.bookingDate,
                price: rawPrice,
              );
            }).toList();

        // Chuyển đến màn hình hoàn tất đặt sân với danh sách các booking
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CompleteBookingScreen(
                    customerName: displayName,
                    customerEmail: email,
                    customerPhone: phone,
                    bookingCode: results.first.code,
                    bookingDetails: bookingDetails,
                    // Truyền giá trị nguyên, không định dạng
                    price: totalPayment.toString(),
                  ),
            ),
          );
        }
      } else {
        // Hiển thị thông báo lỗi nếu không có booking nào được tạo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('bookingFailed'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log.log('Lỗi khi tạo booking: $e');
      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).translate('bookingError')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSearchScreen(BuildContext context) async {
    // Lưu lại một tham chiếu đến AppLocalizations để sử dụng sau khi async
    final appLocalizations = AppLocalizations.of(context);

    // Show loading indicator
    _showLoadingDialog(context);

    // Lấy channel token từ bloc
    final String? channelToken = await _bloc.getChannelToken();

    // Kiểm tra xem context còn hợp lệ không
    if (!mounted) return;

    // Đóng hộp thoại loading
    Navigator.pop(context);

    if (channelToken == null || channelToken.isEmpty) {
      // Sử dụng appLocalizations đã lưu trữ thay vì context trực tiếp
      _showErrorSnackbar(
        context,
        appLocalizations.translate('noChannelSelected'),
      );
      return;
    }

    // Mở màn hình tìm kiếm với context hiện tại
    if (mounted) {
      _openSearchScreen(context, channelToken);
    }
  }

  // Hiển thị loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CustomLoadingIndicator(size: 30.0));
      },
    );
  }

  // Hiển thị thông báo lỗi khi không có token
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Mở màn hình tìm kiếm
  void _openSearchScreen(BuildContext context, String channelToken) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SearchScreen(
              initialQuery: _searchController.text,
              channelToken: channelToken,
            ),
      ),
    ).then(_handleSearchResult);
  }

  // Xử lý kết quả trả về từ màn hình tìm kiếm
  void _handleSearchResult(dynamic selectedCustomer) {
    if (selectedCustomer == null) return;

    if (selectedCustomer is Customer) {
      _lastNameController.text = selectedCustomer.lastName;
      _firstNameController.text = selectedCustomer.firstName;
      _emailController.text = selectedCustomer.emailAddress ?? '';
      _phoneController.text = selectedCustomer.phoneNumber ?? '';

      // Lưu ID của khách hàng
      _bloc.add(CustomerIdChanged(selectedCustomer.id));

      // Hiển thị form thông tin khách hàng
      _bloc.add(const ShowAddCustomerForm());
    } else {
      // Xử lý trường hợp nhận String từ phiên bản SearchScreen cũ
      _searchController.text = selectedCustomer.toString();
    }
  }

  void _navigateToAddCustomerScreen(BuildContext context) async {
    // Lấy thông tin state hiện tại
    final state = _bloc.state;

    // Tạo đối tượng Customer từ dữ liệu hiện tại (nếu có)
    Customer? currentCustomer;
    if (state.lastName.isNotEmpty || state.firstName.isNotEmpty) {
      currentCustomer = Customer(
        id: '', // Không có ID vì đây là khách hàng mới
        firstName: state.firstName,
        lastName: state.lastName,
        emailAddress: state.email,
        phoneNumber: state.phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddCustomerScreen(initialCustomer: currentCustomer),
      ),
    );

    // Nếu có customer trả về, cập nhật thông tin trong form
    if (customer != null) {
      _lastNameController.text = customer.lastName;
      _firstNameController.text = customer.firstName;
      _emailController.text = customer.emailAddress ?? '';
      _phoneController.text = customer.phoneNumber ?? '';

      // Cập nhật bloc
      _bloc.add(LastNameChanged(_lastNameController.text));
      _bloc.add(FirstNameChanged(_firstNameController.text));
      _bloc.add(EmailChanged(_emailController.text));
      _bloc.add(PhoneChanged(_phoneController.text));

      // Hiển thị form điền thông tin khách
      _bloc.add(const ShowAddCustomerForm());
    }
  }

  Widget _buildCourtBookingInfoSection(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // Nếu không có ngày nào được chọn
    if (widget.selectedDates.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sử dụng ExpandablePanel với hiệu ứng xoay icon
        ExpandablePanel(
          header: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppLocalizations.of(context).translate('courtInformation'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          collapsed: const SizedBox.shrink(), // Không hiển thị gì khi đóng
          expanded: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Hiển thị từng booking riêng biệt theo ngày
              ...widget.selectedDates.map((date) {
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final selectedCourts =
                    widget.selectedCourtsByDate[dateKey] ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị ngày
                      CustomSummaryRow(
                        label: AppLocalizations.of(
                          context,
                        ).translate('selectedDates'),
                        value: dateFormatter.format(date),
                        valueColor: Colors.black,
                        isTotal: true,
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Hiển thị tên dịch vụ
                      CustomSummaryRow(
                        label: AppLocalizations.of(
                          context,
                        ).translate('serviceName'),
                        value: widget.serviceName,
                        valueColor: Colors.black,
                      ),
                      const SizedBox(height: 8),

                      // Hiển thị thời gian
                      CustomSummaryRow(
                        label: AppLocalizations.of(context).translate('time'),
                        value: "${widget.fromTime} - ${widget.toTime}",
                        valueColor: Colors.black,
                      ),
                      const SizedBox(height: 8),

                      // Hiển thị số giờ
                      CustomSummaryRow(
                        label: AppLocalizations.of(context).translate('hours'),
                        value: "${widget.numberOfHours}",
                        valueColor: Colors.black,
                      ),
                      const SizedBox(height: 8),

                      // Hiển thị số lượng sân
                      CustomSummaryRow(
                        label: AppLocalizations.of(
                          context,
                        ).translate('courtCount'),
                        value: widget.courtCount.toString(),
                        valueColor: Colors.black,
                      ),
                      const SizedBox(height: 8),

                      // Hiển thị sân đã chọn
                      CustomSummaryRow(
                        label: AppLocalizations.of(context).translate('court'),
                        value:
                            selectedCourts.isEmpty
                                ? AppLocalizations.of(
                                  context,
                                ).translate('noCourt')
                                : selectedCourts
                                    .map(
                                      (courtId) =>
                                          widget.courtNamesById[courtId] ??
                                          courtId,
                                    )
                                    .join(", "),
                        valueColor: Colors.black,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            tapBodyToExpand: true,
            tapBodyToCollapse: true,
            hasIcon: true,
            iconSize: 24.0,
            iconColor: Colors.black, // Đổi màu icon thành đen
            iconRotationAngle:
                3.14159, // Pi radians (180 degrees) cho hiệu ứng xoay
            iconPadding: EdgeInsets.only(right: 8),
            // Luôn sử dụng cùng một icon (mũi tên xuống)
            expandIcon: Icons.keyboard_arrow_down,
            collapseIcon: Icons.keyboard_arrow_down,
          ),
        ),
      ],
    );
  }
}
