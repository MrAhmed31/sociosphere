import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/select_role_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/society/screens/society_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/resident_profile/screens/resident_profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [

    /// Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    /// Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// Select Role
    GoRoute(
      path: '/select-role',
      builder: (context, state) => const SelectRoleScreen(),
    ),
    GoRoute(
  path: '/resident-profile',
  builder: (context, state) => const ResidentProfileScreen(),
),

    /// Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    /// Society Screen
    GoRoute(
      path: '/society',
      builder: (context, state) => const SocietyScreen(),
    ),

    
  ],
);