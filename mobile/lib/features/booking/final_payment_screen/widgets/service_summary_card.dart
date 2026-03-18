import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../utils/service_icons.dart';

import '../../../../data/models/service_model.dart';

class ServiceSummaryCard extends StatelessWidget {
  final ServiceModel serviceData;
  final List<Map<String, dynamic>> selectedOptions;

  const ServiceSummaryCard({
    super.key,
    required this.serviceData,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ServiceIcons.getIcon(serviceData.category),
                    color: AppColors.cardWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Servicio',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cardWhite.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        serviceData.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cardWhite,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (selectedOptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SelectedOptionsSection(options: selectedOptions),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectedOptionsSection extends StatelessWidget {
  final List<dynamic> options;

  const _SelectedOptionsSection({required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardWhite.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicios incluidos:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cardWhite.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          ...options.take(3).map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.cardWhite.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option['name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.cardWhite.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (options.length > 3)
            Text(
              '+${options.length - 3} más...',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.cardWhite.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}