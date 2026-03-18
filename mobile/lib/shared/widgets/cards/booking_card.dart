// lib/shared/widgets/cards/booking_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

import 'package:logger/logger.dart';

final Logger logger = Logger();

class BookingCard extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;
  final bool isCompact;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.bookingId,
    required this.bookingData,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showBookingDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildServiceInfo(),
              if (!isCompact) ...[
                const SizedBox(height: 12),
                _buildLocationInfo(),
                const SizedBox(height: 12),
                _buildActions(),
              ] else ...[
                const SizedBox(height: 8),
                _buildCompactActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final status = bookingData['status'] ?? 'pending';
    // CAMBIO: Usar scheduledDateTime en lugar de scheduledDate
    final scheduledDate =
        DateTime.tryParse(bookingData['scheduledDateTime']?.toString() ?? '') ??
            DateTime.tryParse(bookingData['scheduledDate']?.toString() ?? '');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.getBookingStatusColor(status).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Helpers.getBookingStatusIcon(status),
            color: AppColors.getBookingStatusColor(status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // CAMBIO: Usar serviceTitle como campo principal
                bookingData['serviceTitle'] ??
                    bookingData['serviceName'] ??
                    'Servicio',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    scheduledDate != null
                        ? Helpers.formatDateTime(scheduledDate)
                        : 'Fecha pendiente',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.getBookingStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            Helpers.getBookingStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    // CAMBIO: Manejar diferentes estructuras de precio
    final totalPrice = _getTotalPrice();
    final estimatedHours = bookingData['estimatedHours'] ?? 1;
    final contractMode = bookingData['contractModeLabel'] ?? 'Por Hora';
    // CAMBIO: Usar providerName del nuevo flujo
    final providerName =
        bookingData['providerName'] ?? bookingData['provider'] ?? 'Proveedor';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.person_outline,
                  'Proveedor',
                  providerName,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time,
                  'Modalidad',
                  contractMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.schedule,
                  'Duración',
                  Helpers.getServiceDurationText(estimatedHours),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.attach_money,
                  'Total',
                  Helpers.formatMoney(totalPrice),
                ),
              ),
            ],
          ),

          // NUEVO: Mostrar si es una solicitud simple
          if (_isSimpleBooking()) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Solicitud directa al proveedor',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    // CAMBIO: Manejar la dirección del nuevo flujo
    final address = bookingData['address'] ?? '';
    final sector = bookingData['sector'] ?? _extractSectorFromAddress(address);
    final urgencyLevel = bookingData['urgencyLevel'] ?? 'normal';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.isNotEmpty
                      ? address
                      : sector.isNotEmpty
                          ? sector
                          : 'Tena, Napo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (urgencyLevel != 'normal') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  size: 16,
                  color: AppColors.getPriorityColor(urgencyLevel),
                ),
                const SizedBox(width: 8),
                Text(
                  Helpers.getUrgencyText(urgencyLevel),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getPriorityColor(urgencyLevel),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // NUEVO: Mostrar notas si existen
          if (bookingData['notes'] != null &&
              bookingData['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 14, color: Colors.amber[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bookingData['notes'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    final status = bookingData['status'] ?? 'pending';

    return Row(
      children: [
        if (_canCancel(status)) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _cancelBooking(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handlePrimaryAction(status),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryActionColor(status),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_getPrimaryActionText(status)),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactActions() {
    final status = bookingData['status'] ?? 'pending';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _showBookingDetails(null),
          icon: const Icon(Icons.visibility_outlined, size: 16),
          label: const Text('Ver detalles'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        if (status == 'completed') ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _showRatingDialog(),
            icon: const Icon(Icons.star_outline, size: 16),
            label: const Text('Calificar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber[700],
            ),
          ),
        ],
      ],
    );
  }

  // ====================================
  // MÉTODOS AUXILIARES NUEVOS
  // ====================================

  double _getTotalPrice() {
    // Intentar obtener el precio de diferentes campos
    return (bookingData['finalTotal'] ??
            bookingData['totalPrice'] ??
            bookingData['basePrice'] ??
            0)
        .toDouble();
  }

  bool _isSimpleBooking() {
    // Verificar si es una reserva del nuevo flujo simplificado
    return bookingData['platform'] == null ||
        bookingData['version'] == null ||
        bookingData['clientPhone'] != null;
  }

  String _extractSectorFromAddress(String address) {
    // Extraer sector de la dirección si es posible
    final commonSectors = [
      'Centro de Tena',
      'El Ceibo',
      'Eloy Alfaro',
      'San Antonio',
      'Los Laureles',
      'Cdla. Municipal',
      'Cdla. Los Sauces',
      'Barrio Obrero'
    ];

    for (String sector in commonSectors) {
      if (address.toLowerCase().contains(sector.toLowerCase())) {
        return sector;
      }
    }

    return 'Tena';
  }

  bool _canCancel(String status) {
    return ['pending', 'accepted']
        .contains(status); // CAMBIO: usar 'accepted' en lugar de 'confirmed'
  }

  Color _getPrimaryActionColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.secondary;
      case 'accepted': // CAMBIO
        return AppColors.primary;
      case 'in_progress':
        return AppColors.warning;
      case 'completed':
        return Colors.amber[700]!;
      default:
        return AppColors.primary;
    }
  }

  String _getPrimaryActionText(String status) {
    switch (status) {
      case 'pending':
        return 'Ver detalles';
      case 'accepted': // CAMBIO
        return 'Contactar';
      case 'in_progress':
        return 'Seguimiento';
      case 'completed':
        return 'Calificar';
      default:
        return 'Ver detalles';
    }
  }

  void _handlePrimaryAction(String status) {
    switch (status) {
      case 'accepted': // CAMBIO
        _contactProvider();
        break;
      case 'in_progress':
        _showTrackingInfo();
        break;
      case 'completed':
        _showRatingDialog();
        break;
      default:
        _showBookingDetails(null);
    }
  }

  void _showBookingDetails(BuildContext? context) {
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => BookingDetailsDialog(
          bookingId: bookingId,
          bookingData: bookingData,
        ),
      );
    }
  }

  void _cancelBooking() {
    logger.i('Cancelando reserva: $bookingId');
  }

  void _contactProvider() {
    logger.i('Contactando proveedor para reserva: $bookingId');
  }

  void _showTrackingInfo() {
    logger.i('Mostrando seguimiento para reserva: $bookingId');
  }

  void _showRatingDialog() {
    logger.i('Mostrando calificación para reserva: $bookingId');
  }
}

// ====================================
// DIÁLOGO DE DETALLES ACTUALIZADO
// ====================================

class BookingDetailsDialog extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailsDialog({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(),
                    const SizedBox(height: 20),
                    _buildServiceSection(),
                    const SizedBox(height: 20),
                    _buildLocationSection(),
                    const SizedBox(height: 20),
                    // CAMBIO: Solo mostrar pago si hay información de pago
                    if (_hasPaymentInfo()) ...[
                      _buildPaymentSection(),
                      const SizedBox(height: 20),
                    ],
                    if (bookingData['notes'] != null &&
                        bookingData['notes'].toString().isNotEmpty) ...[
                      _buildNotesSection(),
                      const SizedBox(height: 20),
                    ],
                    // NUEVO: Información del proveedor
                    _buildProviderSection(),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final serviceTitle =
        bookingData['serviceTitle'] ?? bookingData['serviceName'] ?? 'Servicio';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${bookingId.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final status = bookingData['status'] ?? 'pending';
    final scheduledDate =
        DateTime.tryParse(bookingData['scheduledDateTime']?.toString() ?? '') ??
            DateTime.tryParse(bookingData['scheduledDate']?.toString() ?? '');
    final createdAt =
        DateTime.tryParse(bookingData['createdAt']?.toString() ?? '');

    return _buildSection(
      'Estado de la Reserva',
      Icons.info_outline,
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBookingStatusColor(status).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.getBookingStatusColor(status).withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Helpers.getBookingStatusIcon(status),
                  color: AppColors.getBookingStatusColor(status),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Helpers.getBookingStatusText(status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getBookingStatusColor(status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(status),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Programado para',
                  scheduledDate != null
                      ? Helpers.formatDateTimeComplete(scheduledDate)
                      : 'Por confirmar',
                  Icons.schedule,
                ),
              ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Solicitud creada',
                    Helpers.formatTimeAgo(createdAt),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    final contractMode = bookingData['contractModeLabel'] ?? 'Por Hora';
    final estimatedHours = bookingData['estimatedHours'] ?? 1;
    final totalPrice = (bookingData['finalTotal'] ??
            bookingData['totalPrice'] ??
            bookingData['basePrice'] ??
            0)
        .toDouble();
    final providerName = bookingData['providerName'] ?? 'Proveedor';

    return _buildSection(
      'Detalles del Servicio',
      Icons.cleaning_services,
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Proveedor',
                  providerName,
                  Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Modalidad',
                  contractMode,
                  Icons.work,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Duración estimada',
                  Helpers.getServiceDurationText(estimatedHours),
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Precio total',
                  Helpers.formatMoney(totalPrice),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final address = bookingData['address'] ?? '';
    final sector = bookingData['sector'] ?? '';
    final accessInstructions = bookingData['accessInstructions'];

    return _buildSection(
      'Ubicación en Tena',
      Icons.location_on,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sector.isNotEmpty) ...[
            _buildInfoCard(
              'Sector',
              sector,
              Icons.map,
            ),
            const SizedBox(height: 8),
          ],
          _buildInfoCard(
            'Dirección',
            address.isNotEmpty ? address : 'Dirección por confirmar',
            Icons.home,
          ),
          if (accessInstructions != null &&
              accessInstructions.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoCard(
              'Instrucciones de acceso',
              accessInstructions,
              Icons.directions,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentMethod = bookingData['paymentMethodLabel'] ?? 'Efectivo';
    final advancePayment = bookingData['advancePayment']?.toDouble() ?? 0.0;
    final finalPayment = bookingData['finalPayment']?.toDouble() ?? 0.0;

    return _buildSection(
      'Información de Pago',
      Icons.payment,
      Column(
        children: [
          _buildInfoCard(
            'Método de pago',
            paymentMethod,
            Icons.credit_card,
          ),
          if (advancePayment > 0 || finalPayment > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Anticipo (50%)',
                    Helpers.formatMoney(advancePayment),
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Saldo final (50%)',
                    Helpers.formatMoney(finalPayment),
                    Icons.payments,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final notes = bookingData['notes'] ?? '';

    return _buildSection(
      'Notas Adicionales',
      Icons.note,
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          notes,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }

  // NUEVA SECCIÓN: Información del proveedor
  Widget _buildProviderSection() {
    final providerName = bookingData['providerName'] ?? 'Proveedor';
    final providerId = bookingData['providerId'] ?? '';
    final clientPhone = bookingData['clientPhone'] ?? '';

    return _buildSection(
      'Información del Proveedor',
      Icons.business,
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Nombre',
                  providerName,
                  Icons.person,
                ),
              ),
              if (providerId.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'ID Proveedor',
                    providerId.substring(0, 8) + '...',
                    Icons.badge,
                  ),
                ),
              ],
            ],
          ),
          if (clientPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoCard(
              'Tu teléfono de contacto',
              clientPhone,
              Icons.phone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final status = bookingData['status'] ?? 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cerrar'),
            ),
          ),
          const SizedBox(width: 12),
          if (status == 'pending') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactProvider(context),
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Contactar Proveedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else if (status == 'accepted') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactProvider(context),
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Chatear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else if (status == 'completed') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context),
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Calificar Servicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _contactSupport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Contactar Soporte'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ====================================
  // MÉTODOS AUXILIARES
  // ====================================

  bool _hasPaymentInfo() {
    return bookingData['paymentMethodLabel'] != null ||
        bookingData['advancePayment'] != null ||
        bookingData['finalPayment'] != null;
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Esperando confirmación del proveedor';
      case 'accepted':
        return 'El proveedor aceptó tu solicitud';
      case 'in_progress':
        return 'El servicio está en progreso';
      case 'completed':
        return 'El servicio ha sido completado';
      case 'cancelled':
        return 'La reserva fue cancelada';
      case 'rejected':
        return 'El proveedor no pudo aceptar la solicitud';
      default:
        return 'Estado de la reserva';
    }
  }

  void _contactProvider(BuildContext context) {
    Navigator.pop(context);

    final providerName = bookingData['providerName'] ?? 'Proveedor';
    final clientPhone = bookingData['clientPhone'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a $providerName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (clientPhone.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Llamar al proveedor'),
                subtitle: Text('Él te llamará a $clientPhone'),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSuccessSnackBar(
                    context,
                    'El proveedor recibirá tu número para contactarte',
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat en la app'),
              subtitle: const Text('Mensaje directo'),
              onTap: () {
                Navigator.pop(context);
                Helpers.showSuccessSnackBar(
                  context,
                  'Función de chat en desarrollo',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => _RatingDialog(
        bookingId: bookingId,
        serviceTitle: bookingData['serviceTitle'] ?? 'Servicio',
        providerName: bookingData['providerName'] ?? 'Proveedor',
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    Navigator.pop(context);
    Helpers.showSuccessSnackBar(
      context,
      'Soporte será contactado - función en desarrollo',
    );
  }
}

// ====================================
// DIÁLOGO DE CALIFICACIÓN MEJORADO
// ====================================

class _RatingDialog extends StatefulWidget {
  final String bookingId;
  final String serviceTitle;
  final String providerName;

  const _RatingDialog({
    required this.bookingId,
    required this.serviceTitle,
    required this.providerName,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 5;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.star,
              color: Colors.amber[600],
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Calificar Servicio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            widget.serviceTitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Cómo fue tu experiencia con ${widget.providerName}?',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Estrellas de calificación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_outline,
                      color: Colors.amber[600],
                      size: 40,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            Text(
              _getRatingText(_rating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.amber[700],
              ),
            ),

            const SizedBox(height: 20),

            // Campo de comentario
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Comentario (opcional)',
                hintText: 'Cuéntanos sobre tu experiencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[600],
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Enviar Calificación'),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(
          context,
          '¡Gracias por tu calificación!',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Error al enviar calificación: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
