import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../utils/payment_utils.dart';

class BottomActionSection extends StatelessWidget {
  final bool isProcessingPayment;
  final String paymentMethod;
  final double finalTotal;
  final VoidCallback onCancel;
  final VoidCallback onProcess;

  const BottomActionSection({
    super.key,
    required this.isProcessingPayment,
    required this.paymentMethod,
    required this.finalTotal,
    required this.onCancel,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaymentSummaryCard(
                paymentMethod: paymentMethod,
                finalTotal: finalTotal,
              ),
              const SizedBox(height: 16),
              _ActionButtons(
                isProcessingPayment: isProcessingPayment,
                paymentMethod: paymentMethod,
                onCancel: onCancel,
                onProcess: onProcess,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final String paymentMethod;
  final double finalTotal;

  const _PaymentSummaryCard({
    required this.paymentMethod,
    required this.finalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PaymentUtils.getPaymentMethodColor(paymentMethod).withValues(alpha: 0.1),
            PaymentUtils.getPaymentMethodColor(paymentMethod).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PaymentUtils.getPaymentMethodColor(paymentMethod).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            PaymentUtils.getPaymentIcon(paymentMethod),
            color: PaymentUtils.getPaymentMethodColor(paymentMethod),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PaymentUtils.getPaymentMethodName(paymentMethod),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  PaymentUtils.getPaymentInfoText(paymentMethod),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${finalTotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PaymentUtils.getPaymentMethodColor(paymentMethod),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isProcessingPayment;
  final String paymentMethod;
  final VoidCallback onCancel;
  final VoidCallback onProcess;

  const _ActionButtons({
    required this.isProcessingPayment,
    required this.paymentMethod,
    required this.onCancel,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessingPayment ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: isProcessingPayment ? Colors.grey[300]! : Colors.grey[400]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isProcessingPayment ? AppColors.textLight : AppColors.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isProcessingPayment ? null : onProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: isProcessingPayment
                  ? Colors.grey[400]
                  : PaymentUtils.getActionButtonColor(paymentMethod),
              foregroundColor: AppColors.cardWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: isProcessingPayment ? 0 : 3,
              shadowColor: PaymentUtils.getActionButtonColor(paymentMethod).withValues(alpha: 0.3),
            ),
            child: isProcessingPayment
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.cardWhite,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Procesando...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PaymentUtils.getActionButtonIcon(paymentMethod),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        PaymentUtils.getActionButtonText(paymentMethod),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}