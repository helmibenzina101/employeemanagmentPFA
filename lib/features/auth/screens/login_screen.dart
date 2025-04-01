import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/app/navigation/app_routes.dart';
import 'package:employeemanagment/core/utils/validators.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/app/config/constants.dart';

// Feature Imports
import 'package:employeemanagment/features/auth/providers/auth_providers.dart';


/// Screen for user login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
     _emailController.dispose();
     _passwordController.dispose();
     super.dispose();
  }
  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);

  /// Validates form and triggers the login action via the controller.
  /// Navigation is now handled by GoRouter's redirect logic based on auth state
  /// and Firestore user status checks within the redirector.
  Future<void> _submit() async {
    final isLoading = ref.read(loginControllerProvider).isLoading;
    if (isLoading) return; // Prevent double taps
    if (!mounted) return; // Check if widget is still in tree

    if (_formKey.currentState?.validate() ?? false) {
       if (!mounted) return;
       print("--- Triggering Login (Auth Only) ---");

       // Call the simplified login method (only performs Auth)
       final bool authSuccess = await ref.read(loginControllerProvider.notifier).login(
             _emailController.text.trim(),
             _passwordController.text.trim(),
           );

       // --- NO EXPLICIT NAVIGATION HERE ---
       // GoRouter's redirect logic will handle navigation if authSuccess is true
       // AND the subsequent Firestore checks within the redirect logic pass.

       // Show snackbar ONLY if AUTHENTICATION itself failed.
       // Errors related to Firestore status (pending/inactive) are handled by
       // the redirect logic keeping the user on the login screen.
       if (!authSuccess && mounted) {
           final errorState = ref.read(loginControllerProvider);
           if (errorState.hasError) {
              showErrorSnackbar(context, errorState.error.toString());
           } else {
              // Generic message if no specific error from provider after auth failure
              showErrorSnackbar(context, "Erreur d'authentification.");
           }
       }
    } else {
        print("Login form validation failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch state ONLY for isLoading for button UI enable/disable state
    final loginState = ref.watch(loginControllerProvider);

    // --- REMOVED ref.listen ---
    // Feedback for errors during the *login process itself* (like invalid Firestore status)
    // should ideally be handled by the redirect logic (keeping user on login)
    // or potentially by displaying a message on the login screen based on a different provider state
    // if very specific feedback is needed beyond just staying on the login page.
    // For now, we rely on the redirect logic and only show snackbar for direct auth failures.

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.people_alt_rounded, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text('Gestion Employés', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 40),
                TextFieldWidget(controller: _emailController, labelText: 'Adresse e-mail', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined, validator: Validators.email),
                const SizedBox(height: 16),
                TextFieldWidget(
                    controller: _passwordController, labelText: 'Mot de passe', obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline, validator: Validators.password,
                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: _togglePasswordVisibility),
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fonctionnalité "Mot de passe oublié" à implémenter.')));
                    // ref.read(loginControllerProvider.notifier).sendPasswordReset(...);
                }, child: const Text('Mot de passe oublié ?'))),
                const SizedBox(height: 24),
                ButtonWidget(text: 'Se Connecter', isLoading: loginState.isLoading, onPressed: loginState.isLoading ? null : _submit, minWidth: double.infinity),
                const SizedBox(height: 16),
                ButtonWidget(text: 'Créer un compte Employé', type: ButtonType.text, isLoading: false, onPressed: () => context.push(AppRoutes.register)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}