import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/core/models/document_metadata_model.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/features/profile/providers/profile_providers.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
// ADD THIS IMPORT:
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Defines showErrorSnackbar & showSuccessSnackbar
// END ADD IMPORT


class DocumentMetadataListTile extends ConsumerWidget {
  final DocumentMetadataModel document;
  final String viewingUserId; // User whose documents are being viewed

  const DocumentMetadataListTile({
    super.key,
    required this.document,
    required this.viewingUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserDataProvider); // User using the app
    // Determine if the current user has permission to delete
    final bool canDelete = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.rh;
    // Watch the controller state to disable button while deleting
    final deleteState = ref.watch(documentMetadataControllerProvider);

    return Card(
       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
       elevation: 1,
      child: ListTile(
        leading: Icon(document.typeIcon, color: theme.colorScheme.primary),
        title: Text(document.documentName, style: theme.textTheme.titleMedium),
        subtitle: Text(
          'Type: ${document.typeDisplay}\nAjouté le: ${DateFormatter.formatTimestampDate(document.uploadDate)}${document.expiryDate != null ? '\nExpire le: ${DateFormatter.formatTimestampDate(document.expiryDate!)}' : ''}',
           style: theme.textTheme.bodySmall,
        ),
        isThreeLine: document.expiryDate != null,
        // Show delete button only if user has permission
        trailing: canDelete ? IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          tooltip: 'Supprimer l\'entrée',
          // Disable button while controller is processing
          onPressed: deleteState.isLoading ? null : () async {
            // Show confirmation dialog before deleting
             final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: Text('Voulez-vous vraiment supprimer l\'entrée pour "${document.documentName}" ?\n(Ceci ne supprime pas le fichier réel, seulement la référence).'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              // If confirmed, proceed with deletion
              if (confirm == true) {
                 final success = await ref.read(documentMetadataControllerProvider.notifier)
                                // Pass document ID and the ID of the user whose docs are being viewed
                                .deleteDocumentMetadata(document.id, viewingUserId);

                 // Show feedback using the imported snackbar helpers
                 // Check if the widget is still mounted before showing snackbar
                 if (!success && context.mounted) {
                     final errorState = ref.read(documentMetadataControllerProvider); // Read state again for error
                     if(errorState.hasError){
                       showErrorSnackbar(context, errorState.error.toString()); // Use imported function
                     } else {
                       showErrorSnackbar(context, 'Erreur lors de la suppression.'); // Generic fallback
                     }
                 } else if (success && context.mounted) {
                     showSuccessSnackbar(context, 'Entrée supprimée.'); // Use imported function
                 }
              }
          },
        ) : null, // Don't show button if no permission
        onTap: () {
          // Cannot open file as we don't store it.
          // Show details dialog instead.
           showDialog(context: context, builder: (context)=> AlertDialog(
             title: Text(document.documentName),
             content: Text('Ce document est référencé dans le système mais le fichier lui-même n\'est pas stocké dans l\'application.\n\nType: ${document.typeDisplay}\nDate d\'ajout: ${DateFormatter.formatTimestampDate(document.uploadDate)}'),
             actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: const Text('OK'))],
           ));
        },
      ),
    );
  }
}