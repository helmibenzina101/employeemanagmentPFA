import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
// For groupBy
// Corrected import
import 'package:employeemanagment/core/models/leave_request_model.dart'; // Corrected import
// Corrected import
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
// Corrected import
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import

part 'reporting_providers.g.dart';

// --- Absence Report Data ---

// Data structure for absence summary
class AbsenceReportData {
  final Map<String, Duration> totalLeaveByType; // Total days/duration per leave type
  final Map<String, int> totalRequestsByType; // Count of requests per type
  final Map<String, Duration> leaveByUser; // Total leave duration per user ID
  final int totalApprovedRequests;
  // Add lateness/early departure stats if time entries track expected hours

  AbsenceReportData({
    required this.totalLeaveByType,
    required this.totalRequestsByType,
    required this.leaveByUser,
    required this.totalApprovedRequests,
  });
}

// Provider to generate absence report data for a given period
// WARNING: Fetches ALL users and ALL their leave requests for the period.
// Potentially very inefficient. Consider server-side aggregation.
@riverpod
Future<AbsenceReportData> absenceReport(AbsenceReportRef ref, DateTime startDate, DateTime endDate) async {
    final currentUser = ref.watch(currentUserDataProvider);
    final service = ref.watch(firestoreServiceProvider);

    // Basic authorization check
    if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
        throw Exception("Accès non autorisé au rapport.");
    }

    // 1. Fetch all active users (needed for per-user breakdown)
    // Note: Using .future might not be ideal if the user list changes, but simpler for this example.
    final allUsers = await ref.watch(allActiveUsersStreamProvider.future);

    // 2. Fetch all leave requests within the date range
    // This requires a new method in FirestoreService that fetches requests across users
    // for a specific date range. Let's assume such a method exists:
    // Stream<List<LeaveRequestModel>> getAllLeaveRequestsStream(DateTime start, DateTime end)
    // For now, we'll simulate by fetching for each user (VERY INEFFICIENT!)
    List<LeaveRequestModel> allRequests = [];
    for (final user in allUsers) {
       // Need a way to fetch requests for a specific user and period
       // Let's assume a hypothetical method getLeaveRequestsForUserAndPeriod
       // final userRequests = await service.getLeaveRequestsForUserAndPeriod(user.uid, startDate, endDate);
       // allRequests.addAll(userRequests);
    }
     // **** Placeholder / Manual Fetch (REMOVE IN PRODUCTION) ****
     // This simulates fetching all requests. Replace with efficient query.
     print("WARNING: Absence report fetching ALL requests inefficiently!");
     final allReqStream = service.getAllLeaveRequestsStream(); // Hypothetical: gets ALL requests ever
     final allReqList = await allReqStream.first; // Get snapshot
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate.add(const Duration(days: 1))); // End of day
     allRequests = allReqList.where((req) =>
         req.startDate.compareTo(startTimestamp) >= 0 && req.startDate.compareTo(endTimestamp) < 0
     ).toList();
      // **** End Placeholder ****


    // 3. Process the data
    final Map<String, Duration> totalLeaveByType = {};
    final Map<String, int> totalRequestsByType = {};
    final Map<String, Duration> leaveByUser = { for(var u in allUsers) u.uid : Duration.zero };
    int totalApprovedRequests = 0;

     for (final req in allRequests) {
         final typeName = req.typeDisplay; // Use display name as key
          totalRequestsByType[typeName] = (totalRequestsByType[typeName] ?? 0) + 1;

         // Only count duration for approved leaves
         if (req.status == LeaveStatus.approved) {
             totalApprovedRequests++;
             // Assuming req.days is accurate. Convert days to Duration if needed.
             // For simplicity, let's sum days directly, then convert later if necessary.
             // Or assume 'Duration' here means 'total days represented as duration'
             final duration = Duration(hours: (req.days * 8).toInt()); // Example: 8 hours per day
             totalLeaveByType[typeName] = (totalLeaveByType[typeName] ?? Duration.zero) + duration;
             leaveByUser[req.userId] = (leaveByUser[req.userId] ?? Duration.zero) + duration;
         }
     }


    return AbsenceReportData(
       totalLeaveByType: totalLeaveByType,
       totalRequestsByType: totalRequestsByType,
       leaveByUser: leaveByUser,
       totalApprovedRequests: totalApprovedRequests,
    );
}

// --- Performance Report Data (Placeholder) ---
// TODO: Define PerformanceReportData structure
// TODO: Implement performanceReportProvider
// This would likely involve fetching reviews, calculating average ratings per user/dept, etc.
// Again, server-side aggregation is highly recommended.