import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentUtils {
  static Color getActionButtonColor(String paymentMethod) {
    const colors = {
      'efectivo': AppColors.primaryBlue,
      'tarjeta': AppColors.primaryBlue,
      'transferencia': Colors.purple,
    };
    return colors[paymentMethod] ?? AppColors.primaryBlue;
  }

  static Color getPaymentMethodColor(String paymentMethod) {
    const colors = {
      'efectivo': AppColors.primaryBlue,
      'tarjeta': AppColors.primaryBlue,
      'transferencia': Colors.purple,
    };
    return colors[paymentMethod] ?? AppColors.primaryBlue;
  }

  static IconData getActionButtonIcon(String paymentMethod) {
    const icons = {
      'efectivo': Icons.bookmark_add_outlined,
      'tarjeta': Icons.payment_outlined,
      'transferencia': Icons.account_balance_outlined,
    };
    return icons[paymentMethod] ?? Icons.payment_outlined;
  }

  static String getActionButtonText(String paymentMethod) {
    const texts = {
      'efectivo': 'Reservar Servicio',
      'tarjeta': 'Pagar Ahora',
      'transferencia': 'Confirmar Pago',
    };
    return texts[paymentMethod] ?? 'Confirmar';
  }

  static String getPaymentInfoText(String paymentMethod) {
    const texts = {
      'tarjeta': 'Tu tarjeta será cargada de forma segura',
      'transferencia': 'Recibirás datos para transferencia',
      'efectivo': 'Pagarás al finalizar el servicio',
    };
    return texts[paymentMethod] ?? 'Pagarás al finalizar el servicio';
  }

  static IconData getPaymentIcon(String paymentMethod) {
    const icons = {
      'tarjeta': Icons.credit_card_outlined,
      'transferencia': Icons.account_balance_outlined,
      'kushki': Icons.qr_code_outlined,
      'efectivo': Icons.attach_money_outlined,
    };
    return icons[paymentMethod] ?? Icons.attach_money_outlined;
  }

  static String getPaymentMethodName(String paymentMethod) {
    const names = {
      'tarjeta': 'Tarjeta de Crédito/Débito',
      'transferencia': 'Transferencia Bancaria',
      'kushki': 'Pago Digital',
      'efectivo': 'Efectivo',
    };
    return names[paymentMethod] ?? 'Efectivo';
  }

  static String getPaymentMethodDescription(String paymentMethod) {
    const descriptions = {
      'tarjeta': 'Pago seguro con tarjeta',
      'transferencia': 'Banco del Pichincha, Pacífico, etc.',
      'kushki': 'Pago rápido y seguro',
      'efectivo': 'Pago al finalizar el servicio',
    };
    return descriptions[paymentMethod] ?? 'Pago al finalizar el servicio';
  }
}