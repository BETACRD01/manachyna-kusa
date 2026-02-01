import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';

// Configuración
import 'config/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'config/routes/route_generator.dart';

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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Mañachyna Kusa',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,

            // Usar el sistema de rutas existente con logging mejorado

            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,

            // Configuración de localizaciones
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'EC'), // Español Ecuador
              Locale('es', ''), // Español genérico
              Locale('en', ''), // Inglés fallback
            ],
            locale: const Locale('es', 'EC'),
          );
        },
      ),
    );
  }
}
