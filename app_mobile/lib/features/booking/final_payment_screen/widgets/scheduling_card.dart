import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SchedulingCard extends StatelessWidget {
  final DateTime selectedDateTime;
  final int estimatedHours;
  final bool isProcessingPayment;
  final VoidCallback onDateSelect;
  final VoidCallback onTimeSelect;

  const SchedulingCard({
    super.key,
    required this.selectedDateTime,
    required this.estimatedHours,
    required this.isProcessingPayment,
    required this.onDateSelect,
    required this.onTimeSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.schedule_outlined,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Horario Programado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CompactDateTimeCard(
                    title: 'Fecha',
                    icon: Icons.calendar_today_outlined,
                    value: '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year}',
                    onTap: isProcessingPayment ? null : onDateSelect,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactDateTimeCard(
                    title: 'Hora',
                    icon: Icons.access_time_outlined,
                    value: '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                    onTap: isProcessingPayment ? null : onTimeSelect,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duración estimada: $estimatedHours hora(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDateTimeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  const _CompactDateTimeCard({
    required this.title,
    required this.icon,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.purple[600], size: 18),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}