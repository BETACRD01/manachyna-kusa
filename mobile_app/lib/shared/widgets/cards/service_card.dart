// lib/shared/widgets/cards/service_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class ServiceCard extends StatelessWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;
  final bool isCompact;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.serviceId,
    required this.serviceData,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showServiceDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceImage(),
              const SizedBox(height: 8),
              _buildServiceTitle(),
              const SizedBox(height: 4),
              _buildServiceCategory(),
              const SizedBox(height: 8),
              _buildPriceAndRating(),
              if (!isCompact) ...[
                const SizedBox(height: 8),
                _buildProviderInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage() {
    return Container(
      height: isCompact ? 80 : 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: serviceData['imageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                serviceData['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultIcon();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            )
          : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    final category = serviceData['category'] ?? 'General';
    final color = AppColors.getServiceCategoryColor(category);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            color.withAlpha(20),
            color.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          size: isCompact ? 32 : 48,
          color: color,
        ),
      ),
    );
  }

  Widget _buildServiceTitle() {
    return Text(
      serviceData['title'] ?? 'Servicio',
      style: TextStyle(
        fontSize: isCompact ? 14 : 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildServiceCategory() {
    final category = serviceData['category'] ?? 'General';
    final color = AppColors.getServiceCategoryColor(category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceAndRating() {
    final price = serviceData['price']?.toDouble() ?? 0.0;
    final rating = serviceData['rating']?.toDouble() ?? 0.0;
    final totalRatings = serviceData['totalRatings'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.formatMoney(price),
                style: TextStyle(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                '/hora',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (rating > 0) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '($totalRatings)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProviderInfo() {
    final completedJobs = serviceData['completedJobs'] ?? 0;
    final isAvailable = serviceData['isAvailable'] ?? true;
    
    return Column(
      children: [
        const Divider(height: 16),
        Row(
          children: [
            const Icon(
              Icons.work_outline,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$completedJobs trabajos',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAvailable ? 'Disponible' : 'No disponible',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'limpieza':
        return Icons.cleaning_services;
      case 'plomería':
        return Icons.plumbing;
      case 'electricidad':
        return Icons.electrical_services;
      case 'carpintería':
        return Icons.carpenter;
      case 'jardinería':
        return Icons.grass;
      case 'pintura':
        return Icons.format_paint;
      case 'reparaciones':
        return Icons.build;
      case 'instalaciones':
        return Icons.construction;
      case 'mantenimiento':
        return Icons.settings;
      default:
        return Icons.home_repair_service;
    }
  }

  void _showServiceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ServiceDetailsDialog(
        serviceId: serviceId,
        serviceData: serviceData,
      ),
    );
  }
}

class ServiceDetailsDialog extends StatelessWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;

  const ServiceDetailsDialog({
    super.key,
    required this.serviceId,
    required this.serviceData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(
          maxHeight: 200,
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
                    _buildServiceImage(),
                    const SizedBox(height: 16),
                    _buildServiceInfo(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildProviderDetails(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              serviceData['title'] ?? 'Servicio',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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

  Widget _buildServiceImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: serviceData['imageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                serviceData['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultIcon();
                },
              ),
            )
          : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    final category = serviceData['category'] ?? 'General';
    final color = AppColors.getServiceCategoryColor(category);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withAlpha(20),
            color.withAlpha(40),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          size: 64,
          color: color,
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    final price = serviceData['price']?.toDouble() ?? 0.0;
    final rating = serviceData['rating']?.toDouble() ?? 0.0;
    final totalRatings = serviceData['totalRatings'] ?? 0;
    final category = serviceData['category'] ?? 'General';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.attach_money,
                'Precio',
                '${Helpers.formatMoney(price)}/hora',
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                Icons.star,
                'Calificación',
                rating > 0 ? '${rating.toStringAsFixed(1)} ($totalRatings)' : 'Sin calificar',
                Colors.amber[600]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.category,
                'Categoría',
                category,
                AppColors.getServiceCategoryColor(category),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                Icons.work,
                'Trabajos',
                '${serviceData['completedJobs'] ?? 0} completados',
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style:const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = serviceData['description'] ?? 'Sin descripción disponible';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del Proveedor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (serviceData['providerName'] ?? 'P')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceData['providerName'] ?? 'Proveedor',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                       const Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Proveedor verificado',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final isAvailable = serviceData['isAvailable'] ?? true;
    
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
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isAvailable ? () => _requestService(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isAvailable ? 'Solicitar Servicio' : 'No Disponible',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'limpieza':
        return Icons.cleaning_services;
      case 'plomería':
        return Icons.plumbing;
      case 'electricidad':
        return Icons.electrical_services;
      case 'carpintería':
        return Icons.carpenter;
      case 'jardinería':
        return Icons.grass;
      case 'pintura':
        return Icons.format_paint;
      case 'reparaciones':
        return Icons.build;
      case 'instalaciones':
        return Icons.construction;
      case 'mantenimiento':
        return Icons.settings;
      default:
        return Icons.home_repair_service;
    }
  }

  void _requestService(BuildContext context) {
    Navigator.pop(context);
    // Aquí se implementaría la navegación al flujo de reserva
    // Navigator.pushNamed(context, '/booking', arguments: serviceId);
    Helpers.showSuccessSnackBar(
      context,
      'Función de reserva será implementada próximamente',
    );
  }
}