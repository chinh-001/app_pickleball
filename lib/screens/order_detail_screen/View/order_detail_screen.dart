import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/Widgets/custom_search_text_field.dart';
import 'package:app_pickleball/screens/Widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/order_detail_screen/bloc/order_detail_screen_bloc.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, String> item;

  const OrderDetailScreen({super.key, required this.item});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String selectedStatus;
  late String selectedPaymentStatus;
  late String selectedTime;
  late String selectedType;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.item['status']!;
    selectedPaymentStatus = widget.item['paymentStatus']!;
    selectedTime = widget.item['time']!;
    selectedType = widget.item['type'] ?? 'Loại lẻ';
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
                        // Ảnh
                        Center(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<OrderDetailBloc>().add(
                                    PickImageEvent(),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: BlocBuilder<
                                    OrderDetailBloc,
                                    OrderDetailState
                                  >(
                                    builder: (context, state) {
                                      if (state is ImagePickedState) {
                                        return Image.file(
                                          state.image,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Image.asset(
                                        'assets/images/grass_bg.png',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Loại đặt sân
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedType == 'Định kỳ'
                                            ? Colors.green
                                            : Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    selectedType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Loại đặt sân dropdown
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: 'Loại đặt sân',
                              options: ['Loại lẻ', 'Định kỳ'],
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
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Text(
                                "Chọn thời gian",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Trạng thái đặt
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              title: 'Trạng thái đặt',
                              options: ['Đã đặt', 'Chưa đặt'],
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
                              options: ['Đã thanh toán', 'Chưa thanh toán'],
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
                        const SizedBox(height: 5),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
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
    String title,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        readOnly
            ? TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            )
            : CustomSearchTextField(
              controller: controller,
              height: 50,
              width: double.infinity,
              margin: EdgeInsets.zero,
              hintText: '',
              prefixIcon: null,
            ),
      ],
    );
  }
}
