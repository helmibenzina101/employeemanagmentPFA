import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/models/time_entry_model.dart';
import 'package:employeemanagment/core/models/leave_request_model.dart';
import 'package:employeemanagment/core/models/announcement_model.dart';
import 'package:employeemanagment/core/models/performance_review_model.dart';
import 'package:employeemanagment/core/models/document_metadata_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;
  FirestoreService(this._db);

  CollectionReference<T> _collection<T>(String path, T Function(DocumentSnapshot<Map<String, dynamic>>, SnapshotOptions?) fromFirestore, Map<String, Object?> Function(T, SetOptions?) toFirestore) {
    return _db.collection(path).withConverter<T>(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  // --- User Operations ---
  CollectionReference<UserModel> get _usersCol => _collection(FirestoreCollections.users, UserModel.fromFirestore, (m,o) => m.toFirestore());
  Stream<DocumentSnapshot<UserModel>> getUserStream(String uid) => _usersCol.doc(uid).snapshots();
  Future<UserModel?> getUserData(String uid) async => (await _usersCol.doc(uid).get()).data();
  Future<void> setUserData(UserModel user) => _usersCol.doc(user.uid).set(user, SetOptions(merge: true));
  Future<void> updateUserPartial(String uid, Map<String, dynamic> data) => _usersCol.doc(uid).update(data);
  Stream<List<UserModel>> getAllActiveUsersStream() => _usersCol.where('isActive', isEqualTo: true).orderBy('nom').snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  Stream<List<UserModel>> getUsersByManagerIdStream(String managerId) => _usersCol.where('managerUid', isEqualTo: managerId).where('isActive', isEqualTo: true).orderBy('nom').snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  // *** ADD THIS METHOD for Pending Users ***
  /// Gets a stream of users based on their approval status, ordered by creation date.
  /// Requires a Firestore index on status (Asc) and dateEmbauche (Asc).
  Stream<List<UserModel>> getUsersByStatusStream(String status) {
     return _usersCol
        .where('status', isEqualTo: status)
        .orderBy('dateEmbauche', descending: false) // Show oldest pending first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
  // *** END ADD METHOD ***

  // --- Time Entry Operations ---
  CollectionReference<TimeEntryModel> get _timeEntriesCol => _collection(FirestoreCollections.timeEntries, TimeEntryModel.fromFirestore, (m,o) => m.toFirestore());
  Future<void> addTimeEntry(TimeEntryModel entry) => _timeEntriesCol.add(entry);
  Stream<List<TimeEntryModel>> getTimeEntriesStream(String userId, DateTime startDate, DateTime endDate) {
    Timestamp start = Timestamp.fromDate(startDate);
    Timestamp end = Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59));
    return _timeEntriesCol.where('userId', isEqualTo: userId).where('timestamp', isGreaterThanOrEqualTo: start).where('timestamp', isLessThanOrEqualTo: end).orderBy('timestamp', descending: true).snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }
  Stream<TimeEntryModel?> getLastTimeEntryStream(String userId) => _timeEntriesCol.where('userId', isEqualTo: userId).orderBy('timestamp', descending: true).limit(1).snapshots().map((s) => s.docs.isEmpty ? null : s.docs.first.data());

  // --- Leave Request Operations ---
  CollectionReference<LeaveRequestModel> get _leaveRequestsCol => _collection(FirestoreCollections.leaveRequests, LeaveRequestModel.fromFirestore, (m,o) => m.toFirestore());
  Future<void> addLeaveRequest(LeaveRequestModel request) => _leaveRequestsCol.add(request);
  Stream<List<LeaveRequestModel>> getLeaveRequestsStream(String userId) => _leaveRequestsCol.where('userId', isEqualTo: userId).orderBy('requestedAt', descending: true).snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  Stream<List<LeaveRequestModel>> getPendingLeaveRequestsStream() => _leaveRequestsCol.where('status', isEqualTo: LeaveStatus.pending.name).orderBy('requestedAt', descending: false).snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  Future<void> updateLeaveRequestStatus(String requestId, LeaveStatus status, String approverId, {String? rejectionReason}) {
    Map<String, dynamic> data = {'status': status.name, 'approverId': approverId};
    if (status == LeaveStatus.rejected && rejectionReason != null) data['rejectionReason'] = rejectionReason;
    return _leaveRequestsCol.doc(requestId).update(data);
  }
  Stream<List<LeaveRequestModel>> getAllLeaveRequestsStream() => _leaveRequestsCol.orderBy('requestedAt', descending: true).snapshots().map((s) => s.docs.map((d) => d.data()).toList());

  // --- Announcement Operations ---
  CollectionReference<AnnouncementModel> get _announcementsCol => _collection(FirestoreCollections.announcements, AnnouncementModel.fromFirestore, (m,o) => m.toFirestore());
  Future<void> addAnnouncement(AnnouncementModel announcement) => _announcementsCol.add(announcement);
  Stream<List<AnnouncementModel>> getAnnouncementsStream(UserModel? currentUser) {
    Query<AnnouncementModel> query = _announcementsCol.orderBy('isPinned', descending: true).orderBy('createdAt', descending: true);
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).where((ann) {
      if (currentUser == null) return ann.targetRoles == null;
      if (ann.targetRoles == null || ann.targetRoles!.isEmpty) return true;
      return ann.targetRoles!.contains(currentUser.role.name);
    }).toList());
  }
  Future<void> deleteAnnouncement(String announcementId) => _announcementsCol.doc(announcementId).delete();

  // --- Performance Review Operations ---
  CollectionReference<PerformanceReviewModel> get _performanceReviewsCol => _collection(FirestoreCollections.performanceReviews, PerformanceReviewModel.fromFirestore, (m,o) => m.toFirestore());
  Future<void> addPerformanceReview(PerformanceReviewModel review) => _performanceReviewsCol.add(review);
  Stream<List<PerformanceReviewModel>> getPerformanceReviewsForEmployeeStream(String employeeId) => _performanceReviewsCol.where('employeeUid', isEqualTo: employeeId).orderBy('reviewDate', descending: true).snapshots().map((s) => s.docs.map((d) => d.data()).toList());

  // --- Document Metadata Operations ---
  CollectionReference<DocumentMetadataModel> get _documentsCol => _collection(FirestoreCollections.documents, DocumentMetadataModel.fromFirestore, (m,o) => m.toFirestore());
  Future<void> addDocumentMetadata(DocumentMetadataModel metadata) => _documentsCol.add(metadata);
  Stream<List<DocumentMetadataModel>> getDocumentsForUserStream(String userId) => _documentsCol.where('userId', isEqualTo: userId).orderBy('uploadDate', descending: true).snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  Future<void> deleteDocumentMetadata(String docId) => _documentsCol.doc(docId).delete();
}