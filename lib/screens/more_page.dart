import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:flutter_quiz_app/screens/bar_chart.dart';
import 'package:flutter_quiz_app/screens/poll_page.dart';
import 'package:flutter_quiz_app/screens/sliding_cards_view.dart';

import 'exhibition_bottom_sheet.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_outlined),
            onPressed: () {
              // interstitialAd.show();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarChartGraph()));
            },
          ),
        ],
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Read More'),
            ],
          ),
        ),
        backgroundColor: Constant.colorThree,
      ),
      body: Container(
        decoration: Constant.backgroundDecoration,
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Header(),
                  SizedBox(height: 40),
                  SizedBox(height: 8),
                  SlidingCardsView(),
                ],
              ),
            ),
            ExhibitionBottomSheet(), //use this or ScrollableExhibitionSheet
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        Constant.screenDynamicText.where((element) => element.screenName == "MorePage").first.screenTexts[0],
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}