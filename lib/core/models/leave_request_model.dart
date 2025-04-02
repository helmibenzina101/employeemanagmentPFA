import 'package:flutter/material.dart'; // Import material for Color
import 'package:cloud_firestore/cloud_firestore.dart';

// Define enums for Leave Status and Type
enum LeaveStatus { pending, approved, rejected, cancelled }
enum LeaveType { paid, unpaid, sick, special }

class LeaveRequestModel {
  final String id;
  final String userId;
  final String userName; // Denormalized for easy display
  final LeaveType type;
  final Timestamp startDate;
  final Timestamp endDate;
  final double days; // Number of days requested
  final String reason;
  final LeaveStatus status;
  final String? approverId; // User ID of HR/Admin who actioned
  final String? rejectionReason;
  final Timestamp requestedAt;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.approverId,
    this.rejectionReason,
    required this.requestedAt,
  });

  // --- Factory Constructor from Firestore ---
   // --- Factory Constructor from Firestore ---
     factory LeaveRequestModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
       final data = snapshot.data();
       if (data == null) throw Exception("Leave request data is null for ID: ${snapshot.id}");
   
       return LeaveRequestModel(
         id: snapshot.id,
// NEW Line 44:
userId: data['userId']?.toString() ?? '',         userName: data['userName'] ?? 'Utilisateur Inconnu',
         type: _typeFromString(data['type']), // Use the improved method that handles both int and string
         startDate: data['startDate'] ?? Timestamp.now(),
         endDate: data['endDate'] ?? Timestamp.now(),
         // Ensure 'days' is parsed correctly as double
         days: (data['days'] is int) 
             ? (data['days'] as int).toDouble() 
             : ((data['days'] is double) ? (data['days'] as double) : 0.0),
reason: data['reason']?.toString() ?? '',         status: _statusFromString(data['status']),
         approverId: data['approverId'],
         rejectionReason: data['rejectionReason'],
         requestedAt: data['requestedAt'] ?? Timestamp.now(),
       );
     }

  // --- Method to convert to Firestore Map ---
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'type': _typeToString(type), // Convert enum to string
      'startDate': startDate,
      'endDate': endDate,
      'days': days,
      'reason': reason,
      'status': _statusToString(status), // Convert enum to string
      if (approverId != null) 'approverId': approverId,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'requestedAt': requestedAt,
    };
  }

  // --- Private Enum Parsing Helpers ---
   static LeaveType _typeFromString(dynamic typeValue) {
     // Handle integer type values
     if (typeValue is int) {
       return typeValue >= 0 && typeValue < LeaveType.values.length 
           ? LeaveType.values[typeValue] 
           : LeaveType.paid;
     }
     
     // Handle string type values
     switch(typeValue?.toString().toLowerCase()) {
       case 'paid': return LeaveType.paid;
       case 'unpaid': return LeaveType.unpaid;
       case 'sick': return LeaveType.sick;
       case 'special': return LeaveType.special;
       default: return LeaveType.paid; // Sensible default
     }
   }

   static String _typeToString(LeaveType type) => type.name; // Use built-in enum name

   static LeaveStatus _statusFromString(dynamic statusValue) {
     // Handle integer type values
     if (statusValue is int) {
       return statusValue >= 0 && statusValue < LeaveStatus.values.length 
           ? LeaveStatus.values[statusValue] 
           : LeaveStatus.pending;
     }
     
     // Handle string type values
     switch(statusValue?.toString().toLowerCase()) {
       case 'pending': return LeaveStatus.pending;
       case 'approved': return LeaveStatus.approved;
       case 'rejected': return LeaveStatus.rejected;
       case 'cancelled': return LeaveStatus.cancelled;
       default: return LeaveStatus.pending; // Sensible default
     }
   }

   static String _statusToString(LeaveStatus status) => status.name; // Use built-in enum name

   // --- Static Helper Method for Display Names (as requested) ---
   /// Returns a user-friendly display string for a given LeaveType.
   static String getLeaveTypeDisplay(LeaveType type) {
     switch (type) {
       case LeaveType.paid: return 'Congé Payé';
       case LeaveType.unpaid: return 'Sans Solde';
       case LeaveType.sick: return 'Maladie';
       case LeaveType.special: return 'Événement Spécial';
     }
   }
   // --- End Static Helper Method ---


   // --- Instance Getter Helpers for Display ---
   /// Returns a user-friendly display string for the request's status.
   String get statusDisplay {
     switch (status) {
       case LeaveStatus.pending: return 'En attente';
       case LeaveStatus.approved: return 'Approuvée';
       case LeaveStatus.rejected: return 'Rejetée';
       case LeaveStatus.cancelled: return 'Annulée';
     }
   }

   /// Returns a user-friendly display string for the request's type.
   // Calls the static method for consistency.
    String get typeDisplay => getLeaveTypeDisplay(type);

   /// Returns a color associated with the request's status for UI highlighting.
     Color get statusColor {
      switch (status) {
        case LeaveStatus.pending: return Colors.orange.shade600;
        case LeaveStatus.approved: return Colors.green.shade600;
        case LeaveStatus.rejected: return Colors.red.shade600;
        case LeaveStatus.cancelled: return Colors.grey.shade600;
      }
    }
}

// Delete the duplicate factory constructor that was added at the bottom of the file