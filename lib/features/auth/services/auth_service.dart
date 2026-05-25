import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {

  final SupabaseClient _client =
      Supabase.instance.client;

  /// CURRENT USER
  User? get currentUser =>
      _client.auth.currentUser;

  /// AUTH CHANGES
  Stream<AuthState>
      get authStateChanges =>
          _client.auth.onAuthStateChange;

  /// GOOGLE LOGIN
  Future<void> signInWithGoogle() async {

    /// CLEAR OLD SESSION
    await _client.auth.signOut();

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,

      redirectTo:
          '${Uri.base.origin}/',

      authScreenLaunchMode:
          LaunchMode.platformDefault,
    );

    final user =
        _client.auth.currentUser;

    if (user != null) {

      /// SUPER ADMIN LOGIN
      if (user.email ==
          'sociosphereadmin@gmail.com') {

        await _client
            .from('profiles')
            .upsert({

          'id': user.id,

          'full_name':
              user.userMetadata?[
                      'full_name'] ??
                  'Super Admin',

          'email': user.email,

          'role': 'super_admin',
        });

      } else {

        /// NORMAL USER
        final existing =
            await _client
                .from('profiles')
                .select(
                  'id, role',
                )
                .eq(
                  'id',
                  user.id,
                )
                .maybeSingle();

        /// CREATE DEFAULT PROFILE
        if (existing == null) {

          await _client
              .from('profiles')
              .insert({

            'id': user.id,

            'full_name':
                user.userMetadata?[
                        'full_name'] ??
                    user.email ??
                    'User',

            'email': user.email,

            'role': 'resident',
          });
        }
      }
    }
  }

  /// ENSURE PROFILE EXISTS
  Future<void> ensureUserProfile() async {

    final user =
        _client.auth.currentUser;

    if (user == null) return;

    final existing =
        await _client
            .from('profiles')
            .select(
              'id, role',
            )
            .eq(
              'id',
              user.id,
            )
            .maybeSingle();

    /// CREATE DEFAULT PROFILE
    if (existing == null) {

      String role = 'resident';

      /// SUPER ADMIN CHECK
      if (user.email ==
          'sociosphereadmin@gmail.com') {

        role = 'super_admin';
      }

      await _client
          .from('profiles')
          .insert({

        'id': user.id,

        'full_name':
            user.userMetadata?[
                    'full_name'] ??
                user.email ??
                'User',

        'email': user.email,

        'role': role,
      });
    }
  }

  /// GET USER ROLE
  Future<String> getUserRole() async {

    final user =
        _client.auth.currentUser;

    if (user == null) {
      return 'resident';
    }

    await ensureUserProfile();

    final data =
        await _client
            .from('profiles')
            .select('role')
            .eq(
              'id',
              user.id,
            )
            .maybeSingle();

    return data?['role']
            ?.toString() ??
        'resident';
  }

  /// LOGOUT
  Future<void> signOut() async {

    await _client.auth.signOut();

    /// WEB SESSION RESET
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );
  }
}