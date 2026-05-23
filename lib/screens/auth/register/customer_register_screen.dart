// lib/screens/auth/register/customer_register_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../models/auth/register_model.dart';
import '../../../models/auth/user_model.dart';
import '../verification/receipt_upload_screen.dart';
import '../login_screen.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // State
  int _selectedPrepaidOrders = 10;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  
  // Packages
  final List<PrepaidPackage> _packages = [
    PrepaidPackage(orders: 5, price: 5, discount: 0, isPopular: false),
    PrepaidPackage(orders: 10, price: 9, discount: 10, isPopular: true),
    PrepaidPackage(orders: 20, price: 17, discount: 15, isPopular: false),
    PrepaidPackage(orders: 50, price: 40, discount: 20, isPopular: false),
  ];
  
  PrepaidPackage get _selectedPackage {
    return _packages.firstWhere((p) => p.orders == _selectedPrepaidOrders);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _neighborhoodController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showSnackBar('الرجاء الموافقة على الشروط والأحكام', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final registerData = RegisterModel(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      password: _passwordController.text,
      role: UserRole.customer,
    );

    final success = await authProvider.register(registerData);

    setState(() => _isLoading = false);

    if (success && authProvider.pendingUser != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptUploadScreen(
              pendingUserId: authProvider.pendingUser!.id,
              expectedAmount: _selectedPackage.price,
              prepaidOrders: _selectedPackage.orders,
            ),
          ),
        );
      }
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
        title: const Text('إنشاء حساب عميل'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  _buildNeighborhoodField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),
                  _buildPackagesSection(),
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 16),
                  _buildLoginLink(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            size: 35,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'حساب عميل جديد',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'أدخل بياناتك ثم قم بالدفع المسبق لتفعيل حسابك',
          style: TextStyle(color: AppColors.textGray, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textAlign: TextAlign.right,
      decoration: const InputDecoration(
        labelText: 'الاسم الكامل',
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'أحمد محمد',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'الرجاء إدخال الاسم الكامل';
        if (value.length < 3) return 'الاسم قصير جداً';
        return null;
      },
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'الرجاء إدخال رقم الهاتف';
        if (!AuthProvider.isValidPalestinianPhone(value)) {
          return 'رقم هاتف غير صحيح (يبدأ بـ 059، 056، 058، 057)';
        }
        return null;
      },
    );
  }

  Widget _buildNeighborhoodField() {
    return TextFormField(
      controller: _neighborhoodController,
      textAlign: TextAlign.right,
      decoration: const InputDecoration(
        labelText: 'الحي / المنطقة',
        prefixIcon: Icon(Icons.location_on_outlined),
        hintText: 'الرمال - شارع الوحدة',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'الرجاء إدخال الحي';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
        if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'الرجاء تأكيد كلمة المرور';
        if (value != _passwordController.text) return 'كلمة المرور غير متطابقة';
        return null;
      },
    );
  }

  Widget _buildPackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر عدد الطلبات المسبقة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'ادفع مرة واحدة وستُخصم قيمة كل طلب تلقائياً عند الاستلام',
          style: TextStyle(color: AppColors.textGray, fontSize: 12),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: _packages.length,
          itemBuilder: (context, index) {
            final pkg = _packages[index];
            final isSelected = _selectedPrepaidOrders == pkg.orders;
            return _buildPackageCard(pkg, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildPackageCard(PrepaidPackage pkg, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPrepaidOrders = pkg.orders),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${pkg.orders} طلب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pkg.discount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${pkg.orders} شيكل',
                            style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      Text(
                        '${pkg.price} شيكل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  if (pkg.discount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'خصم ${pkg.discount}%',
                        style: TextStyle(fontSize: 10, color: AppColors.success),
                      ),
                    ),
                ],
              ),
            ),
            if (pkg.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'الأفضل',
                    style: TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Text(
            'أوافق على الشروط والأحكام وسياسة الخصوصية',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final package = _selectedPackage;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          'إنشاء حساب ودفع ${package.price} شيكل',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟', style: TextStyle(color: AppColors.textGray)),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(selectedRole: 'customer'),
              ),
            );
          },
          child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

// Package model
class PrepaidPackage {
  final int orders;
  final int price;
  final int discount;
  final bool isPopular;

  PrepaidPackage({
    required this.orders,
    required this.price,
    required this.discount,
    this.isPopular = false,
  });
}