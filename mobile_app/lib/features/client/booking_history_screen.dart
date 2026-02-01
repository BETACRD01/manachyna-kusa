import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/database_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with TickerProviderStateMixin {
  final DatabaseService _firestoreService = DatabaseService();

  String? currentUserId;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _statusFilters = [
    {
      'value': 'all',
      'label': 'Todas',
      'icon': Icons.list_alt,
      'color': Colors.blue,
    },
    {
      'value': 'pending_confirmation',
      'label': 'En Espera',
      'icon': Icons.hourglass_empty,
      'color': Colors.orange,
    },
    {
      'value': 'confirmed',
      'label': 'Confirmadas',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'in_progress',
      'label': 'En Progreso',
      'icon': Icons.work,
      'color': Colors.purple,
    },
    {
      'value': 'completed',
      'label': 'Completadas',
      'icon': Icons.task_alt,
      'color': Colors.teal,
    },
    {
      'value': 'cancelled',
      'label': 'Canceladas',
      'icon': Icons.cancel,
      'color': Colors.red,
    },
    {
      'value': 'rejected',
      'label': 'Rechazadas',
      'icon': Icons.block,
      'color': Colors.red[800]!,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Defer context usage to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentUserId();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _getCurrentUserId() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFFF2F2F7),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              centerTitle: false,
              title: const Text(
                'Mis Reservas',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(color: const Color(0xFFF2F2F7)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {});
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildFilterPills(),
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          _buildSliverBookingsList(_selectedFilter),
          const SliverPadding(
              padding: EdgeInsets.only(
                  bottom: 80)), // Add bottom padding for content
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = filter['value'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    if (isSelected) ...[
                      Icon(filter['icon'], size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      filter['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por servicio o proveedor',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
      ),
    );
  }

  Widget _buildSliverBookingsList(String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getBookingsStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reservas',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(status),
          );
        }

        final bookings = snapshot.data!;
        final filteredBookings = _filterBookings(bookings);

        if (filteredBookings.isEmpty && _searchQuery.isNotEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron resultados',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final booking = filteredBookings[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMinimalBookingCard(booking),
                );
              },
              childCount: filteredBookings.length,
            ),
          ),
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getBookingsStream(String status) {
    if (status == 'all') {
      return _firestoreService.getClientBookings(currentUserId!);
    } else {
      return _firestoreService.getClientBookingsByStatus(
          currentUserId!, status);
    }
  }

  List<Map<String, dynamic>> _filterBookings(
      List<Map<String, dynamic>> bookings) {
    if (_searchQuery.isEmpty) return bookings;
    return bookings.where((booking) {
      final serviceTitle =
          (booking['serviceTitle'] ?? '').toString().toLowerCase();
      final providerName =
          (booking['providerName'] ?? '').toString().toLowerCase();
      return serviceTitle.contains(_searchQuery) ||
          providerName.contains(_searchQuery);
    }).toList();
  }

  Widget _buildEmptyState(String status) {
    final statusLabel = _getStatusLabel(status);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            status == 'all'
                ? 'No tienes reservas aún'
                : 'No hay reservas $statusLabel',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    final filter = _statusFilters.firstWhere(
      (f) => f['value'] == status,
      orElse: () => {'label': status},
    );
    return filter['label'];
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending_confirmation':
        return {
          'label': 'En Espera',
          'color': Colors.orange,
          'icon': Icons.hourglass_empty
        };
      case 'confirmed':
        return {
          'label': 'Confirmada',
          'color': Colors.blue,
          'icon': Icons.check_circle_outline
        };
      case 'in_progress':
        return {
          'label': 'En Progreso',
          'color': Colors.purple,
          'icon': Icons.work_outline
        };
      case 'completed':
        return {
          'label': 'Completada',
          'color': Colors.green,
          'icon': Icons.check_circle
        };
      case 'cancelled':
        return {
          'label': 'Cancelada',
          'color': Colors.red,
          'icon': Icons.cancel_outlined
        };
      case 'rejected':
        return {
          'label': 'Rechazada',
          'color': Colors.red[800]!,
          'icon': Icons.block
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.info_outline
        };
    }
  }

  Widget _buildMinimalBookingCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final statusInfo = _getStatusInfo(status);
    final DateTime? scheduledDate =
        DateTime.tryParse(data['scheduledDateTime']?.toString() ?? '');
    final serviceTitle = data['serviceTitle'] ?? 'Servicio';
    final providerName = data['providerName'] ?? 'Proveedor';
    final totalPrice = (data['totalPrice'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            _viewBookingDetails(data['id']?.toString() ?? '', data);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Column
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            scheduledDate != null
                                ? DateFormat('MMM')
                                    .format(scheduledDate)
                                    .toUpperCase()
                                : '---',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          Text(
                            scheduledDate != null
                                ? scheduledDate.day.toString()
                                : '--',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceTitle,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            providerName,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (statusInfo['color'] as Color)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusInfo['label'],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusInfo['color']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                    height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          scheduledDate != null
                              ? DateFormat('HH:mm').format(scheduledDate)
                              : '--:--',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewBookingDetails(String bookingId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalles de la Reserva',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildDetailSection('Servicio', [
                      _buildDetailRow(Icons.home_repair_service, 'Servicio',
                          data['serviceTitle'] ?? 'N/A'),
                      _buildDetailRow(Icons.category, 'Categoría',
                          data['serviceCategory'] ?? 'N/A'),
                      _buildDetailRow(Icons.info, 'Estado',
                          _getStatusInfo(data['status'] ?? 'pending')['label'],
                          color: _getStatusInfo(
                              data['status'] ?? 'pending')['color'] as Color?),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Proveedor', [
                      _buildDetailRow(Icons.person, 'Nombre',
                          data['providerName'] ?? 'N/A'),
                      if (data['providerEmail'] != null)
                        _buildDetailRow(
                            Icons.email, 'Email', data['providerEmail']),
                    ]),
                    const SizedBox(height: 24),
                    if (data['scheduledDateTime'] != null) ...[
                      _buildDetailSection('Programación', [
                        _buildDetailRow(
                            Icons.calendar_today,
                            'Fecha',
                            DateFormat('dd/MM/yyyy').format(DateTime.tryParse(
                                    data['scheduledDateTime'].toString()) ??
                                DateTime.now())),
                        _buildDetailRow(
                            Icons.access_time,
                            'Hora',
                            DateFormat('HH:mm').format(DateTime.tryParse(
                                    data['scheduledDateTime'].toString()) ??
                                DateTime.now())),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    _buildDetailSection('Costo', [
                      _buildDetailRow(Icons.receipt, 'Total Final',
                          '\$${(data['finalTotal'] ?? data['totalPrice'] ?? 0).toString()}'),
                      _buildDetailRow(Icons.payment, 'Método',
                          data['paymentMethod'] ?? 'Efectivo'),
                    ]),
                  ],
                ),
              ),
              // Action Buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      /* Future Action Buttons
                       if (data['status'] == 'completed' || data['status'] == 'cancelled')
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                 Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Volver a Reservar'),
                            ),
                          ),
                      */
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
