import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  List<QueryDocumentSnapshot> _requests = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/agent-login');
      return;
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('rechargeRequests')
          .where('agentId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      setState(() {
        _requests = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('خطأ في تحميل البيانات: $e', isError: true);
    }
  }

  List<QueryDocumentSnapshot> get _filteredRequests {
    if (_filter == 'all') return _requests;
    return _requests.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == _filter;
    }).toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.textGray;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '⏳ قيد المراجعة';
      case 'approved': return '✅ تم القبول';
      case 'rejected': return '❌ مرفوض';
      default: return status;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return '🕒';
      case 'approved': return '✅';
      case 'rejected': return '❌';
      default: return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حالة طلبات الشحن'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                _buildFilterChip('الكل', 'all'),
                _buildFilterChip('قيد المراجعة', 'pending'),
                _buildFilterChip('مقبولة', 'approved'),
                _buildFilterChip('مرفوضة', 'rejected'),
              ],
            ),
          ),
          Expanded(
            child: _filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: AppColors.textGray),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات',
                    style: TextStyle(color: AppColors.textGray),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                final doc = _filteredRequests[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildRequestCard(doc.id, data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildRequestCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final statusIcon = _getStatusIcon(status);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showRequestDetails(data);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // أيقونة الحالة
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          statusIcon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب شحن رصيد',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['packageCount']} باقة | ${data['totalAfterDiscount']} شيكل',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // حالة الطلب
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // تاريخ الطلب
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate((data['createdAt'] as Timestamp).toDate()),
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                    const Spacer(),
                    // أيقونة السهم للتفاصيل
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGray),
                  ],
                ),
                // ملاحظات الأدمن (إذا وجدت وتم الرفض)
                if (status == 'rejected' && data['adminNotes'] != null && data['adminNotes'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سبب الرفض: ${data['adminNotes']}',
                              style: TextStyle(fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تفاصيل الطلب',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // تفاصيل الباقة
              _buildDetailRow('عدد الباقات:', '${data['packageCount']} باقة'),
              _buildDetailRow('سعر الباقة:', '${data['packagePrice']} شيكل'),
              _buildDetailRow('السعر الإجمالي:', '${data['totalPrice']} شيكل'),
              _buildDetailRow('خصم الوكيل (${data['discountPercent']}%):', '- ${data['discountAmount']} شيكل',
                  valueColor: AppColors.success),
              const Divider(),
              _buildDetailRow('المبلغ المدفوع:', '${data['totalAfterDiscount']} شيكل',
                  isBold: true, valueColor: AppColors.primary),
              const SizedBox(height: 16),
              // تاريخ الطلب
              _buildDetailRow('تاريخ الطلب:', _formatDate((data['createdAt'] as Timestamp).toDate())),
              if (data['notes'] != null && data['notes'].isNotEmpty)
                _buildDetailRow('ملاحظاتك:', data['notes']),
              if (data['adminNotes'] != null && data['adminNotes'].isNotEmpty)
                _buildDetailRow('رد الأدمن:', data['adminNotes']),
              const SizedBox(height: 20),
              // صورة التحويل
              const Text('صورة التحويل:', style: TextStyle(fontWeight: FontWeight.w500)),
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
              const SizedBox(height: 20),
              // زر إغلاق
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textGray)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}