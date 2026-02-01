import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ConfirmationContent extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ConfirmationContent({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.successColor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.psychology_rounded,
            color: AppColors.successColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
            children: [
              const TextSpan(
                text: '¿Confirmas que quieres solicitar el servicio a ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: '${provider['name']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
              const TextSpan(
                text: '?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.lightGray.withAlpha(77),
                AppColors.lightGray.withAlpha(25),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mediumGray.withAlpha(77),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.mediumGray.withAlpha(51),
                  backgroundImage: provider['profileImage'] != null
                      ? NetworkImage(provider['profileImage'])
                      : null,
                  child: provider['profileImage'] == null
                      ? const Icon(Icons.person, size: 24, color: AppColors.textLight)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(38),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '${provider['rating'].toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 12, 
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '\$${provider['pricePerHour'].toStringAsFixed(2)}/h',
                             style: const TextStyle(
                              fontSize: 12, 
                              color: AppColors.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}