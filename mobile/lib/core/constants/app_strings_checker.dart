// CONSTANTES ADICIONALES PARA CHECKER BOOK
// Este archivo complementa app_strings.dart existente

class AppStringsChecker {
  // Sectores de Tena (si no existen en app_strings.dart)
  static const List<String> tenaSectors = [
    'Centro',
    'El Dorado', 
    'Los Álamos',
    'Muyuna',
    'Paushiyacu',
    'Pueblo Nuevo',
    'San Antonio',
    'Santa Inés',
    'Tena Norte',
    'Tena Sur',
  ];

  // Condiciones del servicio
  static const List<String> tenaServiceConditions = [
    'Servicio disponible en toda la ciudad de Tena',
    'Confirmación en máximo 4 horas',
    'Cancelación gratuita hasta 2 horas antes',
    'Todos los proveedores están verificados',
    'Garantía de satisfacción del 100%',
  ];

  // Textos específicos del Checker Book
  static const String checkerBookTitle = '¿Qué servicio necesitas?';
  static const String personalInfoTitle = 'Información Personal';
  static const String locationTitle = 'Ubicación del Servicio';
  static const String urgencyTitle = '¿Qué tan urgente es?';
  static const String continueButton = 'Continuar - Seleccionar Servicios';
  static const String selectServicesTitle = 'Selecciona tus Servicios';
  static const String paymentMethodTitle = 'Método de Pago';
  static const String orderSummaryTitle = 'Resumen de tu Pedido';
}
