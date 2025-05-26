import 'package:app_pickleball/screens/login_screen/View/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_button.dart'; // Import CustomElevatedButton
import 'package:app_pickleball/Screens/Widgets/custom_textfield.dart'; // Import CustomTextField
import 'package:app_pickleball/screens/widgets/text/custom_Text_tap.dart';

class RegisterScreen extends StatelessWidget {
  // Controller để lấy giá trị nhập từ các TextField
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text("Đăng Ký"),
        centerTitle: true, // Căn giữa tiêu đề
      ),
      body: SingleChildScrollView(
        // Thêm SingleChildScrollView để có thể cuộn
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Khoảng cách lề
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Căn giữa theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_app_tach_nen.png', // Đường dẫn tới ảnh logo
                  height: 100, // Chiều cao của logo
                ),
              ),
              SizedBox(height: 20),
              // Ô nhập Họ tên
              CustomTextField(
                labelText: "Họ tên",
                prefixIcon: Icons.person,
                controller: nameController,
              ),
              SizedBox(height: 16), // Khoảng cách giữa các ô nhập
              // Ô nhập Số điện thoại
              CustomTextField(
                labelText: "Số điện thoại",
                prefixIcon: Icons.phone,
                controller: phoneController,
              ),
              SizedBox(height: 16), // Khoảng cách giữa các ô nhập
              // Ô nhập Email
              CustomTextField(
                labelText: "Email",
                prefixIcon: Icons.email,
                controller: emailController,
              ),
              SizedBox(height: 16), // Khoảng cách giữa các ô nhập
              // Ô nhập Mật khẩu
              CustomTextField(
                labelText: "Mật khẩu",
                prefixIcon: Icons.lock,
                obscureText: true,
                controller: passwordController,
              ),
              SizedBox(height: 16),

              // Ô nhập Xác nhận mật khẩu
              CustomTextField(
                labelText: "Xác nhận mật khẩu",
                prefixIcon: Icons.lock,
                obscureText: true,
                controller: confirmPasswordController,
              ),
              SizedBox(height: 24),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity, // Nút rộng toàn bộ màn hình
                child: CustomElevatedButton(
                  text: 'Đăng Ký',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),
              Center(
                child: CustomText(
                  text: "Đã có tài khoản ? , Đăng nhập",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
