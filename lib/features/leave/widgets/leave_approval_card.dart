import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import for Timestamp (used by model/formatter)

// Core Imports
import 'package:employeemanagment/core/models/leave_request_model.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // For snackbars

// Feature Imports
import 'package:employeemanagment/features/leave/providers/leave_providers.dart';


/// A card widget specifically for displaying pending leave requests
/// on the Admin/HR approval screen, providing action buttons.
class LeaveApprovalCard extends ConsumerStatefulWidget {
 /// The pending leave request data to display.
 final LeaveRequestModel request;

 const LeaveApprovalCard({super.key, required this.request});

 @override
 ConsumerState<LeaveApprovalCard> createState() => _LeaveApprovalCardState();
}

class _LeaveApprovalCardState extends ConsumerState<LeaveApprovalCard> {
  // Controller for the rejection reason text field.
  final TextEditingController _rejectionReasonController = TextEditingController();
  // State variable to conditionally show the rejection reason field.
   bool _isRejecting = false;

  @override
  void dispose() {
     // Dispose the controller when the widget is removed.
     _rejectionReasonController.dispose();
    super.dispose();
  }

   /// Handles the approval or rejection action.
   Future<void> _actionRequest(LeaveStatus status) async {
      // Get the rejection reason only if currently in rejecting state.
      String? reason = _isRejecting ? _rejectionReasonController.text.trim() : null;

      // Validate: Ensure rejection reason is provided if rejecting.
       if (_isRejecting && (reason == null || reason.isEmpty)) {
           showErrorSnackbar(context, 'Veuillez entrer une raison pour le rejet.');
           return; // Stop processing if validation fails
       }

       // Call the controller method to perform the action.
       final success = await ref.read(leaveRequestControllerProvider.notifier).actionLeaveRequest(
            requestId: widget.request.id,
            newStatus: status,
            rejectionReason: reason, // Pass reason if rejecting
        );

        // Handle feedback and state reset, ensuring widget is still mounted.
        if (!success && mounted) {
             final errorState = ref.read(leaveRequestControllerProvider);
             if(errorState.hasError){
                showErrorSnackbar(context, errorState.error.toString());
             } else {
                 showErrorSnackbar(context, "Erreur lors de l'action."); // Generic fallback
             }
        }
        // No success snackbar needed as the item will disappear from the list upon success.

        // Reset the rejection state regardless of success/failure, if still mounted.
        if (mounted) {
           setState(() { _isRejecting = false; });
           _rejectionReasonController.clear(); // Clear the text field
        }
   }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch the controller state to disable buttons while an action is processing.
    final actionState = ref.watch(leaveRequestControllerProvider);
    final bool isLoading = actionState.isLoading; // Check if any action is loading

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
       elevation: 2,
      child: Padding(
         padding: const EdgeInsets.all(AppConstants.defaultPadding),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              // Use ListTile for structured display of user/type/days.
              ListTile(
                contentPadding: EdgeInsets.zero, // Remove default ListTile padding
                title: Text(widget.request.userName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.request.typeDisplay, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
                 trailing: Text('${widget.request.days.toStringAsFixed(1)} jour(s)', style: theme.textTheme.titleMedium),
              ),
              const Divider(), // Visual separator
              // Display request period and reason.
              Text('Période: ${DateFormatter.formatTimestampDate(widget.request.startDate)} au ${DateFormatter.formatTimestampDate(widget.request.endDate)}'),
              const SizedBox(height: 8),
              Text('Raison: ${widget.request.reason}'),
               const SizedBox(height: 8),
              // Display when the request was submitted.
              Text('Demandé le: ${DateFormatter.formatTimestamp(widget.request.requestedAt, pattern: 'dd/MM/yy HH:mm')}'),

              // --- Conditional Rejection Reason Field ---
              // Show this field only when the admin clicks "Rejeter".
              if (_isRejecting) ...[
                 const SizedBox(height: AppConstants.defaultPadding),
                 TextFieldWidget(
                    controller: _rejectionReasonController,
                    labelText: 'Raison du rejet (Obligatoire)',
                    maxLines: 2, // Allow brief explanation
                    // Basic validation could be added here if needed,
                    // but primary validation is done in _actionRequest.
                 ),
              ],
              // --- End Conditional Field ---

              const SizedBox(height: AppConstants.defaultPadding),

              // --- Action Buttons ---
              // Align buttons to the right.
              Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   // Show "Annuler Rejet" or "Rejeter" button based on state.
                   if (_isRejecting)
                     TextButton(
                       onPressed: isLoading ? null : () => setState(() { _isRejecting = false; _rejectionReasonController.clear(); }),
                       child: const Text('Annuler'),
                     )
                   else
                     TextButton.icon(
                       icon: const Icon(Icons.close, size: 18),
                       label: const Text('Rejeter'),
                       style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                       // Disable if loading, otherwise enter rejection state.
                       onPressed: isLoading ? null : () => setState(() => _isRejecting = true),
                     ),

                    const SizedBox(width: 8), // Space between buttons

                     // Show "Approuver" or "Confirmer Rejet" button.
                    ButtonWidget(
                        // Change text based on rejection state.
                        text: _isRejecting ? 'Confirmer Rejet' : 'Approuver',
                        isLoading: isLoading, // Show loading indicator if processing.
                        // Call action method with appropriate status.
                        onPressed: isLoading ? null : () => _actionRequest(_isRejecting ? LeaveStatus.rejected : LeaveStatus.approved),
                         // Change color based on action.
                         backgroundColor: _isRejecting ? theme.colorScheme.error : Colors.green.shade600,
                         foregroundColor: Colors.white, // Ensure contrast.
                         type: ButtonType.elevated,
                    ),
                 ],
              ),
              // --- End Action Buttons ---
           ],
         ),
      ),
    );
  }
}