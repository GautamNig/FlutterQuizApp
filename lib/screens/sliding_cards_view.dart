import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'details_page.dart';

class SlidingCardsView extends StatefulWidget {
  @override
  _SlidingCardsViewState createState() => _SlidingCardsViewState();
}

class _SlidingCardsViewState extends State<SlidingCardsView> {
  late PageController pageController;
  double? pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      setState(() => pageOffset = pageController!.page);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: PageView(
        controller: pageController,
        children: getSlidingCardsList(Constant.interstitialAd),
      ),
    );
  }

  List<Widget> getSlidingCardsList(InterstitialAd? interstitialAd) {
    List<SlidingCard> slidingCards = [];
    int counter = 0;
    Constant.slidingCardsList!.forEach((element) {
      var offset = pageOffset! - 1;
      slidingCards.add(SlidingCard(
          name: element.name,
          description: element.description,
          cardRating: element.cardRating,
          assetName: element.picUrl,
          offset: offset,
          interstitialAd: interstitialAd,
          counter: counter));
      counter++;
    });

    return slidingCards;
  }
}

class SlidingCard extends StatelessWidget {
  final String name;
  final String description;
  final String cardRating;
  final String assetName;
  final double offset;
  final InterstitialAd? interstitialAd;
  final int counter;

  const SlidingCard({
    Key? key,
    required this.name,
    required this.description,
    required this.cardRating,
    required this.assetName,
    required this.offset,
    this.interstitialAd,
    required this.counter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double gauss = math.exp(-(math.pow((offset.abs() - 0.5), 2) / 0.08));
    return Transform.translate(
      offset: Offset(-32 * gauss * offset.sign, 0),
      child: Card(
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 24),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment(-offset.abs(), 0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(assetName),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: CardContent(
                  name: name,
                  description: description,
                  cardRating: cardRating,
                  picUrl: assetName,
                  offset: gauss,
                  interstitialAd: interstitialAd,
                  counter: counter),
            ),
          ],
        ),
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  final String name;
  final String description;
  final String cardRating;
  final String picUrl;
  final double offset;
  final InterstitialAd? interstitialAd;
  final int counter;

  const CardContent(
      {Key? key,
      required this.name,
      required this.description,
      required this.cardRating,
      required this.picUrl,
      required this.offset,
      this.interstitialAd,
      required this.counter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Transform.translate(
            offset: Offset(8 * offset, 0),
            child: Text(
              name,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 8),
          Transform.translate(
            offset: Offset(32 * offset, 0),
            child: Text(
              description,
              maxLines: 3,
              style: TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          Row(
            children: <Widget>[
              Transform.translate(
                offset: Offset(48 * offset, 0),
                child: ElevatedButton(
                  child: Transform.translate(
                    offset: Offset(24 * offset, 0),
                    child: Text('Know more'),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Constant.colorThree),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (interstitialAd != null) interstitialAd!.show();

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => DetailsPage(
                            slidingCard: Constant.slidingCardsList!
                                .firstWhere((element) => element.name == name)),
                        transitionsBuilder: (c, anim, a2, child) =>
                            ScaleTransition(
                                scale: anim,
                                alignment: Alignment.topLeft,
                                child: child),
                        transitionDuration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
              ),
              Spacer(),
              Transform.translate(
                offset: Offset(32 * offset, 0),
                child: Text(cardRating,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
          )
        ],
      ),
    );
  }
}
