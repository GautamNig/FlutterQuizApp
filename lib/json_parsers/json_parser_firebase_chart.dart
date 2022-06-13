// To parse this JSON data, do
//
//     final chartData = chartDataFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ChartData chartDataFromJson(String str) => ChartData.fromJson(json.decode(str));

String chartDataToJson(ChartData data) => json.encode(data.toJson());

class ChartData {
  ChartData({
    required this.chartGroupedData,
    required this.chartDynamicText,
  });

  List<ChartGroupedData> chartGroupedData;
  List<String> chartDynamicText;

  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
    chartGroupedData: List<ChartGroupedData>.from(json["ChartGroupedData"].map((x) => ChartGroupedData.fromJson(x))),
    chartDynamicText: List<String>.from(json["ChartDynamicText"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ChartGroupedData": List<dynamic>.from(chartGroupedData.map((x) => x.toJson())),
    "ChartDynamicText": List<dynamic>.from(chartDynamicText.map((x) => x)),
  };
}

class ChartGroupedData {
  ChartGroupedData({
    required this.x,
    required this.y,
    required this.y1,
    required this.y2,
  });

  String x;
  num? y;
  num? y1;
  num? y2;

  factory ChartGroupedData.fromJson(Map<String, dynamic> json) => ChartGroupedData(
    x: json["x"],
    y: json["y"],
    y1: json["y1"],
    y2: json["y2"],
  );

  Map<String, dynamic> toJson() => {
    "x": x,
    "y": y,
    "y1": y1,
    "y2": y2,
  };
}
