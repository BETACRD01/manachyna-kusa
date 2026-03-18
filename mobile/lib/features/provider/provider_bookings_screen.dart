import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:firebase_auth/firebase_auth.dart" hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../data/services/database_service.dart';
import '../../core/constants/app_colors.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _firestoreService = DatabaseService();
  String? currentProviderId;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getCurrentProviderId();
  }

  void _getCurrentProviderId() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentProviderId = authProvider.currentUser?.uid;
    currentUserId = authProvider.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentProviderId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis Trabajos'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.cardWhite,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.cardWhite,
          labelColor: AppColors.cardWhite,
          unselectedLabelColor:
              AppColors.cardWhite.withAlpha((255 * 0.7).round()),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(
              icon: Icon(Icons.hourglass_empty, size: 18),
              text: 'Pendientes',
            ),
            Tab(
              icon: Icon(Icons.check_circle, size: 18),
              text: 'Aceptados',
            ),
            Tab(
              icon: Icon(Icons.work, size: 18),
              text: 'En Curso',
            ),
            Tab(
              icon: Icon(Icons.done_all, size: 18),
              text: 'Completados',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList('pending'),
          _buildBookingsList('accepted'),
          _buildBookingsList('in_progress'),
          _buildBookingsList('completed'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String status) {
    debugPrint('Iniciando búsqueda de reservas:');
    debugPrint('   Provider ID: $currentProviderId');
    debugPrint('   Status: $status');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Stream.fromFuture(_firestoreService.getProviderBookings(currentProviderId!, status)),
      builder: (context, snapshot) {
        debugPrint('Stream estado: ${snapshot.connectionState}');
        debugPrint('Tiene datos: ${snapshot.hasData}');
        debugPrint('Tiene error: ${snapshot.hasError}');

        if (snapshot.hasError) {
          debugPrint('Error completo: ${snapshot.error}');
          debugPrint('StackTrace: ${snapshot.stackTrace}');
        }

        if (snapshot.hasData) {
          debugPrint('Documentos encontrados: ${snapshot.data!.length}');

          for (var i = 0; i < snapshot.data!.length && i < 3; i++) {
            final doc = snapshot.data![i];
            final data = doc;
            debugPrint('Documento $i:');
            debugPrint('   ID: ${doc['id']}');
            debugPrint('   Provider ID: ${data['providerId']}');
            debugPrint('   Status: ${data['status']}');
            debugPrint('   Service: ${data['serviceTitle']}');
            debugPrint('   Client: ${data['clientName']}');
            debugPrint('   ---');
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(status);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(status);
        }

        final bookings = snapshot.data!;
        debugPrint('Construyendo lista con ${bookings.length} reservas');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final data = booking;
            debugPrint('Construyendo card $index: ${data['serviceTitle']}');
            return _buildBookingCard(
                data['id']?.toString() ?? '', data, status);
          },
        );
      },
    );
  }

  Widget _buildLoadingState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: 16),
          Text(
            'Cargando trabajos ${_getStatusDisplayName(status)}...',
            style: const TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Provider: ${currentProviderId?.substring(0, 8)}...',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: AppColors.dangerRed, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar trabajos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Provider ID: ${currentProviderId?.substring(0, 8)}...',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.cardWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getStatusIcon(status),
                size: 64,
                color: _getStatusColor(status),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getEmptyTitle(status),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyMessage(status),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (status == 'pending')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha((255 * 0.05).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          AppColors.primaryBlue.withAlpha((255 * 0.2).round())),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info, color: AppColors.primaryBlue),
                    SizedBox(height: 8),
                    Text(
                      'Asegúrate de que tus servicios estén activos para recibir solicitudes',
                      style: TextStyle(color: AppColors.primaryBlue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
      String bookingId, Map<String, dynamic> data, String status) {
    final DateTime? scheduledDate = _getScheduledDate(data);

    final String clientName =
        data['clientName'] ?? data['contactPerson'] ?? 'Cliente';
    final String serviceTitle = data['serviceTitle'] ?? 'Servicio sin título';
    final double totalPrice = _getTotalPrice(data);
    final String contactPhone = data['clientEmail'] ??
        data['clientPhone'] ??
        data['contactPhone'] ??
        'No disponible';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(status).withAlpha((255 * 0.3).round()),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(serviceTitle, clientName, status),
              const SizedBox(height: 16),
              _buildCardDetails(scheduledDate, totalPrice, contactPhone),
              if (data['paymentMethod'] != null &&
                  data['paymentAccepted'] == true &&
                  data['providerAccepted'] == true) ...[
                const SizedBox(height: 12),
                _buildPaymentInfo(data),
              ],
              if (data['notes'] != null &&
                  data['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNotesSection(data['notes']),
              ],
              if (data['platform'] == null ||
                  data['platform'] != 'advanced') ...[
                const SizedBox(height: 12),
                _buildDirectBookingInfo(),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(bookingId, data, status),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _getScheduledDate(Map<String, dynamic> data) {
    // Try new format first (from AuthProvider)
    if (data['date'] != null) {
      if (data['date'] is String) {
        return DateTime.tryParse(data['date']);
      }
    }
    // Fallback to old format
    if (data['scheduledDateTime'] != null) {
      return DateTime.tryParse(data['scheduledDateTime'].toString());
    }

    // Check scheduledDate
    if (data['scheduledDate'] != null) {
      return DateTime.tryParse(data['scheduledDate'].toString());
    }

    return null;
  }

  double _getTotalPrice(Map<String, dynamic> data) {
    // Try new format first (from AuthProvider)
    if (data['totalPrice'] != null) {
      return (data['totalPrice'] as num).toDouble();
    }
    // Fallback to old formats
    return (data['finalTotal'] ?? data['basePrice'] ?? 0).toDouble();
  }

  Widget _buildPaymentInfo(Map<String, dynamic> data) {
    final String paymentMethod = data['paymentMethod'] ?? '';
    final bool isTransfer = paymentMethod.toLowerCase() == 'transferencia';
    final String? receiptImageUrl = data['receiptImageUrl'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.successGreen.withAlpha((255 * 0.2).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTransfer ? Icons.account_balance : Icons.payments,
                size: 16,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Pago confirmado por ${paymentMethod.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isTransfer && receiptImageUrl != null) ...[
                GestureDetector(
                  onTap: () => _showReceiptImage(receiptImageUrl),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Ver comprobante',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isTransfer && receiptImageUrl != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showReceiptImage(receiptImageUrl),
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.successGreen
                          .withAlpha((255 * 0.3).round())),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    receiptImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.receipt, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReceiptImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Error al cargar la imagen'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.7).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(
      String serviceTitle, String clientName, String status) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.home_repair_service,
            size: 20,
            color: _getStatusColor(status),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(status).withAlpha(76),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                size: 12,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails(
      DateTime? scheduledDate, double totalPrice, String contactPhone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (scheduledDate != null) ...[
            _buildInfoRow(
              Icons.access_time,
              'Fecha y hora',
              _formatDate(scheduledDate),
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.attach_money,
                  'Precio',
                  '\$${totalPrice.toStringAsFixed(2)}',
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              if (contactPhone != 'No disponible') ...[
                Expanded(
                  child: _buildInfoRow(
                    Icons.phone,
                    'Contacto',
                    contactPhone,
                    AppColors.primaryBlue,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.primaryBlue.withAlpha((255 * 0.2).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, size: 16, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Notas del cliente:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Solicitud directa del cliente - Contacta para coordinar detalles',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      String bookingId, Map<String, dynamic> data, String status) {
    switch (status) {
      case 'pending':
        return _buildPendingActions(bookingId, data);
      case 'accepted':
        return _buildAcceptedActions(bookingId, data);
      case 'in_progress':
        return _buildInProgressActions(bookingId, data);
      case 'completed':
        return _buildCompletedActions(bookingId, data);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPendingActions(String bookingId, Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withAlpha((255 * 0.05).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.warningOrange.withAlpha((255 * 0.2).round())),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_empty,
                  size: 16, color: AppColors.warningOrange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Solicitud pendiente - Elige una acción:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectBooking(bookingId),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dangerRed,
                  side: const BorderSide(color: AppColors.dangerRed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _acceptBooking(bookingId),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aceptar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _contactClient(data),
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Contactar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _deleteBooking(bookingId, data),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text(
                  'Eliminar',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptedActions(String bookingId, Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _contactClient(data),
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Contactar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startWork(bookingId),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Iniciar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.cardWhite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openChat(data),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Abrir Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.successGreen,
              side: const BorderSide(color: AppColors.successGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressActions(String bookingId, Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoPurple.withAlpha((255 * 0.05).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.infoPurple.withAlpha((255 * 0.2).round())),
          ),
          child: Row(
            children: [
              const Icon(Icons.work, size: 18, color: AppColors.infoPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trabajo en curso',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.infoPurple,
                      ),
                    ),
                    Text(
                      'Mantente en contacto con el cliente',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            AppColors.infoPurple.withAlpha((255 * 0.8).round()),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.infoPurple.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: AppColors.infoPurple),
                    SizedBox(width: 4),
                    Text(
                      'Activo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.infoPurple,
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
              child: OutlinedButton.icon(
                onPressed: () => _contactClient(data),
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Contactar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _completeWork(bookingId),
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Completar Trabajo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _viewBookingDetails(data),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Ver Detalles'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _reportProblem(bookingId, data),
                icon: const Icon(Icons.report_problem, size: 16),
                label: const Text('Reportar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warningOrange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedActions(String bookingId, Map<String, dynamic> data) {
    return Column(
      children: [
        if (data['hasRated'] == true) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withAlpha((255 * 0.05).round()),
                  Colors.amber.withAlpha((255 * 0.1).round())
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.amber.withAlpha((255 * 0.3).round())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: Colors.amber[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Calificación recibida',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${data['rating']?.toStringAsFixed(1) ?? '0.0'}/5',
                        style: const TextStyle(
                          color: AppColors.cardWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (index) {
                    final rating = data['rating']?.toDouble() ?? 0.0;
                    return Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber[600],
                      size: 16,
                    );
                  }),
                ),
                if (data['review'] != null &&
                    data['review'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${data['review']}"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha((255 * 0.05).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primaryBlue.withAlpha((255 * 0.2).round())),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_empty,
                    size: 16, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esperando calificación del cliente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewBookingDetails(data),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Detalles'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.textLight),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _downloadReceipt(bookingId),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Recibo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.infoPurple,
                  foregroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: AppColors.textLight),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'contact',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text('Contactar cliente'),
                    ],
                  ),
                ),
                if (data['hasRated'] == true) ...[
                  PopupMenuItem(
                    value: 'view_rating',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 8),
                        const Text('Ver calificación completa'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16, color: AppColors.successGreen),
                      SizedBox(width: 8),
                      Text('Duplicar servicio'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppColors.dangerRed),
                      SizedBox(width: 8),
                      Text('Eliminar',
                          style: TextStyle(color: AppColors.dangerRed)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'contact':
                    _contactClient(data);
                    break;
                  case 'view_rating':
                    _viewFullRating(data);
                    break;
                  case 'duplicate':
                    _duplicateService(data);
                    break;
                  case 'delete':
                    _deleteBooking(bookingId, data);
                    break;
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // ========================================
  // ACCIONES DE RESERVAS
  // ========================================

  Future<void> _acceptBooking(String bookingId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen),
            SizedBox(width: 8),
            Text('Aceptar Solicitud',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirmas que quieres aceptar esta solicitud de trabajo?',
                style: TextStyle(color: AppColors.textDark)),
            SizedBox(height: 12),
            Text('Al aceptar:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('• El cliente será notificado',
                style: TextStyle(color: AppColors.textDark)),
            Text('• Te comprometes a realizar el trabajo',
                style: TextStyle(color: AppColors.textDark)),
            Text('• Podrás contactar al cliente',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.updateBookingStatus(
                    bookingId, 'accepted');
                _showSnackBar(
                    '¡Trabajo aceptado! El cliente ha sido notificado.',
                    AppColors.successGreen);
              } catch (e) {
                _showSnackBar(
                    'Error al aceptar trabajo: $e', AppColors.dangerRed);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.cardWhite),
            child: const Text('Aceptar Trabajo'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectBooking(String bookingId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warningOrange),
            SizedBox(width: 8),
            Text('Rechazar Solicitud',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres rechazar esta solicitud?',
                style: TextStyle(color: AppColors.textDark)),
            SizedBox(height: 12),
            Text('Al rechazar:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('• El cliente será notificado',
                style: TextStyle(color: AppColors.textDark)),
            Text('• Podrá buscar otros proveedores',
                style: TextStyle(color: AppColors.textDark)),
            Text('• No afectará tu calificación',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.updateBookingStatus(
                    bookingId, 'rejected');
                _showSnackBar(
                    'Solicitud rechazada. El cliente ha sido notificado.',
                    AppColors.warningOrange);
              } catch (e) {
                _showSnackBar(
                    'Error al rechazar trabajo: $e', AppColors.dangerRed);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningOrange,
                foregroundColor: AppColors.cardWhite),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Future<void> _startWork(String bookingId) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, 'in_progress');
      _showSnackBar('Trabajo iniciado. ¡Buen trabajo!', AppColors.primaryBlue);
    } catch (e) {
      _showSnackBar('Error al iniciar trabajo: $e', AppColors.dangerRed);
    }
  }

  Future<void> _completeWork(String bookingId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Completar Trabajo',
            style: TextStyle(color: AppColors.textDark)),
        content: const Text(
            '¿Has terminado el trabajo? El cliente será notificado para que pueda calificarte.',
            style: TextStyle(color: AppColors.textDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.updateBookingStatus(
                    bookingId, 'completed');
                _showSnackBar(
                    '¡Trabajo completado! Espera la calificación del cliente.',
                    AppColors.successGreen);
              } catch (e) {
                _showSnackBar(
                    'Error al completar trabajo: $e', AppColors.dangerRed);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.cardWhite),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _contactClient(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Contactar a ${data['clientName'] ?? 'Cliente'}',
            style: const TextStyle(color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data['contactPhone'] != null &&
                data['contactPhone'].toString().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primaryBlue),
                title: const Text('Llamar',
                    style: TextStyle(color: AppColors.textDark)),
                subtitle: Text(data['contactPhone'],
                    style: const TextStyle(color: AppColors.textLight)),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Abriendo aplicación de teléfono...',
                      AppColors.primaryBlue);
                },
              ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.primaryBlue),
              title: const Text('Enviar mensaje',
                  style: TextStyle(color: AppColors.textDark)),
              subtitle: const Text('WhatsApp o SMS',
                  style: TextStyle(color: AppColors.textLight)),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Abriendo aplicación de mensajes...',
                    AppColors.primaryBlue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.successGreen),
              title: const Text('Chat en la app',
                  style: TextStyle(color: AppColors.textDark)),
              subtitle: const Text('Mensajería integrada',
                  style: TextStyle(color: AppColors.textLight)),
              onTap: () {
                Navigator.pop(context);
                _openChat(data);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> data) {
    final String clientId = data['clientId'] ?? data['userId'] ?? '';
    final String clientName =
        data['clientName'] ?? data['contactPerson'] ?? 'Cliente';
    final String bookingId = data['bookingId'] ?? '';

    if (clientId.isEmpty) {
      _showSnackBar(
          'Error: No se puede abrir el chat. Información del cliente no disponible.',
          AppColors.dangerRed);
      return;
    }

    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': '${FirebaseAuth.instance.currentUser?.uid}_$clientId',
        'otherUserId': clientId,
        'otherUserName': clientName,
        'bookingId': bookingId,
        'userType': 'provider', // Critical fix: maintaining provider role
      },
    );
  }

  void _viewBookingDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Detalles del Trabajo',
            style: TextStyle(color: AppColors.textDark)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _buildBookingDetails(data),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.textLight)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookingDetails(Map<String, dynamic> data) {
    final details = <Widget>[
      _buildDetailRow('Cliente:', data['clientName'] ?? 'N/A'),
      _buildDetailRow('Email:', data['clientEmail'] ?? 'N/A'),
      _buildDetailRow('Teléfono:', data['contactPhone'] ?? 'N/A'),
      _buildDetailRow(
          'Precio:', '\$${_getTotalPrice(data).toStringAsFixed(2)}'),
    ];

    if (data['duration'] != null && data['duration'] is Map<String, dynamic>) {
      final durationData = data['duration'] as Map<String, dynamic>;
      final displayText = durationData['displayText'] ?? 'No especificada';
      details.add(_buildDetailRow('Duración:', displayText));
    } else if (data['estimatedHours'] != null) {
      // Fallback to old format
      details
          .add(_buildDetailRow('Duración:', '${data['estimatedHours']} horas'));
    }

    if (data['time'] != null) {
      details.add(_buildDetailRow('Hora:', data['time']));
    }

    // Add other details
    if (data['urgencyLevel'] != null && data['urgencyLevel'] != 'normal') {
      details.add(_buildDetailRow(
          'Urgencia:', data['urgencyLevel'].toString().toUpperCase()));
    }
    if (data['propertyType'] != null) {
      details.add(_buildDetailRow('Tipo propiedad:', data['propertyType']));
    }
    if (data['hasAnimals'] == true) {
      details.add(_buildDetailRow('Mascotas:', 'Sí, hay mascotas en el lugar'));
    }
    if (data['hasChildren'] == true) {
      details.add(_buildDetailRow('Niños:', 'Sí, hay niños pequeños'));
    }
    if (data['needsSpecialTools'] == true) {
      details.add(
          _buildDetailRow('Herramientas:', 'Requiere herramientas especiales'));
    }
    if (data['accessInstructions'] != null &&
        data['accessInstructions'].toString().isNotEmpty) {
      details.add(_buildDetailRow('Acceso:', data['accessInstructions']));
    }
    if (data['notes'] != null && data['notes'].toString().isNotEmpty) {
      details.add(_buildDetailRow('Notas:', data['notes']));
    }

    return details;
  }

  void _reportProblem(String bookingId, Map<String, dynamic> data) {
    String problemDescription = '';
    String selectedProblem = 'otros';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.report_problem, color: AppColors.warningOrange),
              SizedBox(width: 8),
              Text('Reportar Problema',
                  style: TextStyle(color: AppColors.textDark)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el tipo de problema:',
                    style: TextStyle(color: AppColors.textDark)),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: selectedProblem,
                  onChanged: (value) {
                    setState(() {
                      selectedProblem = value!;
                    });
                  },
                  child: Column(
                    children: [
                      'cliente_ausente',
                      'acceso_dificil',
                      'herramientas_faltantes',
                      'condiciones_diferentes',
                      'otros'
                    ]
                        .map(
                          (problem) => RadioListTile<String>(
                            title: Text(_getProblemText(problem),
                                style:
                                    const TextStyle(color: AppColors.textDark)),
                            value: problem,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppColors.warningOrange,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción detallada',
                    hintText: 'Explica el problema que estás enfrentando...',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.warningOrange),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => problemDescription = value,
                  style: const TextStyle(color: AppColors.textDark),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (problemDescription.trim().isNotEmpty) {
                  try {
                    await _firestoreService.reportProblem({
                      'bookingId': bookingId,
                      'providerId': currentUserId!,
                      'userId': data['clientId'] ?? '',
                      'reason': selectedProblem,
                      'description': problemDescription.trim(),
                    });
                    _showSnackBar(
                        'Problema reportado. Te contactaremos pronto.',
                        AppColors.warningOrange);
                  } catch (e) {
                    _showSnackBar('Error al reportar: $e', AppColors.dangerRed);
                  }
                } else {
                  _showSnackBar('Por favor describe el problema',
                      AppColors.warningOrange);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningOrange,
                  foregroundColor: AppColors.cardWhite),
              child: const Text('Reportar'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullRating(Map<String, dynamic> data) {
    final rating = data['rating']?.toDouble() ?? 0.0;
    final review = data['review'] ?? '';
    final clientName = data['clientName'] ?? 'Cliente';
    final serviceTitle = data['serviceTitle'] ?? 'Servicio';
    final ratedDate = data['ratedAt'] != null
        ? DateTime.tryParse(data['ratedAt'].toString())
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600]),
            const SizedBox(width: 8),
            const Text('Calificación Completa',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calificado por: $clientName',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  if (ratedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: ${_formatDate(ratedDate)}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber[600],
                  size: 32,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '${rating.toStringAsFixed(1)}/5.0',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
            if (review.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha((255 * 0.05).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          AppColors.primaryBlue.withAlpha((255 * 0.2).round())),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentario:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"$review"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('¡Excelente trabajo! 👏', AppColors.successGreen);
            },
            icon: const Icon(Icons.thumb_up, size: 16),
            label: const Text('¡Genial!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: AppColors.cardWhite,
            ),
          ),
        ],
      ),
    );
  }

  void _duplicateService(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.copy, color: AppColors.successGreen),
            SizedBox(width: 8),
            Text('Duplicar Servicio',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        content: Text(
          '¿Quieres crear un nuevo servicio basado en "${data['serviceTitle'] ?? 'este trabajo'}"?\n\n'
          'Se abrirá el formulario de creación con los datos prellenados.',
          style: const TextStyle(color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                  'Función próximamente...', AppColors.primaryBlue);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.cardWhite),
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _deleteBooking(String bookingId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.dangerRed),
            SizedBox(width: 8),
            Text('Eliminar Solicitud',
                style: TextStyle(color: AppColors.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres eliminar esta solicitud?',
                style: TextStyle(color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data['serviceTitle'] ?? 'Servicio'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  Text('Cliente: ${data['clientName'] ?? 'N/A'}',
                      style: const TextStyle(color: AppColors.textDark)),
                  Text(
                      'Precio: \$${(data['finalTotal'] is num ? (data['finalTotal'] as num) : 0).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textDark)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withAlpha((255 * 0.05).round()),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                    color: AppColors.dangerRed.withAlpha((255 * 0.2).round())),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Al eliminar:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.dangerRed)),
                  Text('• Se borrará permanentemente',
                      style: TextStyle(color: AppColors.dangerRed)),
                  Text('• El cliente NO será notificado',
                      style: TextStyle(color: AppColors.dangerRed)),
                  Text('• No podrás recuperar la información',
                      style: TextStyle(color: AppColors.dangerRed)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteBooking(bookingId);
                _showSnackBar(
                    'Solicitud eliminada permanentemente', AppColors.dangerRed);
              } catch (e) {
                _showSnackBar(
                    'Error al eliminar solicitud: $e', AppColors.dangerRed);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                foregroundColor: AppColors.cardWhite),
            child: const Text('Eliminar Permanentemente'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(String bookingId) {
    _showSnackBar('Descargando recibo del trabajo...', AppColors.successGreen);
  }

  // ========================================
  // HELPERS
  // ========================================

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningOrange;
      case 'accepted':
        return AppColors.successGreen;
      case 'in_progress':
        return AppColors.infoPurple;
      case 'completed':
        return AppColors.primaryBlue;
      case 'rejected':
        return AppColors.dangerRed;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'accepted':
        return 'Aceptado';
      case 'in_progress':
        return 'En Curso';
      case 'completed':
        return 'Completado';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';

    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Mañana ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == -1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getProblemText(String? problem) {
    switch (problem) {
      case 'cliente_ausente':
        return 'Cliente no se encuentra en el lugar';
      case 'acceso_dificil':
        return 'Dificultades para acceder al lugar';
      case 'herramientas_faltantes':
        return 'Faltan herramientas necesarias';
      case 'condiciones_diferentes':
        return 'Las condiciones son diferentes a lo acordado';
      case 'otros':
        return 'Otro problema';
      default:
        return problem ?? 'Sin problemas reportados';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'pendientes';
      case 'accepted':
        return 'aceptados';
      case 'in_progress':
        return 'en curso';
      case 'completed':
        return 'completados';
      default:
        return status;
    }
  }

  String _getEmptyTitle(String status) {
    switch (status) {
      case 'pending':
        return 'No hay solicitudes pendientes';
      case 'accepted':
        return 'No hay trabajos aceptados';
      case 'in_progress':
        return 'No hay trabajos en curso';
      case 'completed':
        return 'No hay trabajos completados';
      default:
        return 'No hay trabajos';
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Las nuevas solicitudes aparecerán aquí cuando los clientes te contacten.';
      case 'accepted':
        return 'Los trabajos que aceptes aparecerán aquí hasta que los inicies.';
      case 'in_progress':
        return 'Los trabajos activos aparecerán aquí mientras los realizas.';
      case 'completed':
        return 'Tu historial de trabajos completados aparecerá aquí.';
      default:
        return 'Los trabajos aparecerán aquí cuando estén disponibles.';
    }
  }
}
