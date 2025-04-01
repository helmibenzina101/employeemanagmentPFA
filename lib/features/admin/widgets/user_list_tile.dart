import 'package:flutter/material.dart';
import 'package:employeemanagment/core/models/user_model.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/user_avatar.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserListTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
       contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 4),
       leading: UserAvatar.fromModel(user, radius: 22),
       title: Text(user.nomComplet, style: theme.textTheme.titleMedium),
       subtitle: Text('${user.poste} | ${user.email}', style: theme.textTheme.bodyMedium),
       trailing: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
            // Role Chip
            Chip(
              label: Text(user.role.displayName, style: theme.textTheme.labelSmall),
              visualDensity: VisualDensity.compact,
               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
               backgroundColor: theme.colorScheme.secondaryContainer,
               labelStyle: TextStyle(fontSize: 11, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 8),
            // Active Status Icon
            Icon(
              user.isActive ? Icons.check_circle : Icons.cancel,
              color: user.isActive ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right), // Indicate tappable
         ],
       ),
       onTap: onTap,
    );
  }
}