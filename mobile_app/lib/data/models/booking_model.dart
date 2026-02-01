enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected
}

extension BookingStatusExtension on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.inProgress:
        return 'En Progreso';
      case BookingStatus.completed:
        return 'Completada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.rejected:
        return 'Rechazada';
    }
  }
}

class BookingModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceTitle;
  final double totalPrice;
  final DateTime scheduledDate;
  final String address;
  final String? notes;
  final BookingStatus status;
  final int estimatedHours;
  final bool hasRated;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceTitle,
    required this.totalPrice,
    required this.scheduledDate,
    required this.address,
    this.notes,
    this.status = BookingStatus.pending,
    this.estimatedHours = 1,
    this.hasRated = false,
    this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      clientId: json['client_id'] ?? '',
      clientName: json['client_name'] ?? '',
      clientPhone: json['client_phone'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      scheduledDate: _parseDate(json['date']),
      address: json['address'] ?? '',
      notes: json['notes'],
      status: _stringToStatus(json['status'] ?? 'pending'),
      estimatedHours: json['estimated_hours'] ?? 1,
      hasRated: json['has_rated'] ?? false,
      rating: json['rating']?.toDouble(),
      review: json['review'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDateNullable(json['updated_at']),
      completedAt: _parseDateNullable(json['completed_at']),
      cancelledAt: _parseDateNullable(json['cancelled_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'provider_id': providerId,
      'provider_name': providerName,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'total_price': totalPrice,
      'date': scheduledDate.toIso8601String(),
      'address': address,
      'notes': notes,
      'status': status.value,
      'estimated_hours': estimatedHours,
      'has_rated': hasRated,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    // Fallback for unexpected types
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  static BookingStatus _stringToStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  BookingModel copyWith({
    String? clientName,
    String? clientPhone,
    String? providerName,
    String? serviceTitle,
    double? totalPrice,
    DateTime? scheduledDate,
    String? address,
    String? notes,
    BookingStatus? status,
    int? estimatedHours,
    bool? hasRated,
    double? rating,
    String? review,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return BookingModel(
      id: id,
      clientId: clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      providerId: providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      totalPrice: totalPrice ?? this.totalPrice,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      hasRated: hasRated ?? this.hasRated,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get canBeCancelled {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }

  bool get canBeRated {
    return status == BookingStatus.completed && !hasRated;
  }

  String get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return '#FF9800';
      case BookingStatus.confirmed:
        return '#4CAF50';
      case BookingStatus.inProgress:
        return '#2196F3';
      case BookingStatus.completed:
        return '#4CAF50';
      case BookingStatus.cancelled:
        return '#F44336';
      case BookingStatus.rejected:
        return '#F44336';
    }
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, service: $serviceTitle, status: ${status.displayName}, total: \$${totalPrice.toStringAsFixed(2)})';
  }
}
