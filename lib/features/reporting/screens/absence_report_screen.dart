import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/features/reporting/providers/reporting_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/features/reporting/widgets/report_summary_card.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Corrected import
import 'package:employeemanagment/core/providers/user_providers.dart'; // For user names

class AbsenceReportScreen extends ConsumerStatefulWidget {
  const AbsenceReportScreen({super.key});

  @override
  ConsumerState<AbsenceReportScreen> createState() => _AbsenceReportScreenState();
}

class _AbsenceReportScreenState extends ConsumerState<AbsenceReportScreen> {
   late DateTime _startDate;
   late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Default to current month
     final now = DateTime.now();
     _startDate = DateTime(now.year, now.month, 1);
     _endDate = DateTime(now.year, now.month + 1, 0); // Last day of current month
  }

  Future<void> _selectDateRange(BuildContext context) async {
     final initialRange = DateTimeRange(start: _startDate, end: _endDate);
     final picked = await showDateRangePicker(
        context: context,
        initialDateRange: initialRange,
        firstDate: DateTime(DateTime.now().year - 2), // Allow up to 2 years back
        lastDate: DateTime.now(),
        locale: const Locale('fr', 'FR'),
         helpText: 'Sélectionner la période du rapport',
         saveText: 'Confirmer',
     );
      if (picked != null && picked != initialRange) {
         setState(() {
            _startDate = picked.start;
            _endDate = picked.end;
             // Invalidate provider to refetch with new dates
             ref.invalidate(absenceReportProvider);
         });
      }
  }

  @override
  Widget build(BuildContext context) {
     // Watch provider with current dates
    final reportAsync = ref.watch(absenceReportProvider(_startDate, _endDate));
     // Watch all users provider to resolve names for the 'by user' list
     final usersAsync = ref.watch(allActiveUsersStreamProvider);
     final theme = Theme.of(context);

    return Scaffold(
       appBar: AppBar(
         title: const Text('Rapport d\'Absences'),
         actions: [
           IconButton(
             icon: const Icon(Icons.calendar_month_outlined),
             tooltip: 'Changer Période',
             onPressed: () => _selectDateRange(context),
           ),
           // TODO: Add Export button
           // IconButton(icon: Icon(Icons.download), onPressed: (){}),
         ],
       ),
      body: RefreshIndicator(
         onRefresh: () async => ref.invalidate(absenceReportProvider(_startDate, _endDate)),
        child: ListView(
           padding: const EdgeInsets.all(AppConstants.defaultPadding),
           children: [
             // Date Range Display
              Center(
                child: Text(
                    'Période: ${DateFormatter.formatDate(_startDate)} - ${DateFormatter.formatDate(_endDate)}',
                    style: theme.textTheme.titleMedium,
                 ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Report Content
              reportAsync.when(
                data: (reportData) {
                   final users = usersAsync.value ?? []; // Get user list, default to empty
                   final userMap = { for(var u in users) u.uid : u.nomComplet }; // Map ID to Name

                  // --- Summary Cards ---
                  return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text("Résumé Général", style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        GridView(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Adjust as needed
                              crossAxisSpacing: AppConstants.defaultPadding,
                              mainAxisSpacing: AppConstants.defaultPadding,
                              childAspectRatio: 2.0, // Adjust aspect ratio
                           ),
                           children: [
                              ReportSummaryCard(
                                 title: "Demandes Approuvées",
                                 value: reportData.totalApprovedRequests.toString(),
                                 icon: Icons.check_circle_outline,
                                 iconColor: Colors.green,
                              ),
                               // Add more summary cards (e.g., total days off)
                               // ReportSummaryCard(title: "Jours Off Totaux", value: "...", icon: Icons.calendar_month),
                           ],
                        ),
                         const SizedBox(height: AppConstants.defaultPadding * 1.5),

                         // --- Leave By Type ---
                         Text("Congés Approuvés par Type", style: theme.textTheme.titleLarge),
                         const SizedBox(height: 8),
                         if (reportData.totalLeaveByType.isEmpty)
                            const Text("Aucun congé approuvé dans cette période.")
                         else
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                                child: Column(
                                   children: reportData.totalLeaveByType.entries.map((entry) =>
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                             Text(entry.key, style: theme.textTheme.bodyLarge),
                                             Text(DateFormatter.formatDuration(entry.value), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      )
                                   ).toList(),
                                ),
                              ),
                            ),
                         const SizedBox(height: AppConstants.defaultPadding * 1.5),

                         // --- Leave By User ---
                          Text("Congés Approuvés par Employé", style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                           if (reportData.leaveByUser.entries.where((e) => e.value > Duration.zero).isEmpty)
                             const Text("Aucun congé approuvé dans cette période.")
                           else
                             Card(
                               child: Padding(
                                 padding: const EdgeInsets.all(AppConstants.defaultPadding),
                                 child: Column(
                                   children: reportData.leaveByUser.entries
                                      // Filter out users with zero leave
                                     .where((entry) => entry.value > Duration.zero)
                                     // Sort by duration descending?
                                     // .sorted((a,b) => b.value.compareTo(a.value))
                                     .map((entry) {
                                         final userName = userMap[entry.key] ?? 'Employé Inconnu (${entry.key.substring(0, 5)}...)';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                               Flexible(child: Text(userName, style: theme.textTheme.bodyLarge, overflow: TextOverflow.ellipsis)),
                                               Text(DateFormatter.formatDuration(entry.value), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        );
                                     }).toList(),
                                 ),
                               ),
                             ),
                         // TODO: Add Charts using fl_chart if desired
                     ],
                  );
                },
                loading: () => const Padding(
                   padding: EdgeInsets.symmetric(vertical: 50.0), child: LoadingWidget()
                ),
                error: (error, stack) => ErrorMessageWidget(
                   message: 'Erreur génération rapport: $error',
                   onRetry: () => ref.invalidate(absenceReportProvider(_startDate, _endDate)),
                ),
              ),
           ],
        ),
      ),
    );
  }
}