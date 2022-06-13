import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';

class BorderIcon extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width, height;

  const BorderIcon(
      {Key? key,
        required this.child,
        this.padding,
        this.width,
        this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Constant.COLOR_WHITE,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border: Border.all(color: Constant.COLOR_GREY.withAlpha(40), width: 2)),
        padding: padding ?? const EdgeInsets.all(8.0),
        child: Center(child: child));
  }
}