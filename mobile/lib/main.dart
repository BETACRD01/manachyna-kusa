import 'package:flutter/material.dart';
import 'core/initialization/app_startup_wrapper.dart';

void main() {
  // Ensure Flutter engine is initialized before any platform interaction
  WidgetsFlutterBinding.ensureInitialized();

  /// Delegates the full initialization lifecycle to the widget tree:
  /// service init, retry logic, and error handling live in [AppStartupWrapper].
  runApp(const AppStartupWrapper());
}
