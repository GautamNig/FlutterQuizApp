// To parse this JSON data, do
//
//     final resources = resourcesFromJson(jsonString);

import 'dart:convert';

Resources resourcesFromJson(String str) => Resources.fromJson(json.decode(str));

String resourcesToJson(Resources data) => json.encode(data.toJson());

class Resources {
  Resources({
    required this.screenDynamicTexts,
    required this.identifiers,
    required this.imageResources,
    required this.developerMessages,
  });

  List<ScreenDynamicText> screenDynamicTexts;
  List<Identifier> identifiers;
  List<ImageResource> imageResources;
  List<String>? developerMessages;

  factory Resources.fromJson(Map<String, dynamic> json) => Resources(
    screenDynamicTexts: List<ScreenDynamicText>.from(json["ScreenDynamicTexts"].map((x) => ScreenDynamicText.fromJson(x))),
    identifiers: List<Identifier>.from(json["Identifiers"].map((x) => Identifier.fromJson(x))),
    imageResources: List<ImageResource>.from(json["ImageResources"].map((x) => ImageResource.fromJson(x))),
      developerMessages: json['DeveloperMessages'].cast<String>()
  );

  Map<String, dynamic> toJson() => {
    "ScreenDynamicTexts": List<dynamic>.from(screenDynamicTexts.map((x) => x.toJson())),
    "Identifiers": List<dynamic>.from(identifiers.map((x) => x.toJson())),
    "ImageResources": List<dynamic>.from(imageResources.map((x) => x.toJson())),
  };
}

class Identifier {
  Identifier({
    required this.identifierValue,
    required this.identifierName,
  });

  String identifierValue;
  String identifierName;

  factory Identifier.fromJson(Map<String, dynamic> json) => Identifier(
    identifierValue: json["IdentifierValue"],
    identifierName: json["IdentifierName"],
  );

  Map<String, dynamic> toJson() => {
    "IdentifierValue": identifierValue,
    "IdentifierName": identifierName,
  };
}

class ImageResource {
  ImageResource({
    required this.url,
    required this.name,
  });

  String url;
  String name;

  factory ImageResource.fromJson(Map<String, dynamic> json) => ImageResource(
    url: json["Url"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Url": url,
    "Name": name,
  };
}

class ScreenDynamicText {
  ScreenDynamicText({
    required this.screenName,
    required this.screenTexts,
    required this.fontSize,
  });

  String screenName;
  List<String> screenTexts;
  num fontSize;

  factory ScreenDynamicText.fromJson(Map<String, dynamic> json) => ScreenDynamicText(
    screenName: json["ScreenName"],
    fontSize: json["FontSize"],
    screenTexts: List<String>.from(json["ScreenTexts"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ScreenName": screenName,
    "FontSize": fontSize,
    "ScreenTexts": List<dynamic>.from(screenTexts.map((x) => x)),
  };
}
