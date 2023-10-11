import 'dart:math';
import 'package:wind/models/user_model.dart';
import 'package:wind/views/voting/filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VotingPieChart extends StatefulWidget {
  final Map<String, int> filteredVoteCounts;
  final List<User> userList;
  final FilterParameters filterParameters;

  const VotingPieChart({
    Key? key,
    required this.userList,
    required this.filterParameters,
    required this.filteredVoteCounts,
  }) : super(key: key);

  @override
  State<VotingPieChart> createState() => _VotingPieChartState();
}

class _VotingPieChartState extends State<VotingPieChart> {
  int touchedIndex = -1;

  final Random random = Random();

  final List<Color> predefinedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.black
  ];

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

    return Column(
      children: [
        SizedBox(height: spaceHeight), // Space at the top
        SizedBox(
          height: screenHeight * 0.35, // Set the height for the PieChart

          child: PieChart(
            PieChartData(
              pieTouchData: pieTouchData(totalVotes),
              borderData: borderData(),
              sectionsSpace: 2,
              centerSpaceRadius: radius * 2.5,
              sections: showingSections(filteredVoteCounts, totalVotes),
            ),
          ),
        ),
        SizedBox(
            height: spaceHeight * 6), // Space between PieChart and indicators
      ],
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
    final fontSize = isTouched ? 25.0 : 16.0;
    final radius = isTouched ? 60.0 : 50.0;
    final double percentage = totalVotes == 0 ? 0 : (count / totalVotes * 100);
    final int roundedPercentage = percentage.round();
    final shadows = [const Shadow(color: Colors.black, blurRadius: 2)];

    Color sectionColor;
    if (index < predefinedColors.length) {
      sectionColor = predefinedColors[index];
    } else {
      sectionColor = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
    }

    return PieChartSectionData(
      color: sectionColor,
      value: percentage.toDouble(),
      title: '$roundedPercentage%',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: shadows,
      ),
    );
  }

  List<Widget> buildIndicators(Map<String, int> filteredVoteCounts) {
    List<Widget> indicators = [];
    List<Widget> columns = [];
    int index = 0;
    int colCount = 0;

    filteredVoteCounts.forEach((option, count) {
      Color indicatorColor;
      if (index < predefinedColors.length) {
        indicatorColor = predefinedColors[index];
      } else {
        indicatorColor = Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        );
      }

      indicators.add(
        Padding(
          padding: EdgeInsets.all(radius * 0.02),
          child: Indicator(
            color: indicatorColor,
            text: option,
            isSquare: true,
          ),
        ),
      );

      if (colCount == 4) {
        columns.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned
          children: indicators,
        ));
        indicators = [];
        colCount = 0;
      } else {
        colCount++;
      }

      index++;
    });

    if (indicators.isNotEmpty) {
      columns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned
        children: indicators,
      ));
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start, // Left-aligned
        children: columns,
      )
    ];
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          width: screenWidth * 0.02,
          height: screenHeight * 0.01,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.015,
        ),
        Text(
          text,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
