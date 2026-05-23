// lib/models/auth/user_model.dart
import 'package:flutter/material.dart';

/// أدوار المستخدمين في النظام
enum UserRole {
  customer,      // عميل عادي
  storeOwner,    // صاحب متجر
  driver,        // سائق
  agent,         // وكيل محلي
  admin,         // مدير النظام
  support,       // دعم فني
}

/// حالات التحقق من الدفع المسبق
enum PaymentVerificationStatus {
  pending,    // قيد المراجعة
  approved,   // تمت الموافقة
  rejected,   // مرفوض
}

/// حالات توثيق السائق
enum DriverVerificationStatus {
  pending,     // قيد المراجعة
  approved,    // موثق
  rejected,    // مرفوض
}

class UserModel {
  // === البيانات الأساسية ===
  final String id;
  final String fullName;
  final String phone;
  final String neighborhood;
  final UserRole role;

  // === بيانات المتجر (لأصحاب المتاجر) ===
  final String? storeName;
  final String? commercialRegister;

  // === توثيق السائق ===
  final DriverVerificationStatus driverVerificationStatus;
  final String? idCardImageUrl;     // صورة الهوية
  final String? bikeImageUrl;       // صورة الدراجة

// === بيانات الوكيل المحلي ===
  final double agentBalance;        // ✅ رصيد الوكيل الحالي (من الإدارة)
  final double agentTotalEarnings;  // ✅ إجمالي أرباح الوكيل (العمولات)
  final int agentTotalTransactions; //

  // === الرصيد والطلبات (للعملاء وأصحاب المتاجر والسائقين) ===
  final int prepaidOrdersBalance;   // عدد الطلبات المدفوعة مسبقاً (لأصحاب المتاجر والعملاء)
  final int totalPrepaidOrders;     // إجمالي الطلبات التي دفعها مسبقاً (للتاريخ)
  final PaymentVerificationStatus paymentVerification; // حالة التحقق من آخر دفعة

  // === بيانات السائق ===
  final double rating;              // متوسط التقييم
  final int totalDeliveries;        // إجمالي التوصيلات التي أتمها

  // === بيانات الوكيل المحلي ===
  final String? agentCode;          // كود الوكيل (للدخول)
  final double collectedCommission; // العمولة التي جمعها (للوكلاء)
  final List<String> issuedCodes;   // أكواد التفعيل التي أصدرها (للوكلاء)
  final double balance;             // ✅ رصيد الوكيل الحالي (قابل للسحب أو الشراء)

  // === بيانات عامة ===
  final String? profileImage;
  final bool isActive;              // هل الحساب مفعل؟
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.neighborhood,
    required this.role,
    this.storeName,
    this.commercialRegister,
    this.driverVerificationStatus = DriverVerificationStatus.pending,
    this.idCardImageUrl,
    this.bikeImageUrl,
    this.prepaidOrdersBalance = 0,
    this.totalPrepaidOrders = 0,
    this.paymentVerification = PaymentVerificationStatus.pending,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.agentCode,
    this.collectedCommission = 0.0,
    this.issuedCodes = const [],
    this.balance = 0.0,  // ✅ القيمة الافتراضية 0
    this.profileImage,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
    this.agentBalance = 0.0,
    this.agentTotalEarnings = 0.0,
    this.agentTotalTransactions = 0,
  });

  /// هل المستخدم مفعل ويمكنه استخدام التطبيق؟
  bool get canUseApp {
    if (!isActive) return false;

    switch (role) {
      case UserRole.driver:
        return driverVerificationStatus == DriverVerificationStatus.approved;
      case UserRole.agent:
        return agentCode != null && agentCode!.isNotEmpty;
      case UserRole.admin:
      case UserRole.support:
        return true;
      case UserRole.customer:
      case UserRole.storeOwner:
        return paymentVerification == PaymentVerificationStatus.approved && prepaidOrdersBalance > 0;
    }
  }

  /// هل يمكن للعميل/صاحب المتجر طلب توصيلة جديدة؟
  bool get canPlaceOrder {
    if (!canUseApp) return false;
    if (role != UserRole.customer && role != UserRole.storeOwner) return false;
    return prepaidOrdersBalance > 0;
  }

  /// كم توصيلة متبقية للمكافأة التالية (كل 100 توصيلة)
  int get remainingForReward {
    if (role != UserRole.driver) return 0;
    final remainder = totalDeliveries % 100;
    return remainder == 0 ? 100 : 100 - remainder;
  }

  /// هل استحق السائق المكافأة (كل 100 توصيلة)؟
  bool get hasReward {
    if (role != UserRole.driver) return false;
    return totalDeliveries > 0 && totalDeliveries % 100 == 0;
  }

  /// خصم طلب واحد من الرصيد (عند قبول الطلب لصاحب المتجر)
  UserModel deductOneOrder() {
    if (role != UserRole.customer && role != UserRole.storeOwner) return this;
    if (prepaidOrdersBalance <= 0) return this;

    return copyWith(
      prepaidOrdersBalance: prepaidOrdersBalance - 1,
      updatedAt: DateTime.now(),
    );
  }

  /// إضافة رصيد جديد (بعد الدفع المسبق)
  UserModel addPrepaidOrders(int additionalOrders, PaymentVerificationStatus verificationStatus) {
    if (role != UserRole.customer && role != UserRole.storeOwner) return this;

    return copyWith(
      prepaidOrdersBalance: prepaidOrdersBalance + additionalOrders,
      totalPrepaidOrders: totalPrepaidOrders + additionalOrders,
      paymentVerification: verificationStatus,
      isActive: verificationStatus == PaymentVerificationStatus.approved,
      updatedAt: DateTime.now(),
    );
  }

  /// زيادة عدد التوصيلات للسائق (بعد إتمام توصيلة)
  UserModel incrementDeliveries() {
    if (role != UserRole.driver) return this;

    return copyWith(
      totalDeliveries: totalDeliveries + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// إضافة عمولة للوكيل (من بيع الباقات)
  UserModel addCommission(double amount) {
    if (role != UserRole.agent) return this;
    return copyWith(
      collectedCommission: collectedCommission + amount,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ إضافة رصيد للوكيل (عند قبول طلب شحن)
  UserModel addBalance(double amount) {
    if (role != UserRole.agent) return this;
    return copyWith(
      balance: balance + amount,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ خصم من رصيد الوكيل (عند السحب أو الشراء)
  UserModel deductBalance(double amount) {
    if (role != UserRole.agent) return this;
    if (balance < amount) return this;
    return copyWith(
      balance: balance - amount,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ هل يمكن للوكيل سحب هذا المبلغ؟
  bool canWithdraw(double amount) {
    if (role != UserRole.agent) return false;
    return balance >= amount;
  }

  /// إضافة كود تفعيل أصدره الوكيل
  UserModel addIssuedCode(String code) {
    if (role != UserRole.agent) return this;
    return copyWith(
      issuedCodes: [...issuedCodes, code],
      updatedAt: DateTime.now(),
    );
  }

  // === JSON Serialization ===

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      role: _roleFromString(json['role'] ?? 'customer'),
      storeName: json['storeName'],
      commercialRegister: json['commercialRegister'],
      driverVerificationStatus: _driverVerificationFromString(json['driverVerificationStatus'] ?? 'pending'),
      idCardImageUrl: json['idCardImageUrl'],
      bikeImageUrl: json['bikeImageUrl'],
      prepaidOrdersBalance: json['prepaidOrdersBalance'] ?? 0,
      totalPrepaidOrders: json['totalPrepaidOrders'] ?? 0,
      paymentVerification: _paymentVerificationFromString(json['paymentVerification'] ?? 'pending'),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
      agentCode: json['agentCode'],
      collectedCommission: (json['collectedCommission'] ?? 0.0).toDouble(),
      issuedCodes: List<String>.from(json['issuedCodes'] ?? []),
      balance: (json['balance'] ?? 0.0).toDouble(),  // ✅ إضافة balance
      profileImage: json['profileImage'],
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      agentBalance: (json['agentBalance'] ?? 0).toDouble(),
      agentTotalEarnings: (json['agentTotalEarnings'] ?? 0).toDouble(),
      agentTotalTransactions: json['agentTotalTransactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'neighborhood': neighborhood,
      'role': _roleToString(role),
      'storeName': storeName,
      'commercialRegister': commercialRegister,
      'driverVerificationStatus': _driverVerificationToString(driverVerificationStatus),
      'idCardImageUrl': idCardImageUrl,
      'bikeImageUrl': bikeImageUrl,
      'prepaidOrdersBalance': prepaidOrdersBalance,
      'totalPrepaidOrders': totalPrepaidOrders,
      'paymentVerification': _paymentVerificationToString(paymentVerification),
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'agentCode': agentCode,
      'collectedCommission': collectedCommission,
      'issuedCodes': issuedCodes,
      'balance': balance,  // ✅ إضافة balance
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'agentBalance': agentBalance,
      'agentTotalEarnings': agentTotalEarnings,
      'agentTotalTransactions': agentTotalTransactions,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? neighborhood,
    UserRole? role,
    String? storeName,
    String? commercialRegister,
    DriverVerificationStatus? driverVerificationStatus,
    String? idCardImageUrl,
    String? bikeImageUrl,
    int? prepaidOrdersBalance,
    int? totalPrepaidOrders,
    PaymentVerificationStatus? paymentVerification,
    double? rating,
    int? totalDeliveries,
    String? agentCode,
    double? collectedCommission,
    List<String>? issuedCodes,
    double? balance,  // ✅ إضافة balance
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      neighborhood: neighborhood ?? this.neighborhood,
      role: role ?? this.role,
      storeName: storeName ?? this.storeName,
      commercialRegister: commercialRegister ?? this.commercialRegister,
      driverVerificationStatus: driverVerificationStatus ?? this.driverVerificationStatus,
      idCardImageUrl: idCardImageUrl ?? this.idCardImageUrl,
      bikeImageUrl: bikeImageUrl ?? this.bikeImageUrl,
      prepaidOrdersBalance: prepaidOrdersBalance ?? this.prepaidOrdersBalance,
      totalPrepaidOrders: totalPrepaidOrders ?? this.totalPrepaidOrders,
      paymentVerification: paymentVerification ?? this.paymentVerification,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      agentCode: agentCode ?? this.agentCode,
      collectedCommission: collectedCommission ?? this.collectedCommission,
      issuedCodes: issuedCodes ?? this.issuedCodes,
      balance: balance ?? this.balance,  // ✅ إضافة balance
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // === Helper methods for enum conversion ===

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'storeOwner': return UserRole.storeOwner;
      case 'driver': return UserRole.driver;
      case 'agent': return UserRole.agent;
      case 'admin': return UserRole.admin;
      case 'support': return UserRole.support;
      default: return UserRole.customer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.storeOwner: return 'storeOwner';
      case UserRole.driver: return 'driver';
      case UserRole.agent: return 'agent';
      case UserRole.admin: return 'admin';
      case UserRole.support: return 'support';
      default: return 'customer';
    }
  }

  static DriverVerificationStatus _driverVerificationFromString(String status) {
    switch (status) {
      case 'approved': return DriverVerificationStatus.approved;
      case 'rejected': return DriverVerificationStatus.rejected;
      default: return DriverVerificationStatus.pending;
    }
  }

  static String _driverVerificationToString(DriverVerificationStatus status) {
    switch (status) {
      case DriverVerificationStatus.approved: return 'approved';
      case DriverVerificationStatus.rejected: return 'rejected';
      default: return 'pending';
    }
  }

  static PaymentVerificationStatus _paymentVerificationFromString(String status) {
    switch (status) {
      case 'approved': return PaymentVerificationStatus.approved;
      case 'rejected': return PaymentVerificationStatus.rejected;
      default: return PaymentVerificationStatus.pending;
    }
  }

  static String _paymentVerificationToString(PaymentVerificationStatus status) {
    switch (status) {
      case PaymentVerificationStatus.approved: return 'approved';
      case PaymentVerificationStatus.rejected: return 'rejected';
      default: return 'pending';
    }
  }
}

// === Extension methods for easier access ===
extension UserModelExtension on UserModel {
  /// عرض نصي لدور المستخدم (للـ UI)
  String get roleDisplayName {
    switch (role) {
      case UserRole.customer: return 'عميل';
      case UserRole.storeOwner: return 'صاحب متجر';
      case UserRole.driver: return 'سائق';
      case UserRole.agent: return 'وكيل محلي';
      case UserRole.admin: return 'مدير النظام';
      case UserRole.support: return 'دعم فني';
    }
  }

  /// لون يمثل دور المستخدم (للتمييز في الـ UI)
  Color get roleColor {
    switch (role) {
      case UserRole.customer: return Colors.green;
      case UserRole.storeOwner: return Colors.orange;
      case UserRole.driver: return Colors.blue;
      case UserRole.agent: return Colors.purple;
      case UserRole.admin: return Colors.red;
      case UserRole.support: return Colors.teal;
    }
  }

  /// هل المستخدم يحتاج إلى دفع مسبق؟
  bool get requiresPrepayment {
    return role == UserRole.customer || role == UserRole.storeOwner;
  }

  /// هل المستخدم يحتاج إلى توثيق هوية؟
  bool get requiresVerification {
    return role == UserRole.driver;
  }
}