class SolicitudModel {
  final String id;
  final String? fullName;
  final String? groupName;
  final String? userEmail;
  final String? description;
  final String providerType;

  SolicitudModel({
    required this.id,
    this.fullName,
    this.groupName,
    this.userEmail,
    this.description,
    required this.providerType,
  });

  factory SolicitudModel.fromMap(Map<String, dynamic> data) {
    return SolicitudModel(
      id: data['id'] ?? '',
      fullName: data['fullName'] as String?,
      groupName: data['groupName'] as String?,
      userEmail: data['userEmail'] as String?,
      description: data['description'] as String?,
      providerType: data['providerType'] as String? ?? 'unknown',
    );
  }
}
