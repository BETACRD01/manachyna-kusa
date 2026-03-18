import 'package:flutter/material.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _providers = _generateMockProviders();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar proveedores: $e');
      }
    }
  }

  List<Map<String, dynamic>> _generateMockProviders() {
    return List.generate(
        8,
        (index) => {
              'id': 'provider_$index',
              'name': 'Proveedor ${index + 1}',
              'email': 'proveedor${index + 1}@email.com',
              'phone': '+593 9${(8000000 + index).toString()}',
              'joinDate': DateTime.now().subtract(Duration(days: index * 8)),
              'isActive': index % 2 == 0,
              'rating': 4.0 + (index % 5) * 0.2,
              'totalServices': (index * 3) + 5,
              'totalEarnings': (index * 234.67) + 567.89,
              'isApproved': index % 3 != 0, // Algunos pendientes de aprobación
              'services': ['Limpieza', 'Jardinería', 'Plomería'][index % 3],
              'avatar': null,
            });
  }

  List<Map<String, dynamic>> _getFilteredProviders() {
    if (_searchQuery.isEmpty) return _providers;
    return _providers
        .where((provider) =>
            provider['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            provider['email']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

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
        title: Text('Proveedores (${_providers.length})'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProviders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildProvidersList()),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar proveedores...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Todos', true),
          const SizedBox(width: 8),
          _buildFilterChip('Activos', false),
          const SizedBox(width: 8),
          _buildFilterChip('Pendientes', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        //
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green.shade700,
    );
  }

  Widget _buildProvidersList() {
    final filteredProviders = _getFilteredProviders();

    if (filteredProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay proveedores registrados'
                  : 'No se encontraron proveedores',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProviders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProviders.length,
        itemBuilder: (context, index) {
          final provider = filteredProviders[index];
          return _buildProviderCard(provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green.shade100,
          child: Text(
            provider['name'][0].toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          provider['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  provider['isApproved'] ? Icons.verified : Icons.pending,
                  size: 16,
                  color: provider['isApproved'] ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  provider['isApproved'] ? 'Aprobado' : 'Pendiente',
                  style: TextStyle(
                    color:
                        provider['isApproved'] ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  provider['rating'].toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleProviderAction(value, provider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            if (!provider['isApproved'])
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Aprobar'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: provider['isActive'] ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    provider['isActive'] ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(provider['isActive'] ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProviderAction(String action, Map<String, dynamic> provider) {
    switch (action) {
      case 'view':
        _showProviderDetails(provider);
        break;
      case 'approve':
        _approveProvider(provider);
        break;
      case 'activate':
      case 'deactivate':
        _toggleProviderStatus(provider);
        break;
      case 'delete':
        _showDeleteProviderDialog(provider);
        break;
    }
  }

  void _showProviderDetails(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${provider['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Email:', provider['email']),
              _buildDetailRow('Teléfono:', provider['phone']),
              _buildDetailRow('Servicios:', provider['services']),
              _buildDetailRow(
                  'Estado:', provider['isApproved'] ? 'Aprobado' : 'Pendiente'),
              _buildDetailRow(
                  'Calificación:', '${provider['rating'].toStringAsFixed(1)}'),
              _buildDetailRow(
                  'Total servicios:', '${provider['totalServices']}'),
              _buildDetailRow('Total ganado:',
                  '\$${provider['totalEarnings'].toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Fecha registro:', _formatDate(provider['joinDate'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
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

  Future<void> _approveProvider(Map<String, dynamic> provider) async {
    try {
      setState(() {
        provider['isApproved'] = true;
      });
      _showSuccessSnackBar('${provider['name']} ha sido aprobado');
    } catch (e) {
      _showErrorSnackBar('Error al aprobar proveedor: $e');
    }
  }

  Future<void> _toggleProviderStatus(Map<String, dynamic> provider) async {
    try {
      setState(() {
        provider['isActive'] = !provider['isActive'];
      });

      _showSuccessSnackBar(
        '${provider['name']} ha sido ${provider['isActive'] ? 'activado' : 'desactivado'}',
      );
    } catch (e) {
      _showErrorSnackBar('Error al actualizar proveedor: $e');
    }
  }

  void _showDeleteProviderDialog(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text(
          '¿Estás seguro de eliminar a ${provider['name']}?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _deleteProvider(provider),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProvider(Map<String, dynamic> provider) async {
    try {
      Navigator.pop(context); // Cerrar diálogo
      setState(() {
        _providers.removeWhere((p) => p['id'] == provider['id']);
      });

      _showSuccessSnackBar('${provider['name']} ha sido eliminado');
    } catch (e) {
      _showErrorSnackBar('Error al eliminar proveedor: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
