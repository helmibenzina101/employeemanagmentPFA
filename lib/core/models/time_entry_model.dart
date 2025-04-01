import 'package:cloud_firestore/cloud_firestore.dart';

enum TimeEntryType { clockIn, clockOut, startBreak, endBreak }

class TimeEntryModel {
  final String id;
  final String userId;
  final Timestamp timestamp;
  final TimeEntryType type;
  final String? location; // Optional: GPS coordinates or place name
  final String? note; // Optional note

  TimeEntryModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    this.location,
    this.note,
  });

  factory TimeEntryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
     if (data == null) throw Exception("Time entry data is null!");

    return TimeEntryModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      type: _typeFromString(data['type']),
      location: data['location'],
      note: data['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timestamp': timestamp,
      'type': _typeToString(type),
      if (location != null) 'location': location,
      if (note != null) 'note': note,
    };
  }

  static TimeEntryType _typeFromString(String? typeStr) {
    switch(typeStr) {
      case 'clockIn': return TimeEntryType.clockIn;
      case 'clockOut': return TimeEntryType.clockOut;
      case 'startBreak': return TimeEntryType.startBreak;
      case 'endBreak': return TimeEntryType.endBreak;
      default: return TimeEntryType.clockIn; // Default or throw error
    }
  }

   static String _typeToString(TimeEntryType type) {
    return type.name;
  }

  // Calculated properties
  Duration calculateDuration(TimeEntryModel? nextEntry) {
    if (type == TimeEntryType.clockIn && nextEntry?.type == TimeEntryType.clockOut) {
      return nextEntry!.timestamp.toDate().difference(timestamp.toDate());
    }
    if (type == TimeEntryType.startBreak && nextEntry?.type == TimeEntryType.endBreak) {
       return nextEntry!.timestamp.toDate().difference(timestamp.toDate());
    }
    // Add other duration calculations if needed
    return Duration.zero;
  }

}