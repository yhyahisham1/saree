// lib/models/auth/register_model.dart
import 'user_model.dart';

class RegisterModel {
  // بيانات أساسية
  final String fullName;
  final String phone;
  final String neighborhood;
  final String password;
  final UserRole role;
  
  // لصاحب المتجر
  final String? storeName;
  final String? commercialRegister;
  
  // للسائق
  final String? idCardImageUrl;
  final String? bikeImageUrl;
  
  // للوكيل
  final String? agentCode;

  RegisterModel({
    required this.fullName,
    required this.phone,
    required this.neighborhood,
    required this.password,
    required this.role,
    this.storeName,
    this.commercialRegister,
    this.idCardImageUrl,
    this.bikeImageUrl,
    this.agentCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'neighborhood': neighborhood,
      'password': password,
      'role': role.name,
      'storeName': storeName,
      'commercialRegister': commercialRegister,
      'idCardImageUrl': idCardImageUrl,
      'bikeImageUrl': bikeImageUrl,
      'agentCode': agentCode,
    };
  }
}