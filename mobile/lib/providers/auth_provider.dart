import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/services/auth_service.dart';
import '../data/services/base_api_service.dart';
import '../core/services/notification_service.dart';
import '../shared/widgets/common/post_login_provider_modal.dart';
import '../../core/utils/app_logger.dart';

enum UserRole {
  client,
  provider,
  admin,
}

// Enum para tipos de duración
enum DurationType {
  hours('horas'),
  days('días'),
  weeks('semanas'),
  custom('personalizado');

  const DurationType(this.displayName);
  final String displayName;
}

// Clase para manejar duración flexible
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

  firebase_auth.User? _user;
  UserType? _userType;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // === VARIABLES PARA PANEL FLOTANTE ===
  Map<String, dynamic>? _pendingBookingData;
  bool _shouldShowProviderModal = false;

  // imagen caches
  String? _cachedProfileImagePath;

  // Constructor - verificar estado inicial
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initializeAuthState();
  }

  String? get cachedProfileImagePath => _cachedProfileImagePath;

  // Getters principales
  firebase_auth.User? get user => _user;
  firebase_auth.User? get currentUser => _user;
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

  // Solo mostrar modal si viene específicamente de booking
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
  String? get currentUserId => _user?.uid;
  String? get currentUserEmail => _user?.email;
  // Firebase User has displayName directamente
  String? get currentUserDisplayName => _user?.displayName;

  // Inicializar estado de autenticación
  void _initializeAuthState() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        if (_user?.uid != user.uid) {
          _handleUserSignIn(user);
        }
      } else {
        _handleUserSignOut();
      }
    });
  }

  // Manejar cuando un usuario se loguea
  Future<void> _handleUserSignIn(firebase_auth.User user) async {
    debugPrint('\n=== USUARIO LOGUEADO (FIREBASE) ===');
    debugPrint('🆔 UID: ${user.uid}');
    debugPrint('Email: ${user.email}');

    _user = user;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Guardar Token FCM al iniciar sesión
      await NotificationService.updateTokenForCurrentUser();

      // OBTENER TIPO DE USUARIO Y DATOS DESDE BACKEND (Django)
      _userType = await _authService.getUserType(user.uid);
      _userData = await _authService.getUserData(user.uid);

      if (_userType != null && _userData != null) {
        debugPrint('Datos cargados exitosamente');
        debugPrint('Tipo: $_userType');
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

  // Limpiar TODOS los datos al logout
  void _handleUserSignOut() {
    debugPrint('\n👋 === USUARIO DESLOGUEADO ===');
    _user = null;
    _userType = null;
    _userData = null;
    _errorMessage = null;
    _isLoading = false;

    // LIMPIAR COMPLETAMENTE DATOS DE RESERVA PENDIENTE
    clearPendingBooking();
    notifyListeners();
    debugPrint('👋 === FIN LOGOUT CLEANUP ===\n');
  }

  // Login con email y password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n=== INICIANDO LOGIN ===');
      await _authService.signInWithEmailAndPassword(email, password);

      // Cargar imagen en cache si es necesario
      await loadProfileImageCache();

      // Esperar a que se carguen los datos en _handleUserSignIn
      int attempts = 0;
      while (_isLoading && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      final success = _user != null && _userType != null;
      debugPrint('=== FIN LOGIN (Success: $success) ===\n');
      return success;
    } catch (e) {
      debugPrint('Error en login: $e');
      _errorMessage = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  // Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n=== INICIANDO LOGIN CON GOOGLE ===');
      await _authService.signInWithGoogle();

      await loadProfileImageCache();

      int attempts = 0;
      while (_isLoading && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      final success = _user != null;
      debugPrint('=== FIN LOGIN GOOGLE (Success: $success) ===\n');
      return success;
    } catch (e) {
      debugPrint('Error en login con Google: $e');
      if (e.toString().contains('Cancelado')) {
        _errorMessage = null;
      } else {
        _errorMessage = _getAuthErrorMessage(e);
      }
      _setLoading(false);
      return false;
    }
  }

  // Registro de usuario (Email/Password)
  Future<bool> signUp(
      String email, String password, String name, UserRole role) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('\n📝 === INICIANDO REGISTRO ===');
      if (role != UserRole.client) {
        _errorMessage = 'Solo se permite registro de clientes';
        _setLoading(false);
        return false;
      }

      final userCredential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        await user.updateDisplayName(name);

        // Sincronizar con backend Django
        await _authService.syncWithBackend();

        debugPrint('REGISTRO EXITOSO');
        // Logout para obligar a login limpio
        await signOut();
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error en registro: $e');
      _errorMessage = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw _getAuthErrorMessage(e);
    }
  }

  // Actualizar password
  Future<void> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _user?.updatePassword(newPassword);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = _getAuthErrorMessage(e);
      rethrow;
    }
  }

  // Recargar datos del usuario actual
  Future<void> reloadUserData() async {
    if (_user == null) return;
    await _handleUserSignIn(_user!);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === LÓGICA DE BOOKING PENDIENTE ===
  void setPendingBooking(Map<String, dynamic> bookingData) {
    AppLogger.d('Guardando booking pendiente: ${bookingData['serviceTitle']}');
    _pendingBookingData = Map<String, dynamic>.from(bookingData);
    notifyListeners();
  }

  void clearPendingBooking() {
    _pendingBookingData = null;
    notifyListeners();
  }

  void clearPendingBookingAndHideModal() {
    _pendingBookingData = null;
    _shouldShowProviderModal = false;
    notifyListeners();
  }

  void cancelBookingAndGoHome(BuildContext context) {
    clearPendingBooking();
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushNamedAndRemoveUntil(context, '/client-home', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva cancelada'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> checkAndShowProviderSelection(BuildContext context) async {
    if (!shouldShowModal) return;

    final bookingData = _pendingBookingData!;
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;

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
  }

  void _proceedToFinalPayment(BuildContext context,
      Map<String, dynamic> bookingData, Map<String, dynamic> providerData) {
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

  Future<void> _completeBooking(
    BuildContext context,
    Map<String, dynamic> bookingData,
    Map<String, dynamic> providerData,
  ) async {
    try {
      AppLogger.d('Completando booking...');
      // Procesar duración flexible
      BookingDuration? duration;
      if (bookingData['duration'] != null) {
        duration = BookingDuration.fromMap(bookingData['duration']);
      }

      // IMPORTANTE: Aquí se sigue usando Supabase temporalmente para las reservas
      final bookingDoc = {
        'client_id': _user?.uid ?? 'unknown',
        'provider_id': providerData['providerId'] ?? 'unknown',
        'service_id': bookingData['serviceId'] ?? 'unknown',
        'service_title': bookingData['serviceTitle'] ?? 'Servicio',
        'service_category': bookingData['serviceCategory'] ?? 'General',
        'provider_name': providerData['providerName'] ?? 'Proveedor',
        'client_name': _userData?['name'] ?? _user?.displayName ?? 'Cliente',
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

      // Migración a Django: Usamos BaseApiService para enviar la reserva
      // El backend de Django ahora maneja la persistencia y notificaciones
      final apiService = BaseApiService();
      await apiService.post('bookings/', body: bookingDoc);

      clearPendingBooking();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/client-home', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reserva confirmada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.e('Error completando booking: $e');
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('\n🔓 === INICIANDO LOGOUT ===');
      _setLoading(true);
      clearPendingBooking();
      await _authService.signOut();
      _cachedProfileImagePath = null;
      debugPrint('Logout completado exitosamente');
    } catch (e) {
      debugPrint('Error en logout: $e');
      _errorMessage = 'Error al cerrar sesión: $e';
    } finally {
      _setLoading(false);
    }
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      return error.message ?? 'Error de autenticación de Firebase.';
    }
    return 'Error: $error';
  }

  // === MÉTODOS DE PERFIL ===
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      if (_userData != null && _user?.uid != null) {
        _userData!['profileImage'] = imageUrl;
        _userData!['photoUrl'] = imageUrl;
        notifyListeners();

        await _authService.updateUserProfile(uid: _user!.uid, userData: {
          'profileImage': imageUrl,
          'photoUrl': imageUrl,
        });
      }
    } catch (e) {
      debugPrint('Error actualizando imagen de perfil: $e');
    }
  }

  String? getCurrentProfileImageUrl() {
    return _userData?['profileImage'] ??
        _userData?['photoUrl'] ??
        _user?.photoURL;
  }

  Future<void> updateProfileData(Map<String, dynamic> newData) async {
    try {
      if (_userData != null && _user?.uid != null) {
        _userData!.addAll(newData);
        notifyListeners();
        await _authService.updateUserProfile(uid: _user!.uid, userData: newData);
      }
    } catch (e) {
      debugPrint('Error actualizando datos de perfil: $e');
    }
  }

  Future<void> loadProfileImageCache() async {
    final profileImageUrl = getCurrentProfileImageUrl();
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      _cachedProfileImagePath = profileImageUrl;
      notifyListeners();
    }
  }

  Map<String, dynamic> getDebugInfo() {
    return {
      'user_uid': _user?.uid,
      'user_email': _user?.email,
      'user_type': _userType?.value,
      'is_loading': _isLoading,
      'has_pending_booking': hasPendingBooking,
    };
  }
}

// Pantalla de Pago
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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => isProcessing = false);
      widget.onPaymentComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.bookingData['basePrice']?.toDouble() ?? 0.0;
    final double total = widget.bookingData['finalTotal']?.toDouble() ?? basePrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Servicio: ${widget.bookingData['serviceTitle']}'),
            Text('Proveedor: ${widget.providerData['providerName']}'),
            const Divider(),
            Text('Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Acepto los términos'),
              value: acceptTerms,
              onChanged: (val) => setState(() => acceptTerms = val ?? false),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: acceptTerms && !isProcessing ? _processPayment : null,
              child: isProcessing ? const CircularProgressIndicator() : const Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
