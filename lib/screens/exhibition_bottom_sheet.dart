import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:url_launcher/url_launcher.dart';

const double minHeight = 120;
const double iconStartSize = 44;
const double iconEndSize = 120;
const double iconStartMarginTop = 36;
const double iconEndMarginTop = 80;
const double iconsVerticalSpacing = 24;
const double iconsHorizontalSpacing = 16;

class ExhibitionBottomSheet extends StatefulWidget {
  @override
  _ExhibitionBottomSheetState createState() => _ExhibitionBottomSheetState();
}

class _ExhibitionBottomSheetState extends State<ExhibitionBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get maxHeight => MediaQuery.of(context).size.height;

  double get headerTopMargin =>
      lerp(20, 20 + MediaQuery.of(context).padding.top);

  double get headerFontSize => lerp(14, 24);

  double get itemBorderRadius => lerp(8, 24);

  double get iconLeftBorderRadius => itemBorderRadius;

  double get iconRightBorderRadius => lerp(8, 0);

  double get iconSize => lerp(iconStartSize, iconEndSize);

  double iconTopMargin(int index) =>
      lerp(iconStartMarginTop,
          iconEndMarginTop + index * (iconsVerticalSpacing + iconEndSize)) +
          headerTopMargin;

  double iconLeftMargin(int index) =>
      lerp(index * (iconsHorizontalSpacing + iconStartSize), 0);

  @override
  void initState() {
    super.initState();
    Constant.slidingEventsList!.forEach((element) {
      if (events.length < Constant.slidingEventsList!.length)
        events.add(Event(element.picUrl, element.name, element.topText,
            element.bottomText, element.date));
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value) ?? 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeight, maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onDoubleTap: _toggle,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Constant.colorTwo, Constant.colorOne],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  // MenuButton(),
                  SheetHeader(
                    fontSize: headerFontSize,
                    topMargin: headerTopMargin,
                  ),
                  for (Event event in events) _buildFullItem(event),
                  for (Event event in events) _buildIcon(event),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(Event event) {
    int index = events.indexOf(event);
    String imgPath = "";
    switch(event.title){
      case 'Name 1': imgPath='assets/Part1.png';
      break;
      case 'Name 2': imgPath='assets/Part2.png';
      break;
      case 'Name 3': imgPath='assets/Youtube_icon.png';
      break;
    }
    return Positioned(
      height: iconSize,
      width: iconSize,
      top: iconTopMargin(index),
      left: iconLeftMargin(index),
      child: ClipRRect(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(iconLeftBorderRadius),
            right: Radius.circular(iconRightBorderRadius),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            alignment: Alignment(lerp(1, 0), 0),
            decoration: BoxDecoration(
              image:  event.picUrl.isEmpty ? DecorationImage(
                image:  AssetImage(imgPath),
                fit: BoxFit.cover,
              ) : DecorationImage(
                image: CachedNetworkImageProvider(event.picUrl),
                fit: BoxFit.cover,
              ),
            ),
          )),
    );
  }

  Widget _buildFullItem(Event event) {
    int index = events.indexOf(event);
    return ExpandedEventItem(
      topMargin: iconTopMargin(index),
      leftMargin: iconLeftMargin(index),
      height: iconSize,
      isVisible: _controller.status == AnimationStatus.completed,
      borderRadius: itemBorderRadius,
      title: event.title,
      topText: event.topText,
      bottomText: event.bottomText,
      date: event.date,
    );
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(velocity: isOpen ? -2 : 2);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }
}

class ExpandedEventItem extends StatelessWidget {
  final double topMargin;
  final double leftMargin;
  final double height;
  final bool isVisible;
  final double borderRadius;
  final String title;
  final String date;
  final String topText;
  final String bottomText;

  const ExpandedEventItem(
      {Key? key,
        required this.topMargin,
        required this.height,
        required this.isVisible,
        required this.borderRadius,
        required this.title,
        required this.date,
        required this.topText,
        required this.bottomText,
        required this.leftMargin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topMargin,
      left: leftMargin,
      right: 0,
      height: height,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
          ),
          padding: EdgeInsets.only(left: height).add(EdgeInsets.all(8)),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   title,
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //   maxLines: 5,
          // ),
          // SizedBox(height: 8),
          Wrap(
            children: <Widget>[
              Text(
                topText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Constant.colorTwo
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                date,
                maxLines: 5,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.black45,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.place, color: Colors.blueAccent, size: 16),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: bottomText,
                        style: TextStyle(color: Colors.blueAccent),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () { launch(bottomText);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded(child: Text(bottomText, style: TextStyle(color: Colors.grey),))
            ],
          )
        ],
      ),
    );
  }
}

final List<Event> events = [];

class Event {
  final String picUrl;
  final String title;
  final String topText;
  final String bottomText;
  final String date;

  Event(this.picUrl,
      this.title,
      this.topText,
      this.bottomText, this.date);
}

class SheetHeader extends StatelessWidget {
  final double fontSize;
  final double topMargin;

  const SheetHeader({Key? key, required this.fontSize, required this.topMargin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topMargin,
      child: Text(
        Constant.screenDynamicText
            .where((element) => element.screenName == "SlidingEventsPage")
            .first
            .screenTexts[0],
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 24,
      child: Icon(
        Icons.menu,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
