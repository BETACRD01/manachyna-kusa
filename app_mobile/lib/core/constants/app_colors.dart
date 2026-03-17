// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Colores principales para Tena
  static const Color primary = Color(0xFF4CAF50); // Verde amazonía
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);
  
  static const Color secondary = Color(0xFF2196F3); // Azul río
  static const Color secondaryDark = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF64B5F6);
  
  static const Color accent = Color(0xFFFF9800); // Naranja atardecer
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  
  // Colores de fondo
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Colores específicos para categorías de servicios
  static const Color cleaning = Color(0xFF4CAF50);
  static const Color plumbing = Color(0xFF2196F3);
  static const Color electrical = Color(0xFFFF9800);
  static const Color carpentry = Color(0xFF795548);
  static const Color gardening = Color(0xFF8BC34A);
  static const Color painting = Color(0xFF9C27B0);
  static const Color maintenance = Color(0xFF607D8B);
  
  // Colores de prioridad
  static const Color priorityLow = Color(0xFF81C784);
  static const Color priorityNormal = Color(0xFF64B5F6);
  static const Color priorityHigh = Color(0xFFFFB74D);
  static const Color priorityUrgent = Color(0xFFE57373);
  
  // Colores de estado de reserva
  static const Color bookingPending = Color(0xFFFF9800);
  static const Color bookingConfirmed = Color(0xFF4CAF50);
  static const Color bookingInProgress = Color(0xFF2196F3);
  static const Color bookingCompleted = Color(0xFF4CAF50);
  static const Color bookingCancelled = Color(0xFFF44336);


  //colores de provider_selection
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF263238);
  static const Color textLight = Color(0xFF78909C);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF1976D2);
  static const Color lightGray = Color(0xFFECF0F1);
  static const Color mediumGray = Color(0xFFBDC3C7);
  static const Color warningColor = Color(0xFFE67E22);
  
  //registrer_screen
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color darkGray = Color(0xFF95A5A6);

  //final_payment_screen
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  //provider_booking_screen
  static const Color successGreen = Color(0xFF2E7D32); // Mantener verde para éxito/completado
  static const Color warningOrange = Color(0xFFE67E22); // Naranja para advertencia/pendiente
  static const Color infoPurple = Color(0xFF8E24AA); // Púrpura para en curso
  static const Color dangerRed = Color(0xFFD32F2F); // Rojo para rechazo/problema
  //login_screen
  static const Color secondaryBlue = Color(0xFF3B82F6);    // Azul medio
  static const Color forestGreen = Color(0xFF065F46);      // Verde selva oscuro
  static const Color accentGreen = Color(0xFF10B981);      // Verde selva claro
  static const Color lightBackground = Color(0xFFF0F9FF);  // Azul muy claro
  static const Color errorRed = Color(0xFFDC2626);         // Rojo de error
  static const Color accentGreenDark = Color(0xFF4CAF50);




  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient amazonGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Sombras
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha((0.1 * 255).toInt()),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withAlpha((0.15 * 255).toInt()),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Métodos auxiliares
  static Color getServiceCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'limpieza':
        return cleaning;
      case 'plomería':
        return plumbing;
      case 'electricidad':
        return electrical;
      case 'carpintería':
        return carpentry;
      case 'jardinería':
        return gardening;
      case 'pintura':
        return painting;
      case 'mantenimiento':
        return maintenance;
      default:
        return primary;
    }
  }
  
  static Color getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return bookingPending;
      case 'confirmed':
        return bookingConfirmed;
      case 'in_progress':
        return bookingInProgress;
      case 'completed':
        return bookingCompleted;
      case 'cancelled':
        return bookingCancelled;
      default:
        return textSecondary;
    }
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'normal':
        return priorityNormal;
      case 'high':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      default:
        return priorityNormal;
    }
  }
}