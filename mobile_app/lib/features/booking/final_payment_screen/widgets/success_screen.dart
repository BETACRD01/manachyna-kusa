import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SuccessScreen extends StatelessWidget {
  final DateTime selectedDateTime;
  final Map<String, dynamic> finalBookingData;
  final AnimationController successController;
  final Animation<double> successScaleAnimation;
  final VoidCallback onClose;

  const SuccessScreen({
    super.key,
    required this.selectedDateTime,
    required this.finalBookingData,
    required this.successController,
    required this.successScaleAnimation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.lightBlue, Colors.indigo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Reserva Confirmada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cardWhite.withAlpha(230),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      color: AppColors.cardWhite.withAlpha(204),
                      size: 24,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: successController,
                      builder: (context, child) {
                        return ScaleTransition(
                          scale: successScaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite.withAlpha(51),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cardWhite.withAlpha(77),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              size: 60,
                              color: AppColors.cardWhite,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '¡Reserva Exitosa!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cardWhite,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tu solicitud ha sido enviada al proveedor.\nTe confirmaremos los detalles muy pronto.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.cardWhite.withAlpha(230),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _SuccessInfoCard(
                      selectedDateTime: selectedDateTime,
                      finalBookingData: finalBookingData,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardWhite,
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ir al Inicio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/booking-history');
                    },
                    child: Text(
                      'Ver Mis Reservas',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.cardWhite.withAlpha(204),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.cardWhite.withAlpha(204),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessInfoCard extends StatelessWidget {
  final DateTime selectedDateTime;
  final Map<String, dynamic> finalBookingData;

  const _SuccessInfoCard({
    required this.selectedDateTime,
    required this.finalBookingData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardWhite.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _SuccessInfoRow(
            label: 'Servicio',
            value: finalBookingData['serviceData']?['serviceName'] ?? 'Servicio',
            icon: Icons.build_outlined,
          ),
          const SizedBox(height: 12),
          _SuccessInfoRow(
            label: 'Proveedor',
            value: finalBookingData['selectedProvider']?['providerName'] ?? 
                   finalBookingData['selectedProvider']?['providerData']?['name'] ?? 'Proveedor',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _SuccessInfoRow(
            label: 'Total',
            value: '\$${(finalBookingData['finalTotal'] ?? 0.0).toStringAsFixed(2)}',
            icon: Icons.attach_money_outlined,
          ),
          const SizedBox(height: 12),
          _SuccessInfoRow(
            label: 'Fecha',
            value: '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} - ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
            icon: Icons.schedule_outlined,
          ),
        ],
      ),
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SuccessInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.cardWhite.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cardWhite.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.cardWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}