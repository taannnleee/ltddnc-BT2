import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project2/login.dart';
import 'package:my_project2/verify-otp.dart';

final _storage = FlutterSecureStorage();

// Cấu hình API URL

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool loading = false;

  // Hàm lưu JWT token vào secure storage
  Future<void> saveJwtToken(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // Hàm lấy access token từ secure storage
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // Hàm gọi API đăng ký
  Future<void> onRegisterPress() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'confirmPassword': _confirmPasswordController.text,
        }),
      );
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = data['data'];  // Giả sử API trả về dạng { "data": { "accesstoken": "", "refreshtoken": "" }}

        // Lưu accessToken và refreshToken vào FlutterSecureStorage
        // await saveJwtToken(tokens['accesstoken'], tokens['refreshtoken']);

        // Thành công, điều hướng đến màn hình OTP

        // Navigator.pushReplacementNamed(context, '/verify-otp', arguments: {
        //   'email': _emailController.text,
        //   'password': _passwordController.text,
        // });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyOtpPage(email: _emailController.text, password: _passwordController.text,)),
        );
      } else {
        // Xử lý lỗi đăng ký
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thất bại")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký tài khoản'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputField(
                  controller: _usernameController,
                  label: "Tên đăng nhập",
                  placeholder: "Nhập tên đăng nhập của bạn",
                  icon: Icons.person,
                  textInputAction: TextInputAction.next,
                ),
                InputField(
                  controller: _fullNameController,
                  label: "Tên đầy đủ",
                  placeholder: "Nhập tên đầy đủ của bạn",
                  icon: Icons.person,
                  textInputAction: TextInputAction.next,
                ),
                InputField(
                  controller: _emailController,
                  label: "Email",
                  placeholder: "Nhập email của bạn",
                  icon: Icons.email,
                  textInputAction: TextInputAction.next,
                ),
                InputField(
                  controller: _phoneController,
                  label: "Số điện thoại",
                  placeholder: "Nhập số điện thoại của bạn",
                  icon: Icons.phone,
                  textInputAction: TextInputAction.next,
                ),
                InputField(
                  controller: _passwordController,
                  label: "Mật khẩu",
                  placeholder: "Nhập mật khẩu của bạn",
                  icon: Icons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                InputField(
                  controller: _confirmPasswordController,
                  label: "Xác nhận mật khẩu",
                  placeholder: "Nhập lại mật khẩu của bạn",
                  icon: Icons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                if (loading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: onRegisterPress,
                    child: Text("Đăng ký"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Đã có tài khoản? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/sign-in');
                      },
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Input field widget
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const InputField({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    required this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        textInputAction: textInputAction,
        validator: validator ??
                (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập $label';
              }
              return null;
            },
      ),
    );
  }
}
