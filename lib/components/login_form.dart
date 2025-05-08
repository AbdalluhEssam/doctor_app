import 'dart:convert';

import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/main.dart';
import 'package:doctor_appointment_app/models/auth_model.dart';
import 'package:doctor_appointment_app/providers/dio_provider.dart';
// import 'package:doctor_appointment_app/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: _inputDecoration('Email Address', Icons.email_outlined),
            validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passController,
            obscureText: obsecurePass,
            cursorColor: Config.primaryColor,
            decoration: _inputDecoration(
              'Password',
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  obsecurePass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => obsecurePass = !obsecurePass),
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
          ),
          const SizedBox(height: 24),
          Consumer<AuthModel>(builder: (context, auth, child) {
            return isLoading
                ? const CircularProgressIndicator()
                : Button(
              width: double.infinity,
              title: 'Sign In',
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                setState(() => isLoading = true);
                final token = await DioProvider()
                    .getToken(_emailController.text, _passController.text);
                if (token) {
                  final prefs = await SharedPreferences.getInstance();
                  final tokenValue = prefs.getString('token') ?? '';
                  if (tokenValue.isNotEmpty) {
                    final response = await DioProvider().getUser(tokenValue);
                    if (response != null) {
                      final user = json.decode(response);
                      Map<String, dynamic> appointment = {};

                      for (var doctor in user['doctor']) {
                        if (doctor['appointments'] != null) {
                          appointment = doctor;
                        }
                      }

                      auth.loginSuccess(user, appointment);
                      MyApp.navigatorKey.currentState!.pushNamed('main');
                    }
                  }
                }
                setState(() => isLoading = false);
              },
              disable: false,
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Config.primaryColor),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Config.primaryColor)),
    );
  }
}