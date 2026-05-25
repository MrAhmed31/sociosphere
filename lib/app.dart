import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class SocioSphereApp extends StatelessWidget {
  const SocioSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SocioSphere',
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}