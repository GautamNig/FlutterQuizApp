import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/helpers/local_notification_service.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/logic/cubit/question_cubit.dart';
import 'package:flutter_quiz_app/logic/cubit/question_state.dart';
import 'package:flutter_quiz_app/screens/popup_overlay.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'leader_board_page.dart';
import 'dart:math' as math;

BannerAd? banner1;
BannerAd? banner2;
bool banner1IsLoaded = false;
bool banner2IsLoaded = false;

class QuizPage extends StatefulWidget {
  final Quiz quiz;

  QuizPage(this.quiz);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  int pageNumber = 1;
  List<int> answerIndexes = [];
  late Future<Quiz> getQuestions;
  String? token;
  int quizLevel = 0;
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String? localFilePath;
  String? localAudioCacheURI;

  var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      backgroundColor: Constant.colorTwo,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Constant.colorOne,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.white,
      ),
      constraints: BoxConstraints.expand(width: 300),
      //First to chars "55" represents transparency of color
      // overlayColor: Color(0x55000000),
      overlayColor: Colors.transparent,
      alertElevation: 0,
      alertAlignment: Alignment.center);

  @override
  void initState() {
    // TODO: implement initState
    Constant.quizLevelCollection = widget.quiz;
    Constant.loadAppAds();
    if (Platform.isIOS) {
      audioCache.fixedPlayer?.notificationService.startHeadlessService();
      advancedPlayer.notificationService.startHeadlessService();
    }
    LocalNotificationService.Initialize(context);

    // Gives you the message when app is closed.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print('message received');
      if (message != null) {
        final routeFromMessage = message.data["route"];
        print(routeFromMessage);
      }
    });

    // FOREGROUND WORK
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification!.title);
      print(event.notification!.body);

      LocalNotificationService.display(event);
    });

    // WHEN APP IS IN BACKGROUND AND USER TAPS ON THE NOTIFICATION
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      final routeFromMessage = event.data["route"];
      print(routeFromMessage);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page = getCurrentQuizPage();

    return MultiBlocProvider(
      providers: [
        BlocProvider<QuestionCubit>(create: (context) => QuestionCubit()),
      ],
      child: FlutterEasyLoading(
          child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  '${Constant.quizLevelCollection!.quizLevels[quizLevel].levelName}',
                  style: Constant.appHeaderTextSTyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            backgroundColor: Constant.colorTwo,
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: Constant.backgroundDecoration,
            child: Stack(
              children: <Widget>[
                // ArrowIcons(),
                Line(),
                Plane(
                    pageNumber ==
                        Constant.quizLevelCollection!.quizLevels[quizLevel]
                                .levelQuizQuestions.length +
                            1,
                    audioCache,
                    quizLevel),
                Positioned.fill(
                  left: 32.0 + 8,
                  child: AnimatedSwitcher(
                    child: page,
                    duration: Duration(milliseconds: 250),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Padding getListTile(int index, String userAnswer, String correctAnswer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: ListTile(
        // leading: Icon(Icons.landscape),
        leading: userAnswer == correctAnswer
            ? Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.check_circle, color: Colors.green),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.cancel, color: Colors.red),
              ),
        title: Text(Constant.quizLevelCollection!.quizLevels[quizLevel]
            .levelQuizQuestions[index].questionText),
        subtitle: Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: userAnswer == correctAnswer
                      ? Colors.greenAccent
                      : Colors.redAccent)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: 'Your answer:\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text: userAnswer,
                    style:
                        TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ])),
              // SizedBox(height: 6,),
              // RichText(text: TextSpan(
              //     children: [
              //       TextSpan(text: 'Correct Answer:\n', style: TextStyle(fontSize: 18, fontWeight:  FontWeight.bold)),
              //       TextSpan(text: correctAnswer,  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              //     ]
              // )),
            ],
          ),
        ),
        // trailing:
        // userAnswer == correctAnswer
        //     ? Icon(
        //   Icons.check_circle,
        //   color: Colors.green,
        // )
        //     : Icon(Icons.cancel,
        //     color: Colors.red),
      ),
    );
  }

  void checkAndShowPopupOverlay() async {
    if (pageNumber ==
            Constant.quizLevelCollection!.quizLevels[quizLevel]
                    .levelQuizQuestions.length +
                1 &&
        Constant.levelQuestionsAnswers
                .where((element) => element == true)
                .length ==
            Constant.quizLevelCollection!.quizLevels[quizLevel]
                .levelQuizQuestions.length) {

      // await Navigator.of(context).push(PopupOverlay());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(!Constant.hasPopupBeenShownForThisQuizAttempt) {
          await Navigator.of(context).push(PopupOverlay());
          Constant.hasPopupBeenShownForThisQuizAttempt = true;
        }
      });
    }
  }

  Widget getCurrentQuizPage() {
    if(pageNumber ==
        Constant.quizLevelCollection!.quizLevels[quizLevel].levelQuizQuestions
                .length +
            1) {
      checkAndShowPopupOverlay();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 14),
            child: Text(
              quizLevel + 1 == Constant.quizLevelCollection!.quizLevels.length
                  ? 'Quiz finished'
                  : 'Level complete',
              style: Constant.appHeaderTextSTyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 18,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Constant.quizLevelCollection!.quizLevels[quizLevel]
                  .levelQuizQuestions.length,
              itemBuilder: (context, index) {
                var userAnswer = Constant
                    .quizLevelCollection!
                    .quizLevels[quizLevel]
                    .levelQuizQuestions[index]
                    .answerOptions[answerIndexes[index]]
                    .optionText;
                var correctAnswer = Constant
                    .quizLevelCollection!
                    .quizLevels[quizLevel]
                    .levelQuizQuestions[index]
                    .answerOptions[Constant
                        .quizLevelCollection!
                        .quizLevels[quizLevel]
                        .levelQuizQuestions[index]
                        .correctAnswerOption]
                    .optionText;

                return Constant.quizLevelCollection!.quizLevels[quizLevel]
                                .levelQuizQuestions.length -
                            1 ==
                        index
                    ? Column(
                        children: [
                          getListTile(index, userAnswer, correctAnswer),
                        ],
                      )
                    : getListTile(index, userAnswer, correctAnswer);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              quizLevel == Constant.quizLevelCollection!.quizLevels.length - 1
                  ? ElevatedButton(
                      child: Text('Retake Quiz'),
                      onPressed: () async {
                        // if (!await googleSignIn.isSignedIn()) {
                        //   await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => SignUpPage()));
                        // }
                        // await updateUserScore();
                        setState(() {
                          pageNumber = 1;
                          answerIndexes.clear();
                          Constant.levelQuestionsAnswers.clear();
                          Constant.totalCorrectAnswersAcrossLevels = 0;
                          quizLevel = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Constant.colorThree,
                          side: BorderSide(
                            width: 1.0,
                            color: Colors.white,
                          )),
                    )
                  : Container(
                      width: 0,
                    ),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                child: Text(quizLevel ==
                        Constant.quizLevelCollection!.quizLevels.length - 1
                    ? 'Leader Board'
                    : 'Next Level'),
                onPressed: quizLevel ==
                        Constant.quizLevelCollection!.quizLevels.length - 1
                    ? () => onLeaderBoardButtonClick()
                    : () {
                        setState(() {
                          pageNumber = 1;
                          answerIndexes.clear();
                          Constant.levelQuestionsAnswers.clear();
                          if (quizLevel <
                              Constant.quizLevelCollection!.quizLevels.length -
                                  1) quizLevel++;
                        });
                      },
                style: ElevatedButton.styleFrom(
                    primary: Constant.colorThree,
                    side: BorderSide(
                      width: 1.0,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          (banner1 != null && banner1IsLoaded)
              ? Container(
                  height: 60,
                  width: 320,
                  child: AdWidget(ad: banner1!),
                )
              : Container(),
        ],
      );
    } else {
      return Stack(children: [
        Page(
            key: Key('page$pageNumber'),
            onOptionSelected: (ansIndex) => setState(() {
                  if (pageNumber <=
                      Constant.quizLevelCollection!.quizLevels[quizLevel]
                          .levelQuizQuestions.length) {
                    answerIndexes.add(ansIndex);
                    pageNumber++;
                  }
                }),
            question: Constant.quizLevelCollection!.quizLevels[quizLevel]
                .levelQuizQuestions[pageNumber - 1].questionText,
            answers: Constant.quizLevelCollection!.quizLevels[quizLevel]
                .levelQuizQuestions[pageNumber - 1].answerOptions
                .map((e) => e.optionText)
                .toList(),
            number: pageNumber,
            quizLevel: quizLevel),
        Positioned(
          child: (banner1 != null && banner1IsLoaded)
              ? Container(
                  height: 65,
                  width: 310,
                  child: AdWidget(ad: banner2!),
                )
              : Container(),
          left: 0,
          bottom: 8,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    banner1?.dispose();
    banner2?.dispose();
    banner1IsLoaded = false;
    banner2IsLoaded = false;
  }

  Future updateUserScore() async {
    print('Updating user score......');
    await _firestore.runTransaction((transaction) async {
      if (Constant.quizLevelCollection!.quizUsers
              .indexWhere((element) => element == currentUser!.id) ==
          -1) {
        currentUser!.quizScorePerVersion[Constant.quizLevelCollection!.quizId
            .toString()] = Constant.totalCorrectAnswersAcrossLevels.toDouble();

        transaction
            .update(_firestore.collection('quiz').doc(widget.quiz.quizId), {
          'QuizUsers': FieldValue.arrayUnion([currentUser!.id])
        });

        Constant.quizLevelCollection!.quizUsers.add(currentUser!.id);

        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['photoUrl'] = currentUser!.photoUrl;
        data['displayName'] = currentUser!.displayName;
        data['bio'] = currentUser!.bio;
        data['id'] = currentUser!.id;
        data['email'] = currentUser!.email;
        data['quizScorePerVersion'] = currentUser!.quizScorePerVersion;
        data['username'] = currentUser!.username;
        data['lastQuizTakenTime'] = DateTime.now();
        data['joiningDateTime'] = currentUser!.joiningDateTime;

        print(data['quizScorePerVersion']);

        transaction.update(
            _firestore.collection('users').doc(currentUser!.id), data);
      }
    });
  }

  Future onLeaderBoardButtonClick() async {
    if (await googleSignIn.isSignedIn()) {
      EasyLoading.show();
      await updateUserScore();
      EasyLoading.dismiss();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LeaderBoardPage()));
    } else {
      var signUpPageResult = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpPage()));

      if (signUpPageResult == false) return;

      var signInStatus = await googleSignIn.isSignedIn();
      setState(() {
        isUserSignedIn = signInStatus;
      });
      if (isUserSignedIn) {
        EasyLoading.show();
        await updateUserScore();
        EasyLoading.dismiss();

        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => LeaderBoardPage()));
      }
    }
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.0 + 32 + 8,
      top: 40,
      bottom: 0,
      width: 1,
      child: Container(color: Colors.white.withOpacity(0.5)),
    );
  }
}

class Page extends StatefulWidget {
  final int number;
  final int quizLevel;
  final String question;
  final List<String> answers;
  final Function onOptionSelected;

  const Page(
      {Key? key,
      required this.onOptionSelected,
      required this.number,
      required this.question,
      required this.answers,
      required this.quizLevel})
      : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  List<GlobalKey<_ItemFaderState>> keys = [];
  int selectedOptionKeyIndex = 0;
  late AnimationController _animationController;
  int prevQuizLevel = 0, prevQuestionNumber = 0, prevSelectedOptionKeyIndex = 0;

  @override
  void initState() {
    super.initState();
    keys = List.generate(
      Constant.quizLevelCollection!.quizLevels[widget.quizLevel]
              .levelQuizQuestions.length +
          3 +
          widget.answers.length,
      (_) => GlobalKey<_ItemFaderState>(),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    onInit();
  }

  Future<void> animateDot(Offset startOffset) async {
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        double minTop = MediaQuery.of(context).padding.top + 52;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              left: 26.0 + 32 + 8,
              top: minTop +
                  (startOffset.dy - minTop) * (1 - _animationController.value),
              child: child ?? Text(''),
            );
          },
          child: Dot(),
        );
      },
    );
    Overlay.of(context)!.insert(entry);
    await _animationController.forward(from: 0);
    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 32),
        ItemFader(key: keys[0], child: StepNumber(number: widget.number)),
        ItemFader(
          key: keys[1],
          child: StepQuestion(question: widget.question),
        ),
        Spacer(),
        ...widget.answers.map((String answer) {
          int answerIndex = widget.answers.indexOf(answer);
          int keyIndex = answerIndex + 3;
          return ItemFader(
            key: keys[keyIndex],
            child: OptionItem(
              name: answer,
              onTap: (offset) {
                if (prevQuizLevel == widget.quizLevel &&
                    prevQuestionNumber == widget.number) {
                } else {
                  onTap(keyIndex - 1, offset, answerIndex, widget.number,
                      widget.quizLevel);
                  prevQuizLevel = widget.quizLevel;
                  prevQuestionNumber = widget.number;
                }
              },
              showDot: selectedOptionKeyIndex != keyIndex,
            ),
          );
        }),
        SizedBox(height: 64),
      ],
    );
  }

  void onTap(int keyIndex, Offset offset, int answerIndex, int questionNumber,
      int quizLevel) async {
    var mediaQD = MediaQuery.of(context);
    var maxWidth = mediaQD.size.width;

    for (GlobalKey<_ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 40));
      if (key.currentState != null) key.currentState!.hide();
      if (keys.indexOf(key) == keyIndex) {
        setState(() => selectedOptionKeyIndex = keyIndex);
        animateDot(offset).then((_) => widget.onOptionSelected(answerIndex));
        BlocProvider.of<QuestionCubit>(context).onQuestionAnswered(
            quizLevel, questionNumber, selectedOptionKeyIndex - 2);
      }
    }
  }

  void onInit() async {
    for (GlobalKey<_ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 40));
      if (key.currentState != null) key.currentState!.show();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }
}

class StepNumber extends StatelessWidget {
  final int number;

  const StepNumber({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class StepQuestion extends StatelessWidget {
  final String question;

  const StepQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Text(
        question,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class OptionItem extends StatefulWidget {
  final String name;
  final void Function(Offset dotOffset) onTap;
  final bool showDot;

  const OptionItem(
      {Key? key, required this.name, required this.onTap, this.showDot = true})
      : super(key: key);

  @override
  _OptionItemState createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        RenderBox object = context.findRenderObject() as RenderBox;
        Offset globalPosition = object.localToGlobal(Offset.zero);

        widget.onTap(globalPosition);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            SizedBox(width: 26),
            Dot(visible: widget.showDot),
            SizedBox(width: 26),
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ItemFader extends StatefulWidget {
  final Widget child;

  const ItemFader({Key? key, required this.child}) : super(key: key);

  @override
  _ItemFaderState createState() => _ItemFaderState();
}

class _ItemFaderState extends State<ItemFader>
    with SingleTickerProviderStateMixin {
  //1 means its below, -1 means its above
  int position = 1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void show() {
    setState(() => position = 1);
    _animationController.forward();
  }

  void hide() {
    setState(() => position = -1);
    _animationController.reverse();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController.view,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 64 * position * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class Dot extends StatelessWidget {
  final bool visible;

  const Dot({Key? key, this.visible = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visible ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class ArrowIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: () {},
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              color: Color.fromRGBO(120, 58, 183, 1),
              icon: Icon(Icons.arrow_downward),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class Plane extends StatefulWidget {
  final bool isLevelComplete;
  final AudioCache audioCache;
  final int quizLevel;

  Plane(this.isLevelComplete, this.audioCache, this.quizLevel);

  @override
  _PlaneState createState() => _PlaneState();
}

class _PlaneState extends State<Plane> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation = CurvedAnimation(
      parent: _animationController.view,
      curve: Curves.easeInOut,
    );
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuestionCubit, QuestionState>(
      listener: (context, state) {
        if (state is AnsweredCorrectly) {
          widget.audioCache.play('correct.mp3');
          _animationController.forward(from: 0);
          Constant.levelQuestionsAnswers.add(true);
          Constant.totalCorrectAnswersAcrossLevels++;
        } else if (state is AnsweredInCorrectly) {
          widget.audioCache.play('wrong.mp3');
          Constant.levelQuestionsAnswers.add(false);
        }
      },
      child: widget.isLevelComplete
          ? Stack(children: [
              Positioned(
                  left: 38,
                  top: 5,
                  child: Stack(children: [
                    Card(
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.white, width: 1),
                        //rderRadius: BorderRadius.circular(10),
                      ),
                      // shape: RoundedRectangleBorder(
                      //   side: BorderSide(color: Colors.white70, width: 1),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      color: Colors.white,
                      child: Container(
                        height: 60,
                        width: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Center(
                            child: Text(
                              '${Constant.levelQuestionsAnswers.where((element) => element == true).length.toString()}/${Constant.levelQuestionsAnswers.length}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Constant.colorOne),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            // 'LEVEL SCORE',
                            'SCORE',
                            style: TextStyle(
                                color: Constant.colorOne,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          )),
                    )),
                  ])),
              // Positioned(
              //     right: 2,
              //     top: 5,
              //     child: Stack(children: [
              //       Card(
              //         shape: BeveledRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0),
              //         ),
              //         color: Colors.white,
              //         child: Container(
              //           height: 60,
              //           width: 60,
              //           child: Center(
              //             child: Text(
              //               '${Constant.totalCorrectAnswersAcrossLevels}/'
              //               '${Constant.quizLevelCollection!.quizLevels.take(widget.quizLevel + 1).expand((element) => element.levelQuizQuestions).length}',
              //               style: TextStyle(
              //                   fontSize: 24,
              //                   fontWeight: FontWeight.bold,
              //                   color: Constant.colorOne),
              //             ),
              //           ),
              //         ),
              //       ),
              //       Positioned.fill(
              //           child: Padding(
              //         padding: const EdgeInsets.only(bottom: 8.0),
              //         child: Align(
              //             alignment: Alignment.bottomCenter,
              //             child: Text(
              //               'TOTAL SCORE',
              //               style: TextStyle(
              //                   color: Constant.colorOne,
              //                   fontSize: 7,
              //                   fontWeight: FontWeight.bold),
              //             )),
              //       )),
              //     ]))
            ])
          : Positioned(
              left: 32.0 + 8,
              top: 10,
              // child: Image.asset('assets/BowlingPin.png'),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..scale(_animationController.value)
                      ..rotateZ(_animationController.value * -math.pi / 2)
                      ..translate(_animationController.value - 5)
                      ..setEntry(3, 2, -0.002),
                    child: child,
                  )..transform.rotateZ(math.pi / 2);
                },
                child: Image.asset('assets/BowlingPin.png', width:65, height:65),
              ),
            ),
    );
  }
}
