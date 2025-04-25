import 'package:expense_tracker_app_hive/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; // (25,500,1000)
  final int
      startMonth; // 0=ENE 1=FEB 2=MAR 3=ABR 4=MAY 5=JUN 6=JUL 7=AUG 8=SEP 9=OCT 10=NOV 11=DIC
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  //this list will hold the data of each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();
    //scroll to the end of the graph/last month
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  //initialize bar data - user our monthly summary to create a list of bars
  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length,
        (index) => IndividualBar(x: index, y: widget.monthlySummary[index]));
  }

  //calculate max for upper limit of graph
  double calculateMax() {
    double max = 500;
    max = widget.monthlySummary.last * 1.05; // Aquí guardas el resultado
    if (max < 500) {
      return 500;
    }
    return max;
  }

  //scroll controller to make sure it controlls the end of graph
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    //initalize the bar data
    initializeBarData();
    //bar dimensions sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
        ),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(BarChartData(
            minY: 0,
            maxY: calculateMax(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBottomTitles,
                reservedSize: 24,
              )),
            ),
            barGroups: barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.x,
                    barRods: [
                      BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade800,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculateMax(),
                            color: Colors.grey.shade100,
                          )),
                    ],
                  ),
                )
                .toList(),
            alignment: BarChartAlignment.center,
            groupsSpace: spaceBetweenBars,
          )),
        ),
      ),
    );
  }
}

//this function will return the bottom titles
Widget getBottomTitles(double value, TitleMeta meta) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = "ENE";
      break;
    case 1:
      text = "FEB";
      break;
    case 2:
      text = "MAR";
      break;
    case 3:
      text = "ABR";
      break;
    case 4:
      text = "MAY";
      break;
    case 5:
      text = "JUN";
      break;
    case 6:
      text = "JUL";
      break;
    case 7:
      text = "AGO";
      break;
    case 8:
      text = "SEP";
      break;
    case 9:
      text = "OCT";
      break;
    case 10:
      text = "NOV";
      break;
    case 11:
      text = "DIC";
      break;
    default:
      text = "";
      break;
  }

  return SideTitleWidget(
    meta: meta,
    child: Text(
      text,
      style: textstyle,
    ),
  );
}
