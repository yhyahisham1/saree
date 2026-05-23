// lib/screens/customer/buy_package_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';

class BuyPackageScreen extends StatefulWidget {
  const BuyPackageScreen({super.key});

  @override
  State<BuyPackageScreen> createState() => _BuyPackageScreenState();
}

class _BuyPackageScreenState extends State<BuyPackageScreen> {
  int _selectedPackageIndex = 0;
  String _paymentMethod = 'cash'; // cash, electronic
  String? _generatedCode;
  bool _showCode = false;
  bool _isLoading = false;
  
  // الباقات المتاحة
  final List<PackageModel> _packages = [
    PackageModel(
      name: 'باقة تجريبية',
      orders: 5,
      price: 5,
      originalPrice: 5,
      discount: 0,
      isPopular: false,
      icon: Icons.rocket_launch,
    ),
    PackageModel(
      name: 'باقة شعبية',
      orders: 10,
      price: 9,
      originalPrice: 10,
      discount: 10,
      isPopular: true,
      icon: Icons.trending_up,
    ),
    PackageModel(
      name: 'باقة اقتصادية',
      orders: 20,
      price: 17,
      originalPrice: 20,
      discount: 15,
      isPopular: false,
      icon: Icons.savings,
    ),
    PackageModel(
      name: 'باقة تجارية',
      orders: 50,
      price: 40,
      originalPrice: 50,
      discount: 20,
      isPopular: false,
      icon: Icons.business,
    ),
  ];
  
  // قائمة الوكلاء المعتمدين
  final List<AgentModel> _agents = [
    AgentModel(
      name: 'بقالة السلام',
      address: 'الرمال - شارع الوحدة، مقابل عمارة الأمل',
      phone: '0591234567',
      workingHours: '8:00 ص - 11:00 م',
      rating: 4.8,
    ),
    AgentModel(
      name: 'صيدلية الشفاء',
      address: 'المنطقة الغربية - شارع الجيش، مجمع الشفاء',
      phone: '0597654321',
      workingHours: '24 ساعة',
      rating: 4.9,
    ),
    AgentModel(
      name: 'مكتبة الأندلس',
      address: 'حي الزيتون - شارع الثلاثيني، بجانب مسجد السلام',
      phone: '0591122334',
      workingHours: '9:00 ص - 9:00 م',
      rating: 4.7,
    ),
    AgentModel(
      name: 'سوبر ماركت الخير',
      address: 'الشجاعية - دوار أبو خضير، عمارة 15',
      phone: '0595566778',
      workingHours: '8:00 ص - 12:00 م',
      rating: 4.8,
    ),
    AgentModel(
      name: 'مخبز الأمل',
      address: 'الرمال - شارع النصر، بجانب البنك الإسلامي',
      phone: '0599988776',
      workingHours: '6:00 ص - 10:00 م',
      rating: 4.6,
    ),
  ];

  PackageModel get _selectedPackage => _packages[_selectedPackageIndex];

  void _generateCode() {
    // توليد كود عشوائي مكون من 6 أرقام
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    final code = random.toString().padLeft(6, '0').substring(0, 6);
    
    setState(() {
      _generatedCode = code;
      _showCode = true;
    });
    
    // نسخ الكود تلقائياً
    Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('تم نسخ الكود بنجاح');
  }

  void _buyPackage() {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة عملية الشراء
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _generateCode();
    });
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

  void _copyCode() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      _showSnackBar('تم نسخ الكود بنجاح');
    }
  }

  void _callAgent(String phone) {
    // يمكن إضافة url_launcher لاحقاً
    _showSnackBar('الاتصال بـ $phone');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentBalance = authProvider.remainingOrders;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('شحن الرصيد'),
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
                // بطاقة الرصيد الحالي
                _buildBalanceCard(currentBalance),
                const SizedBox(height: 24),
                
                // عنوان الباقات
                const Text(
                  'اختر الباقة المناسبة لك',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ادفع مرة واحدة واحصل على طلباتك',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                const SizedBox(height: 16),
                
                // قائمة الباقات
                ..._packages.asMap().entries.map((entry) => 
                  _buildPackageCard(entry.value, entry.key == _selectedPackageIndex)
                ),
                
                const SizedBox(height: 24),
                
                // طريقة الدفع
                const Text(
                  'طريقة الدفع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethods(),
                
                const SizedBox(height: 24),
                
                // كود التفعيل (إذا تم إنشاؤه)
                if (_showCode && _generatedCode != null)
                  _buildCodeCard(),
                
                const SizedBox(height: 24),
                
                // زر الشراء
                _buildBuyButton(),
                
                const SizedBox(height: 24),
                
                // قائمة الوكلاء المعتمدين
                _buildAgentsSection(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(int balance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
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
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رصيدك الحالي',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance طلب',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (balance < 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'رصيد منخفض',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PackageModel pkg, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPackageIndex = _packages.indexOf(pkg);
        _showCode = false;
        _generatedCode = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : pkg.isPopular ? AppColors.secondary : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                pkg.icon,
                color: isSelected ? AppColors.primary : pkg.isPopular ? AppColors.secondary : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pkg.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                        ),
                      ),
                      if (pkg.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'الأكثر مبيعاً',
                            style: TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pkg.orders} طلب',
                    style: TextStyle(fontSize: 13, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (pkg.discount > 0)
                  Text(
                    '${pkg.originalPrice} شيكل',
                    style: TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textLight,
                    ),
                  ),
                Text(
                  '${pkg.price} شيكل',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.secondary,
                  ),
                ),
                if (pkg.discount > 0)
                  Text(
                    'خصم ${pkg.discount}%',
                    style: TextStyle(fontSize: 11, color: AppColors.success),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(color: AppColors.border),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            title: 'نقدي',
            subtitle: 'عبر الوكيل المحلي',
            icon: Icons.store,
            isSelected: _paymentMethod == 'cash',
            isEnabled: true,
            onTap: () => setState(() => _paymentMethod = 'cash'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            title: 'إلكتروني',
            subtitle: 'بطاقة ائتمان',
            icon: Icons.credit_card,
            isSelected: _paymentMethod == 'electronic',
            isEnabled: false,
            onTap: () {
              _showSnackBar('قريباً', isError: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected && isEnabled ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && isEnabled ? AppColors.primary : AppColors.border,
            width: isSelected && isEnabled ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: !isEnabled
                  ? AppColors.textLight
                  : (isSelected ? AppColors.primary : AppColors.textGray),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: !isEnabled
                    ? AppColors.textLight
                    : (isSelected ? AppColors.primary : AppColors.textDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: !isEnabled ? AppColors.textLight : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
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
          const Icon(Icons.qr_code, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'كود التفعيل الخاص بك',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedCode!,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أعطِ هذا الكود لأقرب وكيل محلي لتفعيل رصيدك',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('نسخ الكود'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCode = false;
                      _generatedCode = null;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('إغلاق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    final package = _selectedPackage;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _buyPackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'شراء الباقة (${package.price} شيكل)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAgentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📍 الوكلاء المعتمدون',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _showSnackBar('سيتم إضافة المزيد من الوكلاء قريباً');
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _agents.length,
            itemBuilder: (context, index) {
              final agent = _agents[index];
              return _buildAgentCard(agent);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard(AgentModel agent) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          agent.rating.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primary),
                onPressed: () => _callAgent(agent.phone),
                iconSize: 20,
              ),
            ],
          ),
          const Divider(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: AppColors.textGray),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  agent.address,
                  style: TextStyle(fontSize: 10, color: AppColors.textGray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(
                agent.workingHours,
                style: TextStyle(fontSize: 10, color: AppColors.textGray),
              ),
            ],
          ),
        ],
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
              'جاري إنشاء كود التفعيل...',
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

class PackageModel {
  final String name;
  final int orders;
  final int price;
  final int originalPrice;
  final int discount;
  final bool isPopular;
  final IconData icon;

  PackageModel({
    required this.name,
    required this.orders,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.isPopular,
    required this.icon,
  });
}

class AgentModel {
  final String name;
  final String address;
  final String phone;
  final String workingHours;
  final double rating;

  AgentModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.workingHours,
    required this.rating,
  });
}