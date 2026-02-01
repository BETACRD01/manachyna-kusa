// lib/core/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class Helpers {
  // Formateo de fechas y horas
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDateTimeComplete(DateTime dateTime) {
    return DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'es_EC').format(dateTime);
  }

  static String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return formatDate(dateTime);
    }
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }

  // Formateo de dinero
  static String formatMoney(double amount) {
    return '\${amount.toStringAsFixed(2)}';
  }

  static String formatMoneyCompact(double amount) {
    if (amount >= 1000000) {
      return '\${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatMoney(amount);
    }
  }

  // Saludos según la hora del día
  static String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  // Validaciones
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    // Formato ecuatoriano: 09XXXXXXXX o +593XXXXXXXXX
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return RegExp(r'^(\+593|09)\d{8}$').hasMatch(cleanPhone);
  }

  static bool isValidEcuadorianId(String id) {
    if (id.length != 10) return false;

    final digits = id.split('').map(int.parse).toList();
    final province = int.parse(id.substring(0, 2));

    if (province < 1 || province > 24) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = digits[i];
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == digits[9];
  }

  // Utilidades de texto
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalizeFirst).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Utilidades de color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  // Utilidades de navegación
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red[600],
      duration: const Duration(seconds: 4),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green[600],
      duration: const Duration(seconds: 3),
    );
  }

  // Utilidades de distancia y ubicación para Tena
  static String getDistanceText(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }

  static String getTenaZoneDescription(String zone) {
    switch (zone.toLowerCase()) {
      case 'centro':
        return 'Centro de Tena';
      case 'urbana':
        return 'Zona urbana';
      case 'periurbana':
        return 'Zona periurbana (+15%)';
      case 'rural':
        return 'Zona rural (+25%)';
      case 'fluvial':
        return 'Acceso fluvial (+40%)';
      default:
        return zone;
    }
  }

  // Utilidades para estado de conexión
  static void showConnectionError(BuildContext context) {
    showErrorSnackBar(
      context,
      'Sin conexión a internet. Verifica tu conexión y vuelve a intentar.',
    );
  }

  // Utilidades de rating
  static String getRatingText(double rating) {
    if (rating >= 4.5) return 'Excelente';
    if (rating >= 4.0) return 'Muy bueno';
    if (rating >= 3.5) return 'Bueno';
    if (rating >= 3.0) return 'Regular';
    return 'Mejorable';
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }

  // Utilidades de estado de servicio
  static String getBookingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmada';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      case 'rejected':
        return 'Rechazada';
      default:
        return capitalizeFirst(status);
    }
  }

  static IconData getBookingStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.info;
    }
  }

  // Utilidades de tiempo climático para Tena
  static String getWeatherWarning() {
    final hour = DateTime.now().hour;
    final month = DateTime.now().month;

    // Temporada lluviosa en la Amazonía
    if (month >= 3 && month <= 7) {
      if (hour >= 14 && hour <= 17) {
        return 'Posible lluvia vespertina (típica de la Amazonía)';
      }
    }

    if (hour < 6 || hour > 18) {
      return 'Servicio nocturno - consulta disponibilidad';
    }

    return '';
  }

  // Utilidades de formato de servicios
  static String getServiceDurationText(int hours) {
    if (hours == 1) return '1 hora';
    if (hours < 24) return '$hours horas';

    final days = (hours / 24).floor();
    final remainingHours = hours % 24;

    String result = '$days día${days > 1 ? 's' : ''}';
    if (remainingHours > 0) {
      result += ' y $remainingHours hora${remainingHours > 1 ? 's' : ''}';
    }

    return result;
  }

  static String getUrgencyText(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'normal':
        return 'Normal (24-48h)';
      case 'urgente':
        return 'Urgente (12-24h)';
      case 'emergencia':
        return 'Emergencia (mismo día)';
      default:
        return urgency;
    }
  }

  // Utilidades de conversión
  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Utilidades de debug
  static void debugLog(String message, [String? tag]) {
    final timestamp = DateTime.now().toIso8601String();
    final tagString = tag != null ? '[$tag] ' : '';
    logger.d('$timestamp: $tagString$message');
  }

  // Utilidades de generación de IDs
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Utilidades de limpieza de texto
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String formatPhoneDisplay(String phone) {
    final cleaned = cleanPhoneNumber(phone);
    if (cleaned.startsWith('+593')) {
      return '+593 ${cleaned.substring(4, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    } else if (cleaned.startsWith('09')) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 9)}';
    }
    return phone;
  }
}
