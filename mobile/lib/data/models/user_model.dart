enum UserRole { client, provider, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  // Campos adicionales para estadísticas
  final bool isVerified;
  final int totalBookings;
  final double rating;
  final List<String> favorites;
  final int completedJobs;
  final int joinDate; // Keep as int for compatibility, but populated from Date
  final int lastActive; // Keep as int for compatibility

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
    this.address,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.favorites = const [],
    this.completedJobs = 0,
    required this.joinDate,
    required this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    final created = parseDate(json['createdAt']);

    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _stringToUserRole(json['role'] ?? 'client'),
      photoUrl: json['photoUrl'],
      phone: json['phone'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      createdAt: created,
      updatedAt:
          json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      isVerified: json['isVerified'] as bool? ?? false,
      totalBookings: json['totalBookings'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      favorites: List<String>.from(json['favorites'] as List? ?? []),
      completedJobs: json['completedJobs'] as int? ?? 0,
      joinDate: json['joinDate'] as int? ?? created.millisecondsSinceEpoch,
      lastActive:
          json['lastActive'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'phone': phone,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'isVerified': isVerified,
      'totalBookings': totalBookings,
      'rating': rating,
      'favorites': favorites,
      'completedJobs': completedJobs,
      'joinDate': joinDate,
      'lastActive': lastActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? photoUrl,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    int? totalBookings,
    double? rating,
    List<String>? favorites,
    int? completedJobs,
    int? joinDate,
    int? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      favorites: favorites ?? this.favorites,
      completedJobs: completedJobs ?? this.completedJobs,
      joinDate: joinDate ?? this.joinDate,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.provider:
        return 'Proveedor';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  bool get isClient => role == UserRole.client;
  bool get isProvider => role == UserRole.provider;
  bool get isAdmin => role == UserRole.admin;

  static UserRole _stringToUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'client':
        return UserRole.client;
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.client;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
