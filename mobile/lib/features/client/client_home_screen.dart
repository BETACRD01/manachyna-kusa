import 'package:flutter/material.dart';
import '../../data/services/base_api_service.dart';
import '../client/booking_history_screen.dart';
import '../client/payments_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../config/app_routes.dart'; // Para ServiceOptionsArguments

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  // Lista de pantallas usando los archivos separados
  late final List<Widget> _screens = [
    const HomeTab(), // Esta es la pestaña de inicio específica del cliente
    const BookingHistoryScreen(),
    const PaymentsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// HomeTab para ClientHomeScreen - ahora con búsqueda integrada
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;

  // ========================================
  // CONTROLADORES DE BÚSQUEDA (NUEVO)
  // ========================================
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;
  final String _selectedCategory = 'Todos';

  // Datos de búsqueda
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingResults = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSearchListener(); // NUEVO
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationController.forward();
  }

  // NUEVO: Configurar listener de búsqueda
  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          if (query.isNotEmpty) {
            _performSearch(query);
          } else {
            _clearSearch();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 100.0, // Altura aumentada
            backgroundColor: const Color(0xFFF2F2F7),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              centerTitle: false, // Alineación izquierda
              title: SafeArea(
                  child: Image.asset(
                'assets/images/logo.png',
                height: 60, // Logo más grande
                fit: BoxFit.contain,
              )),
              background: Container(color: const Color(0xFFF2F2F7)),
            ),
            actions: [
              _NotificationButton(
                  isSmallScreen: MediaQuery.of(context).size.width < 600),
            ],
          ),

          // 2. Welcome Card (Publicidad) - Moved below Logo
          if (!_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _WelcomeCard(
                    isSmallScreen: MediaQuery.of(context).size.width < 600),
              ),
            ),

          // 3. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildIOSSearchBar(),
            ),
          ),

          // 4. Content
          if (_isLoadingResults)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_isSearching && _searchResults.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No encontramos resultados',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else if (_isSearching)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ServiceResultCard(
                      serviceData: _searchResults[index],
                      isSmallScreen: MediaQuery.of(context).size.width < 600,
                    ),
                  );
                },
                childCount: _searchResults.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _MainServicesGrid(
                      animationController: _animationController,
                      isSmallScreen: MediaQuery.of(context).size.width < 600,
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Search Bar Widget ---
  Widget _buildIOSSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Buscar servicios...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          // Listener handled in initState
        },
      ),
    );
  }

  // ========================================
  // MÉTODOS DE BÚSQUEDA (NUEVOS)
  // ========================================

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingResults = true;
    });

    try {
      final results = await _searchServices(query);
      setState(() {
        _searchResults = results;
        _isLoadingResults = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoadingResults = false;
      });
      _showErrorMessage('Error en la búsqueda: $e');
    }
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchResults = [];
      _isLoadingResults = false;
    });
  }

  Future<List<Map<String, dynamic>>> _searchServices(String query) async {
    try {
      final apiService = BaseApiService();
      String url = 'services/search/?q=$query';
      if (_selectedCategory != 'Todos') {
        url += '&category=$_selectedCategory';
      }
      
      final response = await apiService.get(url);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en búsqueda Django: $e');
      return [];
    }
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ========================================
// NUEVOS COMPONENTES DE BÚSQUEDA
// ========================================

class _ServiceResultCard extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final bool isSmallScreen;

  const _ServiceResultCard({
    required this.serviceData,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final providerInfo = serviceData['providerInfo'] as Map<String, dynamic>?;
    final rating = (serviceData['rating'] ?? 0.0).toDouble();
    final totalRatings = serviceData['totalRatings'] ?? 0;
    final price = (serviceData['price'] ?? 0.0).toDouble();
    final timeMode = serviceData['timeMode'] ?? 'Por hora';

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.06).round()),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onServiceTap(context),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceImage(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceData['title'] ?? 'Servicio',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              serviceData['category'] ?? 'Otro',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (rating > 0) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber[600],
                                size: isSmallScreen ? 14 : 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ($totalRatings)',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                        Text(
                          _getTimeModeText(timeMode),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (serviceData['description']?.toString().isNotEmpty ==
                    true) ...[
                  Text(
                    serviceData['description'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                if (providerInfo != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        providerInfo['name'] ?? 'Proveedor',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on_outlined,
                        size: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tena, Napo',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage() {
    if (serviceData['imageUrl']?.toString().isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          serviceData['imageUrl'],
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 50 : 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: isSmallScreen ? 50 : 60,
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getCategoryIcon(serviceData['category']),
        color: Colors.grey[600],
        size: isSmallScreen ? 24 : 28,
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
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
      case 'reparaciones':
        return Icons.build;
      default:
        return Icons.home_repair_service;
    }
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

  // NAVEGACIÓN PARA AGENDAR CITA DIRECTA (SOLO RESULTADOS DE BÚSQUEDA)
  void _onServiceTap(BuildContext context) {
    debugPrint('Search result tapped: ${serviceData['title']}');
    debugPrint('Service ID: ${serviceData['id']}');

    try {
      // NAVEGAR A SERVICE-DETAILS PARA AGENDAR CITA DIRECTA
      Navigator.pushNamed(
        context,
        '/service-details',
        arguments: {
          'serviceId': serviceData['id'] ?? '',
          'serviceData': serviceData,
        },
      );
      debugPrint('Navegación de búsqueda exitosa');
    } catch (e) {
      debugPrint('Error en navegación de búsqueda: $e');
    }
  }
}

// ========================================
// COMPONENTES ORIGINALES INTACTOS
// ========================================

// Widget separado para el header

class _NotificationButton extends StatelessWidget {
  final bool isSmallScreen;

  const _NotificationButton({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente: Notificaciones')),
            );
          },
          icon: Icon(
            Icons.notifications_none_rounded, // Icono más redondeado estilo iOS
            color: Colors.black87,
            size: isSmallScreen ? 28 : 32, // Tamaño aumentado
          ),
          padding: const EdgeInsets.all(8),
          constraints:
              const BoxConstraints(), // Eliminar restricciones por defecto
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            highlightColor: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

// Widget separado para la tarjeta de bienvenida
class _WelcomeCard extends StatelessWidget {
  final bool isSmallScreen;

  const _WelcomeCard({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.06).round()),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _WelcomeIcon(size: isSmallScreen ? 60 : 70),
          SizedBox(width: isSmallScreen ? 14 : 18),
          Expanded(
            child: _WelcomeContent(isSmallScreen: isSmallScreen),
          ),
        ],
      ),
    );
  }
}

class _WelcomeIcon extends StatelessWidget {
  final double size;

  const _WelcomeIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/publicidad-digital.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error cargando icono de bienvenida: $error');
        return Icon(
          Icons.image_not_supported,
          size: size,
          color: Colors.grey[400],
        );
      },
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  final bool isSmallScreen;

  const _WelcomeContent({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios profesionales para tu hogar',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Técnicos certificados con garantía incluida',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        const _LocationAndRating(),
      ],
    );
  }
}

class _LocationAndRating extends StatelessWidget {
  const _LocationAndRating();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Tena, Napo',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '★ 4.8',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// CLASE ORIGINAL INTACTA: Grid de servicios principales
class _MainServicesGrid extends StatelessWidget {
  final AnimationController animationController;
  final bool isSmallScreen;

  const _MainServicesGrid({
    required this.animationController,
    required this.isSmallScreen,
  });

  // Lista de servicios principales con iconos personalizados
  static const List<Map<String, String>> _mainServices = [
    {
      'id': 'limpieza',
      'title': 'Limpieza',
      'category': 'limpieza',
      'icon': 'assets/icons/casa-limpia.png',
    },
    {
      'id': 'electricidad',
      'title': 'Electricidad',
      'category': 'electricidad',
      'icon': 'assets/icons/electricista.png',
    },
    {
      'id': 'plomeria',
      'title': 'Plomería',
      'category': 'plomería',
      'icon': 'assets/icons/plomero.png',
    },
    {
      'id': 'carpinteria',
      'title': 'Carpintería',
      'category': 'carpintería',
      'icon': 'assets/icons/caja-de-herramientas.png',
    },
    {
      'id': 'jardineria',
      'title': 'Jardinería',
      'category': 'jardinería',
      'icon': 'assets/icons/agronomia.png',
    },
    {
      'id': 'pintura',
      'title': 'Pintura',
      'category': 'pintura',
      'icon': 'assets/icons/cubo-de-pintura.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        Row(
          children: [
            Icon(
              Icons.build_circle,
              color: Colors.grey[700],
              size: isSmallScreen ? 24 : 28,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              'Servicios',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Grid de servicios
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 2 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: isSmallScreen ? 0.9 : 0.85, // ORIGINAL
          ),
          itemCount: _mainServices.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              serviceData: _mainServices[index],
              index: index,
              animationController: animationController,
              isSmallScreen: isSmallScreen,
            );
          },
        ),
      ],
    );
  }
}

// CLASE ORIGINAL INTACTA: Tarjeta de servicio individual (SIN BOTÓN)
class _ServiceCard extends StatelessWidget {
  final Map<String, String> serviceData;
  final int index;
  final AnimationController animationController;
  final bool isSmallScreen;

  const _ServiceCard({
    required this.serviceData,
    required this.index,
    required this.animationController,
    required this.isSmallScreen,
  });

  String get serviceId => serviceData['id'] ?? 'unknown';
  String get serviceTitle => serviceData['title'] ?? 'Servicio';
  String get serviceCategory => serviceData['category'] ?? 'Otro';
  String get serviceIcon =>
      serviceData['icon'] ?? 'assets/icons/gastos-generales.png';

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.1 + (index * 0.08),
        0.6 + (index * 0.08),
        curve: Curves.easeOutBack,
      ),
    ));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: _buildCard(context),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.03).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onServiceTap(context),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del servicio
                _ServiceIconWidget(
                  iconPath: serviceIcon,
                  category: serviceCategory,
                  size: _getIconSize(),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),

                // Título del servicio
                _ServiceTitle(
                  title: serviceTitle,
                  fontSize: _getTitleFontSize(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getIconSize() {
    if (isSmallScreen) return 45; // ORIGINAL
    return 55;
  }

  double _getTitleFontSize() {
    if (isSmallScreen) return 12;
    return 14;
  }

  // MÉTODO ORIGINAL INTACTO: Navegación a service-options
  void _onServiceTap(BuildContext context) {
    debugPrint('Service tapped: $serviceTitle');
    debugPrint('Service ID: $serviceId');
    debugPrint('Service category: $serviceCategory');

    try {
      // Navegar a service options con datos básicos
      // CORRECTO - Pasando ServiceOptionsArguments
      Navigator.pushNamed(
        context,
        '/service-options',
        arguments: ServiceOptionsArguments(
          serviceId: serviceId,
          serviceName: serviceTitle,
          serviceCategory: serviceCategory,
          basePrice: 0.0,
        ),
      );
      debugPrint('Navegación iniciada correctamente');
    } catch (e) {
      debugPrint('Error en navegación: $e');
    }
  }
}

// CLASE ORIGINAL INTACTA: Widget para el icono del servicio
class _ServiceIconWidget extends StatelessWidget {
  final String iconPath;
  final String category;
  final double size;

  const _ServiceIconWidget({
    required this.iconPath,
    required this.category,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error cargando imagen: $iconPath - $error');
        // Fallback a icono de Material Design
        return Icon(
          _getServiceIcon(category),
          size: size * 0.8,
          color: Colors.blueGrey[400],
        );
      },
    );
  }

  IconData _getServiceIcon(String category) {
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
      default:
        return Icons.home_repair_service;
    }
  }
}

// CLASE ORIGINAL INTACTA: Widget para el título del servicio
class _ServiceTitle extends StatelessWidget {
  final String title;
  final double fontSize;

  const _ServiceTitle({
    required this.title,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
