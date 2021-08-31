import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';
import 'package:flutter_quiz_app/screens/public_user_profile.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final _firestore = FirebaseFirestore.instance;
  late List<User> userList;
  int topScore = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        userList = snapshot.data != null
            ? List<User>.from(
                snapshot.data!.docs.map((x) => User.fromJson(x.data())))
            : [];

        userList.sort((a, b) => b.quizScore.compareTo(a.quizScore));

        return Scaffold(
          appBar: AppBar(
            title: Text("Leader Board (Quiz v${Constant.screenDynamicText
                .firstWhere((element) => element.screenName == 'QuizVersion')
                .screenTexts[0]})", maxLines: 2, style: TextStyle(fontSize: 18),),
            backgroundColor: Constant.colorThree,
          ),
          body: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: userList.length,
            itemBuilder: (BuildContext context, int index) {
              var userIndex = Constant.users.indexWhere(
                  (element) => element.userId == userList[index].userId);
              if (userIndex == -1)
                Constant.users.add(userList[index]);
              else
                Constant.users[userIndex] = userList[index];

              if (index == 0) topScore = int.parse(userList[index].quizScore);

              return Card(
                elevation: 8.0,
                margin:
                    new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  decoration: Constant.backgroundDecoration,
                  child: buildListTile(
                    userList[index], topScore
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  ClipRRect buildListTile(User user, int topScore) {
    var isHighestScore = int.parse(user.quizScore) == topScore;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        bottomLeft: Radius.circular(32),
      ),
      child: ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => UserPublicProfile(user)));
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        leading: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 44,
            minHeight: 44,
            maxWidth: 64,
            maxHeight: 64,
          ),
          child: Container(
              padding: EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: Constant.users
                          .firstWhere((element) => element.userId == user.userId)
                          .userProfilePicUrl
                          .isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(Constant.users
                              .firstWhere(
                                  (element) => element.userId == user.userId)
                              .userProfilePicUrl),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage(Constant.defaultUserPic),
                          fit: BoxFit.cover,
                        )),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.username}',
                    softWrap: true,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: GoogleFonts.abel().fontFamily, fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    '${user.userDescription}',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                      fontFamily: GoogleFonts.mcLaren().fontFamily, fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  isHighestScore ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AvatarGlow(
                        glowColor: Colors.white,
                        endRadius: 25.0,
                        duration: Duration(milliseconds: 1000),
                        repeat: true,
                        showTwoGlows: true,
                        repeatPauseDuration: Duration(milliseconds: 100),
                        child: Text(
                          '★',
                          softWrap: true,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        'Top Score: ${user.quizScore}',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ) : Text(
                    'Score: ${user.quizScore}',
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ), //Icon
          ],
        ),
      ),
    );
    // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
    // trailing: Icon(Icons.keyboard, color: Colors.white, size: 30.0));
  }
}
