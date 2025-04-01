import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Imports
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/user_avatar.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';

// Feature Imports
import 'package:employeemanagment/features/admin/providers/admin_providers.dart';


/// Screen for Admins/HR to approve or reject pending user registrations.
class UserApprovalScreen extends ConsumerWidget {
  const UserApprovalScreen({super.key});

  /// Shows a confirmation dialog before approving/rejecting.
  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content, {
    bool isDestructive = false, // Style reject button differently
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true on confirm
            style: isDestructive ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error) : null,
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to select the role during approval.
  Future<UserRole?> _showRoleSelectionDialog(BuildContext context) async {
      return await showDialog<UserRole>(
          context: context,
          builder: (BuildContext context) {
              return SimpleDialog(
                  title: const Text('Attribuer un Rôle'),
                  children: <Widget>[
                      SimpleDialogOption(
                          onPressed: () { Navigator.pop(context, UserRole.employe); },
                          child: const Text('Employé'),
                      ),
                      SimpleDialogOption(
                          onPressed: () { Navigator.pop(context, UserRole.rh); },
                          child: const Text('Ressources Humaines (RH)'),
                      ),
                      // Optionally add Admin role selection if needed, but often restricted
                      // SimpleDialogOption(
                      //    onPressed: () { Navigator.pop(context, UserRole.admin); },
                      //    child: const Text('Administrateur'),
                      // ),
                      SimpleDialogOption(
                        padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
                        onPressed: () { Navigator.pop(context, null); }, // Cancel option
                        child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                      ),
                  ],
              );
          }
      );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream of pending users
    final pendingUsersAsync = ref.watch(pendingUsersStreamProvider);
    // Watch the controller state for loading indicators on buttons
    final controllerState = ref.watch(userManagementControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Approbation Utilisateurs')),
      body: RefreshIndicator(
        // Allow pull-to-refresh
        onRefresh: () async => ref.invalidate(pendingUsersStreamProvider),
        child: pendingUsersAsync.when(
          data: (pendingUsers) {
            // Display message if no users are pending
            if (pendingUsers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text('Aucun utilisateur en attente d\'approbation.'),
                ),
              );
            }
            // Build the list of pending users
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding / 2),
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            UserAvatar.fromModel(user, radius: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(user.nomComplet, style: Theme.of(context).textTheme.titleMedium),
                                   Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                                   Text('Poste demandé: ${user.poste}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppConstants.defaultPadding * 1.5),
                         Text('Demandé le: ${DateFormatter.formatTimestamp(user.dateEmbauche)}', style: Theme.of(context).textTheme.labelSmall),
                         const SizedBox(height: AppConstants.defaultPadding),
                        // Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Reject Button
                            TextButton.icon(
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Rejeter'),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                              // Disable while controller is processing
                              onPressed: controllerState.isLoading ? null : () async {
                                  final confirm = await _showConfirmationDialog(
                                     context, 'Rejeter l\'Utilisateur ?',
                                     'Voulez-vous vraiment rejeter l\'inscription de ${user.nomComplet} ?',
                                     isDestructive: true
                                  );
                                  if (confirm == true) {
                                     // Call controller method to reject
                                     await ref.read(userManagementControllerProvider.notifier).rejectUser(user.uid);
                                     // Snackbars for errors handled by ref.listen in build (optional here)
                                  }
                              },
                            ),
                            const SizedBox(width: 8),
                            // Approve Button
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Approuver'),
                              style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.green.shade600,
                                 foregroundColor: Colors.white,
                              ),
                               // Disable while controller is processing
                              onPressed: controllerState.isLoading ? null : () async {
                                 // 1. Ask Admin to select Role
                                 final UserRole? selectedRole = await _showRoleSelectionDialog(context);

                                 if (selectedRole != null) {
                                     // 2. Confirm Approval
                                     final confirm = await _showConfirmationDialog(
                                        context, 'Approuver l\'Utilisateur ?',
                                        'Approuver ${user.nomComplet} avec le rôle "${selectedRole.displayName}" ?'
                                     );
                                     if (confirm == true) {
                                        // 3. Call controller method to approve
                                        await ref.read(userManagementControllerProvider.notifier).approveUser(user.uid, selectedRole);
                                        // Snackbars for errors handled by ref.listen in build
                                     }
                                 }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const LoadingWidget(), // Show loading while fetching pending users
          error: (error, stack) => ErrorMessageWidget( // Show error if fetching fails
            message: 'Erreur chargement utilisateurs en attente: $error',
            onRetry: () => ref.invalidate(pendingUsersStreamProvider), // Allow retry
          ),
        ),
      ),
    );
  }
}