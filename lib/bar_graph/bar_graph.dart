// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:expense_tracker/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // this list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToEnd();
    });
  }

  // initialize bar data - use our monthly summary to create a list of bars
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: widget.startMonth + index - 1,
        y: widget.monthlySummary[index],
      ),
    );
  }

  // calculate the upper limit for the graph
  double calculateUpperLimit() {
    double upperLimit = 10000000;
    widget.monthlySummary.sort();
    upperLimit = widget.monthlySummary.last * 1.05;
    if (upperLimit < 10000000) {
      return 10000000;
    }

    return upperLimit;
  }

  // scroll controller to make sure the graph is always at the end
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
    // initialize bar data
    initializeBarData();

    // bar dimension sizes
    const barWidth = 20.0;
    const barSpace = 15.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SizedBox(
          width: barWidth * barData.length + barSpace * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateUpperLimit(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
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
                      getTitlesWidget: getBottomTitles,
                      reservedSize: 24),
                ),
              ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(x: data.x, barRods: [
                      BarChartRodData(
                        toY: data.y,
                        width: barWidth,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: calculateUpperLimit(),
                          color: Colors.grey[200],
                        ),
                      ),
                    ]),
                  )
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: barSpace,
            ),
          ),
        ),
      ),
    );
  }
}

// BOTTOM TITLES
Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;

  switch (value.toInt() % 12) {
    case 0:
      text = 'Jan';
      break;
    case 1:
      text = 'Feb';
      break;
    case 2:
      text = 'Mar';
      break;
    case 3:
      text = 'Apr';
      break;
    case 4:
      text = 'May';
      break;
    case 5:
      text = 'Jun';
      break;
    case 6:
      text = 'Jul';
      break;
    case 7:
      text = 'Aug';
      break;
    case 8:
      text = 'Sep';
      break;
    case 9:
      text = 'Oct';
      break;
    case 10:
      text = 'Nov';
      break;
    case 11:
      text = 'Dec';
      break;
    default:
      text = '';
  }

  return SideTitleWidget(
    child: Text(
      text,
      style: textStyle,
    ),
    axisSide: meta.axisSide,
  );
}
