// lib/screens/agent/agent_reports_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AgentReportsScreen extends StatelessWidget {
  const AgentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقاريري المالية'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ملخص العمولات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'العمولة المستحقة',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '87.5 شيكل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('طلب تسوية مالية'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // إحصائيات
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  title: 'إجمالي التحصيلات',
                  value: '1,250',
                  unit: 'شيكل',
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportCard(
                  title: 'عدد المعاملات',
                  value: '24',
                  unit: 'عملية',
                  icon: Icons.receipt_long,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // رسم بياني بسيط
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التحصيلات آخر 7 أيام',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChartBar(120, 'السبت'),
                      _buildChartBar(80, 'الأحد'),
                      _buildChartBar(150, 'الإثنين'),
                      _buildChartBar(200, 'الثلاثاء'),
                      _buildChartBar(170, 'الأربعاء'),
                      _buildChartBar(90, 'الخميس'),
                      _buildChartBar(60, 'الجمعة'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // جدول المعاملات
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'سجل المعاملات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                _buildTransactionRow('21/5/2025', 'أحمد محمد', '50 شيكل', 'مكتمل'),
                _buildTransactionRow('20/5/2025', 'سارة خالد', '20 شيكل', 'مكتمل'),
                _buildTransactionRow('19/5/2025', 'محمد علي', '10 شيكل', 'مكتمل'),
                _buildTransactionRow('18/5/2025', 'نور عادل', '5 شيكل', 'مكتمل'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
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
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: height / 2,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(String date, String customer, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 3,
            child: Text(customer, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 10, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}