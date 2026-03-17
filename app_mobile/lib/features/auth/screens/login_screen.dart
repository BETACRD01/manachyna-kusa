// features/auth/screens/login_screen.dart
// -----------------------------------------------------------------------------
// PANTALLA DE LOGIN DE MAÑACHYNA KUSA
// - Explicada línea por línea (QUÉ hace y POR QUÉ se hace).
// - Respeta tu estructura de carpetas y el patrón Provider.
// - Considera el contexto amazónico (conectividad intermitente, UX clara).
// - Optimizada para gama media/baja (pocas recomputaciones, layouts simples).
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart'; // Widgets base de Flutter.
import 'package:provider/provider.dart'; // Para acceder a AuthProvider (estado).
import '../../../providers/auth_provider.dart'; // Provider de autenticación (roles, sesión).
import '../../../config/app_routes.dart'; // Rutas nombradas centralizadas.
import '../../../features/client/client_home_screen.dart'; // Fallback de navegación cliente.
import '../../../features/provider/provider_dashboard.dart'; // Fallback de navegación proveedor.
import '../../../features/admin/admin_dashboard.dart'; // Fallback de navegación admin.
import '../widgets/login_form.dart'; // Tu formulario reutilizable de login (email/pass/btn).
import 'register_screen.dart'; // Pantalla de registro (si no tiene cuenta).
import 'forgot_password_screen.dart'; // Pantalla para recuperar contraseña.
import '../../../core/constants/app_colors.dart'; // Paleta de colores consistente del proyecto.

/// Widget con estado porque:
/// - Lee argumentos de navegación (fromBooking/bookingData) una sola vez.
/// - Reacciona a login exitoso y decide navegación según rol/flujo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado interno de la pantalla
class _LoginScreenState extends State<LoginScreen> {
  // --- Estado local controlado por esta pantalla ---

  bool _isFromBooking = false;
  // ↑ ¿El usuario llegó porque quiso confirmar una reserva? (para continuar flujo)

  Map<String, dynamic>? _bookingData;
  // ↑ Datos de la reserva (servicio, total, etc.) para mostrar y luego continuar.

  bool _isInitialized = false;
  // ↑ Evita volver a leer los argumentos al cambiar dependencias (ciclos de vida).

  @override
  void didChangeDependencies() {
    // Se llama cuando el widget se inserta o cambian InheritedWidgets.
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Solo corremos la lectura de argumentos una vez para no duplicar estados.
      _initializeFromArguments();
      _isInitialized = true;
    }
  }

  /// Lee argumentos pasados por Navigator (RouteSettings.arguments)
  /// QUÉ: extrae 'fromBooking' y 'bookingData'.
  /// POR QUÉ: si el usuario venía seleccionando un servicio, al iniciar sesión
  ///          lo reencaminamos a elegir proveedor/confirmar sin perder contexto.
  void _initializeFromArguments() {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _isFromBooking =
              args['fromBooking'] ?? false; // si no viene, asumimos false
          _bookingData = args['bookingData']; // puede ser null: lo toleramos
        });
      }
    } catch (_) {
      // Si no hay argumentos o vinieron mal serializados, no reventamos la app.
      _isFromBooking = false;
      _bookingData = null;
    }
  }

  /// Decide a dónde navegar después de un login exitoso.
  /// QUÉ: si el cliente viene de una reserva, lo manda al flujo de selección de proveedor;
  ///      si no, lo envía al dashboard según su rol (cliente/proveedor/admin).
  /// POR QUÉ: UX simple y directa, evitando que el usuario "se pierda" tras el login.
  void _handlePostLoginNavigation() {
    // Leemos el AuthProvider una única vez (listen: false) para evitar rebuilds.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ----- Caso 1: Cliente llegó con una reserva en curso -----
    if (_isFromBooking && _bookingData != null && authProvider.isClient) {
      // Guardamos la reserva en el provider con una bandera para continuidad.
      authProvider.setPendingBooking({..._bookingData!, 'fromBooking': true});

      // Programamos la navegación/diálogo para el siguiente frame (árbol estable).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) authProvider.checkAndShowProviderSelection(context);
      });
      return; // Salimos porque ya encaminamos el flujo.
    }

    // ----- Caso 2: Cliente NO vino de la reserva pero hay reserva pendiente en memoria -----
    if (authProvider.hasPendingBooking && authProvider.isClient) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) authProvider.checkAndShowProviderSelection(context);
      });
      return;
    }

    // ----- Caso 3: Flujo normal por roles -----
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Evita navegar si el widget ya no está en árbol.

      try {
        // Usar rutas nombradas reduce acoplamiento y centraliza navegación.
        if (authProvider.isProvider) {
          Navigator.pushReplacementNamed(context, AppRoutes.providerDashboard);
        } else if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
        }
      } catch (_) {
        // Fallback por si la ruta nombrada no existe o falla el registro de rutas.
        Widget destination = const ClientHomeScreen();
        if (authProvider.isProvider) destination = const ProviderDashboard();
        if (authProvider.isAdmin) destination = const AdminDashboard();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Medidas de la pantalla para adaptar la UI a equipos pequeños.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen =
        screenHeight < 700; // Heurística simple de dispositivo pequeño.
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; // Altura del teclado.

    return Scaffold(
      backgroundColor:
          AppColors.lightBackground, // Fondo neutro legible a plena luz.
      resizeToAvoidBottomInset: true, // Evita que el teclado tape inputs.

      // Botón flotante estilo iOS limpio
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.systemStatus);
        },
        elevation: 0, // Sin sombra (Flat)
        backgroundColor: const Color(0xFFF2F2F7), // Gris claro
        foregroundColor: const Color(0xFF007AFF), // Icono Azul
        tooltip: 'Verificar Sistema',
        mini: true,
        shape: const CircleBorder(), // Círculo perfecto
        child: const Icon(Icons.wifi_find_rounded), // Icono redondeado
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        // SafeArea para no chocar con notches o barras de estado.
        child: LayoutBuilder(
          // LayoutBuilder nos da constraints para ajustar alturas mínimas.
          builder: (_, constraints) {
            return SingleChildScrollView(
              // Si el teclado está abierto (keyboardHeight > 0), permitimos scroll.
              // De lo contrario, lo bloqueamos completamente para evitar rebotes o movimientos innecesarios.
              physics: keyboardHeight > 0
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Header con identidad visual y mensajes claros ---
                      _buildResponsiveHeader(isSmallScreen, screenWidth),

                      // --- Cuerpo principal (form, links, ayuda) ---
                      Expanded(
                        child: _buildMainContent(isSmallScreen, keyboardHeight),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Header superior con gradiente (azules y verdes = río/bosque amazónico)
  /// QUÉ: Logo, nombre de la app y subtítulo contextual (si viene de reserva).
  /// POR QUÉ: Refuerza confianza e identidad; mensaje directo reduce confusión.
  Widget _buildResponsiveHeader(bool isSmallScreen, double screenWidth) {
    final logoSize = isSmallScreen
        ? 70.0
        : 100.0; // Logo aumentado según solicitud del usuario.

    return Container(
      width: double.infinity,
      color: Colors.white, // Fondo blanco puro
      padding: EdgeInsets.symmetric(
          horizontal: 24, vertical: isSmallScreen ? 4 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centrado estilo iOS
        children: [
          SizedBox(
              height:
                  isSmallScreen ? 8 : 20), // Espacio seguro superior reducido

          // --- Logo Simple (Icono de App) ---
          SizedBox(
            width: logoSize,
            height: logoSize,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit
                  .contain, // Cambiado a contain para asegurar que se vea completo y limpio
            ),
          ),

          const SizedBox(height: 8),

          // --- Título del Sistema (Negro, Bold) ---
          Text(
            'Mañachyna Kusa',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 34,
              fontWeight: FontWeight.w700,
              color: Colors.black, // Texto negro solido
              letterSpacing: -0.5,
              fontFamily:
                  '.SF Pro Display', // Intento de usar fuente nativa si existe, sino default
            ),
          ),

          const SizedBox(height: 4),

          // --- Subtítulo (Gris secundario) ---
          Text(
            _isFromBooking
                ? 'Inicia sesión para confirmar tu reserva'
                : 'Bienvenido',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 17,
              color: Colors.grey[500], // Gris iOS standard
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Cuerpo principal: tarjeta de reserva (si aplica), formulario y accesos.
  /// QUÉ: Muestra un resumen compacto de la reserva, LoginForm y acciones.
  /// POR QUÉ: Mantiene el contexto (confirma al usuario lo que está por hacer).
  /// Cuerpo principal: formulario y accesos.
  /// QUÉ: Contenedor simple y limpio sobre fondo blanco.
  /// POR QUÉ: Diseño iOS prioriza el contenido y el espacio en blanco.
  Widget _buildMainContent(bool isSmallScreen, double keyboardHeight) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 32,
          vertical: 0,
        ),
        child: Column(
          children: [
            // --- Si vino desde reserva, mostramos tarjeta compacta ---
            if (_isFromBooking && _bookingData != null)
              _buildCompactBookingCard(isSmallScreen),

            // --- Formulario de login ---
            // En iOS style, evitamos "Cards" pesadas con sombras profundas.
            // Usamos el fondo limpio.
            LoginForm(
              onLoginSuccess: _handlePostLoginNavigation,
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // --- Link de "olvidaste tu contraseña" ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navegación directa a la pantalla de recuperación.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // --- Separador visual "o" para claridad de opciones ---
            _buildDivider(isSmallScreen),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // --- Botón de registro: conserva el contexto de booking ---
            _buildRegisterButton(isSmallScreen),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // --- Botón de ayuda: muestra contactos y horario ---
            _buildHelpButton(isSmallScreen),

            // --- Espacio extra si el teclado está visible (no tapar botones) ---
            if (keyboardHeight > 0) SizedBox(height: keyboardHeight * 0.1),

            // --- Espacio final mínimo para que el FAB no tape contenido ---
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Tarjeta compacta con resumen de la reserva pendiente.
  /// QUÉ: Muestra título del servicio y total a pagar.
  /// POR QUÉ: Reduce ansiedad/olvido; confirma al usuario su intención previa.
  Widget _buildCompactBookingCard(bool isSmallScreen) {
    // Obtenemos valores defensivos por si faltan en bookingData.
    final String serviceTitle =
        (_bookingData?['serviceTitle'] as String?) ?? 'Servicio seleccionado';
    final double? finalTotal =
        (_bookingData?['finalTotal'] as num?)?.toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.forestGreen.withAlpha(26),
            AppColors.accentGreen.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGreen.withAlpha(76)),
      ),
      child: Row(
        children: [
          // Ícono con fondo degradado para resaltar la tarjeta
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.forestGreen, AppColors.accentGreen],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bookmark_border,
              color: Colors.white,
              size: isSmallScreen ? 16 : 18,
            ),
          ),

          SizedBox(width: isSmallScreen ? 8 : 12),

          // Texto descriptivo: "Reserva pendiente" + nombre del servicio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserva pendiente',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: AppColors.forestGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  serviceTitle,
                  maxLines: 1,
                  overflow: TextOverflow
                      .ellipsis, // Evita desbordes en nombres largos.
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppColors.forestGreen.withAlpha(204),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Chip con el total formateado; si no hay total, mostramos 0.00.
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentGreenDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '\$${(finalTotal ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Separador "o" con líneas a los lados.
  /// QUÉ: Mejora comprensión de que hay alternativas de flujo (login vs registro).
  Widget _buildDivider(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.primaryBlue.withAlpha(76))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          child: Text(
            'o',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.primaryBlue.withAlpha(76))),
      ],
    );
  }

  /// Botón de "Crear cuenta nueva".
  /// QUÉ: Envía a RegisterScreen y le pasa el contexto de la reserva si aplica.
  /// POR QUÉ: Evita perder la intención del usuario cuando decide registrarse.
  Widget _buildRegisterButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
              settings: RouteSettings(
                arguments: {
                  'fromBooking': _isFromBooking,
                  'bookingData': _bookingData,
                },
              ),
            ),
          );
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: Colors.black, // Color base
            ),
            children: [
              TextSpan(text: '¿No tienes cuenta? '),
              TextSpan(
                text: 'Regístrate',
                style: TextStyle(
                  color: Color(0xFF007AFF), // Azul iOS
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botón de ayuda que abre un diálogo con contacto/horarios.
  /// QUÉ: Provee soporte directo (correo/teléfono) en horarios locales.
  /// POR QUÉ: Usuarios con baja alfabetización digital necesitan un salvavidas claro.
  Widget _buildHelpButton(bool isSmallScreen) {
    return TextButton.icon(
      onPressed: _showHelpDialog,
      icon: Icon(
        Icons.help_outline,
        color: AppColors.primaryBlue.withAlpha(178),
        size: isSmallScreen ? 16 : 18,
      ),
      label: Text(
        '¿Necesitas ayuda?',
        style: TextStyle(
          color: AppColors.primaryBlue.withAlpha(178),
          fontSize: isSmallScreen ? 12 : 14,
        ),
      ),
    );
  }

  /// Diálogo de ayuda con datos de contacto.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Centro de Ayuda'),
          ],
        ),
        content: const Text(
          // Nota: Puedes parametrizar esto con Remote Config si cambia seguido.
          'Para obtener ayuda, contacta con nuestro equipo de soporte:\n\n'
          'soporte@manachynakusa.com\n'
          '📞 +593 99 123 4567\n\n'
          'Horario: Lunes a Viernes, 8:00 AM - 6:00 PM',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
