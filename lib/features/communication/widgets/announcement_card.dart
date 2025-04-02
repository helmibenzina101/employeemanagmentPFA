import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Imports
import 'package:employeemanagment/core/models/announcement_model.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
// Import for showErrorSnackbar and showSuccessSnackbar:
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Added Import

// Feature Imports
import 'package:employeemanagment/features/communication/providers/communication_providers.dart';


/// Displays a single announcement in a card format.
/// Allows Admins/HR to delete the announcement.
class AnnouncementCard extends ConsumerWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserDataProvider);
    // Check if the current user has permission to delete announcements
    final bool canDelete = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.rh;
    // Watch the controller state to potentially disable delete while processing
    final deleteState = ref.watch(announcementControllerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 2,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
         // Add a border highlight for pinned announcements
         side: announcement.isPinned
             ? BorderSide(color: theme.colorScheme.secondary, width: 1.5)
             : BorderSide.none,
       ),
      child: InkWell( // Make the card tappable to view full details
        borderRadius: BorderRadius.circular(12), // Match card shape for ripple effect
        onTap: () => _showAnnouncementDetails(context, announcement),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                 crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
                children: [
                  // Pinned Icon (if applicable)
                   if (announcement.isPinned)
                     Padding(
                       padding: const EdgeInsets.only(right: 8.0, top: 2.0), // Adjust alignment
                       child: Icon(Icons.push_pin, size: 18, color: theme.colorScheme.secondary),
                     ),
                  // Title (takes remaining space)
                   Expanded(
                    child: Text(
                      announcement.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface, // Use contrasting color
                      ),
                    ),
                  ),
                  // Delete Button (if authorized)
                  if (canDelete)
                     SizedBox( // Constrain button size for better layout
                        height: 24, width: 24,
                        child: IconButton(
                           padding: EdgeInsets.zero, // Remove default padding
                           iconSize: 18,
                           splashRadius: 18, // Smaller splash radius
                           icon: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error.withOpacity(0.7)),
                           tooltip: 'Supprimer l\'annonce',
                           // Disable button while controller is loading
                           onPressed: deleteState.isLoading ? null : () async {
                               // Confirm deletion with a dialog
                               final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                     title: const Text('Supprimer l\'Annonce'),
                                     content: Text('Voulez-vous vraiment supprimer l\'annonce "${announcement.title}" ?'),
                                     actions: [
                                         TextButton(onPressed: ()=> Navigator.of(context).pop(false), child: const Text('Annuler')),
                                         TextButton(
                                            onPressed: ()=> Navigator.of(context).pop(true),
                                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                            child: const Text('Supprimer')
                                         ),
                                     ],
                                  ),
                               );
                               // If deletion confirmed, call the controller method
                               if (confirm == true) {
                                  final success = await ref.read(announcementControllerProvider.notifier).deleteAnnouncement(announcement.id);
                                  // Show feedback, checking if mounted
                                    if (!success && context.mounted) {
                                        final errorState = ref.read(announcementControllerProvider);
                                        if(errorState.hasError){
                                          // Use the imported helper function
                                          showErrorSnackbar(context, errorState.error.toString());
                                        } else {
                                           showErrorSnackbar(context, "Erreur lors de la suppression.");
                                        }
                                    }
                                    // No success snackbar usually needed as the item disappears.
                               }
                           },
                        ),
                     ),
                ],
              ),
               const SizedBox(height: 8),
              // Content Preview (limit lines shown)
              Text(
                announcement.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface, // Use contrasting color
                ),
                maxLines: 3, // Show only a preview
                overflow: TextOverflow.ellipsis, // Indicate more content with '...'
              ),
               const SizedBox(height: 12),
              // Footer: Author and Date
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(
                      'Par: ${announcement.authorName}',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary,),
                    ),
                    Text(
                       DateFormatter.formatTimestamp(announcement.createdAt, pattern: 'dd/MM/yy HH:mm'),
                       style: theme.textTheme.labelSmall?.copyWith(
                         color: theme.colorScheme.onSurface, // Use contrasting color
                       ),
                    ),
                 ],
               ),
                 // Optional: Show target roles if defined
                if (announcement.targetRoles != null && announcement.targetRoles!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                         'Visible par: ${announcement.targetRoles!.map(_formatRoleName).join(', ')}', // Format role names nicely
                         style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

   /// Helper function to format role names for display (could be moved to enum extension)
   String _formatRoleName(String roleName) {
      switch(roleName) {
         case 'admin': return 'Admin';
         case 'rh': return 'RH';
         case 'employe': return 'Employé';
         default: return roleName; // Fallback
      }
   }

   /// Shows a dialog displaying the full announcement content.
   void _showAnnouncementDetails(BuildContext context, AnnouncementModel announcement) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
          title: Row( // Add pinned icon to dialog title if applicable
             children: [
                if (announcement.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.push_pin, size: 20, color: Theme.of(context).colorScheme.secondary),
                  ),
                Expanded(child: Text(announcement.title)),
             ],
          ),
          // Make content scrollable in case it's long
          content: SingleChildScrollView(
            child: Text(announcement.content),
          ),
          // Add author/date info to dialog as well
           contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0), // Adjust padding
           actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
           actions: [
             Padding( // Add info at the bottom before the close button
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: Text(
                 'Par ${announcement.authorName} le ${DateFormatter.formatTimestampDate(announcement.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall,
               ),
             ),
             TextButton(
               child: const Text('Fermer'),
               onPressed: () => Navigator.of(context).pop(),
             ),
           ],
       ),
     );
   }
}