import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:flutter_quiz_app/helpers/extension_methods.dart';
import 'package:flutter_quiz_app/helpers/local_notification_service.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_chart.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_resources.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_cards.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_event.dart';
import 'package:flutter_quiz_app/logic/cubit/internet_cubit.dart';
import 'package:flutter_quiz_app/logic/cubit/internet_state.dart';
import 'package:flutter_quiz_app/logic/cubit/question_cubit.dart';
import 'package:flutter_quiz_app/logic/cubit/question_state.dart';
import 'package:flutter_quiz_app/screens/popup_overlay.dart';
import 'package:flutter_quiz_app/screens/profile_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'leader_board_page.dart';
import 'more_page.dart';

class QuizPage extends StatefulWidget {
  final Connectivity connectivity;

  QuizPage(this.connectivity);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  int pageNumber = 1;
  List<int> answerIndexes = [];
  late Future<QuizLevelCollection> getQuestions;
  String? token;
  int quizLevel = 0;
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String? localFilePath;
  String? localAudioCacheURI;
  late BannerAd banner1;
  late BannerAd banner2;

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
    getQuestions = fetchData();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<InternetCubit>(
            create: (context) =>
                InternetCubit(connectivity: widget.connectivity)),
        BlocProvider<QuestionCubit>(create: (context) => QuestionCubit()),
      ],
      child: FlutterEasyLoading(
        child: BlocBuilder<InternetCubit, InternetState>(
            builder: (context, state) {
          if (state is InternetDisconnected) {
            return Center(
                child: Text('No internet, please check your connection'));
          }
          return FutureBuilder<QuizLevelCollection>(
              future: getQuestions,
              builder: (context, data) {
                if (data.hasData) {
                  EasyLoading.dismiss();

                  Constant.quizLevelCollection = data.data;

                  checkAndShowPopupOverlay();

                  Widget page = getCurrentQuizPage();

                  return SafeArea(
                    child: Scaffold(
                      appBar: AppBar(
                        title: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                                '${Constant.quizLevelCollection!.quizLevels[quizLevel].levelNumber}'),
                          ),
                        ),
                        backgroundColor: Constant.colorThree,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.read_more_sharp),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MorePage()));
                            },
                          ),
                          Constant.userProfileData.username.isEmpty ? AvatarGlow(
                            endRadius: 60.0,
                            child: IconButton(
                              icon: const FaIcon(FontAwesomeIcons.userCircle),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()));
                              },
                            ),
                          ) : IconButton(
                            icon: const FaIcon(FontAwesomeIcons.userCircle),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()));
                            },
                          )
                        ],
                      ),
                      body: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: Constant.backgroundDecoration,
                        child: Stack(
                          children: <Widget>[
                            ArrowIcons(),
                            Line(),
                            Plane(pageNumber ==
                                Constant
                                        .quizLevelCollection!
                                        .quizLevels[quizLevel]
                                        .levelQuizQuestions
                                        .length +
                                    1),
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
                  );
                } else {
                  EasyLoading.show(status: 'Fetching data..');
                  return Container();
                }
              });
        }),
      ),
    );
  }

  Future<QuizLevelCollection> fetchData() async {

    final _firestore = FirebaseFirestore.instance;

    if (Constant.box.get(Constant.userIdBox) == null) await Constant.addUser();

    var quizSnapshotFuture = _firestore.collection('quiz').get();
    var cardsSnapshotFuture = _firestore.collection('cards').get();
    var resourcesSnapshotFuture = _firestore.collection('resources').get();
    var chartSnapshotFuture = _firestore.collection('chart').get();
    var userSnapshotFuture = _firestore.collection('users').get();

    var value = await Future.wait([
      quizSnapshotFuture,
      cardsSnapshotFuture,
      resourcesSnapshotFuture,
      chartSnapshotFuture,
      userSnapshotFuture
    ]);

    Constant.slidingCardsList =
        CardsCollection.fromJson(value[1].docs[0].data()).slidingCards;
    Constant.slidingEventsList =
        EventsCollection.fromJson(value[1].docs[1].data()).slidingEvents;

    Constant.imageResources =
        Resources.fromJson(value[2].docs.first.data()).imageResources;
    Constant.screenDynamicText =
        Resources.fromJson(value[2].docs.first.data()).screenDynamicTexts;
    Constant.identifiers =
        Resources.fromJson(value[2].docs.first.data()).identifiers;
    Constant.popupOverlayBackgroundColorIntValue = int.parse(Constant.screenDynamicText
        .firstWhere((element) => element.screenName == "PopupPageColors").screenTexts[0]);
    Constant.popupOverlayTextColorIntValue = int.parse(Constant.screenDynamicText
        .firstWhere((element) => element.screenName == "PopupPageColors").screenTexts[1]);


    value[4].docs.forEach((e) {
      print(e.data());
      Constant.users.add(User.fromJson(e.data()));
    });

    if (Constant.box.get(Constant.userScoreBox) == null) {
      Constant.box.put(Constant.userScoreBox, <String>[Constant.screenDynamicText
          .firstWhere((element) => element.screenName == 'QuizVersion')
        .screenTexts[0], "0"]);
    }

    Constant.userProfileData =
        Constant.users.firstWhere((element) => element.userId == Constant.box.get(Constant.userIdBox));

    await loadAppAds();

    Constant.slidingCardsList!.forEach((element) {
      cacheImage(context, element.picUrl);
    });

    Constant.slidingEventsList!.forEach((element) {
      cacheImage(context, element.picUrl);
    });

    Constant.chartData = ChartData.fromJson(value[3].docs.first.data());

    updateUserNotesAndSlidingCardBoxes();
    print('hello2');
    return QuizLevelCollection.fromJson(value[0].docs[0].data());
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  ListTile getListTile(int index, String userAnswer, String correctAnswer) {
    return ListTile(
      // leading: Icon(Icons.landscape),
      leading: userAnswer == correctAnswer
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.cancel, color: Colors.red),
                ),
              ],
            ),
      title: Text(Constant.quizLevelCollection!.quizLevels[quizLevel]
          .levelQuizQuestions[index].questionText),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Answer: $userAnswer"),
          Text("Correct Answer: $correctAnswer"),
        ],
      ),
      // trailing:
      // userAnswer == correctAnswer
      //     ? Icon(
      //   Icons.check_circle,
      //   color: Colors.green,
      // )
      //     : Icon(Icons.cancel,
      //     color: Colors.red),
    );
  }

  void checkAndShowPopupOverlay() {
    if (pageNumber ==
            Constant.quizLevelCollection!.quizLevels[quizLevel]
                    .levelQuizQuestions.length +
                1 &&
        Constant.levelQuestionsAnswers
                .where((element) => element == true)
                .length ==
            Constant.quizLevelCollection!.quizLevels[quizLevel]
                .levelQuizQuestions.length) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).push(PopupOverlay());
        audioCache.play('strike.mp3', mode: PlayerMode.LOW_LATENCY);
      });
    }
  }

  Widget getCurrentQuizPage() {
    return pageNumber ==
            Constant.quizLevelCollection!.quizLevels[quizLevel]
                    .levelQuizQuestions.length +
                1
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 14),
                child: Text(
                  quizLevel + 1 ==
                          Constant.quizLevelCollection!.quizLevels.length
                      ? 'Quiz finished'
                      : 'Level complete',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                        .levelQuizQuestions![index]
                        .answerOptions[Constant
                            .quizLevelCollection!
                            .quizLevels[quizLevel]
                            .levelQuizQuestions![index]
                            .correctAnswerOption]
                        .optionText;

                    return Constant.quizLevelCollection!.quizLevels[quizLevel]
                                    .levelQuizQuestions.length -
                                1 ==
                            index
                        ? Column(
                            children: [
                              getListTile(index, userAnswer, correctAnswer),
                              // SizedBox(
                              //   height: 18,
                              // ),
                              // Text(
                              //   'Level ${quizLevel +1} score: $correctAnswersForLevel / ${Constant.quizLevelCollection!.quizLevels[quizLevel].levelQuizQuestions.length}',
                              //   style: TextStyle(fontSize: 24),
                              // ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Total score: ${Constant.totalCorrectAnswersAcrossLevels} / ${Constant.quizLevelCollection!.quizLevels.take(quizLevel + 1).expand((element) => element.levelQuizQuestions).length}',
                                style: TextStyle(fontSize: 24),
                              )
                            ],
                          )
                        : getListTile(index, userAnswer, correctAnswer);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  quizLevel == Constant.quizLevelCollection!.quizLevels.length - 1 ? ElevatedButton(
                    child: Text('Retake Quiz'),
                    onPressed: () async{
                      await updateUserScore();
                      setState(()  {
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
                  ) : Container(width: 0,),
                  SizedBox(width: 5,),
                  ElevatedButton(
                    child: Text(quizLevel ==
                        Constant.quizLevelCollection!.quizLevels.length - 1 ? 'Leader Board' : 'Next Level'),
                    onPressed: quizLevel ==
                            Constant.quizLevelCollection!.quizLevels.length - 1
                        ? () async {
                      EasyLoading.show(status: 'Submitting your score..');
                      await updateUserScore();
                      EasyLoading.dismiss();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LeaderBoardPage()));
                        }
                        : () {
                            setState(() {
                              pageNumber = 1;
                              answerIndexes.clear();
                              Constant.levelQuestionsAnswers.clear();
                              if (quizLevel <
                                  Constant.quizLevelCollection!.quizLevels
                                          .length -
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
              Container(
                height: 60,
                width: 320,
                child: AdWidget(ad: banner1),
              ),
            ],
          )
        : Stack(children: [
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
              bottom: 5,
              right: 1,
              child: Text(
                'Bowling pin icon by Icons8',
                style: TextStyle(fontSize: 7),
              ),
            ),
            Positioned(
              child: Container(
                height: 65,
                width: 310,
                child: AdWidget(ad: banner2),
              ),
              left: 0,
              bottom: 8,
            ),
          ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    banner1.dispose();
  }

  Future loadAppAds() async{
    banner1 = BannerAd(
        size: AdSize.banner,
        // TEST
        adUnitId: Platform.isAndroid
            ? Constant.identifiers
                .firstWhere((identifier) =>
                    identifier.identifierName ==
                    IdentifierNameEnum.bannerAdUnitIdAndroid1.toShortString)
                .identifierValue
            : Constant.identifiers
                .firstWhere((identifier) =>
                    identifier.identifierName ==
                    IdentifierNameEnum.adUnitIdiOS.toShortString)
                .identifierValue,
        listener: BannerAdListener(),
        request: AdRequest())
      ..load();

    banner2 = BannerAd(
        size: AdSize.banner,
        // TEST
        adUnitId: Platform.isAndroid
            ? Constant.identifiers
                .firstWhere((identifier) =>
                    identifier.identifierName ==
                    IdentifierNameEnum.bannerAdUnitIdAndroid2.toShortString)
                .identifierValue
            : Constant.identifiers
                .firstWhere((identifier) =>
                    identifier.identifierName ==
                    IdentifierNameEnum.adUnitIdiOS.toShortString)
                .identifierValue,
        listener: BannerAdListener(),
        request: AdRequest())
      ..load();

    await InterstitialAd.load(
        adUnitId: Constant.identifiers
            .firstWhere((element) =>
                element.identifierName ==
                IdentifierNameEnum
                    .interstitialAdUnitIdAndroid.toShortString)
            .identifierValue,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad <<<LOADED>>>');
            Constant.interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            Constant.interstitialAd = null;
          },
        ));
  }

  void updateUserNotesAndSlidingCardBoxes() {
    try {
      if (Constant.box.get(Constant.userNotesBox) == null) {
        Constant.box.put(Constant.userNotesBox, Map<String, List<int>>());
      }

      if (Constant.box.get(Constant.slidingCardsBox) == null) {
        Constant.box.put(Constant.slidingCardsBox, Map<String, String>());
      }

      Constant.slidingCardsList!.forEach((element) {
        if (!(Constant.box.get(Constant.slidingCardsBox) as Map)
            .containsKey(element.name)) {
          (Constant.box.get(Constant.slidingCardsBox) as Map)[element.name] =
              element.description;
          (Constant.box.get(Constant.userNotesBox) as Map)[element.name] =
              <int>[];
        } else if ((Constant.box.get(Constant.slidingCardsBox) as Map)
                .containsKey(element.name) &&
            (Constant.box.get(Constant.slidingCardsBox) as Map)[element.name] !=
                element.description) {
          (Constant.box.get(Constant.slidingCardsBox) as Map)[element.name] =
              element.description;
          (Constant.box.get(Constant.userNotesBox) as Map)[element.name] =
              <int>[];
        }
        Constant.box.put(Constant.slidingCardsBox,
            Constant.box.get(Constant.slidingCardsBox) as Map);
        Constant.box.put(Constant.userNotesBox,
            Constant.box.get(Constant.userNotesBox) as Map);
      });

      List<String> userNotesMapKeysToDelete = [];
      List<String> slidingCardsMapKeysToDelete = [];

      (Constant.box.get(Constant.slidingCardsBox) as Map).forEach((key, value) {
        if (Constant.slidingCardsList!
                .where((element) => element.name == key)
                .length ==
            0) {
          userNotesMapKeysToDelete.add(key);
          slidingCardsMapKeysToDelete.add(key);
        }
      });

      userNotesMapKeysToDelete.forEach((String name) {
        if ((Constant.box.get(Constant.userNotesBox) as Map)
            .keys
            .contains(name))
          (Constant.box.get(Constant.userNotesBox) as Map).remove(name);
      });

      slidingCardsMapKeysToDelete.forEach((String name) {
        if ((Constant.box.get(Constant.slidingCardsBox) as Map)
            .keys
            .contains(name))
          (Constant.box.get(Constant.slidingCardsBox) as Map).remove(name);
      });
    } on Exception catch (e) {
      // TODO
    }
  }

  Future updateUserScore() async {
    Constant.userProfileData.quizScore = Constant.totalCorrectAnswersAcrossLevels.toString();

    var boxedQuizVersion = Constant.box.get(Constant.userScoreBox)[0];
    var boxedQuizScore = Constant.box.get(Constant.userScoreBox)[1];

    if(boxedQuizVersion != Constant.screenDynamicText
        .firstWhere((element) => element.screenName == 'QuizVersion')
        .screenTexts[0] || boxedQuizScore == "0") {

      await _firestore
          .collection('users')
          .doc(Constant.box.get(Constant.userIdBox))
          .set(Constant.userProfileData.toJson(), SetOptions(merge: true));

      Constant.box.put(Constant.userScoreBox, [Constant.screenDynamicText
          .firstWhere((element) => element.screenName == 'QuizVersion')
          .screenTexts[0],Constant.userProfileData.quizScore.toString()]);
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

  @override
  void initState() {
    super.initState();
    keys = List.generate(
      Constant.quizLevelCollection!.quizLevels[widget.quizLevel]
              .levelQuizQuestions.length +
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
          int keyIndex = answerIndex + 2;
          return ItemFader(
            key: keys[keyIndex],
            child: OptionItem(
              name: answer,
              onTap: (offset) => onTap(keyIndex, offset, answerIndex,
                  widget.number, widget.quizLevel),
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

  Plane(this.isLevelComplete);

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
      duration: Duration(milliseconds: 450),
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
          _animationController.forward(from: 0);
          Constant.levelQuestionsAnswers.add(true);
          Constant.totalCorrectAnswersAcrossLevels++;
        } else if (state is AnsweredInCorrectly)
          Constant.levelQuestionsAnswers.add(false);
      },
      child: widget.isLevelComplete
          ? Positioned(
              left: 38,
              top: 5,
              child: Stack(children: [
                Card(
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.white,
                  child: Container(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text(
                        '${Constant.levelQuestionsAnswers.where((element) => element == true).length.toString()}/${Constant.levelQuestionsAnswers.length}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Constant.colorOne),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'LEVEL SCORE',
                        style: TextStyle(
                            color: Constant.colorOne,
                            fontSize: 6,
                            fontWeight: FontWeight.bold),
                      )),
                ))
              ]))
          : Positioned(
              left: 32.0 + 8,
              top: 10,
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
                child: Image.asset('assets/BowlingPin.png'),
              ),
            ),
    );
  }
}
