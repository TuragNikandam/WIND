import 'package:wind/models/user_model.dart';
import 'package:wind/views/voting/filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wind/models/voting_model.dart';
import 'dart:math' as math;

class VotingBarChart extends StatefulWidget {
  final Voting voting;
  final List<User> userList;
  final FilterParameters filterParameters;
  final Map<String, int> filteredVoteCounts;

  final List<Color> colors;

  const VotingBarChart({
    Key? key,
    required this.userList,
    required this.filterParameters,
    required this.filteredVoteCounts,
    required this.voting,
    required this.colors,
  }) : super(key: key);

  @override
  State<VotingBarChart> createState() => _VotingBarChartState();
}

class _VotingBarChartState extends State<VotingBarChart> {
  bool _isBarClicked = false;

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
    return _buildBarChart(widget.voting);
  }

  int _getHighestVote(Voting voting) {
    return voting.options
        .fold(0, (prev, option) => math.max(prev, option.voteCount));
  }

  Widget _buildBarChart(Voting voting) {
    return Padding(
      padding: EdgeInsets.all(spaceHeight),
      child: BarChart(
        BarChartData(
            barTouchData: _barTouchData(),
            titlesData: _getBarTitlesData(voting),
            borderData: _barBorderData,
            barGroups: _buildBarGroups(voting),
            gridData: const FlGridData(show: false),
            alignment: BarChartAlignment.spaceAround,
            maxY: _getHighestVote(voting).toDouble()),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }

  BarTouchData _barTouchData() {
    return BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: spaceWidth,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            if (_isBarClicked) {
              // Check if any bar is clicked
              return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return null;
          },
        ),
        touchCallback:
            (FlTouchEvent touchEvent, BarTouchResponse? barTouchResponse) {
          if (touchEvent is FlTapUpEvent && barTouchResponse?.spot != null) {
            setState(() {
              _isBarClicked = !_isBarClicked;
            });
            return;
          }
        });
  }

  FlTitlesData _getBarTitlesData(Voting voting) {
    int maxVote = _getHighestVote(voting);
    int numberOfIntervals = 5;
    double dynamicInterval = (maxVote / numberOfIntervals).toDouble() == 0
        ? 1
        : (maxVote / numberOfIntervals).toDouble();
    return FlTitlesData(
      show: true,
      bottomTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: spaceWidth * 3,
          interval: dynamicInterval,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlBorderData get _barBorderData => FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(
            color: Colors.black,
            width: 1,
          ),
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      );

  List<BarChartGroupData> _buildBarGroups(Voting voting) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < voting.options.length; i++) {
      final option = voting.options[i];
      final filteredVoteCount = widget.filteredVoteCounts[option.text] ?? 0;
      final barColor = widget.colors[i % widget.colors.length];

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: filteredVoteCount.toDouble(),
              //color: Theme.of(context).primaryColor,
              //gradient: _barsGradient,
              color: barColor,
              width: spaceWidth * 4.5,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return barGroups;
  }
}
