import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_quiz_app/helpers/Constants.dart';

class BarChartGraph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartGraphState();
}

class BarChartGraphState extends State<BarChartGraph> {
  final Color leftBarColor = Color(0xff5d8aa8);
  final Color rightBarColor= Color(0xff8db600);
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    List<BarChartGroupData> items = [];

    Constant.chartData!.chartGroupedData.forEach((element) {
      items.add(makeGroupData(
        element.number,
        element.value1,
        element.value2
      ));
    });

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.colorTwo,
      appBar: AppBar(backgroundColor: Constant.colorThree,),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Constant.colorOne, Constant.colorTwo],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  makeTransactionsIcon(),
                  const SizedBox(
                    width: 38,
                  ),
                  Text(
                    Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "Heading1").tagTexts.first,
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 80),
              child: Text(
                Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "Heading2").tagTexts.first,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: BarChart(
                  BarChartData(
                    maxY: 20,
                    barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black,
                          getTooltipItem: (_a, _b, _c, _d) => null,
                        ),
                        touchCallback: (response) {
                          if (response.spot == null) {
                            setState(() {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            });
                            return;
                          }

                          touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                          setState(() {
                            if (response.touchInput is PointerExitEvent ||
                                response.touchInput is PointerUpEvent) {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            } else {
                              showingBarGroups = List.of(rawBarGroups);
                              if (touchedGroupIndex != -1) {
                                var sum = 0.0;
                                for (var rod in showingBarGroups[touchedGroupIndex].barRods) {
                                  sum += rod.y;
                                }
                                final avg =
                                    sum / showingBarGroups[touchedGroupIndex].barRods.length;

                                showingBarGroups[touchedGroupIndex] =
                                    showingBarGroups[touchedGroupIndex].copyWith(
                                      barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                                        return rod.copyWith(y: avg);
                                      }).toList(),
                                    );
                              }
                            }
                          });
                        }),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        // getTextStyles: (value) => const TextStyle(color: Color(
                        //     0xff7589a2), fontWeight: FontWeight.bold, fontSize: 10),
                        margin: 20,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[0];
                            case 1:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[1];
                            case 2:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[2];
                            case 3:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[3];
                            case 4:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[4];
                            case 5:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[5];
                            case 6:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[6];
                            case 7:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[7];
                            case 8:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[8];
                            case 9:
                              return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "HorizontalTags").tagTexts[9];
                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(
                        showTitles: true,
                        // getTextStyles: (value) => const TextStyle(
                        //     color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
                        margin: 32,
                        reservedSize: 14,
                        getTitles: (value) {
                          if (value == 0) {
                            return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "VerticalTags").tagTexts[0];
                          } else if (value == 10) {
                            return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "VerticalTags").tagTexts[1];
                          } else if (value == 19) {
                            return Constant.chartData!.chartDynamicText.firstWhere((element) => element.tagName == "VerticalTags").tagTexts[2];
                          } else {
                            return '';
                          }
                        },
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: showingBarGroups,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData   makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: [leftBarColor],
        width: width,
      ),
      BarChartRodData(
        y: y2,
        colors: [rightBarColor],
        width: width,
      ),
    ]);
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}