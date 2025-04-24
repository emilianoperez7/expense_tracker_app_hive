import 'package:expense_tracker_app_hive/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; // (25,500,1000)
  final int startMonth; // 0=ENE 1=FEB 2=MAR 3=ABR 4=MAY 5=JUN 6=JUL 7=AUG 8=SEP 9=OCT 10=NOV 11=DIC
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  //this list will hold the data of each bar
  List<IndividualBar> barData = [];
  //initialize bar data - user our monthly summary to create a list of bars
  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length, (index) => IndividualBar(x: index, y: widget.monthlySummary[index]));
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
      ));
  }
}
