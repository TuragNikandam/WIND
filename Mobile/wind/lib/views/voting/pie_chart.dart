import 'package:wind/models/user_model.dart';
import 'package:wind/views/voting/filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VotingPieChart extends StatefulWidget {
  final Map<String, int> filteredVoteCounts;
  final List<User> userList;
  final FilterParameters filterParameters;
  final List<Color> colors;

  const VotingPieChart({
    Key? key,
    required this.userList,
    required this.filterParameters,
    required this.filteredVoteCounts,
    required this.colors,
  }) : super(key: key);

  @override
  State<VotingPieChart> createState() => _VotingPieChartState();
}

class _VotingPieChartState extends State<VotingPieChart> {
  int touchedIndex = -1;

  double spaceHeight = 0.0;
  double screenWidth = 0.0;
  double spaceWidth = 0.0;
  double screenHeight = 0.0;
  double radius = 0.0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.width * 0.06;
    Map<String, int> filteredVoteCounts = widget.filteredVoteCounts;
    int totalVotes = filteredVoteCounts.values.fold(0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        pieTouchData: pieTouchData(totalVotes),
        borderData: borderData(),
        sectionsSpace: 2,
        centerSpaceRadius: radius * 1.5,
        sections: showingSections(filteredVoteCounts, totalVotes),
      ),
    );
  }

  PieTouchData pieTouchData(int totalVotes) {
    if (totalVotes != 0) {
      return PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
          });
        },
      );
    } else {
      return PieTouchData();
    }
  }

  FlBorderData borderData() {
    return FlBorderData(
      show: false,
    );
  }

  List<PieChartSectionData> showingSections(
      Map<String, int> filteredVoteCounts, int totalVotes) {
    List<PieChartSectionData> sections = [];
    int index = 0;

    filteredVoteCounts.forEach((option, count) {
      sections.add(buildPieChartSectionData(option, count, totalVotes, index));
      index++;
    });

    return sections;
  }

  PieChartSectionData buildPieChartSectionData(
      String option, int count, int totalVotes, int index) {
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 25.0 : 20.0;
    final sectionRadius = isTouched
        ? MediaQuery.of(context).size.width * 0.3
        : MediaQuery.of(context).size.width * 0.25;
    final double percentage = totalVotes == 0 ? 0 : (count / totalVotes * 100);
    final int roundedPercentage = percentage.round();
    final shadows = [const Shadow(color: Colors.black, blurRadius: 2)];

    Color sectionColor = widget.colors[index];

    return PieChartSectionData(
      color: sectionColor,
      value: percentage.toDouble(),
      title: '$roundedPercentage%',
      radius: sectionRadius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: shadows,
      ),
    );
  }
}
