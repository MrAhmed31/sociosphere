import 'package:flutter/material.dart';
import 'package:sociosphere/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
  url: 'https://qnugcdywazgyydpnftui.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFudWdjZHl3YXpneXlkcG5mdHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MjAxNzcsImV4cCI6MjA5NTE5NjE3N30.PZJRMbq8X5vFDDVDmEkNjsRGhCLHDlJqVMJeCik_gOI',

  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);

  runApp(const SocioSphereApp());
}