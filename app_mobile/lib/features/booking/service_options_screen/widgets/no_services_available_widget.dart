// lib/features/booking/widgets/no_services_available_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NoServicesAvailableWidget extends StatelessWidget {
  const NoServicesAvailableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.tune, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay servicios disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Contacta con soporte para más opciones',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}