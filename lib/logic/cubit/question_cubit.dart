import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:flutter_quiz_app/logic/cubit/question_state.dart';

class QuestionCubit extends Cubit<QuestionState> {
  QuestionCubit() : super(NotAnsweredYet());

  void onQuestionAnswered(int quizLevel, int questionNumber, int selectedOptionIndex) {
    if (Constant.quizLevelCollection!.quizLevels[quizLevel].levelQuizQuestions[questionNumber-1].correctAnswerOption ==
        selectedOptionIndex)
      emit(AnsweredCorrectly(quizLevel, questionNumber, selectedOptionIndex));
    else if (Constant.quizLevelCollection!.quizLevels[quizLevel].levelQuizQuestions[questionNumber-1].correctAnswerOption !=
        selectedOptionIndex)
      emit(AnsweredInCorrectly(quizLevel, questionNumber, selectedOptionIndex));
    else
      emit(NotAnsweredYet());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
