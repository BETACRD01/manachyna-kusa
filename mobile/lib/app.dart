import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Proveedores de estado
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';

// Configuración y Rutas
import 'config/app_routes.dart';
import 'core/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Selector<ThemeProvider, ThemeMode>(
        selector: (_, provider) => provider.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Mañachyna Kusa',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: kDebugMode,

            // Sistema de rutas centralizado
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,

            // Configuración de internacionalización (i18n)
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'EC'), // Español (Ecuador)
              Locale('es', ''), // Español genérico
              Locale('en', ''), // Inglés (fallback)
            ],
            // Al no definir 'locale', Flutter usa automáticamente el del sistema
            // siempre que esté en 'supportedLocales', con fallback al primero.
          );
        },
      ),
    );
  }
}
