// lib/screens/agent/agent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الوكيل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات الوكيل
            Card(
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.storefront,
                    label: 'اسم المحل',
                    value: user?.storeName ?? 'بقالة السلام',
                    onTap: () => _showEditDialog(context, 'اسم المحل', user?.storeName ?? ''),
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.qr_code,
                    label: 'كود الوكيل',
                    value: user?.agentCode ?? 'AGT-001',
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.phone,
                    label: 'رقم الهاتف',
                    value: user?.phone ?? '0591234567',
                    onTap: () => _showEditDialog(context, 'رقم الهاتف', user?.phone ?? ''),
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.location_on,
                    label: 'العنوان',
                    value: user?.neighborhood ?? 'الرمال - شارع الوحدة',
                    onTap: () => _showEditDialog(context, 'العنوان', user?.neighborhood ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // إحصائيات الوكيل
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'إجمالي التحصيلات',
                    value: '1,250',
                    unit: 'شيكل',
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'عمولتك المستحقة',
                    value: '87.5',
                    unit: 'شيكل',
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authProvider.logout();
                    if (context.mounted) {
                      // تمرير الدور المطلوب - افتراضي عميل
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(selectedRole: 'customer'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: AppColors.textGray)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 18, color: AppColors.textGray),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $field'),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'أدخل $field الجديد',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم التعديل بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}