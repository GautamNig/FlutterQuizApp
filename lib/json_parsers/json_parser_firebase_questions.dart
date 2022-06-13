// To parse this JSON data, do
//
//     final quiz = quizFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'json_parser_firebase_user.dart';

Quiz quizFromJson(String str) => Quiz.fromJson(json.decode(str));

String quizToJson(Quiz data) => json.encode(data.toJson());

class Quiz {
  Quiz({
    required this.quizId,
    required this.quizCategory,
    required this.quizName,
    required this.quizNumber,
    required this.quizDescription,
    required this.isQuiz,
    required this.quizPictureUrl,
    required this.quizLevels,
    required this.quizUsers,
    required this.quizCreatedByUserId,
    required this.quizCreatedByUsername,
    required this.quizPassword,
    required this.quizCreationDateTime,
    required this.quizExpiryDateTime,
    required this.isCooking
  });

  String quizId;
  String quizCategory;
  String quizName;
  num quizNumber;
  String quizDescription;
  bool isQuiz;
  String quizPictureUrl;
  List<QuizLevel> quizLevels;
  List<String> quizUsers;
  String quizCreatedByUserId;
  String quizCreatedByUsername;
  String quizPassword;
  DateTime quizCreationDateTime;
  DateTime quizExpiryDateTime;
  bool isCooking;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    if(json.keys.length == 0)
      return Quiz(quizId: "0", quizCategory:'', quizName: 'DefaultEmptyQuiz', quizDescription: "DefaultEmptyQuiz", isQuiz: true, quizPictureUrl: '',
          quizCreatedByUserId: '', quizCreatedByUsername: '', quizCreationDateTime: DateTime.now().toUtc(),
          quizNumber: 1,
          quizExpiryDateTime: DateTime.now().toUtc(),quizPassword: '', quizLevels: [], quizUsers: [], isCooking: false);
    return Quiz(
      quizId: json["QuizId"],
      quizCategory: json["QuizCategory"],
      quizName: json["QuizName"],
      quizDescription: json["QuizDescription"],
      quizNumber: json["QuizNumber"],
      isQuiz: json["IsQuiz"],
      quizPictureUrl: json["QuizPictureUrl"],
      quizLevels: List<QuizLevel>.from(json["QuizLevels"].map((x) => QuizLevel.fromJson(x))),
      quizUsers: List<String>.from(json["QuizUsers"].map((x) => x)),
      quizCreatedByUserId: json["QuizCreatedByUserId"],
      quizCreatedByUsername: json["QuizCreatedByUsername"],
      quizPassword: json["QuizPassword"],
      quizCreationDateTime: (json["QuizCreationDateTime"]  as Timestamp).toDate(),
      quizExpiryDateTime: (json["QuizExpiryDateTime"]  as Timestamp).toDate(),
      isCooking: json["IsCooking"],
    );}

  Map<String, dynamic> toJson() => {
    "QuizId": quizId,
    "QuizCategory": quizCategory,
    "QuizName": quizName,
    "QuizDescription": quizDescription,
    "QuizNumber": quizNumber,
    "IsQuiz": isQuiz,
    "QuizPictureUrl": quizPictureUrl,
    "QuizLevels": List<dynamic>.from(quizLevels.map((x) => x.toJson())),
    "QuizUsers": List<dynamic>.from(quizUsers.map((x) => x)),
    "QuizCreatedByUserId": quizCreatedByUserId,
    "QuizCreatedByUsername": quizCreatedByUsername,
    "QuizPassword": quizPassword,
    "QuizCreationDateTime": Timestamp.fromDate(quizCreationDateTime),
    "QuizExpiryDateTime": Timestamp.fromDate(quizExpiryDateTime),
    "IsCooking": isCooking,
  };
}

class QuizLevel {
  QuizLevel({
    required this.levelName,
    required this.totalQuestionsAttemptedForLevel,
    required this.totalCorrectAnswersGivenForLevel,
    required this.levelQuizQuestions,
  });

  String levelName;
  int totalQuestionsAttemptedForLevel;
  int totalCorrectAnswersGivenForLevel;
  List<LevelQuizQuestion> levelQuizQuestions;

  factory QuizLevel.fromJson(Map<String, dynamic> json) => QuizLevel(
    levelName: json["LevelName"],
    totalQuestionsAttemptedForLevel: json["TotalQuestionsAttemptedForLevel"],
    totalCorrectAnswersGivenForLevel: json["TotalCorrectAnswersGivenForLevel"],
    levelQuizQuestions: List<LevelQuizQuestion>.from(json["LevelQuizQuestions"].map((x) => LevelQuizQuestion.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "LevelName": levelName,
    "TotalQuestionsAttemptedForLevel": totalQuestionsAttemptedForLevel,
    "TotalCorrectAnswersGivenForLevel": totalCorrectAnswersGivenForLevel,
    "LevelQuizQuestions": List<dynamic>.from(levelQuizQuestions.map((x) => x.toJson())),
  };
}

class LevelQuizQuestion {
  LevelQuizQuestion({
    required this.questionText,
    required this.questionGiphyOrImageUrl,
    required this.correctAnswerOption,
    required this.answerOptions,
  });

  String questionText;
  String questionGiphyOrImageUrl;
  int correctAnswerOption;
  List<AnswerOption> answerOptions;

  factory LevelQuizQuestion.fromJson(Map<String, dynamic> json) => LevelQuizQuestion(
    questionText: json["QuestionText"],
    questionGiphyOrImageUrl: json["QuestionGiphyOrImageUrl"] ?? '',
    correctAnswerOption: json["CorrectAnswerOption"],
    answerOptions: List<AnswerOption>.from(json["AnswerOptions"].map((x) => AnswerOption.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "QuestionText": questionText,
    "QuestionGiphyOrImageUrl": questionGiphyOrImageUrl,
    "CorrectAnswerOption": correctAnswerOption,
    "AnswerOptions": List<dynamic>.from(answerOptions.map((x) => x.toJson())),
  };
}

class AnswerOption {
  AnswerOption({
    required this.optionText,
    required this.optionNumber,
  });

  String optionText;
  int optionNumber;

  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
    optionText: json["OptionText"],
    optionNumber: json["OptionNumber"],
  );

  Map<String, dynamic> toJson() => {
    "OptionText": optionText,
    "OptionNumber": optionNumber,
  };
}
