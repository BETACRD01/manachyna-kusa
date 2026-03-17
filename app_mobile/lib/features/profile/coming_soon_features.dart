// lib/features/profile/coming_soon_features.dart
import 'package:flutter/material.dart';
import '../../core/themes/profile_theme.dart';

/// Clase que maneja todas las funciones que estarán disponibles próximamente
class ComingSoonFeatures {
  // ========================================
  // INFORMACIÓN PERSONAL
  // ========================================

  /// Editar información personal del usuario
  static Future<void> editPersonalInfo(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _PersonalInfoDialog(),
    );
  }

  // ========================================
  // GESTIÓN DE DIRECCIONES
  // ========================================

  /// Gestionar direcciones guardadas
  static Future<void> manageAddresses(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _AddressesDialog(),
    );
  }

  // ========================================
  // MÉTODOS DE PAGO
  // ========================================

  /// Gestionar métodos de pago
  static Future<void> managePaymentMethods(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _PaymentMethodsDialog(),
    );
  }

  // ========================================
  // CONFIGURACIÓN DE NOTIFICACIONES
  // ========================================

  /// Configurar notificaciones
  static Future<void> configureNotifications(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _NotificationsDialog(),
    );
  }

  // ========================================
  // AYUDA Y SOPORTE
  // ========================================

  /// Centro de ayuda y soporte
  static Future<void> helpAndSupport(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _HelpSupportDialog(),
    );
  }

  // ========================================
  // POLÍTICA DE PRIVACIDAD
  // ========================================

  /// Mostrar política de privacidad
  static Future<void> privacyPolicy(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _PrivacyPolicyDialog(),
    );
  }

  // ========================================
  // CONFIGURACIÓN GENERAL
  // ========================================

  /// Configuración general de la app
  static Future<void> generalSettings(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const _GeneralSettingsDialog(),
    );
  }

  // ========================================
  // DIÁLOGO GENÉRICO DE "PRÓXIMAMENTE"
  // ========================================

  /// Muestra diálogo genérico de "próximamente"
  static Future<void> showComingSoonDialog(
      BuildContext context, String feature) async {
    await showDialog(
      context: context,
      builder: (context) => _ComingSoonDialog(feature: feature),
    );
  }

  // ========================================
  // FUNCIONES ADICIONALES
  // ========================================

  /// Mostrar diálogo para solicitar función específica
  static Future<void> requestFeature(
      BuildContext context, String featureName) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
        ),
        title: const Text(
          'Solicitar Función',
          style: ProfileTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Te gustaría que priorizáramos "$featureName"?',
              style: ProfileTheme.bodyLarge,
            ),
            const SizedBox(height: ProfileTheme.paddingMedium),
            const Text(
              'Tu solicitud nos ayuda a decidir qué funciones desarrollar primero.',
              style: ProfileTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tal vez después',
              style: TextStyle(color: ProfileTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solicitud enviada para "$featureName"'),
                  backgroundColor: ProfileTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileTheme.primaryColor,
              foregroundColor: ProfileTheme.textOnPrimary,
            ),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar roadmap de funciones
  static Future<void> showRoadmap(BuildContext context) async {
    final roadmapItems = [
      {
        'version': '1.1.0',
        'features': ['Información personal', 'Tema oscuro'],
        'eta': 'Febrero 2025'
      },
      {
        'version': '1.2.0',
        'features': ['Métodos de pago', 'Chat en vivo'],
        'eta': 'Marzo 2025'
      },
      {
        'version': '1.3.0',
        'features': ['Direcciones', 'Notificaciones push'],
        'eta': 'Abril 2025'
      },
      {
        'version': '2.0.0',
        'features': ['Multiidioma', 'Centro de ayuda'],
        'eta': 'Q2 2025'
      },
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
              decoration: BoxDecoration(
                color: ProfileTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.timeline_rounded,
                color: ProfileTheme.primaryColor,
                size: ProfileTheme.iconLarge,
              ),
            ),
            const SizedBox(width: ProfileTheme.paddingMedium),
            const Expanded(
              child: Text(
                'Roadmap de Funciones',
                style: ProfileTheme.headingSmall,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: roadmapItems
                .map((item) => Container(
                      margin: const EdgeInsets.only(
                          bottom: ProfileTheme.paddingMedium),
                      padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: ProfileTheme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(ProfileTheme.radiusMedium),
                        border: Border.all(
                          color: ProfileTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ProfileTheme.paddingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ProfileTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(
                                      ProfileTheme.radiusSmall),
                                ),
                                child: Text(
                                  item['version'] as String,
                                  style: const TextStyle(
                                    color: ProfileTheme.textOnPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['eta'] as String,
                                style: ProfileTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: ProfileTheme.paddingSmall),
                          ...(item['features'] as List<String>)
                              .map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.fiber_manual_record,
                                          size: 6,
                                          color: ProfileTheme.primaryColor,
                                        ),
                                        const SizedBox(
                                            width: ProfileTheme.paddingSmall),
                                        Text(
                                          feature,
                                          style: ProfileTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: ProfileTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// WIDGETS DE DIÁLOGOS ESPECÍFICOS
// ========================================

class _PersonalInfoDialog extends StatelessWidget {
  const _PersonalInfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: ProfileTheme.accentBlue,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Información Personal',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta función te permitirá:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildFeatureList([
            'Editar tu nombre completo',
            'Actualizar número de teléfono',
            'Cambiar dirección principal',
            'Modificar fecha de nacimiento',
            'Actualizar información de contacto',
          ]),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.accentBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: ProfileTheme.accentBlue,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Próximamente en la versión 1.1.0',
                    style: TextStyle(
                      color: ProfileTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.accentBlue),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features
        .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: ProfileTheme.paddingSmall),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: ProfileTheme.successColor,
                    size: ProfileTheme.iconSmall,
                  ),
                  const SizedBox(width: ProfileTheme.paddingSmall),
                  Expanded(
                    child: Text(
                      feature,
                      style: ProfileTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _AddressesDialog extends StatelessWidget {
  const _AddressesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: ProfileTheme.accentGreen,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Mis Direcciones',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestiona tus direcciones guardadas:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildFeatureList([
            'Agregar nuevas direcciones',
            'Editar direcciones existentes',
            'Establecer dirección predeterminada',
            'Eliminar direcciones no utilizadas',
            'Etiquetar direcciones (Casa, Trabajo, etc.)',
          ]),
          const SizedBox(height: ProfileTheme.paddingMedium),
          _buildInfoBox(
            'Tu ubicación se usará solo para mejorar la experiencia de servicios locales.',
            ProfileTheme.accentGreen,
            Icons.location_on_rounded,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.accentGreen),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features
        .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: ProfileTheme.paddingSmall),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: ProfileTheme.accentGreen,
                    size: ProfileTheme.iconSmall,
                  ),
                  const SizedBox(width: ProfileTheme.paddingSmall),
                  Expanded(
                    child: Text(
                      feature,
                      style: ProfileTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildInfoBox(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: ProfileTheme.iconMedium,
          ),
          const SizedBox(width: ProfileTheme.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: ProfileTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodsDialog extends StatelessWidget {
  const _PaymentMethodsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.payment_rounded,
              color: ProfileTheme.accentOrange,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Métodos de Pago',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métodos de pago disponibles:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildPaymentMethods(),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.accentOrange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
              border: Border.all(
                color: ProfileTheme.accentOrange.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: ProfileTheme.accentOrange,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Todos los pagos están protegidos con encriptación de nivel bancario',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.accentOrange),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentMethods() {
    final methods = [
      {
        'icon': Icons.credit_card_rounded,
        'name': 'Tarjetas de crédito/débito',
        'desc': 'Visa, MasterCard, Diners'
      },
      {
        'icon': Icons.account_balance_rounded,
        'name': 'Transferencia bancaria',
        'desc': 'Banco Pichincha, Produbanco'
      },
      {
        'icon': Icons.mobile_friendly_rounded,
        'name': 'Pago móvil',
        'desc': 'Kushki, PayPhone, Datafast'
      },
      {
        'icon': Icons.payments_rounded,
        'name': 'Efectivo contra entrega',
        'desc': 'Pago al recibir el servicio'
      },
    ];

    return methods
        .map((method) => Padding(
              padding:
                  const EdgeInsets.only(bottom: ProfileTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: ProfileTheme.accentOrange.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(ProfileTheme.radiusSmall),
                    ),
                    child: Icon(
                      method['icon'] as IconData,
                      color: ProfileTheme.accentOrange,
                      size: ProfileTheme.iconMedium,
                    ),
                  ),
                  const SizedBox(width: ProfileTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'] as String,
                          style: ProfileTheme.bodyMedium,
                        ),
                        Text(
                          method['desc'] as String,
                          style: ProfileTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: ProfileTheme.accentPurple,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Notificaciones',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurar tus preferencias:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildNotificationTypes(),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.infoColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ProfileTheme.infoColor,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Puedes cambiar estas configuraciones en cualquier momento desde tu dispositivo.',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.accentPurple),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNotificationTypes() {
    final types = [
      {
        'icon': Icons.bookmark_outline_rounded,
        'name': 'Actualizaciones de reservas',
        'desc': 'Confirmaciones y cambios'
      },
      {
        'icon': Icons.local_offer_outlined,
        'name': 'Promociones y ofertas',
        'desc': 'Descuentos especiales'
      },
      {
        'icon': Icons.star_outline_rounded,
        'name': 'Solicitudes de calificación',
        'desc': 'Después de usar un servicio'
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'name': 'Mensajes de proveedores',
        'desc': 'Comunicación directa'
      },
      {
        'icon': Icons.campaign_outlined,
        'name': 'Noticias de la aplicación',
        'desc': 'Nuevas características'
      },
    ];

    return types
        .map((type) => Padding(
              padding:
                  const EdgeInsets.only(bottom: ProfileTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: ProfileTheme.accentPurple.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(ProfileTheme.radiusSmall),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      color: ProfileTheme.accentPurple,
                      size: ProfileTheme.iconMedium,
                    ),
                  ),
                  const SizedBox(width: ProfileTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['name'] as String,
                          style: ProfileTheme.bodyMedium,
                        ),
                        Text(
                          type['desc'] as String,
                          style: ProfileTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) {
                      // Próximamente implementar
                    },
                    activeThumbColor: ProfileTheme.accentPurple,
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _HelpSupportDialog extends StatelessWidget {
  const _HelpSupportDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: ProfileTheme.infoColor,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Ayuda y Soporte',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Canales de soporte disponibles:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildSupportChannels(),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.successColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: ProfileTheme.successColor,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Horario de atención: Lunes a Viernes 8:00 AM - 6:00 PM (GMT-5)',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.infoColor),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSupportChannels() {
    final channels = [
      {
        'icon': Icons.chat_rounded,
        'name': 'Chat en vivo',
        'desc': 'Respuesta inmediata',
        'available': true
      },
      {
        'icon': Icons.email_rounded,
        'name': 'Email',
        'desc': 'soporte@manachynakusa.com',
        'available': true
      },
      {
        'icon': Icons.phone_rounded,
        'name': 'Teléfono',
        'desc': '+593 6 288-7000',
        'available': true
      },
      {
        'icon': Icons.help_center_rounded,
        'name': 'Centro de ayuda',
        'desc': 'FAQ y tutoriales',
        'available': false
      },
    ];

    return channels
        .map((channel) => Padding(
              padding:
                  const EdgeInsets.only(bottom: ProfileTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: ProfileTheme.infoColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(ProfileTheme.radiusSmall),
                    ),
                    child: Icon(
                      channel['icon'] as IconData,
                      color: ProfileTheme.infoColor,
                      size: ProfileTheme.iconMedium,
                    ),
                  ),
                  const SizedBox(width: ProfileTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                channel['name'] as String,
                                style: ProfileTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!(channel['available'] as bool))
                              Container(
                                margin: const EdgeInsets.only(
                                    left: ProfileTheme.paddingSmall),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ProfileTheme.warningColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      ProfileTheme.radiusSmall),
                                ),
                                child: const Text(
                                  'Próximamente',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ProfileTheme.warningColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          channel['desc'] as String,
                          style: ProfileTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _PrivacyPolicyDialog extends StatelessWidget {
  const _PrivacyPolicyDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: ProfileTheme.textSecondary,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Política de Privacidad',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuestra política de privacidad cubre:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          const _PolicySection(
            title: 'Recopilación de datos',
            description: 'Qué información recopilamos y por qué',
          ),
          const _PolicySection(
            title: 'Uso de la información',
            description: 'Cómo utilizamos tus datos personales',
          ),
          const _PolicySection(
            title: 'Compartir información',
            description: 'Con quién compartimos tu información',
          ),
          const _PolicySection(
            title: 'Seguridad',
            description: 'Cómo protegemos tus datos',
          ),
          const _PolicySection(
            title: 'Tus derechos',
            description: 'Control sobre tu información personal',
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.infoColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.update_rounded,
                  color: ProfileTheme.infoColor,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Última actualización: 15 de enero de 2025',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Ver política completa',
            style: TextStyle(color: ProfileTheme.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cerrar',
            style: TextStyle(color: ProfileTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String description;

  const _PolicySection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ProfileTheme.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: ProfileTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ProfileTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: ProfileTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralSettingsDialog extends StatelessWidget {
  const _GeneralSettingsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: ProfileTheme.primaryColor,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Configuración',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuraciones disponibles:',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          ..._buildSettingsOptions(),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.warningColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.construction_rounded,
                  color: ProfileTheme.warningColor,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Estas configuraciones estarán disponibles en futuras actualizaciones.',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Entendido',
            style: TextStyle(color: ProfileTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSettingsOptions() {
    final options = [
      {
        'icon': Icons.dark_mode_outlined,
        'name': 'Tema oscuro',
        'desc': 'Cambiar entre tema claro y oscuro',
        'available': false
      },
      {
        'icon': Icons.language_rounded,
        'name': 'Idioma',
        'desc': 'Español, English, Kichwa',
        'available': false
      },
      {
        'icon': Icons.location_on_outlined,
        'name': 'Servicios de ubicación',
        'desc': 'Gestionar permisos de GPS',
        'available': true
      },
      {
        'icon': Icons.security_rounded,
        'name': 'Seguridad y privacidad',
        'desc': 'Autenticación biométrica, PIN',
        'available': false
      },
      {
        'icon': Icons.storage_rounded,
        'name': 'Almacenamiento y datos',
        'desc': 'Limpiar caché, gestionar descargas',
        'available': false
      },
      {
        'icon': Icons.accessibility_rounded,
        'name': 'Accesibilidad',
        'desc': 'Tamaño de texto, contraste',
        'available': false
      },
    ];

    return options
        .map((option) => Padding(
              padding:
                  const EdgeInsets.only(bottom: ProfileTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: (option['available'] as bool)
                          ? ProfileTheme.primaryColor.withValues(alpha: 0.1)
                          : ProfileTheme.borderColor.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(ProfileTheme.radiusSmall),
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: (option['available'] as bool)
                          ? ProfileTheme.primaryColor
                          : ProfileTheme.textHint,
                      size: ProfileTheme.iconMedium,
                    ),
                  ),
                  const SizedBox(width: ProfileTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                option['name'] as String,
                                style: ProfileTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!(option['available'] as bool))
                              Container(
                                margin: const EdgeInsets.only(
                                    left: ProfileTheme.paddingSmall),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ProfileTheme.warningColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      ProfileTheme.radiusSmall),
                                ),
                                child: const Text(
                                  'Próximamente',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ProfileTheme.warningColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['desc'] as String,
                          style: ProfileTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: (option['available'] as bool)
                        ? ProfileTheme.textHint
                        : ProfileTheme.borderColor,
                    size: ProfileTheme.iconSmall,
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _ComingSoonDialog extends StatelessWidget {
  final String feature;

  const _ComingSoonDialog({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfileTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusXLarge),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingSmall),
            decoration: BoxDecoration(
              color: ProfileTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.schedule_outlined,
              color: ProfileTheme.infoColor,
              size: ProfileTheme.iconLarge,
            ),
          ),
          const SizedBox(width: ProfileTheme.paddingMedium),
          const Expanded(
            child: Text(
              'Próximamente',
              style: ProfileTheme.headingSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La función "$feature" estará disponible en una próxima actualización.',
            style: ProfileTheme.bodyLarge,
          ),
          const SizedBox(height: ProfileTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.paddingMedium),
            decoration: BoxDecoration(
              color: ProfileTheme.infoColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ProfileTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: ProfileTheme.infoColor,
                  size: ProfileTheme.iconMedium,
                ),
                SizedBox(width: ProfileTheme.paddingSmall),
                Expanded(
                  child: Text(
                    'Te notificaremos cuando esté disponible.',
                    style: ProfileTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Entendido',
                  style: TextStyle(color: ProfileTheme.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Te notificaremos sobre "$feature"'),
                      backgroundColor: ProfileTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ProfileTheme.radiusMedium),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_rounded,
                    size: ProfileTheme.iconSmall),
                label: const Text('Notificarme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProfileTheme.infoColor,
                  foregroundColor: ProfileTheme.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ProfileTheme.radiusMedium),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
