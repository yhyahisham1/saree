// lib/screens/agent/sales_history_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('الرجاء تسجيل الدخول'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المبيعات'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agentCodes')
            .where('agentId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.textGray),
                  SizedBox(height: 16),
                  Text('لا توجد مبيعات بعد'),
                ],
              ),
            );
          }

          final codes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: codes.length,
            itemBuilder: (context, index) {
              final data = codes[index].data() as Map<String, dynamic>;
              return _buildSaleCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> data) {
    final code = data['code'] ?? '';
    final isUsed = data['isUsed'] ?? false;
    final createdAt = data['createdAt'] as Timestamp?;
    final usedAt = data['usedAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isUsed ? Icons.check_circle : Icons.pending,
          color: isUsed ? AppColors.success : AppColors.warning,
        ),
        title: Text('الكود: $code'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تاريخ الإنشاء: ${createdAt != null ? _formatDate(createdAt) : ''}'),
            if (isUsed)
              Text('تاريخ الاستخدام: ${usedAt != null ? _formatDate(usedAt) : ''}'),
            Text('الحالة: ${isUsed ? 'مستخدم' : 'غير مستخدم'}'),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}