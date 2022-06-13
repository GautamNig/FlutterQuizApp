import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String email;
  String photoUrl;
  String displayName;
  String bio;
  Map quizScorePerVersion;
  Timestamp lastQuizTakenTime;
  Timestamp joiningDateTime;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.quizScorePerVersion,
    required this.lastQuizTakenTime,
    required this.joiningDateTime,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id']  ?? '',
      email: doc['email']  ?? '',
      username: doc['username']  ?? '',
      photoUrl: doc['photoUrl']  ?? '',
      displayName: doc['displayName']  ?? '',
      bio: doc['bio']  ?? '',
      quizScorePerVersion: doc['quizScorePerVersion'],
      lastQuizTakenTime: doc['lastQuizTakenTime'],
      joiningDateTime: doc['joiningDateTime'],
    );
  }
}
