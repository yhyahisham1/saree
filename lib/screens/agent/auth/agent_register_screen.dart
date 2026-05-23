// lib/screens/agent/auth/agent_register_screen.dart
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'agent_login_screen.dart';

class AgentRegisterScreen extends StatefulWidget {
  const AgentRegisterScreen({super.key});

  @override
  State<AgentRegisterScreen> createState() => _AgentRegisterScreenState();
}

class _AgentRegisterScreenState extends State<AgentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. إنشاء حساب في Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. إنشاء كود وكيل فريد
      final agentCode = _generateAgentCode();

      // 3. حفظ بيانات الوكيل في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'agent',
        'agentCode': agentCode,
        'totalCommission': 0,
        'collectedCommission': 0,
        'issuedCodes': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. عرض رسالة النجاح
      _showSnackBar('تم إنشاء الحساب بنجاح! كود الوكيل: $agentCode');

      // 5. الانتقال إلى شاشة تسجيل الدخول بعد تأخير بسيط
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AgentLoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // أخطاء المصادقة (البريد مستخدم، كلمة مرور ضعيفة، إلخ)
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'weak-password':
          message = 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        default:
          message = 'خطأ في التسجيل: ${e.message}';
      }
      _showSnackBar(message, isError: true);
    } on FirebaseException catch (e) {
      // أخطاء Firestore (مثل: permission-denied, disabled API, إلخ)
      String message;
      if (e.code == 'permission-denied') {
        message = '⚠️ خطأ في الصلاحيات: تأكد من تفعيل Cloud Firestore API وقواعد الأمان.';
      } else if (e.code == 'not-found') {
        message = '⚠️ قاعدة البيانات غير متاحة. تأكد من إعداد Firestore بشكل صحيح.';
      } else {
        message = 'فشل حفظ البيانات: ${e.message}';
      }
      _showSnackBar(message, isError: true);
      // حذف حساب Firebase إذا فشل حفظ البيانات (اختياري)
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (_) {}
    } catch (e) {
      // أي خطأ آخر غير متوقع
      _showSnackBar('خطأ غير متوقع: $e', isError: true);
    } finally {
      // إيقاف مؤشر التحميل في جميع الأحوال
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateAgentCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? AppColors.error : AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب وكيل'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 60, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('بيانات الوكيل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'الاسم الكامل'), validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), validator: (v) => v!.isEmpty ? 'الهاتف مطلوب' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني'), validator: (v) => v!.isEmpty || !v.contains('@') ? 'بريد صالح مطلوب' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور'), validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'), validator: (v) => v != _passwordController.text ? 'غير متطابقة' : null),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _isLoading ? null : _register, child: _isLoading ? const CircularProgressIndicator() : const Text('إنشاء حساب')),
            ],
          ),
        ),
      ),
    );
  }
}