import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/screens/new_quiz.dart';
import 'package:flutter_quiz_app/widgets/header.dart';
import '../helpers/constant.dart';

class QuizLevelConfiguration extends StatefulWidget {
  final int quizLevel;

  QuizLevelConfiguration(this.quizLevel);

  @override
  _QuizLevelConfigurationState createState() => _QuizLevelConfigurationState();
}

class _QuizLevelConfigurationState extends State<QuizLevelConfiguration> {
  final _formKey = GlobalKey<FormState>();
  final _levelNameTextEditingController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('Disposing QuizLevelConfiguration');
    Constant.quiz.quizLevels.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.colorThree,
      appBar: header(context, titleText: 'Configure Quiz Level'),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Constant.colorOne,
              Constant.colorTwo
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please give your quiz level a Name.';
                  }
                  return null;
                },
                onEditingComplete: () {
                  Constant.quiz.quizLevels[widget.quizLevel].levelName =
                      _levelNameTextEditingController.text;
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                controller: _levelNameTextEditingController,
                decoration: Constant.getTextFormFieldInputDecoration('Give your quiz level a name'),
                textInputAction: TextInputAction.none,
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<String>(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select number of questions for the level.';
                  }
                  return null;
                },
                dropdownColor: Constant.colorThree,
                items: <String>['2', '3', '4', '5', '6', '7', '8', '9', '10']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  Constant.quiz.quizLevels[widget.quizLevel].levelQuizQuestions
                      .clear();
                  Constant.quiz.quizLevels[widget.quizLevel].levelQuizQuestions =
                      List.generate(int.parse(val ?? "2"), (index) {
                    return LevelQuizQuestion(
                        questionText: '',
                        questionGiphyOrImageUrl: '',
                        correctAnswerOption: 0,
                        answerOptions: [
                          AnswerOption(optionText: '', optionNumber: 0),
                          AnswerOption(optionText: '', optionNumber: 1),
                          AnswerOption(optionText: '', optionNumber: 2),
                          AnswerOption(optionText: '', optionNumber: 3),
                        ]);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Constant.quiz.quizLevels[widget.quizLevel].levelName =
                        _levelNameTextEditingController.text;

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewQuiz(Constant.quiz.quizId, widget.quizLevel, false)));
                  }
                },
                child: const Text('Configure Questions'),
                style: ElevatedButton.styleFrom(
                  primary: Constant.colorTwo,
                  side: const BorderSide(
                    width: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
