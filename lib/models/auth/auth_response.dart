// lib/models/auth/auth_response.dart
import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;
  final bool requiresAction; // جديد: هل يحتاج المستخدم إلى اتخاذ إجراء (دفع/توثيق)؟

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.requiresAction = false, // القيمة الافتراضية false
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
      requiresAction: json['requiresAction'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'requiresAction': requiresAction,
    };
  }
}