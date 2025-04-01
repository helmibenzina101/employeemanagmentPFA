import 'package:flutter/material.dart';
import 'package:employeemanagment/core/models/time_entry_model.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart';

class ClockButton extends StatelessWidget {
  final TimeEntryType actionType;
  final VoidCallback onPressed;
  final bool isLoading;

  const ClockButton({
    super.key,
    required this.actionType,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define button properties based on action type
    String buttonText;
    IconData buttonIcon;
    Color backgroundColor;
    Color foregroundColor = Colors.white;
    
    switch (actionType) {
      case TimeEntryType.clockIn:
        buttonText = 'Arrivée';
        buttonIcon = Icons.login;
        backgroundColor = theme.colorScheme.primary;
        break;
      case TimeEntryType.clockOut:
        buttonText = 'Départ';
        buttonIcon = Icons.logout;
        backgroundColor = theme.colorScheme.error;
        break;
      case TimeEntryType.startBreak:
        buttonText = 'Début Pause';
        buttonIcon = Icons.coffee;
        backgroundColor = theme.colorScheme.secondary;
        break;
      case TimeEntryType.endBreak:
        buttonText = 'Fin Pause';
        buttonIcon = Icons.work;
        backgroundColor = theme.colorScheme.secondary;
        break;
    }

    return SizedBox(
      width: 200, // Set fixed width for consistent button size
      height: 50, // Height of the button
      child: ElevatedButton.icon(
        icon: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Icon(buttonIcon),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}