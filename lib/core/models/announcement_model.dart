import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName; // Denormalized for easy display
  final Timestamp createdAt;
  final bool isPinned;
  final List<String>? targetRoles; // Optional: ['admin', 'rh'] or null for all

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.isPinned = false,
    this.targetRoles,
  });

   factory AnnouncementModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
     if (data == null) throw Exception("Announcement data is null!");

    // Handle potential List<dynamic> from Firestore
    List<String>? roles;
    if (data['targetRoles'] != null && data['targetRoles'] is List) {
      roles = List<String>.from(data['targetRoles']);
    }

    return AnnouncementModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Inconnu',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isPinned: data['isPinned'] ?? false,
      targetRoles: roles,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'isPinned': isPinned,
      if (targetRoles != null) 'targetRoles': targetRoles,
    };
  }
}