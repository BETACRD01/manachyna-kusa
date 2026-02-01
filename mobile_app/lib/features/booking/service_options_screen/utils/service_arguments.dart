// lib/features/booking/utils/service_arguments.dart

class ServiceOptionsArguments {
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double basePrice;

  const ServiceOptionsArguments({
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.basePrice,
  });
}

class PaymentSummaryArguments {
  final Map<String, dynamic> serviceData;
  final List<Map<String, dynamic>> selectedOptions;
  final bool isHeavyWork;
  final double heavyWorkSurcharge;

  const PaymentSummaryArguments({
    required this.serviceData,
    required this.selectedOptions,
    required this.isHeavyWork,
    required this.heavyWorkSurcharge,
  });
}