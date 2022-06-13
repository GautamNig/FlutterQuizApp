import 'package:flutter/material.dart';
import '../helpers/constant.dart';

Container circularProgress({Color color = Colors.white}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}

Container linearProgress({Color color = Colors.white}) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}
