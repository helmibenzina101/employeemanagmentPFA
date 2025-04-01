import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
import 'package:employeemanagment/core/models/user_model.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/text_field_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/button_widget.dart'; // Corrected import
import 'package:employeemanagment/core/utils/validators.dart'; // Corrected import
import 'package:employeemanagment/features/profile/providers/profile_providers.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:go_router/go_router.dart'; // For pop

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _posteController;
  late TextEditingController _telephoneController;

  UserModel? _currentUser; // To hold initial data

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _posteController = TextEditingController();
    _telephoneController = TextEditingController();

    // Initialize controllers with current user data (read once)
    // We listen later for rebuilds, but init needs synchronous data
    _currentUser = ref.read(currentUserDataProvider);
    if (_currentUser != null) {
      _nomController.text = _currentUser!.nom;
      _prenomController.text = _currentUser!.prenom;
      _posteController.text = _currentUser!.poste;
      _telephoneController.text = _currentUser!.telephone ?? '';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _posteController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      final success = await ref.read(profileEditControllerProvider.notifier).updateUserProfile(
            _currentUser!.uid,
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            poste: _posteController.text.trim(), // Consider role restriction
            telephone: _telephoneController.text.trim().isNotEmpty ? _telephoneController.text.trim() : null,
          );

      if (success && mounted) {
        showSuccessSnackbar(context, 'Profil mis à jour avec succès.');
        context.pop(); // Go back to profile screen
      } else if (!success && mounted) {
         final errorState = ref.read(profileEditControllerProvider);
         if (errorState.hasError) {
           showErrorSnackbar(context, errorState.error.toString());
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in user data to potentially update fields if needed
    // although typically shouldn't change while editing screen is open
    ref.watch(currentUserStreamProvider);

    // Watch the edit controller state for loading indicator
    final editState = ref.watch(profileEditControllerProvider);

     // If initial user data wasn't available on initState, show loading/error
     if (_currentUser == null) {
       final userAsync = ref.watch(currentUserDataProvider); // Use non-stream version
       if (userAsync == null) {
          return Scaffold(appBar: AppBar(), body: const LoadingWidget()); // Or error
       }
       // Initialize controllers now if they weren't before
        _nomController.text = userAsync.nom;
        _prenomController.text = userAsync.prenom;
        _posteController.text = userAsync.poste;
        _telephoneController.text = userAsync.telephone ?? '';
        _currentUser = userAsync; // Set current user
     }


    return Scaffold(
      appBar: AppBar(title: const Text('Modifier Mon Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TODO: Add Avatar/Initials Display here? Maybe non-editable.
              const SizedBox(height: AppConstants.defaultPadding),

              TextFieldWidget(
                controller: _prenomController,
                labelText: 'Prénom',
                prefixIcon: Icons.person_outline,
                validator: (value) => Validators.notEmpty(value, 'Prénom'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextFieldWidget(
                controller: _nomController,
                labelText: 'Nom',
                 prefixIcon: Icons.person_outline,
                validator: (value) => Validators.notEmpty(value, 'Nom'),
                 textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextFieldWidget(
                controller: _telephoneController,
                labelText: 'Téléphone (Optionnel)',
                 prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                 // No validator needed if optional
              ),
              const SizedBox(height: AppConstants.defaultPadding),
               TextFieldWidget(
                controller: _posteController,
                labelText: 'Poste',
                 prefixIcon: Icons.badge_outlined,
                 // Decide if user can edit this. If not, set readOnly: true
                 // readOnly: _currentUser?.role != UserRole.admin && _currentUser?.role != UserRole.rh,
                 readOnly: true, // Example: Only HR/Admin can change via User Management
                 validator: (value) => Validators.notEmpty(value, 'Poste'),
              ),
              const SizedBox(height: AppConstants.defaultPadding * 2),

              ButtonWidget(
                text: 'Enregistrer les Modifications',
                isLoading: editState.isLoading,
                onPressed: editState.isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}