import 'package:flutter/material.dart';
import '../../../../data/models/service_model.dart';

class ServiceSummaryWidget extends StatelessWidget {
  final ServiceModel serviceData;
  final List<Map<String, dynamic>> selectedOptions;
  
  const ServiceSummaryWidget({
    super.key,
    required this.serviceData,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(),
          if (selectedOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildOptionsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildServiceIcon(
            serviceData.category.value, 
            size: 24
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceData.title,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                serviceData.category.displayName,
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey[600]
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opciones seleccionadas:',
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 8),
        ...selectedOptions.map((option) => _buildOptionItem(option))
      ],
    );
  }

  Widget _buildOptionItem(Map<String, dynamic> option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/analista-de-la-red.png',
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green[600],
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              option['name'] ?? '', 
              style: const TextStyle(fontSize: 14)
            ),
          ),
          Text(
            '+\$${(option['price'] ?? 0.0).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(String? category, {double size = 24}) {
    return Image.asset(
      _getServiceIconPath(category),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _getServiceIcon(category),
          color: Colors.white,
          size: size,
        );
      },
    );
  }

  String _getServiceIconPath(String? category) {
    switch (category?.toLowerCase()) {
      case 'limpieza':
        return 'assets/icons/casa-limpia.png';
      case 'plomería':
        return 'assets/icons/plomero.png';
      case 'electricidad':
        return 'assets/icons/electricista.png';
      case 'carpintería':
        return 'assets/icons/caja-de-herramientas.png';
      case 'jardinería':
        return 'assets/icons/agronomia.png';
      case 'pintura':
        return 'assets/icons/cubo-de-pintura.png';
      default:
        return 'assets/icons/gastos-generales.png';
    }
  }

  IconData _getServiceIcon(String? category) {
    switch (category?.toLowerCase()) {
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
      default:
        return Icons.home_repair_service;
    }
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((255 * 0.05).round()),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}