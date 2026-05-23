// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/auth/user_model.dart';
import 'register/customer_register_screen.dart';
import 'customer_forget_password_screen.dart';
import '../customer/home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../agent/agent_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../store_owner/store_owner_home_screen.dart';
import '../support/support_home_screen.dart';
import '../driver/driver_home_screen.dart';


class LoginScreen extends StatefulWidget {
  final String selectedRole;
  const LoginScreen({super.key, required this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _agentCodeController = TextEditingController();
  final _adminCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone');
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember && savedPhone != null) {
      setState(() {
        _phoneController.text = savedPhone;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_phone', _phoneController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_phone');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // تحقق خاص للوكيل والمدير
    if (widget.selectedRole == 'agent' && _agentCodeController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال كود الوكيل', isError: true);
      return;
    }
    if (widget.selectedRole == 'admin' && _adminCodeController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال كود المدير', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // محاولة تسجيل الدخول
    final success = await authProvider.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (success) {
      await _saveCredentials();
      
      // التحقق من أن الدور المختار يتوافق مع دور المستخدم الفعلي
      final user = authProvider.currentUser;
      if (user != null) {
        final String actualRole = _roleToString(user.role);
        if (actualRole != widget.selectedRole && widget.selectedRole != 'customer') {
          _showSnackBar('هذا الحساب ليس ${getRoleTitle()}، يرجى اختيار الدور الصحيح', isError: true);
          setState(() => _isLoading = false);
          return;
        }
      }
      
      // توجيه حسب الدور الفعلي للمستخدم
      Widget nextScreen = _getScreenForRole(user?.role ?? UserRole.customer);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(authProvider.errorMessage ?? 'فشل تسجيل الدخول', isError: true);
    }
  }

  Widget _getScreenForRole(UserRole role) {
    switch (role) {
      case UserRole.storeOwner:
        return const StoreOwnerHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.agent:
        return const AgentHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
      case UserRole.support:
        return const SupportHomeScreen();
      default:
        return const HomeScreen();
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.storeOwner: return 'store_owner';
      case UserRole.driver: return 'driver';
      case UserRole.agent: return 'agent';
      case UserRole.admin: return 'admin';
      case UserRole.support: return 'support';
      default: return 'customer';
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

  String getRoleTitle() {
    switch (widget.selectedRole) {
      case 'store_owner': return 'صاحب متجر';
      case 'driver': return 'سائق';
      case 'agent': return 'وكيل محلي';
      case 'admin': return 'مدير النظام';
      case 'support': return 'دعم فني';
      default: return 'عميل عادي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول - ${getRoleTitle()}'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pedal_bike, size: 45, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  getRoleTitle(),
                  style: TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 40),

                // رقم الهاتف (لجميع الأدوار)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '0591234567',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (!AuthProvider.isValidPalestinianPhone(value)) {
                      return 'رقم هاتف غير صحيح (يبدأ بـ 059، 056، 058، 057)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // كود الوكيل (يظهر فقط للوكيل)
                if (widget.selectedRole == 'agent') ...[
                  TextFormField(
                    controller: _agentCodeController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'كود الوكيل',
                      prefixIcon: Icon(Icons.qr_code),
                      hintText: 'AGT-001',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كود الوكيل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // كود المدير (يظهر فقط للمدير)
                if (widget.selectedRole == 'admin') ...[
                  TextFormField(
                    controller: _adminCodeController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'كود المدير',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      hintText: 'ADMIN-001',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كود المدير';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // خيارات إضافية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const Text('تذكرني', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerForgetPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(fontSize: 13, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('دخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // رابط إنشاء حساب (للعميل فقط)
                if (widget.selectedRole == 'customer') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ليس لديك حساب؟', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('إنشاء حساب', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}