import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

import '../json_parsers/json_parser_firebase_questions.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_screen';

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  var uuid = Uuid();
  final _usernameTextEditingController = TextEditingController();
  final _aboutMeTextEditingController = TextEditingController();
  bool _status = true;
  final _firestore = FirebaseFirestore.instance;
  bool isImageUpdated = false;
  String imageDownloadUrl = '';
  String _previousImage = '';
  late User user;
  bool isEditing = false;
  bool isUploadInProgress = false;
  String username = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _usernameTextEditingController.text = currentUser!.username;
    _aboutMeTextEditingController.text =
       currentUser!.bio;

    username = currentUser!.username;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _usernameTextEditingController.dispose();
    _aboutMeTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constant.colorTwo,
            actions: [],
            title: Text(
              'Profile Page',
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
                Container(
                  height: 250.0,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: UserAccountsDrawerHeader(
                          decoration: Constant.backgroundDecoration,
                          accountName:
                          Text(currentUser != null ? currentUser!.username : ''),
                          accountEmail:
                          Text(currentUser != null ? currentUser!.email : ''),
                          currentAccountPicture: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: currentUser != null ? (currentUser!.photoUrl.isNotEmpty
                                  ? FadeInImage(
                                fit: BoxFit.cover,
                                placeholder: AssetImage(
                                  'assets/loading.gif',
                                ),
                                image: NetworkImage(currentUser!.photoUrl),
                              ) : Image.asset(Constant.defaultUserPic)) : Container(),
                            ),
                          ),
                        ),
                      )
                  ),
                ),
                _formUI(),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  ElevatedButton(onPressed: () async {
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
                                await googleSignIn.signOut();
                                setState(() {
                                  isUserSignedIn = false;
                                  currentUser = null;
                                });
                                Navigator.pop(context, 'signout');
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
                  }, child: Text('Sign out')),
                  ElevatedButton(onPressed: () {
                    Alert(
                      context: context,
                      type: AlertType.warning,
                      title: "PURGE USER",
                      desc: "This action will permanently delete all user data stored. Do you wish to continue?",
                      buttons: [
                        DialogButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);

                            EasyLoading.show();

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
                            EasyLoading.dismiss();
                            Navigator.pop(context, 'signout');
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
                  }, child: Text('Delete')),
                ],),
              ],
            ),
          )),
    );
  }

  _formUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: new Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40.0),
            _mobile(),
            SizedBox(height: 12.0),
            _birthDate(),
            SizedBox(height: 12.0),
            _gender(),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
  _mobile() {
    return Row(children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Quizzes taken',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          SizedBox(height: 3),
          currentUser != null ?
          Text(currentUser!.quizScorePerVersion.length.toString()) : Container(),
        ],
      )
    ]);
  }
  _birthDate() {
    return Row(children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Birth date',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          SizedBox(height: 3),
          Text('00-00-0000')
        ],
      )
    ]);
  }
  _gender() {
    return Row(children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Gender',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          SizedBox(height: 3),
          Text('Male')
        ],
      )
    ]);
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
                      EasyLoading.show(status: "Saving...");
                      await onProfilePageSaveClicked();
                      EasyLoading.dismiss();
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
                       currentUser!.username = username;

                        _usernameTextEditingController.text = username;
                        _aboutMeTextEditingController.text = currentUser!.bio;
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
        backgroundColor: Constant.colorOne,
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

  // Future pickImage() async {
  //   //Get the file from the image picker and store it
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       isImageUpdated = true;
  //       _previousImage =currentUser!.userProfilePicUrl.isNotEmpty
  //           ?currentUser!.userProfilePicUrl
  //           : '';
  //     }
  //   });
  // }
  //
  // Future uploadPic() async {
  //   try {
  //     await FirebaseStorage.instance
  //         .ref('user_images')
  //         .child(Uuid().v1())
  //         .putFile(_image)
  //         .then((value) async {
  //       imageDownloadUrl = await value.ref.getDownloadURL();
  //     });
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }

  Future updateUserInfo(bool newImage) async {
    print('User id is : ${currentUser!.id}');
    await _firestore
        .collection('users')
        .doc(currentUser!.id)
        .update({'bio': _aboutMeTextEditingController.text});
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  Future onProfilePageSaveClicked() async {
    await EasyLoading.show();
    // if (isImageUpdated) {
    //   await uploadPic().then((value) async {
    //     while (imageDownloadUrl.isEmpty) {
    //       await Future.delayed(Duration(milliseconds: 300));
    //     }
    //     await updateUserInfo(true);
    //     isImageUpdated = false;
    //     if (_previousImage.isNotEmpty)
    //       await FirebaseStorage.instance.refFromURL(_previousImage).delete();
    //     cacheImage(context,currentUser!.userProfilePicUrl);
    //     _previousImage = '';
    //   });
    // } else
    await updateUserInfo(false);

    setState(() {
      _status = true;
      FocusScope.of(context).requestFocus(FocusNode());
    });
    await EasyLoading.dismiss();
  }
}
