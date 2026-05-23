// lib/screens/customer/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/auth/user_model.dart';
import 'new_order_screen.dart';
import 'orders_screen.dart';
import 'buy_package_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  bool _hasShownRatingDialog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAndShowRatingDialog();
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowRatingDialog() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_hasShownRatingDialog && mounted) {
      _hasShownRatingDialog = true;
      _showRatingDialog();
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'تقييم التطبيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل أعجبك تطبيق سريع؟ قم بتقييمنا على المتجر',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('لاحقاً'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('تقييم الآن'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareDialog() {
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
              const Text(
                'شارك التطبيق',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.chat,
                    color: const Color(0xFF25D366),
                    label: 'واتساب',
                    onTap: () => _shareApp('whatsapp'),
                  ),
                  _buildShareOption(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    label: 'فيسبوك',
                    onTap: () => _shareApp('facebook'),
                  ),
                  _buildShareOption(
                    icon: Icons.copy,
                    color: AppColors.primary,
                    label: 'نسخ الرابط',
                    onTap: () => _shareApp('copy'),
                  ),
                  _buildShareOption(
                    icon: Icons.more_horiz,
                    color: AppColors.textGray,
                    label: 'المزيد',
                    onTap: () => _shareApp('more'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _shareApp(String platform) async {
    const String appLink = 'https://saree3.app/download';
    
    if (platform == 'copy') {
      await Clipboard.setData(ClipboardData(text: appLink));
      _showSnackBar('تم نسخ الرابط بنجاح');
    } else {
      _showSnackBar('ميزة المشاركة قريباً');
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ============================================================
  // دوال العمولة حسب دور المستخدم (UserRole)
  // ============================================================
  
  double _getCommissionRate(UserRole role) {
    switch (role) {
      case UserRole.storeOwner:
        return 0.10;
      case UserRole.driver:
        return 0.08;
      case UserRole.agent:
        return 0.05;
      case UserRole.customer:
      case UserRole.admin:
      case UserRole.support:
        return 0.0;
    }
  }

  String _getCommissionText(UserRole role) {
    switch (role) {
      case UserRole.storeOwner:
        return 'عمولة المتجر';
      case UserRole.driver:
        return 'عمولة السائق';
      case UserRole.agent:
        return 'عمولة الوكيل';
      case UserRole.customer:
        return 'استخدام مجاني';
      case UserRole.admin:
      case UserRole.support:
        return 'صلاحيات كاملة';
    }
  }

  bool _showCommissionInfo(UserRole role) {
    return role == UserRole.storeOwner || 
           role == UserRole.driver || 
           role == UserRole.agent;
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer: return 'عميل';
      case UserRole.storeOwner: return 'صاحب متجر';
      case UserRole.driver: return 'سائق';
      case UserRole.agent: return 'وكيل محلي';
      case UserRole.admin: return 'مدير النظام';
      case UserRole.support: return 'دعم فني';
    }
  }

  // ============================================================
  // بناء الواجهة الرئيسية
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final remainingOrders = user?.prepaidOrdersBalance ?? 0;
    final hasLowBalance = remainingOrders < 5 && (user?.requiresPrepayment ?? false);
    final userRole = user?.role ?? UserRole.customer;
    final commissionRate = _getCommissionRate(userRole);
    final showCommissionInfo = _showCommissionInfo(userRole);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              userName: user?.fullName ?? 'العميل',
              userRole: userRole,
              user: user,
              hasLowBalance: hasLowBalance,
              remainingOrders: remainingOrders,
              showCommissionInfo: showCommissionInfo,
              commissionRate: commissionRate,
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeContent(),
                  OrdersScreen(),
                  BuyPackageScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader({
    required String userName,
    required UserRole userRole,
    required UserModel? user,
    required bool hasLowBalance,
    required int remainingOrders,
    required bool showCommissionInfo,
    required double commissionRate,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً 👋',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(userRole),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  if (showCommissionInfo) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.9), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'نسبة العمولة: ${(commissionRate * 100).toInt()}%',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  _buildHeaderIcon(Icons.share_outlined, () => _showShareDialog()),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(Icons.notifications_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  }),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(Icons.settings_outlined, () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // بطاقة الرصيد (للعملاء وأصحاب المتاجر)
          if (userRole == UserRole.customer || userRole == UserRole.storeOwner)
            _buildBalanceCard(remainingOrders, hasLowBalance),
          
          // بطاقة إحصائيات السائق
          if (userRole == UserRole.driver && user != null)
            _buildDriverStatsCard(user),
          
          // بطاقة إحصائيات الوكيل
          if (userRole == UserRole.agent && user != null)
            _buildAgentStatsCard(user),
          
          const SizedBox(height: 16),
          
          // إشعار الرصيد المنخفض
          if (hasLowBalance && (userRole == UserRole.customer || userRole == UserRole.storeOwner))
            _buildLowBalanceWarning(),
          
          if (!hasLowBalance && (userRole == UserRole.customer || userRole == UserRole.storeOwner))
            _buildRechargeButton(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(int remainingOrders, bool hasLowBalance) {
    return GestureDetector(
      onTap: () => _showRechargeDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رصيد الطلبات', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  '$remainingOrders',
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                const Text('طلب متبقي', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              ],
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: remainingOrders / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.backgroundGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasLowBalance ? AppColors.warning : AppColors.secondary,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 28,
                        color: hasLowBalance ? AppColors.warning : AppColors.secondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'متبقي',
                        style: TextStyle(
                          fontSize: 10,
                          color: hasLowBalance ? AppColors.warning : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStatsCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('عدد التوصيلات', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                '${user.totalDeliveries}',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const Text('توصيلة', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('التقييم', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    user.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentStatsCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('العمولة المجمعة', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                '${user.collectedCommission.toInt()}',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const Text('شيكل', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('الأكواد المصدرة', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                '${user.issuedCodes.length}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
              const SizedBox(height: 4),
              const Text('كود', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowBalanceWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('رصيدك منخفض! قم بشحنه الآن', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRechargeButton() {
    return GestureDetector(
      onTap: () => _showRechargeDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text('شحن الرصيد', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.index = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGray,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), activeIcon: Icon(Icons.wallet), label: 'شحن'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewOrderScreen()));
      },
      backgroundColor: AppColors.secondary,
      elevation: 4,
      child: const Icon(Icons.add, size: 32),
    );
  }

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          child: _buildRechargeDialogContent(context),
        );
      },
    );
  }

  Widget _buildRechargeDialogContent(BuildContext context) {
    final packages = [
      {'orders': 5, 'price': 5, 'discount': 0, 'isPopular': false},
      {'orders': 10, 'price': 9, 'discount': 10, 'isPopular': true},
      {'orders': 20, 'price': 17, 'discount': 15, 'isPopular': false},
      {'orders': 50, 'price': 40, 'discount': 20, 'isPopular': false},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('شحن الرصيد', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('اختر الباقة المناسبة لك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('ادفع مرة واحدة وستُخصم قيمة كل طلب تلقائياً', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                const SizedBox(height: 20),
                ...packages.map((pkg) => _buildPackageItem(
                  context,
                  orders: pkg['orders'] as int,
                  price: pkg['price'] as int,
                  discount: pkg['discount'] as int,
                  isPopular: pkg['isPopular'] as bool,
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textGray,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(BuildContext context, {
    required int orders,
    required int price,
    required int discount,
    required bool isPopular,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPackageScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPopular ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPopular ? AppColors.primary : AppColors.border, width: isPopular ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.card_giftcard, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$orders طلب', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (discount > 0) Text('خصم $discount%', style: TextStyle(fontSize: 11, color: AppColors.success)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (discount > 0)
                  Text('${orders} شيكل', style: TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textLight)),
                Text('$price شيكل', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// محتوى الصفحة الرئيسية
// ============================================================

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userRole = user?.role ?? UserRole.customer;
    final hasActiveOrder = false;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveOrder)
              _buildActiveOrderCard(userRole),
            if (!hasActiveOrder)
              _buildQuickOrderCard(userRole),
            _buildStatsCard(userRole, user),
            const SizedBox(height: 24),
            _buildMiniMap(),
            const SizedBox(height: 24),
            _buildOffersSection(userRole),
            const SizedBox(height: 24),
            _buildRecentOrdersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(UserRole userRole) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلب قيد التنفيذ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  userRole == UserRole.driver ? 'أنت السائق المكلف بهذا الطلب' : 'السائق في طريقه إليك',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text('تتبع', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOrderCard(UserRole userRole) {
    String title, subtitle;
    IconData icon;
    
    switch (userRole) {
      case UserRole.storeOwner:
        title = 'طلب شحن جديد';
        subtitle = 'أرسل طلب شحن لعملائك';
        icon = Icons.store;
        break;
      case UserRole.driver:
        title = 'توصيلة جديدة';
        subtitle = 'استلم طلب توصيل واكسب';
        icon = Icons.motorcycle;
        break;
      default:
        title = 'طلب توصيلة جديدة';
        subtitle = 'اطلب الآن وسيصلك طلبك خلال دقائق';
        icon = Icons.add_shopping_cart;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewOrderScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(UserRole userRole, UserModel? user) {
    List<Map<String, dynamic>> stats;
    
    switch (userRole) {
      case UserRole.storeOwner:
        stats = [
          {'value': '48', 'label': 'منتج', 'icon': Icons.inventory, 'color': AppColors.primary},
          {'value': '156', 'label': 'طلب', 'icon': Icons.shopping_cart, 'color': AppColors.success},
          {'value': '4.9', 'label': 'تقييم', 'icon': Icons.star, 'color': Colors.amber},
        ];
        break;
      case UserRole.driver:
        stats = [
          {'value': '${user?.totalDeliveries ?? 0}', 'label': 'توصيل', 'icon': Icons.delivery_dining, 'color': AppColors.primary},
          {'value': '${user?.remainingForReward ?? 0}', 'label': 'للمكافأة', 'icon': Icons.emoji_events, 'color': AppColors.warning},
          {'value': user?.rating.toStringAsFixed(1) ?? '0', 'label': 'تقييم', 'icon': Icons.star, 'color': Colors.amber},
        ];
        break;
      case UserRole.agent:
        stats = [
          {'value': '${user?.collectedCommission.toInt() ?? 0}', 'label': 'عمولة', 'icon': Icons.attach_money, 'color': AppColors.success},
          {'value': '${user?.issuedCodes.length ?? 0}', 'label': 'أكواد', 'icon': Icons.qr_code, 'color': AppColors.primary},
          {'value': '4.8', 'label': 'تقييم', 'icon': Icons.star, 'color': Colors.amber},
        ];
        break;
      default:
        stats = [
          {'value': '${user?.totalPrepaidOrders ?? 0}', 'label': 'طلبات سابقة', 'icon': Icons.history, 'color': AppColors.primary},
          {'value': '${user?.prepaidOrdersBalance ?? 0}', 'label': 'متبقي', 'icon': Icons.account_balance_wallet, 'color': AppColors.success},
          {'value': '4.8', 'label': 'تقييمي', 'icon': Icons.star, 'color': Colors.amber},
        ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) => _buildStatItem(
          stat['value'] as String,
          stat['label'] as String,
          stat['icon'] as IconData,
          stat['color'] as Color,
        )).toList(),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textGray)),
      ],
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.map, size: 60, color: AppColors.textGray),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: const Text('موقع السائق', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(UserRole userRole) {
    List<Map<String, dynamic>> offers;
    
    switch (userRole) {
      case UserRole.storeOwner:
        offers = [
          {'title': 'خصم 15%', 'subtitle': 'على أول 5 طلبات شحن', 'icon': Icons.local_offer, 'color': AppColors.secondary},
          {'title': 'شحن مجاني', 'subtitle': 'لأول شهر', 'icon': Icons.local_shipping, 'color': AppColors.primary},
          {'title': 'عمولة مخفضة', 'subtitle': '5% فقط لأول 3 أشهر', 'icon': Icons.percent, 'color': AppColors.tertiaryContainer},
        ];
        break;
      case UserRole.driver:
        offers = [
          {'title': 'عمولة أقل', 'subtitle': '6% فقط للسائقين الجدد', 'icon': Icons.percent, 'color': AppColors.secondary},
          {'title': 'مكافآت التوصيل', 'subtitle': '10 توصيلات = 50 شيكل', 'icon': Icons.emoji_events, 'color': AppColors.warning},
          {'title': 'توصيل إضافي', 'subtitle': 'احصل على طلبات إضافية', 'icon': Icons.add_circle, 'color': AppColors.primary},
        ];
        break;
      default:
        offers = [
          {'title': 'خصم 15%', 'subtitle': 'على أول 5 طلبات', 'icon': Icons.local_offer, 'color': AppColors.secondary},
          {'title': 'توصيل مجاني', 'subtitle': 'للطلبات فوق 20 شيكل', 'icon': Icons.local_shipping, 'color': AppColors.primary},
          {'title': 'هدية ترحيبية', 'subtitle': '5 طلبات مجانية', 'icon': Icons.card_giftcard, 'color': AppColors.tertiaryContainer},
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🎁 عروض خاصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [(offer['color'] as Color).withOpacity(0.1), (offer['color'] as Color).withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (offer['color'] as Color).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (offer['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(offer['icon'] as IconData, color: offer['color'] as Color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(offer['title'] as String,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: offer['color'] as Color)),
                          const SizedBox(height: 2),
                          Text(offer['subtitle'] as String, style: TextStyle(fontSize: 10, color: AppColors.textGray)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📋 آخر الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 12),
        _buildOrderCard(
          orderId: 'ORD-12345',
          status: 'تم التوصيل',
          statusColor: AppColors.success,
          date: '21/5/2025',
          price: '1 شيكل',
        ),
        const SizedBox(height: 12),
        _buildOrderCard(
          orderId: 'ORD-12344',
          status: 'في الطريق',
          statusColor: AppColors.warning,
          date: '20/5/2025',
          price: '1 شيكل',
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String status,
    required Color statusColor,
    required String date,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_getStatusIcon(status), color: statusColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(color: AppColors.textGray, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'تم التوصيل': return Icons.check_circle;
      case 'في الطريق': return Icons.delivery_dining;
      case 'ملغي': return Icons.cancel;
      default: return Icons.pending;
    }
  }
}