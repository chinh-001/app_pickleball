import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/add_order_screen/bloc/add_order_screen_bloc.dart';

class AddOrderScreen extends StatelessWidget {
  const AddOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddOrderBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thêm Mới Thông Tin'),
        ),
        body: BlocListener<AddOrderBloc, AddOrderState>(
          listener: (context, state) {
            if (state is AddOrderSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo đơn hàng thành công!')),
              );
              Navigator.pop(context);
            } else if (state is AddOrderFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: BlocBuilder<AddOrderBloc, AddOrderState>(
            builder: (context, state) {
              final bloc = context.read<AddOrderBloc>();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh
                      Center(
                        child: GestureDetector(
                          onTap: () => bloc.add(AddOrderPickImageEvent()),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: state is AddOrderImagePicked
                                ? Image.file(
                                    state.image,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/grass_bg.png',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tên khách
                      buildInfoField('Tên khách', 'Nhập tên khách'),
                      const SizedBox(height: 20),

                      // Tên sân
                      buildInfoField('Tên sân', 'Nhập tên sân'),
                      const SizedBox(height: 20),

                      // Thời gian
                      buildInfoField(
                        'Thời gian',
                        state is AddOrderTimeSelected
                            ? state.time
                            : 'Chọn thời gian',
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),

                      // Nút chọn thời gian
                      GestureDetector(
                        onTap: () => bloc.add(AddOrderSelectTimeEvent(context)),
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
                      const SizedBox(height: 20),

                      // Trạng thái đặt
                      buildDropdown(
                        title: 'Trạng thái đặt',
                        options: ['Đã đặt', 'Chưa đặt'],
                        selectedValue: 'Đã đặt',
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 20),

                      // Phương thức thanh toán
                      buildDropdown(
                        title: 'Phương thức thanh toán',
                        options: ['Tiền mặt', 'Chuyển khoản'],
                        selectedValue: 'Tiền mặt',
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 20),

                      // Loại booking
                      buildDropdown(
                        title: 'Loại booking',
                        options: ['Loại lẻ', 'Định kỳ'],
                        selectedValue: 'Loại lẻ',
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 20),

                      // Ghi chú
                      const Text(
                        'Ghi chú',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Nhập ghi chú...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nút Tạo Mới
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => bloc.add(AddOrderSubmitEvent(
                              customerName: 'Tên khách',
                              courtName: 'Tên sân',
                              time: state is AddOrderTimeSelected
                                  ? state.time
                                  : '',
                              status: 'Đã đặt',
                              paymentMethod: 'Tiền mặt',
                              bookingType: 'Loại lẻ',
                              note: 'Ghi chú',
                              image: null,
                            )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Tạo Mới',
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildInfoField(String title, String hintText, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}