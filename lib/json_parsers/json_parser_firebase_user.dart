// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.username,
    required this.userId,
    required this.joiningDate,
    required this.userDescription,
    required this.userProfilePicUrl,
    required this.quizScore,
  });

  String username;
  DateTime joiningDate;
  String userId;
  String quizScore;
  String userDescription;
  String userProfilePicUrl;

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json["Username"] != null ? json["Username"] : '',
    joiningDate: (json["JoiningDate"]  as Timestamp).toDate(),
    userId: json["UserId"] != null ? json["UserId"] : '',
    quizScore: json["QuizScore"] != null ? json["QuizScore"] : '',
    userDescription: json["UserDescription"] != null ? json["UserDescription"] : '',
    userProfilePicUrl: json["UserProfilePicUrl"] != null ? json["UserProfilePicUrl"] : '',
  );

  Map<String, dynamic> toJson() => {
    "Username": username,
    "UserId": userId,
    "QuizScore": quizScore,
    "JoiningDate": Timestamp.fromDate(joiningDate),
    "UserDescription": userDescription,
    "UserProfilePicUrl": userProfilePicUrl,
  };
}