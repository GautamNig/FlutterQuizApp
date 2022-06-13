import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:flutter_quiz_app/widgets/progress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../json_parsers/json_parser_firebase_questions.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final _firestore = FirebaseFirestore.instance;
  List<User> userList = [];
  num topScore = 0;
  bool isCurrentUserPurgeInProgress = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          userList = List<User>.from(
              snapshot.data!.docs.map((x) => User.fromDocument(x)));
        }

        userList.sort((a, b) {
          var quizB = b.quizScorePerVersion.length == 0 ? 0 : b.quizScorePerVersion.values
              .reduce((sum, element) => sum + element);

          var quizA = a.quizScorePerVersion.length == 0 ? 0 : a.quizScorePerVersion.values
              .reduce((sum, element) => sum + element);

          return quizB.compareTo(quizA);
        });

        return Scaffold(
          backgroundColor: Constant.colorTwo,
          appBar: AppBar(
            leading: isUserSignedIn ? Row(
              children: [
                Expanded(child: IconButton(icon:Icon(Icons.exit_to_app_outlined, color: Constant.colorIcon,),
                    onPressed: () async {
                  await Alert(
                      context: context,
                      style: AlertStyle(
                        animationType: AnimationType.fromTop,
                        isCloseButton: false,
                        isOverlayTapDismiss: false,
                        backgroundColor: Constant.colorThree,
                        titleStyle: const TextStyle(color: Colors.white),
                        descStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                        animationDuration:
                        const Duration(milliseconds: 400),
                        alertBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: "Sign out",
                      content: const Text(
                          'Are you sure you want to sign out?'),
                      buttons: [
                        DialogButton(
                            child: const Text(
                              'Yes',
                              style: const TextStyle(
                                  color: Constant.colorThree),
                            ),
                            color: Colors.white70,
                            onPressed: () async {
                              try {
                                await googleSignIn.signOut();
                                setState(() {
                                  isUserSignedIn = false;
                                  currentUser = null;
                                });
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              } catch (e) {
                                await Alert(
                                    context: context,
                                    style: AlertStyle(
                                      animationType:
                                      AnimationType.fromTop,
                                      isCloseButton: false,
                                      isOverlayTapDismiss: false,
                                      backgroundColor:
                                      Constant.colorThree,
                                      titleStyle: const TextStyle(
                                          color: Colors.white),
                                      descStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      animationDuration: const Duration(
                                          milliseconds: 400),
                                      alertBorder: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(0.0),
                                        side: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    title: "Error",
                                    content: Text(
                                        'Problem signing out, try later.'),
                                    buttons: [
                                      DialogButton(
                                          child: const Text(
                                            'Ok',
                                            style: const TextStyle(
                                                color:
                                                Constant.colorThree),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })
                                    ]).show();
                              }
                            }),
                        DialogButton(
                          child: const Text(
                            'No',
                            style: const TextStyle(
                                color: Constant.colorThree),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.white70,
                        )
                      ]).show();
                }),),
                Expanded(
                  child: IconButton(onPressed: (){
                    Alert(
                      context: context,
                      type: AlertType.warning,
                      title: "PURGE USER",
                      desc: "This action will permanently delete all your data and sign you out of the application. Do you wish to continue?",
                      buttons: [
                        DialogButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await FirebaseFirestore.instance
                                .runTransaction((
                                Transaction myTransaction) async {
                              QuerySnapshot<Map<String,
                                  dynamic>> quizzesToUpdate = await FirebaseFirestore
                                  .instance.collection('quiz')
                                  .where(
                                  'QuizUsers', arrayContains: currentUser?.id)
                                  .get();

                              quizzesToUpdate.docs.forEach((doc) {
                                Quiz quiz = Quiz.fromJson(doc.data());
                                if (quiz.quizUsers.contains(currentUser?.id))
                                  quiz.quizUsers.remove(currentUser?.id);

                                myTransaction.update(doc.reference, {
                                  'QuizUsers': quiz.quizUsers
                                });
                              });

                              QuerySnapshot<Map<String,
                                  dynamic>> quizzesToConfiscate = await FirebaseFirestore
                                  .instance.collection('quiz')
                                  .where(
                                  'QuizCreatedByUserId', isEqualTo: currentUser?.id)
                                  .get();

                              quizzesToConfiscate.docs.forEach((doc) {
                                myTransaction.update(doc.reference, {
                                  'QuizCreatedByUserId': '',
                                  'QuizCreatedByUsername': '',
                                });
                              });

                              var usersToDelete = await usersRef
                                  .where('id', isEqualTo: currentUser?.id)
                                  .get();

                              usersToDelete.docs.forEach((doc) {
                                myTransaction.delete(doc.reference);
                              });

                              await googleSignIn.signOut();
                            });

                            setState(() {
                              isUserSignedIn = false;
                              currentUser = null;
                            });
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          color: const Color.fromRGBO(0, 179, 134, 1.0),
                        ),
                        DialogButton(
                          child: const Text(
                            "No",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(116, 116, 191, 1.0),
                            Color.fromRGBO(52, 138, 199, 1.0)
                          ]),
                        )
                      ],
                    ).show();
                  }, icon: Icon(Icons.delete_forever_outlined, color: Constant.colorIcon,)),
                )
              ],
            ) : Container(),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                color: Constant.colorIcon,
                icon: Image.asset('assets/Quiz.png'),
                iconSize: 100,
                onPressed: () {
                  Constant.hasPopupBeenShownForThisQuizAttempt = false;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
            title: Center(
              child: Text(
                "Scores",
                maxLines: 2,
                style: Constant.appHeaderTextSTyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            backgroundColor: Constant.colorTwo,
          ),
          body: Stack(children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: userList.length,
              itemBuilder: (BuildContext context, int index) {
                var userIndex = Constant.users
                    .indexWhere((element) => element.id == userList[index].id);
                if (userIndex == -1)
                  Constant.users.add(userList[index]);
                else
                  Constant.users[userIndex] = userList[index];

                if (index == 0)
                  topScore = userList[index].quizScorePerVersion.length > 0
                      ? userList[index]
                      .quizScorePerVersion
                      .values
                      .reduce((sum, element) => sum + element)
                      : 0;

                return Card(
                  elevation: 8.0,
                  margin:
                  new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: Constant.backgroundDecoration,
                    child: userList[index].quizScorePerVersion.length > 0
                        ? buildListTile(userList[index], topScore)
                        : Container(),
                  ),
                );
              },
            ),
            Constant.createAttributionAlignWidget(
                Constant.screenDynamicText
                    .firstWhere(
                        (element) => element.screenName == 'PopupOverlay')
                    .screenTexts[0],
                Constant.screenDynamicText
                    .firstWhere(
                        (element) => element.screenName == 'PopupOverlay')
                    .screenTexts[1])
          ]),
        );
      },
    );
  }

  ClipRRect buildListTile(User user, num topScore) {
    var isHighestScore = user.quizScorePerVersion.values
        .reduce((sum, element) => sum + element) ==
        topScore;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        bottomLeft: Radius.circular(32),
      ),
      child: ListTile(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => UserPublicProfile(user)));
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 34,
              minHeight: 34,
              maxWidth: 54,
              maxHeight: 54,
            ),
            child: Container(
              padding: EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Constant.colorOne, Constant.colorTwo],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  image: Constant.users
                      .firstWhere((element) => element.id == user.id)
                      .photoUrl
                      .isNotEmpty
                      ? DecorationImage(
                    image: CachedNetworkImageProvider(Constant.users
                        .firstWhere((element) => element.id == user.id)
                        .photoUrl),
                    fit: BoxFit.cover,
                  )
                      : DecorationImage(
                    image: AssetImage(Constant.defaultUserPic),
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${user.username}',
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts
                          .abel()
                          .fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              isHighestScore
                  ? Expanded(child: Lottie.asset(
                  'assets/trophy.json', height: 70, width: 70))
                  : Container(),
              Stack(children: [
                Image.asset('assets/bowling_pins_fallen.png',
                    height: 85, width: 85),
                Positioned(
                  bottom: 2,
                  left: 20,
                  child: Card(
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.white, width: 1),
                      //rderRadius: BorderRadius.circular(10),
                    ),
                    color: Constant.colorTwo,
                    child: Container(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Text(
                          '${user.quizScorePerVersion.values.reduce((sum,
                              element) => sum + element).toInt().toString()}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
      )
    );
    // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
    // trailing: Icon(Icons.keyboard, color: Colors.white, size: 30.0));
  }
}
