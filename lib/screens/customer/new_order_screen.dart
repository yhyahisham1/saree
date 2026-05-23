// lib/screens/customer/new_order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import 'track_order_screen.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  // State
  String _selectedPackageType = 'normal';
  bool _isLoading = false;
  bool _useMyLocation = false;
  
  // Package types
  final List<PackageType> _packageTypes = [
    PackageType(value: 'normal', label: 'طرد عادي', icon: Icons.inventory, color: AppColors.primary),
    PackageType(value: 'fragile', label: 'قابل للكسر', icon: Icons.warning_amber, color: AppColors.warning),
    PackageType(value: 'document', label: 'مستندات', icon: Icons.description, color: AppColors.secondary),
  ];
  
  // Sample locations (للتجربة)
  final List<Map<String, String>> _savedLocations = [
    {'name': 'المنزل', 'address': 'الرمال - شارع الوحدة'},
    {'name': 'العمل', 'address': 'الزيتون - شارع الثلاثيني'},
    {'name': 'المتجر', 'address': 'الشجاعية - دوار أبو خضير'},
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _receiverPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // التحقق من الرصيد
    if (!authProvider.canPlaceOrder) {
      _showSnackBar('لا يوجد رصيد كافٍ. يرجى شحن الرصيد أولاً', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    // محاكاة إنشاء طلب
    await Future.delayed(const Duration(seconds: 2));
    
    // خصم طلب واحد
    await authProvider.deductOneOrder();
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    _showSnackBar('تم إنشاء طلبك بنجاح! جاري البحث عن سائق...');
    
    // الانتقال لشاشة التتبع
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TrackOrderScreen(
          orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        ),
      ),
    );
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

  void _showLocationPicker(TextEditingController controller, String title) {
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
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._savedLocations.map((location) => ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location['name']!),
                subtitle: Text(location['address']!),
                onTap: () {
                  controller.text = location['address']!;
                  Navigator.pop(context);
                },
              )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('استخدام موقعي الحالي'),
                onTap: () {
                  controller.text = 'الموقع الحالي (جاري التحديد...)';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final remainingOrders = authProvider.remainingOrders;
    final hasLowBalance = remainingOrders < 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلب توصيلة جديد'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الرصيد
                  _buildBalanceCard(remainingOrders, hasLowBalance),
                  const SizedBox(height: 24),
                  
                  // عنوان الاستلام
                  _buildPickupField(),
                  const SizedBox(height: 16),
                  
                  // عنوان التسليم
                  _buildDeliveryField(),
                  const SizedBox(height: 16),
                  
                  // أيقونة التبديل بين العناوين
                  _buildSwapButton(),
                  const SizedBox(height: 16),
                  
                  // نوع الطرد
                  _buildPackageTypeSection(),
                  const SizedBox(height: 16),
                  
                  // رقم المستلم
                  _buildReceiverPhoneField(),
                  const SizedBox(height: 16),
                  
                  // ملاحظات
                  _buildNotesField(),
                  const SizedBox(height: 24),
                  
                  // ملخص الطلب
                  _buildOrderSummary(),
                  const SizedBox(height: 32),
                  
                  // زر تأكيد
                  _buildConfirmButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(int remainingOrders, bool hasLowBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasLowBalance
              ? [AppColors.warning, AppColors.warning.withOpacity(0.8)]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رصيدك المتبقي',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$remainingOrders طلب',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (hasLowBalance)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'رصيد منخفض',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📍 من أين؟',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pickupController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اختر موقع الاستلام',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () => _showLocationPicker(_pickupController, 'موقع الاستلام'),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان الاستلام';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.my_location, color: AppColors.primary),
                onPressed: () {
                  _pickupController.text = 'الموقع الحالي - الرمال';
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏁 إلى أين؟',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _deliveryController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اختر موقع التسليم',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () => _showLocationPicker(_deliveryController, 'موقع التسليم'),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان التسليم';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.my_location, color: AppColors.primary),
                onPressed: () {
                  _deliveryController.text = 'الموقع الحالي - الرمال';
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // تبديل العناوين
          final temp = _pickupController.text;
          _pickupController.text = _deliveryController.text;
          _deliveryController.text = temp;
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.swap_vert, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildPackageTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📦 نوع الطرد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: _packageTypes.map((type) {
            final isSelected = _selectedPackageType == type.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPackageType = type.value),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? type.color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(type.icon, color: isSelected ? type.color : AppColors.textGray),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? type.color : AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReceiverPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📞 رقم المستلم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _receiverPhoneController,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'اختياري - إذا كان مختلفاً عن رقمك',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 ملاحظات للسائق',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'مثال: جرس الباب مكسور، اتصل قبل الوصول',
            prefixIcon: Icon(Icons.note_outlined),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تكلفة التوصيل', style: TextStyle(fontSize: 14)),
              const Text('1 شيكل', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '1 شيكل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    final canOrder = authProvider.canPlaceOrder;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canOrder && !_isLoading ? _createOrder : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'تأكيد الطلب',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              'جاري إنشاء الطلب...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Package Type Model
class PackageType {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  PackageType({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}