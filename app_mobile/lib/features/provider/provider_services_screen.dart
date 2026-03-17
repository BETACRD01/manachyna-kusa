// NUEVA PANTALLA: lib/features/provider/provider_services_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  String? providerId;
  String? providerName;
  List<Map<String, dynamic>>? services;
  
  // Servicios seleccionados por el usuario
  Map<String, bool> selectedServices = {};
  Map<String, double> servicePrices = {};
  
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      providerId = args['providerId'];
      providerName = args['providerName'];
      services = List<Map<String, dynamic>>.from(args['services']);
      
      // Inicializar estado de selección
      for (var service in services!) {
        final serviceId = service['id'] ?? '';
        selectedServices[serviceId] = false;
        servicePrices[serviceId] = (service['price'] as num?)?.toDouble() ?? 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (services == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se encontraron servicios')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios de $providerName'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showProviderProfile,
            tooltip: 'Ver perfil del proveedor',
          ),
        ],
      ),
      body: Column(
        children: [
          // === HEADER DEL PROVEEDOR ===
          _buildProviderHeader(),
          
          // === LISTA DE SERVICIOS ===
          Expanded(
            child: _buildServicesList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProviderHeader() {
    final firstService = services!.first;
    final rating = (firstService['rating'] as num?)?.toDouble() ?? 0.0;
    final completedJobs = firstService['completedJobs'] ?? 0;
    final coverageAreas = firstService['coverageAreas'] as List<dynamic>? ?? [];

    return Container(
      color: Colors.blue[600],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar del proveedor
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    providerName!.isNotEmpty ? providerName![0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del proveedor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (rating > 0) ...[
                            Icon(Icons.star, size: 18, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700],
                            ),
                            ),
                          const SizedBox(width: 8),
                          ],
                          Text(
                            '$completedJobs trabajos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (coverageAreas.isNotEmpty)
                        Text(
                          'Cobertura: ${coverageAreas.take(3).join(', ')}${coverageAreas.length > 3 ? '...' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecciona los servicios que necesitas y solicita tu cotización',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services!.length,
      itemBuilder: (context, index) {
        final service = services![index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final serviceId = service['id'] ?? '';
    final title = service['title'] ?? 'Servicio';
    final description = service['description'] ?? '';
    final price = (service['price'] as num?)?.toDouble() ?? 0.0;
    final category = service['category'] ?? 'General';
    final subcategories = service['subcategories'] as List<dynamic>? ?? [];
    final isSelected = selectedServices[serviceId] ?? false;
    final imageUrl = service['imageUrl'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del servicio
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: Icon(
                            _getServiceIcon(category),
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                    
                    // Overlay de selección
                    if (isSelected)
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.blue[600]!.withAlpha((0.3 * 255).toInt()),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              // Si no hay imagen, mostrar ícono
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withAlpha((0.1 * 255).toInt()),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getServiceIcon(category),
                    size: 48,
                    color: _getCategoryColor(category),
                  ),
                ),
              ),
            ],
            
            // Contenido del servicio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con checkbox
                  Row(
                    children: [
                      // Checkbox
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedServices[serviceId] = value ?? false;
                          });
                        },
                        activeColor: Colors.blue[600],
                      ),
                      
                      // Título y precio
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue[700] : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}/hora',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(category).withAlpha((0.1 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Descripción
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Subcategorías
                  if (subcategories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: subcategories.take(3).map((sub) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sub.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  
                  // Información adicional si está seleccionado
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Servicio seleccionado - Se incluirá en tu solicitud',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final selectedCount = selectedServices.values.where((selected) => selected).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen de selección
            if (selectedCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$selectedCount ${selectedCount == 1 ? 'servicio seleccionado' : 'servicios seleccionados'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    Text(
                      'Desde \${totalPrice.toStringAsFixed(2)}/h',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProviderProfile(),
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('Ver Perfil'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: selectedCount > 0 ? _proceedToBooking : null,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(
                      selectedCount > 0 
                          ? 'Solicitar ${selectedCount == 1 ? 'Servicio' : 'Servicios'}'
                          : 'Selecciona servicios',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCount > 0 ? Colors.blue[600] : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // ====================================
  // MÉTODOS DE FUNCIONALIDAD
  // ====================================

  void _showProviderProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ProviderProfileModal(
        providerId: providerId!,
        providerName: providerName!,
        services: services!,
      ),
    );
  }

  Future<void> _proceedToBooking() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showSnackBar('Debes iniciar sesión para solicitar servicios', Colors.red);
      return;
    }

    // Obtener servicios seleccionados
    final selectedServicesList = services!.where((service) {
      final serviceId = service['id'] ?? '';
      return selectedServices[serviceId] == true;
    }).toList();

    if (selectedServicesList.isEmpty) {
      _showSnackBar('Selecciona al menos un servicio', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Navegar a pantalla de reserva simplificada con múltiples servicios
      await Navigator.pushNamed(
        context,
        '/simple-booking',
        arguments: {
          'providerId': providerId,
          'providerName': providerName,
          'selectedServices': selectedServicesList,
          'totalEstimatedPrice': selectedServicesList.fold<double>(
            0.0, 
            (sum, service) => sum + ((service['price'] as num?)?.toDouble() ?? 0.0)
          ),
        },
      );

    } catch (e) {
      _showSnackBar('Error al procesar solicitud: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ====================================
  // MÉTODOS AUXILIARES
  // ====================================

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'limpieza': return Colors.blue;
      case 'plomería': return Colors.cyan;
      case 'electricidad': return Colors.yellow[700]!;
      case 'carpintería': return Colors.brown;
      case 'jardinería': return Colors.green;
      case 'pintura': return Colors.purple;
      case 'reparaciones': return Colors.orange;
      case 'instalaciones': return Colors.indigo;
      case 'mantenimiento': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getServiceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'limpieza': return Icons.cleaning_services;
      case 'plomería': return Icons.plumbing;
      case 'electricidad': return Icons.electrical_services;
      case 'carpintería': return Icons.carpenter;
      case 'jardinería': return Icons.grass;
      case 'pintura': return Icons.format_paint;
      case 'reparaciones': return Icons.build;
      case 'instalaciones': return Icons.construction;
      case 'mantenimiento': return Icons.settings;
      default: return Icons.home_repair_service;
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ====================================
// MODAL DEL PERFIL DEL PROVEEDOR
// ====================================

class _ProviderProfileModal extends StatelessWidget {
  final String providerId;
  final String providerName;
  final List<Map<String, dynamic>> services;

  const _ProviderProfileModal({
    required this.providerId,
    required this.providerName,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final firstService = services.first;
    final rating = (firstService['rating'] as num?)?.toDouble() ?? 0.0;
    final completedJobs = firstService['completedJobs'] ?? 0;
    final coverageAreas = firstService['coverageAreas'] as List<dynamic>? ?? [];
    final workingDays = firstService['workingDays'] as List<dynamic>? ?? [];
    final startTime = firstService['startTime'] ?? '08:00';
    final endTime = firstService['endTime'] ?? '18:00';

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle del modal
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Header del perfil
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[100],
                child: Text(
                  providerName.isNotEmpty ? providerName[0].toUpperCase() : 'P',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proveedor de servicios en Tena',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Estadísticas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                child: _buildStatColumn(
                rating.toStringAsFixed(1),
                'Calificación',
                 Icons.star,
                Colors.amber[600]!,
                 ),
               ),

                Container(height: 40, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatColumn(
                    '$completedJobs',
                    'Trabajos',
                    Icons.work,
                    Colors.green[600]!,
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatColumn(
                    '${services.length}',
                    'Servicios',
                    Icons.build,
                    Colors.blue[600]!,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información detallada
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    'Cobertura',
                    coverageAreas.isNotEmpty 
                        ? coverageAreas.join(', ')
                        : 'Información no disponible',
                    Icons.location_on,
                    Colors.red,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoSection(
                    'Horarios de trabajo',
                    workingDays.isNotEmpty 
                        ? '${workingDays.join(', ')} • $startTime - $endTime'
                        : 'Información no disponible',
                    Icons.schedule,
                    Colors.orange,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoSection(
                  'Servicios especializados',
                   services.map((s) => s['category']).toSet().join(', '),
                  Icons.build_circle,
                Colors.purple,
                  ),

                  
                  const SizedBox(height: 16),
                  
                  // Servicios adicionales
                  if (firstService['hasTransport'] == true ||
                      firstService['emergencyService'] == true ||
                      firstService['weekendService'] == true ||
                      firstService['includeProducts'] == true) ...[
                    Text(
                      'Servicios adicionales:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (firstService['hasTransport'] == true)
                          _buildFeatureChip('🚗 Transporte propio'),
                        if (firstService['emergencyService'] == true)
                          _buildFeatureChip('🚨 Emergencias'),
                        if (firstService['weekendService'] == true)
                          _buildFeatureChip('📅 Fines de semana'),
                        if (firstService['includeProducts'] == true)
                          _buildFeatureChip('🧴 Productos incluidos'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón para cerrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cerrar Perfil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}