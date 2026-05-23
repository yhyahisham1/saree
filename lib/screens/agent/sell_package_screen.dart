// lib/screens/agent/sell_package_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SellPackageScreen extends StatefulWidget {
  const SellPackageScreen({super.key});

  @override
  State<SellPackageScreen> createState() => _SellPackageScreenState();
}

class _SellPackageScreenState extends State<SellPackageScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sellPackage() async {
    final code = _codeController.text.trim();
    final phone = _phoneController.text.trim();

    if (code.isEmpty) {
      _showSnackBar('يرجى إدخال الكود', isError: true);
      return;
    }
    if (phone.isEmpty) {
      _showSnackBar('يرجى إدخال رقم هاتف العميل', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. البحث عن الكود في agentCodes
      final codeQuery = await FirebaseFirestore.instance
          .collection('agentCodes')
          .where('code', isEqualTo: code)
          .where('isUsed', isEqualTo: false)
          .limit(1)
          .get();

      if (codeQuery.docs.isEmpty) {
        throw Exception('الكود غير صالح أو مستخدم من قبل');
      }

      final codeDoc = codeQuery.docs.first;
      final codeData = codeDoc.data();
      final packageId = codeData['packageId'];
      final agentId = codeData['agentId'];

      // 2. البحث عن العميل برقم الهاتف
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('لا يوجد مستخدم بهذا الرقم');
      }

      final userDoc = userQuery.docs.first;
      final userId = userDoc.id;
      final userRole = userDoc.data()['role'];

      if (userRole != 'storeOwner' && userRole != 'driver') {
        throw Exception('هذا الحساب ليس لصاحب متجر أو سائق');
      }

      // 3. الحصول على تفاصيل الباقة
      final packageDoc = await FirebaseFirestore.instance
          .collection('packages')
          .doc(packageId)
          .get();
      final packageData = packageDoc.data()!;
      final packageAmount = packageData['amount'] ?? 0;
      final packagePrice = packageData['price'] ?? 0;
      final agentCommission = packagePrice * 0.2; // 20%

      // 4. تحديث رصيد العميل
      await userDoc.reference.update({
        'balance': FieldValue.increment(packageAmount),
      });

      // 5. تحديث رصيد الوكيل (العمولة)
      await FirebaseFirestore.instance.collection('users').doc(agentId).update({
        'totalEarnings': FieldValue.increment(agentCommission),
        'totalCommission': FieldValue.increment(1),
      });

      // 6. تسجيل المعاملة
      await FirebaseFirestore.instance.collection('transactions').add({
        'agentId': agentId,
        'userId': userId,
        'packageId': packageId,
        'packageName': packageData['name'],
        'amount': packagePrice,
        'agentCommission': agentCommission,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 7. تحديث الكود إلى مستخدم
      await codeDoc.reference.update({
        'isUsed': true,
        'usedBy': userId,
        'usedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('✅ تم تفعيل الباقة بنجاح وربح ${agentCommission.toStringAsFixed(2)} شيكل');
      _codeController.clear();
      _phoneController.clear();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيع باقة شحن'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل الكود الذي تم إنشاؤه مسبقاً ورقم هاتف العميل (صاحب متجر أو سائق) لتفعيل الباقة. سيتم إضافة الرصيد للعميل وستحصل على 20% عمولة.',
                      style: TextStyle(color: AppColors.textGray, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'كود التفعيل',
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم هاتف العميل',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _sellPackage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('تفعيل الباقة'),
            ),
          ],
        ),
      ),
    );
  }
}