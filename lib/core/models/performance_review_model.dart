import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceReviewModel {
  final String id;
  final String employeeUid;
  final String employeeName; // Denormalized
  final String reviewerUid;
  final String reviewerName; // Denormalized
  final Timestamp reviewDate;
  final Timestamp periodStartDate;
  final Timestamp periodEndDate;
  final Map<String, int> ratings; // e.g., {'Communication': 4, 'Teamwork': 5}
  final String overallComments;
  final String employeeComments; // Employee self-reflection/comments
  final String goalsForNextPeriod;

  PerformanceReviewModel({
    required this.id,
    required this.employeeUid,
    required this.employeeName,
    required this.reviewerUid,
    required this.reviewerName,
    required this.reviewDate,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.ratings,
    required this.overallComments,
    required this.employeeComments,
    required this.goalsForNextPeriod,
  });

   factory PerformanceReviewModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
     if (data == null) throw Exception("Performance review data is null!");

    // Handle potential type issues for ratings map
    Map<String, int> safeRatings = {};
    if (data['ratings'] is Map) {
       try {
         // Ensure values are integers
         safeRatings = Map<String, int>.from(
            (data['ratings'] as Map).map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0))
         );
       } catch (e) {
         // Handle or log error if conversion fails
         print("Error converting ratings from Firestore: $e");
       }
    }


    return PerformanceReviewModel(
      id: snapshot.id,
      employeeUid: data['employeeUid'] ?? '',
      employeeName: data['employeeName'] ?? 'Employé Inconnu',
      reviewerUid: data['reviewerUid'] ?? '',
      reviewerName: data['reviewerName'] ?? 'Evaluateur Inconnu',
      reviewDate: data['reviewDate'] ?? Timestamp.now(),
      periodStartDate: data['periodStartDate'] ?? Timestamp.now(),
      periodEndDate: data['periodEndDate'] ?? Timestamp.now(),
      ratings: safeRatings,
      overallComments: data['overallComments'] ?? '',
      employeeComments: data['employeeComments'] ?? '',
      goalsForNextPeriod: data['goalsForNextPeriod'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeUid': employeeUid,
      'employeeName': employeeName,
      'reviewerUid': reviewerUid,
      'reviewerName': reviewerName,
      'reviewDate': reviewDate,
      'periodStartDate': periodStartDate,
      'periodEndDate': periodEndDate,
      'ratings': ratings, // Firestore handles Map<String, int>
      'overallComments': overallComments,
      'employeeComments': employeeComments,
      'goalsForNextPeriod': goalsForNextPeriod,
    };
  }
}