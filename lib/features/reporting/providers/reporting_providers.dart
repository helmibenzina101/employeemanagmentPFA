import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
// Ensure collection is imported if used (though not directly needed here)
// import 'package:collection/collection.dart';

// Core Imports
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/models/leave_request_model.dart';
// import 'package:employeemanagment/core/models/time_entry_model.dart'; // Not used in this provider yet
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Import for DateFormatter

part 'reporting_providers.g.dart'; // For Riverpod Generator

// --- Absence Report Data Structure ---
/// Holds the processed data for the absence report.
class AbsenceReportData {
  /// Total duration per leave type (Key: Leave Type Display Name (String), Value: Duration)
  final Map<String, Duration> totalLeaveByType;
  /// Count of requests per leave type (Key: Leave Type Display Name (String), Value: int)
  final Map<String, int> totalRequestsByType;
  /// Total leave duration per user ID (Key: User ID (String), Value: Duration)
  final Map<String, Duration> leaveByUser;
  /// Total number of approved requests in the period.
  final int totalApprovedRequests;
  // TODO: Add lateness/early departure stats if implementing

  AbsenceReportData({
    required this.totalLeaveByType,
    required this.totalRequestsByType,
    required this.leaveByUser,
    required this.totalApprovedRequests,
  });
}

// --- Absence Report Provider ---
/// Provider to generate absence report data for a given date range.
/// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
/// Consider server-side aggregation (e.g., Cloud Functions) for production.
@riverpod
Future<AbsenceReportData> absenceReport(AbsenceReportRef ref, DateTime startDate, DateTime endDate) async {
    final currentUser = ref.watch(currentUserDataProvider);
    final service = ref.watch(firestoreServiceProvider);

    // --- Authorization Check ---
    if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
        // Use a specific exception or error type if desired
        throw Exception("Accès non autorisé au rapport d'absences.");
    }

    // --- Data Fetching ---
    // 1. Fetch all active users (needed for per-user breakdown and names)
    // Await the future to get the list once for this report generation cycle.
    final List<UserModel> allUsers = await ref.watch(allActiveUsersStreamProvider.future);
    if (allUsers.isEmpty) {
      // Return empty report if there are no users
      return AbsenceReportData(
          totalLeaveByType: {},
          totalRequestsByType: {},
          leaveByUser: {},
          totalApprovedRequests: 0);
    }

    // 2. Fetch all leave requests (using the potentially inefficient method)
    // Ensure the FirestoreService method exists and returns the correct type.
    final Stream<List<LeaveRequestModel>> allReqStream = service.getAllLeaveRequestsStream();
    // Await the first list emitted by the stream for processing.
    final List<LeaveRequestModel> allReqList = await allReqStream.first;

    // --- Client-Side Filtering for Date Range ---
    // Convert report start/end dates to Timestamps for comparison.
    // Inside absenceReport provider, after fetching allReqList
    print("Fetched ${allReqList.length} total requests.");
    if (allReqList.isNotEmpty) {
       // Check the type and content of a sample request's fields
       var sampleReq = allReqList.first;
       print("Sample Request ID: ${sampleReq.id}, Type: ${sampleReq.type.runtimeType}, Days: ${sampleReq.days.runtimeType}, Status: ${sampleReq.status.runtimeType}, UserID: ${sampleReq.userId.runtimeType}");
    }

    // BEFORE the filter:
    final Timestamp startTimestamp = Timestamp.fromDate(startDate);
    final Timestamp endTimestamp = Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999));
    print("Filtering between $startTimestamp and $endTimestamp");

    final List<LeaveRequestModel> requestsInPeriod = allReqList.where((req) {
      try { // Add try-catch around filter logic
        final Timestamp reqStart = req.startDate;
        final Timestamp reqEnd = req.endDate;
        bool isInPeriod = reqStart.compareTo(endTimestamp) <= 0 && reqEnd.compareTo(startTimestamp) >= 0;
        // print("Checking request ${req.id}: $isInPeriod"); // Uncomment for very verbose logging
        return isInPeriod;
      } catch (e) {
        print("Error filtering request ${req.id}: $e");
        return false; // Exclude requests that cause errors during filtering
      }
    }).toList();
    print("Filtered down to ${requestsInPeriod.length} requests.");

    // --- Data Processing ---
    // Initialize maps to store aggregated data. Keys are Strings.
    final Map<String, Duration> totalLeaveByType = {}; // String (Type Name) -> Duration
    final Map<String, int> totalRequestsByType = {};    // String (Type Name) -> int (Count)
    // Initialize leaveByUser map with all fetched user IDs and zero duration.
    final Map<String, Duration> leaveByUser = { for(var u in allUsers) u.uid : Duration.zero };
    int totalApprovedRequests = 0;

    // Iterate through the requests *filtered for the period*.
    for (final LeaveRequestModel req in requestsInPeriod) {
        try {
            // Use the display name (String) of the leave type as the key.
            final String typeName = req.typeDisplay;

            // Increment the count for this request type.
            totalRequestsByType[typeName] = (totalRequestsByType[typeName] ?? 0) + 1;

            // Only aggregate duration for APPROVED requests.
            if (req.status == LeaveStatus.approved) {
                totalApprovedRequests++;

                // --- Duration Calculation (Example: Using req.days) ---
                // Convert days (double) to an estimated Duration (e.g., 8 hours/day).
                // Use .round() to get an int for Duration constructor.
                final Duration requestDuration = Duration(hours: (req.days * 8).round());

                // Add duration to the total for this leave type.
                totalLeaveByType[typeName] = (totalLeaveByType[typeName] ?? Duration.zero) + requestDuration;

                // Add duration to the total for this specific user.
                if (leaveByUser.containsKey(req.userId)) {
                   leaveByUser[req.userId] = (leaveByUser[req.userId] ?? Duration.zero) + requestDuration;
                } else {
                   print("Warning: Leave request found for unknown or inactive user ID: ${req.userId}");
                }
            }
        } catch (e) {
            print("Error processing request ${req.id}: $e");
            // Continue with the next request
        }
    }

    // --- Return Processed Data ---
    // Ensure all map keys and values have the correct types defined in AbsenceReportData.
    return AbsenceReportData(
       totalLeaveByType: totalLeaveByType, // Map<String, Duration>
       totalRequestsByType: totalRequestsByType, // Map<String, int>
       leaveByUser: leaveByUser, // Map<String, Duration>
       totalApprovedRequests: totalApprovedRequests, // int
    );
}

// --- Performance Report Data (Placeholder) ---
// TODO: Implement performance report logic and data structure.
// @riverpod
// Future<PerformanceReportData> performanceReport(PerformanceReportRef ref, ...) async { ... }
