// lib/screens/customer/rate_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class RateDriverScreen extends StatefulWidget {
  final String? orderId;
  final String? driverName;
  
  const RateDriverScreen({
    super.key,
    this.orderId,
    this.driverName,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  // متغيرات التقييم
  double _rating = 0;
  String _selectedRatingText = '';
  final List<String> _reviewTags = [];
  final TextEditingController _reviewController = TextEditingController();
  
  // متغيرات OTP
  String? _generatedOtp;
  bool _showOtp = false;
  
  // حالة التحميل
  bool _isLoading = false;
  bool _isSubmitted = false;
  
  // خيارات التقييم السريع
  final List<RatingOption> _ratingOptions = [
    RatingOption(value: 1, text: 'سيء جداً', icon: Icons.sentiment_very_dissatisfied, color: Colors.red),
    RatingOption(value: 2, text: 'سيء', icon: Icons.sentiment_dissatisfied, color: Colors.orange),
    RatingOption(value: 3, text: 'جيد', icon: Icons.sentiment_neutral, color: Colors.grey),
    RatingOption(value: 4, text: 'جيد جداً', icon: Icons.sentiment_satisfied, color: Colors.lightGreen),
    RatingOption(value: 5, text: 'ممتاز', icon: Icons.sentiment_very_satisfied, color: Colors.green),
  ];
  
  // كلمات مفتاحية للتقييم
  final List<String> _availableTags = [
    'سريع', 'مهذب', 'ملتزم', 'موثوق', 'متعاون',
    'دقيق', 'آمن', 'محترف', 'مرن', 'ممتاز',
  ];

  @override
  void initState() {
    super.initState();
    _updateRatingText();
  }

  void _updateRatingText() {
    final option = _ratingOptions.firstWhere(
      (o) => o.value == _rating.round(),
      orElse: () => _ratingOptions.last,
    );
    setState(() {
      _selectedRatingText = option.text;
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_reviewTags.contains(tag)) {
        _reviewTags.remove(tag);
      } else {
        _reviewTags.add(tag);
      }
    });
  }

  void _submitRating() async {
    if (_rating == 0) {
      _showSnackBar('الرجاء تقييم السائق أولاً', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة إرسال التقييم
    await Future.delayed(const Duration(seconds: 1));
    
    // توليد OTP عشوائي من 6 أرقام
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    final otp = random.toString().padLeft(6, '0').substring(0, 6);
    
    setState(() {
      _generatedOtp = otp;
      _showOtp = true;
      _isLoading = false;
      _isSubmitted = true;
    });
    
    // نسخ الـ OTP تلقائياً
    await Clipboard.setData(ClipboardData(text: otp));
  }

  void _copyOtp() {
    if (_generatedOtp != null) {
      Clipboard.setData(ClipboardData(text: _generatedOtp!));
      _showSnackBar('تم نسخ الرقم بنجاح');
    }
  }

  void _completeOrder() {
    // العودة إلى الشاشة السابقة (تتبع الطلب)
    Navigator.popUntil(context, (route) => route.isFirst);
    _showSnackBar('تم إتمام الطلب بنجاح! شكراً لك');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverName = widget.driverName ?? 'السائق';
    final orderId = widget.orderId ?? 'ORD-12345';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تقييم السائق'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة معلومات السائق
                _buildDriverCard(driverName, orderId),
                const SizedBox(height: 24),
                
                if (!_showOtp) ...[
                  // عنوان التقييم
                  _buildRatingHeader(),
                  const SizedBox(height: 16),
                  
                  // تقييم بالنجوم
                  _buildStarRating(),
                  const SizedBox(height: 16),
                  
                  // نص التقييم
                  _buildRatingText(),
                  const SizedBox(height: 24),
                  
                  // كلمات مفتاحية
                  _buildTagsSection(),
                  const SizedBox(height: 24),
                  
                  // تعليق إضافي
                  _buildReviewField(),
                  const SizedBox(height: 32),
                  
                  // زر إرسال التقييم
                  _buildSubmitButton(),
                ],
                
                if (_showOtp && _generatedOtp != null) ...[
                  // بطاقة OTP
                  _buildOtpCard(),
                  const SizedBox(height: 24),
                  
                  // زر إتمام الطلب
                  _buildCompleteButton(),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildDriverCard(String driverName, String orderId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الطلب #$orderId',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'توصيل مكتمل',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'كيف كانت تجربتك مع السائق؟',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'شاركنا رأيك لتطوير الخدمة',
          style: TextStyle(fontSize: 13, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starValue.toDouble();
                    _updateRatingText();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    starValue <= _rating ? Icons.star : Icons.star_border,
                    size: 48,
                    color: starValue <= _rating ? Colors.amber : AppColors.textGray,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (_rating > 0)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _ratingOptions.firstWhere((o) => o.value == _rating.round()).color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _ratingOptions.firstWhere((o) => o.value == _rating.round()).icon,
                    size: 18,
                    color: _ratingOptions.firstWhere((o) => o.value == _rating.round()).color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedRatingText,
                    style: TextStyle(
                      color: _ratingOptions.firstWhere((o) => o.value == _rating.round()).color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingText() {
    if (_rating == 0) return const SizedBox.shrink();
    
    return Center(
      child: Text(
        _getRatingMessage(),
        style: TextStyle(color: AppColors.textGray, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getRatingMessage() {
    switch (_rating.round()) {
      case 1: return 'نأسف أن تجربتك لم تكن جيدة. سنعمل على تحسين الخدمة';
      case 2: return 'شكراً لملاحظاتك، سنسعى لتطوير الخدمة';
      case 3: return 'نشكرك على تقييمك، سنسعى للأفضل';
      case 4: return 'شكراً لك! سعيدون بأن الخدمة نالت رضاكم';
      case 5: return 'رائع! شكراً جزيلاً على تقييمك الممتاز';
      default: return '';
    }
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر كلمات تصف تجربتك (اختياري)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableTags.map((tag) {
            final isSelected = _reviewTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تعليق إضافي (اختياري)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reviewController,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'اكتب تعليقك هنا...',
            hintStyle: TextStyle(color: AppColors.textLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _rating > 0 ? _submitRating : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'إرسال التقييم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, AppColors.success.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'تم استلام تقييمك!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أعطِ هذا الرقم للسائق لإنهاء الطلب',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _generatedOtp!,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyOtp,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('نسخ الرقم'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // مشاركة الرقم
                    _copyOtp();
                    _showSnackBar('تم نسخ الرقم، يمكنك مشاركته مع السائق');
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('مشاركة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _completeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'إتمام الطلب',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'جاري إرسال تقييمك...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Models
// ============================================================

class RatingOption {
  final int value;
  final String text;
  final IconData icon;
  final Color color;

  RatingOption({
    required this.value,
    required this.text,
    required this.icon,
    required this.color,
  });
}