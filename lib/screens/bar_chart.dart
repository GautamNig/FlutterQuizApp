import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';

import '../widgets/header.dart';

class BarChartGraph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartGraphState();
}

class BarChartGraphState extends State<BarChartGraph> {
  List<GDPRData> gdprDataList = [];

  @override
  void initState() {
    super.initState();
    gdprDataList = Constant.chartData?.chartGroupedData
            .map((e) => GDPRData(e.x, e.y, e.y1, e.y2))
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff2c4260),
        appBar: AppBar(title: Text(Constant.chartData!.chartDynamicText.first,
            style: TextStyle(
          fontFamily: "Signatra",
          fontSize: 25,
          color: Colors.white,
        )), backgroundColor: Constant.colorTwo,),
        body: Container(
          decoration: Constant.backgroundDecoration,
          child: SfCartesianChart(
            legend: Legend(isVisible: true),
            // Columns will be rendered back to back
            enableSideBySideSeriesPlacement: true,
            series: [
              ColumnSeries(
                  spacing: 0.2,
                  width: 0.4,
                  name: Constant.chartData?.chartDynamicText[1],
                  dataSource: gdprDataList,
                  xValueMapper: (GDPRData data, _) => data.x,
                  yValueMapper: (GDPRData data, _) => data.y ?? 0),
              ColumnSeries(
                  opacity: 0.9,
                  width: 0.4,
                  spacing: 0.2,
                  dataSource: gdprDataList,
                  xValueMapper: (GDPRData data, _) => data.x,
                  yValueMapper: (GDPRData data, _) => data.y1 ?? 0),
              ColumnSeries(
                  opacity: 0.9,
                  width: 0.4,
                  spacing: 0.2,
                  dataSource: gdprDataList,
                  xValueMapper: (GDPRData data, _) => data.x,
                  yValueMapper: (GDPRData data, _) => data.y2 ?? 0)
            ],
            primaryXAxis: CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              labelRotation: -30
            ),
            primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(width: 0),
                numberFormat: NumberFormat.compact()),
          ),
        ));
  }
}

class GDPRData {
  GDPRData(this.x, this.y, this.y1, this.y2);

  final String x;
  final num? y;
  final num? y1;
  final num? y2;
}
