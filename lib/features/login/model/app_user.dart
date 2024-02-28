import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  // Avoid naming conflict with FirebaseAuth's User
  final String id;
  final String displayName;
  final String email;
  final String uid;
  final String photoUrl;
  final Timestamp createdTime;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.createdTime,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      id: doc.id,
      displayName: data['display_name'] ?? 'Unknown',
      email: data['email'] ?? '',
      uid: data['uid'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      createdTime: data['created_time'] ?? '',
    );
  }
}
