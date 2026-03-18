import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/base_api_service.dart';
import 'dart:io';

// Pantalla de perfil del proveedor para Mañachyna Kusa 2.0
// Mejoras: Carga de imagen optimizada, manejo de foco para evitar conflictos de teclado,
// estética refinada de Banco Pichincha, todas las funcionalidades preservadas
// Compatible con ProviderDashboard mediante constructor const
// Documentado en español para escalabilidad y mantenibilidad

// --- Logger ---
final Logger logger = Logger();

// --- Colores Personalizados ---
const Color verdeSelva = Color(0xFF1A3C34);
const Color azulClaroMedio = Color(0xFF4A90E2);
const Color blancoFondo = Color(0xFFF5F7FA);
const Color grisSuave = Color(0xFF999999);
const Color grisClaro = Color(0xFFE0E0E0);
const Color grisOscuro = Color(0xFF2C3E50);

// --- Modelos ---

/// Modelo para el perfil del proveedor
class ProviderModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int completedJobs;
  final int experienceYears;
  final String location;
  final String phone;
  final String email;
  final String availability;
  final double hourlyRate;
  final List<String> services;
  final bool isVerified;
  final String? profileImage;
  final bool isActive;
  final String? bankName;
  final String? accountType;
  final String? accountNumber;
  final String? accountHolderName;

  ProviderModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.completedJobs,
    required this.experienceYears,
    required this.location,
    required this.phone,
    required this.email,
    required this.availability,
    required this.hourlyRate,
    required this.services,
    required this.isVerified,
    this.profileImage,
    required this.isActive,
    this.bankName,
    this.accountType,
    this.accountNumber,
    this.accountHolderName,
  });

  factory ProviderModel.fromMap(Map<String, dynamic> data) {
    try {
      return ProviderModel(
        // Conversión segura para String
        id: _safeString(data['id']),
        name: _safeString(data['name'], 'Sin nombre'),
        specialty: _safeString(data['specialty'], 'General'),
        location: _safeString(data['location'], 'Tena, Napo'),
        phone: _safeString(data['phone']),
        email: _safeString(data['email']),
        availability: _safeString(data['availability'], 'Disponible'),
        profileImage: _safeString(data['profileImage']),
        bankName: _safeString(data['bankName']),
        accountType: _safeString(data['accountType']),
        accountNumber: _safeString(data['accountNumber']),
        accountHolderName: _safeString(data['accountHolderName']),

        // Conversión segura para double
        rating: _safeDouble(data['rating'], 4.0),
        hourlyRate: _safeDouble(data['hourlyRate'], 15.0),

        // Conversión segura para int
        completedJobs: _safeInt(data['completedJobs'], 0),
        experienceYears: _safeInt(data['experienceYears'], 0),

        // Conversión segura para bool
        isVerified: _safeBool(data['isVerified'], false),
        isActive: _safeBool(data['isActive'], true),

        // Conversión segura para List<String>
        services: _safeStringList(data['services']),
      );
    } catch (e) {
      logger.e('🚨 Error en ProviderModel.fromMap: $e');
      logger.e('Datos recibidos: $data');
      rethrow;
    }
  }

// MÉTODOS AUXILIARES - Agregar DENTRO de la clase ProviderModel

  static String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map || value is List) {
      logger.w(
          'Valor es ${value.runtimeType}, esperaba String. Usando valor por defecto.');
      return defaultValue;
    }
    return value.toString();
  }

  static double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is Map || value is List) {
      logger.w(
          'Valor es ${value.runtimeType}, esperaba número. Usando valor por defecto.');
      return defaultValue;
    }
    logger.w('No se pudo convertir $value a double. Usando valor por defecto.');
    return defaultValue;
  }

  static int _safeInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is Map || value is List) {
      logger.w(
          'Valor es ${value.runtimeType}, esperaba número. Usando valor por defecto.');
      return defaultValue;
    }
    logger.w('No se pudo convertir $value a int. Usando valor por defecto.');
    return defaultValue;
  }

  static bool _safeBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value == 1;
    if (value is Map || value is List) {
      logger.w(
          'Valor es ${value.runtimeType}, esperaba bool. Usando valor por defecto.');
      return defaultValue;
    }
    logger.w('No se pudo convertir $value a bool. Usando valor por defecto.');
    return defaultValue;
  }

  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.map((item) {
          if (item == null) return '';
          if (item is String) return item;
          if (item is Map || item is List) return 'Elemento complejo';
          return item.toString();
        }).toList();
      } catch (e) {
        logger.w('Error al convertir lista: $e');
        return [];
      }
    }
    if (value is String) return [value];
    logger.w(
        'Valor es ${value.runtimeType}, esperaba List. Retornando lista vacía.');
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'completedJobs': completedJobs,
      'experienceYears': experienceYears,
      'location': location,
      'phone': phone,
      'email': email,
      'availability': availability,
      'hourlyRate': hourlyRate,
      'services': services,
      'isVerified': isVerified,
      'profileImage': profileImage,
      'isActive': isActive,
      'bankName': bankName,
      'accountType': accountType,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
    };
  }
}

// --- Servicios ---

/// Servicio para interactuar con el backend Django
class DatabaseService {
  final BaseApiService _apiService = BaseApiService();

  /// Obtiene un documento del proveedor por ID
  Future<Map<String, dynamic>> getProvider(String providerId) async {
    return await _apiService.get('providers/$providerId/');
  }

  Future<Map<String, dynamic>?> getProviderById(String providerId) async {
    try {
      final response = await _apiService.get('providers/$providerId/');
      return response;
    } catch (e) {
      logger.e('Error getting provider by ID from Django: $e');
      return null;
    }
  }

  /// Obtiene reservas del proveedor
  Future<List<Map<String, dynamic>>> getProviderBookings(
      String providerId) async {
    final response = await _apiService.get('bookings/?provider_id=$providerId');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return [];
  }

  /// Actualiza datos del proveedor
  Future<void> updateProvider(
      String providerId, Map<String, dynamic> data) async {
    try {
      await _apiService.patch('providers/$providerId/', body: data);
    } catch (e) {
      logger.e('🚨 Error al actualizar proveedor en Django: $e');
      rethrow;
    }
  }

  /// Carga una imagen a Django y devuelve la URL
  Future<String> uploadImage(File image, String providerId) async {
    try {
      final response = await _apiService.postMultipart(
        'users/upload-profile-image/',
        file: image,
      );
      return response['url'];
    } catch (e) {
      logger.e('🚨 Error al cargar imagen a Django: $e');
      rethrow;
    }
  }
}

/// Servicio para gestionar datos del perfil y reservas
class _ProviderProfileService {
  final DatabaseService _firestoreService;
  final String? _providerId;

  const _ProviderProfileService({
    required DatabaseService firestoreService,
    required String? providerId,
  })  : _firestoreService = firestoreService,
        _providerId = providerId;

  Future<ProviderModel> getProviderProfile() async {
    if (_providerId == null) {
      logger.e('🚨 No se encontró usuario autenticado');
      throw Exception('No hay usuario autenticado');
    }
    logger.d('Obteniendo perfil del proveedor para ID: $_providerId');

    final data = await _firestoreService.getProvider(_providerId!);
    if (data.isEmpty) {
      logger.w('No se encontraron datos del proveedor para ID: $_providerId');
      throw Exception('Proveedor no encontrado');
    }

    try {
      logger.d('Datos del proveedor recibidos: ${data.keys.toList()}');
      return ProviderModel.fromMap(data);
    } catch (e) {
      logger.e('🚨 Error al crear ProviderModel: $e');
      logger.e('Datos problemáticos: $data');
      throw Exception('Error al procesar datos del proveedor: $e');
    }
  }

  Future<List<BookingModel>> getProviderBookings() async {
    if (_providerId == null) {
      logger.e('🚨 No se encontró usuario autenticado');
      throw Exception('No hay usuario autenticado');
    }

    logger.d('Obteniendo reservas del proveedor para ID: $_providerId');

    final bookingsList =
        await _firestoreService.getProviderBookings(_providerId!);
    return bookingsList
        .map((data) {
          try {
            return BookingModel.fromJson(data, data['id']?.toString() ?? '');
          } catch (e, stackTrace) {
            logger.e(
              '🚨 Error al procesar reserva ${data['id']}',
              error: e,
              stackTrace: stackTrace,
            );
            return null;
          }
        })
        .whereType<BookingModel>()
        .toList();
  }

  Future<void> updateAvailability(bool isActive, BuildContext context) async {
    if (_providerId == null) {
      logger.e('🚨 No se encontró usuario autenticado');
      throw Exception('No hay usuario autenticado');
    }
    logger.d('Actualizando disponibilidad del proveedor a: $isActive');
    try {
      await _firestoreService
          .updateProvider(_providerId!, {'isActive': isActive});
      logger.d('Disponibilidad actualizada correctamente');
    } catch (e) {
      logger.e('🚨 Error al actualizar disponibilidad: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar disponibilidad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> uploadProfileImage(
      BuildContext context, ImageSource source) async {
    if (_providerId == null) {
      logger.e('🚨 No se encontró usuario autenticado');
      throw Exception('No hay usuario autenticado');
    }
    try {
      final permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;
      final status = await permission.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Permiso denegado para acceder a la cámara o galería'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        logger.w('No se seleccionó ninguna imagen');
        return;
      }

      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen excede el tamaño máximo de 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                CircularProgressIndicator(color: azulClaroMedio),
                SizedBox(width: 12),
                Text('Cargando imagen...'),
              ],
            ),
            backgroundColor: verdeSelva,
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final imageUrl = await _firestoreService.uploadImage(file, _providerId!);
      await _firestoreService
          .updateProvider(_providerId!, {'profileImage': imageUrl});

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen de perfil actualizada'),
            backgroundColor: verdeSelva,
          ),
        );
      }
    } catch (e) {
      logger.e('🚨 Error al cargar imagen: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// --- Utilidades ---

/// Clase auxiliar para elementos de UI
class _ServiceHelper {
  const _ServiceHelper();

  Color getServiceColor(int index) {
    const colors = [
      azulClaroMedio,
      verdeSelva,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  Color getBookingStatusColor(BookingModel booking) {
    return Color(int.parse('0xFF${booking.statusColor.substring(1)}'));
  }
}

// --- Widgets ---

/// Widget para estadísticas del proveedor
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  color: grisOscuro,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: grisSuave,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Widget para filas de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: azulClaroMedio),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: grisSuave,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: grisOscuro,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para chips de servicios
class _ServiceChip extends StatelessWidget {
  final String service;
  final Color color;

  const _ServiceChip({
    required this.service,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        service,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontFamily: 'Roboto',
              color: color,
            ),
      ),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Widget para mosaicos de opciones
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: azulClaroMedio, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              fontFamily: 'Roboto',
              color: grisOscuro,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: grisSuave,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: grisSuave),
      onTap: onTap,
    );
  }
}

// Diálogos para acciones del perfil

// =============================================================================
// BLOQUE 1: EDICIÓN DE PERFIL
// =============================================================================

/// Widget para editar el perfil del proveedor
class _EditProfileSection extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onSaved;

  const _EditProfileSection({
    required this.provider,
    required this.onSaved,
  });

  @override
  _EditProfileSectionState createState() => _EditProfileSectionState();
}

class _EditProfileSectionState extends State<_EditProfileSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _hourlyRateController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _specialtyController =
        TextEditingController(text: widget.provider.specialty);
    _locationController = TextEditingController(text: widget.provider.location);
    _phoneController = TextEditingController(text: widget.provider.phone);
    _emailController = TextEditingController(text: widget.provider.email);
    _hourlyRateController =
        TextEditingController(text: widget.provider.hourlyRate.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await DatabaseService().updateProvider(userId, {
          'name': _nameController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          'location': _locationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'hourlyRate': double.parse(_hourlyRateController.text),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: verdeSelva,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Campo requerido';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hourlyRateController,
              decoration: const InputDecoration(
                labelText: 'Tarifa por Hora (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Campo requerido';
                if (double.tryParse(value!) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeSelva,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: blancoFondo)
                  : const Text('Guardar Cambios',
                      style: TextStyle(color: blancoFondo)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BLOQUE 2: GESTIÓN DE SERVICIOS
// =============================================================================

/// Widget para gestionar servicios del proveedor
class _ServicesManagementSection extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onSaved;

  const _ServicesManagementSection({
    required this.provider,
    required this.onSaved,
  });

  @override
  _ServicesManagementSectionState createState() =>
      _ServicesManagementSectionState();
}

class _ServicesManagementSectionState
    extends State<_ServicesManagementSection> {
  late List<String> _services;
  final _serviceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _services = List.from(widget.provider.services);
  }

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  void _addService() {
    final service = _serviceController.text.trim();
    if (service.isNotEmpty && !_services.contains(service)) {
      setState(() {
        _services.add(service);
        _serviceController.clear();
      });
    }
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _saveServices() async {
    setState(() => _isLoading = true);

    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await DatabaseService().updateProvider(userId, {
          'services': _services,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicios actualizados correctamente'),
              backgroundColor: verdeSelva,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar servicios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo Servicio',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Plomería, Electricidad',
                    ),
                    onSubmitted: (_) => _addService(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulClaroMedio,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add, color: blancoFondo),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.build, color: azulClaroMedio),
                    title: Text(_services[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeService(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveServices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeSelva,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: blancoFondo)
                    : const Text('Guardar Servicios',
                        style: TextStyle(color: blancoFondo)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BLOQUE 3: CONFIGURACIÓN DE DISPONIBILIDAD
// =============================================================================

/// Widget para configurar disponibilidad del proveedor
class _AvailabilitySection extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onSaved;

  const _AvailabilitySection({
    required this.provider,
    required this.onSaved,
  });

  @override
  _AvailabilitySectionState createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<_AvailabilitySection> {
  final Map<String, bool> _workingDays = {
    'Lunes': true,
    'Martes': true,
    'Miércoles': true,
    'Jueves': true,
    'Viernes': true,
    'Sábado': true,
    'Domingo': false,
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = false;

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);

    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final workingDaysList = _workingDays.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        final availabilityText = '${workingDaysList.join(', ')}: '
            '${_startTime.format(context)} - ${_endTime.format(context)}';

        await DatabaseService().updateProvider(userId, {
          'availability': availabilityText,
          'workingDays': workingDaysList,
          'startTime': '${_startTime.hour}:${_startTime.minute}',
          'endTime': '${_endTime.hour}:${_endTime.minute}',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disponibilidad actualizada correctamente'),
              backgroundColor: verdeSelva,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar disponibilidad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Disponibilidad'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Días de Trabajo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ..._workingDays.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (bool? value) {
                        setState(() {
                          _workingDays[entry.key] = value ?? false;
                        });
                      },
                      activeColor: verdeSelva,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios de Trabajo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Hora de Inicio'),
                          subtitle: Text(_startTime.format(context)),
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Hora de Fin'),
                          subtitle: Text(_endTime.format(context)),
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveAvailability,
            style: ElevatedButton.styleFrom(
              backgroundColor: verdeSelva,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: blancoFondo)
                : const Text('Guardar Disponibilidad',
                    style: TextStyle(color: blancoFondo)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BLOQUE 4: CONFIGURACIÓN DE NOTIFICACIONES
// =============================================================================

/// Widget para configurar notificaciones del proveedor
class _NotificationsSection extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onSaved;

  const _NotificationsSection({
    required this.provider,
    required this.onSaved,
  });

  @override
  _NotificationsSectionState createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _newBookings = true;
  bool _bookingUpdates = true;
  bool _messages = true;
  bool _payments = true;
  bool _promotions = false;
  bool _isLoading = false;

  Future<void> _saveNotificationSettings() async {
    setState(() => _isLoading = true);

    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await DatabaseService().updateProvider(userId, {
          'notificationSettings': {
            'newBookings': _newBookings,
            'bookingUpdates': _bookingUpdates,
            'messages': _messages,
            'payments': _payments,
            'promotions': _promotions,
          },
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuración de notificaciones guardada'),
              backgroundColor: verdeSelva,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Notificaciones'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Nuevas Reservas'),
                  subtitle: const Text(
                      'Recibir notificaciones de nuevas solicitudes'),
                  value: _newBookings,
                  onChanged: (value) => setState(() => _newBookings = value),
                  activeThumbColor: verdeSelva,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Actualizaciones de Reservas'),
                  subtitle: const Text('Cambios en el estado de las reservas'),
                  value: _bookingUpdates,
                  onChanged: (value) => setState(() => _bookingUpdates = value),
                  activeThumbColor: verdeSelva,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Mensajes'),
                  subtitle: const Text('Nuevos mensajes de clientes'),
                  value: _messages,
                  onChanged: (value) => setState(() => _messages = value),
                  activeThumbColor: verdeSelva,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Pagos'),
                  subtitle:
                      const Text('Confirmaciones de pago y transferencias'),
                  value: _payments,
                  onChanged: (value) => setState(() => _payments = value),
                  activeThumbColor: verdeSelva,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Promociones'),
                  subtitle: const Text('Ofertas especiales y promociones'),
                  value: _promotions,
                  onChanged: (value) => setState(() => _promotions = value),
                  activeThumbColor: verdeSelva,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveNotificationSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: verdeSelva,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: blancoFondo)
                : const Text('Guardar Configuración',
                    style: TextStyle(color: blancoFondo)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BLOQUE 5: AYUDA Y SOPORTE
// =============================================================================

/// Widget para ayuda y soporte del proveedor
class _HelpSupportSection extends StatelessWidget {
  const _HelpSupportSection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline, color: azulClaroMedio),
              title: const Text('Preguntas Frecuentes'),
              children: [
                _buildFAQItem(
                  '¿Cómo actualizo mi perfil?',
                  'Ve a "Editar Perfil" desde tu pantalla principal y modifica la información necesaria.',
                ),
                _buildFAQItem(
                  '¿Cómo agrego nuevos servicios?',
                  'En "Gestionar Servicios" puedes agregar, editar o eliminar los servicios que ofreces.',
                ),
                _buildFAQItem(
                  '¿Cómo configuro mi disponibilidad?',
                  'En "Disponibilidad" puedes establecer tus días y horarios de trabajo.',
                ),
                _buildFAQItem(
                  '¿Cuándo recibo los pagos?',
                  'Los pagos se procesan automáticamente después de completar cada trabajo.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: azulClaroMedio),
                  title: const Text('Soporte Telefónico'),
                  subtitle: const Text('Lunes a Viernes: 8:00 AM - 6:00 PM'),
                  trailing: const Text('+593 99 123 4567'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email, color: azulClaroMedio),
                  title: const Text('Soporte por Email'),
                  subtitle: const Text('Respuesta en 24 horas'),
                  trailing: const Text('soporte@manachyna.com'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.chat, color: azulClaroMedio),
                  title: const Text('Chat en Vivo'),
                  subtitle: const Text('Disponible 24/7'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: const Text('Reportar un Problema'),
                  subtitle: const Text('Ayúdanos a mejorar la aplicación'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showReportDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Calificar la App'),
                  subtitle: const Text('Comparte tu experiencia'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(answer),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe el problema que encontraste...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado. Gracias por tu feedback.'),
                  backgroundColor: verdeSelva,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: verdeSelva),
            child: const Text('Enviar', style: TextStyle(color: blancoFondo)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BLOQUE 6: POLÍTICAS DEL PROVEEDOR
// =============================================================================

/// Widget para políticas del proveedor
class _PoliciesSection extends StatelessWidget {
  const _PoliciesSection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas del Proveedor'),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPolicyCard(
            'Términos de Servicio',
            'Como proveedor de servicios en Mañachyna Kusa, te comprometes a:\n\n'
                '• Brindar servicios de calidad y profesionales\n'
                '• Cumplir con los horarios acordados\n'
                '• Mantener comunicación clara con los clientes\n'
                '• Respetar las tarifas establecidas\n'
                '• Seguir las normas de seguridad aplicables',
            Icons.description,
          ),
          _buildPolicyCard(
            'Política de Pagos',
            'Información sobre pagos y comisiones:\n\n'
                '• Los pagos se procesan automáticamente\n'
                '• Comisión de plataforma: 10% por servicio\n'
                '• Pagos disponibles en 24-48 horas\n'
                '• Métodos de pago: transferencia bancaria\n'
                '• Soporte para resolución de disputas',
            Icons.payment,
          ),
          _buildPolicyCard(
            'Política de Cancelaciones',
            'Normas para cancelaciones de servicios:\n\n'
                '• Cancelación gratuita hasta 2 horas antes\n'
                '• Cancelaciones tardías pueden generar penalización\n'
                '• Emergencias justificadas están exentas\n'
                '• Clientes pueden cancelar hasta 1 hora antes\n'
                '• Reembolsos según política de la plataforma',
            Icons.cancel,
          ),
          _buildPolicyCard(
            'Código de Conducta',
            'Comportamiento esperado de los proveedores:\n\n'
                '• Trato respetuoso y profesional\n'
                '• Puntualidad en las citas\n'
                '• Honestidad en la descripción de servicios\n'
                '• Respeto por la privacidad del cliente\n'
                '• Cumplimiento de normas locales',
            Icons.people,
          ),
          _buildPolicyCard(
            'Privacidad y Datos',
            'Protección de información personal:\n\n'
                '• Tus datos están protegidos y encriptados\n'
                '• No compartimos información con terceros\n'
                '• Puedes solicitar eliminación de datos\n'
                '• Acceso controlado a información de clientes\n'
                '• Cumplimiento con regulaciones de privacidad',
            Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: azulClaroMedio),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogos para acciones del perfil
class _ProfileDialogs {
  const _ProfileDialogs();

  static void showEditProfileDialog(
      BuildContext context, ProviderModel provider, VoidCallback onSaved) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _EditProfileSection(provider: provider, onSaved: onSaved),
      ),
    );
  }

  static void showManageServicesDialog(
      BuildContext context, ProviderModel provider, VoidCallback onSaved) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _ServicesManagementSection(provider: provider, onSaved: onSaved),
      ),
    );
  }

  static void showConfigureAvailabilityDialog(
      BuildContext context, ProviderModel provider, VoidCallback onSaved) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _AvailabilitySection(provider: provider, onSaved: onSaved),
      ),
    );
  }

  static void showNotificationsDialog(
      BuildContext context, ProviderModel provider, VoidCallback onSaved) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _NotificationsSection(provider: provider, onSaved: onSaved),
      ),
    );
  }

  static void showHelpSupportDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _HelpSupportSection(),
      ),
    );
  }

  static void showPoliciesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _PoliciesSection(),
      ),
    );
  }

  /// Muestra diálogo para configurar datos bancarios
  static void showConfigureBankDataDialog(BuildContext context,
      {VoidCallback? onSaved}) {
    final bankNameController = TextEditingController();
    final accountTypeController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountHolderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Configurar Datos Bancarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Banco',
                  hintText: 'Ej: Banco del Pichincha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: null,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cuenta',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Cuenta Corriente',
                      child: Text('Cuenta Corriente')),
                  DropdownMenuItem(
                      value: 'Cuenta de Ahorros',
                      child: Text('Cuenta de Ahorros')),
                ],
                onChanged: (value) {
                  accountTypeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Cuenta',
                  hintText: 'Ej: 2100123456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Titular de la Cuenta',
                  hintText: 'Nombre completo del titular',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (bankNameController.text.isNotEmpty &&
                  accountTypeController.text.isNotEmpty &&
                  accountNumberController.text.isNotEmpty &&
                  accountHolderController.text.isNotEmpty) {
                try {
                  final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await DatabaseService().updateProvider(userId, {
                      'bankName': bankNameController.text,
                      'accountType': accountTypeController.text,
                      'accountNumber': accountNumberController.text,
                      'accountHolderName': accountHolderController.text,
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Datos bancarios guardados correctamente'),
                          backgroundColor: verdeSelva,
                        ),
                      );
                      onSaved?.call();
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar datos bancarios: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor complete todos los campos'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: verdeSelva),
            child: const Text('Guardar', style: TextStyle(color: blancoFondo)),
          ),
        ],
      ),
    );
  }

  static void showToggleAvailabilityDialog(BuildContext context,
      _ProviderProfileService service, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => FocusScope(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(currentStatus ? 'Pausar Servicios' : 'Activar Servicios'),
          content: Text(
            currentStatus
                ? '¿Estás seguro de que quieres pausar temporalmente tus servicios? No recibirás nuevas solicitudes de trabajo.'
                : '¿Estás seguro de que quieres activar tus servicios? Comenzarás a recibir solicitudes de trabajo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: grisSuave)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await service.updateAvailability(!currentStatus, context);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentStatus
                              ? 'Servicios pausados temporalmente'
                              : 'Servicios activados',
                        ),
                        backgroundColor: verdeSelva,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar disponibilidad: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStatus ? Colors.orange : verdeSelva,
                foregroundColor: blancoFondo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                shadowColor: Colors.black.withValues(alpha: 0.2),
                elevation: 2,
              ),
              child: Text(
                currentStatus ? 'Pausar' : 'Activar',
                style: const TextStyle(color: blancoFondo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FocusScope(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: grisSuave)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: blancoFondo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                shadowColor: Colors.black.withValues(alpha: 0.2),
                elevation: 2,
              ),
              child: const Text('Cerrar Sesión',
                  style: TextStyle(color: blancoFondo)),
            ),
          ],
        ),
      ),
    );
  }

  static void showImagePickerDialog(
      BuildContext context, _ProviderProfileService service) {
    showDialog(
      context: context,
      builder: (context) => FocusScope(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Seleccionar Imagen de Perfil'),
          content: const Text('Elige la fuente de la imagen:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  service.uploadProfileImage(context, ImageSource.gallery);
                });
              },
              child: const Text('Galería',
                  style: TextStyle(color: azulClaroMedio)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  service.uploadProfileImage(context, ImageSource.camera);
                });
              },
              child:
                  const Text('Cámara', style: TextStyle(color: azulClaroMedio)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: grisSuave)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla de perfil del proveedor
class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with TickerProviderStateMixin {
  ProviderModel? provider;
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _loadProviderData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderData() async {
    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final providerData = await DatabaseService().getProviderById(userId);
        if (providerData != null) {
          setState(() {
            provider = ProviderModel.fromMap(providerData);
            isLoading = false;
          });
          if (provider?.isVerified == true) {
            _animationController.forward();
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildBankInfoSection() {
    if (provider?.bankName != null &&
        provider?.accountNumber != null &&
        provider?.accountType != null &&
        provider?.accountHolderName != null) {
      // Show existing bank info
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: blancoFondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grisClaro),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: azulClaroMedio, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Datos Bancarios',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      color: grisOscuro,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: azulClaroMedio, size: 20),
                  onPressed: () => _ProfileDialogs.showConfigureBankDataDialog(
                    context,
                    onSaved: _loadProviderData,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBankDetailRow('Banco:', provider!.bankName!),
            _buildBankDetailRow('Tipo de Cuenta:', provider!.accountType!),
            _buildBankDetailRow('Número de Cuenta:', provider!.accountNumber!),
            _buildBankDetailRow('Titular:', provider!.accountHolderName!),
          ],
        ),
      );
    } else {
      return _OptionTile(
        icon: Icons.account_balance_outlined,
        title: 'Datos Bancarios',
        subtitle: 'Configura tu cuenta bancaria',
        onTap: () => _ProfileDialogs.showConfigureBankDataDialog(
          context,
          onSaved: _loadProviderData,
        ),
      );
    }
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: grisSuave,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: grisOscuro,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = _ProviderProfileService(
      firestoreService: DatabaseService(),
      providerId: fb_auth.FirebaseAuth.instance.currentUser?.uid,
    );
    const serviceHelper = _ServiceHelper();

    return Scaffold(
      backgroundColor: blancoFondo,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        backgroundColor: verdeSelva,
        foregroundColor: blancoFondo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => provider != null
                ? _ProfileDialogs.showEditProfileDialog(
                    context, provider!, _loadProviderData)
                : null,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [verdeSelva, azulClaroMedio],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.3, 0.7],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: azulClaroMedio),
            )
          : provider == null
              ? Center(
                  child: Text('Error al cargar el perfil'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Información del Proveedor ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor:
                                        azulClaroMedio.withValues(alpha: 0.1),
                                    backgroundImage: provider!.profileImage !=
                                            null
                                        ? NetworkImage(provider!.profileImage!)
                                        : null,
                                    child: provider!.profileImage == null
                                        ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: azulClaroMedio,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: azulClaroMedio,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 6,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.camera_alt,
                                            color: blancoFondo, size: 24),
                                        onPressed: () => _ProfileDialogs
                                            .showImagePickerDialog(
                                                context, service),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                provider!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      fontFamily: 'Roboto',
                                      color: grisOscuro,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider!.specialty,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: grisSuave,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              if (provider!.isVerified)
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: verdeSelva.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: verdeSelva),
                                    ),
                                    child: Text(
                                      'Proveedor Verificado',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: verdeSelva,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Roboto',
                                          ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatColumn(
                                    value: provider!.rating.toStringAsFixed(1),
                                    label: 'Calificación',
                                    icon: Icons.star,
                                    color: Colors.amber,
                                  ),
                                  _StatColumn(
                                    value: provider!.completedJobs.toString(),
                                    label: 'Trabajos',
                                    icon: Icons.work,
                                    color: azulClaroMedio,
                                  ),
                                  _StatColumn(
                                    value: '${provider!.experienceYears} años',
                                    label: 'Experiencia',
                                    icon: Icons.timeline,
                                    color: verdeSelva,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- Estadísticas de Reservas ---
                      //_BookingStatsCard(bookings: bookings),
                      const SizedBox(height: 20),
                      // --- Información Profesional ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información Profesional',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      color: grisOscuro,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                icon: Icons.location_on,
                                label: 'Ubicación',
                                value: provider!.location,
                              ),
                              _InfoRow(
                                icon: Icons.phone,
                                label: 'Teléfono',
                                value: provider!.phone,
                              ),
                              _InfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: provider!.email,
                              ),
                              _InfoRow(
                                icon: Icons.schedule,
                                label: 'Disponibilidad',
                                value: provider!.availability,
                              ),
                              _InfoRow(
                                icon: Icons.attach_money,
                                label: 'Tarifa promedio',
                                value:
                                    '\$${provider!.hourlyRate.toStringAsFixed(2)}/hora',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- Servicios Ofrecidos ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Servicios que Ofrezco',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      color: grisOscuro,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: provider!.services
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final service = entry.value;
                                  return _ServiceChip(
                                    service: service,
                                    color: serviceHelper.getServiceColor(index),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- Configuración de Cuenta ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _OptionTile(
                              icon: Icons.person_outline,
                              title: 'Editar Perfil',
                              subtitle: 'Actualizar información personal',
                              onTap: () =>
                                  _ProfileDialogs.showEditProfileDialog(
                                      context, provider!, _loadProviderData),
                            ),
                            const Divider(height: 1, color: grisClaro),
                            _OptionTile(
                              icon: Icons.build_outlined,
                              title: 'Gestionar Servicios',
                              subtitle: 'Agregar o modificar servicios',
                              onTap: () =>
                                  _ProfileDialogs.showManageServicesDialog(
                                      context, provider!, _loadProviderData),
                            ),
                            const Divider(height: 1, color: grisClaro),
                            _OptionTile(
                              icon: Icons.schedule_outlined,
                              title: 'Disponibilidad',
                              subtitle: 'Configurar horarios de trabajo',
                              onTap: () => _ProfileDialogs
                                  .showConfigureAvailabilityDialog(
                                      context, provider!, _loadProviderData),
                            ),
                            const Divider(height: 1, color: grisClaro),
                            _buildBankInfoSection(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- Opciones de la Aplicación ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _OptionTile(
                              icon: Icons.notifications_outlined,
                              title: 'Notificaciones',
                              subtitle: 'Configurar alertas',
                              onTap: () =>
                                  _ProfileDialogs.showNotificationsDialog(
                                      context, provider!, _loadProviderData),
                            ),
                            const Divider(height: 1, color: grisClaro),
                            _OptionTile(
                              icon: Icons.help_outline,
                              title: 'Ayuda y Soporte',
                              subtitle: 'Centro de ayuda para proveedores',
                              onTap: () =>
                                  _ProfileDialogs.showHelpSupportDialog(
                                      context),
                            ),
                            const Divider(height: 1, color: grisClaro),
                            _OptionTile(
                              icon: Icons.policy_outlined,
                              title: 'Políticas del Proveedor',
                              subtitle: 'Términos y condiciones',
                              onTap: () =>
                                  _ProfileDialogs.showPoliciesDialog(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // --- Botones de Acción ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _ProfileDialogs.showToggleAvailabilityDialog(
                                      context, service, provider!.isActive),
                              icon: Icon(
                                provider!.isActive
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                color: verdeSelva,
                              ),
                              label: Text(
                                provider!.isActive
                                    ? 'Pausar Servicios'
                                    : 'Activar Servicios',
                                style: const TextStyle(
                                    color: verdeSelva, fontFamily: 'Roboto'),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: grisClaro),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.2),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _ProfileDialogs.showLogoutDialog(context),
                              icon:
                                  const Icon(Icons.logout, color: blancoFondo),
                              label: const Text(
                                'Cerrar Sesión',
                                style: TextStyle(
                                    color: blancoFondo, fontFamily: 'Roboto'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: blancoFondo,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.2),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
