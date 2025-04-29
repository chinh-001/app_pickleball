import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';
import 'package:app_pickleball/screens/register_screen.dart';
import 'package:app_pickleball/screens/widgets/custom_Text_tap.dart';
import 'package:app_pickleball/screens/widgets/custom_button.dart';
import 'package:app_pickleball/enum/CallApiStatus.dart';
import 'package:app_pickleball/services/repositories/auth_repository.dart';
import '../bloc/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authRepository: AuthRepository()),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == CallApiStatus.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state.status == CallApiStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng nhập không thành công')),
            );
          }
        },
        child: LoginWidget(),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image.asset(
                'assets/images/logo_app_tach_nen.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          state.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            TogglePasswordVisibility(),
                          );
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: !state.isPasswordVisible,
                  );
                },
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: CustomText(
                  text: 'Quên mật khẩu?',
                  onTap: () {
                    // Xử lý quên mật khẩu
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Đăng nhập',
                onPressed: () {
                  bloc.add(
                    LoginButtonPressed(
                      email: emailController.text,
                      password: passwordController.text,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomText(
                text: 'Chưa có tài khoản, đăng kí!',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
