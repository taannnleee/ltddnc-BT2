import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

import 'package:my_project2/register.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  // Hàm gọi API đăng nhập
  Future<void> onSignInPress() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });
      final response = await http.post(

        Uri.parse('${Config.apiUrl}/api/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      setState(() {
        loading = false;
      });
      int a = response.statusCode;
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        final tokens = data['data'];

        // Lưu JWT token
        await saveJwtToken(tokens['accesstoken'], tokens['refreshtoken']);

        // Điều hướng tới màn hình chính
        // Navigator.pushReplacementNamed(context, '/home');

        //hiện thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thành công")),
        );
      } else {
        // Xử lý lỗi đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thất bại")),
        );
      }
    }
  }

  // Hàm lưu JWT Token vào SecureStorage (hoặc một phương thức lưu token khác)
  Future<void> saveJwtToken(String accessToken, String refreshToken) async {
    // Implement logic to store tokens securely (e.g., using flutter_secure_storage)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  'https://scontent.fsgn2-9.fna.fbcdn.net/v/t39.30808-1/313872028_1714879798899320_5452127081679419373_n.jpg?stp=c0.10.941.940a_dst-jpg_s200x200&_nc_cat=103&ccb=1-7&_nc_sid=0ecb9b&_nc_ohc=0R6gk5FflWoQ7kNvgG1g4uI&_nc_zt=24&_nc_ht=scontent.fsgn2-9.fna&_nc_gid=A6LFp4idttvG_mY4NqTnSGI&oh=00_AYC0qN_u0Z8h0jSy0iq0DcIt99W2EeYqU_LwL8ALumNstw&oe=67313947',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    "Đăng nhập tài khoản của bạn",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      controller: _usernameController,
                      label: "Email",
                      placeholder: "Nhập email của bạn",
                      icon: Icons.email,
                      textInputAction: TextInputAction.next,
                    ),
                    InputField(
                      controller: _passwordController,
                      label: "Mật khẩu",
                      placeholder: "Nhập mật khẩu của bạn",
                      icon: Icons.lock,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    if (loading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: onSignInPress,
                        child: Text("Đăng nhập"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    OAuthWidget(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),  // Khởi tạo đối tượng RegisterPage()
                        );
                      },
                      child: Text(
                        "Bạn chưa có tài khoản? Đăng ký",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forget-password');
                      },
                      child: Text(
                        "Bạn quên mật khẩu? Quên mật khẩu",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputAction textInputAction;

  const InputField({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    required this.textInputAction,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }
}

class OAuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text("Đăng nhập với Google"),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text("Đăng nhập với Facebook"),
        ),
      ],
    );
  }
}
