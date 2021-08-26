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
  });

  String username;
  DateTime joiningDate;
  String userId;
  String userDescription;

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json["Username"] != null ? json["Username"] : '',
    joiningDate: (json["JoiningDate"]  as Timestamp).toDate(),
    userId: json["UserId"] != null ? json["UserId"] : '',
    userDescription: json["UserDescription"] != null ? json["UserDescription"] : '',
  );

  Map<String, dynamic> toJson() => {
    "Username": username,
    "UserId": userId,
    "JoiningDate": Timestamp.fromDate(joiningDate),
    "UserDescription": userDescription,
  };
}