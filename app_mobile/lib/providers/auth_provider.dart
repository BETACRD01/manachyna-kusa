import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/auth_service.dart';
import '../core/services/notification_service.dart';
import '../shared/widgets/common/post_login_provider_modal.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

enum UserRole {
  client,
  provider,
  admin,
}

// NUEVO: Enum para tipos de duración
enum DurationType {
  hours('horas'),
  days('días'),
  weeks('semanas'),
  custom('personalizado');

  const DurationType(this.displayName);
  final String displayName;
}

// NUEVO: Clase para manejar duración flexible
class BookingDuration {
  final DurationType type;
  final int quantity;
  final String? customDescription;

  const BookingDuration({
    required this.type,
    required this.quantity,
    this.customDescription,
  });

  String get displayText {
    switch (type) {
      case DurationType.hours:
        return '$quantity ${quantity == 1 ? 'hora' : 'horas'}';
      case DurationType.days:
        return '$quantity ${quantity == 1 ? 'día' : 'días'}';
      case DurationType.weeks:
        return '$quantity ${quantity == 1 ? 'semana' : 'semanas'}';
      case DurationType.custom:
        return customDescription ?? 'Duración personalizada';
    }
  }

  double getMultiplier() {
    switch (type) {
      case DurationType.hours:
        return quantity.toDouble();
      case DurationType.days:
        return quantity * 8.0; // 8 horas por día
      case DurationType.weeks:
        return quantity * 40.0; // 40 horas por semana (5 días x 8 horas)
      case DurationType.custom:
        return quantity
            .toDouble(); // Para custom, quantity representa el multiplicador directo
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'quantity': quantity,
      'customDescription': customDescription,
      'displayText': displayText,
      'multiplier': getMultiplier(),
    };
  }

  factory BookingDuration.fromMap(Map<String, dynamic> map) {
    return BookingDuration(
      type: DurationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DurationType.hours,
      ),
      quantity: map['quantity'] ?? 1,
      customDescription: map['customDescription'],
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  UserType? _userType;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // === VARIABLES PARA PANEL FLOTANTE ===
  Map<String, dynamic>? _pendingBookingData;
  bool _shouldShowProviderModal = false;

  //imagen caches
  String? _cachedProfileImagePath;

  // Constructor - verificar estado inicial
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initializeAuthState();
  }
  String? get cachedProfileImagePath => _cachedProfileImagePath;

  // Getters principales
  User? get user => _user;
  User? get currentUser => _user;
  UserType? get userType => _userType;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingServiceTitle => _pendingBookingData?['serviceTitle'];
  double? get pendingTotal => _pendingBookingData?['finalTotal']?.toDouble();

  // === GETTERS PARA RESERVA PENDIENTE ===
  Map<String, dynamic>? get pendingBookingData => _pendingBookingData;
  bool get hasPendingBooking => _pendingBookingData != null;
  bool get shouldShowProviderModal => _shouldShowProviderModal;

  // LÓGICA CORREGIDA - Solo mostrar modal si viene específicamente de booking
  bool get shouldShowModal =>
      hasPendingBooking &&
      isAuthenticated &&
      (_pendingBookingData?['fromBooking'] == true);

  // Getters de conveniencia para tipos
  bool get isAuthenticated => _user != null;
  bool get isProvider => _userType == UserType.provider;
  bool get isClient => _userType == UserType.client;
  bool get isAdmin => _userType == UserType.admin;

  // Getters adicionales
  String? get currentUserId => _user?.id;
  String? get currentUserEmail => _user?.email;
  // Supabase User no tiene displayName directamente, está en userMetadata
  String? get currentUserDisplayName =>
      _user?.userMetadata?['name'] ?? _user?.userMetadata?['fullName'];

  // Inicializar estado de autenticación
  void _initializeAuthState() {
    _authService.authStateChanges.listen((AuthState state) {
      final user = state.session?.user;
      if (user != null) {
        if (_user?.id != user.id) {
          _handleUserSignIn(user);
        }
      } else {
        _handleUserSignOut();
      }
    });
  }

  // MÉTODO CORREGIDO - Manejar cuando un usuario se loguea
  Future<void> _handleUserSignIn(User user) async {
    debugPrint('\n=== USUARIO LOGUEADO ===');
    debugPrint('🆔 UID: ${user.id}');
    debugPrint('Email: ${user.email}');

    _user = user;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // NUEVO: Guardar Token FCM al iniciar sesión
      await NotificationService.updateTokenForCurrentUser();

      // OBTENER TIPO DE USUARIO CON LÓGICA CORREGIDA
      _userType = await _authService.getUserType(user.id);
      _userData = await _authService.getUserData(user.id);

      if (_userType != null && _userData != null) {
        debugPrint('Datos cargados exitosamente');
        debugPrint('Tipo: $_userType');
        debugPrint(
            'Nombre: ${_userData!['name'] ?? _userData!['fullName'] ?? 'Sin nombre'}');

        // VERIFICAR SI DEBE MOSTRAR MODAL DESPUÉS DEL LOGIN
        if (shouldShowModal) {
          debugPrint(
              'Usuario logueado con reserva pendiente desde booking - Preparar modal');
        } else {
          debugPrint('Usuario logueado - navegación normal al home');
        }
      } else {
        debugPrint('No se pudieron cargar los datos del usuario');
        _errorMessage = 'Error: No se encontraron datos del usuario';
      }
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
      _errorMessage = 'Error cargando datos: $e';
      _userType = null;
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();

    debugPrint('=== FIN CARGA USUARIO ===\n');
  }

  // MÉTODO CORREGIDO: Limpiar TODOS los datos al logout
  void _handleUserSignOut() {
    debugPrint('\n👋 === USUARIO DESLOGUEADO ===');
    debugPrint('Limpiando todos los datos de sesión...');

    // Limpiar datos de usuario
    _user = null;
    _userType = null;
    _userData = null;
    _errorMessage = null;
    _isLoading = false;

    // LIMPIAR COMPLETAMENTE DATOS DE RESERVA PENDIENTE
    clearPendingBooking();

    debugPrint('Datos de usuario limpiados');
    debugPrint('Datos de reserva pendiente limpiados');
    debugPrint('Estado de modal reseteado');

    notifyListeners();

    debugPrint('👋 === FIN LOGOUT CLEANUP ===\n');
  }

  // Login con email y password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n=== INICIANDO LOGIN ===');
      debugPrint('Email: $email');

      await _authService.signInWithEmailAndPassword(email, password);

      // AGREGAR: Cargar imagen en cache
      await loadProfileImageCache();

      // Esperar a que se carguen los datos
      int attempts = 0;
      while (_isLoading && attempts < 50) {
        // 5 segundos máximo
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      final success = _user != null && _userType != null;

      if (success) {
        debugPrint('LOGIN EXITOSO - Tipo: ${_userType!.value}');
      } else {
        debugPrint('LOGIN FALLIDO - Datos no cargados');
        _errorMessage = 'Error: No se pudieron cargar los datos del usuario';
      }

      debugPrint('=== FIN LOGIN ===\n');

      return success;
    } catch (e) {
      debugPrint('Error en login: $e');
      _errorMessage = _getSupabaseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  // === NUEVO: Login con Google ===
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n=== INICIANDO LOGIN CON GOOGLE ===');

      await _authService.signInWithGoogle();

      // AGREGAR: Cargar imagen en cache
      await loadProfileImageCache();

      // Esperar a que se carguen los datos
      int attempts = 0;
      while (_isLoading && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      final success = _user != null;

      if (success) {
        debugPrint('LOGIN CON GOOGLE EXITOSO');
      } else {
        debugPrint('LOGIN CON GOOGLE FALLIDO - Datos no cargados');
        _errorMessage = 'Error: No se pudieron cargar los datos del usuario';
      }

      debugPrint('=== FIN LOGIN GOOGLE ===\n');

      return success;
    } catch (e) {
      debugPrint('Error en login con Google: $e');
      if (e.toString().contains('Cancelado')) {
        _errorMessage = null; // No mostrar error si el usuario canceló
      } else {
        _errorMessage = _getSupabaseErrorMessage(e);
      }
      _setLoading(false);
      return false;
    }
  }

  // Registro de usuario
  Future<bool> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.createUserWithEmailAndPassword(email, password);

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error en registro: $e');
      _errorMessage = _getSupabaseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  // MÉTODO DE REGISTRO CORREGIDO - Solo para clientes
  Future<bool> signUp(
      String email, String password, String name, UserRole role) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n📝 === INICIANDO REGISTRO ===');
      debugPrint('Email: $email');
      debugPrint('Nombre: $name');
      debugPrint('🎭 Rol: ${role.toString()}');

      // VALIDAR QUE SOLO SEA CLIENTE
      if (role != UserRole.client) {
        _errorMessage = 'Solo se permite registro de clientes';
        _setLoading(false);
        return false;
      }

      // Crear usuario en Supabase Auth
      final response =
          await _authService.createUserWithEmailAndPassword(email, password);

      if (response.user != null) {
        final userId = response.user!.id;

        // Crear documento en DB según el rol
        await _authService.createUserInFirestore(
          uid: userId,
          email: email,
          name: name,
          userType: _roleToUserType(role),
        );

        // Actualizar metadatos de usuario con el nombre
        await Supabase.instance.client.auth
            .updateUser(UserAttributes(data: {'name': name, 'fullName': name}));

        debugPrint('REGISTRO EXITOSO');

        // IMPORTANTE: Hacer logout inmediatamente después del registro
        await _authService.signOut();

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error en registro: $e');
      _errorMessage = _getSupabaseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('\n=== RESET PASSWORD ===');
      debugPrint('Email: $email');

      await _authService.sendPasswordResetEmail(email);

      debugPrint('Email de reset enviado');
    } catch (e) {
      debugPrint('Error en reset password: $e');
      throw _getSupabaseErrorMessage(e);
    }
  }

  /// Actualiza la contraseña del usuario actual
  Future<void> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _authService.updatePassword(newPassword);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = _getSupabaseErrorMessage(e);
      rethrow;
    }
  }

  // CONVERTIR UserRole a UserType
  UserType _roleToUserType(UserRole role) {
    switch (role) {
      case UserRole.client:
        return UserType.client;
      case UserRole.provider:
        return UserType.provider;
      case UserRole.admin:
        return UserType.admin;
    }
  }

  // Recargar datos del usuario actual
  Future<void> reloadUserData() async {
    if (_user == null) return;
    await _handleUserSignIn(_user!);
  }

  // Método auxiliar para manejar loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === FUNCIONES CORREGIDAS PARA PANEL FLOTANTE ===

  // MÉTODO PARA GUARDAR BOOKING PENDIENTE CON DURACIÓN FLEXIBLE
  void setPendingBooking(Map<String, dynamic> bookingData) {
    logger.d('\n=== GUARDANDO BOOKING EN AUTH PROVIDER ===');
    logger.d('Datos recibidos: ${bookingData.keys.toList()}');
    logger.d('ServiceTitle: ${bookingData['serviceTitle']}');
    logger.d('FinalTotal: ${bookingData['finalTotal']}');

    // NUEVO: Validar y procesar duración flexible
    if (bookingData['duration'] != null) {
      final durationData = bookingData['duration'];
      if (durationData is Map<String, dynamic>) {
        final duration = BookingDuration.fromMap(durationData);
        logger.d(
            'Duración: ${duration.displayText} (multiplicador: ${duration.getMultiplier()})');
      }
    }

    _pendingBookingData = Map<String, dynamic>.from(bookingData);

    logger.i('Booking guardado exitosamente');
    logger.d(
        'Verificación - pendingBookingData != null: ${_pendingBookingData != null}');
    logger.d('=== BOOKING GUARDADO COMPLETAMENTE ===\n');

    notifyListeners();
  }

  // MÉTODO PARA LIMPIAR BOOKING
  void clearPendingBooking() {
    logger.d('Limpiando booking pendiente');
    _pendingBookingData = null;
    notifyListeners();
  }

  // MÉTODO PARA LIMPIAR BOOKING Y OCULTAR MODAL
  void clearPendingBookingAndHideModal() {
    logger.d('Limpiando booking pendiente y ocultando modal');
    _pendingBookingData = null;
    _shouldShowProviderModal = false;

    notifyListeners();
  }

  // MÉTODO CORREGIDO: Cancelar booking y volver al home
  void cancelBookingAndGoHome(BuildContext context) {
    debugPrint('Cancelando reserva y navegando al home');

    // Limpiar datos pendientes
    clearPendingBooking();

    // Cerrar cualquier modal/navegación pendiente
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Navegar al home del cliente
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/client-home',
      (route) => false,
    );

    // Mostrar mensaje informativo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Reserva cancelada'),
          ],
        ),
        backgroundColor: Color(0xFFFF9800), // Equivalente a Colors.orange[600]
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // MÉTODO PRINCIPAL CORREGIDO: Solo mostrar modal si viene de booking
  Future<void> checkAndShowProviderSelection(BuildContext context) async {
    debugPrint('\n=== VERIFICANDO SI MOSTRAR MODAL DE PROVEEDORES ===');
    debugPrint('Usuario autenticado: $isAuthenticated');
    debugPrint('Tiene booking pendiente: $hasPendingBooking');
    debugPrint('Viene de booking: ${_pendingBookingData?['fromBooking']}');
    debugPrint('Debe mostrar modal: $shouldShowModal');

    // VALIDACIÓN ESTRICTA: Solo si viene específicamente de booking
    if (!shouldShowModal) {
      debugPrint('No mostrar modal - no viene de booking válido');
      return;
    }

    final bookingData = _pendingBookingData!;
    debugPrint('Mostrando modal para servicio: ${bookingData['serviceTitle']}');

    // Esperar estabilización de UI
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) {
      debugPrint('Context no válido para navegación');
      return;
    }

    try {
      debugPrint('Ejecutando modal de selección de proveedores...');

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => PopScope(
          canPop: false,
          child: PostLoginProviderModal(
            bookingData: bookingData,
            onProviderSelected: (providerData) {
              Navigator.pop(context);
              _proceedToFinalPayment(context, bookingData, providerData);
            },
            onCancel: () {
              Navigator.pop(context);
              cancelBookingAndGoHome(context);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error mostrando modal: $e');
    }

    debugPrint('=== FIN VERIFICACIÓN MODAL ===\n');
  }

  // MÉTODO CORREGIDO: Proceder al pago final con pantalla completa
  void _proceedToFinalPayment(BuildContext context,
      Map<String, dynamic> bookingData, Map<String, dynamic> providerData) {
    debugPrint('Navegando a pantalla de pago final');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingData: bookingData,
          providerData: providerData,
          onPaymentComplete: () {
            _completeBooking(context, bookingData, providerData);
          },
          onCancel: () {
            cancelBookingAndGoHome(context);
          },
        ),
      ),
    );
  }

  // MÉTODO MEJORADO: Completar booking con duración flexible
  Future<void> _completeBooking(
    BuildContext context,
    Map<String, dynamic> bookingData,
    Map<String, dynamic> providerData,
  ) async {
    try {
      logger.d('Creando booking final en Supabase');
      logger.d('Servicio: ${bookingData['serviceTitle']}');
      logger.d('👨‍💼 Proveedor: ${providerData['providerName']}');
      logger.d('Total: \$${bookingData['finalTotal']}');
      logger.d('Cliente: ${_userData?['name'] ?? 'Usuario'}');

      // NUEVO: Procesar duración flexible
      BookingDuration? duration;
      if (bookingData['duration'] != null) {
        duration = BookingDuration.fromMap(bookingData['duration']);
        logger.d('Duración: ${duration.displayText}');
      }

      // Crear documento de booking en Supabase
      final bookingDoc = {
        'client_id': _user?.id ?? 'unknown',
        'provider_id': providerData['providerId'] ?? 'unknown',
        'service_id': bookingData['serviceId'] ?? 'unknown',
        'service_title': bookingData['serviceTitle'] ?? 'Servicio',
        'service_category': bookingData['serviceCategory'] ?? 'General',
        'provider_name': providerData['providerName'] ?? 'Proveedor',
        'client_name':
            _userData?['name'] ?? _user?.userMetadata?['name'] ?? 'Cliente',
        'client_email': _user?.email ?? 'cliente@example.com',
        'date':
            bookingData['date']?.toString() ?? DateTime.now().toIso8601String(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'base_price': bookingData['basePrice'] ?? 0.0,
        'total_price': bookingData['finalTotal'] ?? 0.0,
        'payment_method': bookingData['paymentMethod'] ?? 'card',
        'time': bookingData['time'] ?? '09:00',
        'duration': duration?.toMap() ??
            {
              'type': 'hours',
              'quantity': 2,
              'displayText': '2 horas',
              'multiplier': 2.0,
            },
        'notes': bookingData['notes'] ?? '',
        'images': bookingData['images'] ?? [],
      };

      await Supabase.instance.client.from('bookings').insert(bookingDoc);

      logger.d('Booking guardado en Supabase exitosamente');

      // Limpiar reserva pendiente
      clearPendingBooking();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '¡Reserva confirmada!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Proveedor: ${providerData['providerName']}'),
                  Text('Servicio: ${bookingData['serviceTitle']}'),
                  if (duration != null)
                    Text('Duración: ${duration.displayText}'),
                  Text(
                      'Total: \$${bookingData['finalTotal']?.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Te contactaremos pronto para coordinar el servicio',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Volver al home
        Navigator.pushNamedAndRemoveUntil(
            context, '/client-home', (route) => false);
      }
    } catch (e) {
      logger.e('Error completando booking: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar la reserva: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  // MÉTODO signOut MEJORADO
  Future<void> signOut() async {
    try {
      debugPrint('\n🔓 === INICIANDO LOGOUT ===');
      // AGREGAR: Limpiar cache antes de cerrar sesión
      await clearImageCache();
      _setLoading(true);

      // LIMPIAR DATOS ANTES del logout
      debugPrint('Pre-limpieza de datos...');
      clearPendingBooking();

      // Hacer logout en Supabase
      await _authService.signOut();

      // El _handleUserSignOut se ejecutará automáticamente
      debugPrint('Logout completado exitosamente');
      debugPrint('🔓 === FIN LOGOUT ===\n');
      _cachedProfileImagePath = null;
    } catch (e) {
      debugPrint('Error en logout: $e');
      _errorMessage = 'Error al cerrar sesión: $e';
      _cachedProfileImagePath = null;

      // Aún así, limpiar datos locales
      clearPendingBooking();

      _setLoading(false);
    }
  }

  // Convertir errores de Supabase a mensajes legibles
  String _getSupabaseErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message; // Supabase errors are usually good
    }
    return 'Error: $error';
  }

  // MÉTODO PARA LIMPIAR DESDE CLIENT_HOME
  void clearPendingBookingOnHomeLoad() {
    if (_pendingBookingData != null) {
      logger.d(
          'Limpiando reserva pendiente: ${_pendingBookingData!['serviceTitle']}');
      _pendingBookingData = null;
      notifyListeners();
    }
  }

  // Método para limpiar datos manualmente
  void forceCleanupBookingData() {
    debugPrint('=== FORZANDO LIMPIEZA DE DATOS DE RESERVA ===');
    clearPendingBooking();
    debugPrint('Datos de reserva forzadamente limpiados');
  }

  // MÉTODO DE DEBUG MEJORADO
  Map<String, dynamic> getDebugInfo() {
    return {
      'user_uid': _user?.id,
      'user_email': _user?.email,
      'user_type': _userType?.value,
      'has_user_data': _userData != null,
      'is_loading': _isLoading,
      'error_message': _errorMessage,
      'has_pending_booking': hasPendingBooking,
      'pending_booking_service': _pendingBookingData?['serviceTitle'],
      'from_booking_flag': _pendingBookingData?['fromBooking'],
      'should_show_modal_flag': _shouldShowProviderModal,
      'should_show_modal_calc': shouldShowModal,
      'pending_booking_keys': _pendingBookingData?.keys.toList(),
    };
  }

  // MÉTODO PARA DEBUG - VERIFICAR ESTADO
  void debugPendingBooking() {
    logger.d('\n=== DEBUG PENDING BOOKING ===');
    logger.d('hasPendingBooking: $hasPendingBooking');
    logger.d('serviceTitle: $pendingServiceTitle');
    logger.d('total: $pendingTotal');
    if (_pendingBookingData != null) {
      logger.d('Keys disponibles: ${_pendingBookingData!.keys.toList()}');
    }
    logger.d('=== FIN DEBUG ===\n');
  }

  /// Actualiza la imagen de perfil del usuario en los datos locales
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      debugPrint('🖼️ === ACTUALIZANDO IMAGEN DE PERFIL ===');
      debugPrint('Nueva URL: $imageUrl');

      if (_userData != null) {
        // Actualizar datos locales
        _userData!['profileImage'] = imageUrl;
        _userData!['photoUrl'] = imageUrl;
        _userData!['updatedAt'] = DateTime.now();

        debugPrint('Datos locales actualizados');

        // Notificar cambios
        notifyListeners();

        // Actualizar en Supabase
        if (_user?.id != null) {
          await _authService.updateUserProfile(uid: _user!.id, userData: {
            'profileImage': imageUrl,
            'photoUrl': imageUrl,
          });
        }
      }

      debugPrint('🖼️ === IMAGEN ACTUALIZADA EXITOSAMENTE ===');
    } catch (e) {
      debugPrint('Error actualizando imagen de perfil: $e');
      throw 'Error al actualizar imagen: $e';
    }
  }

  /// Limpia cache de imágenes al cerrar sesión
  Future<void> clearImageCache() async {
    _cachedProfileImagePath = null;
    debugPrint('Cache de imágenes limpiado');
  }

  /// Obtiene la URL actual de la imagen de perfil
  String? getCurrentProfileImageUrl() {
    return _userData?['profileImage'] ??
        _userData?['photoUrl'] ??
        _user?.userMetadata?['avatar_url'];
  }

  /// Actualiza múltiples datos del perfil
  Future<void> updateProfileData(Map<String, dynamic> newData) async {
    try {
      debugPrint('📝 === ACTUALIZANDO DATOS DE PERFIL ===');

      if (_userData != null && _user?.id != null) {
        // Actualizar datos locales
        _userData!.addAll(newData);
        _userData!['updatedAt'] = DateTime.now();

        // Notificar cambios
        notifyListeners();

        // Actualizar en Supabase
        await _authService.updateUserProfile(uid: _user!.id, userData: newData);

        debugPrint('Datos de perfil actualizados en Supabase');
      }
    } catch (e) {
      debugPrint('Error actualizando datos de perfil: $e');
      throw 'Error al actualizar perfil: $e';
    }
  }

  // ============================================================
  // MÉTODOS PARA CACHE DE IMAGEN DE PERFIL
  // ============================================================

  /// Carga imagen de perfil en cache
  Future<void> loadProfileImageCache() async {
    final profileImageUrl = getCurrentProfileImageUrl();

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      try {
        debugPrint('Cargando imagen de perfil en cache...');

        final cachedPath =
            profileImageUrl; // Placeholder si no tienes ImageCacheService

        _cachedProfileImagePath = cachedPath;
        notifyListeners();
        debugPrint('Imagen de perfil cacheada: $cachedPath');
      } catch (e) {
        debugPrint('Error cacheando imagen de perfil: $e');
      }
    }
  }

  // NUEVOS MÉTODOS PARA DURACIÓN FLEXIBLE

  /// Calcula el precio total basado en duración flexible
  double calculateTotalPrice(double basePrice, BookingDuration duration) {
    final multiplier = duration.getMultiplier();
    return basePrice * multiplier;
  }

  /// Obtiene opciones de duración predefinidas
  List<BookingDuration> getDefaultDurationOptions() {
    return [
      const BookingDuration(type: DurationType.hours, quantity: 1),
      const BookingDuration(type: DurationType.hours, quantity: 2),
      const BookingDuration(type: DurationType.hours, quantity: 4),
      const BookingDuration(type: DurationType.hours, quantity: 8),
      const BookingDuration(type: DurationType.days, quantity: 1),
      const BookingDuration(type: DurationType.days, quantity: 2),
      const BookingDuration(type: DurationType.days, quantity: 3),
      const BookingDuration(type: DurationType.weeks, quantity: 1),
      const BookingDuration(type: DurationType.weeks, quantity: 2),
    ];
  }

  /// Valida si una duración personalizada es válida
  bool validateCustomDuration(int quantity, String? description) {
    return quantity > 0 &&
        quantity <= 1000 && // Límite máximo razonable
        (description?.isNotEmpty ?? false);
  }
}

// NUEVA PANTALLA DE PAGO FINAL CON DURACIÓN FLEXIBLE
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> providerData;
  final VoidCallback onPaymentComplete;
  final VoidCallback onCancel;

  const PaymentScreen({
    super.key,
    required this.bookingData,
    required this.providerData,
    required this.onPaymentComplete,
    required this.onCancel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'card';
  bool isProcessing = false;
  bool acceptTerms = false;

  void _processPayment() async {
    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simular proceso
    if (mounted) {
      setState(() => isProcessing = false);
      widget.onPaymentComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // NUEVO: Procesar duración flexible
    BookingDuration? duration;
    if (widget.bookingData['duration'] != null) {
      duration = BookingDuration.fromMap(widget.bookingData['duration']);
    }

    final basePrice = widget.bookingData['basePrice']?.toDouble() ?? 0.0;
    final commission = basePrice * 0.05; // 5% comisión
    final tax = basePrice * 0.12; // 12% IVA
    final total = widget.bookingData['finalTotal']?.toDouble() ??
        (basePrice + commission + tax);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Confirmar Pago',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del servicio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cleaning_services,
                          color: Color(0xFF3498DB),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bookingData['serviceTitle'] ?? 'Servicio',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.bookingData['serviceCategory'] ??
                                  'Servicio profesional',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            // NUEVO: Mostrar duración flexible
                            if (duration != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  duration.displayText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF27AE60),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Información del proveedor
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            const Color(0xFF27AE60).withValues(alpha: 0.1),
                        child: Text(
                          (widget.providerData['providerName'] ?? 'P')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.providerData['providerName'] ??
                                  'Proveedor',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.providerData['providerRating']?.toStringAsFixed(1) ?? '4.8'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${widget.providerData['providerJobs'] ?? 15} trabajos)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // NUEVO: Desglose de precios con duración flexible
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desglose del precio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow('Precio base por hora',
                      basePrice / (duration?.getMultiplier() ?? 1)),
                  if (duration != null)
                    _buildPriceRow(
                        '${duration.displayText} (x${duration.getMultiplier()})',
                        basePrice),
                  _buildPriceRow('Comisión de servicio (5%)', commission),
                  _buildPriceRow('IVA (12%)', tax),
                  const SizedBox(height: 12),
                  const Divider(thickness: 2),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a pagar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Métodos de pago
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Método de pago',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethod(
                    'card',
                    'Tarjeta de crédito/débito',
                    Icons.credit_card,
                    const Color(0xFF3498DB),
                  ),
                  _buildPaymentMethod(
                    'paypal',
                    'PayPal',
                    Icons.account_balance_wallet,
                    const Color(0xFF0070BA),
                  ),
                  _buildPaymentMethod(
                    'transfer',
                    'Transferencia bancaria',
                    Icons.account_balance,
                    const Color(0xFF8E44AD),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Términos y condiciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF27AE60),
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto los términos y condiciones del servicio',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón de pago
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    acceptTerms && !isProcessing ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Procesando pago...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pagar \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de seguridad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF3498DB).withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu pago está protegido con encriptación de nivel bancario',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
      String id, String label, IconData icon, Color color) {
    final isSelected = selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
