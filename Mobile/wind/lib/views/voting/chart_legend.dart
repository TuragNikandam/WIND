import 'package:wind/models/user_model.dart';
import 'package:wind/views/voting/filter.dart';
import 'package:flutter/material.dart';

class VotingChartLegend extends StatefulWidget {
  final Map<String, int> filteredVoteCounts;
  final List<User> userList;
  final FilterParameters filterParameters;
  final List<Color> colors;

  const VotingChartLegend({
    Key? key,
    required this.userList,
    required this.filterParameters,
    required this.filteredVoteCounts,
    required this.colors,
  }) : super(key: key);

  @override
  State<VotingChartLegend> createState() => _VotingChartLegend();
}

class _VotingChartLegend extends State<VotingChartLegend> {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildIndicators(widget.filteredVoteCounts),
    );
  }

  List<Widget> _buildIndicators(Map<String, int> filteredVoteCounts) {
    List<Widget> indicators = [];
    List<Widget> columns = [];
    int index = 0;
    int colCount = 0;

    filteredVoteCounts.forEach((option, count) {
      Color indicatorColor = widget.colors[index];

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

      if (colCount == 2) {
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

    return columns;
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

  bool hasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 1}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double spaceWidth = MediaQuery.of(context).size.width * 0.015;
    TextStyle textStyle = const TextStyle(fontSize: 14);

    Widget textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    if (hasTextOverflow(text, textStyle,
        maxWidth: (screenWidth - spaceWidth))) {
      textWidget = Tooltip(
        message: text,
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 5),
        child: textWidget,
      );
    }

    return Row(
      children: [
        Container(
          width: screenWidth * 0.04,
          height: screenHeight * 0.025,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.015,
        ),
        Flexible(child: textWidget),
        SizedBox(height: screenHeight * 0.03),
      ],
    );
  }
}
