// lib/screens/agent/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/auth/role_selection_screen.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(radius: 50, backgroundColor: AppColors.primary, child: Text(data['fullName']?[0] ?? 'و', style: const TextStyle(fontSize: 40, color: Colors.white))),
              const SizedBox(height: 16),
              Text(data['fullName'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('كود الوكيل: ${data['agentCode'] ?? '----'}', style: const TextStyle(color: AppColors.textGray)),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('رقم الهاتف'),
                  subtitle: Text(data['phone'] ?? 'غير مضاف'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('البريد الإلكتروني'),
                  subtitle: Text(data['email'] ?? 'غير مضاف'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}