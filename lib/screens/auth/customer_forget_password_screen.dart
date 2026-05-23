// lib/screens/auth/customer_forget_password_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'customer_login_screen.dart';

class CustomerForgetPasswordScreen extends StatefulWidget {
  const CustomerForgetPasswordScreen({super.key});

  @override
  State<CustomerForgetPasswordScreen> createState() => _CustomerForgetPasswordScreenState();
}

class _CustomerForgetPasswordScreenState extends State<CustomerForgetPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _step = 1; // 1: phone, 2: otp, 3: new password
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال رقم الهاتف', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    setState(() => _step = 2);
    _showSnackBar('تم إرسال رمز التحقق إلى هاتفك');
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackBar('الرجاء إدخال رمز التحقق الصحيح', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    setState(() => _step = 3);
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty || _newPasswordController.text.length < 6) {
      _showSnackBar('كلمة المرور يجب أن تكون 6 أحرف على الأقل', isError: true);
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('كلمة المرور غير متطابقة', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    _showSnackBar('تم تغيير كلمة المرور بنجاح');
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة كلمة المرور'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            
            if (_step == 1) ...[
              const Text('أدخل رقم هاتفك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('سنرسل رمز تحقق إلى رقم هاتفك', style: TextStyle(color: AppColors.textGray)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إرسال رمز التحقق'),
                ),
              ),
            ],
            
            if (_step == 2) ...[
              const Text('أدخل رمز التحقق', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('تم إرسال رمز إلى ${_phoneController.text}', style: TextStyle(color: AppColors.textGray)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'رمز التحقق',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _sendOtp,
                child: Text('إعادة إرسال الرمز', style: TextStyle(color: AppColors.secondary)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تأكيد'),
                ),
              ),
            ],
            
            if (_step == 3) ...[
              const Text('كلمة مرور جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تغيير كلمة المرور'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}