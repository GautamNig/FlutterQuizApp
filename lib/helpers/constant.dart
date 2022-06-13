import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/extension_methods.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_chart.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_resources.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_user.dart' as userJson;
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_cards.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_event.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../screens/quiz_page.dart';
import '../screens/sign_up_widget.dart';

enum IdentifierNameEnum {
  appIdAndroid,

  testAdUnitIdAndroid,
  testInterstitialAdUnitIdAndroid,

  bannerAdUnitIdAndroid1,
  bannerAdUnitIdAndroid2,
  interstitialAdUnitIdAndroid,

  testAdUnitIdiOS,

  adUnitIdiOS,
}
class Constant{
  static InterstitialAd? interstitialAd;
  static final _firestore = FirebaseFirestore.instance;
  static Quiz quiz = newQuiz;
  static List<userJson.User> users = [];
  static String defaultUserPic = 'assets/icon.png';
  static String userIdBox = 'userIdBox';
  static String userScoreBox = 'userScoreBox';
  static Box box = Hive.box('UserNotes');
  static String userNotesBox = 'notesBox';
  static String slidingCardsBox = 'slidingCardsBox';
  static List<bool> levelQuestionsAnswers = [];
  static int totalCorrectAnswersAcrossLevels = 0;

  static bool hasPopupBeenShownForThisQuizAttempt = false;
  static bool isBusy = false;
  static List<String> quizCategories = ['Beginners', 'Intermediate', 'Advance'];
  static Quiz newQuiz = Quiz(
      quizId: '',
      quizCategory: '',
      quizLevels: [],
      quizPassword: '',
      quizUsers: [],
      quizExpiryDateTime: DateTime.now().toUtc().add(Duration(days: 300)),
      quizCreationDateTime: DateTime.now().toUtc(),
      quizCreatedByUserId: currentUser!.id,
      quizCreatedByUsername: currentUser!.username,
      quizName: '',
      quizPictureUrl: '',
      quizDescription: '',
      quizNumber: 1,
      isQuiz: true,
      isCooking: false);

  static const backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [colorTwo, colorOne,],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static InputDecoration getTextFormFieldInputDecoration(String hintText) =>
      InputDecoration(
        hintText: hintText,
        hintStyle:
        const TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 50,
            style: BorderStyle.solid,
          ),
        ),
        filled: true,
        contentPadding: const EdgeInsets.all(16),);

  static const COLOR_BLACK = Color.fromRGBO(48, 47, 48, 1.0);
  static const COLOR_GREY = Color.fromRGBO(141, 141, 141, 1.0);
  static const COLOR_WHITE = Colors.white;
  static const COLOR_DARK_BLUE = Color.fromRGBO(20, 25, 45, 1.0);

  static const Color colorOne = Color(0xffe84393);
  static const Color colorTwo = Color(0xff000000);
  static const Color colorIcon = Color(0xff993E9D);
  static const Color colorThree = Color(0xff551936);
  static int popupOverlayBackgroundColorIntValue = 0xff000000;
  static int popupOverlayTextColorIntValue = 0xff000000;

  static Quiz? quizLevelCollection;
  static ChartData? chartData;
  static List<SlidingCard>? slidingCardsList = [];
  static List<SlidingEvent>? slidingEventsList = [];
  static List<ImageResource> imageResources = [];
  static List<ScreenDynamicText> screenDynamicText = [];
  static List<Identifier> identifiers = [];

  static const TextStyle appHeaderTextSTyle = TextStyle(
    fontFamily: "Signatra",
    fontSize: 30,
    color: Colors.white,
  );

  static AlertStyle alertSTyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontFamily: GoogleFonts
            .comicNeue()
            .fontFamily,
        fontWeight: FontWeight.bold),
  );

  static bool showProgress = false;

  static Future showAlert(BuildContext context, String title,
      Widget contentWidget) async {
    await Alert(
        context: context,
        style: alertSTyle,
        title: title,
        content: contentWidget,
        buttons: [
          DialogButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              })
        ]).show();
  }

  static GoogleSignIn googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: "50923198394-ji1k72icn7ebvhi3ap72pd2d3tihnt3s.apps.googleusercontent.com",
    // scopes: <String>[
    //   'email',
    //   'https://www.googleapis.com/auth/contacts.readonly',
    // ],
  );
  static GoogleSignInAccount? loggedInGoogleUser;

  static Future loadAppAds() async {
    if(banner1 == null || banner1IsLoaded == false){
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

      banner1IsLoaded = true;
    }
    if(banner2 == null || banner2IsLoaded == false){
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

      banner2IsLoaded = true;
    }

    await InterstitialAd.load(
        adUnitId: Constant.identifiers
            .firstWhere((element) =>
        element.identifierName ==
            IdentifierNameEnum.interstitialAdUnitIdAndroid.toShortString)
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

  static Align createAttributionAlignWidget(String text, String hyperlink,
      {AlignmentGeometry alignmentGeometry = Alignment.bottomRight,
        Color color = Colors.white}) {
    return Align(
      alignment: alignmentGeometry,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text,
                style: TextStyle(color: color, fontSize: 9),
                recognizer: TapGestureRecognizer()
                  ..onTap = () { launchUrlString(hyperlink);
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}