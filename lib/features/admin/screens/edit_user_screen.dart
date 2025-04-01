import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For context.pop()

// Core Imports
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Correct: No message param
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/widgets/user_avatar.dart';
import 'package:employeemanagment/core/utils/validators.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Feature Imports
import 'package:employeemanagment/features/admin/providers/admin_providers.dart';


/// Screen for Admins/HR to edit details of an existing user.
class EditUserScreen extends ConsumerStatefulWidget {
  final String userId; // Passed via route parameter

  const EditUserScreen({super.key, required this.userId});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
   final _formKey = GlobalKey<FormState>();
   late TextEditingController _posteController;
   // State variables initialized after fetching user data
   UserRole? _selectedRole;
   bool? _isActive;
   UserModel? _selectedManager;
   // State for loading manager dropdown
   List<UserModel> _potentialManagers = [];
   bool _isLoadingManagers = true;
   bool _initialPopulationDone = false; // Prevent re-populating on rebuilds

   @override
   void initState() {
      super.initState();
      _posteController = TextEditingController();
      // Load initial data needed for the form
      _loadData();
   }

   /// Loads potential managers and then attempts to populate form fields.
   Future<void> _loadData() async {
      // Ensure widget is mounted before starting async work
      if (mounted) setState(() => _isLoadingManagers = true);
      try {
         // Fetch all active users to populate manager dropdown
         final users = await ref.read(allActiveUsersStreamProvider.future);
         if (mounted) {
            setState(() {
               // Exclude the user being edited from potential managers
               _potentialManagers = users.where((u) => u.uid != widget.userId).toList();
               _isLoadingManagers = false; // Mark manager loading as complete
            });
         }
      } catch (e, stack) {
          print("Error loading potential managers: $e\n$stack");
          if(mounted) {
            setState(() => _isLoadingManagers = false); // Stop loading
            showErrorSnackbar(context, "Erreur chargement managers: $e");
          }
      }
      // Attempt to populate form fields AFTER managers list is available (or failed)
      _populateFields();
   }

   /// Populates the form fields with the target user's current data.
   /// Should only run once after managers are loaded.
   void _populateFields() {
      // Don't run if managers are still loading or if already populated
      if (_isLoadingManagers || _initialPopulationDone) return;

      // Read (don't watch) the user data provider synchronously ONCE
      final userAsync = ref.read(userStreamByIdProvider(widget.userId));

      userAsync.whenData((user) {
          if (user != null && mounted) {
             _posteController.text = user.poste;
              // Use setState to update UI with initial values
              setState(() {
                 _selectedRole = user.role;
                 _isActive = user.isActive;
                 // Find the user's current manager in the potential managers list
                 _selectedManager = _potentialManagers.firstWhereOrNull((m) => m.uid == user.managerUid);
                 _initialPopulationDone = true; // Mark as populated
              });
          } else if(user == null && mounted) {
             // If user data couldn't be fetched, still mark as done to prevent looping
             print("Warning: Could not populate fields, user data not found for ${widget.userId}");
             setState(() => _initialPopulationDone = true);
          }
      });
   }

   @override
   void dispose() {
      _posteController.dispose();
      super.dispose();
   }

   /// Validates the form and triggers the update user action via the controller.
   void _submit() {
      final isLoading = ref.read(userManagementControllerProvider).isLoading;
      if (isLoading) return; // Prevent double submit
      if (!mounted) return;

      // Ensure state variables needed for update are populated
      if (_selectedRole == null || _isActive == null) {
         showErrorSnackbar(context, 'Données utilisateur initiales non chargées ou incomplètes.');
         return;
      }

      if (_formKey.currentState?.validate() ?? false) {
         if (!mounted) return;

         print("--- Triggering User Update ---");
         // Call controller method - DO NOT await here. Result handled by ref.listen.
         ref.read(userManagementControllerProvider.notifier).updateUserAdmin(
            userId: widget.userId,
            newRole: _selectedRole!, // Use ! as null checked above
            isActive: _isActive!, // Use ! as null checked above
            managerUid: _selectedManager?.uid, // Pass selected UID or null
            poste: _posteController.text.trim(),
         );
      } else {
         print("Edit User form validation failed.");
      }
   }

  @override
  Widget build(BuildContext context) {
     // Watch the specific user's data stream mainly for the initial load state handled by .when()
     final userAsync = ref.watch(userStreamByIdProvider(widget.userId));
     // Watch the controller state for the button's isLoading status
     final controllerState = ref.watch(userManagementControllerProvider);
     final theme = Theme.of(context);

     // Listen for completion/error states from the controller AFTER an action
     ref.listen<AsyncValue<void>>(userManagementControllerProvider, (_, state) {
        state.whenOrNull(
            data: (_) { // On Success
                if (mounted) {
                    showSuccessSnackbar(context, 'Utilisateur mis à jour.');
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

     // Attempt population again if still needed (e.g., if initial fetch failed but now succeeded)
     if (!_initialPopulationDone && !_isLoadingManagers) {
        _populateFields();
     }

    return Scaffold(
       appBar: AppBar(title: const Text('Modifier Utilisateur')),
       // Use .when on the user data provider to handle initial loading/error for the form
       body: userAsync.when(
         data: (user) {
           // If user fetch failed after trying
           if (user == null && _initialPopulationDone) {
             return ErrorMessageWidget(message: 'Utilisateur (${widget.userId}) non trouvé.');
           }
           // Show loading if managers OR initial form population isn't finished
           if (_isLoadingManagers || !_initialPopulationDone) {
              // Use LoadingWidget WITHOUT message parameter
             return const LoadingWidget();
           }
           // --- User data loaded and form populated: Build Form ---
           return SingleChildScrollView(
             padding: const EdgeInsets.all(AppConstants.defaultPadding),
             child: Form(
               key: _formKey,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                    // Display basic info (non-editable here)
                    Center(child: UserAvatar.fromModel(user!, radius: 40)), // Use user! (safe due to check above)
                    const SizedBox(height: 8),
                    Center(child: Text(user.nomComplet, style: theme.textTheme.headlineSmall)),
                    Center(child: Text(user.email, style: theme.textTheme.bodyLarge)),
                    const SizedBox(height: AppConstants.defaultPadding * 1.5),
                    const Divider(),

                    // Poste (Editable by Admin/HR)
                    TextFieldWidget(
                       controller: _posteController, labelText: 'Poste',
                       prefixIcon: Icons.badge_outlined, validator: (v) => Validators.notEmpty(v, 'Poste'),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Role Dropdown
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole, // Bind to state variable
                      decoration: const InputDecoration(labelText: 'Rôle Utilisateur', border: OutlineInputBorder(), prefixIcon: Icon(Icons.security_outlined)),
                      items: UserRole.values.map((UserRole role) => DropdownMenuItem<UserRole>(value: role, child: Text(role.displayName))).toList(),
                      onChanged: (UserRole? newValue) => setState(() { if (newValue != null) _selectedRole = newValue; }),
                      validator: (value) => value == null ? 'Sélectionnez un rôle' : null,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Manager Dropdown
                    DropdownButtonFormField<UserModel?>(
                       value: _selectedManager, // Bind to state variable
                       decoration: const InputDecoration(labelText: 'Manager Direct (Optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.supervisor_account_outlined)),
                       items: [
                          const DropdownMenuItem<UserModel?>(value: null, child: Text("-- Aucun --", style: TextStyle(fontStyle: FontStyle.italic))),
                         ..._potentialManagers.map((UserModel m) => DropdownMenuItem<UserModel?>(value: m, child: Text(m.nomComplet))).toList()
                       ],
                       onChanged: (UserModel? newValue) => setState(() => _selectedManager = newValue),
                       // No validator needed as it's optional
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Active Status Switch
                    SwitchListTile(
                      title: const Text('Compte Actif'),
                      value: _isActive ?? true, // Use state variable, default true
                      onChanged: (bool value) => setState(() { _isActive = value; }),
                      secondary: Icon( (_isActive ?? true) ? Icons.check_circle_outline : Icons.cancel_outlined, color: (_isActive ?? true) ? Colors.green : Colors.red),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding * 2),

                    // Submit Button
                    ButtonWidget(
                       text: 'Enregistrer Modifications',
                       isLoading: controllerState.isLoading, // Use watched controller state
                       onPressed: controllerState.isLoading ? null : _submit, // Disable if loading
                    ),
                 ],
               ),
             ),
           );
           // --- End Form ---
         },
         // --- Loading/Error states for initial user data fetch ---
         loading: () => const LoadingWidget(), // Use LoadingWidget WITHOUT message
         error: (error, stack) => ErrorMessageWidget(
            message: 'Erreur chargement données utilisateur: $error',
            // No automatic retry needed here as error likely means invalid user ID
         ),
       ),
    );
  }
}

// Helper extension (keep or move to utils)
extension UserModelFirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) { if (test(element)) return element; }
    return null;
  }
}