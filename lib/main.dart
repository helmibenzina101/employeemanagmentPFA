import 'package:flutter/material.dart';
// --- Add Firebase Core Import ---
import 'package:firebase_core/firebase_core.dart';
// --- Import Firebase Options ---
import 'package:employeemanagment/firebase_options.dart'; // Adjust path if needed

// Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your App specific imports
import 'package:employeemanagment/app/navigation/app_router.dart'; // Corrected import
import 'package:employeemanagment/app/theme/app_theme.dart'; // Corrected import

// Imports for localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // For initializing date formatting

// --- Main entry point of the application ---
void main() async {
  // --- Ensure Flutter bindings are initialized ---
  // This is required before using async operations like Firebase.initializeApp
  // or accessing platform channels before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Date Formatting for French Locale ---
  // Do this BEFORE Firebase or runApp if you need formatted dates early
  await initializeDateFormatting('fr_FR', null);

  // --- Initialize Firebase ---
  // Call Firebase.initializeApp using the generated options file.
  // This MUST be called before using any other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // --- End Firebase Initialization ---


  // --- Run the Flutter Application ---
  runApp(
    // Wrap the entire app in ProviderScope for Riverpod state management
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter provider instance from Riverpod
    final router = ref.watch(goRouterProvider);

    // Build the MaterialApp using router configuration
    return MaterialApp.router(
      title: 'Gestion Employés', // App title

      // --- Router Configuration ---
      routerConfig: router, // Use the GoRouter instance

      // --- Theme Configuration ---
      theme: AppTheme.lightTheme, // Your light theme
      darkTheme: AppTheme.darkTheme, // Your dark theme (optional)
      themeMode: ThemeMode.system, // Use system theme setting (light/dark)

      // --- Localization Configuration ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // For Material widgets
        GlobalWidgetsLocalizations.delegate, // For general widget directionality
        GlobalCupertinoLocalizations.delegate, // For Cupertino widgets
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // French (France) - Primary
        // Locale('en', 'US'), // English (US) - Optional fallback
      ],
      locale: const Locale('fr', 'FR'), // Set default locale to French

      // --- Debug Banner ---
      debugShowCheckedModeBanner: false, // Hide debug banner in release builds
    );
  }
}