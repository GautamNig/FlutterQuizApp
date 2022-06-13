import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:lottie/lottie.dart' as lot;

class PopupOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;
  AudioCache audioCache = AudioCache();
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    audioCache.play('strike.mp3', mode: PlayerMode.LOW_LATENCY);
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.canvas,
      color: Color(Constant.popupOverlayBackgroundColorIntValue),
      //type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      decoration: Constant.backgroundDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: lot.Lottie.network(Constant.imageResources
                  .firstWhere((element) => element.name == 'PopupOverlay')
                  .url),
            ),
          ),
          SizedBox(
            height: 22,
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              'You got all correct answers for this level.',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color(Constant.popupOverlayTextColorIntValue)),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              primary: Constant.colorThree,
              side: BorderSide(
                width: 1.0,
                color: Colors.white,
              ),
            ),
            child: Text('Great Job!'),
          ),
          Constant.createAttributionAlignWidget(
              Constant.screenDynamicText
                  .firstWhere((element) => element.screenName == 'PopupOverlay')
                  .screenTexts[0],
              Constant.screenDynamicText
                  .firstWhere((element) => element.screenName == 'PopupOverlay')
                  .screenTexts[1])
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
