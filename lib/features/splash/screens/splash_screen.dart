import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      checkAuth();
    });
  }

  Future<void> checkAuth() async {

  final user = Supabase.instance.client.auth.currentUser;

  /// NOT LOGGED IN
  if (user == null) {

    if (!mounted) return;

    context.go('/login');
    return;
  }

  try {

    /// CHECK PROFILE
    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    /// NEW USER
    if (profile == null) {

      if (!mounted) return;

      context.go('/select-role');
      return;
    }

    final role = profile['role'];

    if (!mounted) return;

    /// ADMIN
    if (role == 'society_admin' ||
        role == 'super_admin') {

      context.go('/dashboard');

    } else {

      /// RESIDENT
      context.go('/dashboard');
    }

  } catch (e) {

    debugPrint('Splash Error: $e');

    if (!mounted) return;

    context.go('/login');
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.apartment,
              size: 90,
              color: Colors.blue.shade700,
            ),

            const SizedBox(height: 20),

            const Text(
              'SocioSphere',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Smart Society Management System',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}