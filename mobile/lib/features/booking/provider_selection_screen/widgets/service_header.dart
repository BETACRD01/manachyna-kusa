import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ServiceHeader extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final int providersCount;
  final IconData Function(String?) getServiceIcon;

  const ServiceHeader({
    super.key,
    required this.bookingData,
    required this.providersCount,
    required this.getServiceIcon,
  });

  @override
  Widget build(BuildContext context) {
    final serviceData = bookingData['serviceData'] ?? {};
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getServiceIcon(serviceData['serviceCategory']),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceData['serviceName'] ?? 'Servicio',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '\$${(bookingData['finalTotal'] ?? 0.0).toStringAsFixed(2)} • ${bookingData['estimatedHours'] ?? 1}h',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.successColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$providersCount',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}