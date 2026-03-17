// lib/features/auth/widgets/login_form.dart (ACTUALIZADO Y COMPATIBLE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

// COLORES TEMÁTICOS
class LoginTheme {
  static const Color primaryBlue = Color(0xFF1E3A8A); // Azul profundo
  static const Color secondaryBlue = Color(0xFF3B82F6); // Azul medio
  static const Color forestGreen = Color(0xFF065F46); // Verde selva oscuro
  static const Color accentGreen = Color(0xFF10B981); // Verde selva claro
  static const Color lightBackground = Color(0xFFF0F9FF); // Azul muy claro
  static const Color errorRed = Color(0xFFDC2626); // Rojo de error
  static const Color successGreen = Color(0xFF059669); // Verde de éxito
}

class LoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginForm({super.key, this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNCIÓN DE LOGIN CON LOADING TEMÁTICO
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Limpiar errores anteriores
    setState(() {
      _errorMessage = null;
    });

    try {
      if (!mounted) return;

      // MOSTRAR LOADING CON COLORES TEMÁTICOS
      context.showLoading(
        message: 'Iniciando sesión...',
        progressMessages: [
          'Iniciando sesión...',
          'Verificando credenciales...',
          'Validando usuario...',
          'Cargando perfil...',
          'Configurando sesión...',
          '¡Bienvenido de vuelta!',
        ],
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Delay mínimo para mostrar animaciones
      await Future.delayed(const Duration(milliseconds: 1800));

      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Ocultar loading
      context.hideLoading();

      if (success) {
        logger.i('🎉 LOGIN EXITOSO - Ejecutando navegación...');

        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        widget.onLoginSuccess?.call();
        logger.i('Navegación ejecutada correctamente');

        if (mounted) {
          _showSuccessMessage('¡Bienvenido de vuelta!');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                authProvider.errorMessage ?? 'Error de autenticación';
          });

          _showErrorMessage(_errorMessage!);
        }
      }
    } catch (e) {
      if (mounted) {
        context.hideLoading();

        setState(() {
          _errorMessage = 'Error inesperado: ${e.toString()}';
        });

        _showErrorMessage(_errorMessage!);
      }

      logger.e('Error en login: $e');
    }
  }

  // FUNCIÓN DE LOGIN CON GOOGLE
  Future<void> _loginWithGoogle() async {
    try {
      if (!mounted) return;

      context.showLoading(
        message: 'Conectando con Google...',
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Pequeño delay para UX
      await Future.delayed(const Duration(milliseconds: 500));

      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;
      context.hideLoading();

      if (success) {
        logger.i('🎉 LOGIN GOOGLE EXITOSO');
        _showSuccessMessage('¡Bienvenido!');

        // Navegación
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) widget.onLoginSuccess?.call();
      } else {
        if (authProvider.errorMessage != null) {
          setState(() => _errorMessage = authProvider.errorMessage);
          _showErrorMessage(_errorMessage!);
        }
      }
    } catch (e) {
      if (mounted) {
        context.hideLoading();
        setState(() => _errorMessage = 'Error: $e');
        _showErrorMessage(_errorMessage!);
      }
    }
  }

  // MENSAJE DE ÉXITO TEMÁTICO
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: LoginTheme.successGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // MENSAJE DE ERROR TEMÁTICO
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: LoginTheme.errorRed,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DETECTAR SI ES PANTALLA PEQUEÑA
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final fieldSpacing = isSmallScreen ? 6.0 : 16.0;
    final buttonHeight = isSmallScreen ? 40.0 : 52.0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Se eliminaron los textos redundantes para ahorrar espacio vertical.

          // CAMPO DE EMAIL TEMÁTICO
          _buildThemedTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'ejemplo@correo.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            isSmallScreen: isSmallScreen,
            contentPadding: isSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Por favor ingresa un email válido';
              }
              return null;
            },
          ),

          SizedBox(height: fieldSpacing),

          // CAMPO DE CONTRASEÑA TEMÁTICO
          _buildThemedTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            icon: Icons.lock_outlined,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            isSmallScreen: isSmallScreen,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: LoginTheme.forestGreen.withAlpha(153),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
            onFieldSubmitted: (value) => _login(),
          ),

          SizedBox(height: isSmallScreen ? 4 : 8),

          // ☑️ CHECKBOX RECORDAR SESIÓN
          Row(
            children: [
              Transform.scale(
                scale: isSmallScreen ? 0.9 : 1.0,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: LoginTheme.accentGreen,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Text(
                'Recordar mi sesión',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: LoginTheme.forestGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // MOSTRAR ERROR SI EXISTE
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LoginTheme.errorRed.withAlpha(26),
                    LoginTheme.errorRed.withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LoginTheme.errorRed.withAlpha(76)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: LoginTheme.errorRed,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: LoginTheme.errorRed,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 10),
          ],

          // BOTÓN DE LOGIN TEMÁTICO
          SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF), // iOS Blue
                foregroundColor: Colors.white,
                elevation: 0, // Flat design
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 17, // Tamaño estándar iOS
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 6 : 16),

          // SEPARADOR
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('O',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: isSmallScreen ? 10 : 12)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
            ],
          ),

          SizedBox(height: isSmallScreen ? 6 : 16),

          // BOTÓN GOOGLE
          SizedBox(
            height: buttonHeight,
            child: OutlinedButton.icon(
              onPressed: _loginWithGoogle,
              icon: Image.asset('assets/images/google_logo.png', height: 24),
              label: const Text(
                'Continuar con Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CAMPO DE TEXTO TEMÁTICO
  Widget _buildThemedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isSmallScreen,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    final fontSize = isSmallScreen ? 13.0 : 15.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final defaultContentPadding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 12 : 16,
      vertical: isSmallScreen ? 12 : 16,
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        fontSize: fontSize,
        color: LoginTheme.primaryBlue,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: LoginTheme.forestGreen, size: iconSize),
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? defaultContentPadding,

        // ESTILO IOS: Fondo gris claro, sin bordes visibles
        filled: true,
        fillColor: const Color(0xFFF2F2F7), // iOS System Grey 6
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFF007AFF), width: 1.5), // Azul iOS al enfocar
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFFFF3B30), width: 1.5), // Rojo iOS
        ),
      ),
    );
  }
}
