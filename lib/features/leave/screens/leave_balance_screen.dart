import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Needed for context.push
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp (used by model)

// Core Imports
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/models/leave_request_model.dart';
import 'package:employeemanagment/app/config/constants.dart';
// Import for AppRoutes:
import 'package:employeemanagment/app/navigation/app_routes.dart'; // Added Import

// Feature Imports
import 'package:employeemanagment/features/leave/providers/leave_providers.dart';
import 'package:employeemanagment/features/leave/widgets/leave_request_card.dart';


/// Screen displaying the user's leave balance and their request history.
class LeaveBalanceScreen extends ConsumerWidget {
  const LeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers for balance and request history
    final balanceAsyncValue = ref.watch(leaveBalanceProvider);
    final requestsAsyncValue = ref.watch(currentUserLeaveRequestsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Congés et Soldes')),
      // Use RefreshIndicator for pull-to-refresh functionality
      body: RefreshIndicator(
         onRefresh: () async {
            // Invalidate both providers to refetch data
            ref.invalidate(leaveBalanceProvider);
            ref.invalidate(currentUserLeaveRequestsProvider);
         },
        child: ListView( // Use ListView to allow scrolling of balance and history
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // --- Balance Section ---
            Text('Mon Solde de Congés (Année en cours)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            // Use .when to handle loading/error/data states for balance
            balanceAsyncValue.when(
              data: (balanceMap) {
                // Handle case where balance calculation might return empty
                if (balanceMap.isEmpty) {
                   return const Card(
                    child: ListTile(
                        leading: Icon(Icons.warning_amber_rounded),
                        title: Text("Impossible de calculer le solde."),
                        subtitle: Text("Vérifiez la configuration ou réessayez.")
                    )
                   );
                }
                // Filter out unpaid leave from the summary if it's infinity, as it's less informative
                final displayBalances = Map.from(balanceMap)..removeWhere((key, value) => key == LeaveType.unpaid && value == double.infinity);

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    // Use Wrap to display balances nicely on different screen sizes
                    child: Wrap(
                      spacing: AppConstants.defaultPadding * 2, // Horizontal spacing
                      runSpacing: AppConstants.defaultPadding, // Vertical spacing
                      alignment: WrapAlignment.spaceEvenly, // Distribute items evenly
                      children: displayBalances.entries.map((entry) {
                          // Get display name for the leave type
                           final typeDisplay = LeaveRequestModel(id:'', userId:'', userName:'', type:entry.key, startDate:Timestamp.now(), endDate:Timestamp.now(), days:0, reason:'', requestedAt: Timestamp.now()).typeDisplay;
                          // Build a display widget for each balance item
                          return _buildBalanceItem(theme, typeDisplay, entry.value);
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: LoadingWidget(size: 30))
              ), // Show loading indicator
              error: (error, stack) => ErrorMessageWidget(message: 'Erreur calcul solde: $error'), // Show error
            ),
            // --- End Balance Section ---

            const SizedBox(height: AppConstants.defaultPadding * 2),

            // --- History Section Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Historique des Demandes', style: theme.textTheme.titleLarge),
                 // Button to navigate to the new request screen
                 TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Nouvelle'),
                    // Use context.push with the defined AppRoute constant
                    onPressed: () => context.push(AppRoutes.leaveRequest),
                 ),
              ],
            ),
            const SizedBox(height: 8),
            // --- History List ---
            // Use .when for the request history provider
            requestsAsyncValue.when(
              data: (requests) {
                // Show message if no requests exist
                if (requests.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Text('Aucune demande de congé trouvée.'),
                    ),
                  );
                }
                // Build list of LeaveRequestCard widgets
                return Column(
                  children: requests.map((req) => LeaveRequestCard(request: req)).toList(),
                );
              },
              loading: () => const Center(child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 30.0),
                 child: LoadingWidget())
              ), // Show loading
              error: (error, stack) => ErrorMessageWidget(
                 message: 'Erreur chargement historique: $error',
                 onRetry: () => ref.invalidate(currentUserLeaveRequestsProvider), // Allow retry
              ),
            ),
             // --- End History List ---
            const SizedBox(height: 80), // Add padding at the bottom for FAB
          ],
        ),
      ),
       // Floating action button for quick access to new request screen
       floatingActionButton: FloatingActionButton.extended(
         icon: const Icon(Icons.add),
         label: const Text('Demander Congé'),
         // Use context.push with the defined AppRoute constant
         onPressed: () => context.push(AppRoutes.leaveRequest),
       ),
    );
  }

  /// Helper widget to display a single leave balance item.
  Widget _buildBalanceItem(ThemeData theme, String type, double balance) {
     return Column(
        mainAxisSize: MainAxisSize.min, // Take minimum space
        children: [
           Text(
             // Display infinity symbol for unlimited balances
             balance == double.infinity ? '∞' : balance.toStringAsFixed(1),
             style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
             )
           ),
           Text('$type (j)', style: theme.textTheme.bodyMedium), // Label with units
        ],
     );
   }
}