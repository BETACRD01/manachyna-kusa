import 'package:flutter/material.dart';

enum UserType {
  client,
  provider,
  admin
}

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.client:
        return 'client';
      case UserType.provider:
        return 'provider';
      case UserType.admin:
        return 'admin';
    }
  }

  String get displayName {
    switch (this) {
      case UserType.client:
        return 'Cliente';
      case UserType.provider:
        return 'Proveedor';
      case UserType.admin:
        return 'Administrador';
    }
  }

  String get description {
    switch (this) {
      case UserType.client:
        return 'Usuario que busca y contrata servicios';
      case UserType.provider:
        return 'Proveedor que ofrece servicios';
      case UserType.admin:
        return 'Administrador del sistema';
    }
  }

  // Colección de Firestore correspondiente
  String get firestoreCollection {
    switch (this) {
      case UserType.client:
        return 'users';
      case UserType.provider:
        return 'providers';
      case UserType.admin:
        return 'admins';
    }
  }

  // Ruta de navegación principal
  String get homeRoute {
    switch (this) {
      case UserType.client:
        return '/client-home';
      case UserType.provider:
        return '/provider-dashboard';
      case UserType.admin:
        return '/admin-dashboard';
    }
  }
}

// Función helper para convertir string a UserType
UserType? userTypeFromString(String? value) {
  if (value == null) return null;
  
  switch (value.toLowerCase()) {
    case 'client':
    case 'cliente':
    case 'user':
      return UserType.client;
    case 'provider':
    case 'proveedor':
      return UserType.provider;
    case 'admin':
    case 'administrador':
      return UserType.admin;
    default:
      return null;
  }
}

const List<UserType> userTypePriority = [
  UserType.provider,
  UserType.admin,
  UserType.client,
];

// Configuración de debug
class UserTypeConfig {
  static const bool enableDebugLogs = true;
  static const bool enableDebugUI = true;
  static const int maxLoadingTimeSeconds = 10;
  
  // Colores para debug UI
  static const Map<UserType, Color> debugColors = {
    UserType.client: Colors.blue,
    UserType.provider: Colors.green,
    UserType.admin: Colors.red,
  };
}

