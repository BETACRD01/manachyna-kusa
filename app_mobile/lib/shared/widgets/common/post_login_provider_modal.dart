import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

// Single file containing all components for PostLoginProviderModal
// Structured with clear sections for models, utilities, services, widgets, and main modal
// Designed to align with Banco Pichincha's aesthetic: blue and white, rounded corners, subtle shadows
// Follows Dart/Flutter best practices: type safety, null safety, modularity, and responsive design

// --- Logger ---
final Logger logger = Logger();

// --- Models ---

/// Model for booking data
class BookingData {
  final String serviceCategory;
  final String? serviceTitle;
  final double? finalTotal;
  final String? paymentMethod;

  BookingData({
    required this.serviceCategory,
    this.serviceTitle,
    this.finalTotal,
    this.paymentMethod,
  });

  factory BookingData.fromMap(Map<String, dynamic> map) {
    return BookingData(
      serviceCategory: map['serviceCategory'] ?? 'general',
      serviceTitle: map['serviceTitle'],
      finalTotal: map['finalTotal']?.toDouble(),
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceCategory': serviceCategory,
      'serviceTitle': serviceTitle,
      'finalTotal': finalTotal,
      'paymentMethod': paymentMethod,
    };
  }
}

/// Model for provider selection data
class ProviderSelectionData {
  final String providerId;
  final String providerName;
  final Map<String, dynamic> providerData;
  final double rating;
  final int completedJobs;
  final double pricePerHour;
  final String responseTime;
  final String location;
  final int experienceYears;

  ProviderSelectionData({
    required this.providerId,
    required this.providerName,
    required this.providerData,
    required this.rating,
    required this.completedJobs,
    required this.pricePerHour,
    required this.responseTime,
    required this.location,
    required this.experienceYears,
  });

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'providerData': providerData,
      'providerRating': rating,
      'providerJobs': completedJobs,
      'pricePerHour': pricePerHour,
      'responseTime': responseTime,
      'location': location,
      'experienceYears': experienceYears,
    };
  }
}

/// Model for provider statistics
class ProviderStats {
  final int completedJobs;
  final String responseTime;
  final String location;
  final double pricePerHour;
  final int experienceYears;

  ProviderStats({
    required this.completedJobs,
    required this.responseTime,
    required this.location,
    required this.pricePerHour,
    required this.experienceYears,
  });

  Widget toWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat(
          Icons.work_history,
          '$completedJobs',
          'Trabajos',
          Colors.blue,
        ),
        _buildStat(
          Icons.schedule,
          responseTime,
          'Respuesta',
          Colors.orange,
        ),
        _buildStat(
          Icons.location_on,
          _DistanceCalculator().formatDistance(
            _DistanceCalculator().calculateDistance(location),
          ),
          'Distancia',
          Colors.purple,
        ),
        _buildStat(
          Icons.attach_money,
          '\$${pricePerHour.toStringAsFixed(0)}',
          'Por hora',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// --- Utilities ---

/// Helper for service categories
class _ServiceCategoryHelper {
  IconData getServiceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'electricidad':
        return Icons.electrical_services;
      case 'plomería':
        return Icons.plumbing;
      case 'limpieza':
        return Icons.cleaning_services;
      case 'carpintería':
        return Icons.carpenter;
      case 'jardinería':
        return Icons.grass;
      case 'pintura':
        return Icons.format_paint;
      default:
        return Icons.home_repair_service;
    }
  }

  String getServiceDisplayName(String? category) {
    switch (category?.toLowerCase()) {
      case 'limpieza':
        return 'Limpieza del Hogar';
      case 'plomería':
        return 'Servicios de Plomería';
      case 'electricidad':
        return 'Instalaciones Eléctricas';
      case 'carpintería':
        return 'Trabajos de Carpintería';
      case 'jardinería':
        return 'Mantenimiento de Jardines';
      case 'pintura':
        return 'Servicios de Pintura';
      default:
        return 'Servicios Generales';
    }
  }

  String getCategoryKey(String? category) {
    return category?.toLowerCase() ?? 'general';
  }
}

/// Helper for distance calculations
class _DistanceCalculator {
  final Map<String, double> _distances = {
    'Centro de Tena': 1.2,
    'El Ceibo': 2.5,
    'Eloy Alfaro': 3.1,
    'San Antonio': 4.0,
    'Los Laureles': 2.8,
    'Tena': 2.0,
    'Archidona': 8.5,
    'Puerto Napo': 12.3,
  };

  double calculateDistance(String? location) {
    return _distances[location] ?? 3.5;
  }

  String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }

  Map<String, double> getLocationDistances() {
    return Map.unmodifiable(_distances);
  }
}

/// Helper for payment methods
class _PaymentMethodHelper {
  String getPaymentMethodName(String? method) {
    switch (method?.toLowerCase()) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      default:
        return 'Por definir';
    }
  }

  IconData getPaymentMethodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

// --- Services ---

/// Service for provider data fetching and filtering
class _ProviderSelectionService {
  final Logger _logger = Logger();

  Stream<List<Map<String, dynamic>>> getProvidersStream(String category) {
    _logger.d('Fetching providers for category: $category');
    _logger.d('Fetching providers for category: $category');
    return Supabase.instance.client
        .from('providers')
        .stream(primaryKey: ['id'])
        .order('rating', ascending: false)
        .map((list) => list.where((p) => p['isActive'] == true).toList());
  }

  List<Map<String, dynamic>> filterProviders(
      List<Map<String, dynamic>> providers, String category) {
    _logger.d('Filtering providers for category: $category');
    return providers.where((doc) {
      final data = doc;
      return data['isActive'] == true;
    }).toList();
  }

  List<Map<String, dynamic>> sortProvidersByRating(
      List<Map<String, dynamic>> providers) {
    _logger.d('Sorting providers by rating');
    final sorted = List<Map<String, dynamic>>.from(providers);
    sorted.sort((a, b) {
      final aData = a;
      final bData = b;
      final aRating = (aData['rating'] ?? 0.0).toDouble();
      final bRating = (bData['rating'] ?? 0.0).toDouble();
      return bRating.compareTo(aRating);
    });
    return sorted;
  }
}

// --- Widgets ---

/// Header widget for the modal
class _ProviderModalHeader extends StatelessWidget {
  final BookingData bookingData;

  const _ProviderModalHeader({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final categoryHelper = _ServiceCategoryHelper();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(153),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              categoryHelper.getServiceIcon(bookingData.serviceCategory),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Confirmar Solicitud de Servicio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona el proveedor especializado en ${categoryHelper.getServiceDisplayName(bookingData.serviceCategory)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(178),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ServiceSummaryCard(bookingData: bookingData),
        ],
      ),
    );
  }
}

/// Card widget to display service summary
class _ServiceSummaryCard extends StatelessWidget {
  final BookingData bookingData;

  const _ServiceSummaryCard({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final categoryHelper = _ServiceCategoryHelper();
    final paymentHelper = _PaymentMethodHelper();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                categoryHelper.getServiceIcon(bookingData.serviceCategory),
                color: Colors.blue[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bookingData.serviceTitle ?? 'Servicio Solicitado',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceDetail(
                'Categoría',
                categoryHelper
                    .getServiceDisplayName(bookingData.serviceCategory),
                Icons.category,
              ),
              _buildServiceDetail(
                'Total',
                '\$${bookingData.finalTotal?.toStringAsFixed(2) ?? '0.00'}',
                Icons.attach_money,
              ),
              _buildServiceDetail(
                'Pago',
                paymentHelper.getPaymentMethodName(bookingData.paymentMethod),
                paymentHelper.getPaymentMethodIcon(bookingData.paymentMethod),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetail(String label, String value, IconData icon) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// List view widget for providers
class _ProviderListView extends StatelessWidget {
  final BookingData bookingData;
  final Function(Map<String, dynamic>) onProviderSelected;
  final VoidCallback onCancel;

  const _ProviderListView({
    required this.bookingData,
    required this.onProviderSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final service = _ProviderSelectionService();
    final categoryHelper = _ServiceCategoryHelper();
    final category = categoryHelper.getCategoryKey(bookingData.serviceCategory);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.getProvidersStream(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue[600]),
                const SizedBox(height: 16),
                Text(
                  'Buscando especialistas en ${categoryHelper.getServiceDisplayName(category)}...',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _ErrorProvidersState(onCancel: onCancel);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _EmptyProvidersState(onCancel: onCancel);
        }

        final providers = service.filterProviders(snapshot.data!, category);
        final sortedProviders = service.sortProvidersByRating(providers);

        return Column(
          children: [
            _ProvidersFilterHeader(providerCount: sortedProviders.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sortedProviders.length,
                itemBuilder: (context, index) {
                  final provider = sortedProviders[index];
                  final data = provider;
                  return _ProviderCardItem(
                    providerId: provider['id'] ?? '',
                    data: data,
                    onTap: (selectionData) =>
                        onProviderSelected(selectionData.toMap()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Card widget for individual provider
class _ProviderCardItem extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> data;
  final Function(ProviderSelectionData) onTap;

  const _ProviderCardItem({
    required this.providerId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue[50],
                        backgroundImage: data['profileImage'] != null
                            ? NetworkImage(data['profileImage'])
                            : null,
                        child: data['profileImage'] == null
                            ? Icon(
                                Icons.person,
                                color: Colors.blue[600],
                                size: 28,
                              )
                            : null,
                      ),
                    ),
                    if (data['isOnline'] == true)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'] ??
                                  data['fullName'] ??
                                  'Proveedor Profesional',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (data['isVerified'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      size: 12, color: Colors.blue[600]),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            double rating = data['rating']?.toDouble() ?? 4.8;
                            if (starIndex < rating.floor()) {
                              return Icon(Icons.star,
                                  size: 14, color: Colors.amber[600]);
                            } else if (starIndex < rating) {
                              return Icon(Icons.star_half,
                                  size: 14, color: Colors.amber[600]);
                            } else {
                              return Icon(Icons.star_border,
                                  size: 14, color: Colors.grey[400]);
                            }
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${(data['rating'] ?? 4.8).toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(${data['totalReviews'] ?? 25} reseñas)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
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
            _ProviderStatsRow(
              stats: ProviderStats(
                completedJobs: data['completedJobs'] ?? 35,
                responseTime: data['responseTime'] ?? '2h',
                location: data['location'] ?? 'Tena',
                pricePerHour: (data['pricePerHour'] ?? 20.0).toDouble(),
                experienceYears: data['experienceYears'] ?? 3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Disponible ahora',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data['experienceYears'] ?? 3} años exp.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onTap(ProviderSelectionData(
                  providerId: providerId,
                  providerName: data['name'] ?? data['fullName'] ?? 'Proveedor',
                  providerData: data,
                  rating: (data['rating'] ?? 4.8).toDouble(),
                  completedJobs: data['completedJobs'] ?? 35,
                  pricePerHour: (data['pricePerHour'] ?? 20.0).toDouble(),
                  responseTime: data['responseTime'] ?? '2 horas',
                  location: data['location'] ?? 'Tena',
                  experienceYears: data['experienceYears'] ?? 3,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Seleccionar este especialista',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row widget for provider statistics
class _ProviderStatsRow extends StatelessWidget {
  final ProviderStats stats;

  const _ProviderStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: stats.toWidget(),
    );
  }
}

/// Error state widget
class _ErrorProvidersState extends StatelessWidget {
  final VoidCallback onCancel;

  const _ErrorProvidersState({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            const Text(
              'Error al cargar proveedores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifica tu conexión a internet e intenta nuevamente',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                try {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/client-home',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  logger.e('🚨 Error de navegación: $e');
                }
                onCancel();
              },
              icon: const Icon(Icons.home, size: 16),
              label: const Text('Volver al inicio',
                  style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class _EmptyProvidersState extends StatelessWidget {
  final VoidCallback onCancel;

  const _EmptyProvidersState({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay especialistas disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'No encontramos proveedores especializados en este momento.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                try {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/client-home',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  logger.e('🚨 Error de navegación: $e');
                }
                onCancel();
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text(
                'Cancelar solicitud',
                style: TextStyle(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer widget with action buttons
class _ModalFooterActions extends StatelessWidget {
  final VoidCallback onCancel;

  const _ModalFooterActions({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  try {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/client-home',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    logger.e('🚨 Error de navegación: $e');
                  }
                  onCancel();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Cancelar Todo',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.green[700], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Elige un proveedor',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter header widget for provider list
class _ProvidersFilterHeader extends StatelessWidget {
  final int providerCount;

  const _ProvidersFilterHeader({required this.providerCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.blue[600],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proveedores Disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                Text(
                  '$providerCount ${providerCount == 1 ? 'proveedor disponible' : 'proveedores disponibles'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 10, color: Colors.green[700]),
                const SizedBox(width: 3),
                Text(
                  'Activos',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Main Modal ---

/// Main modal widget for post-login provider selection
class PostLoginProviderModal extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final Function(Map<String, dynamic>) onProviderSelected;
  final VoidCallback onCancel;

  const PostLoginProviderModal({
    super.key,
    required this.bookingData,
    required this.onProviderSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final booking = BookingData.fromMap(bookingData);
    logger.d(
        'Building PostLoginProviderModal with bookingData: ${booking.toMap()}');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProviderModalHeader(bookingData: booking),
          Expanded(
            child: _ProviderListView(
              bookingData: booking,
              onProviderSelected: onProviderSelected,
              onCancel: onCancel,
            ),
          ),
          _ModalFooterActions(onCancel: onCancel),
        ],
      ),
    );
  }
}
