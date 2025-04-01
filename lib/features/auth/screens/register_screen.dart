import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/core/utils/validators.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Feature Imports
import 'package:employeemanagment/features/auth/providers/auth_providers.dart';


/// Screen for users to register their own account (requires admin approval).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _posteController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);
  void _toggleConfirmPasswordVisibility() => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _posteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Change registerControllerProvider to the correct name
    final isLoading = ref.read(registerControllerProvider).isLoading;
    if (isLoading) return;
    if (!mounted) return;

    if (_formKey.currentState?.validate() ?? false) {
       if (!mounted) return;

       // Call the modified register method
       final success = await ref.read(registerControllerProvider.notifier).register(
             email: _emailController.text.trim(),
             password: _passwordController.text.trim(),
             nom: _nomController.text.trim(),
             prenom: _prenomController.text.trim(),
             poste: _posteController.text.trim(),
           );

       if (success && mounted) {
          showSuccessSnackbar(context, 'Compte créé. Connexion possible après approbation.');
          if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.login); }
       } else if (!success && mounted) {
           final errorState = ref.read(registerControllerProvider);
           if(errorState.hasError){ showErrorSnackbar(context, errorState.error.toString()); }
           else { showErrorSnackbar(context, "Erreur d'inscription inconnue."); }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Replace registerControllerProvider with RegisterController.provider
    final registerState = ref.watch(registerControllerProvider);

    return Scaffold(
      appBar: AppBar( title: const Text('Créer Mon Compte') ), // Updated title
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Demande de Compte Employé', // Updated heading
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: theme.colorScheme.primary,
                  ),
                ),
                 const SizedBox(height: 8),
                Text( // Updated subtitle
                  'Votre compte sera activé après approbation par un administrateur.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                ),
                const SizedBox(height: 32),
                // --- Form Fields ---
                TextFieldWidget(controller: _prenomController, labelText: 'Prénom', prefixIcon: Icons.person_outline, validator: (v) => Validators.notEmpty(v, 'Prénom'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 16),
                TextFieldWidget(controller: _nomController, labelText: 'Nom', prefixIcon: Icons.person_outline, validator: (v) => Validators.notEmpty(v, 'Nom'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 16),
                TextFieldWidget(controller: _posteController, labelText: 'Poste / Fonction', prefixIcon: Icons.badge_outlined, validator: (v) => Validators.notEmpty(v, 'Poste'), textCapitalization: TextCapitalization.sentences),
                const SizedBox(height: 16),
                TextFieldWidget(controller: _emailController, labelText: 'Adresse e-mail', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined, validator: Validators.email),
                const SizedBox(height: 16),
                TextFieldWidget(controller: _passwordController, labelText: 'Mot de passe', obscureText: _obscurePassword, prefixIcon: Icons.lock_outline, validator: Validators.password, suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: _togglePasswordVisibility)),
                const SizedBox(height: 16),
                TextFieldWidget(controller: _confirmPasswordController, labelText: 'Confirmer le mot de passe', obscureText: _obscureConfirmPassword, prefixIcon: Icons.lock_outline, validator: (value) => Validators.confirmPassword(_passwordController.text, value), suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: _toggleConfirmPasswordVisibility)),
                const SizedBox(height: 32),
                // --- Submit Button ---
                ButtonWidget(
                  text: 'Créer le Compte',
                  isLoading: registerState.isLoading,
                  onPressed: registerState.isLoading ? null : _submit,
                  minWidth: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}