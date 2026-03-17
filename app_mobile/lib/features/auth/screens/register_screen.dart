// features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ===============================
  // VARIABLES DE ESTADO
  // ===============================
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cedulaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isFromBooking = false;
  Map<String, dynamic>? _bookingData;
  bool _isInitialized = false;

  // SOLO CLIENTES - Sin selector de rol
  final UserRole _selectedRole = UserRole.client;

  // ===============================
  // CICLO DE VIDA
  // ===============================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeFromArguments();
      _isInitialized = true;
    }
  }

  void _initializeFromArguments() {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _isFromBooking = args['fromBooking'] ?? false;
          _bookingData = args['bookingData'];
        });
      }
    } catch (e) {
      setState(() {
        _isFromBooking = false;
        _bookingData = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  // ===============================
  // VALIDACIONES (Manteniendo lógica original)
  // ===============================
  bool _isValidCedula(String cedula) {
    if (cedula.length != 10) {
      return false;
    }
    if (!RegExp(r'^\d+$').hasMatch(cedula)) {
      return false;
    }
    try {
      List<int> digits = cedula.split('').map(int.parse).toList();
      int provincia = int.parse(cedula.substring(0, 2));
      if (provincia < 1 || provincia > 24) {
        return false;
      }
      int suma = 0;
      for (int i = 0; i < 9; i++) {
        int digit = digits[i];
        if (i % 2 == 0) {
          digit *= 2;
          if (digit > 9) digit -= 9;
        }
        suma += digit;
      }
      int verificador = 10 - (suma % 10);
      if (verificador == 10) {
        verificador = 0;
      }
      return verificador == digits[9];
    } catch (e) {
      return false;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre completo';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 9 || cleanPhone.length > 10) {
      return 'Número de teléfono inválido';
    }
    return null;
  }

  String? _validateCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de cédula';
    }
    if (!_isValidCedula(value.trim())) {
      return 'Número de cédula inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // ===============================
  // INTERFAZ DE USUARIO (Rediseño iOS Style)
  // ===============================
  @override
  Widget build(BuildContext context) {
    final showBookingHeader = _isInitialized && _isFromBooking;

    // Detectar pantalla pequeña para ajustes responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio (iOS)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: showBookingHeader
            ? Text(
                'Crear cuenta',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: SizedBox(
          height: double.infinity, // Ocupar todo el alto
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: 24, vertical: isSmallScreen ? 10 : 20),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showBookingHeader && _bookingData != null)
                        _buildBookingContextHeader(),
                      _buildHeader(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      _buildRegistrationForm(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      _buildRegisterButton(authProvider),
                      SizedBox(height: 16),
                      _buildErrorMessage(authProvider),
                      _buildLoginLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Header Simplificado ---
  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      children: [
        // Icono simple sin sombras pesadas
        Container(
          width: isSmallScreen ? 70 : 80,
          height: isSmallScreen ? 70 : 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7), // Gris muy claro
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.person_add_rounded,
            color: AppColors.primaryColor,
            size: isSmallScreen ? 35 : 40,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Text(
          'Crear Cuenta',
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _isFromBooking
              ? 'Confirma tu reserva registrándote'
              : 'Únete para solicitar servicios',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- Contexto de Reserva (Estilo "Alert" o "Banner" sutil) ---
  Widget _buildBookingContextHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.successColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark_rounded, color: AppColors.successColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserva pendiente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successColor,
                  ),
                ),
                Text(
                  _bookingData?['serviceTitle'] ?? 'Servicio',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.successColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '\$${_bookingData?['finalTotal']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.successColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- Formulario (Sin Cards pesadas) ---
  Widget _buildRegistrationForm(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Información Personal'),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _nameController,
          label: 'Nombre completo',
          hint: 'Ej: Juan Pérez',
          icon: Icons.person_outline,
          validator: _validateName,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: _cedulaController,
          label: 'Cédula',
          hint: '10 dígitos',
          icon: Icons.badge_outlined,
          validator: _validateCedula,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        SizedBox(height: isSmallScreen ? 20 : 28),
        _buildSectionTitle('Contacto'),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'correo@ejemplo.com',
          icon: Icons.email_outlined,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '0991234567',
          icon: Icons.phone_outlined,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: _addressController,
          label: 'Dirección',
          hint: 'Calle principal y secundaria',
          icon: Icons.location_on_outlined,
          validator: (val) => (val == null || val.isEmpty) ? 'Requerido' : null,
          maxLines: 1, // iOS inputs usually single line unless TextArea
          textCapitalization: TextCapitalization.sentences,
        ),
        SizedBox(height: isSmallScreen ? 20 : 28),
        _buildSectionTitle('Seguridad'),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          obscureText: _obscurePassword,
          onToggleVisibility: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: _validatePassword,
        ),
        const SizedBox(height: 12),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite la contraseña',
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: _validateConfirmPassword,
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- TextField estilo iOS (Gris flat, sin borde visible) ---
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        filled: true,
        fillColor: const Color(0xFFF2F2F7), // iOS System Grey 6
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
        ),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: Colors.grey[600], size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F2F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
        ),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      ),
      validator: validator,
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _acceptTerms
            ? AppColors.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _acceptTerms
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (val) => setState(() => _acceptTerms = val ?? false),
            activeColor: AppColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _acceptTerms = !_acceptTerms),
              child: const Text(
                'Acepto los Términos y Condiciones y la Política de Privacidad.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Botón de Registro ---
  Widget _buildRegisterButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54, // Altura estándar iOS para botones principales
      child: ElevatedButton(
        onPressed: (_acceptTerms && !authProvider.isLoading)
            ? () => _handleRegister(authProvider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorMessage(AuthProvider authProvider) {
    if (authProvider.errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              authProvider.errorMessage!,
              style: const TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton(
          onPressed: () {
            if (_isFromBooking && _bookingData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                  settings: RouteSettings(arguments: {
                    'fromBooking': true,
                    'bookingData': _bookingData,
                    'returnTo': '/provider-selection',
                  }),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              children: [
                const TextSpan(text: '¿Ya tienes cuenta? '),
                TextSpan(
                  text: 'Inicia sesión',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // LÓGICA DE REGISTRO
  // ===============================
  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
      return;
    }

    if (_isFromBooking && _bookingData != null) {
      authProvider.setPendingBooking(_bookingData!);
    }

    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _selectedRole,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: AppColors.successColor,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        authProvider.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: RouteSettings(
              arguments: _isFromBooking && _bookingData != null
                  ? {
                      'fromBooking': true,
                      'bookingData': _bookingData,
                      'returnTo': '/provider-selection',
                    }
                  : null,
            ),
          ),
        );
      }
    }
  }
}
