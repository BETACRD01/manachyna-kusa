// ============================================================================
// PANTALLA 1: SERVICE OPTIONS SCREEN
// features/booking/service_options_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../data/services/database_service.dart';
import '../../shared/widgets/common/loading_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../config/app_routes.dart';
import '../../config/routes/route_arguments.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/service_model.dart';
import 'service_options_screen/widgets/service_header_widget.dart';
import 'service_options_screen/widgets/services_grid_widget.dart';
import 'service_options_screen/widgets/heavy_work_option_widget.dart';
import 'service_options_screen/widgets/selected_services_details_widget.dart';
import 'service_options_screen/widgets/no_services_available_widget.dart';
import 'service_options_screen/utils/service_catalog.dart';

/// Pantalla para que el cliente seleccione **opciones** de un servicio base
/// (p. ej., limpieza + extras). Funciona **offline-first**:
/// - Intenta cargar opciones desde Firestore.
/// - Si falla o no hay opciones, usa un catálogo local (`ServiceCatalog`)
///   adaptado al contexto de Tena.
///
/// Reglas que preserva:
/// - No modifica rutas ni navegación.
/// - Mantiene la lógica, precios y recargos.
/// - Mantiene compatibilidad y nombres existentes.
///
/// Parámetros:
/// - [arguments]: datos iniciales del servicio (id, nombre, categoría, precio base).
class ServiceOptionsScreen extends StatefulWidget {
  /// Argumentos recibidos al navegar a esta pantalla.
  final ServiceOptionsArguments? arguments;

  /// Crea la pantalla de selección de opciones de servicio.
  const ServiceOptionsScreen({
    super.key,
    this.arguments,
  });

  @override
  State<ServiceOptionsScreen> createState() => _ServiceOptionsScreenState();
}

/// Estado de [ServiceOptionsScreen] con animaciones y manejo de datos.
class _ServiceOptionsScreenState extends State<ServiceOptionsScreen>
    with TickerProviderStateMixin {
  // ======================== VARIABLES DE ESTADO ========================

  /// Datos del servicio base (id, nombre, categoría, precio base).
  late Map<String, dynamic> serviceData = {};

  /// Mapa de selección de opciones por `id` (true = seleccionada).
  final Map<String, bool> selectedOptions = {};

  /// Mapa de precios por `id` de opción.
  final Map<String, double> optionPrices = {};

  /// Si el trabajo es pesado (recargo fijo).
  bool isHeavyWork = false;

  /// Indicador de carga inicial.
  bool isLoading = true;

  /// Opciones disponibles para el servicio (de Firestore o catálogo local).
  List<Map<String, dynamic>> availableOptions = [];

  /// Recargo fijo por trabajos pesados (mantener idéntico).
  static const double heavyWorkSurcharge = 5.0;

  /// Argumentos reales usados (de `widget.arguments` o de `ModalRoute`).
  ServiceOptionsArguments? args;

  // ======================== ANIMACIONES ========================
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ======================== CICLO DE VIDA ========================

  @override
  void initState() {
    super.initState();
    _setupAnimations(); // Configura animaciones (sin cambiar comportamiento).
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData(); // Carga argumentos y obtiene opciones.
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ======================== INICIALIZACIÓN ========================

  /// Inicializa `serviceData` a partir de argumentos de navegación o valores por defecto.
  /// Luego dispara la carga de opciones si es la primera vez.
  void _initializeData() {
    // Mantener compatibilidad: respeta `widget.arguments` y el uso de `ModalRoute`.
    args = widget.arguments ??
        ModalRoute.of(context)?.settings.arguments as ServiceOptionsArguments?;

    if (args != null) {
      // Estructura exacta preservada.
      serviceData = {
        'serviceId': args!.serviceId,
        'serviceName': args!.serviceName,
        'serviceCategory': args!.serviceCategory,
        'basePrice': args!.basePrice,
      };
      debugPrint(
          'ServiceOptions inicializado con: ${serviceData['serviceName']}');
    } else {
      // Fallback seguro para pruebas y modo offline.
      serviceData = _getDefaultServiceData();
      debugPrint('ServiceOptions usando datos por defecto');
    }

    if (isLoading) _loadServiceOptions();
  }

  /// Retorna datos por defecto cuando no hay argumentos.
  Map<String, dynamic> _getDefaultServiceData() {
    // Mantener mismos campos esperados por resto del flujo.
    return const {
      'serviceId': 'default',
      'serviceName': 'Servicio de Limpieza',
      'serviceCategory': 'limpieza',
      'basePrice': 15.0,
    };
  }

  /// Configura los controladores y curvas de animación de entrada.
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  // ======================== CARGA DE DATOS ========================

  /// Carga las opciones del servicio desde Firestore; si no existen o hay error,
  /// usa el catálogo local (`ServiceCatalog`) para garantizar continuidad en Tena.
  ///
  /// Consideraciones offline-first (contexto amazónico):
  /// - Conectividad intermitente: `try/catch` + fallback local.
  /// - UX: siempre muestra opciones (aunque sean por defecto), evitando pantallas vacías.
  Future<void> _loadServiceOptions() async {
    try {
      debugPrint('Cargando opciones para: ${serviceData['serviceId']}');

      // Llamado controlado al servicio (no cambia interfaces ni rutas).
      final serviceDoc =
          await DatabaseService().getServiceById(serviceData['serviceId']);

      if (serviceDoc != null) {
        final data = serviceDoc;
        final options = data['options'] as List<dynamic>? ?? [];

        // Si el proveedor definió opciones en Firestore, se respetan.
        // Caso contrario, usamos el catálogo local (mejor UX).
        availableOptions = options.isNotEmpty
            ? _mapFirestoreOptions(options)
            : ServiceCatalog.getServicesForCategory(
                serviceData['serviceCategory']);
      } else {
        // Documento no existe: usar catálogo local por categoría.
        availableOptions = ServiceCatalog.getServicesForCategory(
            serviceData['serviceCategory']);
      }

      _initializeOptionsState();
      setState(() => isLoading = false);
      _animationController.forward();

      debugPrint('${availableOptions.length} opciones cargadas');
    } catch (e) {
      // Modo resiliente: ante errores de red/permiso, continuar con catálogo local.
      debugPrint('Error loading service options: $e');
      _handleLoadError();
    }
  }

  /// Transforma la lista de Firestore a un `List<Map<String, dynamic>>`
  /// con claves seguras para la UI (evita nulls).
  ///
  /// Parámetros:
  /// - [options]: lista cruda de opciones desde Firestore.
  ///
  /// Retorna: lista normalizada de opciones.
  List<Map<String, dynamic>> _mapFirestoreOptions(List<dynamic> options) {
    return options
        .map((option) => {
              'id': option['id'] ?? '',
              'name': option['name'] ?? '',
              'description': option['description'] ?? '',
              'price': (option['price'] ?? 0.0).toDouble(),
              'required': option['required'] ?? false,
              'category': option['category'] ?? 'general',
            })
        .toList();
  }

  /// Maneja errores de carga: usa catálogo local, inicializa estado y
  /// muestra animación. No rompe el flujo del usuario.
  void _handleLoadError() {
    availableOptions =
        ServiceCatalog.getServicesForCategory(serviceData['serviceCategory']);
    _initializeOptionsState();
    setState(() => isLoading = false);
    _animationController.forward();
  }

  /// Inicializa los mapas `selectedOptions` y `optionPrices` con base en
  /// las opciones disponibles. Las opciones `required` se marcan seleccionadas.
  void _initializeOptionsState() {
    for (final option in availableOptions) {
      // Seleccionar automáticamente si es "obligatoria" (required).
      selectedOptions[option['id']] = option['required'] ?? false;
      optionPrices[option['id']] = option['price'] ?? 0.0;
    }
  }

  // ======================== GETTERS (LÓGICA DE PRECIOS) ========================

  /// Calcula el total dinámico:
  /// base + suma(opciones marcadas) + recargo por trabajo pesado (si aplica).
  double get totalPrice {
    // Precio base garantizado.
    final double base = serviceData['basePrice']?.toDouble() ?? 0.0;

    // Suma de precios de las opciones seleccionadas.
    final double additional = selectedOptions.entries
        .where((entry) => entry.value) // solo seleccionadas
        .fold(0.0, (sum, entry) => sum + (optionPrices[entry.key] ?? 0.0));

    final double subtotal = base + additional;
    return isHeavyWork ? subtotal + heavyWorkSurcharge : subtotal;
  }

  /// Lista de opciones seleccionadas (para detalle y navegación).
  List<Map<String, dynamic>> get selectedOptionsList {
    return availableOptions
        .where((option) => selectedOptions[option['id']] == true)
        .toList();
  }

  /// Indica si el usuario ya eligió al menos una opción.
  bool get hasSelectedServices => selectedOptionsList.isNotEmpty;

  // ======================== MÉTODOS DE UI (BUILD) ========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingBody() : _buildBody(),
      bottomNavigationBar: isLoading ? null : _buildBottomBar(),
    );
  }

  /// AppBar con título dinámico y “Paso 1/4”, preservando colores/estilos.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cardWhite,
      foregroundColor: AppColors.textDark,
      title: Text(
        serviceData['serviceName'] ?? 'Seleccionar Servicios',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
              const SizedBox(width: 4),
              Text(
                'Paso 1/4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Cuerpo mostrado durante la carga inicial.
  Widget _buildLoadingBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget(),
          SizedBox(height: 16),
          Text(
            'Cargando servicios disponibles...',
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  /// Cuerpo principal con animaciones (fade + slide) y secciones.
  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con datos del servicio base.
                  ServiceHeaderWidget(serviceData: serviceData),

                  const SizedBox(height: 24),

                  // Sección de servicios disponibles.
                  _buildServicesSection(),

                  const SizedBox(height: 24),

                  // Alternativa de “trabajo pesado” con recargo fijo (mantener igual).
                  HeavyWorkOptionWidget(
                    isHeavyWork: isHeavyWork,
                    onChanged: (value) => setState(() => isHeavyWork = value),
                    surcharge: heavyWorkSurcharge,
                  ),

                  const SizedBox(height: 24),

                  // Detalle de lo seleccionado solo si hay opciones marcadas.
                  if (hasSelectedServices)
                    SelectedServicesDetailsWidget(
                      selectedOptions: selectedOptionsList,
                      isHeavyWork: isHeavyWork,
                      heavyWorkSurcharge: heavyWorkSurcharge,
                      totalPrice: totalPrice,
                    ),

                  // Espaciado para que no tape el bottom bar.
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye la sección con el título “Servicios disponibles” y el grid.
  Widget _buildServicesSection() {
    if (availableOptions.isEmpty) {
      // UX inclusiva: muestra componente explícito cuando no hay opciones.
      return const NoServicesAvailableWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios disponibles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),

        // Grid de opciones reutilizable (preservado).
        ServicesGridWidget(
          availableOptions: availableOptions,
          selectedOptions: selectedOptions,
          onOptionChanged: (optionId, value) {
            // Mantener comportamiento exacto: togglear selección en `setState`.
            setState(() => selectedOptions[optionId] = value ?? false);
          },
        ),
      ],
    );
  }

  /// Barra inferior con botón “Cancelar” y CTA que avanza al paso 2/4.
  /// No altera rutas ni argumentos existentes.
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancelar mantiene el pop directo (sin cambios de navegación).
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.textLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // CTA: “Elegir Proveedor” (habilitado solo si hay selección).
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: hasSelectedServices ? _onContinuePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelectedServices
                      ? AppColors.primaryColor
                      : AppColors.textLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: hasSelectedServices ? 2 : 0,
                ),
                // Importante: contenido del botón preservado (mismo layout/strings).
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hasSelectedServices
                            ? 'Elegir Proveedor'
                            : 'Selecciona servicios',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (hasSelectedServices) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== NAVEGACIÓN AL SIGUIENTE PASO ========================

  /// Avanza a “Provider Selection” (paso 2/4) con la estructura original
  /// de argumentos. **No** cambia la ruta (`/provider-selection`) ni
  /// el tipo `ProviderSelectionArguments`, preservando el flujo.
  void _onContinuePressed() {
    if (!hasSelectedServices) return;

    // PREPARAR DATOS PARA PROVIDER SELECTION usando BookingModel.
    final booking = BookingModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      clientId: '', // Se llenará después
      clientName: '',
      clientPhone: '',
      providerId: '',
      providerName: '',
      serviceId: args!.serviceId,
      serviceTitle: args!.serviceName,
      totalPrice: totalPrice,
      scheduledDate: DateTime.now(),
      address: '',
      createdAt: DateTime.now(),
      selectedOptions: selectedOptionsList,
      isHeavyWork: isHeavyWork,
      heavyWorkSurcharge: heavyWorkSurcharge,
      serviceData: ServiceModel(
        id: args!.serviceId,
        title: args!.serviceName,
        description: '',
        category: ServiceModel.stringToCategory(args!.serviceCategory),
        basePrice: args!.basePrice,
        hourlyRate: 0.0,
        providerId: '',
        providerName: '',
        createdAt: DateTime.now(),
      ),
    );

    debugPrint(
        'Navegando a Provider Selection con: ${selectedOptionsList.length} servicios, total: \$${totalPrice.toStringAsFixed(2)}');

    // NAVEGAR A PROVIDER SELECTION (PASO 2/4)
    Navigator.pushNamed(
      context,
      '/provider-selection',
      arguments: ProviderSelectionArguments(
        bookingData: booking,
      ),
    );
  }
}
