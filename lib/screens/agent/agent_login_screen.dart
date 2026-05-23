// // lib/screens/agent/agent_login_screen.dart
// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import 'agent_home_screen.dart';  // تأكد من وجود هذا الاستيراد
//
// class AgentLoginScreen extends StatefulWidget {
//   const AgentLoginScreen({super.key});
//
//   @override
//   State<AgentLoginScreen> createState() => _AgentLoginScreenState();
// }
//
// class _AgentLoginScreenState extends State<AgentLoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _agentCodeController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(seconds: 1));
//
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//
//     // انتقل إلى شاشة الوكيل الرئيسية
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const AgentHomeScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('دخول الوكيل'),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Spacer(),
//                 Icon(
//                   Icons.storefront,
//                   size: 80,
//                   color: AppColors.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'وكيل سريع',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textDark,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'أدخل بيانات حساب الوكيل',
//                   style: TextStyle(color: AppColors.textGray),
//                 ),
//                 const SizedBox(height: 40),
//                 TextFormField(
//                   controller: _agentCodeController,
//                   textAlign: TextAlign.right,
//                   decoration: const InputDecoration(
//                     labelText: 'كود الوكيل',
//                     prefixIcon: Icon(Icons.qr_code),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال كود الوكيل';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   textAlign: TextAlign.right,
//                   decoration: InputDecoration(
//                     labelText: 'كلمة المرور',
//                     prefixIcon: const Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال كلمة المرور';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('دخول', style: TextStyle(fontSize: 18)),
//                   ),
//                 ),
//                 const Spacer(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }