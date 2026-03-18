import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final bool isSelected;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.mediumGray.withAlpha(77),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? AppColors.primaryColor.withAlpha(38) 
                : Colors.black.withAlpha(20),
            blurRadius: isSelected ? 16 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isSelected ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primaryColor.withAlpha(26),
          highlightColor: AppColors.primaryColor.withAlpha(13),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderHeader(),
                const SizedBox(height: 16),
                _buildProviderDescription(),
                const SizedBox(height: 16),
                _buildProviderStats(),
                const SizedBox(height: 18),
                _buildSelectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderHeader() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.mediumGray.withAlpha(51),
                backgroundImage: provider['profileImage'] != null
                    ? NetworkImage(provider['profileImage'])
                    : null,
                child: provider['profileImage'] == null
                    ? Icon(Icons.person, size: 28, 
                           color: AppColors.textLight.withAlpha(153))
                    : null,
              ),
            ),
            if (provider['isOnline'] == true)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.successColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successColor.withAlpha(77),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      provider['name'] ?? 'Proveedor',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (provider['isVerified'] == true) _buildVerifiedBadge(),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${provider['rating'].toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${provider['totalReviews']} reseñas)',
                    style: TextStyle(
                      fontSize: 12, 
                      color: AppColors.textLight.withAlpha(204),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       const Icon(Icons.location_on_rounded, 
                             size: 12, color: AppColors.accentColor),
                        const SizedBox(width: 2),
                        Text(
                          '${provider['distance'].toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11, 
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderDescription() {
    List<String> specialties = List<String>.from(provider['specialties'] ?? []);
    if (specialties.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray.withAlpha(128),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const  Row(
            children: [
              Icon(Icons.star_outline_rounded, 
                   size: 16, color: AppColors.accentColor),
               SizedBox(width: 6),
              Text(
                'Especialidades',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: specialties.take(3).map((specialty) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Text(
                specialty,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentColor,
            AppColors.accentColor.withAlpha(204)
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withAlpha(77),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Verificado',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStats() {
    return Row(
      children: [
        _buildStatItem(
          Icons.work_history_rounded,
          '${provider['completedJobs']}',
          'trabajos',
          AppColors.successColor,
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          Icons.access_time_rounded,
          provider['responseTime'] ?? '2h',
          'respuesta',
          AppColors.accentColor,
        ),
        const SizedBox(width: 10),
        _buildStatItem(
        Icons.payments_rounded,
       '\$${provider['pricePerHour'].toStringAsFixed(0)}',
         'por hora',
        AppColors.warningColor,
       ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(38),
              color.withAlpha(13),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(51),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(204)
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isSelected 
            ? LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withAlpha(204)],
              )
            : null,
        color: isSelected ? null : AppColors.lightGray.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withAlpha(35)
                        : AppColors.textLight.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.person_add_alt_1_rounded,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isSelected ? 'Seleccionado' : 'Seleccionar Proveedor',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}