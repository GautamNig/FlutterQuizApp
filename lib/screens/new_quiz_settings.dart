import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_kitchen/helpers/Constants.dart';
import 'package:quiz_kitchen/json_parsers/json_parser_firebase_quiz.dart';
import 'package:quiz_kitchen/screens/quizlevel_configuration.dart';
import 'package:uuid/uuid.dart';

class NewQuizSettings extends StatefulWidget {
  final bool isQuiz;
  NewQuizSettings({required this.isQuiz});

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
  final _quizDescriptionTextEditingController = TextEditingController();
  final _quizPasswordTextEditingController = TextEditingController();
  bool _status = true;
  File _image = File('');
  final picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;
  bool isImageUpdated = false;
  String imageDownloadUrl = '';
  String _previousImage = '';
  bool isEditing = false;
  bool isUploadInProgress = false;
  String quizName = '';
  String aboutQuiz = '';
  String quizPassword = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _quizNameTextEditingController.text = Constant.quiz.quizName;
    _quizDescriptionTextEditingController.text = Constant.quiz.quizDescription;
    _quizPasswordTextEditingController.text = Constant.quiz.quizPassword;

    quizName = Constant.quiz.quizName;
    aboutQuiz = Constant.quiz.quizDescription;
    quizPassword = Constant.quiz.quizPassword;
  }

  @override
  void dispose() {
    print('Disposing NewQuizSettings');
    super.dispose();
    // Clean up the controller when the Widget is disposed
    _quizNameTextEditingController.dispose();
    _quizDescriptionTextEditingController.dispose();
    _quizPasswordTextEditingController.dispose();

    Constant.quiz = Constant.newQuiz;
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.interstitialAd != null) Constant.interstitialAd!.show();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constant.appBarColor,
          actions: [

          ],
          title: Text(
            Constant.quiz.quizName,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ),
        body: Container(
          decoration: Constant.backgroundDecoration,
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 250.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text('CREATE A QUIZ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        fontFamily: 'sans-serif-light',
                                        color: Colors.white)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Stack(fit: StackFit.loose, children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 180.0,
                                  height: 180.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: _image.path.isEmpty
                                        ? (Constant
                                                .quiz.quizPictureUrl.isNotEmpty
                                            ? DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        Constant.quiz
                                                            .quizPictureUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: AssetImage(
                                                    Constant.defaultQuizPic),
                                                fit: BoxFit.cover,
                                              ))
                                        : DecorationImage(
                                            image: FileImage(_image),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 120.0, left: 100.0),
                                child: InkWell(
                                  onTap: () async {
                                    await pickImage();
                                    setState(() {
                                      _status = false;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Constant.appBarColor,
                                    radius: 25.0,
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
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
                                    'Quiz Description',
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
                                          _quizDescriptionTextEditingController,
                                      onEditingComplete: () {
                                        Constant.quiz.quizDescription =
                                            _quizDescriptionTextEditingController
                                                .text;
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: Constant.getTextFormFieldInputDecoration('Give your quiz a description.'),
                                      enabled: !_status,
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
                                    'Quiz Password',
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
                                      obscureText: true,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      controller:
                                          _quizPasswordTextEditingController,
                                      onEditingComplete: () {
                                        Constant.quiz.quizPassword =
                                            _quizPasswordTextEditingController
                                                .text;
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      decoration: Constant.getTextFormFieldInputDecoration('Make your quiz private?'),
                                      enabled: !_status,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //       left: 25.0, right: 25.0, top: 25.0),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.max,
                            //     children: <Widget>[
                            //       Expanded(
                            //         child: Text(
                            //           'Is Quiz? (switching off will turn quiz to a poll)',
                            //           style: TextStyle(
                            //               fontSize: 16.0,
                            //               fontWeight: FontWeight.bold),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //       left: 25.0, right: 25.0, top: 2.0),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.max,
                            //     children: <Widget>[
                            //       Flexible(
                            //         child: Switch(
                            //           value: Constant.quiz.isQuiz,
                            //           onChanged: (value) {
                            //             setState(() {
                            //               Constant.quiz.isQuiz = value;
                            //               print(Constant.quiz.isQuiz);
                            //             });
                            //           },
                            //           activeTrackColor: Colors.yellow,
                            //           activeColor: Colors.orangeAccent,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
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
                                        return 'Please select number of levels for your quiz.';
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
                                            return 'Please select a category for your quiz.';
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
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //       left: 25.0, right: 25.0, top: 25.0),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.max,
                            //     children: <Widget>[
                            //       Text(
                            //         'Quiz expires in(hours):',
                            //         style: TextStyle(
                            //             fontSize: 16.0,
                            //             fontWeight: FontWeight.bold),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //       left: 25.0, right: 25.0, top: 2.0),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.max,
                            //     children: <Widget>[
                            //       Flexible(
                            //           child: DropdownButtonFormField<String>(
                            //         // The validator receives the text that the user has entered.
                            //         // validator: (value) {
                            //         //   if (value == null || value.isEmpty) {
                            //         //     return 'Please select in how many hours your quiz should expire.';
                            //         //   }
                            //         //   return null;
                            //         // },
                            //         dropdownColor: Constant.colorThree,
                            //         items: <String>[
                            //           '2',
                            //           '4',
                            //           '8',
                            //           '12',
                            //           '16',
                            //           '20',
                            //           '24',
                            //           '32',
                            //           '36',
                            //           '40',
                            //           '44',
                            //           '52',
                            //           '60',
                            //           '68',
                            //           '72'
                            //         ].map((String value) {
                            //           return DropdownMenuItem<String>(
                            //             value: value,
                            //             child: Text(value),
                            //           );
                            //         }).toList(),
                            //         onChanged: _status
                            //             ? null
                            //             : (val) {
                            //                 Constant.quiz.quizExpiryDateTime =
                            //                     DateTime.now().add(Duration(
                            //                         hours:
                            //                             int.parse(val ?? "2")));
                            //               },
                            //       )),
                            //     ],
                            //   ),
                            // ),
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
        ));
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
                        await onProfilePageSaveClicked();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    QuizLevelConfiguration(0)));
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
                    Constant.quiz.quizName = quizName;
                    Constant.quiz.quizDescription = aboutQuiz;

                    _quizNameTextEditingController.text = quizName;
                    _quizDescriptionTextEditingController.text = aboutQuiz;
                    _quizPasswordTextEditingController.text = aboutQuiz;
                    if (_image.path.isNotEmpty) _image = File('');
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
        backgroundColor: Constant.appBarColor,
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

  Future pickImage() async {
    //Get the file from the image picker and store it
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        isImageUpdated = true;
        _previousImage = Constant.quiz.quizPictureUrl.isNotEmpty
            ? Constant.quiz.quizPictureUrl
            : '';
      }
    });
  }

  Future uploadPic() async {
    try {
      await FirebaseStorage.instance
          .ref('quiz_images')
          .child(Uuid().v1())
          .putFile(_image)
          .then((value) async {
        imageDownloadUrl = await value.ref.getDownloadURL();
      });
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future updateQuizInfo(bool newImage) async {
    Constant.quiz.quizId = Uuid().v1();
    Quiz quizToUpdate = Quiz(
        quizId: Constant.quiz.quizId,
        quizCategory: Constant.quiz.quizCategory,
        quizLevels: Constant.quiz.quizLevels,
        quizPassword: Constant.quiz.quizPassword,
        quizUsers: Constant.quiz.quizUsers,
        quizExpiryDateTime: Constant.quiz.quizExpiryDateTime,
        quizCreationDateTime: DateTime.now().toUtc(),
        quizCreatedByUserId: Constant.userProfileData.id,
        quizName: _quizNameTextEditingController.text,
        quizVersion: Constant.quiz.quizVersion,
        quizPictureUrl:
            newImage ? imageDownloadUrl : Constant.quiz.quizPictureUrl,
        quizDescription: _quizDescriptionTextEditingController.text,
        isQuiz: widget.isQuiz,
        isCooking: true);
    await _firestore
        .collection('quiz')
        .doc(Constant.quiz.quizId)
        .set(quizToUpdate.toJson(), SetOptions(merge: true));

    Constant.quiz = quizToUpdate;
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  Future onProfilePageSaveClicked() async {
    await EasyLoading.show();

    if (Constant.quiz.quizId.isNotEmpty)
      await _firestore.collection('quiz').doc(Constant.quiz.quizId).delete();

    if (isImageUpdated) {
      await uploadPic().then((value) async {
        while (imageDownloadUrl.isEmpty) {
          await Future.delayed(Duration(milliseconds: 300));
        }
        await updateQuizInfo(true);
        isImageUpdated = false;
        if (_previousImage.isNotEmpty)
          await FirebaseStorage.instance.refFromURL(_previousImage).delete();
        if (Constant.quiz.quizPictureUrl.isNotEmpty)
          cacheImage(context, Constant.quiz.quizPictureUrl);
        _previousImage = '';
      });
    } else
      await updateQuizInfo(false);

    setState(() {
      _status = true;
      FocusScope.of(context).requestFocus(FocusNode());
    });
    await EasyLoading.dismiss();
  }
}
