import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import 'request_status_screen.dart';

class RechargeRequestScreen extends StatefulWidget {
  const RechargeRequestScreen({super.key});

  @override
  State<RechargeRequestScreen> createState() => _RechargeRequestScreenState();
}

class _RechargeRequestScreenState extends State<RechargeRequestScreen> {
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;

  // ✅ معلق مؤقتاً - لرفع الصورة
  // File? _transferImage;

  // متغيرات الباقة
  int _packageCount = 1;
  final double _packagePrice = 1.0;
  double _totalPrice = 0;
  double _discountAmount = 0;
  double _totalAfterDiscount = 0;
  bool _hasPackageSelected = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    if (_packageCount <= 0) {
      setState(() {
        _totalPrice = 0;
        _discountAmount = 0;
        _totalAfterDiscount = 0;
        _hasPackageSelected = false;
      });
      return;
    }

    setState(() {
      _totalPrice = _packageCount * _packagePrice;
      _discountAmount = _totalPrice * 0.05; // 5% خصم
      _totalAfterDiscount = _totalPrice - _discountAmount;
      _hasPackageSelected = true;
    });
  }

  void _showPackageDialog() {
    final countController = TextEditingController(text: _packageCount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'اختر عدد الباقات',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'عدد الباقات',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                      helperText: 'سعر الباقة الواحدة = 1 شيكل',
                    ),
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      if (count != null && count > 0) {
                        setDialogState(() {
                          _packageCount = count;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_packageCount > 0) ...[
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('سعر الباقة الواحدة:'),
                              Text('$_packagePrice شيكل'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('عدد الباقات:'),
                              Text('$_packageCount'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('السعر الإجمالي:'),
                              Text('${(_packageCount * _packagePrice).toStringAsFixed(2)} شيكل'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('خصم الوكيل (5%):'),
                              Text(
                                '- ${(_packageCount * _packagePrice * 0.05).toStringAsFixed(2)} شيكل',
                                style: const TextStyle(color: AppColors.success),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المطلوب دفعه:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(_packageCount * _packagePrice * 0.95).toStringAsFixed(2)} شيكل',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_packageCount > 0) {
                      _calculatePrice();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء إدخال عدد صحيح'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ معلق مؤقتاً - دوال رفع الصورة
  /*
  Future<String?> _uploadImage() async {
    if (_transferImage == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final fileName = 'recharge_${user?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('recharge_requests/$fileName');

      await ref.putFile(_transferImage!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showSnackBar('فشل رفع الصورة: $e', isError: true);
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _transferImage = File(pickedFile.path);
      });
    }
  }
  */

  Future<void> _submitRequest() async {
    if (!_hasPackageSelected) {
      _showSnackBar('الرجاء اختيار الباقة أولاً', isError: true);
      return;
    }

    // ✅ تم تعليق التحقق من الصورة مؤقتاً
    // if (_transferImage == null) {
    //   _showSnackBar('الرجاء رفع صورة إشعار التحويل', isError: true);
    //   return;
    // }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('الرجاء تسجيل الدخول');

      // ✅ تم تعليق رفع الصورة مؤقتاً
      // final imageUrl = await _uploadImage();
      // if (imageUrl == null) throw Exception('فشل رفع الصورة');

      // جلب بيانات المستخدم من Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();

      final requestData = {
        'id': '',
        'agentId': user.uid,
        'agentName': userData?['fullName'] ?? 'الوكيل',
        'agentPhone': userData?['phone'] ?? '',
        'packageCount': _packageCount,
        'packagePrice': _packagePrice,
        'totalPrice': _totalPrice,
        'discountPercent': 5,
        'discountAmount': _discountAmount,
        'totalAfterDiscount': _totalAfterDiscount,
        // 'transferImageUrl': imageUrl,  // ✅ معلق مؤقتاً
        'transferImageUrl': '',  // ✅ قيمة فارغة حالياً
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'adminNotes': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('rechargeRequests')
          .add(requestData);

      await docRef.update({'id': docRef.id});

      _showSnackBar('تم إرسال طلب الشحن بنجاح! سيتم الرد عليك خلال 24 ساعة');

      // إعادة تعيين الحقول
      setState(() {
        _packageCount = 1;
        _totalPrice = 0;
        _discountAmount = 0;
        _totalAfterDiscount = 0;
        _hasPackageSelected = false;
        // _transferImage = null;  // ✅ معلق مؤقتاً
        _notesController.clear();
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RequestStatusScreen()),
        );
      }

    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلب شحن رصيد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'طلب شحن رصيد',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'اختر عدد الباقات (سعر الباقة = 1 شيكل)',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            const SizedBox(height: 32),

            // زر اختيار الباقة
            const Text(
              'اختيار عدد الباقات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showPackageDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اضغط لاختيار عدد الباقات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'سعر الباقة الواحدة = 1 شيكل',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // عرض تفاصيل الباقة المختارة
            if (_hasPackageSelected) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('عدد الباقات:'),
                        Text(
                          '$_packageCount',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('سعر الباقة الواحدة:'),
                        Text(
                          '$_packagePrice شيكل',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('السعر الإجمالي:'),
                        Text('${_totalPrice.toStringAsFixed(2)} شيكل'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('خصم الوكيل (5%):'),
                        Text(
                          '- ${_discountAmount.toStringAsFixed(2)} شيكل',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المطلوب دفعه:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_totalAfterDiscount.toStringAsFixed(2)} شيكل',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ✅ تم تعليق قسم رفع الصورة مؤقتاً
            /*
            // رفع صورة التحويل
            const Text(
              'إشعار التحويل',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: _transferImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 40, color: AppColors.textGray),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط لرفع صورة التحويل',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_transferImage!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _transferImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            */


            // ملاحظات إضافية
            const Text(
              'ملاحظات إضافية (اختياري)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أضف أي ملاحظات هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // أزرار الإرسال والإلغاء
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('إرسال الطلب'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}