import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/widgets/progress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../json_parsers/json_parser_firebase_user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
User? currentUser;
bool isUserSignedIn = false;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isAuth = false;

  @override
  initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {});

    // Re-authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {});
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      await createUserInFirestore();
      if (this.mounted) setState(() {
        isAuth = true;
        Navigator.pop(context);
      });
    } else {
      if (this.mounted) setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user?.id).get();

    if (!doc.exists) {
      // final username = await Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.doc(user?.id).set({
        "id": user?.id,
        "email": user?.email,
        "username": user?.displayName,
        "photoUrl": user?.photoUrl,
        "displayName": user?.displayName,
        "bio": "",
        "quizScorePerVersion": {},
        "lastQuizTakenTime": DateTime.now(),
        "joiningDateTime": DateTime.now(),
      });
      doc = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(doc);
    if (mounted) cacheImage(context, currentUser!.photoUrl);
  }

  static Future cacheImage(BuildContext context, String urlImage) {
    if (urlImage.isNotEmpty)
      return precacheImage(CachedNetworkImageProvider(urlImage), context);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? circularProgress() : buildUnAuthScreen();
  }

  buildUnAuthScreen() {
    return FlutterEasyLoading(
      child: SafeArea(
        child: Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, false);
              return false;
            },
            child: Container(
              decoration: Constant.backgroundDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 42.0),
                    child: Image.asset('assets/Quiz_old.png'),
                  ),
                  SizedBox(width: 200, child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       FaIcon(FontAwesomeIcons.google, size:20 ),
                       Text('  Sign in with Google'),
                     ],
                     ),
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                        primary: Constant.colorThree,
                        side: BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        )),
                  ),),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Later'),
                      style: ElevatedButton.styleFrom(
                          primary: Constant.colorThree,
                          side: BorderSide(
                            width: 1.0,
                            color: Colors.white,
                          )),
                    )
                    ,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    EasyLoading.show();
    await googleSignIn.signIn().then((result) {}).catchError((err) {});
    EasyLoading.dismiss();
  }

  logout() {
    googleSignIn.signOut();
  }
}
