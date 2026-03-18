import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';
import '../../data/services/base_api_service.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic>? serviceData;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    this.serviceData,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  Map<String, dynamic>? serviceData;
  Map<String, dynamic>? providerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    serviceData = widget.serviceData;
    debugPrint('ServiceDetailsScreen iniciado con:');
    debugPrint('ServiceId: ${widget.serviceId}');
    debugPrint('ServiceData: ${widget.serviceData}');
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      debugPrint('Cargando detalles del servicio...');

      if (serviceData == null || serviceData!.isEmpty) {
        debugPrint('Cargando desde Django...');
        final apiService = BaseApiService();
        final response = await apiService.get('services/${widget.serviceId}/');

        if (response != null && response is Map<String, dynamic>) {
          serviceData = response;
          debugPrint(
              'Servicio cargado desde Django: ${serviceData!['title']}');
        } else {
          debugPrint('Servicio no encontrado en Django');
        }
      }

      if (serviceData != null && serviceData!['providerId'] != null) {
        debugPrint('Cargando datos del proveedor...');
        final apiService = BaseApiService();
        final providerId = serviceData!['providerId'];
        final response = await apiService.get('providers/$providerId/');

        if (response != null && response is Map<String, dynamic>) {
          providerData = response;
          debugPrint('Proveedor cargado: ${providerData!['name']}');
        }
      }
    } catch (e) {
      debugPrint('Error loading service details: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Construyendo ServiceDetailsScreen - isLoading: $isLoading');

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Servicio'),
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (serviceData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Servicio'),
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Servicio no encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(serviceData!['title'] ?? 'Detalles del Servicio'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceHeader(),
            _buildServiceInfo(),
            _buildProviderInfo(),
            _buildScheduleInfo(),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[600]!, Colors.indigo[700]!],
        ),
      ),
      child: Stack(
        children: [
          if (serviceData!['imageUrl'] != null)
            Positioned.fill(
              child: Image.network(
                serviceData!['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.indigo[600],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                  );
                },
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.7)],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    serviceData!['category'] ?? 'Servicio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  serviceData!['title'] ?? 'Título del servicio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Tena, Napo',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    final price = (serviceData!['price'] ?? 0.0).toDouble();
    final timeMode = serviceData!['timeMode'] ?? 'Por hora';
    final rating = (serviceData!['rating'] ?? 0.0).toDouble();
    final totalRatings = serviceData!['totalRatings'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  Text(
                    _getTimeModeText(timeMode),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (rating > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} ($totalRatings)',
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceData!['description'] ?? 'Sin descripción disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    if (providerData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proveedor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.indigo[100],
                child: Text(
                  (providerData!['name'] ?? 'P').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerData!['name'] ?? 'Proveedor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      providerData!['email'] ?? '',
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
        ],
      ),
    );
  }

  Widget _buildScheduleInfo() {
    final workHours = serviceData!['workHours'] as Map<String, dynamic>?;
    if (workHours == null) return const SizedBox.shrink();

    final activeHours = workHours.entries
        .where((entry) => entry.value['isActive'] == true)
        .toList();

    if (activeHours.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios de Atención',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: activeHours.length,
            itemBuilder: (context, index) {
              final dayEntry = activeHours[index];
              final day = dayEntry.key;
              final hours = dayEntry.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Text(
                      day.substring(0, 3),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${hours['start']} - ${hours['end']}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _contactProvider,
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('Contactar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.indigo[300]!),
                foregroundColor: Colors.indigo[600],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _scheduleAppointment,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: const Text('Agendar Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeModeText(String timeMode) {
    switch (timeMode) {
      case 'Por hora':
        return '/hora';
      case 'Por día':
        return '/día';
      case 'Por semana':
        return '/semana';
      case 'Por trabajo':
        return '/trabajo';
      case 'Por visita':
        return '/visita';
      default:
        return '';
    }
  }

  void _contactProvider() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de contacto próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _scheduleAppointment() {
    debugPrint('Botón Agendar Cita presionado');

    // Verificar si hay un AuthProvider disponible
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) {
        debugPrint('Usuario no autenticado, mostrando diálogo de login');
        _showLoginDialog();
        return;
      }

      debugPrint('Usuario autenticado, navegando a booking');
      Navigator.pushNamed(
        context,
        '/booking',
        arguments: BookingArguments(
          serviceId: widget.serviceId,
          serviceData: serviceData!,
          providerData: providerData,
        ),
      );
    } catch (e) {
      debugPrint('Error al verificar autenticación: $e');
      // Si no hay AuthProvider, navegar directamente
      Navigator.pushNamed(
        context,
        '/booking',
        arguments: BookingArguments(
          serviceId: widget.serviceId,
          serviceData: serviceData!,
          providerData: providerData,
        ),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Iniciar Sesión'),
        content: const Text('Necesitas iniciar sesión para agendar una cita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}
