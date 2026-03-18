import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PriceBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> finalBookingData;

  const PriceBreakdownCard({
    super.key,
    required this.finalBookingData,
  });

  @override
  Widget build(BuildContext context) {
    final serviceBasePrice = finalBookingData['serviceData']?['basePrice']?.toDouble() ?? 0.0;
    final selectedOptions = finalBookingData['selectedOptions'] as List<dynamic>? ?? [];
    final optionsTotal = selectedOptions.fold(0.0, (total, option) => total + (option['price']?.toDouble() ?? 0.0));
    final isHeavyWork = finalBookingData['isHeavyWork'] ?? false;
    final heavyWorkSurcharge = finalBookingData['heavyWorkSurcharge']?.toDouble() ?? 0.0;
    final processingFee = finalBookingData['processingFee']?.toDouble() ?? 0.0;
    final subtotalServices = finalBookingData['totalPrice']?.toDouble() ?? 0.0;
    final finalTotal = finalBookingData['finalTotal']?.toDouble() ?? 0.0;

    return Container(
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.cardWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumen de Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cardWhite.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Precio base del servicio:',
                    value: '\$${serviceBasePrice.toStringAsFixed(2)}',
                  ),
                  if (selectedOptions.isNotEmpty)
                    _PriceRow(
                      label: 'Opciones adicionales:',
                      value: '+\$${optionsTotal.toStringAsFixed(2)}',
                    ),
                  if (isHeavyWork)
                    _PriceRow(
                      label: 'Recargo trabajo pesado:',
                      value: '+\$${heavyWorkSurcharge.toStringAsFixed(2)}',
                    ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PriceRow(
                    label: 'Subtotal de servicios:',
                    value: '\$${subtotalServices.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  if (processingFee > 0)
                    _PriceRow(
                      label: 'Comisión de procesamiento:',
                      value: '+\$${processingFee.toStringAsFixed(2)}',
                    ),
                  const SizedBox(height: 12),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL A PAGAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cardWhite,
                        ),
                      ),
                      Text(
                        '\$${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cardWhite,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
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

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.cardWhite.withValues(alpha: 0.8),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.cardWhite,
            ),
          ),
        ],
      ),
    );
  }
}