import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart'
    as userJson;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/screens/new_quiz_settings.dart';
import 'package:flutter_quiz_app/screens/quiz_page.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helpers/constant.dart';
import '../json_parsers/json_parser_firebase_chart.dart';
import '../json_parsers/json_parser_firebase_questions.dart';
import '../json_parsers/json_parser_firebase_resources.dart';
import '../json_parsers/json_parser_firebase_user.dart';
import '../json_parsers/json_parser_sliding_cards.dart';
import '../json_parsers/json_parser_sliding_event.dart';
import '../widgets/common.dart';
import '../widgets/progress.dart';
import 'leader_board_page.dart';
import 'more_page.dart';
import 'package:expandable/expandable.dart';

class QuizTiles extends StatefulWidget {
  const QuizTiles({Key? key}) : super(key: key);

  @override
  State<QuizTiles> createState() => _QuizTilesState();
}

class _QuizTilesState extends State<QuizTiles> {
  var quizList = <Quiz>[];
  Random rnd = Random();
  String snackBarText = '';

  @override
  initState() {
    super.initState();

    // Re-authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {});
    fetchData();
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      final GoogleSignInAccount? user = googleSignIn.currentUser;
      DocumentSnapshot doc = await usersRef.doc(user?.id).get();
      setState(() => currentUser = User.fromDocument(doc));
      cacheImage(context, currentUser!.photoUrl);
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon:
                  FaIcon(FontAwesomeIcons.bookOpen, color: Constant.colorIcon),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MorePage()));
              },
            ),
            actions: [
              IconButton(
                icon:
                    FaIcon(FontAwesomeIcons.trophy, color: Constant.colorIcon),
                onPressed: () async {
                  if (await googleSignIn.isSignedIn()) {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaderBoardPage()))
                        .then((value) async {
                      var signInStatus = await googleSignIn.isSignedIn();
                      setState(() {
                        setState(() {
                          isUserSignedIn = signInStatus;
                        });
                        Constant.quizLevelCollection = null;
                        Constant.levelQuestionsAnswers.clear();
                        Constant.totalCorrectAnswersAcrossLevels = 0;
                        Constant.hasPopupBeenShownForThisQuizAttempt = false;
                      });
                    });
                  } else {
                    var signUpPageResult = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));

                    if (signUpPageResult == false) return;

                    var signInStatus = await googleSignIn.isSignedIn();
                    setState(() {
                      isUserSignedIn = signInStatus;
                    });
                    if (isUserSignedIn) {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LeaderBoardPage()))
                          .then((value) {
                        setState(() {
                          isUserSignedIn = signInStatus;
                        });
                        Constant.quizLevelCollection = null;
                        Constant.levelQuestionsAnswers.clear();
                        Constant.totalCorrectAnswersAcrossLevels = 0;
                        Constant.hasPopupBeenShownForThisQuizAttempt = false;
                      });
                    }
                  }
                },
              ),
              // currentUser == null ? Container() : IconButton(
              //   icon: CachedNetworkImage(imageUrl: currentUser?.photoUrl ?? ''),
              //   iconSize: 50,
              //   onPressed: () async{
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => ProfilePage()));
              //   },
              // )
            ],
            title: const Text(
              'Quizzes',
              style: Constant.appHeaderTextSTyle,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            backgroundColor: Constant.colorTwo,
          ),
          floatingActionButton: _getFAB(),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: Constant.backgroundDecoration,
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('quiz').get(),
                // async work
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return circularProgress();
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else {
                        final List<DocumentSnapshot<Map<String, dynamic>>>
                            documents = snapshot.data!.docs;
                        quizList.clear();
                        documents.forEach((doc) {
                          quizList.add(Quiz.fromJson(doc.data()!));
                        });

                        return getGroupedMasonryGridViews(quizList);
                      }
                  }
                }),
          )),
    );
  }

  fetchData() async {
    final _firestore = FirebaseFirestore.instance;

    var cardsSnapshotFuture = _firestore.collection('cards').get();
    var resourcesSnapshotFuture = _firestore.collection('resources').get();
    var chartSnapshotFuture = _firestore.collection('chart').get();
    var userSnapshotFuture = _firestore.collection('users').get();

    var signInStatus = await googleSignIn.isSignedIn();
    setState(() {
      isUserSignedIn = signInStatus;
    });

    var value = await Future.wait([
      cardsSnapshotFuture,
      resourcesSnapshotFuture,
      chartSnapshotFuture,
      userSnapshotFuture
    ]);
    Constant.slidingCardsList =
        CardsCollection.fromJson(value[0].docs[0].data()).slidingCards;
    Constant.slidingEventsList =
        EventsCollection.fromJson(value[0].docs[1].data()).slidingEvents;

    var resources = Resources.fromJson(value[1].docs.first.data());
    Constant.imageResources = resources.imageResources;
    Constant.screenDynamicText = resources.screenDynamicTexts;

    Constant.identifiers = resources.identifiers;

    Constant.identifiers.forEach((element) {print('${element.identifierName}');});

    snackBarText = resources.developerMessages!.first;
    if (snackBarText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(snackBarText,
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
        backgroundColor: Constant.colorTwo,
      ));
    }

    Constant.popupOverlayBackgroundColorIntValue = int.parse(Constant
        .screenDynamicText
        .firstWhere((element) => element.screenName == "PopupPageColors")
        .screenTexts[0]);
    Constant.popupOverlayTextColorIntValue = int.parse(Constant
        .screenDynamicText
        .firstWhere((element) => element.screenName == "PopupPageColors")
        .screenTexts[1]);
    try {
      value[3].docs.forEach((e) {
        print(e.data());
        print(json.encode(e.data()));
        Constant.users.add(userJson.User.fromDocument(e));
      });
    } catch (e) {
      print(e);
    }

    Constant.slidingCardsList!.forEach((element) {
      if (element.picUrl.isNotEmpty) cacheImage(context, element.picUrl);
    });

    Constant.slidingEventsList!.forEach((element) {
      if (element.picUrl.isNotEmpty) cacheImage(context, element.picUrl);
    });

    Constant.chartData = ChartData.fromJson(value[2].docs.first.data());
    await Constant.loadAppAds();
    // updateUserNotesAndSlidingCardBoxes();
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

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

  Container getGroupedMasonryGridViews(List<Quiz> quizList) {
    List<Widget> widgets = [];
    Map<String, List<Quiz>> mappedQuizzes =
        groupBy(quizList, (Quiz quiz) => quiz.quizCategory);

    mappedQuizzes.keys.forEach((element) {
      var quizList = mappedQuizzes[element] ?? [];
      quizList.sort((a, b) => a.quizNumber.compareTo(b.quizNumber));
      // widgets.add(Container(
      //   height: 60,
      //     decoration: BoxDecoration(
      //   color: Color(0x80000428),
      //   // border: Border.all(
      //   //     color: Constant.colorTwo, // Set border color
      //   //     width: 1.0),
      //     ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Expanded(
      //         child: Center(child:Text(quizList.first.quizCategory,
      //           style: TextStyle(fontSize: 16, color: Colors.white,fontWeight:FontWeight.bold),),),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: FaIcon(FontAwesomeIcons.scroll),
      //       )
      //     ],
      //   ),
      // ));
      widgets.add(ExpandableNotifier(
        initialExpanded: true,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              iconColor: Colors.white70,
            ),
            header: Container(
              decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: 35,
              child: Center(
                child: Text(
                  quizList.first.quizCategory,
                  style: TextStyle(
                      fontSize: 16,
                      color: Constant.colorTwo,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            collapsed: Container(),
            expanded: Padding(
                padding: const EdgeInsets.all(8),
                child: MasonryGridView.count(
                  shrinkWrap: true,
                  itemCount: quizList.length,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizPage(quizList[index])),
                        ).then((value) async {
                          var isSigned = await googleSignIn.isSignedIn();
                          setState(() {
                            isUserSignedIn = isSigned;
                          });
                          Constant.quizLevelCollection = null;
                          Constant.levelQuestionsAnswers.clear();
                          Constant.totalCorrectAnswersAcrossLevels = 0;
                          Constant.hasPopupBeenShownForThisQuizAttempt = false;
                        });
                      },
                      child: Stack(children: [
                        Tooltip(
                          message: quizList[index].quizCreatedByUsername.isNotEmpty ?
                          'This quiz is created by ${quizList[index].quizCreatedByUsername}' :
                          'This quiz is created by Anonymous',
                          child: Tile(
                              quiz: quizList[index],
                              extent: 150,
                              backgroundColor: Colors.transparent),
                        ),
                        (!isUserSignedIn)
                            ? Container()
                            : quizList[index]
                                    .quizUsers
                                    .contains(currentUser?.id)
                                ? Positioned(
                                    bottom: 1,
                                    right: 10,
                                    child: Icon(Icons.check_circle,
                                        color: Colors.green))
                                : Container()
                      ]),
                    );
                  },
                )),
          ),
        ),
      ));
    });

    return Container(
        child: SingleChildScrollView(child: Column(children: widgets)));
  }

  _getFAB() {
    return  isUserSignedIn ? FloatingActionButton(
      backgroundColor: Constant.colorIcon,
      onPressed:(){
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewQuizSettings())).then((value) {
              setState((){});
        });
      }, child: Icon(Icons.add, color: Colors.white,),
    ) : Container();
  }
}
