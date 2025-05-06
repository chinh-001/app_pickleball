import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/order_detail_screen/bloc/order_detail_screen_bloc.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
// import 'dart:convert';
import 'dart:developer' as log;

class OrderDetailScreen extends StatefulWidget {
  final Map<String, String> item;

  const OrderDetailScreen({super.key, required this.item});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late List<String> typeOptions;
  late List<String> statusOptions;
  late List<String> paymentStatusOptions;

  late String selectedType;
  late String selectedPaymentStatus;
  late String selectedTime;
  late String selectedStatus;
  final TextEditingController noteController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Debug logging to verify received values
    log.log('\n=== ORDER DETAIL SCREEN RECEIVED DATA ===');
    log.log('Available keys: ${widget.item.keys.join(", ")}');
    log.log('Code value: "${widget.item['code']}"');
    log.log('NoteCustomer value: "${widget.item['noteCustomer']}"');

    // Initialize with empty lists - will be populated in didChangeDependencies
    typeOptions = [];
    statusOptions = [];
    paymentStatusOptions = [];

    // Store the original value to map to localized value later
    final originalType = widget.item['type'];
    selectedType = originalType ?? '';

    // Lấy giá trị status từ order list
    final originalStatus = widget.item['status'] ?? '';
    selectedStatus = originalStatus;

    final originalPaymentStatus = widget.item['paymentStatus'] ?? '';
    selectedPaymentStatus = originalPaymentStatus;

    selectedTime = widget.item['time'] ?? '';

    // Set the note controller with noteCustomer value
    noteController.text = widget.item['noteCustomer'] ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize options with localized strings - these are fixed UI elements that should be translated
    typeOptions = [
      AppLocalizations.of(context).translate('singleType'),
      AppLocalizations.of(context).translate('periodicType'),
    ];

    statusOptions = [
      AppLocalizations.of(context).translate('new'),
      AppLocalizations.of(context).translate('booked'),
    ];

    paymentStatusOptions = [
      AppLocalizations.of(context).translate('paid'),
      AppLocalizations.of(context).translate('unpaid'),
      AppLocalizations.of(context).translate('deposit'),
    ];

    // Only map the values on first initialization
    if (!_initialized) {
      // Map the original type value to localized value for dropdown display
      if (selectedType == 'Loại lẻ' || selectedType.isEmpty) {
        selectedType = AppLocalizations.of(context).translate('singleType');
      } else if (selectedType == 'Định kì') {
        selectedType = AppLocalizations.of(context).translate('periodicType');
      }

      // Map status
      if (selectedStatus == 'Mới' || selectedStatus.isEmpty) {
        selectedStatus = AppLocalizations.of(context).translate('new');
      } else if (selectedStatus == 'Đặt sân') {
        selectedStatus = AppLocalizations.of(context).translate('booked');
      }

      // Map payment status
      if (selectedPaymentStatus == 'Đã thanh toán' ||
          selectedPaymentStatus.isEmpty) {
        selectedPaymentStatus = AppLocalizations.of(context).translate('paid');
      } else if (selectedPaymentStatus == 'Chưa thanh toán') {
        selectedPaymentStatus = AppLocalizations.of(
          context,
        ).translate('unpaid');
      } else if (selectedPaymentStatus == 'Đặt cọc') {
        selectedPaymentStatus = AppLocalizations.of(
          context,
        ).translate('deposit');
      }

      _initialized = true;
    }
  }

  // Hàm định dạng tổng tiền với dấu phẩy phân cách hàng nghìn
  String formatTotalPrice(String price) {
    if (price.isEmpty) return '';

    try {
      // Chuyển chuỗi thành số và định dạng
      final priceNumber = int.tryParse(price.replaceAll(RegExp(r'[^\d]'), ''));
      if (priceNumber == null) return price;

      return priceNumber.toCommaSeparated();
    } catch (e) {
      print('Error formatting price: $e');
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the original values directly from widget.item without translation
    final TextEditingController customerNameController = TextEditingController(
      text: widget.item['customerName'],
    );
    final TextEditingController courtNameController = TextEditingController(
      text: widget.item['courtName'],
    );
    final TextEditingController phoneNumberController = TextEditingController(
      text: widget.item['phoneNumber'] ?? '',
    );
    final TextEditingController emailAddressController = TextEditingController(
      text: widget.item['emailAddress'] ?? '',
    );
    final TextEditingController codeController = TextEditingController(
      text: widget.item['code'] ?? '',
    );

    // Lấy giá trị tổng tiền và định dạng
    final rawTotalPrice = widget.item['total_price'] ?? '';
    final formattedTotalPrice = formatTotalPrice(rawTotalPrice);

    final TextEditingController totalPriceController = TextEditingController(
      text: formattedTotalPrice,
    );

    // Hiển thị thông tin log để debug
    print('DEBUG - OrderDetailScreen received item: ${widget.item}');
    print('DEBUG - Raw total price: $rawTotalPrice');
    print('DEBUG - Formatted total price: $formattedTotalPrice');
    print('DEBUG - Note: ${widget.item['noteCustomer']}');
    print('DEBUG - Code: ${widget.item['code']}');

    return BlocProvider(
      create: (_) => OrderDetailBloc(),
      child: Builder(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  // Translate fixed UI elements like headers
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
              body: BlocListener<OrderDetailBloc, OrderDetailState>(
                listener: (context, state) {
                  if (state is StatusUpdatedState) {
                    setState(() {
                      selectedStatus = state.status;
                    });
                  } else if (state is PaymentStatusUpdatedState) {
                    setState(() {
                      selectedPaymentStatus = state.paymentStatus;
                    });
                  } else if (state is TimeSelectedState) {
                    setState(() {
                      selectedTime = state.time;
                    });
                  }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Loại đặt sân dropdown
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: AppLocalizations.of(
                                context,
                              ).translate('bookingType'),
                              options: typeOptions,
                              selectedValue: selectedType,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    // Store the selected value as-is without translation
                                    selectedType = newValue;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Tên khách
                        buildInfoField(
                          AppLocalizations.of(
                            context,
                          ).translate('customerName'),
                          customerNameController,
                        ),
                        const SizedBox(height: 20),

                        // Số điện thoại
                        buildInfoField(
                          AppLocalizations.of(context).translate('phoneNumber'),
                          phoneNumberController,
                        ),
                        const SizedBox(height: 20),

                        // Email
                        buildInfoField('Email', emailAddressController),
                        const SizedBox(height: 20),

                        // Tên sân
                        buildInfoField(
                          AppLocalizations.of(context).translate('courtName'),
                          courtNameController,
                        ),
                        const SizedBox(height: 20),

                        // Mã đơn hàng (Code)
                        buildInfoField(
                          AppLocalizations.of(context).translate('orderCode'),
                          codeController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),

                        // Tổng tiền
                        buildPriceField(
                          AppLocalizations.of(context).translate('totalPrice'),
                          totalPriceController,
                        ),
                        const SizedBox(height: 20),

                        // Thời gian
                        buildInfoField(
                          AppLocalizations.of(context).translate('time'),
                          TextEditingController(text: selectedTime),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),

                        // Nút chọn thời gian
                        BlocListener<OrderDetailBloc, OrderDetailState>(
                          listener: (context, state) {
                            if (state is TimeSelectedState) {
                              setState(() {
                                selectedTime = state.time;
                              });
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              context.read<OrderDetailBloc>().add(
                                SelectTimeEvent(context),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('selectTime'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Trạng thái
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: AppLocalizations.of(
                                context,
                              ).translate('status'),
                              options: statusOptions,
                              dropdownHeight: 40,
                              dropdownWidth: 400,
                              selectedValue: selectedStatus,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  // Pass the value directly without translation
                                  context.read<OrderDetailBloc>().add(
                                    UpdateStatusEvent(newValue),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Trạng thái thanh toán
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: AppLocalizations.of(
                                context,
                              ).translate('paymentStatus'),
                              options: paymentStatusOptions,
                              dropdownHeight: 40,
                              dropdownWidth: 400,
                              selectedValue: selectedPaymentStatus,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  // Pass the value directly without translation
                                  context.read<OrderDetailBloc>().add(
                                    UpdatePaymentStatusEvent(newValue),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Ghi chú của khách hàng
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('notes'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('customerNotes'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nút Sửa
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Xử lý giá trị totalPrice để loại bỏ định dạng trước khi submit
                                String originalTotalPrice =
                                    totalPriceController.text
                                        .replaceAll(
                                          ',',
                                          '',
                                        ) // Loại bỏ dấu phẩy phân cách
                                        .trim(); // Xóa khoảng trắng thừa

                                // Map translated UI values back to original values for submission
                                String originalStatus = selectedStatus;
                                String originalPaymentStatus =
                                    selectedPaymentStatus;
                                String originalType = selectedType;

                                // Reverse mapping for type
                                if (selectedType ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('singleType')) {
                                  originalType = 'Loại lẻ';
                                } else if (selectedType ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('periodicType')) {
                                  originalType = 'Định kì';
                                }

                                // Reverse mapping for status
                                if (selectedStatus ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('new')) {
                                  originalStatus = 'Mới';
                                } else if (selectedStatus ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('booked')) {
                                  originalStatus = 'Đặt sân';
                                }

                                // Reverse mapping for payment status
                                if (selectedPaymentStatus ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('paid')) {
                                  originalPaymentStatus = 'Đã thanh toán';
                                } else if (selectedPaymentStatus ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('unpaid')) {
                                  originalPaymentStatus = 'Chưa thanh toán';
                                } else if (selectedPaymentStatus ==
                                    AppLocalizations.of(
                                      context,
                                    ).translate('deposit')) {
                                  originalPaymentStatus = 'Đặt cọc';
                                }

                                // Submit original, untranslated values
                                context.read<OrderDetailBloc>().add(
                                  SubmitOrderDetailEvent(
                                    customerName: customerNameController.text,
                                    courtName: courtNameController.text,
                                    time: selectedTime,
                                    status: originalStatus,
                                    paymentStatus: originalPaymentStatus,
                                    note: noteController.text,
                                    phoneNumber: phoneNumberController.text,
                                    emailAddress: emailAddressController.text,
                                    totalPrice: originalTotalPrice,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                // Translate the button text (fixed UI element)
                                AppLocalizations.of(
                                  context,
                                ).translate('modify'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget buildInfoField(
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
          ),
        ),
      ],
    );
  }

  Widget buildPriceField(String label, TextEditingController controller) {
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
          readOnly: false,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: 'VNĐ',
            suffixStyle: const TextStyle(fontSize: 16),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              controller.removeListener(() {});

              final cursorPos = controller.selection.start;

              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
              int? intValue = int.tryParse(cleanValue);

              if (intValue != null) {
                final formattedValue = intValue.toCommaSeparated();

                controller.text = formattedValue;

                final newValue = controller.text;
                final commasBeforeCursor =
                    ','
                        .allMatches(
                          newValue.substring(
                            0,
                            cursorPos > newValue.length
                                ? newValue.length
                                : cursorPos,
                          ),
                        )
                        .length;
                final commasInOldValueBeforeCursor =
                    ','.allMatches(value.substring(0, cursorPos)).length;

                final newCursorPos =
                    cursorPos +
                    (commasBeforeCursor - commasInOldValueBeforeCursor);

                if (newCursorPos >= 0 && newCursorPos <= newValue.length) {
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: newCursorPos),
                  );
                }
              }

              controller.addListener(() {});
            }
          },
        ),
      ],
    );
  }
}
