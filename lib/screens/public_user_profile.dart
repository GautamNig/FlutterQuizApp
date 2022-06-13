import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';

class UserPublicProfile extends StatefulWidget {
  final User user;

  UserPublicProfile(this.user);

  @override
  _UserPublicProfileState createState() => _UserPublicProfileState();
}

class _UserPublicProfileState extends State<UserPublicProfile> {
  final _firestore = FirebaseFirestore.instance;
  late User clickedUser;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EasyLoading.init();
    clickedUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlutterEasyLoading(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Constant.colorTwo,
            actions: [],
            title: Text(
              clickedUser.username,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
          ),
          body: Column(
            children: [
              Container(
                  decoration: Constant.backgroundDecoration,
                  child: Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CircleAvatar(
                          backgroundImage:
                              clickedUser.photoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      clickedUser.photoUrl,
                                    )
                                  : (AssetImage(Constant.defaultUserPic)
                                      as ImageProvider),
                          radius: 120.0,
                        ),
                      ),
                    ),
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: Constant.backgroundDecoration,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "This is me :",
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              clickedUser.bio,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
