// lib/screens/agent/generate_codes_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GenerateCodesScreen extends StatefulWidget {
  const GenerateCodesScreen({super.key});

  @override
  State<GenerateCodesScreen> createState() => _GenerateCodesScreenState();
}

class _GenerateCodesScreenState extends State<GenerateCodesScreen> {
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _packageIdController = TextEditingController();
  bool _isLoading = false;
  List<String> _generatedCodes = [];
  List<Package> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('packages')
        .where('isActive', isEqualTo: true)
        .get();
    setState(() {
      _packages = snapshot.docs.map((doc) => Package.fromFirestore(doc)).toList();
    });
  }

  Future<void> _generateCodes() async {
    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0) {
      _showSnackBar('يرجى إدخال عدد صحيح موجب', isError: true);
      return;
    }
    if (_packageIdController.text.isEmpty) {
      _showSnackBar('يرجى اختيار الباقة', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final List<String> codes = [];
    final batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < count; i++) {
      final code = _generateRandomCode();
      codes.add(code);
      final docRef = FirebaseFirestore.instance.collection('agentCodes').doc();
      batch.set(docRef, {
        'code': code,
        'agentId': userId,
        'packageId': _packageIdController.text,
        'isUsed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // تحديث إحصائيات الوكيل
    final agentRef = FirebaseFirestore.instance.collection('users').doc(userId);
    batch.update(agentRef, {
      'totalCodesSold': FieldValue.increment(count),
    });

    await batch.commit();

    setState(() {
      _generatedCodes = codes;
      _isLoading = false;
    });
    _showSnackBar('تم إنشاء $count كود بنجاح');
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[DateTime.now().millisecondsSinceEpoch % chars.length];
    }
    return code;
  }

  void _copyCodes() {
    final allCodes = _generatedCodes.join('\n');
    // نسخ إلى الحافظة (سنضيف لاحقاً)
    _showSnackBar('تم نسخ الأكواد');
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
        title: const Text('إنشاء أكواد جديدة'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // اختيار الباقة
            DropdownButtonFormField<String>(
              value: _packageIdController.text.isEmpty ? null : _packageIdController.text,
              decoration: InputDecoration(
                labelText: 'اختر الباقة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _packages.map((pkg) {
                return DropdownMenuItem(
                  value: pkg.id,
                  child: Text('${pkg.name} - ${pkg.price} شيكل'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _packageIdController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            // عدد الأكواد
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'عدد الأكواد',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateCodes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('إنشاء الأكواد'),
            ),
            if (_generatedCodes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'الأكواد المنشأة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _generatedCodes.map((code) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(code)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyCodes(),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Package {
  final String id;
  final String name;
  final int price;
  final int amount;
  Package({required this.id, required this.name, required this.price, required this.amount});
  factory Package.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Package(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      amount: data['amount'] ?? 0,
    );
  }
}