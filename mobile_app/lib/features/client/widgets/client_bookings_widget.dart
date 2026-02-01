import 'package:flutter_application_manachyna_kusa_2_0/core/extensions/supabase_extensions.dart';
// NUEVO WIDGET: lib/features/client/widgets/client_bookings_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/database_service.dart';
import '../../../shared/widgets/cards/booking_card.dart';
import '../../../shared/widgets/common/loading_widget.dart';

class ClientBookingsWidget extends StatelessWidget {
  const ClientBookingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 16),
        _buildBookingsList(currentUser.uid),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.bookmark_outlined,
            size: 22,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Mis Reservas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/booking-history'),
          child: const Text('Ver todas'),
        ),
      ],
    );
  }

  Widget _buildBookingsList(String clientId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getClientRecentBookings(clientId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: LoadingWidget(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }

        final bookings = snapshot.data!;

        return Column(
          children: [
            ...bookings.map((booking) {
              final data = booking;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookingCard(
                  bookingId: booking['id'].toString(),
                  bookingData: data,
                  isCompact: true,
                ),
              );
            }),

            // Botón para ver más
            if (bookings.length >= 3) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/booking-history'),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver todas mis reservas'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 32,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Haz tu primera reserva!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora los servicios disponibles y encuentra el proveedor perfecto para ti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Scroll al inicio donde están los servicios
              Scrollable.ensureVisible(
                context,
                alignment: 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.search, size: 16),
            label: const Text('Explorar Servicios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al cargar reservas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  'Intenta recargar la página',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
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
