// lib/features/admin/analytics_screen.dart
// Versión SIN fl_chart - Solo usando widgets nativos de Flutter

import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedPeriod = 'Últimos 30 días';
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    // Simular carga de datos analíticos
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _analyticsData = {
          'revenue': {
            'current': 45678.90,
            'previous': 38934.67,
            'growth': 17.3,
            'monthly': [
              {'month': 'Ene', 'amount': 28500},
              {'month': 'Feb', 'amount': 32100},
              {'month': 'Mar', 'amount': 29800},
              {'month': 'Abr', 'amount': 35600},
              {'month': 'May', 'amount': 38200},
              {'month': 'Jun', 'amount': 45678},
            ],
          },
          'users': {
            'newUsers': 156,
            'activeUsers': 1247,
            'retentionRate': 78.5,
            'growth': 12.4,
            'dailyActive': [
              {'day': 'Lun', 'users': 845},
              {'day': 'Mar', 'users': 923},
              {'day': 'Mié', 'users': 1087},
              {'day': 'Jue', 'users': 1156},
              {'day': 'Vie', 'users': 1234},
              {'day': 'Sáb', 'users': 967},
              {'day': 'Dom', 'users': 756},
            ],
          },
          'bookings': {
            'total': 3456,
            'completed': 3201,
            'cancelled': 255,
            'completionRate': 92.6,
            'categories': [
              {'name': 'Limpieza General', 'count': 1234, 'percentage': 35.7},
              {'name': 'Limpieza Profunda', 'count': 987, 'percentage': 28.6},
              {'name': 'Limpieza de Oficinas', 'count': 654, 'percentage': 18.9},
              {'name': 'Limpieza Post-Construcción', 'count': 345, 'percentage': 10.0},
              {'name': 'Otros', 'count': 236, 'percentage': 6.8},
            ],
          },
          'providers': {
            'total': 89,
            'active': 76,
            'topRated': 34,
            'averageRating': 4.3,
            'performance': [
              {'name': 'María González', 'rating': 4.9, 'services': 156},
              {'name': 'Carlos Pérez', 'rating': 4.8, 'services': 142},
              {'name': 'Ana Rodríguez', 'rating': 4.7, 'services': 138},
              {'name': 'Luis Morales', 'rating': 4.6, 'services': 129},
              {'name': 'Carmen López', 'rating': 4.5, 'services': 115},
            ],
          },
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analíticas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalyticsData();
            },
            itemBuilder: (context) => [
              'Últimos 7 días',
              'Últimos 30 días',
              'Últimos 3 meses',
              'Último año',
            ].map((period) => PopupMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod, style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Ingresos'),
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.book_online), text: 'Reservas'),
            Tab(icon: Icon(Icons.business), text: 'Proveedores'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRevenueTab(),
                _buildUsersTab(),
                _buildBookingsTab(),
                _buildProvidersTab(),
              ],
            ),
    );
  }

  Widget _buildRevenueTab() {
    final revenueData = _analyticsData['revenue'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs de ingresos
          _buildRevenueKPIs(revenueData),
          const SizedBox(height: 24),
          
          // Gráfico simple de ingresos mensuales
          _buildSimpleRevenueChart(revenueData),
          const SizedBox(height: 24),
          
          // Métricas adicionales
          _buildRevenueMetrics(),
        ],
      ),
    );
  }

  Widget _buildRevenueKPIs(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de Ingresos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Ingresos Actuales',
                value: '\$${data['current'].toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.green,
                subtitle: '+${data['growth']}% vs período anterior',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Período Anterior',
                value: '\$${data['previous'].toStringAsFixed(2)}',
                icon: Icons.history,
                color: Colors.blue,
                subtitle: 'Comparación base',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleRevenueChart(Map<String, dynamic> data) {
    final monthlyData = data['monthly'] as List;
    final maxAmount = monthlyData
        .map((item) => item['amount'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia de Ingresos Mensuales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: monthlyData.map((item) {
                final height = (item['amount'] / maxAmount) * 200;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.purple.shade700,
                                Colors.purple.shade400,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['month'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '\$${(item['amount'] / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas Adicionales',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildMetricTile('Ticket Promedio', '\$67.45', Icons.receipt, Colors.orange),
            _buildMetricTile('Comisión Plataforma', '\$4,567.89', Icons.account_balance, Colors.blue),
            _buildMetricTile('Ingresos por Usuario', '\$36.62', Icons.person_outline, Colors.green),
            _buildMetricTile('Proyección Mensual', '\$52,340', Icons.trending_up, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    final usersData = _analyticsData['users'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs de usuarios
          _buildUsersKPIs(usersData),
          const SizedBox(height: 24),
          
          // Gráfico simple de usuarios activos diarios
          _buildSimpleUsersChart(usersData),
          const SizedBox(height: 24),
          
          // Métricas de retención
          _buildRetentionMetrics(usersData),
        ],
      ),
    );
  }

  Widget _buildUsersKPIs(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas de Usuarios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildKPICard(
              title: 'Usuarios Activos',
              value: '${data['activeUsers']}',
              icon: Icons.people,
              color: Colors.blue,
              subtitle: '+${data['growth']}% este mes',
            ),
            _buildKPICard(
              title: 'Nuevos Usuarios',
              value: '${data['newUsers']}',
              icon: Icons.person_add,
              color: Colors.green,
              subtitle: 'Este período',
            ),
            _buildKPICard(
              title: 'Tasa de Retención',
              value: '${data['retentionRate']}%',
              icon: Icons.favorite,
              color: Colors.red,
              subtitle: 'Usuarios que regresan',
            ),
            _buildKPICard(
              title: 'Promedio Diario',
              value: '967',
              icon: Icons.today,
              color: Colors.orange,
              subtitle: 'Usuarios activos/día',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleUsersChart(Map<String, dynamic> data) {
    final dailyData = data['dailyActive'] as List;
    final maxUsers = dailyData
        .map((item) => item['users'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usuarios Activos por Día',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dailyData.map((item) {
                final height = (item['users'] / maxUsers) * 200;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['day'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${item['users']}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionMetrics(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis de Retención',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRetentionIndicator('1 Día', 85.3, Colors.green),
              ),
              Expanded(
                child: _buildRetentionIndicator('7 Días', 78.5, Colors.blue),
              ),
              Expanded(
                child: _buildRetentionIndicator('30 Días', 65.2, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionIndicator(String period, double percentage, Color color) {
    return Column(
      children: [
        Text(
          period,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    final bookingsData = _analyticsData['bookings'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs de reservas
          _buildBookingsKPIs(bookingsData),
          const SizedBox(height: 24),
          
          // Gráfico simple de distribución por categorías
          _buildSimpleCategoriesChart(bookingsData),
          const SizedBox(height: 24),
          
          // Lista de categorías populares
          _buildCategoriesList(bookingsData),
        ],
      ),
    );
  }

  Widget _buildBookingsKPIs(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas de Reservas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildKPICard(
              title: 'Total Reservas',
              value: '${data['total']}',
              icon: Icons.book_online,
              color: Colors.blue,
              subtitle: 'Este período',
            ),
            _buildKPICard(
              title: 'Completadas',
              value: '${data['completed']}',
              icon: Icons.check_circle,
              color: Colors.green,
              subtitle: '${data['completionRate']}% tasa éxito',
            ),
            _buildKPICard(
              title: 'Canceladas',
              value: '${data['cancelled']}',
              icon: Icons.cancel,
              color: Colors.red,
              subtitle: '${((data['cancelled'] / data['total']) * 100).toStringAsFixed(1)}% del total',
            ),
            _buildKPICard(
              title: 'Promedio Diario',
              value: '${(data['total'] / 30).toStringAsFixed(0)}',
              icon: Icons.today,
              color: Colors.orange,
              subtitle: 'Reservas por día',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleCategoriesChart(Map<String, dynamic> data) {
    final categories = data['categories'] as List;
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por Categorías',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                ];
                final color = colors[index % colors.length];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          category['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: category['percentage'] / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${category['percentage']}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(Map<String, dynamic> data) {
    final categories = data['categories'] as List;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Categorías Más Populares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              final colors = [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.red,
              ];
              
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(category['name']),
                subtitle: Text('${category['count']} reservas'),
                trailing: Text(
                  '${category['percentage']}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersTab() {
    final providersData = _analyticsData['providers'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs de proveedores
          _buildProvidersKPIs(providersData),
          const SizedBox(height: 24),
          
          // Top proveedores
          _buildTopProviders(providersData),
        ],
      ),
    );
  }

  Widget _buildProvidersKPIs(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas de Proveedores',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildKPICard(
              title: 'Total Proveedores',
              value: '${data['total']}',
              icon: Icons.business,
              color: Colors.blue,
              subtitle: 'Registrados',
            ),
            _buildKPICard(
              title: 'Activos',
              value: '${data['active']}',
              icon: Icons.verified,
              color: Colors.green,
              subtitle: '${((data['active'] / data['total']) * 100).toStringAsFixed(1)}% del total',
            ),
            _buildKPICard(
              title: 'Top Rated',
              value: '${data['topRated']}',
              icon: Icons.star,
              color: Colors.amber,
              subtitle: '4.5+ estrellas',
            ),
            _buildKPICard(
              title: 'Rating Promedio',
              value: '${data['averageRating']}',
              icon: Icons.trending_up,
              color: Colors.orange,
              subtitle: 'General plataforma',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProviders(Map<String, dynamic> data) {
    final performance = data['performance'] as List;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mejores Proveedores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: performance.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final provider = performance[index];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(provider['name']),
                subtitle: Text('${provider['services']} servicios completados'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${provider['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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