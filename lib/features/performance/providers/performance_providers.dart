import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

// Core Imports
// Ensure UserModel is imported:
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/models/performance_review_model.dart';
import 'package:employeemanagment/core/providers/user_providers.dart'; // Imports user providers needed
import 'package:employeemanagment/core/enums/user_role.dart';


// Required for Riverpod code generation
part 'performance_providers.g.dart';


// --- Performance Reviews Stream ---

/// Provides a real-time stream of performance reviews FOR a specific employee.
@riverpod
Stream<List<PerformanceReviewModel>> reviewsForEmployee(ReviewsForEmployeeRef ref, String employeeId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.getPerformanceReviewsForEmployeeStream(employeeId);
}


/// Provider that fetches performance reviews for all users directly managed by the current user.
/// Returns a Future that resolves once all data is fetched for the initial load.
@riverpod
Future<List<PerformanceReviewModel>> reviewsForManagedUsers(ReviewsForManagedUsersRef ref) async {
    // Await the list of managed user models from its provider
    final List<UserModel> managedUsers = await ref.watch(managedUsersStreamProvider.future); // Uses UserModel here
    final service = ref.watch(firestoreServiceProvider);

    if (managedUsers.isEmpty) {
        return <PerformanceReviewModel>[];
    }

    // Fetch reviews for each managed user (inefficient for large numbers)
    List<PerformanceReviewModel> allReviews = [];
    final List<Future<List<PerformanceReviewModel>>> reviewFutures = managedUsers.map((user) {
       // Get the first list emitted by the stream for each user's reviews
       return ref.watch(reviewsForEmployeeProvider(user.uid).stream).first;
    }).toList();

    final List<List<PerformanceReviewModel>> results = await Future.wait(reviewFutures);
    allReviews = results.expand((list) => list).toList(); // Flatten the list
    allReviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate)); // Sort newest first

    return allReviews;
}


// --- Performance Review Controller ---
@riverpod
class PerformanceReviewController extends _$PerformanceReviewController {
    @override
    FutureOr<void> build() {
      return null;
    }

    /// Creates a new performance review document in Firestore.
    Future<bool> createReview({
        required String employeeUid,
        required String employeeName,
        required Timestamp periodStartDate,
        required Timestamp periodEndDate,
        required Map<String, int> ratings,
        required String overallComments,
        required String employeeComments,
        required String goalsForNextPeriod,
    }) async {
       state = const AsyncLoading();
       final currentUser = ref.read(currentUserDataProvider); // Uses UserModel? implicitly
       final service = ref.read(firestoreServiceProvider);

       if (currentUser == null) {
           state = AsyncError("Utilisateur non connecté.", StackTrace.current);
           return false;
       }

       // Authorization Check
        UserModel? targetEmployee; // Uses UserModel here
        try {
           targetEmployee = await ref.read(userStreamByIdProvider(employeeUid).future);
        } catch(e, stack) {
           print("Error fetching target employee for review creation: $e");
           state = AsyncError("Impossible de vérifier les informations de l'employé cible.", stack);
           return false;
        }

        if (targetEmployee == null) {
             state = AsyncError("Employé cible ($employeeUid) non trouvé.", StackTrace.current);
            return false;
        }

       final bool isManager = targetEmployee.managerUid == currentUser.uid;
       final bool isAdminOrHR = currentUser.role == UserRole.admin || currentUser.role == UserRole.rh;

       if (!isAdminOrHR && !isManager) {
            state = AsyncError("Action non autorisée.", StackTrace.current);
           return false;
       }

       final newReview = PerformanceReviewModel(
           id: '',
           employeeUid: employeeUid,
           employeeName: employeeName,
           reviewerUid: currentUser.uid,
           reviewerName: currentUser.nomComplet,
           reviewDate: Timestamp.now(),
           periodStartDate: periodStartDate,
           periodEndDate: periodEndDate,
           ratings: ratings,
           overallComments: overallComments,
           employeeComments: employeeComments,
           goalsForNextPeriod: goalsForNextPeriod,
       );

       try {
         await service.addPerformanceReview(newReview);
         ref.invalidate(reviewsForEmployeeProvider(employeeUid));
         if (isManager) ref.invalidate(reviewsForManagedUsersProvider);
         state = const AsyncData(null);
         return true;
       } catch (e, stack) {
          state = AsyncError("Erreur création évaluation: $e", stack);
          return false;
       }
    }
}