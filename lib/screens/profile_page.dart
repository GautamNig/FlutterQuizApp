import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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
  File _image = File('');
  final picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;
  bool isImageUpdated = false;
  String imageDownloadUrl = '';
  String _previousImage = '';
  late User user;
  bool isEditing = false;
  bool isUploadInProgress = false;
  String username = '';
  String aboutMe = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EasyLoading.init();

    _usernameTextEditingController.text = Constant.userProfileData.username;
    _aboutMeTextEditingController.text =
        Constant.userProfileData.userDescription;

    username = Constant.userProfileData.username;
    aboutMe = Constant.userProfileData.userDescription;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Constant.colorOne,
              actions: [],
              title: Text(
                Constant.userProfileData.username,
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
                                    child: Text('MY PROFILE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                            fontFamily: 'sans-serif-light',
                                            color: Colors.black)),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child:
                                  Stack(fit: StackFit.loose, children: <Widget>[
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
                                                    .userProfileData
                                                    .userProfilePicUrl
                                                    .isNotEmpty
                                                ? DecorationImage(
                                                    image: CachedNetworkImageProvider(
                                                        Constant.userProfileData
                                                            .userProfilePicUrl),
                                                    fit: BoxFit.cover,
                                                  )
                                                : DecorationImage(
                                                    image: AssetImage(Constant
                                                        .defaultUserPic),
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
                                    padding: EdgeInsets.only(
                                        top: 120.0, left: 100.0),
                                    child: InkWell(
                                      onTap: () async {
                                        await pickImage();
                                        setState(() {
                                          _status = false;
                                        });
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Constant.colorOne,
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
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Username',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
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
                                      child: TextField(
                                        onEditingComplete: () {
                                          Constant.userProfileData.username =
                                              _usernameTextEditingController
                                                  .text;
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        controller:
                                            _usernameTextEditingController,
                                        decoration: const InputDecoration(
                                          hintText:
                                              "Enter your real or friendly name",
                                        ),
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
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'About me',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
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
                                      child: TextField(
                                        controller:
                                            _aboutMeTextEditingController,
                                        onEditingComplete: () {
                                          Constant.userProfileData
                                                  .userDescription =
                                              _aboutMeTextEditingController
                                                  .text;
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Say something about yourself"),
                                        enabled: !_status,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              !_status ? _getActionButtons() : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _usernameTextEditingController.dispose();
    _aboutMeTextEditingController.dispose();
    super.dispose();
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
                      await onProfilePageSaveClicked();
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
                    Constant.userProfileData.username = username;
                    Constant.userProfileData.userDescription = aboutMe;

                    _usernameTextEditingController.text = username;
                    _aboutMeTextEditingController.text = aboutMe;
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

  Future pickImage() async {
    //Get the file from the image picker and store it
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        isImageUpdated = true;
        _previousImage = Constant.userProfileData.userProfilePicUrl.isNotEmpty
            ? Constant.userProfileData.userProfilePicUrl
            : '';
      }
    });
  }

  Future uploadPic() async {
    try {
      await FirebaseStorage.instance
          .ref('user_images')
          .child(Uuid().v1())
          .putFile(_image)
          .then((value) async {
        imageDownloadUrl = await value.ref.getDownloadURL();
      });
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future updateUserInfo(bool newImage) async {
    User userToUpdate = User(
      userId: Constant.userProfileData.userId,
      username: _usernameTextEditingController.text,
      userDescription: _aboutMeTextEditingController.text,
      quizScore: Constant.userProfileData.quizScore,
      userProfilePicUrl: newImage
          ? imageDownloadUrl
          : Constant.userProfileData.userProfilePicUrl,
      joiningDate: Constant.userProfileData.joiningDate,
    );
    await _firestore
        .collection('users')
        .doc(Constant.box.get(Constant.userIdBox))
        .set(userToUpdate.toJson(), SetOptions(merge: true));

    Constant.userProfileData = userToUpdate;
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  Future onProfilePageSaveClicked() async {
    await EasyLoading.show(status: 'Saving..');
    if (isImageUpdated) {
      await uploadPic().then((value) async {
        while (imageDownloadUrl.isEmpty) {
          await Future.delayed(Duration(milliseconds: 300));
        }
        await updateUserInfo(true);
        isImageUpdated = false;
        if (_previousImage.isNotEmpty)
          await FirebaseStorage.instance.refFromURL(_previousImage).delete();
        cacheImage(context, Constant.userProfileData.userProfilePicUrl);
        _previousImage = '';
      });
    } else
      await updateUserInfo(false);

    setState(() {
      _status = true;
      FocusScope.of(context).requestFocus(FocusNode());
    });
    await EasyLoading.dismiss();
  }
}
