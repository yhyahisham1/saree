import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import 'driver_orders_screen.dart';

// Models
class AvailableOrder {
  final String id;
  final String pickupAddress;
  final String deliveryAddress;
  final String distance;
  final String estimatedTime;
  final int price;
  final String customerName;
  final String customerPhone;
  final String orderTime;

  AvailableOrder({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.estimatedTime,
    required this.price,
    required this.customerName,
    required this.customerPhone,
    required this.orderTime,
  });
}

class ActiveOrder {
  final String id;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final String statusText;
  final String customerName;
  final String customerPhone;
  final String remainingTime;

  ActiveOrder({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.statusText,
    required this.customerName,
    required this.customerPhone,
    required this.remainingTime,
  });
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<AvailableOrder> _availableOrders = [];
  List<ActiveOrder> _activeOrders = [];
  
  bool _isLoading = true;
  
  int _totalDeliveries = 0;
  double _averageRating = 4.8;
  int _todayDeliveries = 0;
  double _todayEarnings = 0;
  int _remainingForReward = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDriverData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    
    _totalDeliveries = 45;
    _averageRating = 4.8;
    _todayDeliveries = 3;
    _todayEarnings = 3.0;
    _remainingForReward = 100 - (_totalDeliveries % 100);
    
    _availableOrders = [
      AvailableOrder(
        id: 'ORD-12346',
        pickupAddress: 'الرمال - شارع الوحدة، عمارة 10',
        deliveryAddress: 'الزيتون - دوار أبو حصيرة',
        distance: '2.5 كم',
        estimatedTime: '10-15 دقيقة',
        price: 1,
        customerName: 'أحمد محمد',
        customerPhone: '0591234567',
        orderTime: '10:30',
      ),
      AvailableOrder(
        id: 'ORD-12347',
        pickupAddress: 'الشجاعية - شارع الثلاثيني',
        deliveryAddress: 'الرمال - برج الأمل',
        distance: '3.2 كم',
        estimatedTime: '15-20 دقيقة',
        price: 1,
        customerName: 'سارة خالد',
        customerPhone: '0597654321',
        orderTime: '10:45',
      ),
      AvailableOrder(
        id: 'ORD-12348',
        pickupAddress: 'المنطقة الغربية - عمارة 5',
        deliveryAddress: 'حي الزيتون - شارع الجيش',
        distance: '1.8 كم',
        estimatedTime: '8-12 دقيقة',
        price: 1,
        customerName: 'محمد علي',
        customerPhone: '0591122334',
        orderTime: '11:00',
      ),
    ];
    
    _activeOrders = [
      ActiveOrder(
        id: 'ORD-12345',
        pickupAddress: 'الرمال - شارع النصر',
        deliveryAddress: 'الشجاعية - دوار أبو خضير',
        status: 'picked',
        statusText: 'تم الاستلام',
        customerName: 'نور عادل',
        customerPhone: '0595566778',
        remainingTime: '5-10 دقائق',
      ),
    ];
    
    setState(() => _isLoading = false);
  }

  Future<void> _acceptOrder(AvailableOrder order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الطلب #${order.id}'),
            const SizedBox(height: 8),
            Text('من: ${order.pickupAddress}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('إلى: ${order.deliveryAddress}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text('المسافة: ${order.distance}', style: const TextStyle(fontSize: 12)),
            Text('الوقت المقدر: ${order.estimatedTime}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رفض'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        _availableOrders.removeWhere((o) => o.id == order.id);
      });
      _showSnackBar('تم قبول الطلب بنجاح');
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user?.fullName ?? 'السائق'),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAvailableOrders(),
                        Container(  // مؤقتاً
                          child: const Center(child: Text('طلباتي الحالية - قريباً')),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pedal_bike, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildStatCard(Icons.delivery_dining, 'توصيلات', _totalDeliveries.toString()),
              _buildStatCard(Icons.star, 'التقييم', _averageRating.toString()),
              _buildStatCard(Icons.today, 'اليوم', _todayDeliveries.toString()),
              _buildStatCard(Icons.attach_money, 'الأرباح', '$_todayEarnings'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'متبقي $_remainingForReward توصيلة للمكافأة',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(child: Text('طلبات متاحة')),
          Tab(child: Text('طلباتي الحالية')),
        ],
      ),
    );
  }

  Widget _buildAvailableOrders() {
    if (_availableOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات متاحة حالياً',
              style: TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 8),
            Text(
              'اسحب للأسفل للتحديث',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDriverData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableOrders.length,
        itemBuilder: (context, index) {
          final order = _availableOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(AvailableOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'طلب جديد',
                        style: TextStyle(fontSize: 11, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildAddressRow(Icons.location_on, order.pickupAddress, true),
                const SizedBox(height: 8),
                _buildAddressRow(Icons.flag, order.deliveryAddress, false),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildInfoChip(Icons.straighten, order.distance),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.timer, order.estimatedTime),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.attach_money, '${order.price} شيكل'),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(order.customerName, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(order.customerPhone, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _acceptOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('قبول الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String address, bool isPickup) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isPickup ? AppColors.primary : AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGray),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}