// lib/screens/agent/generate_code_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GenerateCodeScreen extends StatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  State<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends State<GenerateCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _selectedPackage;
  int _amount = 0;
  bool _isLoading = false;
  String? _generatedCode;

  final List<Map<String, dynamic>> _packages = [
    {'name': '5 طلبات', 'price': 5, 'quantity': 5},
    {'name': '10 طلبات', 'price': 9, 'quantity': 10},
    {'name': '20 طلب', 'price': 17, 'quantity': 20},
  ];

  Future<void> _generateCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الباقة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // توليد كود عشوائي
    final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    setState(() {
      _generatedCode = code;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار كود تفعيل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // رقم هاتف العميل
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'رقم هاتف العميل',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // اختيار الباقة - النسخة المصححة
                DropdownButtonFormField<String>(
                  value: _selectedPackage,
                  decoration: const InputDecoration(
                    labelText: 'اختر الباقة',
                    prefixIcon: Icon(Icons.card_giftcard),
                  ),
                  items: _packages.map<DropdownMenuItem<String>>((pkg) {
                    return DropdownMenuItem<String>(
                      value: pkg['name'] as String,
                      child: Text('${pkg['name']} - ${pkg['price']} شيكل'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPackage = value;
                      final pkg = _packages.firstWhere((p) => p['name'] == value);
                      _amount = pkg['price'] as int;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الباقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // المبلغ المستلم
                TextFormField(
                  initialValue: _amount.toString(),
                  readOnly: true,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المستلم',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 24),

                // زر إصدار الكود
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إصدار الكود', style: TextStyle(fontSize: 18)),
                  ),
                ),

                // عرض الكود
                if (_generatedCode != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code, size: 60, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          _generatedCode!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أعطِ هذا الكود للعميل',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // نسخ الكود
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('نسخ'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _generatedCode = null;
                                    _phoneController.clear();
                                    _selectedPackage = null;
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('كود جديد'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}