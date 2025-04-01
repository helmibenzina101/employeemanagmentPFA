import 'package:flutter/material.dart';
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap; // Optional: for making tile tappable (e.g., phone)

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell( // Wrap with InkWell if onTap is provided
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultPadding / 1.5, // Adjust vertical padding
          horizontal: AppConstants.defaultPadding,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary), // Smaller label
                  ),
                   const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : '-', // Display '-' if value is empty
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (onTap != null) // Show arrow if tappable
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}