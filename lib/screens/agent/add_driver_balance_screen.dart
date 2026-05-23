import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddDriverBalanceScreen extends StatefulWidget {
  const AddDriverBalanceScreen({super.key});

  @override
  State<AddDriverBalanceScreen> createState() => _AddDriverBalanceScreenState();
}

class _AddDriverBalanceScreenState extends State<AddDriverBalanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isSearching = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _selectedDriver;
  String? _selectedDriverId;

  double _amount = 0;
  double _agentBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadAgentBalance();
  }

  Future<void> _loadAgentBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _agentBalance = (doc.data()?['agentBalance'] ?? 0).toDouble();
      });
    }
  }

  Future<void> _searchDriver() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      _showSnackBar('الرجاء إدخال رقم الهوية أو الاسم', isError: true);
      return;
    }

    setState(() {
      _isSearching = true;
      _selectedDriver = null;
      _selectedDriverId = null;
    });

    try {
      QuerySnapshot query;

      if (RegExp(r'^[0-9]+$').hasMatch(searchTerm)) {
        // بحث برقم الهوية
        query = await FirebaseFirestore.instance
            .collection('users')
            .where('nationalId', isEqualTo: searchTerm)
            .where('role', isEqualTo: 'driver')
            .limit(1)
            .get();
      } else {
        // بحث بالاسم
        query = await FirebaseFirestore.instance
            .collection('users')
            .where('fullName', isGreaterThanOrEqualTo: searchTerm)
            .where('fullName', isLessThanOrEqualTo: '$searchTerm\uf8ff')
            .where('role', isEqualTo: 'driver')
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        _showSnackBar('لم يتم العثور على سائق بهذا الرقم/الاسم', isError: true);
        setState(() => _isSearching = false);
        return;
      }

      final doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        _selectedDriver = data;
        _selectedDriverId = doc.id;
        _isSearching = false;
      });

      _showSnackBar('تم العثور على السائق: ${data['fullName']}');

    } catch (e) {
      _showSnackBar('خطأ في البحث: $e', isError: true);
      setState(() => _isSearching = false);
    }
  }

  void _calculateAmount(String value) {
    final amount = double.tryParse(value);
    if (amount != null && amount > 0) {
      setState(() {
        _amount = amount;
      });
    } else {
      setState(() {
        _amount = 0;
      });
    }
  }

  Future<void> _submitRecharge() async {
    if (_selectedDriver == null) {
      _showSnackBar('الرجاء البحث عن سائق أولاً', isError: true);
      return;
    }

    if (_amount <= 0) {
      _showSnackBar('الرجاء إدخال مبلغ صحيح', isError: true);
      return;
    }

    if (_agentBalance < _amount) {
      _showSnackBar('رصيدك غير كافي لإتمام العملية', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final agent = FirebaseAuth.instance.currentUser;
      if (agent == null) throw Exception('الرجاء تسجيل الدخول');

      // جلب بيانات الوكيل
      final agentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(agent.uid)
          .get();

      final agentData = agentDoc.data()!;
      final currentAgentBalance = (agentData['agentBalance'] ?? 0).toDouble();
      final currentAgentTransactions = (agentData['agentTotalTransactions'] ?? 0);

      // جلب بيانات السائق الحالية
      final driverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedDriverId)
          .get();

      final driverData = driverDoc.data()!;
      final currentDriverBalance = (driverData['balance'] ?? 0).toDouble();

      // ✅ لا يوجد خصم، المبلغ كاملاً يذهب للسائق
      final newAgentBalance = currentAgentBalance - _amount;
      final newDriverBalance = currentDriverBalance + _amount;
      final newAgentTransactions = currentAgentTransactions + 1;

      final batch = FirebaseFirestore.instance.batch();

      // 1. تحديث رصيد السائق
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(_selectedDriverId),
        {
          'balance': newDriverBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // 2. تحديث رصيد الوكيل
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(agent.uid),
        {
          'agentBalance': newAgentBalance,
          'agentTotalTransactions': newAgentTransactions,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // 3. تسجيل المعاملة (بدون عمولة)
      final transactionRef = FirebaseFirestore.instance.collection('agentTransactions').doc();
      batch.set(transactionRef, {
        'id': transactionRef.id,
        'agentId': agent.uid,
        'agentName': agentData['fullName'] ?? 'الوكيل',
        'driverId': _selectedDriverId,
        'driverName': _selectedDriver!['fullName'],
        'driverNationalId': _selectedDriver!['nationalId'] ?? '',
        'amount': _amount,
        'type': 'driver_recharge',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _showSnackBar(
        'تم شحن السائق بنجاح!\n'
            'تم إضافة $_amount شيكل إلى رصيد السائق',
      );

      // إعادة تعيين الحقول
      setState(() {
        _selectedDriver = null;
        _selectedDriverId = null;
        _amount = 0;
        _amountController.clear();
        _searchController.clear();
        _agentBalance = newAgentBalance;
      });

      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('شحن رصيد سائق'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رصيد الوكيل الحالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'رصيدك الحالي:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_agentBalance.toStringAsFixed(2)} شيكل',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // البحث عن سائق
            const Text(
              'البحث عن سائق',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'رقم الهوية أو الاسم',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('بحث'),
                ),
              ],
            ),

            // عرض بيانات السائق
            if (_selectedDriver != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, size: 28, color: AppColors.success),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDriver!['fullName'] ?? 'سائق',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'رقم الهوية: ${_selectedDriver!['nationalId'] ?? 'غير متوفر'}',
                                style: TextStyle(fontSize: 12, color: AppColors.textGray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الرصيد الحالي:'),
                          Text(
                            '${(_selectedDriver!['balance'] ?? 0).toInt()} شيكل',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // إدخال المبلغ
            const Text(
              'المبلغ المراد شحنه',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ بالشيكل',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'شيكل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _calculateAmount(value),
            ),

            // ✅ تفاصيل العملية (بدون خصم)
            if (_amount > 0) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المبلغ المشحون للسائق:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_amount شيكل',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سيتم خصم المبلغ من رصيدك:',
                          style: TextStyle(color: AppColors.warning),
                        ),
                        Text(
                          '- $_amount شيكل',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _selectedDriver == null || _amount <= 0) ? null : _submitRecharge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'تأكيد الدفع وشحن الرصيد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}