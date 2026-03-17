// ============================================================================
// WIDGET: RESUMEN DE PRECIOS
// features/booking/widgets/price_breakdown_widget.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../utils/payment_calculator.dart';

class PriceBreakdownWidget extends StatelessWidget {
  final PaymentCalculator calculator;
  
  const PriceBreakdownWidget({
    super.key,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = calculator.getPriceBreakdown();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha((255 * 0.3).round()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPriceDetails(breakdown),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Text(
          'Resumen de costos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails(Map<String, dynamic> breakdown) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.15).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // PRECIO BASE (siempre se muestra)
          _buildPriceRow(
            'Precio base del servicio:',
            calculator.formatPrice(breakdown['basePrice']),
          ),
          
          // OPCIONES ADICIONALES (solo si hay opciones)
          if (breakdown['hasOptions'])
            _buildPriceRow(
              'Opciones adicionales (${calculator.selectedOptions.length}):',
              '+${calculator.formatPrice(breakdown['optionsTotal'])}',
            ),
          
          // RECARGO TRABAJO PESADO (solo si aplica)
          if (breakdown['hasHeavyWork'])
            _buildPriceRow(
              'Recargo trabajo pesado:',
              '+${calculator.formatPrice(breakdown['heavyWorkFee'])}',
            ),
          
          // SUBTOTAL
          const SizedBox(height: 8),
          _buildDivider(),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Subtotal del servicio:',
            calculator.formatPrice(breakdown['subtotal']),
            isBold: true,
          ),
          
          // COMISIÓN DE PROCESAMIENTO (solo si hay comisión)
          if (breakdown['hasProcessingFee']) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Comisión de procesamiento (${breakdown['processingFeePercentage']}):',
              '+${calculator.formatPrice(breakdown['processingFee'])}',
              color: Colors.orange[100],
            ),
          ],
          
          // TOTAL FINAL
          const SizedBox(height: 12),
          _buildThickDivider(),
          const SizedBox(height: 12),
          _buildFinalTotalRow(breakdown['finalTotal']),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label, 
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: color != null 
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : EdgeInsets.zero,
        decoration: color != null 
          ? BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            )
          : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label, 
                style: TextStyle(
                  fontSize: 14, 
                  color: color != null ? Colors.orange[800] : Colors.white70,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color != null ? Colors.orange[800] : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalTotalRow(double finalTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TOTAL A PAGAR:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          calculator.formatPrice(finalTotal),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.3).round()),
      ),
    );
  }

  Widget _buildThickDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}