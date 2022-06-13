import 'package:flutter/material.dart';
import '../helpers/constant.dart';

AppBar header(context,
    {required String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
     titleText,
      style: Constant.appHeaderTextSTyle,
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Constant.colorTwo,
  );
}
