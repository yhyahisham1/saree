// lib/screens/customer/orders_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'track_order_screen.dart';
import 'rate_driver_screen.dart';
import 'new_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // قائمة الطلبات
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _completedOrders = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 800));

    // بيانات تجريبية
    _activeOrders = [
      OrderModel(
        id: 'ORD-12344',
        date: '2025-05-20',
        time: '10:30',
        status: OrderStatus.inProgress,
        statusText: 'في الطريق',
        price: 1,
        pickupAddress: 'الرمال - شارع الوحدة',
        deliveryAddress: 'الزيتون - دوار أبو حصيرة',
        driverName: 'أحمد محمد',
        driverRating: 4.8,
        driverPhone: '0591234567',
        estimatedTime: '10-15 دقيقة',
      ),
      OrderModel(
        id: 'ORD-12342',
        date: '2025-05-19',
        time: '14:15',
        status: OrderStatus.pending,
        statusText: 'جاري البحث عن سائق',
        price: 1,
        pickupAddress: 'الشجاعية - شارع الثلاثيني',
        deliveryAddress: 'الرمال - برج الأمل',
        driverName: null,
        driverRating: null,
        driverPhone: null,
        estimatedTime: 'جاري البحث...',
      ),
    ];

    _completedOrders = [
      OrderModel(
        id: 'ORD-12345',
        date: '2025-05-21',
        time: '18:30',
        status: OrderStatus.completed,
        statusText: 'تم التوصيل',
        price: 1,
        pickupAddress: 'المنطقة الغربية - عمارة 5',
        deliveryAddress: 'الرمال - شارع الثلاثيني',
        driverName: 'محمد سعيد',
        driverRating: 4.9,
        driverPhone: '0597654321',
        isRated: true,
      ),
      OrderModel(
        id: 'ORD-12343',
        date: '2025-05-18',
        time: '09:45',
        status: OrderStatus.completed,
        statusText: 'تم التوصيل',
        price: 1,
        pickupAddress: 'حي الزيتون - شارع الجيش',
        deliveryAddress: 'الشجاعية - دوار أبو خضير',
        driverName: 'خالد علي',
        driverRating: 4.7,
        driverPhone: '0591122334',
        isRated: false,
      ),
      OrderModel(
        id: 'ORD-12341',
        date: '2025-05-17',
        time: '16:20',
        status: OrderStatus.cancelled,
        statusText: 'ملغي',
        price: 1,
        pickupAddress: 'الرمال - برج فلسطين',
        deliveryAddress: 'المنطقة الغربية - مجمع الكليات',
        driverName: null,
        driverRating: null,
        driverPhone: null,
      ),
    ];

    setState(() => _isLoading = false);
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  void _reorder(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewOrderScreen(),
      ),
    );
  }

  void _trackOrder(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackOrderScreen(orderId: order.id),
      ),
    );
  }

void _rateDriver(OrderModel order) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const RateDriverScreen(), // بدون معاملات إضافية
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلباتي'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(),
        ),
      ),
      body: _isLoading
          ? _buildShimmerEffect()
          : RefreshIndicator(
              onRefresh: _refreshOrders,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(_activeOrders, isActive: true),
                  _buildOrdersList(_completedOrders, isActive: false),
                ],
              ),
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pending_actions, size: 18),
                const SizedBox(width: 6),
                Text('قيد التنفيذ (${_activeOrders.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 6),
                Text('السابقة (${_completedOrders.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.pending_outlined : Icons.history_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'لا توجد طلبات قيد التنفيذ' : 'لا توجد طلبات سابقة',
              style: TextStyle(color: AppColors.textGray, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (!isActive)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewOrderScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('طلب جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, isActive: isActive);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStatusIcon(order.status),
                        size: 18,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${order.date} - ${order.time}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // محتوى البطاقة
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العناوين
                _buildAddressRow(
                    Icons.location_on, 'من: ${order.pickupAddress}',
                    isPrimary: true),
                const SizedBox(height: 8),
                _buildAddressRow(Icons.flag, 'إلى: ${order.deliveryAddress}',
                    isPrimary: false),

                const Divider(height: 20),

                // السعر والسائق (للطلبات النشطة أو المكتملة)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${order.price} شيكل',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (order.driverName != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            order.driverRating?.toString() ?? '4.5',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.driverName!,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textGray),
                          ),
                        ],
                      ),
                  ],
                ),

                if (isActive && order.estimatedTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'الوقت المقدر: ${order.estimatedTime}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // أزرار الإجراءات
                Row(
                  children: [
                    if (isActive)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _trackOrder(order),
                          icon: const Icon(Icons.location_on, size: 18),
                          label: const Text('تتبع'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (!isActive &&
                        order.status == OrderStatus.completed &&
                        !order.isRated)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rateDriver(order),
                          icon: const Icon(Icons.star, size: 18),
                          label: const Text('تقييم'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (!isActive &&
                        order.status == OrderStatus.completed &&
                        order.isRated)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reorder(order),
                          icon: const Icon(Icons.replay, size: 18),
                          label: const Text('طلب مرة أخرى'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (!isActive && order.status == OrderStatus.cancelled)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reorder(order),
                          icon: const Icon(Icons.replay, size: 18),
                          label: const Text('إعادة الطلب'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (isActive && order.status == OrderStatus.pending)
                      const SizedBox(width: 12),
                    if (isActive && order.status == OrderStatus.pending)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelOrder(order),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('إلغاء'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String text,
      {required bool isPrimary}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: isPrimary ? AppColors.primary : AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Text('هل أنت متأكد من إلغاء الطلب #${order.id}؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _activeOrders.removeWhere((o) => o.id == order.id);
              });
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.inProgress:
        return AppColors.primary;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.inProgress:
        return Icons.delivery_dining;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// ============================================================
// Model
// ============================================================

enum OrderStatus { pending, inProgress, completed, cancelled }

class OrderModel {
  final String id;
  final String date;
  final String time;
  final OrderStatus status;
  final String statusText;
  final int price;
  final String pickupAddress;
  final String deliveryAddress;
  final String? driverName;
  final double? driverRating;
  final String? driverPhone;
  final String? estimatedTime;
  final bool isRated;

  OrderModel({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.statusText,
    required this.price,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.driverName,
    this.driverRating,
    this.driverPhone,
    this.estimatedTime,
    this.isRated = false,
  });
}
