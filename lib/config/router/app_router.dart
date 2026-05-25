import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociosphere/features/auth/screens/login_screen.dart';
import 'package:sociosphere/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:sociosphere/features/dashboard/screens/resident_dashboard_screen.dart';
import 'package:sociosphere/features/splash/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    GoRoute(
      path: '/resident',
      builder: (context, state) => const ResidentDashboardScreen(),
    ),
  ],
);