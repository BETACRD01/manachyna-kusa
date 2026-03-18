import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final DatabaseService _firestoreService = DatabaseService();
  bool _isProcessing = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Pendientes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: Stream.fromFuture(_firestoreService.getProviderRequests(status: 'pending')),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar solicitudes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, intenta de nuevo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay solicitudes pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las nuevas solicitudes de proveedores aparecerán aquí',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final data = req as Map<String, dynamic>;
              return _buildPendingRequestCard(
                  data['id']?.toString() ?? '', data);
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestCard(String requestId, Map<String, dynamic> data) {
    final String displayName = data['providerType'] == 'individual'
        ? (data['fullName'] ?? 'Sin nombre')
        : (data['groupName'] ?? 'Sin nombre');

    final String phone = data['providerType'] == 'individual'
        ? (data['phone'] ?? 'Sin teléfono')
        : (data['groupPhone'] ?? 'Sin teléfono');

    final List<String> services = List<String>.from(data['services'] ?? []);
    final String servicesList = services.isNotEmpty
        ? services.join(', ')
        : 'Sin servicios especificados';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información básica
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['userEmail'] ?? 'Sin email',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge del tipo de proveedor
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: data['providerType'] == 'individual'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['providerType'] == 'individual'
                        ? 'Individual'
                        : 'Grupo',
                    style: TextStyle(
                      color: data['providerType'] == 'individual'
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información de servicios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Servicios ofrecidos:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servicesList.length > 100
                        ? '${servicesList.substring(0, 100)}...'
                        : servicesList,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Información de precios
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Por hora',
                    '${data['hourlyRate']?.toString() ?? '0'}/h', // Corrección aquí
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Por día',
                    '${data['dailyRate']?.toString() ?? '0'}/día', // Comilla simple normal
                    Icons.today,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status de solicitud
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.pending_actions,
                      color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esperando aprobación de administrador',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _showRequestDetails(requestId, data),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver detalles'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isProcessing ? null : () => _rejectRequest(requestId),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isProcessing ? null : () => _approveRequest(requestId),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check,
                            size: 18, color: Colors.white),
                    label: Text(
                      _isProcessing ? 'Procesando...' : 'Aprobar',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(String requestId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detalles de la Solicitud',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Información Personal', [
                        if (data['providerType'] == 'individual') ...[
                          _buildDetailRow(
                              'Nombre:', data['fullName'] ?? 'No especificado'),
                          _buildDetailRow(
                              'Cédula:', data['cedula'] ?? 'No especificado'),
                          _buildDetailRow('Edad:',
                              '${data['age'] ?? 'No especificado'} años'),
                          _buildDetailRow(
                              'Teléfono:', data['phone'] ?? 'No especificado'),
                          _buildDetailRow('Dirección:',
                              data['address'] ?? 'No especificado'),
                          _buildDetailRow('Transporte propio:',
                              data['hasTransport'] == true ? 'Sí' : 'No'),
                        ] else ...[
                          _buildDetailRow('Nombre del grupo:',
                              data['groupName'] ?? 'No especificado'),
                          _buildDetailRow('Representante:',
                              data['representative'] ?? 'No especificado'),
                          _buildDetailRow('Tamaño del equipo:',
                              '${data['teamSize'] ?? 'No especificado'} personas'),
                          _buildDetailRow('Teléfono:',
                              data['groupPhone'] ?? 'No especificado'),
                          _buildDetailRow('Dirección:',
                              data['groupAddress'] ?? 'No especificado'),
                          _buildDetailRow(
                              'RUC:',
                              data['ruc']?.isNotEmpty == true
                                  ? data['ruc']
                                  : 'No proporcionado'),
                        ],
                        _buildDetailRow(
                            'Email:', data['userEmail'] ?? 'No especificado'),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Servicios y Precios', [
                        _buildDetailRow(
                            'Servicios:',
                            (data['services'] as List?)?.join(', ') ??
                                'No especificados'),
                        _buildDetailRow(
                            'Tarifa por hora:', '${data['hourlyRate'] ?? 0}'),
                        _buildDetailRow(
                            'Tarifa por día:', '${data['dailyRate'] ?? 0}'),
                        if (data['description']?.isNotEmpty == true)
                          _buildDetailRow('Descripción:', data['description']),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Disponibilidad', [
                        _buildDetailRow('Días disponibles:',
                            _getAvailableDays(data['availability'])),
                        _buildDetailRow('Horario:',
                            '${data['workingHours']?['start'] ?? 'No especificado'} - ${data['workingHours']?['end'] ?? 'No especificado'}'),
                        _buildDetailRow('Trabajo fuera de Tena:',
                            data['worksOutsideTena'] == true ? 'Sí' : 'No'),
                        _buildDetailRow('Trabajo en zonas rurales:',
                            data['worksRuralAreas'] == true ? 'Sí' : 'No'),
                      ]),
                      if (data['reference'] != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Referencias', [
                          _buildDetailRow('Nombre:',
                              data['reference']['name'] ?? 'No especificado'),
                          _buildDetailRow('Teléfono:',
                              data['reference']['phone'] ?? 'No especificado'),
                          _buildDetailRow(
                              'Relación:',
                              data['reference']['relationship'] ??
                                  'No especificado'),
                        ]),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _rejectRequest(requestId);
                                    },
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Rechazar',
                                  style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _approveRequest(requestId);
                                    },
                              icon: _isProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check,
                                      color: Colors.white),
                              label: Text(
                                _isProcessing ? 'Procesando...' : 'Aprobar',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getAvailableDays(Map<String, dynamic>? availability) {
    if (availability == null) return 'No especificado';

    final availableDays = availability.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    return availableDays.isNotEmpty
        ? availableDays.join(', ')
        : 'Ningún día seleccionado';
  }

  /// Aprobar solicitud y convertir usuario a proveedor
  Future<void> _approveRequest(String requestId) async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await _firestoreService.updateProviderRequestStatus(
          requestId, 'approved');

      _showSuccessSnackBar('Solicitud aprobada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al aprobar solicitud: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    if (_isProcessing) return;

    // Mostrar diálogo de confirmación
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Rechazo'),
        content: const Text(
          '¿Estás seguro de que deseas rechazar esta solicitud?\n\n'
          'Esta acción no se puede deshacer y el solicitante será notificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      try {
        setState(() => _isProcessing = true);

        await _firestoreService.updateProviderRequestStatus(
            requestId, 'rejected');

        _showSuccessSnackBar('Solicitud rechazada');
      } catch (e) {
        _showErrorSnackBar('Error al rechazar solicitud: $e');
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }
}
