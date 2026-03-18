// ============================================================================
// WIDGET: MÉTODOS DE PAGO SIMPLIFICADO - CORREGIDO
// features/booking/widgets/payment_methods_widget.dart
// ============================================================================

import 'package:flutter/material.dart';

class PaymentMethodsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;
  final bool isCardDataSaved;
  final bool isTransferDataSaved;
  final VoidCallback onShowCardForm;
  final VoidCallback onShowTransferForm;
  
  const PaymentMethodsWidget({
    super.key,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.isCardDataSaved,
    required this.isTransferDataSaved,
    required this.onShowCardForm,
    required this.onShowTransferForm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) => _buildPaymentMethodTile(method))
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.payment, color: Colors.indigo.shade600, size: 24),
        const SizedBox(width: 12),
        const Text(
          'Método de pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];
    final isAvailable = method['isAvailable'] ?? false;
    final methodColor = _getMethodColor(method);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected && isAvailable 
              ? methodColor 
              : isAvailable 
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
          width: isSelected && isAvailable ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected && isAvailable 
            ? methodColor.withAlpha((255 * 0.05).round())
            : isAvailable 
                ? Colors.white 
                : Colors.grey.shade50,
      ),
      child: InkWell(
        onTap: isAvailable ? () => _handleMethodSelection(method) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildSelectionIndicator(isSelected && isAvailable, methodColor, isAvailable),
              const SizedBox(width: 12),
              _buildMethodIcon(method, isAvailable),
              const SizedBox(width: 12),
              Expanded(child: _buildMethodInfo(method, isAvailable)),
              _buildMethodBadges(method, isAvailable),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, Color color, bool isAvailable) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected && isAvailable 
              ? color 
              : isAvailable 
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
          width: 2,
        ),
        color: isSelected && isAvailable ? color : Colors.transparent,
      ),
      child: isSelected && isAvailable
        ? const Icon(Icons.check, size: 16, color: Colors.white)
        : !isAvailable 
            ? Icon(Icons.lock, size: 12, color: Colors.grey.shade400)
            : null,
    );
  }

  Widget _buildMethodIcon(Map<String, dynamic> method, bool isAvailable) {
    final methodColor = _getMethodColor(method);
    final iconColor = isAvailable ? methodColor : Colors.grey.shade400;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isAvailable 
            ? methodColor.withAlpha((255 * 0.1).round())
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildPaymentIcon(method['id'], iconColor, size: 20),
    );
  }

  Widget _buildMethodInfo(Map<String, dynamic> method, bool isAvailable) {
    // Descripción especial para transferencia simplificada
    String description = method['description'] ?? '';
    if (method['id'] == 'transferencia' && isAvailable) {
      description = 'Solo sube tu comprobante de pago';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          method['name'] ?? 'Método de pago',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isAvailable ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodBadges(Map<String, dynamic> method, bool isAvailable) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge de no disponible
        if (!isAvailable) _buildUnavailableBadge(method['id']),
        
        // Badge de comisión (solo si está disponible)
        if ((method['processingFee'] ?? 0) > 0 && isAvailable) 
          _buildFeeBadge(method['processingFee'] ?? 0),
          
        // Para transferencia simplificada, mostrar badge de "fácil"
        if (method['id'] == 'transferencia' && isAvailable) 
          _buildEasyBadge(),
          
        // Badge de datos guardados solo para tarjeta (ya no aplica para transferencia)
        if (method['id'] == 'tarjeta' && isCardDataSaved && isAvailable) 
          _buildSavedBadge('Guardada'),
      ],
    );
  }

  Widget _buildUnavailableBadge(String methodId) {
    if (methodId == 'tarjeta') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 10, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Próximamente',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildFeeBadge(double fee) {
    return Text(
      '+${(fee * 100).toStringAsFixed(0)}%',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.orange.shade600,
      ),
    );
  }

  /// Nuevo badge para indicar que transferencia es fácil
  Widget _buildEasyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, size: 10, color: Colors.green.shade700),
          const SizedBox(width: 2),
          Text(
            'Fácil',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String paymentId, Color color, {double size = 20}) {
    return Icon(_getPaymentIcon(paymentId), color: color, size: size);
  }

  IconData _getPaymentIcon(String paymentId) {
    switch (paymentId) {
      case 'efectivo':
        return Icons.payments;
      case 'tarjeta':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.upload_file; // Cambio de icono para enfatizar la subida de comprobante
      default:
        return Icons.payment;
    }
  }

  /// Método helper para obtener el color del método de pago de forma segura
  Color _getMethodColor(Map<String, dynamic> method) {
    if (method['color'] != null && method['color'] is Color) {
      return method['color'];
    }
    
    // Colores por defecto según el tipo de método de pago
    switch (method['id']) {
      case 'efectivo':
        return Colors.green.shade600;
      case 'tarjeta':
        return Colors.blue.shade600;
      case 'transferencia':
        return Colors.purple.shade600;
      default:
        return Colors.indigo.shade600;
    }
  }

  void _handleMethodSelection(Map<String, dynamic> method) {
    if (!(method['isAvailable'] ?? false)) return;
    
    onPaymentMethodChanged(method['id']);
    
    // Solo mostrar formulario de tarjeta (mensaje de no disponible)
    if (method['id'] == 'tarjeta') {
      onShowCardForm();
    }
    // Para transferencia ya no hay formulario, solo selección
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((255 * 0.05).round()),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}