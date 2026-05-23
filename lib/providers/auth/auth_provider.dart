// lib/providers/auth/auth_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/register_model.dart';
import '../../services/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  UserModel? _pendingUser; // المستخدم الذي سجل لكن غير مفعل
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  UserModel? get pendingUser => _pendingUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isActive;
  bool get isPendingActivation => _pendingUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  // ==================== تحميل البيانات ====================

  /// تحميل المستخدم الحالي من التخزين
  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  /// تحميل مستخدم معلق (إذا كان هناك عملية تسجيل غير مكتملة)
  Future<void> loadPendingUser(String userId) async {
    _pendingUser = await _authService.getPendingUser(userId);
    notifyListeners();
  }

  // ==================== تسجيل الدخول ====================

  /// تسجيل الدخول للمستخدمين المفعلين فقط
  Future<bool> login(String phone, String password) async {
    _setLoading(true);
    _clearMessages();

    try {
      final loginData = LoginModel(phone: phone, password: password);
      final response = await _authService.login(loginData);

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _pendingUser = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى';
      _setLoading(false);
      return false;
    }
  }

  // ==================== التسجيل (حسب الدور) ====================

  /// تسجيل مستخدم جديد (الخطوة الأولى)
  /// للعملاء/أصحاب المتاجر: يحتاجون دفعة مسبقة
  /// للسائقين: يحتاجون توثيق هوية
  /// للوكلاء: يحتاجون كود تفعيل
  Future<bool> register(RegisterModel registerData) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.register(registerData);

      if (response.success && response.user != null) {
        _pendingUser = response.user;
        
        if (response.requiresAction) {
          // الحساب يحتاج إلى تفعيل (دفع أو توثيق)
          _successMessage = response.message;
        } else {
          _currentUser = response.user;
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التسجيل. يرجى المحاولة مرة أخرى';
      _setLoading(false);
      return false;
    }
  }

  // ==================== تفعيل الحساب (للعملاء/أصحاب المتاجر) ====================

  /// تفعيل حساب العميل/صاحب المتجر بعد الدفع المسبق
  Future<bool> activateWithPrepayment({
    required int prepaidOrders,
    required File receiptImage,
  }) async {
    if (_pendingUser == null) {
      _errorMessage = 'لم يتم العثور على حساب معلق';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.activateWithPrepayment(
        userId: _pendingUser!.id,
        prepaidOrders: prepaidOrders,
        verificationStatus: PaymentVerificationStatus.pending,
        receiptImage: receiptImage,
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _pendingUser = null;
        _successMessage = response.message;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء معالجة الدفع. يرجى المحاولة مرة أخرى';
      _setLoading(false);
      return false;
    }
  }

  // ==================== تفعيل الحساب بكود الوكيل ====================

  /// تفعيل حساب العميل باستخدام كود من الوكيل (بعد الدفع المسبق)
  Future<bool> activateWithAgentCode(String phone, String agentCode) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.activateWithAgentCode(phone, agentCode);

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _pendingUser = null;
        _successMessage = response.message;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التفعيل. يرجى المحاولة مرة أخرى';
      _setLoading(false);
      return false;
    }
  }

  // ==================== توثيق السائق (للمدير) ====================

  /// تفعيل حساب السائق بعد توثيق الهوية (يستخدمه المدير)
  Future<bool> activateDriver(String driverId) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.activateDriver(driverId);

      if (response.success && response.user != null) {
        if (_currentUser?.id == driverId) {
          _currentUser = response.user;
        }
        _successMessage = response.message;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء توثيق السائق';
      _setLoading(false);
      return false;
    }
  }

  // ==================== عمليات الرصيد والطلبات ====================

  /// خصم طلب واحد من رصيد المستخدم (عند قبول الطلب)
  Future<bool> deductOneOrder() async {
    if (_currentUser == null) return false;
    if (!_currentUser!.canPlaceOrder) return false;

    final updatedUser = _currentUser!.deductOneOrder();
    await _authService.updateCurrentUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
    return true;
  }

  /// تحديث رصيد المستخدم بعد شحن جديد
  Future<void> updateUserBalance(int newBalance) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      prepaidOrdersBalance: newBalance,
      updatedAt: DateTime.now(),
    );
    await _authService.updateCurrentUser(_currentUser!);
    notifyListeners();
  }

  /// زيادة عدد توصيلات السائق (بعد إتمام توصيلة)
  Future<bool> incrementDriverDeliveries() async {
    if (_currentUser == null) return false;
    if (_currentUser!.role != UserRole.driver) return false;

    final updatedUser = _currentUser!.incrementDeliveries();
    await _authService.updateCurrentUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
    return true;
  }

  // ==================== تسجيل الخروج ====================

  /// تسجيل الخروج من التطبيق
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _pendingUser = null;
    _clearMessages();
    notifyListeners();
  }

  // ==================== تحديث بيانات المستخدم ====================

  /// تحديث بيانات المستخدم الحالي (مثل تعديل الملف الشخصي)
  Future<void> updateUser(UserModel user) async {
    await _authService.updateCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  /// تحديث صورة الملف الشخصي
  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      profileImage: imageUrl,
      updatedAt: DateTime.now(),
    );
    await _authService.updateCurrentUser(_currentUser!);
    notifyListeners();
  }

  // ==================== حالة المستخدم ====================

  /// هل يمكن للمستخدم طلب توصيلة جديدة؟
  bool get canPlaceOrder {
    return _currentUser?.canPlaceOrder ?? false;
  }

  /// الرصيد المتبقي من الطلبات (للعملاء/أصحاب المتاجر)
  int get remainingOrders {
    return _currentUser?.prepaidOrdersBalance ?? 0;
  }

  /// هل استحق السائق مكافأة؟
  bool get hasDriverReward {
    return _currentUser?.hasReward ?? false;
  }

  /// كم توصيلة متبقية للسائق للمكافأة التالية؟
  int get driverRemainingForReward {
    return _currentUser?.remainingForReward ?? 0;
  }

  // ==================== التحقق من صحة البيانات ====================

  /// التحقق من صحة رقم الهاتف الفلسطيني
  static bool isValidPalestinianPhone(String phone) {
    final regex = RegExp(r'^(059|056|058|057)[0-9]{7}$');
    return regex.hasMatch(phone);
  }

  /// التحقق من صحة كود التفعيل
  static bool isValidActivationCode(String code) {
    return code.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(code);
  }

  // ==================== دوال مساعدة ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// إعادة تعيين المستخدم المعلق (مثلاً إذا فشل الدفع)
  void clearPendingUser() {
    _pendingUser = null;
    notifyListeners();
  }

  // عدد الطلبات النشطة (قيد التنفيذ)
int get activeOrdersCount {
  // TODO: جلب من قاعدة البيانات لاحقاً
  // مؤقتاً نرجع 0
  return 0;
}
}