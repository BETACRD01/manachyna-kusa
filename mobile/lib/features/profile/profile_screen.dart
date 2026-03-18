import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/base_api_service.dart';
import '../../providers/auth_provider.dart' as my_auth;
import '../../data/services/auth_service.dart' as auth_service;
import '../provider/provider_request_form.dart';
import '../../core/themes/profile_theme.dart';
import 'coming_soon_features.dart';
import 'profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isUploadingPhoto = false;
  String? _localProfileImagePath;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // CORRECCIÓN: Cargar stats de forma segura
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // NUEVO: Método mejorado para cargar estadísticas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS System Background Color
      body: Consumer<my_auth.AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final userData = authProvider.userData;
          final userType = authProvider.userType;

          // CORRECCIÓN: Condición más específica para loading
          if (user == null) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 15),
            );
          }

          // CORRECCIÓN: Solo mostrar loading si authProvider está cargando Y no tenemos usuario
          if (authProvider.isLoading && userData == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(radius: 15),
                  SizedBox(height: 16),
                  Text(
                    'Cargando perfil...',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header personalizado con AppBar
                _buildCustomAppBar(context),

                // Contenido principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
                    child: Column(
                      children: [
                        // Header del perfil
                        ProfileWidgets.buildProfileHeaderCard(
                          context: context,
                          user: user,
                          userData: userData,
                          userType: userType,
                          profileImage:
                              _getProfileImageUrl(authProvider, userData, user),
                          isUploadingPhoto: _isUploadingPhoto,
                          onPhotoTap: () => _showPhotoOptions(context),
                        ),

                        const SizedBox(height: ProfileTheme.paddingLarge),

                        // Solicitud de proveedor (solo para clientes)
                        if (userType == auth_service.UserType.client) ...[
                          ProfileWidgets.buildProviderRequestSection(
                            context: context,
                            onRequestTap: () =>
                                _showProviderRequestDialog(context),
                          ),
                          const SizedBox(height: ProfileTheme.paddingLarge),
                        ],

                        // Sección de cuenta
                        _buildAccountSection(context),

                        const SizedBox(height: ProfileTheme.paddingLarge),

                        // Sección de soporte
                        _buildSupportSection(context),

                        const SizedBox(height: ProfileTheme.paddingLarge),

                        // Sección de logout
                        ProfileWidgets.buildLogoutSection(
                          context: context,
                          onLogoutTap: () => _showLogoutDialog(context),
                        ),

                        const SizedBox(height: ProfileTheme.paddingXLarge),

                        // Footer con versión
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _getProfileImageUrl(my_auth.AuthProvider authProvider,
      Map<String, dynamic>? userData, dynamic user) {
    // 1. Prioridad: Cache local o imagen en proceso de subida
    if (authProvider.cachedProfileImagePath != null) {
      return authProvider.cachedProfileImagePath;
    }
    if (_localProfileImagePath != null) {
      return _localProfileImagePath;
    }

    // 2. Imagen de la tabla 'public.users' o 'public.providers'
    if (userData != null) {
      final img = userData['profileImage'] ??
          userData['photoUrl'] ??
          userData['photo_url'];
      if (img != null) {
        return img;
      }
    }

    // 3. Imagen de los metadatos de Firebase Auth (ej: Google)
    if (user != null && user is User) {
      return user.photoURL;
    }

    return null;
  }

  // NUEVO: Método mejorado para sección de estadísticas

  // ========================================
  // HEADER PERSONALIZADO
  // ========================================

  Widget _buildCustomAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      toolbarHeight: 50,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF2F2F7),
      automaticallyImplyLeading: true,
      actions: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => ComingSoonFeatures.generalSettings(context),
          child: const Icon(
            CupertinoIcons.settings,
            color: Color(0xFF007AFF),
            size: 24,
          ),
        ),
      ],
    );
  }

  // ========================================
  // SECCIONES PRINCIPALES (sin cambios)
  // ========================================

  Widget _buildAccountSection(BuildContext context) {
    return ProfileWidgets.buildSection(
      title: 'Mi Cuenta',
      icon: Icons.account_circle_outlined,
      iconColor: ProfileTheme.accentBlue,
      children: [
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.person_outline_rounded,
          title: 'Información personal',
          subtitle: 'Nombre, teléfono, dirección',
          onTap: () => ComingSoonFeatures.editPersonalInfo(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.location_on_outlined,
          title: 'Mis direcciones',
          subtitle: 'Gestionar direcciones guardadas',
          onTap: () => ComingSoonFeatures.manageAddresses(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.payment_rounded,
          title: 'Métodos de pago',
          subtitle: 'Tarjetas, cuentas bancarias',
          onTap: () => ComingSoonFeatures.managePaymentMethods(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notificaciones',
          subtitle: 'Configurar alertas y avisos',
          onTap: () => ComingSoonFeatures.configureNotifications(context),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return ProfileWidgets.buildSection(
      title: 'Soporte y Ayuda',
      icon: Icons.help_outline_rounded,
      iconColor: ProfileTheme.accentGreen,
      children: [
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.support_agent_rounded,
          title: 'Ayuda y soporte',
          subtitle: 'Centro de ayuda, contacto',
          onTap: () => ComingSoonFeatures.helpAndSupport(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.star_outline_rounded,
          title: 'Calificar la app',
          subtitle: 'Comparte tu experiencia',
          onTap: () => _showRatingDialog(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Política de privacidad',
          subtitle: 'Términos y condiciones',
          onTap: () => ComingSoonFeatures.privacyPolicy(context),
        ),
        ProfileWidgets.buildMenuOption(
          context,
          icon: Icons.info_outline_rounded,
          title: 'Acerca de la app',
          subtitle: 'Versión 1.0.0',
          onTap: () => _showAboutDialog(context),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(ProfileTheme.paddingLarge),
      child: Column(
        children: [
          Text(
            'Mañachyna Kusa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ProfileTheme.primaryColor,
            ),
          ),
          SizedBox(height: ProfileTheme.paddingXSmall),
          Text(
            'Versión 1.0.0',
            style: ProfileTheme.bodySmall,
          ),
          SizedBox(height: ProfileTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: ProfileTheme.errorColor,
                size: ProfileTheme.iconSmall,
              ),
              SizedBox(width: ProfileTheme.paddingXSmall),
              Text(
                'Hecho con amor para Napo',
                style: ProfileTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================
  // FUNCIONALIDAD DE FOTO DE PERFIL
  // ========================================

  void _showPhotoOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Cambiar foto de perfil'),
        message: const Text('Selecciona una opción para tu nueva foto'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.activeBlue),
                SizedBox(width: 10),
                Text('Cámara'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_on_rectangle,
                    color: CupertinoColors.activeBlue),
                SizedBox(width: 10),
                Text('Galería'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  // CORRECCIÓN: Manejo de errores mejorado en pickImage
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _localProfileImagePath = image.path;
          _isUploadingPhoto = true;
        });
        await _uploadProfileImage(image.path);
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      if (mounted) {
        _showErrorSnackBar('Error al seleccionar imagen: $e');
      }
    }
  }

  // CORRECCIÓN: Upload con timeout y mejor manejo de errores
  Future<void> _uploadProfileImage(String imagePath) async {
    try {
      final authProvider =
          Provider.of<my_auth.AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user == null) return;

      final apiService = BaseApiService();
      final response = await apiService.postMultipart(
        'users/upload-profile-image/',
        file: File(imagePath),
      );

      if (!mounted) return;

      if (response['url'] != null) {
        final downloadUrl = response['url'];
        setState(() {
          _isUploadingPhoto = false;
          _localProfileImagePath = downloadUrl;
        });
        _showSuccessSnackBar('Foto actualizada correctamente');

        // Actualizar el provider con la nueva imagen Y cachearla
        await authProvider.updateProfileImage(downloadUrl);
      } else {
        throw Exception('No se recibió la URL de la imagen');
      }
    } catch (e) {
      debugPrint('Error uploading image to Django: $e');
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _localProfileImagePath = null;
        });
        _showErrorSnackBar('Error al subir imagen a Django: $e');
      }
    }
  }

  // ========================================
  // DIÁLOGOS (sin cambios grandes, pero con corrección en rating)
  // ========================================

  void _showRatingDialog(BuildContext context) {
    // CORRECCIÓN: Inicializar rating como int, no double
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ProfileTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
                decoration: BoxDecoration(
                  color: ProfileTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: ProfileTheme.accentOrange,
                  size: ProfileTheme.iconLarge,
                ),
              ),
              const SizedBox(width: ProfileTheme.paddingMedium),
              const Text(
                'Calificar app',
                style: ProfileTheme.headingSmall,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué te parece nuestra app?',
                style: ProfileTheme.bodyLarge,
              ),
              const SizedBox(height: ProfileTheme.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ProfileTheme.paddingXSmall),
                      child: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < rating
                            ? ProfileTheme.accentOrange
                            : ProfileTheme.borderColor,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: ProfileTheme.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: rating > 0
                  ? () {
                      Navigator.pop(context);
                      _showSuccessSnackBar(
                          '¡Gracias por calificar con $rating estrellas!');
                    }
                  : null,
              icon:
                  const Icon(Icons.send_rounded, size: ProfileTheme.iconSmall),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: rating > 0
                    ? ProfileTheme.accentOrange
                    : ProfileTheme.borderColor,
                foregroundColor: ProfileTheme.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ProfileTheme.radiusMedium),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Resto de métodos sin cambios...
  void _showProviderRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
              decoration: BoxDecoration(
                color: ProfileTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: ProfileTheme.accentGreen,
                size: ProfileTheme.iconLarge,
              ),
            ),
            const SizedBox(width: ProfileTheme.paddingMedium),
            const Text(
              'Solicitar ser proveedor',
              style: ProfileTheme.headingSmall,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para ser proveedor necesitas:',
              style: ProfileTheme.bodyLarge,
            ),
            const SizedBox(height: ProfileTheme.paddingMedium),
            ...[
              'Experiencia en servicios',
              'Documentos válidos',
              'Referencias verificables',
              'Residir en Tena o Napo'
            ].map((requirement) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: ProfileTheme.paddingSmall),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: ProfileTheme.accentGreen,
                        size: ProfileTheme.iconSmall,
                      ),
                      const SizedBox(width: ProfileTheme.paddingSmall),
                      Expanded(
                        child: Text(
                          requirement,
                          style: ProfileTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: ProfileTheme.paddingMedium),
            const Text(
              '¿Deseas llenar el formulario?',
              style: ProfileTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: ProfileTheme.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _sendProviderRequest(context);
            },
            icon: const Icon(Icons.arrow_forward_rounded,
                size: ProfileTheme.iconSmall),
            label: const Text('Continuar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileTheme.accentGreen,
              foregroundColor: ProfileTheme.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mañachyna Kusa',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
        decoration: BoxDecoration(
          color: ProfileTheme.primaryColor,
          borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
        ),
        child: const Icon(
          Icons.cleaning_services_rounded,
          size: 28,
          color: ProfileTheme.textOnPrimary,
        ),
      ),
      children: const [
        Text(
          'Aplicación de multiservicios para Tena y Napo.',
          style: ProfileTheme.bodyLarge,
        ),
        SizedBox(height: ProfileTheme.paddingMedium),
        Text(
          'Conectamos proveedores locales con clientes de manera fácil y segura.',
          style: ProfileTheme.bodyMedium,
        ),
        SizedBox(height: ProfileTheme.paddingMedium),
        Text(
          'Desarrollado con ❤️ para la comunidad de Napo.',
          style: ProfileTheme.bodyMedium,
        ),
      ],
    );
  }

  // ========================================
  // ACCIONES
  // ========================================

  void _sendProviderRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProviderRequestForm(),
      ),
    );
  }

  void _logout(BuildContext context) {
    Provider.of<my_auth.AuthProvider>(context, listen: false).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ========================================
  // NOTIFICACIONES
  // ========================================

  void _showSuccessSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ProfileTheme.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: ProfileTheme.textOnPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: ProfileTheme.paddingMedium),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: ProfileTheme.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ProfileTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(ProfileTheme.paddingMedium),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ProfileTheme.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: ProfileTheme.textOnPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: ProfileTheme.paddingMedium),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: ProfileTheme.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ProfileTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(ProfileTheme.paddingMedium),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
