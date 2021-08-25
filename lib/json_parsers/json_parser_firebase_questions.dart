// To parse this JSON data, do
//
//     final quizLevelCollection = quizLevelCollectionFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

QuizLevelCollection quizLevelCollectionFromJson(String str) => QuizLevelCollection.fromJson(json.decode(str));

String quizLevelCollectionToJson(QuizLevelCollection data) => json.encode(data.toJson());

class QuizLevelCollection {
  QuizLevelCollection({
    required this.quizLevels,
  });

  List<QuizLevel> quizLevels;

  factory QuizLevelCollection.fromJson(Map<String, dynamic> json) => QuizLevelCollection(
    quizLevels: List<QuizLevel>.from(json["QuizLevels"].map((x) => QuizLevel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "QuizLevels": List<dynamic>.from(quizLevels.map((x) => x.toJson())),
  };
}

class QuizLevel {
  QuizLevel({
    required this.levelNumber,
    required this.levelQuizQuestions,
  });

  String levelNumber;
  List<LevelQuizQuestion> levelQuizQuestions;

  factory QuizLevel.fromJson(Map<String, dynamic> json) => QuizLevel(
    levelNumber: json["LevelNumber"],
    levelQuizQuestions: List<LevelQuizQuestion>.from(json["LevelQuizQuestions"].map((x) => LevelQuizQuestion.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "LevelNumber": levelNumber,
    "LevelQuizQuestions": List<dynamic>.from(levelQuizQuestions.map((x) => x.toJson())),
  };
}

class LevelQuizQuestion {
  LevelQuizQuestion({
    required this.questionText,
    required this.correctAnswerOption,
    required this.answerOptions,
  });

  String questionText;
  int correctAnswerOption;
  List<AnswerOption> answerOptions;

  factory LevelQuizQuestion.fromJson(Map<String, dynamic> json) => LevelQuizQuestion(
    questionText: json["QuestionText"],
    correctAnswerOption: json["CorrectAnswerOption"],
    answerOptions: List<AnswerOption>.from(json["AnswerOptions"].map((x) => AnswerOption.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "QuestionText": questionText,
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
