import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Tus pantallas ya existentes:
import 'service_management_screen.dart';
import 'provider_bookings_screen.dart';
import 'earnings_screen.dart';
import 'provider_profile_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _currentIndex = 0;

  // Construimos la lista para poder pasar el callback a la pestaña Home
  List<Widget> _screensBuilder() => [
        ProviderHomeTab(
          onChangeTab: (i) => setState(() => _currentIndex = i),
        ),
        const ServiceManagementScreen(),
        const ProviderBookingsScreen(),
        const EarningsScreen(),
        ProviderProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final screens = _screensBuilder();
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Trabajos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // <-- NUEVO ÍCONO
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

// =============================================
// TAB 1: HOME - Dashboard del proveedor (FUNCIONAL)
// =============================================
class ProviderHomeTab extends StatefulWidget {
  const ProviderHomeTab({
    super.key,
    required this.onChangeTab,
  });

  /// Cambia la pestaña del BottomNavigationBar del padre
  final ValueChanged<int> onChangeTab;

  @override
  State<ProviderHomeTab> createState() => _ProviderHomeTabState();
}

class _ProviderHomeTabState extends State<ProviderHomeTab> {
  String? get _uid => Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('Error: usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Botón de notificaciones con badge
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from('notifications')
                .stream(primaryKey: ['id']).map((list) => list
                    .where((n) => n['userId'] == _uid && n['read'] == false)
                    .toList()),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.length ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProviderNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header proveedor
          FutureBuilder<Map<String, dynamic>>(
            future: Supabase.instance.client
                .from('providers')
                .select()
                .eq('id', _uid!)
                .maybeSingle()
                .then((data) => data ?? {}),
            builder: (context, snap) {
              final isLoading = snap.connectionState == ConnectionState.waiting;
              final hasData = snap.hasData && snap.data!.isNotEmpty;
              final data = hasData ? snap.data! : {};
              final name = (data['name'] ?? 'Proveedor').toString();
              final specialty =
                  (data['providerType'] ?? 'Profesional').toString();
              final location = (data['location'] ?? 'Tena, Napo').toString();
              final isActive = data['isActive'] == true;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green.withAlpha(50),
                      child: const Icon(Icons.person,
                          size: 30, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: isLoading
                          ? const LinearProgressIndicator()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('¡Hola, $name!',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text(specialty),
                                Text(location),
                              ],
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.grey)
                            .withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Resumen
          const Text('Resumen de hoy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>>(
            future: _getStats(_uid!),
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final stats = snap.data ??
                  {
                    'activeServices': 0,
                    'completedJobs': 0,
                    'pendingBookings': 0,
                    'totalEarnings': 0.0,
                  };

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _statCard('Servicios Activos', '${stats['activeServices']}',
                      Icons.build, Colors.teal, loading),
                  _statCard('Pendientes', '${stats['pendingBookings']}',
                      Icons.pending, Colors.orange, loading),
                  _statCard('Completados', '${stats['completedJobs']}',
                      Icons.check_circle, Colors.blue, loading),
                  _statCard(
                      'Ganancias Totales',
                      '\$${(stats['totalEarnings'] as num).toStringAsFixed(2)}',
                      Icons.monetization_on,
                      Colors.green,
                      loading),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Próximos trabajos (confirmados)
          const Text('Próximos trabajos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from('bookings')
                .stream(primaryKey: ['id'])
                .map((list) => list
                    .where((b) =>
                        b['providerId'] == _uid && b['status'] == 'confirmed')
                    .toList()
                  ..sort((a, b) => (a['scheduledDateTime'] ?? '')
                      .compareTo(b['scheduledDateTime'] ?? '')))
                .map((list) => list.take(5).toList()),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Text('Error al cargar trabajos');
              }
              final docs = snap.data ?? [];
              if (docs.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.event_busy),
                    title: Text('Sin trabajos próximos'),
                    subtitle: Text('Cuando te confirmen, aparecerán aquí.'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final client = (d['clientName'] ?? 'Cliente').toString();
                  final title = (d['serviceTitle'] ?? 'Servicio').toString();
                  final ts = d['scheduledDate'] ?? d['scheduledDateTime'];
                  final when =
                      ts != null ? DateTime.tryParse(ts.toString()) : null;
                  final price =
                      (d['finalTotal'] ?? d['totalPrice'] ?? 0).toDouble();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withAlpha(50),
                        child: Text(client.isNotEmpty ? client[0] : '?'),
                      ),
                      title: Text(title),
                      subtitle: Text(when == null
                          ? client
                          : '$client • ${_fmtDate(when)} ${_fmtTime(when)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          const Text('ver más', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      onTap: () => _showBookingDetailDialog(context, d),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          const Text('Acciones rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Cambiar disponibilidad (abre bottom sheet funcional)
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final snap = await Supabase.instance.client
                      .from('providers')
                      .select()
                      .eq('id', _uid!)
                      .maybeSingle();
                  if (!context.mounted) return;
                  _openAvailabilitySheet(
                    context,
                    _uid!,
                    snap ?? <String, dynamic>{},
                  );
                },
                icon: const Icon(Icons.access_time),
                label: const Text('Cambiar Disponibilidad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          // Ver historial (pantalla) & Reportar problema (bottom sheet)
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProviderHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Ver Historial'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final recent = await Supabase.instance.client
                      .from('bookings')
                      .select()
                      .eq('providerId', _uid!)
                      .order('createdAt', ascending: false)
                      .limit(10);
                  if (!context.mounted) return;
                  _openReportProblemSheet(
                    context,
                    _uid!,
                    List<Map<String, dynamic>>.from(recent),
                  );
                },
                icon: const Icon(Icons.report_problem),
                label: const Text('Reportar Problema'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ----------------- Helpers UI -----------------
  Widget _statCard(
      String title, String value, IconData icon, Color color, bool loading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ----------------- Disponibilidad (BottomSheet) -----------------
  void _openAvailabilitySheet(
      BuildContext context, String providerId, Map<String, dynamic> current) {
    bool isActive = (current['isActive'] ?? true) as bool;
    // workingHours esperado como:
    // { Lunes: {isActive: true, start: '08:00', end: '18:00'}, ... }
    final Map<String, dynamic> workingHours = Map<String, dynamic>.from(
      current['workingHours'] ??
          {
            'Lunes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
            'Martes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
            'Miércoles': {'isActive': true, 'start': '08:00', 'end': '18:00'},
            'Jueves': {'isActive': true, 'start': '08:00', 'end': '18:00'},
            'Viernes': {'isActive': true, 'start': '08:00', 'end': '18:00'},
            'Sábado': {'isActive': false, 'start': '09:00', 'end': '15:00'},
            'Domingo': {'isActive': false, 'start': '00:00', 'end': '00:00'},
          },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setModal) {
          Future<void> pickTime(String day, bool start) async {
            final initial = (start
                ? workingHours[day]['start']
                : workingHours[day]['end']) as String;
            final initParts = initial.split(':');
            final initialTime = TimeOfDay(
              hour: int.tryParse(initParts[0]) ?? 8,
              minute: int.tryParse(initParts[1]) ?? 0,
            );
            final picked = await showTimePicker(
              context: context,
              initialTime: initialTime,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              final t =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              setModal(() {
                if (start) {
                  workingHours[day]['start'] = t;
                } else {
                  workingHours[day]['end'] = t;
                }
              });
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 12),
                const Text('Disponibilidad',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Perfil activo'),
                  subtitle:
                      Text(isActive ? 'Visible para clientes' : 'No visible'),
                  value: isActive,
                  onChanged: (v) => setModal(() => isActive = v),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Horario por día',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                // Lista segura contra tipos inválidos
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: workingHours.entries.map((entry) {
                      final String day = entry.key.toString();
                      final dynamic raw = entry.value;
                      final Map<String, dynamic> dayHours = (raw is Map)
                          ? Map<String, dynamic>.from(raw)
                          : <String, dynamic>{
                              'isActive': false,
                              'start': '08:00',
                              'end': '18:00',
                            };
                      final bool dayActive = dayHours['isActive'] == true;
                      final String start =
                          (dayHours['start'] ?? '08:00').toString();
                      final String end =
                          (dayHours['end'] ?? '18:00').toString();

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        (dayActive ? Colors.green : Colors.grey)
                                            .withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      color: dayActive
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: dayActive,
                                  onChanged: (v) {
                                    setModal(() {
                                      workingHours[day] = {
                                        ...dayHours,
                                        'isActive': v,
                                      };
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (dayActive)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => pickTime(day, true),
                                      icon: const Icon(Icons.access_time),
                                      label: Text('Inicio: $start'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => pickTime(day, false),
                                      icon: const Icon(Icons.access_time),
                                      label: Text('Fin: $end'),
                                    ),
                                  ),
                                ],
                              ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        onPressed: () async {
                          await Supabase.instance.client
                              .from('providers')
                              .update({
                            'isActive': isActive,
                            'workingHours': workingHours,
                            'updatedAt': DateTime.now().toIso8601String(),
                          }).eq('id', providerId);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Disponibilidad actualizada')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ----------------- Reportar problema (BottomSheet) -----------------
  void _openReportProblemSheet(
    BuildContext context,
    String userId,
    List<Map<String, dynamic>> recentBookings,
  ) {
    String? selectedBookingId;
    final problems = ['Pago', 'Cliente', 'Horario', 'App', 'Otro'];
    String selectedProblem = problems.first;
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 12),
          const Text('Reportar problema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              labelText: 'Reserva relacionada (opcional)',
              border: OutlineInputBorder(),
            ),
            initialValue: selectedBookingId,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Ninguna'),
              ),
              ...recentBookings.map((b) {
                final d = b;
                final title = (d['serviceTitle'] ?? 'Servicio').toString();
                return DropdownMenuItem<String?>(
                  value: b['id'],
                  child: Text('$title • ${(b['id'] ?? '').substring(0, 6)}'),
                );
              }),
            ],
            onChanged: (v) => selectedBookingId = v,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo de problema',
              border: OutlineInputBorder(),
            ),
            initialValue: selectedProblem,
            items: problems
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => selectedProblem = v ?? problems.first,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Describe el problema con detalle…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                  onPressed: () async {
                    final text = descCtrl.text.trim();
                    if (text.isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Escribe una descripción')),
                      );
                      return;
                    }
                    await Supabase.instance.client.from('reports').insert({
                      'userId': userId,
                      'bookingId': selectedBookingId ?? '',
                      'type': selectedProblem,
                      'description': text,
                      'createdAt': DateTime.now().toIso8601String(),
                      'status': 'open',
                      'platform': 'provider_app',
                    });
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reporte enviado')),
                    );
                  },
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // ----------------- Detalle de reserva (Dialog) -----------------
  void _showBookingDetailDialog(
      BuildContext context, Map<String, dynamic> data) {
    final client = (data['clientName'] ?? 'Cliente').toString();
    final title = (data['serviceTitle'] ?? 'Servicio').toString();
    final status = (data['status'] ?? 'pending').toString();
    final price = (data['finalTotal'] ?? data['totalPrice'] ?? 0).toDouble();
    final ts = data['scheduledDate'] ?? data['scheduledDateTime'];
    final when = ts != null ? DateTime.tryParse(ts.toString()) : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detalle de Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio: $title'),
            Text('Cliente: $client'),
            if (when != null)
              Text('Fecha: ${_fmtDate(when)} ${_fmtTime(when)}'),
            Text('Estado: $status'),
            Text('Monto: \$${price.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ----------------- Stats (simples) -----------------
  Future<Map<String, dynamic>> _getStats(String providerId) async {
    final bookings = await Supabase.instance.client
        .from('bookings')
        .select()
        .eq('providerId', providerId);

    int pending = 0;
    int completed = 0;
    int activeServices =
        0; // si tienes colección services, puedes actualizar esto
    double totalEarnings = 0;

    for (final doc in bookings) {
      final d = doc;
      final status = (d['status'] ?? '').toString();
      final amt = (d['finalTotal'] ?? d['totalPrice'] ?? 0).toDouble();
      if (status == 'pending') pending++;
      if (status == 'completed') {
        completed++;
        totalEarnings += amt;
      }
    }

    return {
      'activeServices': activeServices,
      'completedJobs': completed,
      'pendingBookings': pending,
      'totalEarnings': totalEarnings,
    };
  }
}

// ===================================================================
// HISTORIAL del proveedor (pantalla simple)
// ===================================================================
class ProviderHistoryScreen extends StatelessWidget {
  const ProviderHistoryScreen({super.key});

  String? get _uid => Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('bookings')
            .stream(primaryKey: ['id'])
            .map((list) => list.where((b) => b['providerId'] == _uid).toList()
              ..sort((a, b) => (b['createdAt'] ?? '')
                  .toString()
                  .compareTo((a['createdAt'] ?? '').toString())))
            .map((list) => list.take(100).toList()),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Sin historial todavía'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = docs[i];
              final title = (d['serviceTitle'] ?? 'Servicio').toString();
              final client = (d['clientName'] ?? 'Cliente').toString();
              final amount =
                  (d['finalTotal'] ?? d['totalPrice'] ?? 0).toDouble();
              final status = (d['status'] ?? 'pending').toString();
              final ts = d['createdAt'];
              final when = ts != null ? DateTime.tryParse(ts.toString()) : null;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(title),
                  subtitle: Text([
                    client,
                    if (when != null)
                      '${when.day.toString().padLeft(2, '0')}/${when.month.toString().padLeft(2, '0')}/${when.year}',
                    status,
                  ].join(' • ')),
                  trailing: Text('\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===================================================================
// PANTALLA MEJORADA DE NOTIFICACIONES CON ELIMINACIÓN
// ===================================================================
class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() =>
      _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState
    extends State<ProviderNotificationsScreen> {
  String? get _uid => Supabase.instance.client.auth.currentUser?.id;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final stream = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('userId', _uid!)
        .order('createdAt', ascending: false)
        .limit(100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // 🗑️ Botón para eliminar todas las notificaciones
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              final hasNotifications =
                  snapshot.hasData && snapshot.data!.isNotEmpty;

              return PopupMenuButton<String>(
                enabled: hasNotifications && !_isDeleting,
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read,
                            size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Marcar todas como leídas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_read',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep,
                            size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Eliminar leídas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar todas',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'mark_all_read':
                      await _markAllAsRead();
                      break;
                    case 'delete_read':
                      await _deleteReadNotifications();
                      break;
                    case 'delete_all':
                      await _deleteAllNotifications();
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error al cargar notificaciones'),
                ],
              ),
            );
          }

          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sin notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las notificaciones aparecerán aquí',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = docs[i];
              final title = (d['title'] ?? 'Notificación').toString();
              final msg = (d['message'] ?? '').toString();
              final type = (d['type'] ?? '').toString();
              final read = d['read'] == true;
              final createdAtStr = d['createdAt']?.toString();
              final timeAgo = createdAtStr != null
                  ? _getTimeAgo(
                      DateTime.tryParse(createdAtStr) ?? DateTime.now())
                  : '';

              return Card(
                elevation: read ? 1 : 3,
                color: read ? Colors.grey[50] : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: read
                        ? Colors.grey[300]
                        : _getNotificationColor(type).withAlpha(50),
                    child: Icon(
                      _getNotificationIcon(type),
                      color: read ? Colors.grey : _getNotificationColor(type),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: read ? FontWeight.normal : FontWeight.bold,
                      color: read ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          msg,
                          style: TextStyle(
                            color: read ? Colors.grey[500] : Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (timeAgo.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    itemBuilder: (context) => [
                      if (!read)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read,
                                  size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Marcar como leída'),
                            ],
                          ),
                        ),
                      if (read)
                        const PopupMenuItem(
                          value: 'mark_unread',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_unread,
                                  size: 16, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Marcar como no leída'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'mark_read':
                          await _markAsRead(d['id']);
                          break;
                        case 'mark_unread':
                          await _markAsUnread(d['id']);
                          break;
                        case 'delete':
                          await _deleteNotification(d['id']);
                          break;
                      }
                    },
                  ),
                  onTap: () async {
                    // Marcar como leída al tocar
                    if (!read) {
                      await _markAsRead(d['id']);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Obtener icono según tipo de notificación
  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'nueva_reserva':
        return Icons.calendar_today;
      case 'payment':
      case 'pago':
        return Icons.payment;
      case 'message':
      case 'mensaje':
        return Icons.message;
      case 'rating':
      case 'calificacion':
        return Icons.star;
      case 'system':
      case 'sistema':
        return Icons.settings;
      case 'promotion':
      case 'promocion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  // Obtener color según tipo de notificación
  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'nueva_reserva':
        return Colors.blue;
      case 'payment':
      case 'pago':
        return Colors.green;
      case 'message':
      case 'mensaje':
        return Colors.purple;
      case 'rating':
      case 'calificacion':
        return Colors.amber;
      case 'system':
      case 'sistema':
        return Colors.grey;
      case 'promotion':
      case 'promocion':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  // Obtener tiempo transcurrido
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // 📖 Marcar notificación individual como leída
  Future<void> _markAsRead(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (e) {
      _showSnackBar('Error al marcar como leída: $e', Colors.red);
    }
  }

  // 📩 Marcar notificación individual como no leída
  Future<void> _markAsUnread(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'read': false}).eq('id', notificationId);
    } catch (e) {
      _showSnackBar('Error al marcar como no leída: $e', Colors.red);
    }
  }

  // 🗑️ Eliminar notificación individual
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      _showSnackBar('Notificación eliminada', Colors.green);
    } catch (e) {
      _showSnackBar('Error al eliminar: $e', Colors.red);
    }
  }

  // 📖Marcar todas como leídas
  Future<void> _markAllAsRead() async {
    if (_uid == null) return;

    setState(() => _isDeleting = true);

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'read': true})
          .eq('userId', _uid!)
          .eq('read', false);

      // await batch.commit();
      _showSnackBar(
          'Todas las notificaciones marcadas como leídas', Colors.green);
    } catch (e) {
      _showSnackBar('Error al marcar todas como leídas: $e', Colors.red);
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  // 🗑️📖 Eliminar notificaciones leídas
  Future<void> _deleteReadNotifications() async {
    if (_uid == null) return;

    final confirmed = await _showConfirmDialog(
      'Eliminar notificaciones leídas',
      '¿Estás seguro de que quieres eliminar todas las notificaciones leídas?\n\nEsta acción no se puede deshacer.',
      'Eliminar leídas',
      Colors.orange,
    );

    if (!confirmed) return;

    setState(() => _isDeleting = true);

    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('userId', _uid!)
          .eq('read', true);

      // await batch.commit();
      _showSnackBar('Notificaciones leídas eliminadas', Colors.green);
    } catch (e) {
      _showSnackBar('Error al eliminar notificaciones leídas: $e', Colors.red);
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  // 🗑️Eliminar todas las notificaciones
  Future<void> _deleteAllNotifications() async {
    if (_uid == null) return;

    final confirmed = await _showConfirmDialog(
      'Eliminar todas las notificaciones',
      '¿Estás seguro de que quieres eliminar TODAS las notificaciones?\n\nEsta acción no se puede deshacer y perderás todo el historial.',
      'Eliminar todas',
      Colors.red,
    );

    if (!confirmed) return;

    setState(() => _isDeleting = true);

    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('userId', _uid!);

      // await batch.commit();
      _showSnackBar('Todas las notificaciones eliminadas', Colors.green);
    } catch (e) {
      _showSnackBar(
          'Error al eliminar todas las notificaciones: $e', Colors.red);
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  // ❓ Mostrar diálogo de confirmación
  Future<bool> _showConfirmDialog(
      String title, String content, String confirmText, Color color) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Mostrar SnackBar
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
