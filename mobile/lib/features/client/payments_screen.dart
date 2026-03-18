import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../data/services/database_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final DatabaseService _firestoreService = DatabaseService();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: const Color(0xFFF2F2F7),
            title: const Text(
              'Pagos',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Color(0xFF007AFF)),
                onPressed: () => _showPaymentHistory(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de pagos del mes
                  _buildMonthlySummary(),

                  const SizedBox(height: 24),

                  // Métodos de pago
                  _buildPaymentMethods(),

                  const SizedBox(height: 24),

                  // Historial reciente
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Pagos recientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildRecentPayments(),

                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Stream.fromFuture(_firestoreService.getMonthlyPayments(_currentUserId)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        double totalSpent = 0.0;
        int totalPayments = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!) {
            final data = doc;
            final amount = (data['amount'] ?? 0).toDouble();
            if (data['status'] == 'completed') {
              totalSpent += amount;
              totalPayments++;
            }
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF0051FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Resumen del mes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total gastado',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$totalPayments',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'servicios',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: const Text(
            'Métodos de pago',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: Stream.fromFuture(_firestoreService.getUserPaymentMethods(_currentUserId)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GestureDetector(
                onTap: _addPaymentMethod,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Agregar tarjeta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount:
                    snapshot.data!.length + 1, // +1 for add button at end
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index == snapshot.data!.length) {
                    return GestureDetector(
                      onTap: _addPaymentMethod,
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: const Center(
                          child: Icon(Icons.add,
                              color: Color(0xFF007AFF), size: 32),
                        ),
                      ),
                    );
                  }

                  final doc = snapshot.data![index];
                  return _buildPaymentMethodCard(doc['id'], doc);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String methodId, Map<String, dynamic> data) {
    final isDefault = data['isDefault'] ?? false;
    final cardType = (data['cardType'] as String? ?? 'visa').toLowerCase();
    final lastFour = data['lastFour'] ?? '0000';
    final expiryDate = data['expiryDate'] ?? '00/00';
    final holderName = data['holderName'] ?? 'USUARIO';

    // Gradients based on card type - Softer/Pastel Modern Look
    List<Color> getGradientColors(String type) {
      switch (type) {
        case 'visa':
          // Soft Blue
          return [const Color(0xFF4A90E2), const Color(0xFF007AFF)];
        case 'mastercard':
          // Charcoal/Dark Grey instead of pure black
          return [const Color(0xFF4A4A4A), const Color(0xFF2C2C2E)];
        case 'amex':
          // Soft Cyan
          return [const Color(0xFF5AC8FA), const Color(0xFF34AADC)];
        default:
          // Soft Silver
          return [const Color(0xFFD1D1D6), const Color(0xFFAEB0B2)];
      }
    }

    final gradientColors = getGradientColors(cardType);

    return GestureDetector(
      onTap: () => _handlePaymentMethodAction('edit', methodId, data),
      onLongPress: () => _handlePaymentMethodAction('options', methodId, data),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26), // Increased roundness
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.2), // Softer shadow
              blurRadius: 15, // Softer blur
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(_getCardIcon(cardType), color: Colors.white, size: 32),
                if (isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '**** **** **** $lastFour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Courier', // Monospace feel
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      holderName.toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      expiryDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Stream.fromFuture(_firestoreService.getRecentPayments(_currentUserId).then((list) => list.take(10).toList())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tienes pagos registrados',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 70,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            final doc = snapshot.data![index];
            final data = doc;
            return _buildPaymentCard(doc['id'], data);
          },
        );
      },
    );
  }

  Widget _buildPaymentCard(String paymentId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final amount = (data['amount'] ?? 0).toDouble();
    final serviceTitle = data['serviceTitle'] ?? 'Servicio';
    final providerName = data['providerName'] ?? 'Proveedor';
    final date = DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
        DateTime.now();

    return InkWell(
      onTap: () => _showPaymentDetails(paymentId, data),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    providerName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date).split(' ')[0], // Just the date
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // Métodos de utilidad para UI

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
      case 'mastercard':
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Métodos de acción
  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddPaymentMethodSheet(
          userId: _currentUserId,
          onPaymentMethodAdded: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Método de pago agregado exitosamente')),
            );
          },
        ),
      ),
    );
  }

  void _handlePaymentMethodAction(
      String action, String methodId, Map<String, dynamic> data) {
    switch (action) {
      case 'set_default':
        _setDefaultPaymentMethod(methodId);
        break;
      case 'edit':
        _editPaymentMethod(methodId, data);
        break;
      case 'delete':
        _deletePaymentMethod(methodId);
        break;
    }
  }

  void _setDefaultPaymentMethod(String methodId) async {
    try {
      await _firestoreService.setDefaultPaymentMethod(methodId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Método de pago principal actualizado')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _editPaymentMethod(String methodId, Map<String, dynamic> data) {
    // Implementar edición de método de pago
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar método de pago'),
        content: const Text('Funcionalidad en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar método de pago'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este método de pago?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deletePaymentMethod(methodId);

                // Verificar que el widget sigue montado antes de usar context
                if (!context.mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Método de pago eliminado')),
                );
              } catch (e) {
                // Verificar que el widget sigue montado antes de usar context
                if (!context.mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(String paymentId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDetailsDialog(
        paymentId: paymentId,
        paymentData: data,
      ),
    );
  }

  void _showPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHistoryScreen(userId: _currentUserId),
      ),
    );
  }
}

// Widget para agregar método de pago
class _AddPaymentMethodSheet extends StatefulWidget {
  final String userId;
  final VoidCallback onPaymentMethodAdded;

  const _AddPaymentMethodSheet({
    required this.userId,
    required this.onPaymentMethodAdded,
  });

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agregar método de pago',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Número de tarjeta',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Campo requerido';
                if (value!.replaceAll(' ', '').length < 16) {
                  return 'Número inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      hintText: '12/25',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo requerido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo requerido';
                      if (value!.length < 3) return 'CVV inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _holderNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del titular',
                hintText: 'Juan Pérez',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Campo requerido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addPaymentMethod,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Agregar método de pago'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu información está protegida con encriptación de extremo a extremo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final lastFour = cardNumber.substring(cardNumber.length - 4);

      final paymentMethodData = {
        'cardType': _detectCardType(cardNumber),
        'lastFour': lastFour,
        'expiryDate': _expiryController.text,
        'holderName': _holderNameController.text,
        'isDefault': false,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await DatabaseService().addPaymentMethod({
        ...paymentMethodData,
        'userId': widget.userId,
      });
      widget.onPaymentMethodAdded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5')) return 'mastercard';
    if (cardNumber.startsWith('3')) return 'amex';
    return 'other';
  }
}

// Diálogo de detalles de pago
class _PaymentDetailsDialog extends StatelessWidget {
  final String paymentId;
  final Map<String, dynamic> paymentData;

  const _PaymentDetailsDialog({
    required this.paymentId,
    required this.paymentData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalles del pago'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('ID de transacción:', paymentId.substring(0, 8)),
            _buildDetailRow('Servicio:', paymentData['serviceTitle'] ?? 'N/A'),
            _buildDetailRow('Proveedor:', paymentData['providerName'] ?? 'N/A'),
            _buildDetailRow('Monto:',
                '\$${(paymentData['amount'] ?? 0).toStringAsFixed(2)}'),
            _buildDetailRow('Estado:', paymentData['status'] ?? 'N/A'),
            if (paymentData['paymentMethod'] != null)
              _buildDetailRow('Método:',
                  '**** ${paymentData['paymentMethod']['lastFour']}'),
            if (paymentData['transactionId'] != null)
              _buildDetailRow('ID Transacción:', paymentData['transactionId']),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        if (paymentData['status'] == 'completed')
          TextButton(
            onPressed: () {
              // Implementar descarga de recibo
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Descargar recibo'),
          ),
      ],
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
}

// Pantalla de historial completo de pagos
class PaymentHistoryScreen extends StatelessWidget {
  final String userId;

  const PaymentHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            backgroundColor: Color(0xFFF2F2F7),
            title: Text(
              'Historial',
              style: TextStyle(color: Colors.black),
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Stream.fromFuture(DatabaseService().getPaymentHistory(userId)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No hay historial de pagos',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = snapshot.data![index];
                      final amount = (doc['amount'] ?? 0).toDouble();
                      final date = DateTime.tryParse(
                              doc['createdAt']?.toString() ?? '') ??
                          DateTime.now();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // First item rounded top, last item rounded bottom within sections?
                          // For simplicity, just white blocks or grouped look.
                          // Let's do a simple list look.
                          borderRadius: index == 0 && snapshot.data!.length == 1
                              ? BorderRadius.circular(12)
                              : index == 0
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(12))
                                  : index == snapshot.data!.length - 1
                                      ? const BorderRadius.vertical(
                                          bottom: Radius.circular(12))
                                      : BorderRadius.zero,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['serviceTitle'] ?? 'Servicio',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doc['providerName'] ?? 'Proveedor',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '-\$${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
