// To parse this JSON data, do
//
//     final chartData = chartDataFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ChartData chartDataFromJson(String str) => ChartData.fromJson(json.decode(str));

String chartDataToJson(ChartData data) => json.encode(data.toJson());

class ChartData {
  ChartData({
    required this.chartDynamicText,
    required this.chartGroupedData,
  });

  List<ChartDynamicText> chartDynamicText;
  List<ChartGroupedData> chartGroupedData;

  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
    chartDynamicText: List<ChartDynamicText>.from(json["ChartDynamicText"].map((x) => ChartDynamicText.fromJson(x))),
    chartGroupedData: List<ChartGroupedData>.from(json["ChartGroupedData"].map((x) => ChartGroupedData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ChartDynamicText": List<dynamic>.from(chartDynamicText.map((x) => x.toJson())),
    "ChartGroupedData": List<dynamic>.from(chartGroupedData.map((x) => x.toJson())),
  };
}

class ChartDynamicText {
  ChartDynamicText({
    required this.tagName,
    required this.tagTexts,
  });

  String tagName;
  List<String> tagTexts;

  factory ChartDynamicText.fromJson(Map<String, dynamic> json) => ChartDynamicText(
    tagName: json["TagName"],
    tagTexts: List<String>.from(json["TagTexts"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "TagName": tagName,
    "TagTexts": List<dynamic>.from(tagTexts.map((x) => x)),
  };
}

class ChartGroupedData {
  ChartGroupedData({
    required this.number,
    required this.value2,
    required this.value1,
  });

  int number;
  double value2;
  double value1;

  factory ChartGroupedData.fromJson(Map<String, dynamic> json) => ChartGroupedData(
    number: json["number"],
    value2: json["value2"],
    value1: json["value1"],
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "value2": value2,
    "value1": value1,
  };
}
