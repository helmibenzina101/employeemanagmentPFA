import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/features/leave/providers/leave_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/features/leave/widgets/leave_approval_card.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

class LeaveApprovalScreen extends ConsumerWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequestsAsync = ref.watch(pendingLeaveRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Approbation des Congés')),
      body: RefreshIndicator(
         onRefresh: () async => ref.invalidate(pendingLeaveRequestsProvider),
        child: pendingRequestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text('Aucune demande de congé en attente d\'approbation.'),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return LeaveApprovalCard(request: requests[index]);
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stack) => ErrorMessageWidget(
            message: 'Erreur chargement demandes: $error',
            onRetry: () => ref.invalidate(pendingLeaveRequestsProvider),
          ),
        ),
      ),
    );
  }
}