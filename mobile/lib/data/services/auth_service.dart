import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

enum UserType {
  client('client'),
  provider('provider'),
  admin('admin');

  const UserType(this.value);
  final String value;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BaseApiService _apiService = BaseApiService();

  // Getters
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Performs the login and ensures the user is synchronized with the Django backend.
  Future<void> syncWithBackend() async {
    try {
      AppLogger.i('Sincronizando usuario con el backend...');
      // Call the sync endpoint. BaseApiService automatically attaches the IdToken.
      final response = await _apiService.post('users/sync/', body: {});
      AppLogger.i('Sincronización exitosa: ${response['email']}');
    } catch (e) {
      AppLogger.e('Error sincronizando con backend: $e');
      rethrow;
    }
  }

  /// REST-mapped: Fetches user profile from Django backend.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      return await _apiService.get('users/profile/');
    } catch (e) {
      AppLogger.e('Error obteniendo datos del usuario desde Django: $e');
      return null;
    }
  }

  /// REST-mapped: Fetches user type (stub for now, should be in profile).
  Future<UserType?> getUserType(String uid) async {
    final data = await getUserData(uid);
    if (data == null) return null;
    final typeStr = data['user_type'] as String?;
    return UserType.values.firstWhere((e) => e.value == typeStr, orElse: () => UserType.client);
  }

  /// Authenticates with Email and Password using Firebase.
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      AppLogger.i('Iniciando sesión con Firebase: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      
      await syncWithBackend();
      return credential;
    } catch (e) {
      AppLogger.e('Error en login Firebase: $e');
      rethrow;
    }
  }

  /// Authenticates with Google using Firebase.
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    try {
      AppLogger.i('Iniciando Google Sign-In con Firebase...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Cancelado por el usuario';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await syncWithBackend();
      
      return userCredential;
    } catch (e) {
      AppLogger.e('Error en Google Sign-In: $e');
      rethrow;
    }
  }

  /// Registers a new user with Firebase and syncs with Django.
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      await syncWithBackend();
      return credential;
    } catch (e) {
      AppLogger.e('Error en registro Firebase: $e');
      rethrow;
    }
  }

  /// Signs out from all providers.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      AppLogger.i('Sesión cerrada correctamente');
    } catch (e) {
      AppLogger.e('Error en logout: $e');
      rethrow;
    }
  }

  // --- STUBS FOR BACKWARD COMPATIBILITY (Will be removed after Provider refactor) ---

  Future<void> sendPasswordResetEmail(String email) async => 
      await _firebaseAuth.sendPasswordResetEmail(email: email);

  Future<void> updatePassword(String newPassword) async => 
      await currentUser?.updatePassword(newPassword);

  Future<void> updateUserProfile({required String uid, required Map<String, dynamic> userData}) async =>
      await _apiService.put('users/profile/', body: userData);

  Future<void> createUserInFirestore({required String uid, required String email, required String name, String? phone, UserType userType = UserType.client}) async =>
      await syncWithBackend();
}
