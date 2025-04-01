import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart'; // Needed for navigation constants
import 'package:employeemanagment/app/config/constants.dart';

// Feature Imports
import 'package:employeemanagment/features/admin/widgets/user_list_tile.dart';


/// Screen for Admins/HR to view and manage the list of users.
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
   final TextEditingController _searchController = TextEditingController();
   String _searchTerm = '';

  @override
  void initState() {
     super.initState();
     // Listen to search field changes to update the filter term
     _searchController.addListener(() {
        if (mounted) {
            setState(() { _searchTerm = _searchController.text.toLowerCase(); });
        }
     });
  }

   @override
   void dispose() {
     _searchController.dispose();
     super.dispose();
   }


  @override
  Widget build(BuildContext context) {
    // Watch the stream of all active users for the list display
    final usersAsync = ref.watch(allActiveUsersStreamProvider);
    // TODO: Implement filter/toggle to show inactive users as well

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        // Actions could include filtering options
      ),
      body: Column(
        children: [
           // --- Search Bar ---
           Padding(
             padding: const EdgeInsets.fromLTRB(
                 AppConstants.defaultPadding, AppConstants.defaultPadding,
                 AppConstants.defaultPadding, AppConstants.defaultPadding / 2
             ),
             child: TextField(
               controller: _searchController,
               decoration: InputDecoration(
                  hintText: 'Rechercher par nom, email, poste...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  // Clear button for the search field
                  suffixIcon: _searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Effacer la recherche',
                          onPressed: () => _searchController.clear(), // Listener updates state
                        )
                      : null,
               ),
             ),
           ),
           // --- User List ---
           Expanded(
            child: RefreshIndicator( // Enable pull-to-refresh
              onRefresh: () async => ref.invalidate(allActiveUsersStreamProvider),
              child: usersAsync.when(
                data: (users) {
                   // Apply client-side filtering based on the search term
                   final filteredUsers = users.where((user) {
                      final lowerSearch = _searchTerm; // Already lowercase from listener
                      return user.nomComplet.toLowerCase().contains(lowerSearch) ||
                             user.email.toLowerCase().contains(lowerSearch) ||
                             user.poste.toLowerCase().contains(lowerSearch);
                   }).toList();

                  // Display message if list is empty or filter yields no results
                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Text(
                          _searchTerm.isEmpty
                             ? 'Aucun utilisateur actif trouvé.'
                             : 'Aucun utilisateur ne correspond à votre recherche.'
                          ),
                      )
                    );
                  }
                  // Display the filtered list
                  return ListView.separated(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserListTile(
                        user: user,
                        // Navigate to the edit screen for the selected user
                        onTap: () {
                           context.push('${AppRoutes.editUser}/${user.uid}');
                        },
                      );
                    },
                     separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
                  );
                },
                loading: () => const LoadingWidget(), // Show loading indicator
                error: (error, stack) => ErrorMessageWidget( // Show error message
                  message: 'Erreur chargement utilisateurs: $error',
                  onRetry: () => ref.invalidate(allActiveUsersStreamProvider), // Allow retry
                ),
              ),
            ),
          ),
        ],
      ),
      // --- Floating Action Button to Add User ---
      floatingActionButton: FloatingActionButton.extended(
         icon: const Icon(Icons.add),
         label: const Text('Créer'), // Changed label for brevity
         tooltip: 'Créer un nouvel utilisateur',
         // Navigate to the Create User screen
         onPressed: () => context.push(AppRoutes.createUser),
      ),
      // --- End FAB ---
    );
  }
}