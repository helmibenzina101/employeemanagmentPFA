import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core Imports
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected typo if project name changed
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/core/models/time_entry_model.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Feature Imports
import 'package:employeemanagment/features/presence/providers/presence_providers.dart';
// *** ENSURE THIS IMPORT EXISTS AND THE PATH/PROJECT NAME IS CORRECT ***
import 'package:employeemanagment/features/presence/widgets/clock_button.dart'; // Keep this import


class ClockInOutScreen extends ConsumerWidget {
  const ClockInOutScreen({super.key});

   Future<void> _performAction(BuildContext context, WidgetRef ref, TimeEntryType action) async {
     final success = await ref.read(clockControllerProvider.notifier)
                           .performClockAction(action);

     if (!success && context.mounted) {
         final errorState = ref.read(clockControllerProvider);
         if(errorState.hasError){
            showErrorSnackbar(context, errorState.error.toString());
         } else {
            showErrorSnackbar(context, "Erreur lors du pointage.");
         }
     } else if (success && context.mounted) {
          showSuccessSnackbar(context, 'Pointage enregistré: ${_getStatusText(action)}');
     }
   }

   String _getStatusText(TimeEntryType type) {
     switch (type) {
       case TimeEntryType.clockIn: return 'Arrivée';
       case TimeEntryType.clockOut: return 'Départ';
       case TimeEntryType.startBreak: return 'Début Pause';
       case TimeEntryType.endBreak: return 'Fin Pause';
     }
   }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastEntryAsync = ref.watch(lastTimeEntryProvider);
    final clockControllerState = ref.watch(clockControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage'),
         actions: [
            IconButton(
               icon: const Icon(Icons.list_alt_outlined),
               tooltip: 'Voir Feuille de Temps',
               onPressed: () => context.push(AppRoutes.timesheet),
            )
         ]
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: lastEntryAsync.when(
            data: (lastEntry) {
              final nextAction = ref.read(clockControllerProvider.notifier).getNextAction(lastEntry);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                    'Dernier pointage:',
                    style: theme.textTheme.titleMedium,
                   ),
                   const SizedBox(height: 8),
                   Text(
                      lastEntry != null
                          ? '${_getStatusText(lastEntry.type)} à ${DateFormatter.formatTimestamp(lastEntry.timestamp)}'
                          : 'Aucun pointage enregistré.',
                       style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                   ),
                  if(lastEntry?.type == TimeEntryType.clockIn)
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: StreamBuilder<DateTime>(
                         stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                         builder: (context, snapshot) {
                            if (!snapshot.hasData || lastEntry == null) return const SizedBox.shrink();
                            final duration = snapshot.data!.difference(lastEntry.timestamp.toDate());
                            return Text(
                              'Durée actuelle: ${DateFormatter.formatDuration(duration)}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                            );
                         }
                       ),
                     ),
                   const SizedBox(height: 40),

                   // *** RESTORED ClockButton USAGE ***
                   ClockButton( // Use the imported ClockButton widget
                     actionType: nextAction,
                     isLoading: clockControllerState.isLoading, // Use controller's loading state
                     onPressed: () => _performAction(context, ref, nextAction), // Trigger action
                   ),
                   // *** END RESTORED USAGE ***

                    const SizedBox(height: 40), // Spacer

                    OutlinedButton.icon(
                        icon: const Icon(Icons.list_alt_outlined),
                        label: const Text("Voir Feuille de Temps"),
                        onPressed: () => context.push(AppRoutes.timesheet), // Navigate
                    )
                ],
              );
            },
            loading: () => const LoadingWidget(),
            error: (error, stack) => ErrorMessageWidget(
              message: 'Erreur chargement dernier pointage: $error',
              onRetry: () => ref.invalidate(lastTimeEntryProvider),
            ),
          ),
        ),
      ),
    );
  }
}