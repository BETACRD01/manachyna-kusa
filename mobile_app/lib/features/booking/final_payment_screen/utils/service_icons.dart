import 'package:flutter/material.dart';

class ServiceIcons {
  static IconData getIcon(String? category) {
    const icons = {
      'limpieza': Icons.cleaning_services_outlined,
      'plomería': Icons.plumbing_outlined,
      'electricidad': Icons.electrical_services_outlined,
      'carpintería': Icons.carpenter_outlined,
      'jardinería': Icons.grass_outlined,
      'pintura': Icons.format_paint_outlined,
    };
    return icons[category?.toLowerCase()] ?? Icons.home_repair_service_outlined;
  }
}