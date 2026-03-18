enum ServiceCategory {
  cleaning,
  plumbing,
  electrical,
  carpentry,
  gardening,
  painting,
  maintenance,
  other
}

extension ServiceCategoryExtension on ServiceCategory {
  String get value {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'limpieza';
      case ServiceCategory.plumbing:
        return 'plomeria';
      case ServiceCategory.electrical:
        return 'electricidad';
      case ServiceCategory.carpentry:
        return 'carpinteria';
      case ServiceCategory.gardening:
        return 'jardineria';
      case ServiceCategory.painting:
        return 'pintura';
      case ServiceCategory.maintenance:
        return 'mantenimiento';
      case ServiceCategory.other:
        return 'otro';
    }
  }

  String get displayName {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'Limpieza';
      case ServiceCategory.plumbing:
        return 'Plomería';
      case ServiceCategory.electrical:
        return 'Electricidad';
      case ServiceCategory.carpentry:
        return 'Carpintería';
      case ServiceCategory.gardening:
        return 'Jardinería';
      case ServiceCategory.painting:
        return 'Pintura';
      case ServiceCategory.maintenance:
        return 'Mantenimiento';
      case ServiceCategory.other:
        return 'Otro';
    }
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final ServiceCategory category;
  final double basePrice;
  final double hourlyRate;
  final String providerId;
  final String providerName;
  final double rating;
  final int totalReviews;
  final bool isActive;
  final bool isAvailable;
  final List<String> images;
  final Map<String, dynamic> pricing;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.hourlyRate,
    required this.providerId,
    required this.providerName,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    this.isAvailable = true,
    this.images = const [],
    this.pricing = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: stringToCategory(json['category'] ?? 'otro'),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isActive: json['isActive'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      pricing: Map<String, dynamic>.from(json['pricing'] ?? {}),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDateNullable(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.value,
      'basePrice': basePrice,
      'hourlyRate': hourlyRate,
      'providerId': providerId,
      'providerName': providerName,
      'rating': rating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'images': images,
      'pricing': pricing,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  static ServiceCategory stringToCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'limpieza':
        return ServiceCategory.cleaning;
      case 'plomeria':
        return ServiceCategory.plumbing;
      case 'electricidad':
        return ServiceCategory.electrical;
      case 'carpinteria':
        return ServiceCategory.carpentry;
      case 'jardineria':
        return ServiceCategory.gardening;
      case 'pintura':
        return ServiceCategory.painting;
      case 'mantenimiento':
        return ServiceCategory.maintenance;
      default:
        return ServiceCategory.other;
    }
  }

  ServiceModel copyWith({
    String? title,
    String? description,
    ServiceCategory? category,
    double? basePrice,
    double? hourlyRate,
    String? providerId,
    String? providerName,
    double? rating,
    int? totalReviews,
    bool? isActive,
    bool? isAvailable,
    List<String>? images,
    Map<String, dynamic>? pricing,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      images: images ?? this.images,
      pricing: pricing ?? this.pricing,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, title: $title, category: ${category.displayName}, price: \$${basePrice.toStringAsFixed(2)})';
  }
}
