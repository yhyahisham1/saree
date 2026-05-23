// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/agent/agent_home_screen.dart';
import 'screens/agent/auth/agent_login_screen.dart';
import 'screens/agent/auth/agent_register_screen.dart';
import 'screens/agent/generate_codes_screen.dart';
import 'screens/agent/sell_package_screen.dart';
import 'screens/agent/commissions_screen.dart';
import 'screens/agent/sales_history_screen.dart';
import 'screens/agent/profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth/auth_provider.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/new_order_screen.dart';
import 'screens/customer/track_order_screen.dart';
import 'screens/customer/buy_package_screen.dart';
import 'screens/customer/rate_driver_screen.dart';
import 'screens/customer/orders_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/driver/driver_home_screen.dart';
import 'screens/store_owner/store_owner_home_screen.dart';
import 'screens/support/support_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Saree3App());
}

class Saree3App extends StatelessWidget {
  const Saree3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'سريع - توصيل سريع',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: _buildTheme(),
        initialRoute: '/',
        routes: _buildRoutes(),
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('الصفحة غير موجودة')),
            ),
          );
        },
      ),
    );
  }

  // ✅ احتفظ بدالة _buildTheme كما هي في ملفك الأصلي (لم تتغير)
  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: AppColors.surface,
      ),
    );
  }

  // ✅ احتفظ بدالة _buildRoutes كما هي (بدون تغيير)
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => const RoleSelectionScreen(),
      '/login': (context) => const LoginScreen(selectedRole: 'customer'),
      '/home': (context) => const HomeScreen(),
      '/new-order': (context) => const NewOrderScreen(),
      '/track-order': (context) => const TrackOrderScreen(orderId: 'ORD-12345'),
      '/buy-package': (context) => const BuyPackageScreen(),
      '/rate-driver': (context) => const RateDriverScreen(),
      '/orders': (context) => const OrdersScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/notifications': (context) => const NotificationsScreen(),
      '/agent-home': (context) => const AgentHomeScreen(),
      '/admin-home': (context) => const AdminHomeScreen(),
      '/driver-home': (context) => const DriverHomeScreen(),
      '/store-owner-home': (context) => const StoreOwnerHomeScreen(),
      '/support-home': (context) => const SupportHomeScreen(),
    };
  }

  // ✅ احتفظ بدالة _onGenerateRoute كما هي (مع إضافة مسارات الوكيل)
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case '/login':
        final role = settings.arguments as String? ?? 'customer';
        return MaterialPageRoute(builder: (_) => LoginScreen(selectedRole: role));

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/new-order':
        return MaterialPageRoute(builder: (_) => const NewOrderScreen());

      case '/track-order':
        final orderId = settings.arguments as String? ?? 'ORD-12345';
        return MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: orderId));

      case '/buy-package':
        return MaterialPageRoute(builder: (_) => const BuyPackageScreen());

      case '/rate-driver':
        return MaterialPageRoute(builder: (_) => const RateDriverScreen());

      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case '/driver-home':
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());

    // مسارات الوكيل
      case '/agent-login':
        return MaterialPageRoute(builder: (_) => const AgentLoginScreen());

      case '/agent-register':
        return MaterialPageRoute(builder: (_) => const AgentRegisterScreen());

      case '/agent-home':
        return MaterialPageRoute(builder: (_) => const AgentHomeScreen());

      case '/store-owner-home':
        return MaterialPageRoute(builder: (_) => const StoreOwnerHomeScreen());

      case '/admin-home':
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());

      case '/support-home':
        return MaterialPageRoute(builder: (_) => const SupportHomeScreen());

    // للتوافق
      case '/login-with-role':
        final role = settings.arguments as String? ?? 'customer';
        return MaterialPageRoute(builder: (_) => LoginScreen(selectedRole: role));

      default:
        return null;
    }
  }
}