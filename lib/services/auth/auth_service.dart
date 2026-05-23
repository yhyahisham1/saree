// lib/services/auth/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/register_model.dart';
import '../../models/auth/auth_response.dart';
import '../payment_verification_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _pendingUserKey = 'pending_user_data';

  // ==================== تسجيل الدخول ====================
  
  Future<AuthResponse> login(LoginModel loginData) async {
    await Future.delayed(const Duration(seconds: 1));

    // حساب تجريبي: عميل مفعل
    if (loginData.phone == '0591234567' && loginData.password == '123456') {
      final user = UserModel(
        id: 'user_001',
        fullName: 'أحمد محمد',
        phone: loginData.phone,
        neighborhood: 'الرمال',
        role: UserRole.customer,
        prepaidOrdersBalance: 10,
        paymentVerification: PaymentVerificationStatus.approved,
        isActive: true,
        rating: 4.8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveAuthData('dummy_token_123', user);
      
      return AuthResponse(
        success: true,
        message: 'تم تسجيل الدخول بنجاح',
        user: user,
        token: 'dummy_token_123',
      );
    }
    
    // حساب تجريبي: سائق موثق
    if (loginData.phone == '0597654321' && loginData.password == '123456') {
      final user = UserModel(
        id: 'driver_001',
        fullName: 'محمد سعيد',
        phone: loginData.phone,
        neighborhood: 'الشجاعية',
        role: UserRole.driver,
        driverVerificationStatus: DriverVerificationStatus.approved,
        totalDeliveries: 45,
        isActive: true,
        rating: 4.9,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveAuthData('dummy_token_driver', user);
      
      return AuthResponse(
        success: true,
        message: 'تم تسجيل الدخول بنجاح',
        user: user,
        token: 'dummy_token_driver',
      );
    }
    
    // حساب تجريبي: وكيل محلي
    if (loginData.phone == '0591112222' && loginData.password == '123456') {
      final user = UserModel(
        id: 'agent_001',
        fullName: 'بقالة السلام',
        phone: loginData.phone,
        neighborhood: 'الرمال',
        role: UserRole.agent,
        agentCode: 'AGT-001',
        isActive: true,
        collectedCommission: 87.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveAuthData('dummy_token_agent', user);
      
      return AuthResponse(
        success: true,
        message: 'تم تسجيل الدخول بنجاح',
        user: user,
        token: 'dummy_token_agent',
      );
    }
    
    return AuthResponse(
      success: false,
      message: 'رقم الهاتف أو كلمة المرور غير صحيحة',
    );
  }

  // ==================== تسجيل مستخدم جديد ====================
  
  Future<AuthResponse> register(RegisterModel registerData) async {
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    
    UserModel user;
    
    // استخدام switch مع enum بشكل صحيح
    switch (registerData.role) {
      case UserRole.customer:
      case UserRole.storeOwner:
        user = UserModel(
          id: 'user_${now.millisecondsSinceEpoch}',
          fullName: registerData.fullName,
          phone: registerData.phone,
          neighborhood: registerData.neighborhood,
          role: registerData.role,
          storeName: registerData.storeName,
          commercialRegister: registerData.commercialRegister,
          prepaidOrdersBalance: 0,
          totalPrepaidOrders: 0,
          paymentVerification: PaymentVerificationStatus.pending,
          isActive: false,
          createdAt: now,
          updatedAt: now,
        );
        break;
        
      case UserRole.driver:
        user = UserModel(
          id: 'driver_${now.millisecondsSinceEpoch}',
          fullName: registerData.fullName,
          phone: registerData.phone,
          neighborhood: registerData.neighborhood,
          role: UserRole.driver,
          driverVerificationStatus: DriverVerificationStatus.pending,
          idCardImageUrl: registerData.idCardImageUrl,
          bikeImageUrl: registerData.bikeImageUrl,
          isActive: false,
          createdAt: now,
          updatedAt: now,
        );
        break;
        
      case UserRole.agent:
        user = UserModel(
          id: 'agent_${now.millisecondsSinceEpoch}',
          fullName: registerData.fullName,
          phone: registerData.phone,
          neighborhood: registerData.neighborhood,
          role: UserRole.agent,
          agentCode: registerData.agentCode,
          isActive: registerData.agentCode != null,
          createdAt: now,
          updatedAt: now,
        );
        break;
        
      default:
        return AuthResponse(
          success: false,
          message: 'دور المستخدم غير صالح للتسجيل الذاتي',
        );
    }
    
    await _savePendingUser(user);
    
    return AuthResponse(
      success: true,
      message: _getSuccessMessageByRole(registerData.role),
      user: user,
      token: null,
      requiresAction: true,
    );
  }
  
  String _getSuccessMessageByRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
      case UserRole.storeOwner:
        return 'تم إنشاء الحساب. يرجى دفع المبلغ المطلوب لتفعيل حسابك';
      case UserRole.driver:
        return 'تم إنشاء حساب السائق. سيتم مراجعة طلبك خلال 24 ساعة';
      case UserRole.agent:
        return 'تم إنشاء حساب الوكيل. يرجى انتظار كود التفعيل من المدير';
      default:
        return 'تم إنشاء الحساب بنجاح';
    }
  }

  // ==================== تفعيل الحساب للعميل ====================
  
  Future<AuthResponse> activateWithPrepayment({
    required String userId,
    required int prepaidOrders,
    required PaymentVerificationStatus verificationStatus,
    File? receiptImage,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final pendingUser = await getPendingUser(userId);
    if (pendingUser == null) {
      return AuthResponse(
        success: false,
        message: 'المستخدم غير موجود',
      );
    }
    
    if (receiptImage != null && verificationStatus == PaymentVerificationStatus.pending) {
      final verification = await PaymentVerificationService.verifyReceipt(
        receiptImage,
        prepaidOrders,
      );
      
      if (!verification.success && !verification.needsManualReview) {
        return AuthResponse(
          success: false,
          message: verification.message,
        );
      }
      
      if (verification.needsManualReview) {
        await _savePendingUser(pendingUser.copyWith(
          paymentVerification: PaymentVerificationStatus.pending,
        ));
        
        return AuthResponse(
          success: false,
          message: 'تم استلام الإيصال. سيتم مراجعته خلال 24 ساعة',
          requiresAction: true,
        );
      }
    }
    
    final activatedUser = pendingUser.addPrepaidOrders(prepaidOrders, verificationStatus);
    
    await _saveAuthData('token_${DateTime.now().millisecondsSinceEpoch}', activatedUser);
    await _removePendingUser(userId);
    
    return AuthResponse(
      success: true,
      message: 'تم تفعيل حسابك بنجاح! يمكنك الآن بدء الطلبات',
      user: activatedUser,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
  
  // ==================== تفعيل حساب السائق ====================
  
  Future<AuthResponse> activateDriver(String driverId) async {
    final pendingUser = await getPendingUser(driverId);
    if (pendingUser == null) {
      return AuthResponse(
        success: false,
        message: 'السائق غير موجود',
      );
    }
    
    if (pendingUser.role != UserRole.driver) {
      return AuthResponse(
        success: false,
        message: 'هذا المستخدم ليس سائقاً',
      );
    }
    
    final activatedUser = pendingUser.copyWith(
      driverVerificationStatus: DriverVerificationStatus.approved,
      isActive: true,
      updatedAt: DateTime.now(),
    );
    
    await _saveAuthData('driver_token_${DateTime.now().millisecondsSinceEpoch}', activatedUser);
    await _removePendingUser(driverId);
    
    return AuthResponse(
      success: true,
      message: 'تم توثيق حساب السائق. يمكنه الآن استلام الطلبات',
      user: activatedUser,
      token: 'driver_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
  
  // ==================== تفعيل حساب العميل بكود الوكيل ====================
  
  Future<AuthResponse> activateWithAgentCode(String phone, String agentCode) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (agentCode.length != 6) {
      return AuthResponse(
        success: false,
        message: 'كود التفعيل غير صحيح (6 أرقام)',
      );
    }
    
    final pendingUser = await getPendingUserByPhone(phone);
    if (pendingUser == null) {
      return AuthResponse(
        success: false,
        message: 'لم يتم العثور على حساب بهذا الرقم',
      );
    }
    
    if (pendingUser.paymentVerification != PaymentVerificationStatus.approved) {
      return AuthResponse(
        success: false,
        message: 'يرجى إتمام عملية الدفع المسبق أولاً',
      );
    }
    
    final activatedUser = pendingUser.copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
    
    await _saveAuthData('token_${DateTime.now().millisecondsSinceEpoch}', activatedUser);
    await _removePendingUser(pendingUser.id);
    
    return AuthResponse(
      success: true,
      message: 'تم تفعيل حسابك بنجاح! رصيدك: ${activatedUser.prepaidOrdersBalance} طلب',
      user: activatedUser,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ==================== إدارة التخزين المحلي ====================
  
  Future<void> _saveAuthData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  Future<void> _savePendingUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUsersJson = prefs.getString(_pendingUserKey);
    Map<String, dynamic> pendingUsers = {};
    
    if (pendingUsersJson != null) {
      pendingUsers = jsonDecode(pendingUsersJson);
    }
    
    pendingUsers[user.id] = user.toJson();
    await prefs.setString(_pendingUserKey, jsonEncode(pendingUsers));
  }
  
  Future<UserModel?> getPendingUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUsersJson = prefs.getString(_pendingUserKey);
    
    if (pendingUsersJson == null) return null;
    
    final pendingUsers = jsonDecode(pendingUsersJson);
    if (pendingUsers[userId] == null) return null;
    
    return UserModel.fromJson(pendingUsers[userId]);
  }
  
  Future<UserModel?> getPendingUserByPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUsersJson = prefs.getString(_pendingUserKey);
    
    if (pendingUsersJson == null) return null;
    
    final pendingUsers = jsonDecode(pendingUsersJson);
    
    for (var userData in pendingUsers.values) {
      final user = UserModel.fromJson(userData);
      if (user.phone == phone) return user;
    }
    
    return null;
  }
  
  Future<void> _removePendingUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUsersJson = prefs.getString(_pendingUserKey);
    
    if (pendingUsersJson == null) return;
    
    final pendingUsers = jsonDecode(pendingUsersJson);
    pendingUsers.remove(userId);
    await prefs.setString(_pendingUserKey, jsonEncode(pendingUsers));
  }

  // ==================== عمليات أساسية ====================
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    
    if (token == null || userJson == null) return false;
    
    final user = UserModel.fromJson(jsonDecode(userJson));
    return user.isActive;
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<void> updateCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      await _saveAuthData(token, user);
    }
  }
}