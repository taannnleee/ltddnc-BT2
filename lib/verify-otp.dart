import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String? password;

  const VerifyOtpPage({Key? key, required this.email, this.password}) : super(key: key);

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  bool loading = false;
  bool modalVisible = false;

  // Hàm gọi API để xác nhận OTP
  Future<void> verifyOtp(String email, String otp) async {
    try {
      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/auth/verifyOTP_register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success']) {
          if (widget.password != null) {
            await changePassword(widget.email, widget.password!);
          } else {
            Fluttertoast.showToast(msg: responseData['message']);
            Navigator.pushReplacementNamed(context, '/sign-in');
          }
        } else {
          Fluttertoast.showToast(msg: 'OTP không hợp lệ');
        }
      } else {
        Fluttertoast.showToast(msg: responseData['error'] ?? 'Đã xảy ra lỗi');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi kết nối');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Hàm thay đổi mật khẩu sau khi xác nhận OTP
  Future<void> changePassword(String email, String password) async {
    final url = 'http://192.168.1.46:8080/api/auth/change-password'; // API thay đổi mật khẩu
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        setState(() {
          modalVisible = true;
        });
      } else {
        Fluttertoast.showToast(msg: responseData['error'] ?? 'Không thể thay đổi mật khẩu');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi kết nối');
    }
  }

  // Hàm đóng modal và quay lại màn hình đăng nhập
  void closeModal() {
    setState(() {
      modalVisible = false;
    });
    Navigator.pushReplacementNamed(context, '/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xác nhận OTP'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=600', height: 250, width: double.infinity),
            SizedBox(height: 20),
            Text('Nhập mã OTP đã gửi vào email của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                hintText: 'Nhập OTP',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            if (loading)
              Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () {
                  if (_otpController.text.isNotEmpty) {
                    verifyOtp(widget.email, _otpController.text);
                  } else {
                    Fluttertoast.showToast(msg: 'Vui lòng nhập OTP');
                  }
                },
                child: Text('Xác nhận'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            SizedBox(height: 20),
            if (modalVisible)
              Dialog(
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/check.png', height: 110, width: 110),
                      SizedBox(height: 20),
                      Text('Verified', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('You have successfully verified your account.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: closeModal,
                        child: Text('OK'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
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
