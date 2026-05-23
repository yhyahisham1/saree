// lib/screens/auth/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:saree3_app/screens/agent/agent_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../agent/auth/agent_login_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  Future<void> _selectRole(String role) async {
    setState(() {
      _selectedRole = role;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);

    if (!mounted) return;

    // ✅ التعديل هنا:
    if (role == 'agent') {
      // التوجيه إلى صفحة تسجيل دخول الوكيل المنفصلة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgentLoginScreen()),
      );
    } else {
      // باقي الأدوار تذهب إلى LoginScreen العام
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(selectedRole: role)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pedal_bike,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'مرحباً بك في سريع',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر نوع الحساب للمتابعة',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 32),

              // صف أول
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.person_outline,
                      title: 'عميل عادي',
                      subtitle: 'طلب توصيل الطرود',
                      color: AppColors.primary,
                      role: 'customer',
                      isSelected: _selectedRole == 'customer',
                      onTap: () => _selectRole('customer'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.store_outlined,
                      title: 'صاحب متجر',
                      subtitle: 'إدارة الفروع والطلبات',
                      color: AppColors.secondary,
                      role: 'store_owner',
                      isSelected: _selectedRole == 'store_owner',
                      onTap: () => _selectRole('store_owner'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // صف ثاني
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.delivery_dining,
                      title: 'سائق',
                      subtitle: 'توصيل وكسب المال',
                      color: AppColors.tertiaryContainer,
                      role: 'driver',
                      isSelected: _selectedRole == 'driver',
                      onTap: () => _selectRole('driver'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.storefront,
                      title: 'وكيل محلي',
                      subtitle: 'استلام المدفوعات',
                      color: const Color(0xFF9C27B0),
                      role: 'agent',
                      isSelected: _selectedRole == 'agent',
                      onTap: () => _selectRole('agent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // صف ثالث
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.admin_panel_settings,
                      title: 'مدير النظام',
                      subtitle: 'إدارة المنصة',
                      color: const Color(0xFF1E88E5),
                      role: 'admin',
                      isSelected: _selectedRole == 'admin',
                      onTap: () => _selectRole('admin'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleCard(
                      icon: Icons.support_agent,
                      title: 'دعم فني',
                      subtitle: 'مساعدة العملاء',
                      color: const Color(0xFF00ACC1),
                      role: 'support',
                      isSelected: _selectedRole == 'support',
                      onTap: () => _selectRole('support'),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'يمكنك تغيير نوع الحساب لاحقاً من الإعدادات',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}