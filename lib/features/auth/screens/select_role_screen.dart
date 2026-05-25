import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Choose Account Type',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            /// REGISTER SOCIETY
            SizedBox(
              width: double.infinity,
              height: 65,

              child: ElevatedButton.icon(

                onPressed: () async {

                  final user =
                      Supabase.instance.client.auth.currentUser;

                  if (user == null) return;

                  await Supabase.instance.client
                      .from('profiles')
                      .upsert({
                    'id': user.id,
                    'email': user.email,
                    'role': 'society_admin',
                  });

                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.admin_panel_settings),

                label: const Text(
                  'Register Society',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// JOIN SOCIETY
            SizedBox(
              width: double.infinity,
              height: 65,

              child: OutlinedButton.icon(

                onPressed: () async {

                  final user =
                      Supabase.instance.client.auth.currentUser;

                  if (user == null) return;

                  await Supabase.instance.client
                      .from('profiles')
                      .upsert({
                    'id': user.id,
                    'email': user.email,
                    'role': 'resident',
                  });

                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                },

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF2563EB),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.people),

                label: const Text(
                  'Join Existing Society',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}