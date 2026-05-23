// lib/screens/auth/register/shared/register_widgets.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// حقل إدخال موحد
class CustomRegisterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final String? hintText;

  const CustomRegisterField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

// زر التسجيل
class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const RegisterButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('إنشاء حساب', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// خيار تسجيل الدخول
class LoginOption extends StatelessWidget {
  final VoidCallback onTap;

  const LoginOption({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('لديك حساب بالفعل؟'),
        TextButton(
          onPressed: onTap,
          child: const Text('تسجيل الدخول'),
        ),
      ],
    );
  }
}