// lib/screens/customer/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all'; // all, unread
  
  // قائمة الإشعارات
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 800));
    
    // بيانات تجريبية
    _notifications = [
      NotificationModel(
        id: 'notif_001',
        title: 'تم قبول طلبك',
        message: 'تم قبول طلبك #ORD-12345 من قبل السائق أحمد محمد',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.order,
        isRead: false,
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        orderId: 'ORD-12345',
        action: 'تتبع الطلب',
      ),
      NotificationModel(
        id: 'notif_002',
        title: 'تم توصيل طلبك',
        message: 'تم توصيل طلبك #ORD-12344 بنجاح. قم بتقييم السائق',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.order,
        isRead: false,
        icon: Icons.local_shipping,
        iconColor: AppColors.primary,
        orderId: 'ORD-12344',
        action: 'تقييم',
      ),
      NotificationModel(
        id: 'notif_003',
        title: 'عرض خاص',
        message: 'احصل على 15% خصم على أول 5 طلبات. العرض محدود',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.promo,
        isRead: true,
        icon: Icons.local_offer,
        iconColor: AppColors.secondary,
        action: 'استفد الآن',
      ),
      NotificationModel(
        id: 'notif_004',
        title: 'تم شحن الرصيد',
        message: 'تم شحن رصيدك بنجاح، رصيدك الحالي: 10 طلبات',
        time: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.wallet,
        isRead: true,
        icon: Icons.wallet,
        iconColor: AppColors.success,
        action: 'شحن مرة أخرى',
      ),
      NotificationModel(
        id: 'notif_005',
        title: 'مكافأة ترحيبية',
        message: 'مرحباً بك في سريع! احصل على 5 طلبات مجانية كهدية ترحيبية',
        time: DateTime.now().subtract(const Duration(days: 5)),
        type: NotificationType.promo,
        isRead: true,
        icon: Icons.card_giftcard,
        iconColor: AppColors.tertiaryContainer,
        action: 'استلم الهدية',
      ),
      NotificationModel(
        id: 'notif_006',
        title: 'تحديث التطبيق',
        message: 'تحديث جديد متاح للتطبيق. قم بالتحديث للحصول على ميزات جديدة',
        time: DateTime.now().subtract(const Duration(days: 7)),
        type: NotificationType.system,
        isRead: true,
        icon: Icons.system_update,
        iconColor: AppColors.primary,
        action: 'تحديث الآن',
      ),
      NotificationModel(
        id: 'notif_007',
        title: 'تذكير برصيد منخفض',
        message: 'رصيدك على وشك النفاذ. قم بشحن الرصيد الآن لتتمكن من طلب التوصيلات',
        time: DateTime.now().subtract(const Duration(days: 10)),
        type: NotificationType.wallet,
        isRead: true,
        icon: Icons.warning_amber,
        iconColor: AppColors.warning,
        action: 'شحن الرصيد',
      ),
    ];
    
    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'unread') {
        _filteredNotifications = _notifications.where((n) => !n.isRead).toList();
      } else {
        _filteredNotifications = List.from(_notifications);
      }
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
        _applyFilter();
      });
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _applyFilter();
    });
    _showSnackBar('تم تعليم جميع الإشعارات كمقروءة');
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
      _applyFilter();
    });
    _showSnackBar('تم حذف الإشعار');
  }

  Future<void> _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكل'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        _notifications.clear();
        _applyFilter();
      });
      _showSnackBar('تم حذف جميع الإشعارات');
    }
  }

  void _onNotificationTap(NotificationModel notification) async {
    await _markAsRead(notification);
    
    // تنفيذ الإجراء حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.order:
        _showSnackBar('جاري فتح تفاصيل الطلب ${notification.orderId}');
        break;
      case NotificationType.promo:
        _showSnackBar('جاري تطبيق العرض...');
        break;
      case NotificationType.wallet:
        _showSnackBar('جاري فتح صفحة الشحن...');
        break;
      case NotificationType.system:
        _showSnackBar('جاري التحقق من التحديثات...');
        break;
    }
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        actions: [
          if (_filteredNotifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                } else if (value == 'delete_all') {
                  _deleteAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 18),
                      SizedBox(width: 12),
                      Text('تعليم الكل كمقروء'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 18, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('حذف الكل', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterBar(),
        ),
      ),
      body: _isLoading
          ? _buildShimmerEffect()
          : _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'all';
                  _applyFilter();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedFilter == 'all' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'الكل',
                    style: TextStyle(
                      color: _selectedFilter == 'all' ? Colors.white : AppColors.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'unread';
                  _applyFilter();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedFilter == 'unread' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'غير مقروء ($_unreadCount)',
                    style: TextStyle(
                      color: _selectedFilter == 'unread' ? Colors.white : AppColors.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification),
      child: GestureDetector(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // المحتوى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.time),
                          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (notification.action != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.action!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // نقطة غير مقروء
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 40,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الإشعارات عندما تستلمها',
            style: TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
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

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// ============================================================
// Models
// ============================================================

enum NotificationType { order, promo, wallet, system }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final String? orderId;
  final String? action;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    required this.icon,
    required this.iconColor,
    this.orderId,
    this.action,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    NotificationType? type,
    bool? isRead,
    IconData? icon,
    Color? iconColor,
    String? orderId,
    String? action,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      orderId: orderId ?? this.orderId,
      action: action ?? this.action,
    );
  }
}