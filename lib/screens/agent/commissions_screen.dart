// lib/screens/agent/commissions_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CommissionsScreen extends StatelessWidget {
  const CommissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('الرجاء تسجيل الدخول'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('عمولاتي'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
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
                  Icon(Icons.monetization_on, size: 64, color: AppColors.textGray),
                  SizedBox(height: 16),
                  Text('لا توجد عمولات بعد'),
                ],
              ),
            );
          }

          final transactions = snapshot.data!.docs;
          double total = 0;
          for (var doc in transactions) {
            total += (doc.data() as Map<String, dynamic>)['agentCommission'] ?? 0;
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إجمالي العمولات:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} شيكل',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final data = transactions[index].data() as Map<String, dynamic>;
                    return _buildCommissionCard(data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommissionCard(Map<String, dynamic> data) {
    final amount = (data['agentCommission'] ?? 0).toDouble();
    final packageName = data['packageName'] ?? 'باقة';
    final date = data['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withOpacity(0.1),
          child: const Icon(Icons.attach_money, color: AppColors.success),
        ),
        title: Text('عمولة من باقة $packageName'),
        subtitle: Text(date != null ? _formatDate(date) : ''),
        trailing: Text(
          '+${amount.toStringAsFixed(2)} شيكل',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}