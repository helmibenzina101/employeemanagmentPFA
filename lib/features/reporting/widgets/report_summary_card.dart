import 'package:flutter/material.dart';
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Icon(icon, size: 32, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                     overflow: TextOverflow.ellipsis,
                  ),
                   const SizedBox(height: 2),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                     overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}