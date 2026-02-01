import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/supabase_config.dart';

final Logger logger = Logger();

enum UserType {
  client('client'),
  provider('provider'),
  admin('admin');

  const UserType(this.value);
  final String value;
}

class AuthService {
  // Tablas en Supabase
  static const String _usersTable = 'users';
  static const String _providersTable = 'providers';
  static const String _adminsTable = 'admins';

  // Instancia persistente para manejar el login de Google correctamente
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '265582480726-6l9507ncg4mfbsdnh9515di0a6r9j8lo.apps.googleusercontent.com',
  );

  // Getters
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  User? get currentUser => supabase.auth.currentUser;

  /// Determina el tipo de usuario verificando las tablas en orden de prioridad
  Future<UserType?> getUserType(String uid) async {
    try {
      _log('Verificando tipo de usuario para: $uid');

      // 1. Verificar en providers (prioridad)
      if (await _recordExists(_providersTable, uid)) {
        _log('Usuario es PROVEEDOR');
        return UserType.provider;
      }

      // 2. Verificar en admins
      if (await _recordExists(_adminsTable, uid)) {
        _log('Usuario es ADMIN');
        return UserType.admin;
      }

      // 3. Verificar en users (clientes)
      final userResponse = await supabase
          .from(_usersTable)
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (userResponse != null) {
        final userData = userResponse;
        final userRole = userData['role'] as String?;
        final isProvider = userData['is_provider'] as bool? ?? false;

        _log('Datos en users - Rol: $userRole, EsProveedor: $isProvider');

        if (userRole == 'admin') {
          _log('Usuario es ADMIN (rol en users)');
          return UserType.admin;
        }

        if (userRole == 'provider' ||
            (userData['is_provider'] as bool? ?? false)) {
          _log(
              'Usuario marcado como provider en users pero no está en tabla providers');
          return UserType.provider;
        }

        _log('Usuario es CLIENTE');
        return UserType.client;
      }

      _log('Usuario no encontrado en ninguna tabla');
      return null;
    } catch (e) {
      _log('Error obteniendo tipo de usuario: $e');
      return null;
    }
  }

  /// Obtiene los datos del usuario desde la tabla correspondiente
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userType = await getUserType(uid);
      if (userType == null) {
        _log('No se pudo determinar el tipo de usuario');
        return null;
      }

      final String table = _getTableForUserType(userType);

      var data =
          await supabase.from(table).select().eq('uid', uid).maybeSingle();

      // Fallback para admin si no existe en admins
      if (data == null && userType == UserType.admin) {
        data = await supabase
            .from(_usersTable)
            .select()
            .eq('uid', uid)
            .maybeSingle();
      }

      if (data != null) {
        final userData = Map<String, dynamic>.from(data);
        userData['userType'] = userType.value;
        userData['uid'] = uid;
        _log(
            'Datos obtenidos de $table: ${userData['email'] ?? 'sin email'} - ${userType.value}');
        return userData;
      }

      _log('No se encontraron datos para el usuario: $uid');
      return null;
    } catch (e) {
      _log('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  /// Autentica usuario con email y contraseña
  Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _log('Intentando login con: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _log('Login exitoso para: ${response.user!.id}');
        final userType = await getUserType(response.user!.id);
        _log('Tipo de usuario detectado: ${userType?.value ?? 'DESCONOCIDO'}');
      }

      return response;
    } catch (e) {
      _log('Error en login: $e');
      rethrow;
    }
  }

  /// Autentica con Google (Hybrid Approach)
  Future<AuthResponse> signInWithGoogle() async {
    try {
      _log('Iniciando login con Google...');

      // 1. Obtener credenciales de Google (Lado Cliente)
      // LIMPIEZA DE CACHÉ: Forzamos el cierre de sesión previo para que siempre aparezca el selector de cuentas
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        _log('Error limpiando sesión previa de Google: $e');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Cancelado por el usuario';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No se pudo obtener el Access Token de Google';
      }

      if (idToken == null) {
        throw 'No se pudo obtener el ID Token de Google';
      }

      // 2. Autenticar con Supabase usando el ID Token
      _log('Intercambiando tokens con Supabase...');
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      _log('Login con Google exitoso para: ${response.user?.email}');

      // 3. Sincronizar datos del usuario con la tabla 'users' de Supabase
      if (response.user != null) {
        final user = response.user!;
        await createUserInFirestore(
          uid: user.id,
          email: user.email ?? '',
          name: googleUser.displayName ??
              user.userMetadata?['name'] ??
              user.userMetadata?['full_name'] ??
              'Usuario de Google',
          phone: user.phone,
          userType: UserType.client, // Por defecto cliente si es nuevo
        );
      }

      return response;
    } catch (e) {
      _log('Error en login con Google: $e');
      rethrow;
    }
  }

  /// Registra un nuevo usuario
  Future<AuthResponse> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      _log('Error en registro: $e');
      rethrow;
    }
  }

  /// Crea un registro de usuario en la base de datos
  Future<void> createUserInFirestore({
    required String uid,
    required String email,
    required String name,
    String? phone,
    UserType userType = UserType.client,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'role': userType.value,
        'is_active': true,
        'is_provider': userType == UserType.provider,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from(_usersTable).upsert(userData);
      _log('Usuario creado en DB: $email - ${userType.value}');
    } catch (e) {
      _log('Error creando usuario en DB: $e');
      rethrow;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      // 1. Cerrar sesión en Supabase
      await supabase.auth.signOut();

      // 2. Cerrar sesión en Google para limpiar caché
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        _log('Error al cerrar sesión de Google: $e');
      }

      _log('Logout exitoso (Supabase + Google)');
    } catch (e) {
      _log('Error en logout: $e');
      rethrow;
    }
  }

  /// Envía email para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      _log('Email de reset enviado a: $email');
    } catch (e) {
      _log('Error enviando reset email: $e');
      rethrow;
    }
  }

  /// Actualiza la contraseña del usuario actual
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _log('Contraseña actualizada exitosamente');
    } catch (e) {
      _log('Error actualizando contraseña: $e');
      rethrow;
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      if (userData.isEmpty) return;

      userData['updated_at'] = DateTime.now().toIso8601String();
      final userType = await getUserType(uid);

      if (userType == null) return;

      switch (userType) {
        case UserType.provider:
          await _updateMultipleTables(
              uid, userData, [_usersTable, _providersTable]);
          break;
        case UserType.admin:
          await _updateMultipleTables(
              uid, userData, [_usersTable, _adminsTable]);
          break;
        case UserType.client:
        default:
          await supabase.from(_usersTable).update(userData).eq('uid', uid);
          break;
      }

      _log('Perfil actualizado para usuario: $uid');
    } catch (e) {
      _log('Error actualizando perfil: $e');
      rethrow;
    }
  }

  // Métodos auxiliares privados
  Future<bool> _recordExists(String table, String uid) async {
    final count = await supabase
        .from(table)
        .select()
        .eq('uid', uid)
        .count(CountOption.exact);
    return count.count > 0;
  }

  String _getTableForUserType(UserType userType) {
    switch (userType) {
      case UserType.provider:
        return _providersTable;
      case UserType.admin:
        return _adminsTable;
      case UserType.client:
        return _usersTable;
    }
  }

  Future<void> _updateMultipleTables(
      String uid, Map<String, dynamic> userData, List<String> tables) async {
    for (final table in tables) {
      if (await _recordExists(table, uid)) {
        await supabase.from(table).update(userData).eq('uid', uid);
      }
    }
  }

  void _log(String message) {
    logger.i(message);
  }
}
