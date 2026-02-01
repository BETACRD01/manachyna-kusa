// lib/themes/profile_theme.dart
import 'package:flutter/material.dart';

/// Constantes de tema para la pantalla de perfil
class ProfileTheme {
  // ========================================
  // COLORES PRINCIPALES - ESQUEMA BLANCO Y AZUL SUAVE
  // ========================================
  
  // Colores primarios
  static const Color primaryColor = Color(0xFF2196F3);        // Azul Material suave
  static const Color primaryLight = Color(0xFF64B5F6);        // Azul claro
  static const Color primaryDark = Color(0xFF1976D2);         // Azul oscuro
  
  // Colores de fondo
  static const Color backgroundColor = Color(0xFFFAFAFA);     // Gris muy claro (casi blanco)
  static const Color surfaceColor = Colors.white;            // Blanco puro
  static const Color cardColor = Colors.white;               // Blanco para cards
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);        // Negro suave
  static const Color textSecondary = Color(0xFF757575);      // Gris medio
  static const Color textHint = Color(0xFFBDBDBD);           // Gris claro
  static const Color textOnPrimary = Colors.white;           // Texto sobre primario
  
  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);       // Verde
  static const Color warningColor = Color(0xFFFF9800);       // Naranja
  static const Color errorColor = Color(0xFFF44336);         // Rojo
  static const Color infoColor = Color(0xFF2196F3);          // Azul info
  
  // Colores de acento suaves
  static const Color accentBlue = Color(0xFF42A5F5);         // Azul acento
  static const Color accentGreen = Color(0xFF66BB6A);        // Verde acento
  static const Color accentOrange = Color(0xFFFFB74D);       // Naranja acento
  static const Color accentPurple = Color(0xFFAB47BC);       // Púrpura acento
  
  // Colores de bordes y divisores
  static const Color borderColor = Color(0xFFE0E0E0);        // Gris claro para bordes
  static const Color dividerColor = Color(0xFFEEEEEE);       // Gris muy claro para divisores
  
  // ========================================
  // GRADIENTES
  // ========================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, surfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ========================================
  // SOMBRAS
  // ========================================
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // ========================================
  // ESTILOS DE TEXTO
  // ========================================
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textHint,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
  );
  
  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  // ========================================
  // DIMENSIONES Y ESPACIADO
  // ========================================
  
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Padding y margin
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Elevación
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Tamaños de iconos
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  
  // ========================================
  // DECORACIONES PREDEFINIDAS
  // ========================================
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: buttonShadow,
  );
  
  static BoxDecoration avatarDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.1),
      ],
    ),
  );
  
  static BoxDecoration badgeDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(25),
    border: Border.all(
      color: color.withValues(alpha: 0.3),
      width: 1,
    ),
  );
  
  // ========================================
  // UTILIDADES DE COLOR
  // ========================================
  
  static Color getUserTypeColor(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'client':
        return accentBlue;
      case 'provider':
        return accentGreen;
      case 'admin':
        return accentOrange;
      default:
        return textSecondary;
    }
  }
  
  static IconData getUserTypeIcon(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'client':
        return Icons.person_outline_rounded;
      case 'provider':
        return Icons.work_outline_rounded;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }
  
  static String getUserTypeDisplayName(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'client':
        return 'Cliente';
      case 'provider':
        return 'Proveedor';
      case 'admin':
        return 'Administrador';
      default:
        return 'Usuario';
    }
  }
}