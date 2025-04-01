import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For cancel action
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp
import 'package:employeemanagment/core/models/leave_request_model.dart'; // Corrected import
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/features/leave/providers/leave_providers.dart'; // For cancel provider

class LeaveRequestCard extends ConsumerWidget {
  final LeaveRequestModel request;
  final bool showUserName; // If viewing as HR/Admin

  const LeaveRequestCard({
    super.key,
    required this.request,
    this.showUserName = false,
  });

  void showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canCancel = request.status == LeaveStatus.pending && !showUserName; // Only user can cancel their own pending

    return Card(
       margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
       elevation: 1.5,
       shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: request.statusColor.withOpacity(0.5), width: 1), // Border color based on status
       ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leave Type and User Name (if applicable)
                Flexible(
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.typeDisplay, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      if (showUserName)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(request.userName, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                        ),
                    ],
                  ),
                ),
                // Status Chip
                Chip(
                  label: Text(request.statusDisplay, style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
                  backgroundColor: request.statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: AppConstants.defaultPadding),
            // Dates and Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _buildDateColumn(theme, 'Du', request.startDate),
                 const Icon(Icons.arrow_forward, size: 18),
                 _buildDateColumn(theme, 'Au', request.endDate),
                  _buildDaysColumn(theme, request.days),
              ],
            ),
             const SizedBox(height: AppConstants.defaultPadding / 2),
            // Reason
            if (request.reason.isNotEmpty)
              Text('Raison: ${request.reason}', style: theme.textTheme.bodyMedium),

             // Rejection Reason (if rejected)
             if (request.status == LeaveStatus.rejected && request.rejectionReason != null)
                Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text('Motif du rejet: ${request.rejectionReason}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                ),

             // Cancel Button (if applicable)
             if (canCancel)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Annuler demande'),
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        onPressed: () async {
                             // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                title: const Text('Annuler la demande'),
                                content: const Text('Êtes-vous sûr de vouloir annuler cette demande de congé ?'),
                                actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Non')),
                                    TextButton(
                                       onPressed: () => Navigator.of(context).pop(true),
                                       style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                       child: const Text('Oui, Annuler'),
                                    ),
                                ],
                                ),
                            );
                            if (confirm == true) {
                                final success = await ref.read(leaveRequestControllerProvider.notifier).cancelLeaveRequest(request);
                                if (!success && context.mounted) {
                                     final errorState = ref.read(leaveRequestControllerProvider);
                                     if(errorState.hasError){
                                       showErrorSnackbar(context, errorState.error.toString());
                                     }
                                } else if (success && context.mounted) {
                                     showSuccessSnackbar(context, 'Demande annulée.');
                                }
                            }
                        },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

   Widget _buildDateColumn(ThemeData theme, String label, Timestamp timestamp) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: theme.textTheme.labelSmall),
           Text(DateFormatter.formatTimestampDate(timestamp), style: theme.textTheme.bodyMedium),
        ],
     );
   }
   Widget _buildDaysColumn(ThemeData theme, double days) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
           Text('Jours', style: theme.textTheme.labelSmall),
           Text(days.toStringAsFixed(1), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
     );
   }
}