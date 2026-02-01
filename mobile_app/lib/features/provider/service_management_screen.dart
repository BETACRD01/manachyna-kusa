import 'package:flutter_application_manachyna_kusa_2_0/core/extensions/supabase_extensions.dart';
// ========================================
// SISTEMA DE GESTIÓN DE SERVICIOS FLUTTER
// ========================================
// Descripción: Sistema completo para gestión de servicios profesionales
// Autor: Desarrollado para proveedores de servicios en región amazónica
// Funcionalidades: CRUD servicios, filtros, búsqueda, gestión horarios
// ========================================

// ========================================
// IMPORTS Y DEPENDENCIAS
// ========================================
import 'package:flutter/material.dart'; // Framework UI Flutter
import 'package:provider/provider.dart'; // Gestión de estado con Provider
import 'package:supabase_flutter/supabase_flutter.dart'; // Base de datos Firestore
import 'package:image_picker/image_picker.dart'; // Selección de imágenes
import 'dart:io'; // Operaciones de archivos del sistema
import '../../../../providers/auth_provider.dart'; // Proveedor de autenticación personalizado
import '../../../../data/services/database_service.dart'; // Servicio de base de datos personalizado
import 'package:logger/logger.dart'; // Sistema de logging y debugging

// ========================================
// CONFIGURACIÓN GLOBAL
// ========================================
final Logger logger = Logger(); // Instancia global del logger para debugging

// ========================================
// PANTALLA PRINCIPAL - GESTIÓN DE SERVICIOS
// ========================================
// Descripción: Pantalla principal que muestra la lista de servicios del proveedor
// Funcionalidades: Visualizar, buscar, filtrar, editar, eliminar servicios
// ========================================

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  // ========================================
  // VARIABLES DE ESTADO Y CONTROLADORES
  // ========================================

  // Servicios
  final DatabaseService _firestoreService = DatabaseService();
  String? currentProviderId; // ID del proveedor actual autenticado

  // Filtros y búsqueda
  String _searchQuery = ''; // Consulta de búsqueda actual
  String _selectedCategory = 'Todos'; // Categoría seleccionada para filtrar
  String _selectedTimeMode = 'Todos'; // Modalidad de tiempo seleccionada
  bool _showActiveOnly = true; // Mostrar solo servicios activos

  // ========================================
  // CONFIGURACIÓN DE CATEGORÍAS
  // ========================================
  // Lista de categorías de servicios disponibles
  final List<String> _categories = [
    'Todos', // Opción para mostrar todas las categorías
    'Limpieza', // Servicios de limpieza doméstica/comercial
    'Plomería', // Servicios de fontanería y reparaciones
    'Electricidad', // Servicios eléctricos e instalaciones
    'Carpintería', // Trabajos en madera y muebles
    'Jardinería', // Mantenimiento de jardines y paisajismo
    'Pintura', // Servicios de pintura interior/exterior
    'Reparaciones', // Reparaciones generales
    'Instalaciones', // Instalación de equipos y sistemas
    'Mantenimiento', // Servicios de mantenimiento preventivo
  ];

  // ========================================
  // CONFIGURACIÓN DE MODALIDADES DE TIEMPO
  // ========================================
  // Diferentes formas de cobrar por el servicio
  final List<String> _timeModes = [
    'Todos', // Mostrar todas las modalidades
    'Por hora', // Cobro por horas trabajadas (2-8h típico)
    'Por día', // Jornada completa de trabajo
    'Por semana', // Servicio semanal recurrente
    'Por trabajo', // Precio fijo por proyecto completo
    'Por visita' // Precio fijo por cada visita/sesión
  ];

  // ========================================
  // MÉTODOS DE INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();
    _getCurrentProviderId(); // Obtener ID del usuario autenticado
  }

  /// Obtiene el ID del proveedor actual desde el AuthProvider
  void _getCurrentProviderId() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentProviderId = authProvider.currentUser?.uid;
  }

  // ========================================
  // CONSTRUCCIÓN DE LA INTERFAZ PRINCIPAL
  // ========================================

  @override
  Widget build(BuildContext context) {
    // Validar que el usuario esté autenticado
    if (currentProviderId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo gris claro
      appBar: _buildAppBar(), // Barra superior con título y acciones
      body: Column(
        children: [
          _buildHeader(), // Sección de búsqueda y filtros
          Expanded(child: _buildServicesList()), // Lista principal de servicios
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(), // Botón para crear nuevo servicio
    );
  }

  // ========================================
  // COMPONENTE: BARRA SUPERIOR (AppBar)
  // ========================================
  // Descripción: Barra superior con título, botones de estadísticas y notificaciones

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Mis Servicios',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.indigo[600], // Color azul índigo corporativo
      foregroundColor: Colors.white, // Texto blanco para contraste
      elevation: 0, // Sin sombra para diseño moderno
      actions: [
        // Botón de estadísticas/analytics
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: _showServiceAnalytics,
          tooltip: 'Estadísticas',
        ),
        // Botón de notificaciones
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implementar sistema de notificaciones
          },
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: HEADER CON BÚSQUEDA Y FILTROS
  // ========================================
  // Descripción: Sección superior con campo de búsqueda, filtros por categoría,
  // modalidad de tiempo y toggle para servicios activos

  Widget _buildHeader() {
    return Container(
      // Gradiente de fondo desde la AppBar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[600]!, Colors.indigo[700]!],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Campo de búsqueda con diseño moderno
            _buildSearchField(),
            const SizedBox(height: 20),
            // Fila de filtros dropdown
            _buildFiltersRow(),
            const SizedBox(height: 15),
            // Chips de filtro y botón limpiar
            _buildFilterChipsRow(),
          ],
        ),
      ),
    );
  }

  // ========================================
  // COMPONENTE: CAMPO DE BÚSQUEDA
  // ========================================

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar en mis servicios...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase(); // Búsqueda case-insensitive
          });
        },
      ),
    );
  }

  // ========================================
  // COMPONENTE: FILA DE FILTROS DROPDOWN
  // ========================================

  Widget _buildFiltersRow() {
    return Row(
      children: [
        // Filtro por categoría de servicio
        Expanded(
          child: _buildFilterDropdown(
            'Categoría',
            _selectedCategory,
            _categories,
            Icons.category_outlined,
            (value) => setState(() => _selectedCategory = value!),
          ),
        ),
        const SizedBox(width: 12),
        // Filtro por modalidad de tiempo/cobro
        Expanded(
          child: _buildFilterDropdown(
            'Modalidad',
            _selectedTimeMode,
            _timeModes,
            Icons.schedule_outlined,
            (value) => setState(() => _selectedTimeMode = value!),
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: DROPDOWN PERSONALIZADO PARA FILTROS
  // ========================================
  // Descripción: Dropdown reutilizable con diseño consistente
  // Parámetros: label, valor actual, items, icono, callback de cambio

  Widget _buildFilterDropdown(
    String label, // Etiqueta del filtro
    String value, // Valor seleccionado actualmente
    List<String> items, // Lista de opciones disponibles
    IconData icon, // Icono identificativo
    void Function(String?) onChanged, // Función callback al cambiar
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true, // Hace el campo más compacto
        ),
        isExpanded: true, // Permite usar todo el ancho disponible
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis, // Evita overflow en texto largo
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        iconSize: 20,
        menuMaxHeight: 300, // Limita altura del menú dropdown
      ),
    );
  }

  // ========================================
  // COMPONENTE: FILA DE CHIPS Y ACCIONES
  // ========================================

  Widget _buildFilterChipsRow() {
    return Row(
      children: [
        // Chip para toggle de servicios activos/todos
        _buildFilterChip(
          _showActiveOnly ? 'Solo activos' : 'Todos los servicios',
          _showActiveOnly,
          Icons.visibility_outlined,
          (selected) => setState(() => _showActiveOnly = selected),
        ),
        const Spacer(),
        // Botón para limpiar todos los filtros
        TextButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear_all, size: 18),
          label: const Text('Limpiar'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: CHIP DE FILTRO PERSONALIZADO
  // ========================================

  Widget _buildFilterChip(
    String label, // Texto del chip
    bool selected, // Estado seleccionado/no seleccionado
    IconData icon, // Icono del chip
    void Function(bool) onSelected, // Callback al cambiar estado
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.indigo[100], // Color cuando está seleccionado
      checkmarkColor: Colors.indigo[600], // Color del checkmark
      backgroundColor: Colors.grey[100], // Color cuando no está seleccionado
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ========================================
  // COMPONENTE: LISTA PRINCIPAL DE SERVICIOS
  // ========================================
  // Descripción: StreamBuilder que escucha cambios en Firestore y muestra
  // la lista de servicios filtrada del proveedor actual

  Widget _buildServicesList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // Stream que escucha cambios en los servicios del proveedor
      stream: _firestoreService.getProviderServices(currentProviderId!),
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          );
        }

        // Estado de error
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // Estado sin datos o vacío
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Procesar y filtrar los servicios
        final allServices = snapshot.data!;
        final filteredServices = _filterServices(allServices);

        // No hay resultados después del filtrado
        if (filteredServices.isEmpty) {
          return _buildNoResultsState();
        }

        // Construir lista de servicios
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            final data = filteredServices[index];
            // data['id'] is likely already in the service map if fetched correctly,
            // but if service comes from Supabase select it should represent the row.
            // If the map has the id, we use it directly.
            // Assuming service IS the data map.
            return _buildServiceCard(data['id']?.toString() ?? '', data);
          },
        );
      },
    );
  }

  // ========================================
  // LÓGICA DE FILTRADO DE SERVICIOS
  // ========================================
  // Descripción: Aplica todos los filtros activos a la lista de servicios
  // Filtros: búsqueda por texto, categoría, modalidad de tiempo, estado activo

  List<Map<String, dynamic>> _filterServices(
      List<Map<String, dynamic>> services) {
    return services.where((service) {
      final data = service;

      // Filtro por búsqueda de texto (título y descripción)
      if (_searchQuery.isNotEmpty) {
        final title = (data['title'] ?? '').toString().toLowerCase();
        final description =
            (data['description'] ?? '').toString().toLowerCase();
        if (!title.contains(_searchQuery) &&
            !description.contains(_searchQuery)) {
          return false;
        }
      }

      // Filtro por categoría de servicio
      if (_selectedCategory != 'Todos') {
        if (data['category'] != _selectedCategory) {
          return false;
        }
      }

      // Filtro por modalidad de tiempo
      if (_selectedTimeMode != 'Todos') {
        if (data['timeMode'] != _selectedTimeMode) {
          return false;
        }
      }

      // Filtro por estado activo (solo servicios activos o todos)
      if (_showActiveOnly) {
        if (data['isActive'] != true) {
          return false;
        }
      }

      return true; // El servicio pasa todos los filtros
    }).toList();
  }

  // ========================================
  // COMPONENTE: TARJETA DE SERVICIO
  // ========================================
  // Descripción: Tarjeta individual que muestra información completa de un servicio
  // con imagen, datos, métricas, estados y acciones disponibles

  Widget _buildServiceCard(String serviceId, Map<String, dynamic> data) {
    // Extraer datos principales del servicio
    final isActive = data['isActive'] ?? true;
    final timeMode = data['timeMode'] ?? 'Por hora';
    final price = data['price']?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isActive
              ? Colors.indigo.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de imagen con overlays
          if (data['imageUrl'] != null)
            _buildServiceImageSection(data, isActive, timeMode),

          // Sección de contenido principal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceHeader(
                    data, isActive, serviceId), // Título, categoría, estado
                const SizedBox(height: 15),
                _buildServiceDescription(
                    data, isActive), // Descripción del servicio
                const SizedBox(height: 20),
                _buildPriceSection(
                    price, timeMode), // Sección de precio destacada
                const SizedBox(height: 15),
                _buildServiceMetrics(
                    data), // Métricas (rating, trabajos, reseñas)
                const SizedBox(height: 20),
                _buildServiceActions(
                    serviceId, data, isActive), // Botones de acción
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: SECCIÓN DE IMAGEN DEL SERVICIO
  // ========================================

  Widget _buildServiceImageSection(
      Map<String, dynamic> data, bool isActive, String timeMode) {
    return Stack(
      children: [
        // Imagen principal
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(
            data['imageUrl'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
        ),

        // Overlay si el servicio está inactivo
        if (!isActive)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pause_circle_outline,
                      color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'SERVICIO PAUSADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Badge de modalidad de tiempo
        Positioned(
          top: 15,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTimeModeColor(timeMode),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTimeModeIcon(timeMode),
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  timeMode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: HEADER DEL SERVICIO
  // ========================================

  Widget _buildServiceHeader(
      Map<String, dynamic> data, bool isActive, String serviceId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del servicio
              Text(
                data['title'] ?? 'Sin título',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.grey[800] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              // Badge de categoría
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getCategoryColor(data['category'])
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  data['category'] ?? 'Sin categoría',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryColor(data['category']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            // Badge de estado (Activo/Pausado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.pause_circle,
                    size: 16,
                    color: isActive ? Colors.green[600] : Colors.red[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Activo' : 'Pausado',
                    style: TextStyle(
                      color: isActive ? Colors.green[600] : Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Menú de opciones
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (context) => [
                _buildPopupMenuItem('edit', Icons.edit_outlined, 'Editar'),
                if ((data['totalRatings'] ?? 0) > 0) ...[
                  _buildPopupMenuItem(
                      'ratings', Icons.star_outline, 'Ver reseñas'),
                  _buildPopupMenuItem(
                      'analytics', Icons.analytics_outlined, 'Análisis'),
                ],
                _buildPopupMenuItem(
                  'toggle',
                  isActive ? Icons.pause_outlined : Icons.play_arrow_outlined,
                  isActive ? 'Pausar' : 'Activar',
                ),
                _buildPopupMenuItem(
                    'duplicate', Icons.copy_outlined, 'Duplicar'),
                _buildPopupMenuItem('delete', Icons.delete_outline, 'Eliminar',
                    isDestructive: true),
              ],
              onSelected: (value) => _handleMenuAction(value, serviceId, data),
            ),
          ],
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: DESCRIPCIÓN DEL SERVICIO
  // ========================================

  Widget _buildServiceDescription(Map<String, dynamic> data, bool isActive) {
    return Text(
      data['description'] ?? 'Sin descripción',
      style: TextStyle(
        color: isActive ? Colors.grey[600] : Colors.grey[400],
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ========================================
  // COMPONENTE: SECCIÓN DE PRECIO DESTACADA
  // ========================================

  Widget _buildPriceSection(double price, String timeMode) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.indigo[600], size: 24),
          const SizedBox(width: 8),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          Text(
            ' ${_getTimeModeText(timeMode)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.indigo[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeMode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: MÉTRICAS DEL SERVICIO
  // ========================================

  Widget _buildServiceMetrics(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            Icons.star_outline,
            '${data['rating']?.toStringAsFixed(1) ?? '0.0'}',
            'Calificación',
            Colors.amber[600]!,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            Icons.work_outline,
            '${data['completedJobs'] ?? 0}',
            'Trabajos',
            Colors.blue[600]!,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            Icons.reviews_outlined,
            '${data['totalRatings'] ?? 0}',
            'Reseñas',
            Colors.purple[600]!,
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: ITEM DE MÉTRICA INDIVIDUAL
  // ========================================

  Widget _buildMetricItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: ACCIONES DEL SERVICIO
  // ========================================

  Widget _buildServiceActions(
      String serviceId, Map<String, dynamic> data, bool isActive) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editService(serviceId, data),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.indigo[300]!),
              foregroundColor: Colors.indigo[600],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleServiceStatus(serviceId, data),
            icon: Icon(
              isActive ? Icons.pause_outlined : Icons.play_arrow_outlined,
              size: 18,
            ),
            label: Text(isActive ? 'Pausar' : 'Activar'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isActive ? Colors.orange[500] : Colors.green[500],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // COMPONENTE: ITEM DEL MENÚ POPUP
  // ========================================

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red[600] : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red[600] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTES: ESTADOS ESPECIALES DE LA LISTA
  // ========================================

  /// Estado cuando no hay servicios creados (primera vez)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center_outlined,
                size: 80,
                color: Colors.indigo[300],
              ),
            ),
            const SizedBox(height: 30),

            // Título motivacional
            const Text(
              '¡Comienza a ofrecer tus servicios!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción
            Text(
              'Crea tu primer servicio y conecta con clientes que necesitan tu experiencia profesional.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Botón de acción principal
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateService(),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Crear mi primer servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Sección de consejos
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue[600], size: 30),
                  const SizedBox(height: 12),
                  Text(
                    'Consejos para empezar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Usa fotos profesionales de alta calidad\n'
                    '• Describe claramente qué incluye tu servicio\n'
                    '• Define precios competitivos para tu zona\n'
                    '• Menciona tu experiencia y certificaciones\n'
                    '• Elige la modalidad de tiempo que prefieras',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado cuando los filtros no devuelven resultados
  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'No se encontraron servicios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpiar filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de error en la conexión o carga de datos
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Error al cargar servicios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() {}), // Recargar la vista
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // COMPONENTE: BOTÓN FLOTANTE
  // ========================================

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateService(),
      backgroundColor: Colors.indigo[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text(
        'Nuevo Servicio',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES PARA MODALIDADES DE TIEMPO
  // ========================================

  /// Obtiene el color asociado a cada modalidad de tiempo
  Color _getTimeModeColor(String timeMode) {
    switch (timeMode) {
      case 'Por hora':
        return Colors.blue[600]!; // Azul para trabajo por horas
      case 'Por día':
        return Colors.green[600]!; // Verde para días completos
      case 'Por semana':
        return Colors.purple[600]!; // Púrpura para semanal
      case 'Por trabajo':
        return Colors.orange[600]!; // Naranja para proyectos
      case 'Por visita':
        return Colors.teal[600]!; // Teal para visitas
      default:
        return Colors.grey[600]!; // Gris por defecto
    }
  }

  /// Obtiene el icono representativo de cada modalidad
  IconData _getTimeModeIcon(String timeMode) {
    switch (timeMode) {
      case 'Por hora':
        return Icons.schedule; // Reloj para horas
      case 'Por día':
        return Icons.today; // Calendario para días
      case 'Por semana':
        return Icons.date_range; // Rango para semanas
      case 'Por trabajo':
        return Icons.work; // Maletín para trabajos
      case 'Por visita':
        return Icons.location_on; // Ubicación para visitas
      default:
        return Icons.help; // Ayuda por defecto
    }
  }

  /// Convierte modalidad a sufijo de precio para mostrar
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

  /// Obtiene color distintivo para cada categoría de servicio
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'limpieza':
        return Colors.blue[600]!; // Azul para limpieza
      case 'plomería':
        return Colors.cyan[600]!; // Cyan para plomería
      case 'electricidad':
        return Colors.amber[600]!; // Amarillo para electricidad
      case 'carpintería':
        return Colors.brown[600]!; // Café para carpintería
      case 'jardinería':
        return Colors.green[600]!; // Verde para jardinería
      case 'pintura':
        return Colors.purple[600]!; // Púrpura para pintura
      case 'reparaciones':
        return Colors.orange[600]!; // Naranja para reparaciones
      case 'instalaciones':
        return Colors.indigo[600]!; // Índigo para instalaciones
      case 'mantenimiento':
        return Colors.teal[600]!; // Teal para mantenimiento
      default:
        return Colors.grey[600]!; // Gris por defecto
    }
  }

  // ========================================
  // MÉTODOS DE GESTIÓN DE FILTROS
  // ========================================

  /// Limpia todos los filtros y vuelve al estado inicial
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'Todos';
      _selectedTimeMode = 'Todos';
      _showActiveOnly = true;
    });
  }

  // ========================================
  // MANEJADORES DE ACCIONES DEL MENÚ
  // ========================================

  /// Distribuye las acciones del menú popup a sus métodos correspondientes
  void _handleMenuAction(
      String action, String serviceId, Map<String, dynamic> data) {
    switch (action) {
      case 'edit':
        _editService(serviceId, data);
        break;
      case 'ratings':
        _showServiceRatings(data);
        break;
      case 'analytics':
        _showRatingAnalytics(data);
        break;
      case 'toggle':
        _toggleServiceStatus(serviceId, data);
        break;
      case 'duplicate':
        _duplicateService(data);
        break;
      case 'delete':
        _deleteService(serviceId, data);
        break;
    }
  }

  // ========================================
  // MÉTODOS DE NAVEGACIÓN Y ACCIONES
  // ========================================

  /// Navega a la pantalla de creación de nuevo servicio
  void _navigateToCreateService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateServiceScreen(providerId: currentProviderId!),
      ),
    );
  }

  /// Navega a la pantalla de edición con datos existentes
  void _editService(String serviceId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateServiceScreen(
          providerId: currentProviderId!,
          serviceId: serviceId,
          existingData: data,
        ),
      ),
    );
  }

  /// Cambia el estado activo/pausado del servicio
  Future<void> _toggleServiceStatus(
      String serviceId, Map<String, dynamic> data) async {
    try {
      final newStatus = !(data['isActive'] ?? true);
      await _firestoreService.updateServiceStatus(serviceId, newStatus);
      _showSnackBar(
        newStatus ? 'Servicio activado exitosamente' : 'Servicio pausado',
        newStatus ? Colors.green : Colors.orange,
      );
    } catch (e) {
      _showSnackBar('Error al actualizar servicio: $e', Colors.red);
    }
  }

  /// Crea una copia del servicio para duplicar
  void _duplicateService(Map<String, dynamic> data) {
    final duplicatedData = Map<String, dynamic>.from(data);
    duplicatedData['title'] = '${data['title']} (Copia)';
    // Remover datos específicos que no deben duplicarse
    duplicatedData.remove('createdAt');
    duplicatedData.remove('rating');
    duplicatedData.remove('totalRatings');
    duplicatedData.remove('completedJobs');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateServiceScreen(
          providerId: currentProviderId!,
          existingData: duplicatedData,
        ),
      ),
    );
  }

  /// Muestra diálogo de confirmación antes de eliminar servicio
  void _deleteService(String serviceId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text('¡Eliminar Servicio!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vas a eliminar permanentemente:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Información del servicio a eliminar
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['title'] ?? 'Servicio'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((data['price'] ?? 0) as num).toStringAsFixed(2)} ${_getTimeModeText(data['timeMode'] ?? 'Por hora')}',
                  ),
                  Text(
                      '${data['rating']?.toStringAsFixed(1) ?? '0.0'} (${data['totalRatings'] ?? 0} reseñas)'),
                  Text('${data['completedJobs'] ?? 0} trabajos completados'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Advertencias sobre la eliminación
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta acción:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text('• NO se puede deshacer'),
                  Text('• Eliminará todas las reservas asociadas'),
                  Text('• Perderás el historial y reseñas'),
                  Text('• Los clientes no podrán encontrar tu servicio'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDeleteService(serviceId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sí, eliminar permanentemente'),
          ),
        ],
      ),
    );
  }

  /// Ejecuta la eliminación del servicio después de confirmar
  Future<void> _confirmDeleteService(String serviceId) async {
    Navigator.pop(context);
    try {
      // Mostrar loading durante eliminación
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Eliminando servicio...'),
            ],
          ),
        ),
      );

      await _firestoreService.deleteService(serviceId);
      if (mounted) Navigator.pop(context);
      _showSnackBar('Servicio eliminado permanentemente', Colors.red);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Error al eliminar servicio: $e', Colors.red);
    }
  }

  // ========================================
  // MÉTODOS DE ANÁLISIS Y ESTADÍSTICAS
  // ========================================

  /// Muestra estadísticas generales de todos los servicios
  void _showServiceAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Estadísticas de Servicios'),
        content: const Text('Función de analytics próximamente...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra reseñas específicas de un servicio
  void _showServiceRatings(Map<String, dynamic> data) {
    // TODO: Implementar vista detallada de reseñas
    _showSnackBar('Vista de reseñas próximamente', Colors.blue);
  }

  /// Muestra análisis detallado de calificaciones
  void _showRatingAnalytics(Map<String, dynamic> data) {
    // TODO: Implementar análisis de tendencias de calificaciones
    _showSnackBar('Análisis de calificaciones próximamente', Colors.purple);
  }

  // ========================================
  // MÉTODO AUXILIAR PARA NOTIFICACIONES
  // ========================================

  /// Muestra SnackBar con mensaje y color personalizados
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ========================================
// PANTALLA DE CREACIÓN/EDICIÓN DE SERVICIOS
// ========================================
// Descripción: Pantalla completa para crear nuevos servicios o editar existentes
// Funcionalidades: Formulario con pestañas, selección de categorías, configuración
// de precios, horarios de disponibilidad, vista previa del cliente
// ========================================

class CreateServiceScreen extends StatefulWidget {
  final String providerId; // ID del proveedor que crea/edita el servicio
  final String?
      serviceId; // ID del servicio (null para nuevo, valor para editar)
  final Map<String, dynamic>? existingData; // Datos existentes para edición

  const CreateServiceScreen({
    super.key,
    required this.providerId,
    this.serviceId,
    this.existingData,
  });

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen>
    with SingleTickerProviderStateMixin {
  // ========================================
  // CONTROLADORES Y GESTIÓN DE ESTADO
  // ========================================

  late TabController _tabController; // Controlador para las pestañas
  final _formKey =
      GlobalKey<FormState>(); // Llave para validación del formulario

  // Controladores de texto para los campos del formulario
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '5.00');

  // Servicios
  final DatabaseService _firestoreService = DatabaseService();

  // Estado de la imagen
  File? _selectedImage; // Imagen seleccionada localmente
  bool _isLoading = false; // Estado de carga durante operaciones
  String? _currentImageUrl; // URL de imagen existente (para edición)

  // Configuración del servicio
  String _selectedCategory = 'Limpieza'; // Categoría seleccionada
  String _selectedTimeMode = 'Por hora'; // Modalidad de tiempo/cobro
  bool _isActive = true; // Estado activo/pausado

  // ========================================
  // CONFIGURACIÓN DE HORARIOS SEMANALES
  // ========================================
  // Estructura para manejar disponibilidad por día de la semana

  final Map<String, Map<String, dynamic>> _dailyHours = {
    'Lunes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
    'Martes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
    'Miércoles': {'isActive': true, 'start': '08:00', 'end': '18:00'},
    'Jueves': {'isActive': true, 'start': '08:00', 'end': '18:00'},
    'Viernes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
    'Sábado': {'isActive': false, 'start': '09:00', 'end': '15:00'},
    'Domingo': {'isActive': false, 'start': '00:00', 'end': '00:00'},
  };

  // ========================================
  // CONFIGURACIÓN DE CATEGORÍAS CON METADATOS
  // ========================================
  // Lista completa de categorías con información visual y descriptiva

  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'value': 'Limpieza',
      'label': 'Limpieza',
      'description':
          'Servicios de limpieza por horas, días completos y mantenimiento',
      'icon': Icons.cleaning_services_outlined,
      'color': Colors.blue,
    },
    {
      'value': 'Plomería',
      'label': 'Plomería',
      'description': 'Reparaciones, instalaciones y emergencias 24/7',
      'icon': Icons.plumbing_outlined,
      'color': Colors.cyan,
    },
    {
      'value': 'Electricidad',
      'label': 'Electricidad',
      'description': 'Instalaciones eléctricas, reparaciones y mantenimiento',
      'icon': Icons.electrical_services_outlined,
      'color': Colors.amber,
    },
    {
      'value': 'Carpintería',
      'label': 'Carpintería',
      'description': 'Trabajos en madera, muebles a medida y reparaciones',
      'icon': Icons.carpenter_outlined,
      'color': Colors.brown,
    },
    {
      'value': 'Jardinería',
      'label': 'Jardinería',
      'description': 'Mantenimiento de jardines, diseño paisajístico',
      'icon': Icons.local_florist_outlined,
      'color': Colors.green,
    },
    {
      'value': 'Pintura',
      'label': 'Pintura',
      'description': 'Pintura de interiores, exteriores y trabajos decorativos',
      'icon': Icons.format_paint_outlined,
      'color': Colors.purple,
    },
    {
      'value': 'Reparaciones',
      'label': 'Reparaciones',
      'description': 'Reparación de electrodomésticos, muebles y más',
      'icon': Icons.build_outlined,
      'color': Colors.orange,
    },
    {
      'value': 'Instalaciones',
      'label': 'Instalaciones',
      'description': 'Instalación de equipos, muebles y sistemas',
      'icon': Icons.settings_input_component_outlined,
      'color': Colors.indigo,
    },
    {
      'value': 'Mantenimiento',
      'label': 'Mantenimiento',
      'description': 'Servicios de mantenimiento preventivo y correctivo',
      'icon': Icons.handyman_outlined,
      'color': Colors.teal,
    },
    {
      'value': 'Otro',
      'label': 'Otro',
      'description': 'Cualquier otro servicio no listado',
      'icon': Icons.more_horiz_outlined,
      'color': Colors.grey,
    },
  ];

  // ========================================
  // CONFIGURACIÓN DE MODALIDADES DE TIEMPO
  // ========================================
  // Diferentes formas de estructurar precios con información contextual

  final List<Map<String, dynamic>> _timeModesOptions = [
    {
      'value': 'Por hora',
      'label': 'Por horas (2-8h)',
      'description': 'Limpieza por horas',
      'icon': Icons.schedule,
      'color': Colors.blue,
      'recommendedRange': '\$5 - \$6/hora',
    },
    {
      'value': 'Por día',
      'label': 'Días completos',
      'description': 'Jornada completa',
      'icon': Icons.calendar_today,
      'color': Colors.green,
      'recommendedRange': '\$30 - \$35/día',
    },
    {
      'value': 'Por semana',
      'label': 'Recurrente semanal',
      'description': 'Servicio semanal',
      'icon': Icons.calendar_view_week,
      'color': Colors.purple,
      'recommendedRange': '\$120 - \$150/semana',
    },
    {
      'value': 'Por trabajo',
      'label': 'Por trabajo',
      'description': 'Precio fijo por trabajo completo',
      'icon': Icons.work,
      'color': Colors.orange,
      'recommendedRange': 'Según complejidad del trabajo',
    },
    {
      'value': 'Por visita',
      'label': 'Por visita',
      'description': 'Precio fijo por cada visita',
      'icon': Icons.location_on,
      'color': Colors.teal,
      'recommendedRange': '\$15 - \$40/visita',
    },
  ];

  // ========================================
  // MÉTODOS DE INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 pestañas
    if (widget.existingData != null) {
      _loadExistingData(); // Cargar datos si es edición
    }
  }

  /// Carga los datos existentes para modo edición
  void _loadExistingData() {
    final data = widget.existingData!;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _priceController.text = data['price']?.toString() ?? '5.00';
    _selectedCategory = data['category'] ?? 'Limpieza';
    _selectedTimeMode = data['timeMode'] ?? 'Por hora';
    _isActive = data['isActive'] ?? true;
    _currentImageUrl = data['imageUrl'];

    // Cargar horarios existentes si están disponibles
    if (data['workHours'] is Map) {
      (data['workHours'] as Map).forEach((key, value) {
        if (_dailyHours.containsKey(key)) {
          _dailyHours[key] = {
            'isActive': value['isActive'] ?? false,
            'start': value['start'] ?? '00:00',
            'end': value['end'] ?? '00:00',
          };
        }
      });
    }
  }

  // ========================================
  // CONSTRUCCIÓN DE LA INTERFAZ PRINCIPAL
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.serviceId == null ? 'Crear Servicio' : 'Editar Servicio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(), // Header informativo
          _buildTabBar(), // Barra de pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategorySelectionTab(), // Pestaña 1: Categoría y datos básicos
                _buildPriceConfigurationTab(), // Pestaña 2: Configuración de precios
                _buildHoursConfigurationTab(), // Pestaña 3: Horarios de disponibilidad
                _buildPreviewTab(), // Pestaña 4: Vista previa para clientes
              ],
            ),
          ),
          _buildBottomBar(), // Barra inferior con botones de acción
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: HEADER INFORMATIVO
  // ========================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo[600],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceId == null
                      ? 'Nuevo Servicio'
                      : 'Editar Servicio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa la información de tu servicio profesional',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: BARRA DE PESTAÑAS
  // ========================================

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.green[100],
        ),
        labelColor: Colors.green[700],
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: const [
          Tab(text: 'Categoría'), // Pestaña para categoría y datos básicos
          Tab(text: 'Precios'), // Pestaña para configuración de precios
          Tab(text: 'Horarios'), // Pestaña para horarios de trabajo
          Tab(text: 'Vista Previa'), // Pestaña para preview del cliente
        ],
      ),
    );
  }

  // ========================================
  // PESTAÑA 1: SELECCIÓN DE CATEGORÍA Y DATOS BÁSICOS
  // ========================================

  Widget _buildCategorySelectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          _buildSectionHeader(
              Icons.category_outlined,
              'Seleccione su Categoría de Servicio',
              'Elija la categoría principal de servicios que ofrece en la región amazónica'),
          const SizedBox(height: 20),

          // Grid de categorías
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: _serviceCategories.length,
            itemBuilder: (context, index) {
              final category = _serviceCategories[index];
              return _buildCategoryCard(category);
            },
          ),
          const SizedBox(height: 20),

          // Campo de título del servicio
          _buildFormField(
            controller: _titleController,
            label: 'Título del servicio',
            hint: 'Ej: Limpieza profesional de hogares',
            icon: Icons.title,
            validator: (value) {
              if (value?.trim().isEmpty == true) return 'Campo requerido';
              if (value!.length < 5) return 'Mínimo 5 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de descripción
          _buildFormField(
            controller: _descriptionController,
            label: 'Descripción del servicio',
            hint: 'Describe tu servicio, experiencia y qué incluye...',
            icon: Icons.description,
            maxLines: 4,
            validator: (value) {
              if (value?.trim().isEmpty == true) return 'Campo requerido';
              if (value!.length < 20) return 'Mínimo 20 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Selector de imagen
          _buildImageSelector(),
          const SizedBox(height: 20),

          // Toggle de estado activo (solo para edición)
          if (widget.serviceId != null) _buildActiveToggle(),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: TARJETA DE CATEGORÍA
  // ========================================

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['value'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['value'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? category['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? category['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? category['color'].withOpacity(0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'],
              size: 40,
              color: isSelected ? category['color'] : Colors.grey[600],
            ),
            const SizedBox(height: 10),
            Text(
              category['label'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? category['color'] : Colors.grey[800],
              ),
            ),
            Text(
              category['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? category['color'].withOpacity(0.8)
                    : Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // PESTAÑA 2: CONFIGURACIÓN DE PRECIOS
  // ========================================

  Widget _buildPriceConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey, // Usar la misma llave del formulario para validación
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                Icons.attach_money_outlined,
                'Configuración de Precios - $_selectedCategory',
                'Configure sus precios según los rangos recomendados para la región amazónica'),
            const SizedBox(height: 20),

            // Lista de opciones de modalidades de tiempo
            ..._timeModesOptions.map((mode) {
              final isSelected = _selectedTimeMode == mode['value'];
              return _buildPricingOptionCard(mode, isSelected);
            }),

            const SizedBox(height: 30),

            // Campo de precio específico
            _buildPriceField(),
          ],
        ),
      ),
    );
  }

  // ========================================
  // COMPONENTE: TARJETA DE OPCIÓN DE PRECIO
  // ========================================

  Widget _buildPricingOptionCard(Map<String, dynamic> mode, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeMode = mode['value'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? mode['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? mode['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? mode['color'].withOpacity(0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: mode['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(mode['icon'], color: mode['color'], size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? mode['color'] : Colors.grey[800],
                    ),
                  ),
                  Text(
                    mode['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? mode['color'].withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mode['recommendedRange'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected ? mode['color'] : Colors.grey[700],
                  ),
                ),
                Switch(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeMode = mode['value'];
                    });
                  },
                  activeTrackColor: mode['color'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // PESTAÑA 3: CONFIGURACIÓN DE HORARIOS
  // ========================================

  Widget _buildHoursConfigurationTab() {
    final activeDaysCount =
        _dailyHours.values.where((day) => day['isActive'] == true).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.calendar_today_outlined,
              'Horarios de Disponibilidad',
              'Configure sus horarios de trabajo para cada día de la semana'),
          const SizedBox(height: 10),

          // Contador de días activos
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeDaysCount días activos',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lista de días de la semana
          ..._dailyHours.keys.map((day) {
            return _buildDailyHoursCard(day, _dailyHours[day]!);
          }),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: TARJETA DE HORARIO DIARIO
  // ========================================

  Widget _buildDailyHoursCard(String day, Map<String, dynamic> hours) {
    final isActive = hours['isActive'] ?? false;
    final startTime = hours['start'] ?? '00:00';
    final endTime = hours['end'] ?? '00:00';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? Colors.green[300]! : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      day.substring(0, 3).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isActive ? Colors.grey[800] : Colors.grey[500],
                        ),
                      ),
                      Text(
                        isActive ? '$startTime - $endTime' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    _dailyHours[day]!['isActive'] = value;
                    if (!value) {
                      _dailyHours[day]!['start'] = '00:00';
                      _dailyHours[day]!['end'] = '00:00';
                    }
                  });
                },
                activeTrackColor: Colors.green[600],
              ),
            ],
          ),

          // Selectores de tiempo (solo si está activo)
          if (isActive) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerField(
                    label: 'Hora de Inicio',
                    icon: Icons.access_time,
                    time: startTime,
                    onTap: () => _selectTime(context, day, true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTimePickerField(
                    label: 'Hora de Fin',
                    icon: Icons.access_time,
                    time: endTime,
                    onTap: () => _selectTime(context, day, false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTE: CAMPO SELECTOR DE TIEMPO
  // ========================================

  Widget _buildTimePickerField({
    required String label,
    required IconData icon,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // MÉTODO: SELECTOR DE TIEMPO
  // ========================================

  /// Muestra el selector de tiempo nativo para configurar horarios
  Future<void> _selectTime(
      BuildContext context, String day, bool isStartTime) async {
    final initialTime = TimeOfDay.fromDateTime(
      DateTime.parse(
          '2023-01-01 ${isStartTime ? _dailyHours[day]!['start'] : _dailyHours[day]!['end']}:00'),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStartTime) {
          _dailyHours[day]!['start'] = formattedTime;
        } else {
          _dailyHours[day]!['end'] = formattedTime;
        }
      });
    }
  }

  // ========================================
  // PESTAÑA 4: VISTA PREVIA PARA CLIENTES
  // ========================================

  Widget _buildPreviewTab() {
    final selectedCategoryData = _serviceCategories.firstWhere(
      (cat) => cat['value'] == _selectedCategory,
      orElse: () => _serviceCategories[0],
    );

    final activeHours = _dailyHours.entries
        .where((entry) => entry.value['isActive'] == true)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.visibility_outlined,
              'Vista Previa para Clientes',
              'Así verán los clientes su perfil de servicio'),
          const SizedBox(height: 20),

          // Simulación de vista del cliente
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del perfil simulado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(selectedCategoryData['icon'],
                              color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _titleController.text.isEmpty
                                  ? 'Título del Servicio'
                                  : _titleController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  '4.8 (127 reseñas)', // Rating placeholder
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Tena/Napo - Región Amazónica',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenido del perfil simulado
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horarios de Atención',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Mostrar horarios activos o mensaje si no hay
                      if (activeHours.isEmpty)
                        Text(
                          'No hay horarios configurados.',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
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

                      const SizedBox(height: 20),

                      // Botones de acción simulados
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_outlined, size: 18),
                              label: const Text('Contactar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.calendar_month_outlined,
                                  size: 18),
                              label: const Text('Agendar Cita'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.green[300]!),
                                foregroundColor: Colors.green[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Servicio Especializado en la Región Amazónica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _descriptionController.text.isEmpty
                            ? 'Descripción detallada de su servicio, experiencia y lo que lo hace único en la región. '
                                'Precios adaptados a la economía local de Tena/Napo. Conocimiento especializado en las '
                                'necesidades de la comunidad amazónica.'
                            : _descriptionController.text,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENTES AUXILIARES REUTILIZABLES
  // ========================================

  /// Header de sección con icono, título y descripción
  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de formulario reutilizable con validación
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.indigo[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  /// Campo específico para precio con validaciones especializadas
  Widget _buildPriceField() {
    final selectedMode = _timeModesOptions.firstWhere(
      (mode) => mode['value'] == _selectedTimeMode,
      orElse: () => _timeModesOptions[0],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Precio ${_getTimeModeText(_selectedTimeMode)}',
          hintText: 'Ingresa tu precio',
          prefixIcon: Icon(Icons.attach_money, color: Colors.indigo[600]),
          suffixText: _getTimeModeText(_selectedTimeMode),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          helperText: selectedMode['recommendedRange'],
        ),
        validator: (value) {
          if (value?.trim().isEmpty == true) return 'Campo requerido';
          final price = double.tryParse(value!);
          if (price == null) return 'Precio inválido';
          if (price < 1) return 'Precio mínimo: \$1.00';
          if (price > 500) return 'Precio máximo: \$500.00';
          return null;
        },
      ),
    );
  }

  // ========================================
  // COMPONENTE: SELECTOR DE IMAGEN
  // ========================================

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del servicio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Una buena foto aumenta las posibilidades de ser contratado',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: Colors.grey[300]!, style: BorderStyle.solid),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            Image.network(_currentImageUrl!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Agregar foto del servicio',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca para seleccionar desde galería o cámara',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  /// Toggle para activar/desactivar servicio (solo en edición)
  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: const Text(
          'Servicio activo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _isActive
              ? 'Los clientes pueden ver y contratar tu servicio'
              : 'Servicio pausado - no visible para clientes',
        ),
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeThumbColor: Colors.green[600],
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ========================================
  // COMPONENTE: BARRA INFERIOR CON BOTONES DE ACCIÓN
  // ========================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón cancelar (solo en edición)
          if (widget.serviceId != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 15),
          ],
          // Botón principal de acción
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveService,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(widget.serviceId == null
                      ? Icons.add_circle_outline
                      : Icons.save_outlined),
              label: Text(
                widget.serviceId == null ? 'Crear Servicio' : 'Guardar Cambios',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES PARA MODALIDADES DE TIEMPO
  // ========================================

  /// Convierte modalidad a sufijo de precio para mostrar
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

  // ========================================
  // MÉTODOS DE GESTIÓN DE IMÁGENES
  // ========================================

  /// Muestra opciones para seleccionar imagen (cámara o galería)
  Future<void> _pickImage() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Seleccionar imagen'),
          content: const Text('¿Desde dónde quieres seleccionar la imagen?'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Error al seleccionar imagen: $e', Colors.red);
    }
  }

  /// Obtiene imagen desde la fuente seleccionada (cámara o galería)
  Future<void> _getImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024, // Máximo ancho para optimizar
        maxHeight: 768, // Máximo alto para optimizar
        imageQuality: 85, // Calidad de compresión
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error al obtener imagen: $e', Colors.red);
    }
  }

  /// Sube imagen a Supabase Storage y retorna la URL
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      final String fileName =
          'services/${widget.providerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage.from('services').upload(
            fileName,
            _selectedImage!,
            fileOptions: const FileOptions(upsert: true),
          );

      return Supabase.instance.client.storage
          .from('services')
          .getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // ========================================
  // MÉTODO PRINCIPAL: GUARDAR SERVICIO
  // ========================================

  /// Guarda o actualiza el servicio en Firestore
  Future<void> _saveService() async {
    try {
      // Validar formulario
      if (!_formKey.currentState!.validate()) {
        _showSnackBar(
            'Por favor completa todos los campos requeridos', Colors.red);
        return;
      }

      // Validaciones adicionales para prevenir errores
      if (_titleController.text.trim().isEmpty) {
        _showSnackBar('El título es requerido', Colors.red);
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _showSnackBar('La descripción es requerida', Colors.red);
        return;
      }

      if (_selectedCategory.isEmpty) {
        _showSnackBar('Selecciona una categoría', Colors.red);
        return;
      }

      if (_selectedTimeMode.isEmpty) {
        _showSnackBar('Selecciona una modalidad de tiempo', Colors.red);
        return;
      }

      // Validar precio
      double? price;
      try {
        price = double.parse(_priceController.text.trim());
        if (price <= 0) {
          _showSnackBar('El precio debe ser mayor a 0', Colors.red);
          return;
        }
      } catch (e) {
        _showSnackBar('Ingresa un precio válido', Colors.red);
        return;
      }

      // Validar providerId
      if (widget.providerId.isEmpty) {
        _showSnackBar('Error: ID de proveedor no válido', Colors.red);
        return;
      }

      setState(() => _isLoading = true);

      String? imageUrl = _currentImageUrl;

      // Subir nueva imagen si se seleccionó una
      if (_selectedImage != null) {
        try {
          imageUrl = await _uploadImage();
          if (imageUrl == null || imageUrl.isEmpty) {
            throw Exception('Error al subir la imagen');
          }
        } catch (e) {
          _showSnackBar('Error al subir imagen: ${e.toString()}', Colors.red);
          return;
        }
      }

      // Preparar datos del servicio con validaciones null safety
      final serviceData = <String, dynamic>{
        'providerId': widget.providerId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'timeMode': _selectedTimeMode,
        'price': price,
        'isActive': _isActive,
        'imageUrl': imageUrl ?? '', // String vacío si es null
        'workHours': _dailyHours, // Map de horarios

        // Valores seguros desde existingData
        'rating': _getSafeDouble(widget.existingData?['rating'], 0.0),
        'totalRatings': _getSafeInt(widget.existingData?['totalRatings'], 0),
        'completedJobs': _getSafeInt(widget.existingData?['completedJobs'], 0),
        'location': 'Tena, Napo',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Validar que _firestoreService esté inicializado
      // Esta validación se mantiene por seguridad aunque no debería ser null

      if (widget.serviceId == null) {
        // Crear nuevo servicio
        serviceData['createdAt'] = DateTime.now().toIso8601String();
        await _firestoreService.createService(serviceData);
        _showSnackBar('¡Servicio creado exitosamente!', Colors.green);
      } else {
        // Actualizar servicio existente - widget.serviceId no puede ser null aquí
        await _firestoreService.updateService(widget.serviceId!, serviceData);
        _showSnackBar('¡Servicio actualizado exitosamente!', Colors.green);
      }

      // Navegar solo si el widget sigue montado
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Log detallado del error para debugging
      debugPrint('Error en _saveService: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');

      // Mensaje de error más específico
      String errorMessage = 'Error desconocido';
      if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Error de permisos. Intenta nuevamente.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.';
      } else {
        errorMessage = 'Error al guardar: ${e.toString()}';
      }

      if (mounted) {
        _showSnackBar(errorMessage, Colors.red);
      }
    } finally {
      // Asegurar que _isLoading se resetee siempre
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// Métodos auxiliares para manejo seguro de tipos
  double _getSafeDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  int _getSafeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  // ========================================
  // MÉTODO AUXILIAR PARA NOTIFICACIONES
  // ========================================

  /// Muestra SnackBar con mensaje y color personalizados
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ========================================
  // LIMPIEZA DE RECURSOS
  // ========================================

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// ========================================
// DOCUMENTACIÓN ADICIONAL Y NOTAS
// ========================================

/* 
CARACTERÍSTICAS PRINCIPALES DEL SISTEMA:

1. PANTALLA PRINCIPAL (ServiceManagementScreen):
   - Lista completa de servicios del proveedor
   - Sistema de filtros por categoría, modalidad y estado
   - Búsqueda por texto en título y descripción
   - Tarjetas detalladas con información completa
   - Acciones: editar, pausar/activar, duplicar, eliminar
   - Estados especiales: vacío, sin resultados, error

2. PANTALLA DE CREACIÓN/EDICIÓN (CreateServiceScreen):
   - Interfaz con pestañas para mejor organización
   - Selección visual de categorías con iconos y colores
   - Configuración flexible de precios por modalidad
   - Gestión completa de horarios semanales
   - Vista previa simulada para el cliente
   - Validaciones completas de formulario

3. FUNCIONALIDADES TÉCNICAS:
   - Integración completa con Firebase (Firestore + Storage)
   - Manejo de estados de carga y error
   - Validaciones de entrada robustas
   - Optimización de imágenes automática
   - Diseño responsive y accesible
   - Animaciones y transiciones suaves

4. ARQUITECTURA:
   - Separación clara de responsabilidades
   - Componentes reutilizables bien documentados
   - Gestión de estado con Provider
   - Estructura modular y escalable

PRÓXIMAS CARACTERÍSTICAS A IMPLEMENTAR:
- Sistema de notificaciones push
- Analytics detallados de servicios
- Chat integrado con clientes
- Sistema de reseñas y calificaciones
- Geolocalización avanzada
- Múltiples imágenes por servicio
- Integración con pasarelas de pago

CONSIDERACIONES DE RENDIMIENTO:
- Lazy loading en listas grandes
- Cacheo de imágenes
- Paginación en consultas
- Optimización de queries de Firestore

SEGURIDAD:
- Validación en cliente y servidor
- Reglas de seguridad en Firestore
- Sanitización de entrada de usuario
- Control de acceso basado en roles
*/
