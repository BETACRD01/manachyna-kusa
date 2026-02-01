// lib/features/profile/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../data/services/auth_service.dart';
import '../../core/themes/profile_theme.dart';

/// Widgets reutilizables para la pantalla de perfil
class ProfileWidgets {
  // ========================================
  // HEADER DEL PERFIL
  // ========================================

  static Widget buildProfileHeaderCard({
    required BuildContext context,
    required dynamic user,
    required Map<String, dynamic>? userData,
    required UserType? userType,
    required String? profileImage,
    required bool isUploadingPhoto,
    required VoidCallback onPhotoTap,
  }) {
    final userName = userData?['name'] ??
        userData?['fullName'] ??
        user?.displayName ??
        'Usuario';
    final userEmail = user?.email ?? 'Sin email';

    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar circular simplificado
        _buildProfileAvatar(
          profileImage: profileImage,
          isUploadingPhoto: isUploadingPhoto,
          onPhotoTap: onPhotoTap,
        ),
        const SizedBox(height: 16),
        // Nombre y Email centrados
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  static Widget _buildProfileAvatar({
    required String? profileImage,
    required bool isUploadingPhoto,
    required VoidCallback onPhotoTap,
  }) {
    return GestureDetector(
      onTap: isUploadingPhoto ? null : onPhotoTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar principal con borde fino
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFFE5E5EA),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: profileImage != null
                  ? (profileImage.startsWith('http')
                      ? NetworkImage(profileImage)
                      : FileImage(File(profileImage)) as ImageProvider)
                  : null,
              child: profileImage == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Color(0xFFC7C7CC),
                    )
                  : null,
            ),
          ),

          // Indicador de carga iOS
          if (isUploadingPhoto)
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),

          // Botón de cámara minimalista
          if (!isUploadingPhoto)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: ProfileTheme.primaryColor,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========================================
  // SOLICITUD DE PROVEEDOR
  // ========================================

  static Widget buildProviderRequestSection({
    required BuildContext context,
    required VoidCallback onRequestTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Verde suave iOS
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onRequestTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  '¿Deseas ofrecer servicios?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D32),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Únete',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF4CAF50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // SECCIÓN DE LOGOUT
  // ========================================

  static Widget buildLogoutSection({
    required BuildContext context,
    required VoidCallback onLogoutTap,
  }) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            onPressed: onLogoutTap,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF3B30),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ========================================
  // COMPONENTES AUXILIARES
  // ========================================

  static Widget buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: ProfileTheme.paddingMedium,
            bottom: ProfileTheme.paddingSmall,
            top: ProfileTheme.paddingMedium,
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93), // iOS System Gray color
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ProfileTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E5EA), // iOS separator color
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  static Widget buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ProfileTheme.paddingMedium,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Icono con fondo estilo iOS
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ProfileTheme.primaryColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Títulos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Chevron iOS
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Padding(
              padding:
                  EdgeInsets.only(left: 54), // Alineado con el inicio del texto
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: Color(0xFFC6C6C8),
              ),
            ),
        ],
      ),
    );
  }

  // ========================================
  // WIDGETS ESPECIALIZADOS
  // ========================================

  /// Widget para mostrar información de estado
  static Widget buildStatusBadge({
    required String label,
    required bool isActive,
    IconData? icon,
  }) {
    final color =
        isActive ? ProfileTheme.successColor : ProfileTheme.warningColor;
    final statusIcon =
        icon ?? (isActive ? Icons.check_circle_rounded : Icons.warning_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileTheme.paddingMedium,
        vertical: ProfileTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ProfileTheme.radiusLarge),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: ProfileTheme.iconSmall,
            color: color,
          ),
          const SizedBox(width: ProfileTheme.paddingXSmall),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar información adicional
  static Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    Color? color,
    VoidCallback? onTap,
  }) {
    final cardColor = color ?? ProfileTheme.infoColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
          border: Border.all(
            color: cardColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: cardColor,
                size: ProfileTheme.iconMedium,
              ),
            ),
            const SizedBox(width: ProfileTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ProfileTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: ProfileTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: ProfileTheme.iconSmall,
                color: ProfileTheme.textHint,
              ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar progreso con barra
  static Widget buildProgressCard({
    required String title,
    required String subtitle,
    required double progress, // 0.0 to 1.0
    Color? color,
  }) {
    final progressColor = color ?? ProfileTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
      decoration: ProfileTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ProfileTheme.textPrimary,
            ),
          ),
          const SizedBox(height: ProfileTheme.paddingXSmall),
          Text(
            subtitle,
            style: ProfileTheme.bodySmall,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: progressColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            minHeight: 6,
          ),
          const SizedBox(height: ProfileTheme.paddingSmall),
          Text(
            '${(progress * 100).toInt()}% completado',
            style: TextStyle(
              fontSize: 12,
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar una lista de características/beneficios
  static Widget buildFeaturesList({
    required List<String> features,
    Color? color,
  }) {
    final featureColor = color ?? ProfileTheme.successColor;

    return Column(
      children: features
          .map((feature) => Padding(
                padding:
                    const EdgeInsets.only(bottom: ProfileTheme.paddingSmall),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: featureColor,
                      size: ProfileTheme.iconSmall,
                    ),
                    const SizedBox(width: ProfileTheme.paddingSmall),
                    Expanded(
                      child: Text(
                        feature,
                        style: ProfileTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
