class AppConstants {
  // روابط API
  static const String baseUrl = "https://your-api.com/api";
  
  // مفاتيح SharedPreferences
  static const String userToken = "user_token";
  static const String userId = "user_id";
  static const String cartKey = "cart_data";
  
  // حدود التطبيق
  static const int maxCartItems = 50;
  static const int minOrderAmount = 10;
  static const double deliveryFee = 15.0;
  
  // الرسائل
  static const String errorMessage = "حدث خطأ، يرجى المحاولة مرة أخرى";
  static const String noInternetMessage = "لا يوجد اتصال بالإنترنت";
  static const String emptyCartMessage = "السلة فارغة، أضف بعض المنتجات";
}