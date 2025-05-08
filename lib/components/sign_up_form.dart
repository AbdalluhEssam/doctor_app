import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/main.dart';
import 'package:doctor_appointment_app/models/auth_model.dart';
import 'package:doctor_appointment_app/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/config.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Username', Icons.person_outlined),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter username' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email Address', Icons.email_outlined),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passController,
            obscureText: obsecurePass,
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
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter password' : null,
          ),
          const SizedBox(height: 24),
          Consumer<AuthModel>(builder: (context, auth, child) {
            return isLoading
                ? const CircularProgressIndicator()
                : Button(
                    width: double.infinity,
                    title: 'Sign Up',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => isLoading = true);
                      final registered = await DioProvider().registerUser(
                          _nameController.text,
                          _emailController.text,
                          _passController.text);
                      if (registered) {
                        final token = await DioProvider().getToken(
                            _emailController.text, _passController.text);
                        if (token) {
                          auth.loginSuccess({}, {});
                          MyApp.navigatorKey.currentState!.pushNamed('main');
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Registration failed. Try again.")));
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
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Config.primaryColor)),
    );
  }
}
