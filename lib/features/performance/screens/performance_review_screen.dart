import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
import 'package:employeemanagment/features/performance/providers/performance_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/features/performance/widgets/performance_review_card.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/app/navigation/app_routes.dart'; // Corrected import
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import

class PerformanceReviewScreen extends ConsumerWidget {
  // Optional: If Admin/HR/Manager views someone else's reviews
  final String? targetUserId;
  final String? targetUserName; // Pass name for app bar title

  const PerformanceReviewScreen({
    super.key,
    this.targetUserId,
    this.targetUserName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDataProvider);
    final String userIdToShow = targetUserId ?? currentUser?.uid ?? '';
    final bool isViewingOwn = targetUserId == null || targetUserId == currentUser?.uid;

    // Determine if the current user can create a review for the target user
     final bool canCreateReview = currentUser != null &&
         (currentUser.role == UserRole.admin || currentUser.role == UserRole.rh /* || isManager (check needed) */);
     // TODO: Add check if currentUser is manager of userIdToShow

    // Fetch the reviews for the user being viewed
    final reviewsAsync = ref.watch(reviewsForEmployeeProvider(userIdToShow));

    return Scaffold(
      appBar: AppBar(
         title: Text(isViewingOwn ? 'Mes Évaluations' : 'Évaluations de ${targetUserName ?? 'Employé'}'),
         // Add button for creating new review if authorized
         actions: [
            if(canCreateReview && !isViewingOwn) // Can only create for others
               IconButton(
                  icon: const Icon(Icons.add_chart),
                  tooltip: 'Nouvelle Évaluation',
                  // Pass target user ID to creation screen
                  onPressed: () => context.push('${AppRoutes.createReview}?employeeId=$userIdToShow'),
               ),
         ],
      ),
      body: RefreshIndicator(
         onRefresh: () async => ref.invalidate(reviewsForEmployeeProvider(userIdToShow)),
        child: reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Center(child: Text('Aucune évaluation de performance trouvée.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return PerformanceReviewCard(
                    review: reviews[index],
                    showEmployeeName: !isViewingOwn, // Show name if not viewing own
                );
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stack) => ErrorMessageWidget(
            message: 'Erreur chargement évaluations: $error',
            onRetry: () => ref.invalidate(reviewsForEmployeeProvider(userIdToShow)),
          ),
        ),
      ),
       // Optional FAB for managers/HR to create review for their team
       // floatingActionButton: canCreateReview ? FloatingActionButton( ... ) : null,
    );
  }
}