// To parse this JSON data, do
//
//     final CardsCollection = CardsCollectionFromJson(jsonString);

import 'dart:convert';

CardsCollection cardsCollectionFromJson(String str) => CardsCollection.fromJson(json.decode(str));

String cardsCollectionToJson(CardsCollection data) => json.encode(data.toJson());

class CardsCollection {
  CardsCollection({
    required this.slidingCards,
  });

  List<SlidingCard> slidingCards;

  factory CardsCollection.fromJson(Map<String, dynamic> json) => CardsCollection(
    slidingCards: List<SlidingCard>.from(json["SlidingCards"].map((x) => SlidingCard.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "SlidingCards": List<dynamic>.from(slidingCards.map((x) => x.toJson())),
  };
}

class SlidingCard {
  SlidingCard({
    required this.name,
    required this.description,
    required this.cardRating,
    required this.picUrl,
    required this.link,
    required this.informationTiles,
  });

  String name;
  String description;
  String cardRating;
  String picUrl;
  String link;
  List<InformationTile> informationTiles;

  factory SlidingCard.fromJson(Map<String, dynamic> json) => SlidingCard(
      name: json["Name"],
      description: json["Date"],
      cardRating: json["CardRating"],
      picUrl: json["PicUrl"],
      link: json["Link"],
      informationTiles: json["InformationTiles"] != null ? List<InformationTile>.from(json["InformationTiles"].map((x) => InformationTile.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Date": description,
    "CardRating": cardRating,
    "PicUrl": picUrl,
    "Link": link,
    "InformationTiles": List<dynamic>.from(informationTiles.map((x) => x.toJson())),
  };
}

class InformationTile{
  String name;
  String content;

  InformationTile({ required this.name, required this.content});

  factory InformationTile.fromJson(Map<String, dynamic> json) => InformationTile(
    name: json["Name"],
    content: json["Content"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Content": content,
  };
}
