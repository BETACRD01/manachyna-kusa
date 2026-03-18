import '../../../../data/models/service_model.dart';

class PaymentCalculator {
  final ServiceModel serviceData;
  final List<Map<String, dynamic>> selectedOptions;
  final bool isHeavyWork;
  final double heavyWorkSurcharge;
  final String selectedPaymentMethod;
  final List<Map<String, dynamic>> paymentMethods;

  PaymentCalculator({
    required this.serviceData,
    required this.selectedOptions,
    required this.isHeavyWork,
    required this.heavyWorkSurcharge,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
  });

  // ======================== GETTERS PRINCIPALES ========================
  
  /// Precio base del servicio seleccionado
  double get basePrice => serviceData.basePrice;
  
  /// Suma total de opciones adicionales seleccionadas
  double get optionsTotal {
    double total = 0.0;
    for (var option in selectedOptions) {
      total += (option['price'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
  
  /// Recargo por trabajo pesado (si aplica)
  double get heavyWorkFee => isHeavyWork ? heavyWorkSurcharge : 0.0;
  
  /// SUBTOTAL = Precio base + Opciones + Recargo pesado
  double get subtotal => basePrice + optionsTotal + heavyWorkFee;
  
  /// Comisión de procesamiento según método de pago
  double get processingFee {
    final method = paymentMethods.firstWhere(
      (m) => m['id'] == selectedPaymentMethod,
      orElse: () => paymentMethods.first,
    );
    
    double feePercentage = (method['processingFee'] as num?)?.toDouble() ?? 0.0;
    return subtotal * feePercentage;
  }
  
  /// TOTAL FINAL = Subtotal + Comisión de procesamiento
  double get finalTotal => subtotal + processingFee;
  
  // ======================== MÉTODOS AUXILIARES ========================
  
  /// Obtiene el porcentaje de comisión como string
  String getProcessingFeePercentage() {
    final method = paymentMethods.firstWhere(
      (m) => m['id'] == selectedPaymentMethod,
      orElse: () => paymentMethods.first,
    );
    
    double feePercentage = (method['processingFee'] as num?)?.toDouble() ?? 0.0;
    return '${(feePercentage * 100).toStringAsFixed(0)}%';
  }
  
  /// Formatea precios con símbolo de dólar
  String formatPrice(double? price) {
    if (price == null || price == 0) return '\$0.00';
    return '\$${price.toStringAsFixed(2)}';
  }
  
  /// Genera el desglose completo de precios
  Map<String, dynamic> getPriceBreakdown() {
    return {
      'basePrice': basePrice,
      'optionsTotal': optionsTotal,
      'heavyWorkFee': heavyWorkFee,
      'subtotal': subtotal,
      'processingFee': processingFee,
      'finalTotal': finalTotal,
      'hasOptions': selectedOptions.isNotEmpty,
      'hasHeavyWork': isHeavyWork && heavyWorkFee > 0,
      'hasProcessingFee': processingFee > 0,
      'processingFeePercentage': getProcessingFeePercentage(),
    };
  }
  
  /// Valida si todos los cálculos son correctos
  bool validateCalculations() {
    return basePrice >= 0 && 
           optionsTotal >= 0 && 
           heavyWorkFee >= 0 && 
           processingFee >= 0 && 
           finalTotal > 0;
  }
  
  /// Convierte a Map para envío de datos
  Map<String, dynamic> toBookingData() {
    return {
      'basePrice': basePrice,
      'optionsTotal': optionsTotal,
      'heavyWorkFee': heavyWorkFee,
      'subtotal': subtotal,
      'processingFee': processingFee,
      'finalTotal': finalTotal,
      'paymentMethod': selectedPaymentMethod,
      'isHeavyWork': isHeavyWork,
      'heavyWorkSurcharge': heavyWorkSurcharge,
    };
  }
}