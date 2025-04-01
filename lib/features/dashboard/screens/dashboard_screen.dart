import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/core/providers/user_providers.dart'; // Provides currentUserStreamProvider
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/models/user_model.dart'; // Needed for _buildDashboardCard call if using User type hint
// Import LoginController to trigger logout
import 'package:employeemanagment/features/auth/providers/auth_providers.dart'; // Provides loginControllerProvider
// Import leave-related providers
import 'package:employeemanagment/features/leave/providers/leave_providers.dart'; // Add this import for leave providers

/// The main screen displayed after successful login and validation.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user data stream provider
    final userAsyncValue = ref.watch(currentUserStreamProvider);
    final theme = Theme.of(context);

    // Use .when to handle the different states of the user data stream
    return userAsyncValue.when(
      // --- Data Loaded State ---
      data: (user) {
        // --- CRUCIAL CHECK: Validate user status AFTER data is loaded ---
        if (user == null || !user.isActive || user.status != 'active') {
          // Determine the specific reason for invalidity
          String errorMessage = "Erreur de compte inattendue.";
          if (user?.status == 'pending') errorMessage = "Compte en attente d'approbation.";
          if (user?.isActive == false) errorMessage = "Compte désactivé.";
          if (user == null) errorMessage = "Données utilisateur non trouvées après connexion.";

          print("DashboardScreen: Invalid user detected ($errorMessage). Forcing logout.");

          // Use addPostFrameCallback to trigger logout AFTER the current build completes.
          // This avoids trying to change state (logout) during a build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
              // Check mounted is good practice in callbacks
              if (context.mounted) {
                  // Trigger logout via the LoginController provider
                  // This will change authState, and GoRouter's redirect logic
                  // will then handle sending the user back to the login screen.
                  ref.read(loginControllerProvider.notifier).logout();
              }
          });

          // Display a temporary "Access Restricted" screen while logout occurs.
          return Scaffold(
            appBar: AppBar(title: const Text("Accès Restreint"), automaticallyImplyLeading: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Icon(Icons.lock_outline, size: 50, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(errorMessage, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const Text("Vous allez être déconnecté."),
                      const SizedBox(height: 20),
                      const LoadingWidget(size: 30), // Indicate activity
                   ],
                ),
              )
            ),
          );
        }
        // --- END VALIDATION CHECK ---

        // --- If user is valid, build the actual Dashboard UI ---
        print("DashboardScreen: User ${user.uid} is valid. Building dashboard UI.");
        return Scaffold(
           appBar: AppBar(
            title: const Text('Tableau de Bord'),
            automaticallyImplyLeading: false, // No back button on main dashboard
            actions: [
                 // Logout Button
                 IconButton(
                   icon: const Icon(Icons.logout),
                   tooltip: 'Déconnexion',
                   onPressed: () async {
                      final confirm = await showDialog<bool>(
                         context: context,
                         builder: (context) => AlertDialog(
                           title: const Text('Déconnexion'),
                           content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                           actions: [
                             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
                             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmer')),
                           ],
                         ),
                      );
                      if (confirm == true && context.mounted) { // Check mounted after await
                         await ref.read(loginControllerProvider.notifier).logout();
                         // GoRouter redirect handles navigation back to login
                      }
                   },
                 ),
            ],
           ),
          body: RefreshIndicator( // Allow pull-to-refresh
             onRefresh: () async {
                 // Invalidate providers that should be refreshed
                 ref.invalidate(currentUserStreamProvider);
                 
                 // If these providers aren't available yet, you can comment them out
                 // or replace with the correct provider names
                 if (ref.exists(leaveBalanceProvider)) {
                   ref.invalidate(leaveBalanceProvider);
                 }
                 if (ref.exists(currentUserLeaveRequestsProvider)) {
                   ref.invalidate(currentUserLeaveRequestsProvider);
                 }
                 // Add other relevant providers
             },
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Welcome message
                Text('Bonjour, ${user.prenom}!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Bienvenue sur votre tableau de bord.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary)),
                const SizedBox(height: 24),

                // Quick Actions Grid
                GridView.count(
                   crossAxisCount: 2, // Adjust number of columns as needed
                   shrinkWrap: true, // Essential inside ListView
                   physics: const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
                   crossAxisSpacing: AppConstants.defaultPadding,
                   mainAxisSpacing: AppConstants.defaultPadding,
                   children: [
                     _buildDashboardCard(context, theme: theme, icon: Icons.timer, label: 'Pointage', onTap: () => context.go(AppRoutes.clockInOut)),
                     _buildDashboardCard(context, theme: theme, icon: Icons.calendar_today, label: 'Congés', onTap: () => context.go(AppRoutes.leaveBalance)),
                     _buildDashboardCard(context, theme: theme, icon: Icons.person_outline, label: 'Mon Profil', onTap: () => context.go(AppRoutes.profile)),
                     _buildDashboardCard(context, theme: theme, icon: Icons.campaign_outlined, label: 'Annonces', onTap: () => context.go(AppRoutes.announcements)),
                     // Conditional Admin/HR Cards
                      if (user.role == UserRole.rh || user.role == UserRole.admin)
                       _buildDashboardCard(context, theme: theme, icon: Icons.check_circle_outline, label: 'Approb. Congés', color: Colors.orange.shade100, onTap: () => context.push(AppRoutes.leaveApproval)),
                     if (user.role == UserRole.admin) // Only Admin for user management in this setup
                       _buildDashboardCard(context, theme: theme, icon: Icons.group_add_outlined, label: 'Gestion Utilisateurs', color: Colors.blue.shade100, onTap: () => context.push(AppRoutes.userManagement)),
                     if (user.role == UserRole.rh || user.role == UserRole.admin)
                        _buildDashboardCard(context, theme: theme, icon: Icons.pending_actions_outlined, label: 'Approb. Comptes', color: Colors.purple.shade100, onTap: () => context.push(AppRoutes.userApproval)), // Link to user approval
                     if (user.role == UserRole.rh || user.role == UserRole.admin)
                       _buildDashboardCard(context, theme: theme, icon: Icons.bar_chart_outlined, label: 'Rapports', color: Colors.green.shade100, onTap: () => context.push(AppRoutes.absenceReport)),
                   ],
                 ),

                 const SizedBox(height: 24),
                 Text("Notifications Récentes / Actions", style: theme.textTheme.titleMedium),
                 const SizedBox(height: 8),
                 // Placeholder for dynamic content
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.info_outline, color: theme.colorScheme.secondary),
                      title: const Text('Aucune notification pour le moment.'),
                    ),
                  )
              ],
            ),
          ),
        );
      },
      // Loading state while fetching initial user data for the dashboard
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingWidget()), // Simpler loading indicator
      // Error state if fetching user data fails critically AFTER successful login
      error: (error, stack) {
           print("DashboardScreen: Critical error loading user data after login: $error");
           // This indicates a problem fetching essential user data. Force logout.
           WidgetsBinding.instance.addPostFrameCallback((_) {
               if (context.mounted) ref.read(loginControllerProvider.notifier).logout();
           });
           return Scaffold(
              appBar: AppBar(title: const Text("Erreur Chargement Utilisateur"), automaticallyImplyLeading: false),
              body: ErrorMessageWidget(message: "Impossible de charger vos données : $error\nDéconnexion..."),
           );
      }
    );
  }

  // --- Helper Method to Build Dashboard Cards ---
  Widget _buildDashboardCard(
      BuildContext context, {
      required ThemeData theme, // Pass theme explicitly
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color,
      }) {
     return Card(
        color: color ?? theme.cardTheme.color ?? theme.cardColor, // Use card theme color
        elevation: theme.cardTheme.elevation ?? 2,
        shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(12), // Match card shape
         child: Padding(
           padding: const EdgeInsets.all(AppConstants.defaultPadding),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Icon(icon, size: 40, color: theme.colorScheme.primary),
               const SizedBox(height: 12),
               Text(
                 label,
                 textAlign: TextAlign.center,
                 style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                 maxLines: 2, // Prevent overflow on small cards
                 overflow: TextOverflow.ellipsis,
               ),
             ],
           ),
         ),
       ),
     );
   }
   // --- End Helper Method ---
}