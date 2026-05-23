// lib/screens/customer/track_order_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'rate_driver_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  // حالة الطلب
  int _currentStep = 1; // 1, 2, 3, 4
  String _status = 'searching'; // searching, assigned, picked, delivered
  
  // بيانات السائق
  String? _driverName;
  String? _driverPhone;
  double _driverRating = 0;
  String? _driverImage;
  String _driverVehicle = 'دراجة هوائية';
  
  // الوقت
  String _estimatedTime = 'جاري البحث عن سائق...';
  String _orderTime = '';
  String _pickupTime = '';
  String _deliveryTime = '';
  
  // موقع السائق (محاكاة)
  double _driverLatitude = 31.5;
  double _driverLongitude = 34.5;
  double _customerLatitude = 31.52;
  double _customerLongitude = 34.52;
  
  // مؤقت للمحاكاة
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _orderTime = _getCurrentTime();
    _startSimulation();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _startSimulation() async {
    if (_isSimulating) return;
    _isSimulating = true;

    // المرحلة 1: البحث عن سائق (3 ثواني)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    setState(() {
      _status = 'assigned';
      _currentStep = 2;
      _driverName = 'أحمد محمد';
      _driverPhone = '0591234567';
      _driverRating = 4.8;
      _driverImage = null;
      _estimatedTime = '5-10 دقائق';
      _pickupTime = _getCurrentTime();
    });

    // المرحلة 2: السائق في الطريق للاستلام (5 ثواني)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    
    setState(() {
      _status = 'picked';
      _currentStep = 3;
      _estimatedTime = '3-5 دقائق';
    });

    // المرحلة 3: السائق في الطريق للتسليم (5 ثواني)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    
    setState(() {
      _status = 'delivered';
      _currentStep = 4;
      _estimatedTime = 'تم التوصيل';
      _deliveryTime = _getCurrentTime();
    });
  }

  void _callDriver() {
    // فتح تطبيق الهاتف
    // يمكن إضافة url_launcher لاحقاً
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جارٍ الاتصال بالسائق...')),
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟ لن يتم استرداد الرصيد.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للصفحة السابقة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'تفاصيل الطلب',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('رقم الطلب', widget.orderId),
              const Divider(),
              _buildDetailRow('تاريخ الطلب', DateTime.now().toString().substring(0, 10)),
              const Divider(),
              _buildDetailRow('وقت الإنشاء', _orderTime),
              const Divider(),
              if (_pickupTime.isNotEmpty)
                _buildDetailRow('وقت الاستلام', _pickupTime),
              if (_deliveryTime.isNotEmpty) ...[
                const Divider(),
                _buildDetailRow('وقت التوصيل', _deliveryTime),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGray)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تتبع الطلب #${widget.orderId}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showOrderDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط حالة الطلب
          _buildProgressBar(),
          const Divider(height: 1),
          
          // الخريطة
          Expanded(
            flex: 2,
            child: _buildMap(),
          ),
          
          // معلومات السائق (إذا تم التعيين)
          if (_status != 'searching')
            _buildDriverInfo(),
          
          // زر إلغاء الطلب (إذا كان لا يزال قيد البحث)
          if (_status == 'searching')
            _buildCancelButton(),
          
          // زر تقييم السائق (بعد التوصيل)
          if (_status == 'delivered')
            _buildRateButton(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStep(1, 'تم الإنشاء', _currentStep >= 1, Icons.check_circle),
          Expanded(child: _buildLine(_currentStep >= 2)),
          _buildStep(2, 'تم التعيين', _currentStep >= 2, Icons.person),
          Expanded(child: _buildLine(_currentStep >= 3)),
          _buildStep(3, 'تم الاستلام', _currentStep >= 3, Icons.inventory),
          Expanded(child: _buildLine(_currentStep >= 4)),
          _buildStep(4, 'تم التوصيل', _currentStep >= 4, Icons.home),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.border,
          ),
          child: Center(
            child: isActive && step < _currentStep
                ? const Icon(Icons.check, size: 22, color: Colors.white)
                : Icon(icon, size: 20, color: isActive ? Colors.white : AppColors.textGray),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      height: 3,
      color: isActive ? AppColors.primary : AppColors.border,
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: AppColors.backgroundGray,
          child: Stack(
            children: [
              // خريطة محاكاة
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/map_placeholder.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.3),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
              ),
              
              // أيقونة العميل
              Positioned(
                bottom: 40,
                left: 40,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_pin, color: Colors.white, size: 24),
                ),
              ),
              
              // أيقونة السائق (يتحرك حسب الحالة)
              if (_status != 'searching' && _status != 'delivered')
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  bottom: _status == 'assigned' ? 100 : 60,
                  right: _status == 'assigned' ? 60 : 80,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delivery_dining, color: Colors.white, size: 24),
                  ),
                ),
              
              // نص الحالة على الخريطة
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _status == 'searching' ? Icons.search :
                        _status == 'assigned' ? Icons.person_pin_circle :
                        _status == 'picked' ? Icons.delivery_dining :
                        Icons.check_circle,
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getStatusText(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // زر التحكم في الخريطة
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تحديد موقعك الحالي...')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'searching': return AppColors.warning;
      case 'assigned': return AppColors.primary;
      case 'picked': return AppColors.secondary;
      case 'delivered': return AppColors.success;
      default: return AppColors.textGray;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case 'searching': return 'جاري البحث عن سائق...';
      case 'assigned': return 'تم تعيين سائق، السائق في طريقه إليك';
      case 'picked': return 'تم استلام الطرد، السائق في طريقه للتسليم';
      case 'delivered': return 'تم توصيل الطلب بنجاح';
      default: return '';
    }
  }

  Widget _buildDriverInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // صورة السائق
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, size: 30, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              
              // معلومات السائق
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverName ?? 'السائق',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(_driverRating.toString(), style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Text('متوسط التقييم', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.pedal_bike, size: 12, color: AppColors.textGray),
                        const SizedBox(width: 4),
                        Text(_driverVehicle, style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // زر الاتصال
              ElevatedButton.icon(
                onPressed: _callDriver,
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('اتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // الوقت المقدر
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.timer, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'الوقت المقدر للوصول: $_estimatedTime',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (_status == 'assigned' || _status == 'picked')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gps_fixed, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'مباشر',
                          style: TextStyle(fontSize: 10, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _cancelOrder,
          icon: const Icon(Icons.cancel),
          label: const Text('إلغاء الطلب'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RateDriverScreen()),
            );
          },
          icon: const Icon(Icons.star),
          label: const Text('تقييم السائق وإنهاء الطلب'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}