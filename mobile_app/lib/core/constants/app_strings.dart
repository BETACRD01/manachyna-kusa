// lib/core/constants/app_strings.dart
class AppStrings {
  // Información de la aplicación
  static const String appName = 'Servicios Tena';
  static const String appSlogan = 'Tu hogar, nuestro cuidado';
  static const String appDescription = 'Servicios domiciliarios confiables en Tena, Napo';
  
  // Ubicación
  static const String cityName = 'Tena';
  static const String provinceName = 'Napo';
  static const String countryName = 'Ecuador';
  static const String regionName = 'Amazonía Ecuatoriana';
  
  // Navegación
  static const String navHome = 'Inicio';
  static const String navBookings = 'Reservas';
  static const String navPayments = 'Pagos';
  static const String navChat = 'Chat';
  static const String navProfile = 'Perfil';
  
  // Saludos
  static const String greetingMorning = 'Buenos días';
  static const String greetingAfternoon = 'Buenas tardes';
  static const String greetingEvening = 'Buenas noches';
  
  // Estados de reserva
  static const String statusPending = 'Pendiente';
  static const String statusConfirmed = 'Confirmada';
  static const String statusInProgress = 'En progreso';
  static const String statusCompleted = 'Completada';
  static const String statusCancelled = 'Cancelada';
  static const String statusRejected = 'Rechazada';
  
  // Descripciones de estado
  static const String statusPendingDesc = 'Esperando confirmación del proveedor';
  static const String statusConfirmedDesc = 'El proveedor confirmó tu solicitud';
  static const String statusInProgressDesc = 'El servicio está en progreso';
  static const String statusCompletedDesc = 'El servicio ha sido completado';
  static const String statusCancelledDesc = 'La reserva fue cancelada';
  static const String statusRejectedDesc = 'El proveedor no pudo aceptar la solicitud';
  
  // Categorías de servicios
  static const String categoryCleaningTitle = 'Limpieza';
  static const String categoryCleaningDesc = 'Limpieza general y profunda';
  static const String categoryPlumbingTitle = 'Plomería';
  static const String categoryPlumbingDesc = 'Reparaciones e instalaciones';
  static const String categoryElectricalTitle = 'Electricidad';
  static const String categoryElectricalDesc = 'Instalaciones eléctricas';
  static const String categoryCarpentryTitle = 'Carpintería';
  static const String categoryCarpentryDesc = 'Trabajos en madera';
  static const String categoryGardeningTitle = 'Jardinería';
  static const String categoryGardeningDesc = 'Cuidado de jardines';
  static const String categoryPaintingTitle = 'Pintura';
  static const String categoryPaintingDesc = 'Pintura de interiores y exteriores';
  static const String categoryMaintenanceTitle = 'Mantenimiento';
  static const String categoryMaintenanceDesc = 'Mantenimiento general';
  
  // Modalidades de contratación
  static const String contractHourlyTitle = 'Por Hora (Flexible)';
  static const String contractHourlyDesc = 'Ideal para tareas específicas o emergencias';
  static const String contractHalfDayTitle = 'Media Jornada';
  static const String contractHalfDayDesc = 'Perfecto para hogares pequeños y locales';
  static const String contractFullDayTitle = 'Jornada Completa';
  static const String contractFullDayDesc = 'Limpieza general + servicios adicionales';
  
  // Niveles de urgencia
  static const String urgencyNormal = 'Normal (24-48h)';
  static const String urgencyUrgent = 'Urgente (12-24h)';
  static const String urgencyEmergency = 'Emergencia (mismo día)';
  
  // Métodos de pago
  static const String paymentCashTitle = 'Efectivo al finalizar';
  static const String paymentCashDesc = 'Pago tradicional al completar el servicio';
  static const String paymentTransferTitle = 'Transferencia bancaria';
  static const String paymentTransferDesc = 'Banco del Pichincha, Banco del Pacífico, etc.';
  static const String paymentCardTitle = 'Pago con tarjeta';
  static const String paymentCardDesc = 'Próximamente disponible';
  
  // Sectores de Tena
  static const List<String> tenaSectors = [
    'Centro de Tena',
    'El Ceibo',
    'Eloy Alfaro',
    'San Antonio',
    'Los Laureles',
    'Cdla. Municipal',
    'Cdla. Los Sauces',
    'Barrio Obrero',
    'Santa Rosa',
    'Cdla. Amazonas',
    'Vía a Archidona',
    'Vía a Baños',
    'Vía al Puyo',
    'Comunidad Rural',
  ];
  
  // Zonas de Tena con recargos
  static const String zoneUrban = 'Zona urbana';
  static const String zonePeriurban = 'Zona periurbana (+15%)';
  static const String zoneRural = 'Zona rural (+25%)';
  static const String zoneFluvial = 'Acceso fluvial (+40%)';
  
  // Mensajes de éxito
  static const String successBookingCreated = '¡Solicitud enviada exitosamente!';
  static const String successBookingCancelled = 'Reserva cancelada correctamente';
  static const String successPaymentReceived = 'Pago recibido exitosamente';
  static const String successRatingSubmitted = 'Calificación enviada correctamente';
  static const String successProfileUpdated = 'Perfil actualizado exitosamente';
  
  // Mensajes de error
  static const String errorGeneral = 'Ha ocurrido un error. Intenta nuevamente.';
  static const String errorNetwork = 'Sin conexión a internet. Verifica tu conexión.';
  static const String errorInvalidEmail = 'Correo electrónico no válido';
  static const String errorInvalidPhone = 'Número de teléfono no válido';
  static const String errorInvalidId = 'Cédula de identidad no válida';
  static const String errorRequiredField = 'Este campo es requerido';
  static const String errorBookingNotFound = 'Reserva no encontrada';
  static const String errorServiceNotAvailable = 'Servicio no disponible';
  static const String errorPaymentFailed = 'Error en el procesamiento del pago';
  
  // Mensajes informativos
  static const String infoNoBookings = 'No tienes reservas activas';
  static const String infoNoServices = 'No hay servicios disponibles';
  static const String infoNoNotifications = 'No tienes notificaciones';
  static const String infoNoMessages = 'No hay mensajes';
  static const String infoWeatherWarning = 'Posible lluvia vespertina (típica de la Amazonía)';
  static const String infoNightService = 'Servicio nocturno - consulta disponibilidad';
  
  // Textos de confirmación
  static const String confirmCancelBooking = '¿Estás seguro de cancelar esta reserva?';
  static const String confirmDeleteAccount = '¿Estás seguro de eliminar tu cuenta?';
  static const String confirmLogout = '¿Quieres cerrar sesión?';
  
  // Textos de acción
  static const String actionCancel = 'Cancelar';
  static const String actionConfirm = 'Confirmar';
  static const String actionAccept = 'Aceptar';
  static const String actionReject = 'Rechazar';
  static const String actionSave = 'Guardar';
  static const String actionEdit = 'Editar';
  static const String actionDelete = 'Eliminar';
  static const String actionView = 'Ver';
  static const String actionClose = 'Cerrar';
  static const String actionNext = 'Siguiente';
  static const String actionPrevious = 'Anterior';
  static const String actionFinish = 'Finalizar';
  static const String actionRetry = 'Reintentar';
  static const String actionContact = 'Contactar';
  static const String actionRate = 'Calificar';
  static const String actionBook = 'Reservar';
  static const String actionSearch = 'Buscar';
  
  // Etiquetas de formularios
  static const String labelName = 'Nombre completo';
  static const String labelEmail = 'Correo electrónico';
  static const String labelPhone = 'Teléfono/WhatsApp';
  static const String labelPassword = 'Contraseña';
  static const String labelAddress = 'Dirección';
  static const String labelDate = 'Fecha';
  static const String labelTime = 'Hora';
  static const String labelNotes = 'Notas adicionales';
  static const String labelDescription = 'Descripción';
  static const String labelRating = 'Calificación';
  static const String labelReview = 'Reseña';
  
  // Placeholder de formularios
  static const String hintName = 'Ingresa tu nombre completo';
  static const String hintEmail = 'ejemplo@correo.com';
  static const String hintPhone = '0987654321';
  static const String hintPassword = 'Mínimo 6 caracteres';
  static const String hintAddress = 'Calle, número, referencias';
  static const String hintNotes = 'Información adicional...';
  static const String hintSearch = 'Buscar servicios...';
  
  // Información de contacto
  static const String supportPhone = '+593 987 654 321';
  static const String supportEmail = 'soporte@tenalimpieza.com';
  static const String supportWhatsApp = '+593 987 654 321';
  static const String supportHours = '7:00 AM - 6:00 PM';
  
  // Términos y condiciones
  static const String termsTitle = 'Términos y Condiciones';
  static const String privacyTitle = 'Política de Privacidad';
  static const String aboutTitle = 'Acerca de la App';
  
  // Condiciones específicas de Tena
  static const List<String> tenaServiceConditions = [
    'El proveedor confirmará en máximo 4 horas',
    'Servicios de 7:00 AM a 6:00 PM (clima favorable)',
    'Cancelación gratuita hasta 2 horas antes',
    'El clima amazónico puede afectar horarios',
    'Pago: 50% al inicio, 50% al finalizar',
    'Precio fijo sin sorpresas adicionales',
    'Garantía de satisfacción o repetición gratuita',
  ];
  
  // Características de la app
  static const List<String> appFeatures = [
    'Precios justos y transparentes',
    'Servicios de calidad garantizada',
    'Proveedores verificados y confiables',
    'Soporte local 24/7',
    'Pagos seguros y flexibles',
    'Calificaciones y reseñas reales',
  ];
  
  // Versión y créditos
  static const String appVersion = '1.0.0';
  static const String developedBy = 'Desarrollado para la comunidad de Tena';
  static const String copyright = '© 2024 Servicios Tena. Todos los derechos reservados.';
  
  // Notificaciones
  static const String notificationBookingConfirmed = 'Tu reserva ha sido confirmada';
  static const String notificationBookingStarted = 'El proveedor ha llegado y comenzó el servicio';
  static const String notificationBookingCompleted = 'Tu servicio ha sido completado';
  static const String notificationBookingCancelled = 'Tu reserva ha sido cancelada';
  static const String notificationPaymentReceived = 'Hemos recibido tu pago';
  static const String notificationPaymentRefunded = 'Tu reembolso ha sido procesado';
  static const String notificationNewMessage = 'Tienes un nuevo mensaje';
  static const String notificationPromotion = 'Nueva promoción disponible';
  
  // Días de la semana
  static const List<String> weekDays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];
  
  // Meses del año
  static const List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  
  // Calificaciones
  static const String ratingExcellent = 'Excelente';
  static const String ratingVeryGood = 'Muy bueno';
  static const String ratingGood = 'Bueno';
  static const String ratingRegular = 'Regular';
  static const String ratingPoor = 'Mejorable';
  
  // Estados de conexión
  static const String connectionOnline = 'Conectado';
  static const String connectionOffline = 'Sin conexión';
  static const String connectionSyncing = 'Sincronizando...';
  
  // Validaciones
  static const String validationMinLength = 'Mínimo {0} caracteres';
  static const String validationMaxLength = 'Máximo {0} caracteres';
  static const String validationRequired = 'Campo requerido';
  static const String validationEmailFormat = 'Formato de email no válido';
  static const String validationPhoneFormat = 'Formato de teléfono no válido';
  static const String validationPasswordMatch = 'Las contraseñas no coinciden';
  
  // Unidades
  static const String unitHour = 'hora';
  static const String unitHours = 'horas';
  static const String unitDay = 'día';
  static const String unitDays = 'días';
  static const String unitMinute = 'minuto';
  static const String unitMinutes = 'minutos';
  static const String unitKilometer = 'km';
  static const String unitMeter = 'm';
}