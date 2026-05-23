import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  String _selectedPeriod = 'daily'; // daily, weekly, monthly
  double _totalEarnings = 0;
  double _currentBalance = 0;
  int _totalTransactions = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // جلب بيانات الوكيل
      final agentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (agentDoc.exists) {
        final data = agentDoc.data()!;
        setState(() {
          _currentBalance = (data['agentBalance'] ?? 0).toDouble();
          _totalEarnings = (data['agentTotalEarnings'] ?? 0).toDouble();
          _totalTransactions = data['agentTotalTransactions'] ?? 0;
        });
      }

      // جلب المعاملات حسب الفترة
      await _loadTransactionsByPeriod();

    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransactionsByPeriod() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime startDate;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('agentTransactions')
        .where('agentId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('createdAt', descending: true)
        .get();

    final transactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'driverName': data['driverName'] ?? '',
        'amount': (data['amount'] ?? 0).toDouble(),
        'commission': (data['commission'] ?? 0).toDouble(),
        'finalAmount': (data['finalAmount'] ?? 0).toDouble(),
        'createdAt': (data['createdAt'] as Timestamp).toDate(),
      };
    }).toList();

    setState(() {
      _recentTransactions = transactions;
    });
  }

  double _getPeriodEarnings() {
    return _recentTransactions.fold(0, (sum, item) => sum + (item['commission'] as double));
  }

  int _getPeriodTransactions() {
    return _recentTransactions.length;
  }

  double _getPeriodTotalAmount() {
    return _recentTransactions.fold(0, (sum, item) => sum + (item['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الرصيد والأرباح
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'رصيدك الحالي',
                    value: '$_currentBalance شيكل',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'إجمالي الأرباح',
                    value: '$_totalEarnings شيكل',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'عدد العمليات',
                    value: '$_totalTransactions',
                    icon: Icons.swap_horiz,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'متوسط العمولة',
                    value: '${_totalTransactions > 0 ? (_totalEarnings / _totalTransactions).toStringAsFixed(2) : '0'} شيكل',
                    icon: Icons.percent,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // إحصائيات الفترة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات الفترة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // اختيار الفترة
                  Row(
                    children: [
                      _buildPeriodButton('يومي', 'daily'),
                      const SizedBox(width: 8),
                      _buildPeriodButton('أسبوعي', 'weekly'),
                      const SizedBox(width: 8),
                      _buildPeriodButton('شهري', 'monthly'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPeriodStat(
                          'عدد العمليات',
                          '${_getPeriodTransactions()}',
                          Icons.swap_horiz,
                          AppColors.info,
                        ),
                      ),
                      Expanded(
                        child: _buildPeriodStat(
                          'إجمالي المشحون',
                          '${_getPeriodTotalAmount().toStringAsFixed(2)} شيكل',
                          Icons.attach_money,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPeriodStat(
                          'أرباحك',
                          '${_getPeriodEarnings().toStringAsFixed(2)} شيكل',
                          Icons.trending_up,
                          AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: _buildPeriodStat(
                          'متوسط العملية',
                          '${_getPeriodTransactions() > 0 ? (_getPeriodEarnings() / _getPeriodTransactions()).toStringAsFixed(2) : '0'} شيكل',
                          Icons.percent,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // آخر المعاملات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 آخر المعاملات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // الانتقال إلى صفحة كل المعاملات
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('لا توجد معاملات في هذه الفترة'),
                ),
              )
            else
              ..._recentTransactions.take(5).map((transaction) => _buildTransactionCard(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            _loadTransactionsByPeriod();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodStat(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final date = transaction['createdAt'] as DateTime;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['driverName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'المبلغ: ${transaction['amount']} شيكل | عمولة: ${transaction['commission']} شيكل',
                  style: TextStyle(fontSize: 11, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${transaction['finalAmount']} شيكل',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 11, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}