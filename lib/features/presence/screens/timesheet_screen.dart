import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/features/presence/providers/presence_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/features/presence/widgets/timesheet_day_card.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Corrected import

class TimesheetScreen extends ConsumerStatefulWidget {
  // Optional: Allow viewing other users' timesheets (for HR/Admin)
  final String? targetUserId;

  const TimesheetScreen({super.key, this.targetUserId});

  @override
  ConsumerState<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends ConsumerState<TimesheetScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Default to the current week
    _initializeDatesForCurrentWeek();
  }

   void _initializeDatesForCurrentWeek() {
    final now = DateTime.now();
    // Calculate the start of the current week (assuming Monday is the first day)
    int daysToSubtract = now.weekday - DateTime.monday;
    if (daysToSubtract < 0) {
       daysToSubtract += 7; // Adjust if Sunday is considered weekday 7
    }
    _startDate = DateUtils.dateOnly(now.subtract(Duration(days: daysToSubtract)));
    _endDate = DateUtils.dateOnly(_startDate.add(const Duration(days: 6)));
   }

   void _changeWeek(int weekDelta) {
      setState(() {
        _startDate = _startDate.add(Duration(days: 7 * weekDelta));
        _endDate = _endDate.add(Duration(days: 7 * weekDelta));
         // Invalidate the provider to refetch data for the new period
        // Note: We pass the NEW dates to the provider instance we watch
      });
       ref.invalidate(processedTimesheetProvider); // Invalidate the family
   }

   // TODO: Implement Date Range Picker for custom periods

  @override
  Widget build(BuildContext context) {
     // IMPORTANT: Watch the provider with the CURRENT state dates
    final timesheetAsyncValue = ref.watch(processedTimesheetProvider(_startDate, _endDate));
     final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
         title: Text(widget.targetUserId == null ? 'Ma Feuille de Temps' : 'Feuille de Temps Employé'),
         // TODO: Add Date Range Picker action
      ),
      body: Column(
        children: [
          // --- Week Navigation Header ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: AppConstants.defaultPadding),
            color: theme.appBarTheme.backgroundColor?.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Semaine précédente',
                  onPressed: () => _changeWeek(-1),
                ),
                 Text(
                  '${DateFormatter.formatDate(_startDate)} - ${DateFormatter.formatDate(_endDate)}',
                   style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                 ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                   tooltip: 'Semaine suivante',
                   // Disable next week button if it's the current week or future
                   onPressed: _endDate.isBefore(DateUtils.dateOnly(DateTime.now())) ? () => _changeWeek(1) : null,
                ),
              ],
            ),
          ),
          // --- Timesheet List ---
          Expanded(
            child: timesheetAsyncValue.when(
              data: (processedDays) {
                if (processedDays.isEmpty) {
                  return const Center(child: Text('Aucun pointage pour cette période.'));
                }
                // Calculate weekly summary
                 Duration weeklyWork = processedDays.fold(Duration.zero, (prev, day) => prev + day.totalWorkDuration);
                 Duration weeklyBreak = processedDays.fold(Duration.zero, (prev, day) => prev + day.totalBreakDuration);

                return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(processedTimesheetProvider(_startDate, _endDate)),
                  child: ListView( // Use ListView to include summary header
                     padding: const EdgeInsets.all(AppConstants.defaultPadding),
                     children: [
                        // Weekly Summary Card
                        Card(
                           color: theme.colorScheme.surfaceContainerHighest,
                           elevation: 1,
                           child: Padding(
                             padding: const EdgeInsets.all(AppConstants.defaultPadding),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                               children: [
                                 _buildSummaryItem(theme, Icons.work_history_outlined, "Travail Total", DateFormatter.formatDuration(weeklyWork)),
                                 _buildSummaryItem(theme, Icons.free_breakfast_outlined, "Pause Totale", DateFormatter.formatDuration(weeklyBreak)),
                               ],
                             ),
                           ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        // List of Day Cards
                        ...processedDays.map((dayEntry) => TimesheetDayCard(dayEntry: dayEntry)),
                     ],
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => ErrorMessageWidget(
                message: 'Erreur chargement feuille de temps: $error',
                onRetry: () => ref.invalidate(processedTimesheetProvider(_startDate, _endDate)),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildSummaryItem(ThemeData theme, IconData icon, String label, String value) {
     return Column(
        children: [
           Icon(icon, color: theme.colorScheme.primary, size: 20),
           const SizedBox(height: 4),
           Text(label, style: theme.textTheme.labelSmall),
           Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
     );
   }
}