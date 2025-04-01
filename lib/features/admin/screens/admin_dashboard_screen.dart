import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/core/providers/user_providers.dart'; // To confirm role
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // You could potentially fetch specific admin-related data here if needed

    // Although routing should prevent non-admins/HR from reaching here,
    // an extra check can be added for robustness.
    final user = ref.watch(currentUserDataProvider);
    if (user?.role != UserRole.admin && user?.role != UserRole.rh) {
      // This case should ideally not be reachable due to GoRouter redirects
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Accès non autorisé.")),
      );
    }

    return Scaffold(
      // AppBar might be redundant if using ShellRoute with consistent AppBar,
      // but defining it here allows for a specific title for this section.
      appBar: AppBar(
        title: const Text('Administration / RH'),
        // No leading back button if part of ShellRoute
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _buildAdminTile(
            context: context,
            theme: theme,
            icon: Icons.person_add_disabled_outlined, // Or pending icon
            title: 'Approbation Nouveaux Comptes',
            subtitle: 'Activer les comptes en attente',
            routeName: AppRoutes.userApproval, // Navigate to new screen
          ),
          _buildAdminTile(context: context, theme: theme, icon: Icons.group_outlined, title: 'Gestion des Utilisateurs', subtitle: 'Voir, modifier les rôles et statuts', routeName: AppRoutes.userManagement),
          _buildAdminTile(context: context, theme: theme, icon: Icons.check_circle_outline, title: 'Approbations des Congés', subtitle: 'Traiter les demandes en attente', routeName: AppRoutes.leaveApproval),
          _buildAdminTile(
            context: context,
            theme: theme,
            icon: Icons.edit_note_outlined,
            title: 'Gérer les Annonces',
            subtitle: 'Créer ou supprimer des annonces',
            // Navigate to Create screen, or potentially a screen listing existing announcements for editing/deleting
            routeName: AppRoutes.createAnnouncement,
          ),
          _buildAdminTile(
            context: context,
            theme: theme,
            icon: Icons.access_time_outlined,
            title: 'Gestion Heures Suppl.',
            subtitle: 'Suivre et valider les heures supp.', // Placeholder text
            routeName: AppRoutes.overtime,
          ),
          _buildAdminTile(
            context: context,
            theme: theme,
            icon: Icons.bar_chart_outlined,
            title: 'Rapports',
            subtitle: 'Consulter les rapports d\'absences, etc.',
            routeName: AppRoutes.absenceReport, // Navigate to absence report or a report menu
          ),
          _buildAdminTile(
            context: context,
            theme: theme,
            icon: Icons.settings_outlined,
            title: 'Paramètres Application',
            subtitle: 'Configurer types de congés, critères...', // Placeholder text
            routeName: AppRoutes.settings,
          ),
          // Add other Admin/HR links as needed...
        ],
      ),
    );
  }

  // Helper widget to create consistent list tiles for admin actions
  Widget _buildAdminTile({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 30),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(routeName), // Use push for sub-navigation
      ),
    );
  }
}