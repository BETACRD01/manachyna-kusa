import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SortingOptions extends StatelessWidget {
  final String sortBy;
  final Function(String) onSortChanged;

  const SortingOptions({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    const sortOptions = [
      {'value': 'rating', 'label': 'Top valorados', 'icon': Icons.star},
      {'value': 'price', 'label': 'Mejor precio', 'icon': Icons.attach_money},
      {'value': 'distance', 'label': 'Más cerca', 'icon': Icons.location_on},
      {'value': 'reviews', 'label': 'Más reseñas', 'icon': Icons.reviews},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortOptions.length,
        itemBuilder: (context, index) {
          final option = sortOptions[index];
          final isSelected = sortBy == option['value'];
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSortChanged(option['value'] as String);
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(option['label'] as String),
                ],
              ),
              selectedColor: AppColors.primaryColor,
              backgroundColor: AppColors.cardWhite,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryColor : AppColors.mediumGray,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}