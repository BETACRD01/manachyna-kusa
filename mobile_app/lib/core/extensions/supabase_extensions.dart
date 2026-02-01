import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseUserExtensions on User {
  /// Compatibility getter for Firebase 'uid' -> Supabase 'id'
  String get uid => id;

  /// Compatibility getter for Firebase 'displayName' -> Supabase 'user_metadata'
  String? get displayName {
    final meta = userMetadata;
    return meta?['name'] ??
        meta?['full_name'] ??
        meta?['fullName'] ??
        email?.split('@').first;
  }

  /// Compatibility getter for Firebase 'photoURL' -> Supabase 'user_metadata'
  String? get photoURL {
    final meta = userMetadata;
    return meta?['avatar_url'] ?? meta?['picture'] ?? meta?['photoURL'];
  }

  bool get emailVerified =>
      identities?.any((i) => i.identityData?['email_verified'] == true) ??
      false;

  // Shim for reload (Supabase session refresh handled differently but method needed for compilation)
  Future<void> reload() async {
    await Supabase.instance.client.auth.refreshSession();
  }
}
