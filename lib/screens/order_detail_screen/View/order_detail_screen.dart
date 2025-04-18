import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/order_detail_screen/bloc/order_detail_screen_bloc.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, String> item;

  const OrderDetailScreen({super.key, required this.item});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const List<String> typeOptions = ['Loại lẻ', 'Định kỳ'];
  static const List<String> statusOptions = [
    'Đã xác nhận',
    'Đang chờ',
    'Đã hủy',
  ];
  static const List<String> paymentStatusOptions = [
    'Đã thanh toán',
    'Chưa thanh toán',
  ];

  late String selectedStatus;
  late String selectedPaymentStatus;
  late String selectedTime;
  late String selectedType;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Đảm bảo các giá trị khởi tạo nằm trong danh sách options
    selectedType =
        typeOptions.contains(widget.item['type'])
            ? widget.item['type']!
            : typeOptions.first;
    selectedStatus =
        statusOptions.contains(widget.item['status'])
            ? widget.item['status']!
            : statusOptions.first;
    selectedPaymentStatus =
        paymentStatusOptions.contains(widget.item['paymentStatus'])
            ? widget.item['paymentStatus']!
            : paymentStatusOptions.first;
    selectedTime = widget.item['time'] ?? '';
    noteController.text = widget.item['note'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController customerNameController = TextEditingController(
      text: widget.item['customerName'],
    );
    final TextEditingController courtNameController = TextEditingController(
      text: widget.item['courtName'],
    );

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
                title: const Text(
                  "Chi Tiết Đơn Hàng",
                  style: TextStyle(
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
                              title: 'Loại đặt sân',
                              options: typeOptions,
                              selectedValue: selectedType,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedType = newValue;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Tên khách
                        buildInfoField('Tên khách', customerNameController),
                        const SizedBox(height: 20),

                        // Tên sân
                        buildInfoField('Tên sân', courtNameController),
                        const SizedBox(height: 20),

                        // Thời gian
                        buildInfoField(
                          'Thời gian',
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
                              child: const Text(
                                'Chọn thời gian',
                                style: TextStyle(
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
                              title: 'Trạng thái',
                              options: statusOptions,
                              dropdownHeight: 40,
                              dropdownWidth: 400,
                              selectedValue: selectedStatus,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
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
                              title: 'Trạng thái thanh toán',
                              options: paymentStatusOptions,
                              dropdownHeight: 40,
                              dropdownWidth: 400,
                              selectedValue: selectedPaymentStatus,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  context.read<OrderDetailBloc>().add(
                                    UpdatePaymentStatusEvent(newValue),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Ghi chú
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nút Sửa
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<OrderDetailBloc>().add(
                                  SubmitOrderDetailEvent(
                                    customerName: customerNameController.text,
                                    courtName: courtNameController.text,
                                    time: selectedTime,
                                    status: selectedStatus,
                                    paymentStatus: selectedPaymentStatus,
                                    note: noteController.text,
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
                              child: const Text(
                                'Sửa',
                                style: TextStyle(
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
}
