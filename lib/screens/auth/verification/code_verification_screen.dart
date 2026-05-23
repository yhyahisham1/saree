// lib/screens/auth/verification/code_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../customer/home_screen.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({super.key});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // محاولة جلب رقم الهاتف من المستخدم المعلق
    _loadPhoneFromPendingUser();
  }

  void _loadPhoneFromPendingUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.pendingUser != null) {
      _phoneController.text = authProvider.pendingUser!.phone;
    }
  }

  Future<void> _verifyCode() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty) {
      _showSnackBar('الرجاء إدخال رقم الهاتف', isError: true);
      return;
    }

    if (code.length != 6) {
      _showSnackBar('كود التفعيل مكون من 6 أرقام', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.activateWithAgentCode(phone, code);

    setState(() => _isLoading = false);

    if (success && mounted) {
      // الانتقال إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (authProvider.errorMessage != null && mounted) {
      _showSnackBar(authProvider.errorMessage!, isError: true);
    }
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
        title: const Text('تفعيل الحساب'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // العودة إلى شاشة تسجيل الدخول
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildCodeField(),
            const SizedBox(height: 32),
            _buildVerifyButton(),
            const SizedBox(height: 16),
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.qr_code, size: 45, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          'أدخل كود التفعيل',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'قم بشراء كود التفعيل من أي وكيل محلي معتمد',
          style: TextStyle(color: AppColors.textGray, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.right,
      decoration: const InputDecoration(
        labelText: 'رقم الهاتف',
        prefixIcon: Icon(Icons.phone_outlined),
        hintText: '0591234567',
      ),
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'كود التفعيل',
        hintText: '______',
        counterText: '',
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('تفعيل الحساب', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildHelpText() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () {
            // عرض معلومات عن الوكلاء
            _showAgentsInfo();
          },
          icon: const Icon(Icons.help_outline, size: 18),
          label: const Text('كيف أحصل على كود التفعيل؟', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 8),
        Text(
          'إذا لم يكن لديك كود، يمكنك الدفع نقداً لدى أي وكيل معتمد',
          style: TextStyle(fontSize: 11, color: AppColors.textLight),
        ),
      ],
    );
  }

  void _showAgentsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الوكلاء المعتمدين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('يمكنك الحصول على كود التفعيل من:'),
            const SizedBox(height: 12),
            _buildAgentItem('بقالة السلام', 'الرمال - شارع الوحدة', '0591234567'),
            const Divider(),
            _buildAgentItem('صيدلية الشفاء', 'المنطقة الغربية', '0597654321'),
            const Divider(),
            _buildAgentItem('مكتبة الأندلس', 'حي الزيتون', '0591122334'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentItem(String name, String address, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(address, style: const TextStyle(fontSize: 12)),
          Text(phone, style: TextStyle(fontSize: 11, color: AppColors.primary)),
        ],
      ),
    );
  }
}