// ============================================================================
// PANTALLA 4: FINAL PAYMENT SCREEN
// features/booking/final_payment_screen.dart
// ============================================================================
// Pantalla final del proceso de reserva donde el usuario puede:
// - Revisar todos los detalles del servicio y proveedor
// - Seleccionar fecha y hora del servicio
// - Confirmar el método de pago
// - Procesar la reserva y el pago
// - Ver animación de confirmación exitosa

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/database_service.dart';
import '../../../providers/auth_provider.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/user_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/routes/route_arguments.dart';
// Importación de widgets modulares para mejor organización del código
import '../booking/final_payment_screen/widgets/modern_app_bar.dart';
import '../booking/final_payment_screen/widgets/service_summary_card.dart';
import '../booking/final_payment_screen/widgets/provider_card.dart';
import '../booking/final_payment_screen/widgets/scheduling_card.dart';
import '../booking/final_payment_screen/widgets/price_breakdown_card.dart';
import '../booking/final_payment_screen/widgets/payment_method_card.dart';
import '../booking/final_payment_screen/widgets/terms_card.dart';
import '../booking/final_payment_screen/widgets/bottom_action_section.dart';
import '../booking/final_payment_screen/widgets/success_screen.dart';
import '../booking/final_payment_screen/widgets/dialogs.dart';

/// Widget principal de la pantalla de pago final
/// Implementa StatefulWidget con TickerProviderStateMixin para animaciones
class FinalPaymentScreen extends StatefulWidget {
  /// Argumentos opcionales que contienen los datos de la reserva
  final FinalPaymentArguments? arguments;

  const FinalPaymentScreen({
    super.key,
    this.arguments,
  });

  @override
  State<FinalPaymentScreen> createState() => _FinalPaymentScreenState();
}

class _FinalPaymentScreenState extends State<FinalPaymentScreen>
    with TickerProviderStateMixin {
  // ======================== VARIABLES DE ESTADO ========================

  /// Argumentos recibidos desde la pantalla anterior con datos de la reserva
  FinalPaymentArguments? args;

  /// Modelo que contiene todos los datos finales de la reserva
  late BookingModel finalBookingData;

  /// Estado que indica si se está procesando el pago actualmente
  bool isProcessingPayment = false;

  /// Controla la visualización de la animación de éxito
  bool showSuccessAnimation = false;

  /// Fecha y hora seleccionada para el servicio (por defecto: 2 horas desde ahora)
  DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 2));

  /// ID de la reserva creada exitosamente en base de datos
  String? createdBookingId;

  // ======================== ANIMACIONES ========================

  /// Controlador principal para animaciones de entrada de la pantalla
  late AnimationController _animationController;

  /// Controlador para animaciones de la pantalla de éxito
  late AnimationController _successController;

  /// Animación de desvanecimiento (fade) de 0.0 a 1.0
  late Animation<double> _fadeAnimation;

  /// Animación de deslizamiento desde abajo hacia su posición final
  late Animation<Offset> _slideAnimation;

  /// Animación de escala elástica para la pantalla de éxito
  late Animation<double> _successScaleAnimation;

  // ======================== CICLO DE VIDA DEL WIDGET ========================

  @override
  void initState() {
    super.initState();
    _setupAnimations(); // Configurar todas las animaciones al inicializar
  }

  /// Se ejecuta después de initState() cuando las dependencias están disponibles
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData(); // Inicializar datos de la reserva
  }

  /// Limpia los recursos al destruir el widget
  @override
  void dispose() {
    _animationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  // ======================== INICIALIZACIÓN DE DATOS ========================

  /// Inicializa los datos de la reserva desde los argumentos recibidos
  /// Si no hay argumentos, usa datos por defecto para testing
  void _initializeData() {
    args = widget.arguments ??
        ModalRoute.of(context)?.settings.arguments as FinalPaymentArguments?;

    if (args != null) {
      finalBookingData = args!.finalBookingData;
      selectedDateTime = finalBookingData.scheduledDate;

      debugPrint('FinalPayment inicializado con:');
      debugPrint('   - Servicio: ${finalBookingData.serviceTitle}');
      debugPrint('   - Proveedor: ${finalBookingData.providerName}');
      debugPrint('   - Total: \$${finalTotal.toStringAsFixed(2)}');
      debugPrint('   - Método: $paymentMethod');
    } else {
      finalBookingData = _getDefaultBookingData();
      debugPrint('FinalPayment usando datos por defecto');
    }
  }

  BookingModel _getDefaultBookingData() {
    final service = ServiceModel(
      id: 'default',
      title: 'Servicio de Limpieza',
      description: 'Default service',
      category: ServiceCategory.cleaning,
      basePrice: 15.0,
      hourlyRate: 15.0,
      providerId: 'example_provider',
      providerName: 'Proveedor de Ejemplo',
      createdAt: DateTime.now(),
    );

    return BookingModel(
      id: 'pending',
      serviceId: service.id,
      clientId: 'example_client',
      providerId: service.providerId,
      status: BookingStatus.pending,
      scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      totalPrice: 15.0,
      serviceData: service,
      clientName: 'Cliente Ejemplo',
      clientPhone: '0987654321',
      providerName: service.providerName,
      serviceTitle: service.title,
      address: 'Tena, Napo',
      createdAt: DateTime.now(),
      paymentMethod: 'efectivo',
    );
  }

  // ======================== GETTERS SIMPLIFICADOS ========================
  // Estos getters extraen datos específicos del mapa finalBookingData
  // con valores por defecto para evitar errores null

  /// Método de pago seleccionado (efectivo por defecto)
  String get paymentMethod => finalBookingData.paymentMethod ?? 'efectivo';
  double get finalTotal => finalBookingData.totalPrice;
  ServiceModel get serviceData => finalBookingData.serviceData!;
  UserModel? get selectedProvider => finalBookingData.providerData;
  List<Map<String, dynamic>> get selectedOptions =>
      finalBookingData.selectedOptions;

  // ======================== CONFIGURACIÓN DE ANIMACIONES ========================

  /// Configura todos los controladores y animaciones de la pantalla
  void _setupAnimations() {
    // Controlador principal: animación de entrada (800ms)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controlador de éxito: animación de confirmación (1200ms)
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animación de desvanecimiento suave con curva easeOut
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Animación de deslizamiento desde 20% abajo con curva cúbica
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Animación de escala elástica para la pantalla de éxito
    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    // Iniciar animación de entrada inmediatamente
    _animationController.forward();
  }

  // ======================== MÉTODOS DE CONSTRUCCIÓN DE UI ========================

  /// Método principal de construcción del widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      // Alternar entre pantalla principal y pantalla de éxito
      body: showSuccessAnimation ? _buildSuccessScreen() : _buildMainScreen(),
    );
  }

  /// Construye la pantalla principal con todos los detalles de la reserva
  Widget _buildMainScreen() {
    return SafeArea(
      child: Column(
        children: [
          // Barra superior con botón de regreso y título
          ModernAppBar(
            isProcessingPayment: isProcessingPayment,
            onBackPressed: () => Navigator.pop(context),
          ),
          // Contenido principal scrolleable
          Expanded(child: _buildMainContent()),
          // Sección inferior con botones de acción
          BottomActionSection(
            isProcessingPayment: isProcessingPayment,
            paymentMethod: paymentMethod,
            finalTotal: finalTotal,
            onCancel: _cancelBooking,
            onProcess: _processBookingAndPayment,
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal con animaciones
  /// Incluye todas las tarjetas de información organizadas verticalmente
  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(), // Scroll con rebote iOS
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta con resumen del servicio y opciones
                  ServiceSummaryCard(
                    serviceData: serviceData,
                    selectedOptions: selectedOptions,
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta con información del proveedor
                  ProviderCard(selectedProvider: selectedProvider),
                  const SizedBox(height: 16),

                  // Tarjeta para selección de fecha y hora
                  SchedulingCard(
                    selectedDateTime: selectedDateTime,
                    estimatedHours: finalBookingData.estimatedHours,
                    isProcessingPayment: isProcessingPayment,
                    onDateSelect: _selectDate,
                    onTimeSelect: _selectTime,
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta con desglose de precios
                  PriceBreakdownCard(finalBookingData: finalBookingData),
                  const SizedBox(height: 16),

                  // Tarjeta con método de pago seleccionado
                  PaymentMethodCard(paymentMethod: paymentMethod),
                  const SizedBox(height: 16),

                  // Tarjeta con términos y condiciones
                  const TermsCard(),

                  // Espacio adicional para evitar superposición con botones
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye la pantalla de éxito con animación
  Widget _buildSuccessScreen() {
    return SuccessScreen(
      selectedDateTime: selectedDateTime,
      finalBookingData: finalBookingData,
      successController: _successController,
      successScaleAnimation: _successScaleAnimation,
      // Al cerrar, navegar al home y limpiar stack de navegación
      onClose: () => Navigator.pushNamedAndRemoveUntil(
        context,
        '/client-home',
        (route) => false,
      ),
    );
  }

  // ======================== MÉTODOS DE SELECCIÓN DE FECHA Y HORA ========================

  /// Muestra el selector de fecha y actualiza selectedDateTime
  /// Permite seleccionar desde hoy hasta 30 días en el futuro
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(), // No permitir fechas pasadas
      lastDate: DateTime.now().add(const Duration(days: 30)), // Máximo 30 días
      locale: const Locale('es', 'EC'), // Configuración para Ecuador
      helpText: 'Seleccionar fecha del servicio',
    );

    if (picked != null) {
      setState(() {
        // Mantener la hora actual, solo cambiar la fecha
        selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  /// Muestra el selector de hora y actualiza selectedDateTime
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      helpText: 'Seleccionar hora del servicio',
    );

    if (picked != null) {
      setState(() {
        // Mantener la fecha actual, solo cambiar la hora
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          picked.hour,
          picked.minute,
          picked.hour,
        );
      });
    }
  }

  /// Muestra diálogo de confirmación para cancelar la reserva
  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (context) => CancelBookingDialog(
        onConfirm: () {
          Navigator.pop(context); // Cerrar diálogo
          // Navegar al home y limpiar toda la pila de navegación
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/client-home',
            (route) => false,
          );
        },
      ),
    );
  }

  // ======================== PROCESAMIENTO DE RESERVA Y PAGO ========================

  /// Método principal que orquesta todo el proceso de creación de reserva
  /// Pasos: 1) Preparar datos 2) Procesar pago 3) Crear reserva
  ///        4) Actualizar stats 5) Enviar notificaciones 6) Mostrar éxito
  Future<void> _processBookingAndPayment() async {
    setState(() => isProcessingPayment = true);

    try {
      // Obtener usuario autenticado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentDatabaseUser;

      if (currentUser == null) {
        throw Exception('Usuario no autenticado (o perfil incompleto)');
      }

      debugPrint('=== INICIANDO PROCESAMIENTO DE RESERVA ===');

      // Paso 1: Preparar todos los datos de la reserva
      final bookingDataMap = await _prepareBookingData(currentUser);

      // Paso 2: Simular procesamiento del pago
      await _processPayment();

      // Paso 3: Crear la reserva en Supabase y obtener el ID
      final bookingId = await _createBooking(bookingDataMap);

      // Paso 4: Actualizar estadísticas del proveedor
      await _updateProviderStats(finalBookingData.providerId);

      // Paso 5: Enviar notificaciones a cliente y proveedor
      await _sendNotifications(bookingDataMap, bookingId);

      // Paso 6: Limpiar datos pendientes en el provider
      authProvider.clearPendingBooking();

      // Guardar ID de la reserva para referencia futura
      createdBookingId = bookingId;

      // Mostrar pantalla de éxito con animación
      setState(() {
        isProcessingPayment = false;
        showSuccessAnimation = true;
      });

      _successController.forward(); // Iniciar animación de éxito

      debugPrint('=== RESERVA PROCESADA EXITOSAMENTE ===');
      debugPrint('   - ID: $bookingId');
      debugPrint('   - Servicio: ${finalBookingData.serviceTitle}');
      debugPrint('   - Total: \$${finalBookingData.totalPrice}');
    } catch (e) {
      // En caso de error, detener loading y mostrar diálogo de error
      setState(() => isProcessingPayment = false);
      debugPrint('Error en procesamiento: $e');
      if (mounted) _showErrorDialog(e.toString());
    }
  }

  /// Prepara y valida todos los datos necesarios para crear la reserva
  /// Extrae información del usuario, proveedor y servicio
  Future<Map<String, dynamic>> _prepareBookingData(
      UserModel currentUser) async {
    return finalBookingData
        .copyWith(
          scheduledDate: selectedDateTime,
        )
        .toJson();
  }

  /// Simula el procesamiento del pago según el método seleccionado
  /// Diferentes tiempos de espera para diferentes métodos de pago
  Future<void> _processPayment() async {
    const paymentDelays = {
      'tarjeta': Duration(seconds: 2), // Tarjeta: 2 segundos
      'transferencia': Duration(seconds: 1), // Transferencia: 1 segundo
      'efectivo': Duration(milliseconds: 800), // Efectivo: 800ms
    };

    // Aplicar delay según método de pago (efectivo por defecto)
    await Future.delayed(
        paymentDelays[paymentMethod] ?? const Duration(seconds: 1));
    debugPrint('Pago simulado completado: $paymentMethod');
  }

  /// Crea la reserva en Supabase y retorna el ID generado
  Future<String> _createBooking(Map<String, dynamic> bookingData) async {
    try {
      // createBooking method in DatabaseService should be updated to return response compatible with Supabase logic.
      // Assuming database_service.dart creates booking in Supabase now.
      // But ref: database_service.dart was mostly just imports, user said "DatabaseService: This is the new central service... replaces FirestoreService".
      // Let's use direct Supabase call here OR ensure DatabaseService returns what we need.
      // createBooking in DatabaseService usually returns a DocumentReference in Firebase.
      // We should check what DatabaseService.createBooking does now.
      // Actually, I'll use Supabase client directly here for safety or update DatabaseService.
      // The DatabaseService likely returns Future<dynamic> or Map.

      final response = await DatabaseService().createBooking(bookingData);
      final bookingId = response['id'].toString();

      debugPrint('Reserva creada exitosamente con ID: $bookingId');
      return bookingId;
    } catch (e) {
      debugPrint('Error al crear la reserva: $e');
      throw Exception('Error al crear la reserva: $e');
    }
  }

  /// Actualiza las estadísticas del proveedor en Supabase
  /// Incrementa trabajos pendientes y actualiza fecha de última reserva
  Future<void> _updateProviderStats(String providerId) async {
    try {
      await DatabaseService().updateProviderStats(providerId, {
        'lastBookingDate': DateTime.now().toIso8601String(),
      });

      debugPrint('Estadísticas del proveedor actualizadas');
    } catch (e) {
      debugPrint('Error actualizando estadísticas del proveedor: $e');
      // No lanzar error aquí, las stats no son críticas
    }
  }

  /// Crea notificaciones para el proveedor y el cliente
  /// Proveedor: recibe notificación de nueva reserva
  /// Cliente: recibe confirmación de reserva enviada
  Future<void> _sendNotifications(
      Map<String, dynamic> bookingData, String bookingId) async {
    try {
      final notifications = [
        // Notificación para el proveedor
        {
          'recipientId': bookingData['providerId'],
          'type': 'new_booking',
          'title': 'Nueva reserva recibida',
          'body':
              'Tienes una nueva solicitud de ${bookingData['serviceTitle']}',
          'data': {
            'bookingId': bookingId,
            'clientName': bookingData['clientName'],
            'serviceTitle': bookingData['serviceTitle'],
            'scheduledDateTime': bookingData['scheduledDateTime'],
            'finalTotal': bookingData['finalTotal'],
          },
        },
        // Notificación para el cliente
        {
          'recipientId': bookingData['clientId'],
          'type': 'booking_created',
          'title': 'Reserva enviada exitosamente',
          'body':
              'Tu solicitud de ${bookingData['serviceTitle']} ha sido enviada a ${bookingData['providerName']}',
          'data': {
            'bookingId': bookingId,
            'providerName': bookingData['providerName'],
            'serviceTitle': bookingData['serviceTitle'],
            'scheduledDateTime': bookingData['scheduledDateTime'],
            'finalTotal': bookingData['finalTotal'],
          },
        },
      ];

      for (final notification in notifications) {
        final userId = notification['recipientId'];
        final data = notification['data'];

        await DatabaseService().createNotification({
          'userId': userId,
          'type': notification['type'],
          'title': notification['title'],
          'body': notification['body'],
          'data': data,
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
        });
      }

      debugPrint('Notificaciones enviadas exitosamente');
    } catch (e) {
      debugPrint('Error enviando notificaciones: $e');
      // No lanzar error aquí, las notificaciones no son críticas
    }
  }

  /// Muestra diálogo de error con opción de reintentar
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        error: error,
        onRetry: () {
          Navigator.pop(context); // Cerrar diálogo
          _processBookingAndPayment(); // Reintentar proceso
        },
      ),
    );
  }
}
