import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LinePathForAnt extends StatefulWidget {
  final List<double> _pathDistance;
  LinePathForAnt(this._pathDistance);
  @override
  _LinePathForAntState createState() => _LinePathForAntState();
}

class _LinePathForAntState extends State<LinePathForAnt> {
  @override
  Widget build(BuildContext context) {
    return Align(
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          color: Colors.grey.withOpacity(0.3),
          padding: EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                '路径值',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  lineData(),
                  swapAnimationDuration: const Duration(milliseconds: 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _barStyle() {
    return GoogleFonts.jua(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 10,
      ),
    );
  }

  LineChartData lineData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => _barStyle(),
          interval: widget._pathDistance.length / 15,
          getTitles: (value) => value.toInt().toString(),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => _barStyle(),
          interval: widget._pathDistance.reduce(max) / 20,
          getTitles: (value) => value.toInt().toString(),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 3),
          left: BorderSide(color: Colors.black, width: 3),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 0,
      maxX: (widget._pathDistance.length - 1).toDouble(),
      minY: 0,
      maxY: widget._pathDistance.reduce(max).toDouble() + 20,
      lineBarsData: linesBarData(),
    );
  }

  List<LineChartBarData> linesBarData() {
    final LineChartBarData lineChartBarData = LineChartBarData(
      spots: List.generate(
        widget._pathDistance.length,
        (i) => FlSpot(
          i.toDouble(),
          double.parse(widget._pathDistance[i].toStringAsFixed(2)),
        ),
      ),
      isCurved: false,
      colors: [Colors.black],
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: true),
    );
    return [lineChartBarData];
  }
}
