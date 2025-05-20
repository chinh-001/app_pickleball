import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/order_detail_screen/bloc/order_detail_screen_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'dart:developer' as log;

class OrderDetailScreen extends StatefulWidget {
  final Map<String, String> item;

  const OrderDetailScreen({super.key, required this.item});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Khai báo controllers
  final TextEditingController noteController = TextEditingController();
  final Map<String, TextEditingController> _formControllers = {};
  late final OrderDetailBloc _bloc;

  // Biến theo dõi trạng thái
  String _currentPrice = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo các controllers cho form
    _formControllers['customerName'] = TextEditingController(
      text: widget.item['customerName'],
    );
    _formControllers['courtName'] = TextEditingController(
      text: widget.item['courtName'],
    );
    _formControllers['phoneNumber'] = TextEditingController(
      text: widget.item['phoneNumber'] ?? '',
    );
    _formControllers['emailAddress'] = TextEditingController(
      text: widget.item['emailAddress'] ?? '',
    );
    _formControllers['price'] = TextEditingController();

    noteController.text = widget.item['noteCustomer'] ?? '';

    // Khởi tạo bloc mới và giữ lại tham chiếu
    _bloc = OrderDetailBloc();

    // Log để debugging
    log.log(
      'OrderDetailScreen - initState - Initializing with item: ${widget.item['code']}',
    );

    // Chỉ gửi sự kiện khởi tạo 1 lần trong initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _bloc.add(
          InitializeOrderDetailEvent(orderData: widget.item, context: context),
        );
        _isInitialized = true;
        log.log('OrderDetailScreen - Event sent for initialization');
      }
    });
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên khi widget bị hủy
    _formControllers.forEach((_, controller) => controller.dispose());
    noteController.dispose();
    _bloc.close();
    log.log('OrderDetailScreen - dispose - Resources cleaned up');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.log('OrderDetailScreen - build method called');

    return BlocProvider<OrderDetailBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context).translate('orderDetails'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
            listenWhen: (previous, current) {
              // Chỉ xử lý listener khi trạng thái thay đổi thực sự
              return current is PriceFormattedState ||
                  current is OrderDetailSuccess ||
                  current is SubmitValuesTranslatedState;
            },
            listener: (context, state) {
              if (state is PriceFormattedState) {
                _handlePriceFormatting(state);
              } else if (state is OrderDetailSuccess) {
                Navigator.pop(context);
              } else if (state is SubmitValuesTranslatedState) {
                _handleSubmit(context, state);
              }
            },
            buildWhen: (previous, current) {
              // Chỉ rebuild UI khi trạng thái dữ liệu thay đổi đáng kể
              return current is OrderDetailLoading ||
                  current is OrderDetailDataLoaded ||
                  current is OrderDetailFailure;
            },
            builder: (context, state) {
              if (state is OrderDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is OrderDetailFailure) {
                return Center(child: Text(state.error));
              } else if (state is OrderDetailDataLoaded) {
                // Cập nhật price controller với giá trị từ state
                if (_formControllers['price']?.text !=
                    state.formattedTotalPrice) {
                  _formControllers['price']?.text = state.formattedTotalPrice;
                }
                return _buildFormContent(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _handlePriceFormatting(PriceFormattedState state) {
    final priceController = _formControllers['price'];
    if (priceController == null) return;

    try {
      // Lưu vị trí con trỏ hiện tại
      final selection = priceController.selection;
      if (selection.baseOffset < 0) return;

      // Đếm số lượng dấu phẩy trước và sau khi định dạng
      final commasInOldValue = ','.allMatches(_currentPrice).length;
      final commasInNewValue = ','.allMatches(state.formattedPrice).length;

      // Cập nhật giá trị đã định dạng
      priceController.value = TextEditingValue(
        text: state.formattedPrice,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset + (commasInNewValue - commasInOldValue),
        ),
      );
    } catch (e) {
      // Xử lý trường hợp lỗi, chỉ cập nhật text
      priceController.text = state.formattedPrice;
      log.log('Error handling price formatting: $e');
    }
  }

  void _handleSubmit(BuildContext context, SubmitValuesTranslatedState state) {
    final String totalPrice =
        _formControllers['price']?.text.replaceAll(',', '').trim() ?? '';

    context.read<OrderDetailBloc>().add(
      SubmitOrderDetailEvent(
        customerName: _formControllers['customerName']?.text ?? '',
        courtName: _formControllers['courtName']?.text ?? '',
        time: state.timeToSubmit ?? '',
        status: state.status,
        paymentStatus: state.paymentStatus,
        note: noteController.text,
        phoneNumber: _formControllers['phoneNumber']?.text ?? '',
        emailAddress: _formControllers['emailAddress']?.text ?? '',
        totalPrice: totalPrice,
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, OrderDetailDataLoaded state) {
    final codeController = TextEditingController(
      text: widget.item['code'] ?? '',
    );
    final timeController = TextEditingController(text: state.selectedTime);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loại đặt sân dropdown
            CustomDropdown(
              title: AppLocalizations.of(context).translate('bookingType'),
              options: state.typeOptions,
              selectedValue: state.selectedType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<OrderDetailBloc>().add(
                    UpdateTypeEvent(newValue),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Tên khách hàng
            _buildTextField(
              AppLocalizations.of(context).translate('customerName'),
              _formControllers['customerName']!,
            ),
            const SizedBox(height: 20),

            // Số điện thoại
            _buildTextField(
              AppLocalizations.of(context).translate('phoneNumber'),
              _formControllers['phoneNumber']!,
            ),
            const SizedBox(height: 20),

            // Email
            _buildTextField('Email', _formControllers['emailAddress']!),
            const SizedBox(height: 20),

            // Tên sân
            _buildTextField(
              AppLocalizations.of(context).translate('courtName'),
              _formControllers['courtName']!,
            ),
            const SizedBox(height: 20),

            // Mã đơn hàng
            _buildTextField(
              AppLocalizations.of(context).translate('orderCode'),
              codeController,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            // Tổng tiền
            _buildPriceField(
              AppLocalizations.of(context).translate('totalPrice'),
              _formControllers['price']!,
            ),
            const SizedBox(height: 20),

            // Thời gian
            _buildTextField(
              AppLocalizations.of(context).translate('time'),
              timeController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            // Nút chọn thời gian
            _buildTimePickerButton(context),
            const SizedBox(height: 20),

            // Trạng thái đơn
            CustomDropdown(
              title: AppLocalizations.of(context).translate('status'),
              options: state.statusOptions,
              dropdownHeight: 40,
              dropdownWidth: 400,
              selectedValue: state.selectedStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<OrderDetailBloc>().add(
                    UpdateStatusEvent(newValue),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Trạng thái thanh toán
            CustomDropdown(
              title: AppLocalizations.of(context).translate('paymentStatus'),
              options: state.paymentStatusOptions,
              dropdownHeight: 40,
              dropdownWidth: 400,
              selectedValue: state.selectedPaymentStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<OrderDetailBloc>().add(
                    UpdatePaymentStatusEvent(newValue),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Ghi chú
            _buildNotesField(context),
            const SizedBox(height: 20),

            // Nút submit
            _buildSubmitButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: 'VNĐ',
            suffixStyle: const TextStyle(fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) return;

            // Lưu giá trị hiện tại để tính toán vị trí con trỏ sau
            _currentPrice = value;

            // Chỉ gửi sự kiện định dạng giá nếu có thay đổi
            context.read<OrderDetailBloc>().add(
              FormatPriceEvent(value, context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimePickerButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<OrderDetailBloc>().add(SelectTimeEvent(context));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppLocalizations.of(context).translate('selectTime'),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('notes'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: AppLocalizations.of(context).translate('customerNotes'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, OrderDetailDataLoaded state) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<OrderDetailBloc>().add(
              TranslateValuesForSubmitEvent(
                context: context,
                type: state.selectedType,
                status: state.selectedStatus,
                paymentStatus: state.selectedPaymentStatus,
                timeToSubmit: state.selectedTime,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppLocalizations.of(context).translate('modify'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
