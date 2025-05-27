import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_action_button.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/bloc/add_order_retail_step_2_screen_bloc.dart';
import 'package:app_pickleball/screens/complete_booking_screen/View/complete_booking_screen.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_step_circle.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_option_item.dart';
import 'package:app_pickleball/screens/widgets/cards/custom_options_container.dart';
import 'package:app_pickleball/screens/widgets/summary/custom_payment_summary.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'package:app_pickleball/screens/search_screen/View/search_screen.dart';
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/screens/widgets/indicators/custom_loading_indicator.dart';
import 'package:app_pickleball/screens/add_customer_screen/View/add_customer_screen.dart';
import 'package:app_pickleball/models/payment_methods_model.dart';

class AddOrderRetailStep2View extends StatefulWidget {
  final double totalPayment;

  const AddOrderRetailStep2View({super.key, this.totalPayment = 0.0});

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
  bool _showStepper = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _bloc = AddOrderRetailStep2ScreenBloc();

    _scrollController.addListener(_scrollListener);

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

  void _scrollListener() {
    if (_scrollController.position.pixels > _lastScrollOffset &&
        _scrollController.position.pixels > 10 &&
        _showStepper) {
      // Lướt xuống - ẩn thanh tiến trình
      setState(() {
        _showStepper = false;
      });
    } else if (_scrollController.position.pixels < _lastScrollOffset &&
        !_showStepper) {
      // Lướt lên - hiện thanh tiến trình
      setState(() {
        _showStepper = true;
      });
    }
    _lastScrollOffset = _scrollController.position.pixels;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
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
                _buildAnimatedStepper(context),
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

  // Animated Stepper
  Widget _buildAnimatedStepper(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showStepper ? null : 0,
      child: _showStepper ? _buildStepper(context) : const SizedBox(),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            CustomStepCircle(text: '1', isActive: false, isDone: true),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('courtInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            CustomStepCircle(text: '2', isActive: true, isDone: false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('customerInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            CustomStepCircle(text: '3', isActive: false, isDone: false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('completeBooking'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
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

        if (state.showAddCustomerForm) ...[
          const SizedBox(height: 16),
          _buildAddCustomerForm(context, state),
        ],
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

  Widget _buildAddCustomerForm(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    final salutationOptions = [
      AppLocalizations.of(context).translate('mr'),
      AppLocalizations.of(context).translate('ms'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      // Sử dụng ClipRRect để cắt nội dung nếu vượt quá
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('addCustomer'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _bloc.add(const HideAddCustomerForm());
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('salutation'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            state.selectedSalutation ?? salutationOptions.first,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items:
                            salutationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddOrderRetailStep2ScreenBloc>().add(
                              SalutationChanged(value),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: AppLocalizations.of(
                              context,
                            ).translate('firstName'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: AppLocalizations.of(
                              context,
                            ).translate('lastName'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).translate('email'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).translate('phoneNumber'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomActionButton(
                          text: AppLocalizations.of(
                            context,
                          ).translate('clearForm'),
                          onPressed: _resetForm,
                          isPrimary: false,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(
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
          AppLocalizations.of(context).translate('paymentMethod'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodOptions(context, state),
        const SizedBox(height: 20),
        _buildPaymentSummary(
          context,
          bookingPrice,
          serviceFee,
          discount,
          totalPayment,
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
            child: CircularProgressIndicator(strokeWidth: 2.0),
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

            // Trả về widget tùy chỉnh cho mỗi phương thức thanh toán
            return CustomOptionItem(
              icon: icon,
              title: paymentMethod.name,
              isSelected: state.paymentMethod == paymentMethod.name,
              iconColor: iconColor,
              onTap: () => _bloc.add(PaymentMethodChanged(paymentMethod.name)),
            );
          }).toList(),
    );
  }

  // Widget hiển thị tổng kết thanh toán
  Widget _buildPaymentSummary(
    BuildContext context,
    double bookingPrice,
    double serviceFee,
    double discount,
    double totalPayment,
  ) {
    return CustomPaymentSummary(
      bookingPrice: bookingPrice.toCurrency(context),
      serviceFee: serviceFee.toCurrency(context),
      discount: discount.toCurrency(context),
      totalPayment: totalPayment.toCurrency(context),
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
  ) {
    // Khởi tạo các giá trị
    final String name = '${state.firstName} ${state.lastName}'.trim();
    final String displayName = name.isEmpty ? 'Khách hàng' : name;
    final String email =
        state.email.isEmpty ? '0123456789@gmail.com' : state.email;
    final String phone = state.phone.isEmpty ? '0123456789' : state.phone;

    // Chuyển đến màn hình hoàn tất đặt sân
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CompleteBookingScreen(
              customerName: displayName,
              customerEmail: email,
              customerPhone: phone,
              bookingCode: 'TD/TD/D25050059',
              court: 'Demo 1',
              bookingTime: '08:00 - 09:30 (1.5h)',
              bookingDate: 'T7, 10/05/2025',
              price: '90,000VND',
            ),
      ),
    );
  }

  void _resetForm() {
    // Xóa tất cả dữ liệu form
    _lastNameController.clear();
    _firstNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _notesController.clear();

    // Gửi event reset form đến bloc
    _bloc.add(const ResetForm());
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
}
