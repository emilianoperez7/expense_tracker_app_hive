import 'package:expense_tracker_app_hive/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  final int startYear;
  final void Function(int)? onBarTap;
  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
    required this.startYear,
    this.onBarTap,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeBarData();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());
  }

  @override
  void didUpdateWidget(MyBarGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthlySummary != widget.monthlySummary) {
      initializeBarData();
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());
    }
  }

  void initializeBarData() {
    if (widget.monthlySummary.isEmpty) {
      // Si no hay datos, creamos 1 barra vacía
      barData = [IndividualBar(x: 0, y: 0)];
    } else {
      barData = List.generate(
        widget.monthlySummary.length,
        (index) => IndividualBar(x: index, y: widget.monthlySummary[index]),
      );
    }
  }

  double calculateMax() {
    if (widget.monthlySummary.isEmpty) {
      return 500; // Evitar error si la lista está vacía
    }
    List<double> sortedSummary = List.from(widget.monthlySummary)..sort();
    double max = sortedSummary.last * 1.05;
    return max < 500 ? 500 : max;
  }

  void scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();
    double barWidth = 20;
    double spaceBetweenBars = 70;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          // ancho mínimo para que no truene
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchCallback:
                    (FlTouchEvent event, BarTouchResponse? response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.spot == null) return;
                  widget.onBarTap?.call(response.spot!.touchedBarGroup.x);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) => getBottomTitles(
                        value,
                        meta,
                        widget.startMonth,
                        int.parse(widget.startYear.toString().substring(2))),
                  ),
                ),
              ),
              barGroups: barData.map(
                (data) {
                  return BarChartGroupData(
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
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(
    double value, TitleMeta meta, int startMonth, int startYear) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  int index = value.toInt();
  int year = startYear + (startMonth + index - 1) ~/ 12;
  int month = (startMonth + index - 1) % 12;
  if (month < 0) month += 12;

  String monthText;
  switch (month) {
    case 0:
      monthText = "ENE";
      break;
    case 1:
      monthText = "FEB";
      break;
    case 2:
      monthText = "MAR";
      break;
    case 3:
      monthText = "ABR";
      break;
    case 4:
      monthText = "MAY";
      break;
    case 5:
      monthText = "JUN";
      break;
    case 6:
      monthText = "JUL";
      break;
    case 7:
      monthText = "AGO";
      break;
    case 8:
      monthText = "SEP";
      break;
    case 9:
      monthText = "OCT";
      break;
    case 10:
      monthText = "NOV";
      break;
    case 11:
      monthText = "DIC";
      break;
    default:
      monthText = "";
  }

  String finalText = '$monthText $year';

  return SideTitleWidget(
    meta: meta,
    child: Text(finalText, style: textStyle),
  );
}
