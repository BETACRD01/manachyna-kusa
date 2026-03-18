import 'package:flutter/material.dart';
import '../../../../data/models/service_model.dart';

class ServiceIcons {
  static IconData getIcon(ServiceCategory? category) {
    const icons = {
      'cleaning': Icons.cleaning_services_outlined,
      'plumbing': Icons.plumbing_outlined,
      'electrical': Icons.electrical_services_outlined,
      'carpentry': Icons.carpenter_outlined,
      'gardening': Icons.grass_outlined,
      'painting': Icons.format_paint_outlined,
    };
    return icons[category?.name.toLowerCase()] ?? Icons.home_repair_service_outlined;
  }
}