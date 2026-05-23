// lib/screens/driver/driver_orders_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// نموذج الطلب النشط
class ActiveOrder {
  final String id;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final String statusText;
  final String customerName;
  final String customerPhone;
  final String remainingTime;
  final String orderTime;
  final String distance;  // ✅ غير من double إلى String

  ActiveOrder({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.statusText,
    required this.customerName,
    required this.customerPhone,
    required this.remainingTime,
    required this.orderTime,
    required this.distance,
  });
}

// نموذج الطلب المكتمل
class CompletedOrder {
  final String id;
  final String pickupAddress;
  final String deliveryAddress;
  final String date;
  final String time;
  final int price;
  final String customerName;
  final int customerRating;
  final double earnings;

  CompletedOrder({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.date,
    required this.time,
    required this.price,
    required this.customerName,
    required this.customerRating,
    required this.earnings,
  });
}

class DriverOrdersScreen extends StatefulWidget {
  final List<ActiveOrder>? activeOrders;
  
  const DriverOrdersScreen({
    super.key,
    this.activeOrders,
  });

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<ActiveOrder> _activeOrders = [];
  List<CompletedOrder> _completedOrders = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  
  int _totalDeliveries = 0;
  double _totalEarnings = 0;
  double _averageRating = 0;

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
    await Future.delayed(const Duration(milliseconds: 800));
    
    _activeOrders = widget.activeOrders ?? [
      ActiveOrder(
        id: 'ORD-12345',
        pickupAddress: 'الرمال - شارع النصر، عمارة 10',
        deliveryAddress: 'الشجاعية - دوار أبو خضير، مجمع 5',
        status: 'picked',
        statusText: 'تم الاستلام',
        customerName: 'أحمد محمد',
        customerPhone: '0591234567',
        remainingTime: '5-10 دقائق',
        orderTime: '10:30',
        distance: '2.5 كم',  // ✅ String
      ),
      ActiveOrder(
        id: 'ORD-12346',
        pickupAddress: 'الزيتون - شارع الجيش، بناية 3',
        deliveryAddress: 'الرمال - شارع الوحدة، عمارة 15',
        status: 'accepted',
        statusText: 'قيد التنفيذ',
        customerName: 'سارة خالد',
        customerPhone: '0597654321',
        remainingTime: '15-20 دقيقة',
        orderTime: '11:00',
        distance: '3.8 كم',  // ✅ String
      ),
    ];
    
    _completedOrders = [
      CompletedOrder(
        id: 'ORD-12344',
        pickupAddress: 'الرمال - شارع الوحدة',
        deliveryAddress: 'الزيتون - دوار أبو حصيرة',
        date: '2025-05-20',
        time: '10:30',
        price: 1,
        customerName: 'محمد علي',
        customerRating: 5,
        earnings: 1.0,
      ),
      CompletedOrder(
        id: 'ORD-12343',
        pickupAddress: 'الشجاعية - شارع الثلاثيني',
        deliveryAddress: 'الرمال - برج الأمل',
        date: '2025-05-19',
        time: '14:15',
        price: 1,
        customerName: 'نور عادل',
        customerRating: 4,
        earnings: 1.0,
      ),
      CompletedOrder(
        id: 'ORD-12342',
        pickupAddress: 'المنطقة الغربية - عمارة 5',
        deliveryAddress: 'حي الزيتون - شارع الجيش',
        date: '2025-05-18',
        time: '09:45',
        price: 1,
        customerName: 'خالد سعيد',
        customerRating: 5,
        earnings: 1.0,
      ),
      CompletedOrder(
        id: 'ORD-12341',
        pickupAddress: 'الرمال - برج فلسطين',
        deliveryAddress: 'الشجاعية - دوار أبو خضير',
        date: '2025-05-17',
        time: '16:20',
        price: 1,
        customerName: 'ريم حسن',
        customerRating: 3,
        earnings: 1.0,
      ),
    ];
    
    _totalDeliveries = _completedOrders.length;
    _totalEarnings = _completedOrders.fold(0, (sum, order) => sum + order.earnings);
    _averageRating = _completedOrders.isEmpty 
        ? 0 
        : _completedOrders.fold(0, (sum, order) => sum + order.customerRating) / _completedOrders.length;
    
    setState(() => _isLoading = false);
  }

  Future<void> _updateOrderStatus(ActiveOrder order, String newStatus, String statusText) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديث حالة الطلب #${order.id}'),
        content: Text('هل أنت متأكد من تحديث الحالة إلى "$statusText"؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        final index = _activeOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _activeOrders[index] = ActiveOrder(
            id: order.id,
            pickupAddress: order.pickupAddress,
            deliveryAddress: order.deliveryAddress,
            status: newStatus,
            statusText: statusText,
            customerName: order.customerName,
            customerPhone: order.customerPhone,
            remainingTime: newStatus == 'delivered' ? 'تم التوصيل' : order.remainingTime,
            orderTime: order.orderTime,
            distance: order.distance,
          );
        }
      });
      _showSnackBar('تم تحديث حالة الطلب');
      
      if (newStatus == 'delivered') {
        _showRatingDialog(order);
      }
    }
  }

  void _showRatingDialog(ActiveOrder order) async {
    double rating = 0;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('تقييم العميل'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('كيف كانت تجربتك مع ${order.customerName}؟'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setStateDialog(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تخطي'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar('شكراً لتقييمك');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('إرسال'),
              ),
            ],
          );
        },
      ),
    );
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

  void _callCustomer(String phone) {
    _showSnackBar('جارٍ الاتصال بـ $phone');
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return '🟡';
      case 'picked': return '📦';
      case 'delivered': return '✅';
      default: return '🟡';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        _buildStatsBar(),
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'جاري التنفيذ'),
              Tab(text: 'سجل الطلبات'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveOrders(),
              _buildCompletedOrders(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.delivery_dining, 'توصيلات', _totalDeliveries.toString()),
          _buildStatItem(Icons.attach_money, 'الأرباح', '${_totalEarnings.toStringAsFixed(1)} شيكل'),
          _buildStatItem(Icons.star, 'التقييم', _averageRating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActiveOrders() {
    if (_activeOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('لا توجد طلبات نشطة'),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeOrders.length,
        itemBuilder: (context, index) {
          final order = _activeOrders[index];
          return _buildActiveOrderCard(order);
        },
      ),
    );
  }

  Widget _buildActiveOrderCard(ActiveOrder order) {
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
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusIcon(order.status),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.statusText,
                            style: TextStyle(fontSize: 11, color: _getStatusColor(order.status)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(
                      'طلب في ${order.orderTime}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.straighten, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(
                      order.distance,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAddressRow(Icons.location_on, order.pickupAddress, true),
                const SizedBox(height: 8),
                _buildAddressRow(Icons.flag, order.deliveryAddress, false),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _callCustomer(order.customerPhone),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.phone, size: 16, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.status != 'delivered')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text(
                            'الوقت المتبقي: ${order.remainingTime}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
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
            child: Row(
              children: [
                if (order.status == 'accepted')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(order, 'picked', 'تم الاستلام'),
                      icon: const Icon(Icons.inventory, size: 18),
                      label: const Text('تم الاستلام'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (order.status == 'picked')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(order, 'delivered', 'تم التوصيل'),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('تم التوصيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (order.status != 'delivered')
                  const SizedBox(width: 12),
                if (order.status != 'delivered')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateOrderStatus(order, 'cancelled', 'ملغي'),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedOrders() {
    List<CompletedOrder> filteredOrders = List.from(_completedOrders);
    
    if (_selectedFilter == 'today') {
      final today = DateTime.now().toString().substring(0, 10);
      filteredOrders = filteredOrders.where((o) => o.date == today).toList();
    } else if (_selectedFilter == 'week') {
      filteredOrders = filteredOrders.take(3).toList();
    }
    
    if (filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('لا توجد طلبات مكتملة'),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('الكل', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('اليوم', 'today'),
              const SizedBox(width: 8),
              _buildFilterChip('آخر 7 أيام', 'week'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildCompletedOrderCard(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? AppColors.primary : AppColors.textGray,
      ),
    );
  }

  Widget _buildCompletedOrderCard(CompletedOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star,
                  size: 14,
                  color: index < order.customerRating ? Colors.amber : AppColors.border,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.date} - ${order.time}',
            style: TextStyle(fontSize: 11, color: AppColors.textGray),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.pickupAddress} → ${order.deliveryAddress}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Text(order.customerName, style: const TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                '${order.earnings.toStringAsFixed(2)} شيكل',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
              ),
            ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.warning;
      case 'picked': return AppColors.primary;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textGray;
    }
  }
}