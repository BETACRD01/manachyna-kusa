
// lib/features/booking/widgets/services_grid_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../utils/service_icons.dart';

class ServicesGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> availableOptions;
  final Map<String, bool> selectedOptions;
  final Function(String, bool?) onOptionChanged;

  const ServicesGridWidget({
    super.key,
    required this.availableOptions,
    required this.selectedOptions,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: availableOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isLast = index == availableOptions.length - 1;
          final optionId = option['id'];
          final isSelected = selectedOptions[optionId] ?? false;

          return ServiceCheckboxWidget(
            option: option,
            isSelected: isSelected,
            isLast: isLast,
            onChanged: (value) => onOptionChanged(optionId, value),
            getServiceIconPath: ServiceIcons.getIconPath,
          );
        }).toList(),
      ),
    );
  }
}

class ServiceCheckboxWidget extends StatelessWidget {
  final Map<String, dynamic> option;
  final bool isSelected;
  final bool isLast;
  final ValueChanged<bool?> onChanged;
  final String Function(String?) getServiceIconPath;

  const ServiceCheckboxWidget({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isLast,
    required this.onChanged,
    required this.getServiceIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : AppColors.cardWhite,
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSelected ? AppColors.primaryColor : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Precio: \$${(option['price'] is num ? (option['price'] as num).toDouble() : 0.0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? AppColors.successColor : AppColors.successColor,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Image.asset(
                        getServiceIconPath(option['category']),
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 20,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}