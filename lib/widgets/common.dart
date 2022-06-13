import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/screens/quiz_page.dart';
import 'package:flutter_quiz_app/screens/sign_up_widget.dart';
import 'package:flutter_quiz_app/widgets/progress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/constant.dart';
import '../json_parsers/json_parser_firebase_questions.dart';


class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.title,
    this.topPadding = 0,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: child,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.quiz,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final Quiz quiz;
  final double? extent;
  final Color? backgroundColor;
  final double? bottomSpace;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: new BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.blueAccent, width: 2,),
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: const Radius.circular(20.0),
            bottomRight: const Radius.circular(20.0),
          )
      ),
      // color: backgroundColor ?? _defaultColor,
      height: extent,
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipOval(
                  child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: quiz.quizPictureUrl.isNotEmpty ?
                      quiz.quizPictureUrl : 'https://cdn.pixabay.com/photo/2018/04/02/21/33/gdpr-3285252__340.jpg',
                      // imageBuilder: (context, imageProvider) => Container(
                      //   width: 150.0,
                      //   height: 150.0,
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.rectangle,
                      //     image: DecorationImage(
                      //         image: imageProvider, fit: BoxFit.cover),
                      //   ),
                      // ),
                      placeholder: (context, url) => circularProgress(color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                ),
              ),
            ),
            Text(quiz.quizName, style: const TextStyle(fontSize: 16,
                fontFamily: 'Segoe UI', color: Colors.white))
          ],
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}