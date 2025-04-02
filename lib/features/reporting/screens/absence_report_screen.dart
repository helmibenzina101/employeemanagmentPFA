import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Feature Imports
// *** ENSURE THIS IMPORT IS CORRECT AND THE .g.dart FILE EXISTS ***
import 'package:employeemanagment/features/reporting/providers/reporting_providers.dart';
import 'package:employeemanagment/features/reporting/widgets/report_summary_card.dart';

// Core Imports
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/core/providers/user_providers.dart'; // Needed to get user names

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
     final now = DateTime.now();
     _startDate = DateTime(now.year, now.month, 1);
     _endDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _selectDateRange(BuildContext context) async {
     final initialRange = DateTimeRange(start: _startDate, end: _endDate);
     final picked = await showDateRangePicker(
        context: context,
        initialDateRange: initialRange,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('fr', 'FR'),
         helpText: 'Sélectionner la période du rapport',
         cancelText: 'Annuler',
         confirmText: 'Confirmer',
         saveText: 'Confirmer',
     );
      if (picked != null && picked != initialRange) {
         if (mounted) {
            setState(() {
               _startDate = picked.start;
               _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
            });
            // Fix: Invalidate the specific provider instance with parameters
            ref.invalidate(absenceReportProvider(_startDate, _endDate));
         }
      }
  }

  @override
  Widget build(BuildContext context) {
    // *** Watch the provider FAMILY INSTANCE with parameters ***
    final reportAsync = ref.watch(absenceReportProvider(_startDate, _endDate));
    final usersAsync = ref.watch(allActiveUsersStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
       appBar: AppBar(
         title: const Text('Rapport d\'Absences'),
         actions: [
           IconButton(
             icon: const Icon(Icons.calendar_month_outlined),
             tooltip: 'Changer la Période',
             onPressed: () => _selectDateRange(context),
           ),
         ],
       ),
      body: RefreshIndicator(
         // Fix: Invalidate the specific provider instance with parameters
         onRefresh: () async => ref.invalidate(absenceReportProvider(_startDate, _endDate)),
        child: ListView(
           padding: const EdgeInsets.all(AppConstants.defaultPadding),
           children: [
             Center(
               child: Text(
                   'Période: ${DateFormatter.formatDate(_startDate)} - ${DateFormatter.formatDate(_endDate)}',
                   style: theme.textTheme.titleMedium,
                ),
             ),
             const SizedBox(height: AppConstants.defaultPadding),
             reportAsync.when(
               data: (reportData) {
                  try {
                    final users = usersAsync.value ?? [];
                    final userMap = { for(var u in users) u.uid : u.nomComplet };
                    
                    return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text("Résumé Général", style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          GridView(
                             shrinkWrap: true,
                             physics: const NeverScrollableScrollPhysics(),
                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppConstants.defaultPadding,
                                mainAxisSpacing: AppConstants.defaultPadding,
                                childAspectRatio: 2.0,
                             ),
                             children: [
                                ReportSummaryCard(
                                   title: "Demandes Approuvées",
                                   value: reportData.totalApprovedRequests.toString(),
                                   icon: Icons.check_circle_outline,
                                   iconColor: Colors.green,
                                ),
                             ],
                          ),
                           const SizedBox(height: AppConstants.defaultPadding * 1.5),
                           Text("Congés Approuvés par Type", style: theme.textTheme.titleLarge),
                           const SizedBox(height: 8),
                           if (reportData.totalLeaveByType.isEmpty)
                              const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 16.0),
                                 child: Text("Aucun congé approuvé dans cette période.")
                              )
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
                                               Text(entry.key),
                                               Text(DateFormatter.formatDuration(entry.value)),
                                            ],
                                          ),
                                        )
                                     ).toList(),
                                  ),
                                ),
                              ),
                           const SizedBox(height: AppConstants.defaultPadding * 1.5),
                            Text("Congés Approuvés par Employé", style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                             if (reportData.leaveByUser.entries.where((e) => e.value > Duration.zero).isEmpty)
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 16.0),
                                 child: Text("Aucun employé avec congé approuvé dans cette période.")
                              )
                            else
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                                  child: Column(
                                     children: reportData.leaveByUser.entries
                                       .where((entry) => entry.value > Duration.zero)
                                       .map((entry) {
                                           final userName = userMap[entry.key] ?? 'ID: ${entry.key.substring(0, 6)}...';
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(child: Text(userName, overflow: TextOverflow.ellipsis)),
                                                Text(DateFormatter.formatDuration(entry.value)),
                                             ],
                                           ),
                                        );
                                     }).toList(),
                                  ),
                                ),
                              ),
                       ],
                    );
                  } catch (e) {
                    print("Error rendering report data: $e");
                    return ErrorMessageWidget(
                      message: "Erreur d'affichage: ${e.toString()}",
                      onRetry: () => ref.invalidate(absenceReportProvider(_startDate, _endDate)),
                    );
                  }
               },
               loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: LoadingWidget()
               ),
               error: (error, stack) {
                   print("Error in AbsenceReportScreen .when(): $error");
                   print(stack);
                   return ErrorMessageWidget(
                      message: "Erreur génération rapport: ${error.toString()}",
                      // Fix: Invalidate the specific provider instance with parameters
                      onRetry: () => ref.invalidate(absenceReportProvider(_startDate, _endDate)),
                   );
                },
             ),
           ],
        ),
      ),
    );
  }
}