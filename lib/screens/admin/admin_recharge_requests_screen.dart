import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdminRechargeRequestsScreen extends StatefulWidget {
  const AdminRechargeRequestsScreen({super.key});

  @override
  State<AdminRechargeRequestsScreen> createState() => _AdminRechargeRequestsScreenState();
}

class _AdminRechargeRequestsScreenState extends State<AdminRechargeRequestsScreen> {
  String _selectedFilter = 'pending'; // pending, approved, rejected, all

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلبات شحن الرصيد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // فلاتر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('قيد المراجعة', 'pending'),
                _buildFilterChip('مقبولة', 'approved'),
                _buildFilterChip('مرفوضة', 'rejected'),
                _buildFilterChip('الكل', 'all'),
              ],
            ),
          ),
          Expanded(
            child: _buildRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildRequestsList() {
    Query query = FirebaseFirestore.instance.collection('rechargeRequests');

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد طلبات'));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            return _buildRequestCard(requests[index].id, data);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(String docId, Map<String, dynamic> data) {
    final status = data['status'];
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = '✅ مقبولة';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = '❌ مرفوضة';
        break;
      default:
        statusColor = AppColors.warning;
        statusText = '⏳ قيد المراجعة';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.request_page, color: AppColors.primary),
        ),
        title: Text(
          data['agentName'] ?? 'الوكيل',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data['packageCount']} × ${data['packageName']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
            ),
          ],
        ),
        trailing: Text(
          '${data['totalAfterDiscount']} شيكل',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('اسم الوكيل:', data['agentName']),
                _buildInfoRow('رقم الهاتف:', data['agentPhone'] ?? 'غير متوفر'),
                const Divider(),
                _buildInfoRow('الباقة:', data['packageName']),
                _buildInfoRow('عدد الباقات:', '${data['packageCount']}'),
                _buildInfoRow('السعر الأصلي:', '${data['totalPrice']} شيكل'),
                _buildInfoRow('الخصم (${data['discountPercent']}%):', '- ${data['discountAmount']} شيكل'),
                const Divider(),
                _buildInfoRow('المبلغ المدفوع:', '${data['totalAfterDiscount']} شيكل',
                    isBold: true, color: AppColors.primary),
                if (data['notes'] != null && data['notes'].isNotEmpty)
                  _buildInfoRow('ملاحظات:', data['notes']),
                const SizedBox(height: 12),

                // صورة التحويل
                const Text('صورة التحويل:'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showImageDialog(data['transferImageUrl']);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['transferImageUrl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: AppColors.backgroundGray,
                        child: const Center(child: Icon(Icons.broken_image, size: 40)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // حقل ملاحظات الأدمن
                if (status == 'pending') ...[
                  const Text('ملاحظات الأدمن:'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController(text: data['adminNotes']),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'أضف ملاحظات...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection('rechargeRequests')
                          .doc(docId)
                          .update({'adminNotes': value});
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateRequestStatus(docId, 'approved', data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('قبول الطلب'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateRequestStatus(docId, 'rejected', data),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('رفض', style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ],
                  ),
                ] else if (status == 'approved') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تمت الموافقة على هذا الطلب وتم إضافة ${data['totalAfterDiscount']} شيكل إلى رصيد الوكيل',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (status == 'rejected') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data['adminNotes'] ?? 'تم رفض الطلب',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGray)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(String docId, String status, Map<String, dynamic> requestData) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'approved' ? 'قبول الطلب' : 'رفض الطلب'),
        content: Text(
          status == 'approved'
              ? 'هل أنت متأكد من قبول هذا الطلب؟ سيتم إضافة ${requestData['totalAfterDiscount']} شيكل إلى رصيد الوكيل.'
              : 'هل أنت متأكد من رفض هذا الطلب؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? AppColors.success : AppColors.error,
            ),
            child: Text(status == 'approved' ? 'قبول' : 'رفض'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // تحديث حالة الطلب
      final requestRef = FirebaseFirestore.instance.collection('rechargeRequests').doc(docId);
      batch.update(requestRef, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // إذا كان مقبولاً، أضف الرصيد للوكيل
      if (status == 'approved') {
        final agentRef = FirebaseFirestore.instance.collection('users').doc(requestData['agentId']);
        batch.update(agentRef, {
          'balance': FieldValue.increment(requestData['totalAfterDiscount']),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'approved' ? 'تم قبول الطلب وإضافة الرصيد' : 'تم رفض الطلب'),
          backgroundColor: status == 'approved' ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}