// lib/features/booking/widgets/selected_services_details_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SelectedServicesDetailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> selectedOptions;
  final bool isHeavyWork;
  final double heavyWorkSurcharge;
  final double totalPrice;

  const SelectedServicesDetailsWidget({
    super.key,
    required this.selectedOptions,
    required this.isHeavyWork,
    required this.heavyWorkSurcharge,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.successColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Servicios seleccionados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...selectedOptions.map((option) => SelectedServiceItemWidget(option: option)),
          if (isHeavyWork) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recargo trabajo pesado/riesgoso',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.warningColor,
                  ),
                ),
                Text(
                  '+\$${heavyWorkSurcharge.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warningColor,
                  ),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectedServiceItemWidget extends StatelessWidget {
  final Map<String, dynamic> option;

  const SelectedServiceItemWidget({
    super.key,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '🟢 ${option['name']}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Text(
                '\$${(option['price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${option['description']}',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}