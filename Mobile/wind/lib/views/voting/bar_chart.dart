import 'package:wind/main.dart';
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

  const VotingBarChart({
    Key? key,
    required this.userList,
    required this.filterParameters,
    required this.filteredVoteCounts,
    required this.voting,
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

  int _getHighestVote(Voting voting) {
    return voting.options
        .fold(0, (prev, option) => math.max(prev, option.voteCount));
  }

  Widget _buildBarChart(Voting voting) {
    return BarChart(
      BarChartData(
          barTouchData: _barTouchData(),
          titlesData: _getBarTitlesData(voting),
          borderData: _barBorderData,
          //barGroups: _buildBarGroups(voting),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: _getHighestVote(voting).toDouble() + 1),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.linear,
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
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => _getBarTitles(value, meta, voting),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 3, // Set the interval here
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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

  Widget _getBarTitles(double value, TitleMeta meta, Voting voting) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    if (value < 0 || value >= voting.options.length) {
      return const SizedBox();
    }
    String text = voting.options[value.toInt()].text;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 60,
        ),
        child: Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Limit the number of lines
        ),
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

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Theme.of(context).primaryColor,
          MyApp.secondaryColor,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> _buildBarGroups(Voting voting) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < voting.options.length; i++) {
      final option = voting.options[i];
      final filteredVoteCount = widget.filteredVoteCounts[option.text] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: filteredVoteCount.toDouble(),
              color: Theme.of(context).primaryColor,
              gradient: _barsGradient,
              width: 30,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.width * 0.06;
    return _buildBarChart(widget.voting);
  }
}
