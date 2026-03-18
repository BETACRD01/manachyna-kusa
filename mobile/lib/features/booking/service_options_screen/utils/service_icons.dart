// lib/features/booking/utils/service_icons.dart
import 'package:flutter/material.dart';

class ServiceIcons {
  static IconData getIcon(String? category) {
    const icons = {
      'limpieza': Icons.cleaning_services,
      'plomería': Icons.plumbing,
      'electricidad': Icons.electrical_services,
      'carpintería': Icons.carpenter,
      'jardinería': Icons.grass,
      'pintura': Icons.format_paint,
    };
    return icons[category?.toLowerCase()] ?? Icons.home_repair_service;
  }

  static String getIconPath(String? category) {
    const paths = {
      'limpieza': 'assets/icons/casa-limpia.png',
      'plomería': 'assets/icons/plomero.png',
      'electricidad': 'assets/icons/electricista.png',
      'carpintería': 'assets/icons/caja-de-herramientas.png',
      'jardinería': 'assets/icons/agronomia.png',
      'pintura': 'assets/icons/cubo-de-pintura.png',
    };
    return paths[category?.toLowerCase()] ?? 'assets/icons/gastos-generales.png';
  }
}