import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/screens/quizlevel_configuration.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';

import '../widgets/header.dart';
import '../widgets/progress.dart';

class NewQuizSettings extends StatefulWidget {

  @override
  NewQuizSettingsState createState() => NewQuizSettingsState();
}

class NewQuizSettingsState extends State<NewQuizSettings>
    with SingleTickerProviderStateMixin {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  String quizId = '';
  final _quizNameTextEditingController = TextEditingController();
  final _quizPictureUrlTextEditingController = TextEditingController();
  bool _status = true;
  final _firestore = FirebaseFirestore.instance;
  bool isEditing = false;
  bool isUploadInProgress = false;
  String quizPictureUrl = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('Disposing NewQuizSettings');
    super.dispose();
    // Clean up the controller when the Widget is disposed
    _quizNameTextEditingController.dispose();
    _quizPictureUrlTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.interstitialAd != null) Constant.interstitialAd!.show();
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: header(context, titleText: 'CREATE QUIZ'),
          body: Container(
            decoration: Constant.backgroundDecoration,
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 10.0),
                                child: _status ? _getEditIcon() : Container(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Quiz Name',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          print('quiz name form field: $value');
                                          if (value == null || value.isEmpty) {
                                            return 'Please give your quiz a Name.';
                                          }
                                          return null;
                                        },
                                        onEditingComplete: () {
                                          Constant.quiz.quizName =
                                              _quizNameTextEditingController.text;
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        style: TextStyle(fontSize: 22),
                                        controller:
                                            _quizNameTextEditingController,
                                        decoration: Constant.getTextFormFieldInputDecoration('Give your quiz a name'),
                                        enabled: !_status,
                                        autofocus: !_status,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Quiz Picture Url',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        controller:
                                            _quizPictureUrlTextEditingController,
                                        onEditingComplete: () {
                                          setState((){
                                            quizPictureUrl =
                                                _quizPictureUrlTextEditingController
                                                    .text;
                                          });

                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: Constant.getTextFormFieldInputDecoration('Give your quiz a picture url.'),
                                        enabled: !_status,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl: quizPictureUrl.isNotEmpty ?
                                            quizPictureUrl : 'https://cdn.pixabay.com/photo/2021/02/02/23/09/quiz-5975814__340.png',
                                            // imageBuilder: (context, imageProvider) => Container(
                                            //   width: 150.0,
                                            //   height: 150.0,
                                            //   decoration: BoxDecoration(
                                            //     shape: BoxShape.rectangle,
                                            //     image: DecorationImage(
                                            //         image: imageProvider, fit: BoxFit.cover),
                                            //   ),
                                            // ),
                                            placeholder: (context, url) => circularProgress(color: Colors.white),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Number of levels:',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                        child: DropdownButtonFormField<String>(
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select number of levels for your Constant.quiz.';
                                        }
                                        return null;
                                      },
                                      dropdownColor: Constant.colorThree,
                                      items: <String>['1', '2', '3', '4', '5']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: _status
                                          ? null
                                          : (val) {
                                              Constant.quiz.quizLevels.clear();
                                              Constant.quiz.quizLevels =
                                                  List.generate(
                                                      int.parse(val ?? "1"),
                                                      (index) {
                                                return QuizLevel(
                                                    levelName: '',
                                                    totalQuestionsAttemptedForLevel:
                                                        0,
                                                    totalCorrectAnswersGivenForLevel:
                                                        0,
                                                    levelQuizQuestions: []);
                                              });
                                            },
                                    )),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Quiz Category:',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                        child: DropdownButtonFormField<String>(
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select a category for your Constant.quiz.';
                                            }
                                            return null;
                                          },
                                          dropdownColor: Constant.colorThree,
                                          items: Constant.quizCategories
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: _status
                                              ? null
                                              : (val) {
                                            Constant.quiz.quizCategory = val ?? 'Others';
                                          },
                                        )),
                                  ],
                                ),
                              ),
                              !_status ? _getActionButtons() : Container(),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                child: ElevatedButton(
                    child: Text("Save"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await onProfilePageSaveClicked().then((value){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      QuizLevelConfiguration(0)));
                        });
                      }
                    }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: ElevatedButton(
                child: Text("Cancel"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )),
                ),
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Constant.colorTwo,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  Future onProfilePageSaveClicked() async {
    await EasyLoading.show();

    if (Constant.quiz.quizId.isNotEmpty)
      await _firestore.collection('quiz').doc(Constant.quiz.quizId).delete();

    var id = Uuid().v1();
    Quiz quizToUpdate = Quiz(
        quizId: id,
        quizCategory: Constant.quiz.quizCategory,
        quizLevels: Constant.quiz.quizLevels,
        quizPassword: Constant.quiz.quizPassword,
        quizUsers: Constant.quiz.quizUsers,
        quizExpiryDateTime: Constant.quiz.quizExpiryDateTime,
        quizCreationDateTime: DateTime.now().toUtc(),
        quizCreatedByUserId: currentUser!.id,
        quizCreatedByUsername: currentUser!.username,
        quizName: _quizNameTextEditingController.text,
        quizNumber:1,
        quizPictureUrl: _quizPictureUrlTextEditingController.text,
        quizDescription: Constant.quiz.quizDescription,
        isQuiz: true,
        isCooking: true);

    try{
      await _firestore
          .collection('quiz')
          .doc(id)
          .set(quizToUpdate.toJson(), SetOptions(merge: true));
    }catch(e){
          print(e);
    }


    Constant.quiz = quizToUpdate;

    setState(() {
      _status = true;
      FocusScope.of(context).requestFocus(FocusNode());
    });
    await EasyLoading.dismiss();
  }
}
