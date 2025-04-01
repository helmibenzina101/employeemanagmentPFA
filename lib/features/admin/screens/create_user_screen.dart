import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Correct: No message param here
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/utils/validators.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Feature Imports
import 'package:employeemanagment/features/admin/providers/admin_providers.dart';


/// Screen accessible only by Admins to create new user accounts.
class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers for form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _posteController = TextEditingController();
  final _telephoneController = TextEditingController();

  // State variables for selections and UI control
  UserRole _selectedRole = UserRole.employe; // Default to 'employe'
  UserModel? _selectedManager;
  List<UserModel> _potentialManagers = [];
  bool _isLoadingManagers = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Fetch potential managers when the screen loads
    _loadPotentialManagers();
  }

  /// Fetches the list of active users to populate the manager selection dropdown.
  Future<void> _loadPotentialManagers() async {
    if (mounted) setState(() => _isLoadingManagers = true);
    try {
      // Read the future from the provider to get the list once
      final users = await ref.read(allActiveUsersStreamProvider.future);
      if (mounted) {
        setState(() {
          _potentialManagers = users; // Store the fetched users
          _isLoadingManagers = false; // Mark loading as complete
        });
      }
    } catch (e, stack) {
      print("Error loading potential managers: $e\n$stack");
      if (mounted) {
         setState(() => _isLoadingManagers = false); // Stop loading even on error
         showErrorSnackbar(context, "Erreur chargement managers: $e");
      }
    }
  }


  @override
  void dispose() {
    // Dispose all controllers
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _posteController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  /// Toggles the visibility state of the initial password field.
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }


  /// Validates form and attempts to create the user via the controller.
  void _submit() {
    final isLoading = ref.read(userManagementControllerProvider).isLoading;
    if (isLoading) return; // Prevent double submit
    if (!mounted) return;

    if (_formKey.currentState?.validate() ?? false) {
       if (!mounted) return;

       // Use Cloud Functions to create user instead of client-side method
       print("--- Triggering Cloud Function for User Creation (Secure) ---");
       
       // TODO: Implement call to Cloud Function for user creation
       // Example:
       // ref.read(cloudFunctionsProvider).createNewUser(
       //   email: _emailController.text.trim(),
       //   password: _passwordController.text.trim(),
       //   nom: _nomController.text.trim(),
       //   prenom: _prenomController.text.trim(),
       //   poste: _posteController.text.trim(),
       //   role: _selectedRole.name,
       //   managerUid: _selectedManager?.uid,
       //   telephone: _telephoneController.text.trim().isNotEmpty
       //       ? _telephoneController.text.trim()
       //       : null,
       // );
       
       // Temporary placeholder until Cloud Function is implemented
       if (mounted) {
         showErrorSnackbar(context, "La création d'utilisateur via Cloud Functions n'est pas encore implémentée.");
       }
    } else {
       print("Create User form validation failed.");
    }
  }


  @override
  Widget build(BuildContext context) {
    // Listen to the controller's state for feedback and navigation
    ref.listen<AsyncValue<void>>(userManagementControllerProvider, (_, state) {
        state.whenOrNull(
            data: (_) { // On Success
                if (mounted) {
                    showSuccessSnackbar(context, 'Utilisateur créé avec succès.');
                    if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.userManagement); }
                }
            },
            error: (error, stackTrace) { // On Error
                 if (mounted) {
                    showErrorSnackbar(context, "Erreur: ${error.toString()}");
                 }
            }
        );
    });

    // Watch the controller state ONLY for the button's isLoading status
    final controllerState = ref.watch(userManagementControllerProvider);
    final theme = Theme.of(context);

    // Show loading indicator while fetching potential managers
    if (_isLoadingManagers) {
       return Scaffold(
         appBar: AppBar(title: const Text("Créer Utilisateur")),
         // Use LoadingWidget WITHOUT the message parameter
         body: const LoadingWidget()
       );
    }

    // Build the main form UI once managers are loaded
    return Scaffold(
      appBar: AppBar(title: const Text('Créer Nouvel Utilisateur')),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // --- Basic Information ---
               Text("Informations Principales", style: theme.textTheme.titleLarge),
               const SizedBox(height: AppConstants.defaultPadding),
               TextFieldWidget(controller: _prenomController, labelText: 'Prénom', prefixIcon: Icons.person_outline, validator: (v) => Validators.notEmpty(v, 'Prénom'), textCapitalization: TextCapitalization.words),
               const SizedBox(height: 16),
               TextFieldWidget(controller: _nomController, labelText: 'Nom', prefixIcon: Icons.person_outline, validator: (v) => Validators.notEmpty(v, 'Nom'), textCapitalization: TextCapitalization.words),
               const SizedBox(height: 16),
               TextFieldWidget(controller: _posteController, labelText: 'Poste / Fonction', prefixIcon: Icons.badge_outlined, validator: (v) => Validators.notEmpty(v, 'Poste'), textCapitalization: TextCapitalization.sentences),
               const SizedBox(height: 16),
               TextFieldWidget(controller: _telephoneController, labelText: 'Téléphone (Optionnel)', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),

               // --- Separator ---
               const SizedBox(height: AppConstants.defaultPadding * 1.5),
               const Divider(),
               const SizedBox(height: AppConstants.defaultPadding / 2),

               // --- Account & Access ---
               Text("Compte & Accès", style: theme.textTheme.titleLarge),
               const SizedBox(height: AppConstants.defaultPadding),
               TextFieldWidget(controller: _emailController, labelText: 'Adresse e-mail', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined, validator: Validators.email),
               const SizedBox(height: 16),
               TextFieldWidget(
                  controller: _passwordController, labelText: 'Mot de passe initial', obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline, validator: Validators.password,
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: _togglePasswordVisibility),
                  hintText: 'Communiquer à l\'utilisateur',
                ),
               const SizedBox(height: 16),
               DropdownButtonFormField<UserRole>(
                  value: _selectedRole, decoration: const InputDecoration(labelText: 'Rôle Utilisateur', border: OutlineInputBorder(), prefixIcon: Icon(Icons.security_outlined)),
                  items: UserRole.values.map((UserRole role) => DropdownMenuItem<UserRole>(value: role, child: Text(role.displayName))).toList(),
                  onChanged: (UserRole? newValue) => setState(() { if (newValue != null) _selectedRole = newValue; }),
                  validator: (value) => value == null ? 'Sélectionnez un rôle' : null,
                ),
               const SizedBox(height: 16),
               DropdownButtonFormField<UserModel?>(
                   value: _selectedManager, decoration: const InputDecoration(labelText: 'Manager Direct (Optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.supervisor_account_outlined)),
                   items: [
                      const DropdownMenuItem<UserModel?>(value: null, child: Text("-- Aucun --", style: TextStyle(fontStyle: FontStyle.italic))),
                      ..._potentialManagers.map((UserModel m) => DropdownMenuItem<UserModel?>(value: m, child: Text(m.nomComplet))).toList()
                   ],
                   onChanged: (UserModel? newValue) => setState(() => _selectedManager = newValue),
               ),

               // --- Submit Button & Warning ---
               const SizedBox(height: AppConstants.defaultPadding * 2),
               ButtonWidget(
                 text: 'Créer Utilisateur',
                 isLoading: controllerState.isLoading,
                 onPressed: controllerState.isLoading ? null : _submit,
               ),
               const SizedBox(height: AppConstants.defaultPadding),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text(
                    'AVERTISSEMENT: L\'utilisateur sera créé avec le mot de passe initial. Communiquez-le de manière sécurisée.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}