import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_chart.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_questions.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_firebase_resources.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_cards.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_event.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

  static Box box = Hive.box('UserNotes');
  static String userNotesBox = 'notesBox';
  static String slidingCardsBox = 'slidingCardsBox';
  static List<bool> levelQuestionsAnswers = [];
  static int totalCorrectAnswersAcrossLevels = 0;

  static const backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [ colorOne, colorTwo],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const COLOR_BLACK = Color.fromRGBO(48, 47, 48, 1.0);
  static const COLOR_GREY = Color.fromRGBO(141, 141, 141, 1.0);
  static const COLOR_WHITE = Colors.white;
  static const COLOR_DARK_BLUE = Color.fromRGBO(20, 25, 45, 1.0);

  static const Color colorOne = Color(0xffe84393);
  static const Color colorTwo = Color(0xff000000);
  static const Color colorFour = Color(0xff993E9D);
  static const Color colorThree = Color(0xff551936);
  static int popupOverlayBackgroundColorIntValue = 0xff000000;
  static int popupOverlayTextColorIntValue = 0xff000000;

  static QuizLevelCollection? quizLevelCollection;
  static ChartData? chartData;
  static List<SlidingCard>? slidingCardsList = [];
  static List<SlidingEvent>? slidingEventsList = [];
  static List<ImageResource> imageResources = [];
  static List<ScreenDynamicText> screenDynamicText = [];
  static List<Identifier> identifiers = [];

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
}