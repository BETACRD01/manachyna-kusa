// lib/features/booking/widgets/heavy_work_option_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HeavyWorkOptionWidget extends StatelessWidget {
  final bool isHeavyWork;
  final ValueChanged<bool> onChanged;
  final double surcharge;

  const HeavyWorkOptionWidget({
    super.key,
    required this.isHeavyWork,
    required this.onChanged,
    required this.surcharge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isHeavyWork,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: AppColors.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trabajo pesado o riesgoso',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.warningColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marca esta opción si el trabajo requiere esfuerzo adicional, herramientas especiales o presenta riesgos de seguridad.',
                  style: TextStyle(
                    color: AppColors.warningColor.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recargo adicional: +\$${surcharge.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warningColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}