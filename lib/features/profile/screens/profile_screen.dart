import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/widgets/user_avatar.dart';
import 'package:employeemanagment/features/profile/widgets/profile_info_tile.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/app/config/constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        // --- CORRECTED ACTIONS ---
        actions: userAsyncValue.maybeWhen(
           data: (user) {
             // If user data is available and not null, return a list with the IconButton
             if (user != null) {
               return <Widget>[ // Return List<Widget>
                 IconButton(
                   icon: const Icon(Icons.edit_outlined),
                   tooltip: 'Modifier le profil',
                   onPressed: () => context.push(AppRoutes.editProfile),
                 ),
               ];
             } else {
               // If user is null, return an empty list
               return <Widget>[];
             }
           },
           // In loading or error states, return an empty list for actions
           orElse: () => <Widget>[], // Return List<Widget>
         ) ?? <Widget>[], // Provide default empty list
         // --- END CORRECTED ACTIONS ---
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            // This state should ideally be prevented by router redirects if user is null after login
             return const ErrorMessageWidget(message: 'Impossible de charger les données utilisateur.');
          }
          // --- User data is available, build the profile view ---
          return RefreshIndicator(
             onRefresh: () async => ref.invalidate(currentUserStreamProvider),
            child: ListView(
              children: [
                const SizedBox(height: AppConstants.defaultPadding * 1.5),
                // Avatar Section
                Column(
                  children: [
                    UserAvatar.fromModel(user, radius: 50, fontSize: 28),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      user.nomComplet,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.poste,
                       style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                       textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding * 1.5),
                const Divider(),

                // Personal Information Section
                ProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: 'E-mail',
                  value: user.email,
                ),
                 ProfileInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  value: user.telephone ?? 'Non renseigné',
                   // Add onTap for launching phone dialer if desired
                   // onTap: user.telephone != null ? () { /* launchUrl('tel:${user.telephone}') */ } : null,
                ),
                 ProfileInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Poste',
                  value: user.poste,
                ),
                 ProfileInfoTile(
                  icon: Icons.perm_identity,
                  label: 'Rôle',
                  value: user.role.displayName,
                ),
                ProfileInfoTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Date d\'embauche',
                  value: DateFormatter.formatTimestampDate(user.dateEmbauche),
                ),
                // TODO: Display Manager Name (requires fetching manager data if managerUid exists)

                 const Divider(),

                // Documents Section Link
                 ListTile(
                   leading: const Icon(Icons.folder_open_outlined),
                   title: const Text('Mes Documents'),
                   subtitle: const Text('Consulter les références (contrats, etc.)'),
                   trailing: const Icon(Icons.chevron_right),
                   // Navigate to the documents screen for the current user
                   onTap: () => context.push(AppRoutes.documents),
                 ),

                 // Performance Reviews Link
                  ListTile(
                   leading: const Icon(Icons.star_border_outlined),
                   title: const Text('Mes Évaluations'),
                   trailing: const Icon(Icons.chevron_right),
                    // Navigate to performance review screen for the current user
                   onTap: () => context.push(AppRoutes.performanceReview),
                 ),

                const Divider(),
                const SizedBox(height: AppConstants.defaultPadding * 2), // Bottom padding
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(), // Show loading indicator while fetching data
        error: (error, stack) => ErrorMessageWidget( // Show error message if fetching fails
          message: 'Erreur chargement profil: $error',
          onRetry: () => ref.invalidate(currentUserStreamProvider), // Allow user to retry
        ),
      ),
    );
  }
}