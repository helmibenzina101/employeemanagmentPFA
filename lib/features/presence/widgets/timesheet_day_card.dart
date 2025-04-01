import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateFormat.EEEE

// Core imports
import 'package:employeemanagment/core/models/time_entry_model.dart'; // Corrected import
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

// Feature specific imports (needed for ProcessedDayEntry and TimeInterval)
import 'package:employeemanagment/features/presence/providers/presence_providers.dart'; // Corrected import


/// A card widget to display the summary and details of time entries for a single day.
class TimesheetDayCard extends StatelessWidget {
  /// The processed data for the day, containing summaries and intervals.
  final ProcessedDayEntry dayEntry;

  const TimesheetDayCard({super.key, required this.dayEntry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Format the day name and date using the French locale
    final dayName = DateFormat.EEEE(DateFormatter.frenchLocale).format(dayEntry.date);
    final dateFormatted = DateFormatter.formatDate(dayEntry.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 2,
      // Use ExpansionTile to allow users to view detailed intervals
      child: ExpansionTile(
        // --- Header Section of the Card ---
        leading: CircleAvatar( // Display the day of the month
           backgroundColor: theme.colorScheme.primaryContainer,
           child: Text(
              dayEntry.date.day.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
           ),
        ),
        title: Text( // Display Day Name and Date
          '$dayName $dateFormatted',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
        subtitle: Text( // Display Total Work and Break Durations
           'Travail: ${DateFormatter.formatDuration(dayEntry.totalWorkDuration)}${dayEntry.totalBreakDuration > Duration.zero ? ' | Pause: ${DateFormatter.formatDuration(dayEntry.totalBreakDuration)}' : ''}'
        ),
         trailing: Text( // Display First Clock-In and Last Clock-Out Time
          '${dayEntry.clockInTime != null ? DateFormatter.formatTimestampTime(dayEntry.clockInTime!) : "--:--"} - ${dayEntry.clockOutTime != null ? DateFormatter.formatTimestampTime(dayEntry.clockOutTime!) : "--:--"}',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
         ),
         // Initially expanded state can be set here if needed: initiallyExpanded: false,

         // --- Expanded Content (Details) ---
         children: <Widget>[
           Padding(
             // Add padding inside the expanded section
             padding: const EdgeInsets.fromLTRB(AppConstants.defaultPadding, 0, AppConstants.defaultPadding, AppConstants.defaultPadding),
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Divider(), // Separator between header and details
                    Text('Détails des pointages:', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    // --- Logic to Display Details ---
                    // Option 1: If intervals are empty but raw entries exist (simple clock in/out)
                     if(dayEntry.intervals.isEmpty && dayEntry.rawEntries.isNotEmpty)
                        ...dayEntry.rawEntries.map((entry) => _buildDetailRow(theme, entry))
                     // Option 2: If no intervals and no raw entries (shouldn't happen if card is shown)
                     else if (dayEntry.intervals.isEmpty)
                         const Text("Aucun pointage détaillé pour cette journée.", style: TextStyle(fontStyle: FontStyle.italic))
                     // Option 3: Display calculated intervals (work/break)
                     else
                         ...dayEntry.intervals.map((interval) => _buildIntervalRow(theme, interval)),
                    // --- End Detail Display Logic ---
                ],
             ),
           )
         ],
      ),
    );
  }

  /// Helper widget to build a row displaying a single raw time entry.
  /// Used as a fallback if interval calculation isn't performed or is simple.
  Widget _buildDetailRow(ThemeData theme, TimeEntryModel entry) {
      IconData icon; // Variable for the icon
      String label; // Variable for the action label

       // Assign icon and label based on the TimeEntryType
       // This switch MUST cover all cases of TimeEntryType
       switch (entry.type) {
         case TimeEntryType.clockIn:
             icon = Icons.login;
             label = 'Arrivée';
             break;
         case TimeEntryType.clockOut:
             icon = Icons.logout;
             label = 'Départ';
             break;
         case TimeEntryType.startBreak:
             icon = Icons.pause;
             label = 'Début Pause';
             break;
         case TimeEntryType.endBreak:
             icon = Icons.play_arrow;
             label = 'Fin Pause';
             break;
         // No default needed if all enum cases are handled explicitly.
       }

      // Build the row widget
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text('$label: ${DateFormatter.formatTimestampTime(entry.timestamp)}'),
            // Display note if present
            if (entry.note != null && entry.note!.isNotEmpty)
               Expanded(
                 child: Text(
                   ' (${entry.note})',
                   style: theme.textTheme.bodySmall,
                   overflow: TextOverflow.ellipsis // Prevent long notes from overflowing
                 )
               ),
          ],
        ),
      );
  }

  /// Helper widget to build a row displaying a calculated time interval (work or break).
  Widget _buildIntervalRow(ThemeData theme, TimeInterval interval) {
      IconData icon; // Variable for the icon
      String label; // Variable for the interval type label
      Color color; // Variable for the icon/text color

      // Assign icon, label, and color based on the interval's type
      // This switch MUST be exhaustive for all types used in TimeInterval
       switch (interval.type) {
         case TimeEntryType.clockIn: // Represents a work interval in our provider logic
             icon = Icons.work_outline;
             label = 'Travail';
             color = Colors.green.shade700; // Or theme.colorScheme.primary
             break;
         case TimeEntryType.startBreak: // Represents a break interval in our provider logic
             icon = Icons.free_breakfast_outlined;
             label = 'Pause';
              color = Colors.orange.shade700; // Or theme.colorScheme.secondary
             break;
          // --- Add default case to handle unexpected interval types ---
         case TimeEntryType.clockOut: // Should not typically be an interval type
         case TimeEntryType.endBreak: // Should not typically be an interval type
         default:
              icon = Icons.error_outline; // Indicate an issue
              label = 'Intervalle Inconnu';
              color = Colors.grey;
              // Log a warning for debugging if this case is reached
              print("Warning: Unexpected interval type found in timesheet card: ${interval.type}");
              break;
          // --- End default case ---
       }

      // Build the row widget
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            // Display label and start/end times
            Text(
              '$label: ${DateFormatter.formatTimestampTime(interval.start)} - ${DateFormatter.formatTimestampTime(interval.end)}',
               style: theme.textTheme.bodyMedium
            ),
            const SizedBox(width: 10),
            // Display the duration of the interval
             Text(
              '(${DateFormatter.formatDuration(interval.duration)})',
               style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)
            ),
          ],
        ),
      );
  }
}