import 'package:bloc/bloc.dart';

abstract class QuestionState{}

class NotAnsweredYet extends QuestionState {
}

class AnsweredCorrectly extends QuestionState {
  int quizLevel;
  int questionNumber;
  int selectedOptionIndex;
  AnsweredCorrectly(this.quizLevel, this.questionNumber, this.selectedOptionIndex);
}

class AnsweredInCorrectly extends QuestionState {
  int quizLevel;
  int questionNumber;
  int selectedOptionIndex;
  AnsweredInCorrectly(this.quizLevel, this.questionNumber, this.selectedOptionIndex);
}

