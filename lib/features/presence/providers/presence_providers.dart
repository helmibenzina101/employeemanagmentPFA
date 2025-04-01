import 'package:flutter/material.dart'; // Added import for DateUtils
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:uuid/uuid.dart'; // For generating IDs (though Firestore can do this)

// Core Imports
import 'package:employeemanagment/core/models/time_entry_model.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart'; // For formatting durations/dates

part 'presence_providers.g.dart'; // For Riverpod Generator

// --- Time Entry Stream for Current User ---
/// Provides a stream of time entries for the current user within a specified date range.
@riverpod
Stream<List<TimeEntryModel>> timeEntriesForPeriod(TimeEntriesForPeriodRef ref, DateTime startDate, DateTime endDate) {
  final currentUser = ref.watch(currentUserDataProvider);
  final service = ref.watch(firestoreServiceProvider);
  if (currentUser != null) {
    // Fetch entries using the service method for the given user and period.
    return service.getTimeEntriesStream(currentUser.uid, startDate, endDate);
  }
  // Return an empty stream if no user is logged in.
  return Stream.value([]);
}

// --- Last Time Entry Stream for Current User ---
/// Provides a stream of the single most recent time entry for the current user.
/// Useful for determining current clock-in/out/break status.
@riverpod
Stream<TimeEntryModel?> lastTimeEntry(LastTimeEntryRef ref) {
   final currentUser = ref.watch(currentUserDataProvider);
   final service = ref.watch(firestoreServiceProvider);
    if (currentUser != null) {
      // Fetch the last entry using the service method.
      return service.getLastTimeEntryStream(currentUser.uid);
    }
   // Return a stream with null if no user is logged in.
   return Stream.value(null);
}

// --- Clock In/Out Controller ---
/// Manages the logic and state for clocking actions (in, out, break start/end).
@riverpod
class ClockController extends _$ClockController {
  @override
  FutureOr<void> build() {
    // No initial state needed for this action controller.
    return null;
  }

  /// Determines the next logical clocking action based on the last recorded entry.
  TimeEntryType getNextAction(TimeEntryModel? lastEntry) {
     // If no previous entry or last action was clocking out, next action is clock in.
     if (lastEntry == null || lastEntry.type == TimeEntryType.clockOut) {
       return TimeEntryType.clockIn;
     }
     // If clocked in or just ended a break, next logical action is clock out.
     // Simple workflow: doesn't allow starting break immediately after ending one.
     else if (lastEntry.type == TimeEntryType.clockIn || lastEntry.type == TimeEntryType.endBreak) {
       // TODO: Optionally add logic here to allow starting a break instead of only clocking out.
       // For example, return a different state or provide multiple action buttons in UI.
        return TimeEntryType.clockOut;
     }
     // If currently on break, next action is to end the break.
     else if (lastEntry.type == TimeEntryType.startBreak) {
        return TimeEntryType.endBreak;
     }
     // Default fallback case (should ideally not be reached with above logic).
     return TimeEntryType.clockIn;
  }

   /// Executes the specified clocking action (Clock In/Out, Break Start/End).
   Future<bool> performClockAction(TimeEntryType actionType, {String? note}) async {
     state = const AsyncLoading(); // Set loading state.
     final currentUser = ref.read(currentUserDataProvider);
     final service = ref.read(firestoreServiceProvider);

      // Ensure a user is logged in.
      if (currentUser == null) {
        state = AsyncError("Utilisateur non connecté.", StackTrace.current);
        return false;
      }

      // --- Optional: Location Capture ---
      // TODO: Integrate geolocator package and handle permissions if GPS clock-in is needed.
      String? locationData;
      // try {
      //   Position position = await Geolocator.getCurrentPosition(...);
      //   locationData = "${position.latitude}, ${position.longitude}";
      // } catch (e) { print("Location error: $e"); /* Handle error */ }
      // --- End Location Capture ---

     // Create the new time entry model.
     final newEntry = TimeEntryModel(
        id: '', // Firestore generates ID.
        userId: currentUser.uid,
        timestamp: Timestamp.now(), // Record current time.
        type: actionType,
        note: note, // Include optional note.
        location: locationData, // Include optional location.
     );

     try {
       // Add the entry to Firestore.
       await service.addTimeEntry(newEntry);
       // Invalidate providers to ensure UI updates immediately.
       ref.invalidate(lastTimeEntryProvider); // Update the clock status display.
       // Invalidate the timesheet period if the current action falls within its range
       // (e.g., invalidate today's timesheet data). This requires more complex logic
       // to determine the correct period to invalidate based on the action time.
       // ref.invalidate(processedTimesheetProvider(...));
       state = const AsyncData(null); // Set success state.
       return true;
     } catch (e, stack) {
       state = AsyncError("Erreur lors du pointage: $e", stack);
       return false;
     }
   }
}

// --- Timesheet Data Provider (Calculates durations) ---
/// Processes raw time entries for a given period to calculate work/break durations per day.
/// Returns a Future containing the list of processed daily entries.
@riverpod
Future<List<ProcessedDayEntry>> processedTimesheet(ProcessedTimesheetRef ref, DateTime startDate, DateTime endDate) async {
    // Watch the provider that fetches raw entries for the period.
    final entriesAsync = ref.watch(timeEntriesForPeriodProvider(startDate, endDate));

    // Use .when to handle the async states of the raw entries.
    return entriesAsync.when(
      data: (entries) {
         // --- Process Entries ---
         // Group entries by calendar day using DateUtils.dateOnly.
        Map<DateTime, List<TimeEntryModel>> entriesByDay = {};
        for (var entry in entries) {
            // Use DateUtils.dateOnly to get the date part without time.
            final day = DateUtils.dateOnly(entry.timestamp.toDate());
            // Add entry to the list for that day.
            (entriesByDay[day] ??= []).add(entry);
        }

         // Process each day's entries.
         List<ProcessedDayEntry> processedDays = [];
         entriesByDay.forEach((day, dayEntries) {
            // Sort entries chronologically within the day for correct calculation.
            dayEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            Duration totalWorkDuration = Duration.zero;
            Duration totalBreakDuration = Duration.zero;
            Timestamp? dayClockIn; // First clock-in of the day
            Timestamp? dayClockOut; // Last clock-out of the day
            List<TimeInterval> workIntervals = []; // List to store calculated intervals
            TimeEntryModel? lastClockInOrBreakEnd; // Track start of work/break periods

            // Iterate through the sorted entries for the day.
            for (int i = 0; i < dayEntries.length; i++) {
              final current = dayEntries[i];

               // Track overall day clock in/out times.
               if(current.type == TimeEntryType.clockIn && dayClockIn == null){
                 dayClockIn = current.timestamp; // Record first clock-in
               }
               if(current.type == TimeEntryType.clockOut){
                 dayClockOut = current.timestamp; // Update with latest clock-out
               }

               // --- Calculate Work Durations ---
              // If user clocks in or ends a break, mark the start of a potential work period.
              if (current.type == TimeEntryType.clockIn || current.type == TimeEntryType.endBreak) {
                 lastClockInOrBreakEnd = current;
              }
              // If user clocks out or starts a break AND we have a start marker...
              else if ((current.type == TimeEntryType.clockOut || current.type == TimeEntryType.startBreak) && lastClockInOrBreakEnd != null) {
                  // Calculate duration from the last clock-in/break-end to now.
                  final duration = current.timestamp.toDate().difference(lastClockInOrBreakEnd.timestamp.toDate());
                  if (duration > Duration.zero) {
                     totalWorkDuration += duration; // Add to total work time.
                     // Add this work segment as an interval.
                     workIntervals.add(TimeInterval(start: lastClockInOrBreakEnd.timestamp, end: current.timestamp, type: TimeEntryType.clockIn));
                  }
                  lastClockInOrBreakEnd = null; // Reset the marker.
              }

              // --- Calculate Break Durations ---
              // If user starts a break and there's a next entry...
               if (current.type == TimeEntryType.startBreak && i + 1 < dayEntries.length) {
                 final next = dayEntries[i+1];
                  // And the next entry is ending the break...
                  if (next.type == TimeEntryType.endBreak) {
                     // Calculate the break duration.
                     final duration = next.timestamp.toDate().difference(current.timestamp.toDate());
                      if (duration > Duration.zero) {
                        totalBreakDuration += duration; // Add to total break time.
                        // Add this break segment as an interval.
                        workIntervals.add(TimeInterval(start: current.timestamp, end: next.timestamp, type: TimeEntryType.startBreak));
                     }
                  }
               }
            } // End loop through day's entries

             // Sort intervals chronologically for display.
             workIntervals.sort((a, b) => a.start.compareTo(b.start));

            // Add the processed data for this day to the results list.
            processedDays.add(ProcessedDayEntry(
              date: day,
              clockInTime: dayClockIn,
              clockOutTime: dayClockOut,
              totalWorkDuration: totalWorkDuration,
              totalBreakDuration: totalBreakDuration,
              intervals: workIntervals,
              rawEntries: dayEntries, // Include raw entries for potential detailed view
            ));
         }); // End loop through days

         // Sort processed days, showing the most recent day first.
         processedDays.sort((a, b) => b.date.compareTo(a.date));
         return processedDays; // Return the list of processed daily entries.

      },
      // Return empty list while loading dependencies.
      loading: () => <ProcessedDayEntry>[],
      // Propagate error if fetching raw entries fails.
      error: (e, s) {
        print("Error processing timesheet: $e");
        // Rethrow or handle appropriately
        throw e;
      }
    );
}

// --- Helper classes for Processed Timesheet Data ---

/// Represents the summarized and processed time entries for a single day.
class ProcessedDayEntry {
  final DateTime date;
  final Timestamp? clockInTime; // First clock-in
  final Timestamp? clockOutTime; // Last clock-out
  final Duration totalWorkDuration;
  final Duration totalBreakDuration;
  final List<TimeInterval> intervals; // Calculated work/break intervals
  final List<TimeEntryModel> rawEntries; // Original entries for the day

  ProcessedDayEntry({
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.totalWorkDuration,
    required this.totalBreakDuration,
    required this.intervals,
    required this.rawEntries,
  });
}

/// Represents a continuous time interval (either work or break).
class TimeInterval {
   final Timestamp start;
   final Timestamp end;
   // Type indicates if it's a work (clockIn) or break (startBreak) interval.
   final TimeEntryType type;

  TimeInterval({required this.start, required this.end, required this.type});

  /// Calculates the duration of the interval.
  Duration get duration => end.toDate().difference(start.toDate());
}

// TODO: Add providers for Overtime management (fetching rules, calculating overtime based on ProcessedDayEntry).