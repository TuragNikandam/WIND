import 'dart:math';
import 'package:wind/models/user_model.dart';
import 'package:wind/views/voting/bar_chart.dart';
import 'package:wind/views/voting/chart_legend.dart';
import 'package:wind/views/voting/filter.dart';
import 'package:wind/views/voting/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:wind/models/voting_model.dart';
import 'package:dots_indicator/dots_indicator.dart';

class VotingClosedDetailView extends StatefulWidget {
  final Voting voting;
  final List<User> userList;

  const VotingClosedDetailView(
      {Key? key, required this.voting, required this.userList})
      : super(key: key);

  @override
  State<VotingClosedDetailView> createState() => _VotingClosedDetailViewState();
}

class _VotingClosedDetailViewState extends State<VotingClosedDetailView> {
  int _totalVotes = 0;
  int _guestVotes = 0;
  int currentPage = 0;
  double spaceHeight = 0.0;
  double spaceWidth = 0.0;
  double screenHeight = 0.0;
  double radius = 0.0;

  late FilterParameters _filterParameters;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.width * 0.06;
    updateVoteCounts();
    final controller = PageController(initialPage: currentPage);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Wahlergebnisse'),
          actions: [
            VotingFilter(
              userList: widget.userList,
              onFilterChanged: onFilterChanged,
              filterParameters: _filterParameters,
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(spaceHeight * 1.3),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVotingQuestion(),
                SizedBox(height: spaceHeight),
                _buildVoteCounts(),
                SizedBox(height: spaceHeight),
                SizedBox(
                  height: screenHeight * 0.4,
                  child: _buildChartsCard(controller),
                ),
                _buildDotsIndicator(),
                _buildVotinChartLegend()
              ],
            ),
          ),
        ));
  }

  void onFilterChanged(FilterParameters filterParameters) {
    setState(() {
      _filterParameters = filterParameters;
    });
  }

  Map<String, int> getFilteredVoteCounts(Voting voting) {
    Map<String, int> filteredVoteCounts = {};

    for (var option in voting.options) {
      int count = 0;
      for (var userId in option.votedUsers) {
        var user = widget.userList
            .firstWhere((u) => u.getId == userId, orElse: () => User());
        if (VotingFilterUtility.shouldIncludeVote(user, _filterParameters)) {
          count++;
        }
      }
      filteredVoteCounts[option.text] = count;
    }

    return filteredVoteCounts;
  }

  void updateVoteCounts() {
    int newTotalVotes = 0;
    int newGuestVotes = 0;

    for (var option in widget.voting.options) {
      for (var userId in option.votedUsers) {
        var user = widget.userList
            .firstWhere((u) => u.getId == userId, orElse: () => User());

        if (VotingFilterUtility.shouldIncludeVote(user, _filterParameters)) {
          newTotalVotes++;

          if (user.getIsGuest) {
            newGuestVotes++;
          }
        }
      }
    }

    setState(() {
      _totalVotes = newTotalVotes;
      _guestVotes = newGuestVotes;
    });
  }

  List<Color> _buildColorList() {
    final Random random = Random();
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.black,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];

    int numVotingOptions = getFilteredVoteCounts(widget.voting).length;

    // Generate additional random colors if needed
    while (colors.length < numVotingOptions) {
      colors.add(Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      ));
    }

    return colors;
  }

  @override
  void initState() {
    super.initState();
    _filterParameters = FilterParameters.defaultParameters();
  }

  Widget _buildVotingQuestion() {
    return Text(
      widget.voting.question,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVoteCounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stimmen: $_totalVotes",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Gäste Stimmen: $_guestVotes",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsCard(PageController controller) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: _buildCharts(controller),
    );
  }

  Widget _buildCharts(PageController controller) {
    return PageView(
      controller: controller,
      onPageChanged: (page) {
        setState(() {
          currentPage = page;
        });
      },
      children: [
        _buildVotingPieChart(),
        _buildVotingBarChart(),
      ],
    );
  }

  Widget _buildVotingPieChart() {
    return Padding(
      padding: EdgeInsets.fromLTRB(spaceWidth, 0, spaceWidth, 0),
      child: VotingPieChart(
        userList: widget.userList,
        filterParameters: _filterParameters,
        filteredVoteCounts: getFilteredVoteCounts(widget.voting),
        colors: _buildColorList(),
      ),
    );
  }

  Widget _buildVotingBarChart() {
    return Padding(
      padding: EdgeInsets.fromLTRB(spaceWidth, spaceHeight, spaceWidth, 0),
      child: VotingBarChart(
        voting: widget.voting,
        userList: widget.userList,
        filterParameters: _filterParameters,
        filteredVoteCounts: getFilteredVoteCounts(widget.voting),
        colors: _buildColorList(),
      ),
    );
  }

  Widget _buildVotinChartLegend() {
    return VotingChartLegend(
      userList: widget.userList,
      filterParameters: _filterParameters,
      filteredVoteCounts: getFilteredVoteCounts(widget.voting),
      colors: _buildColorList(),
    );
  }

  Widget _buildDotsIndicator() {
    return Center(
        child: Padding(
      padding: EdgeInsets.all(radius * 0.2),
      child: DotsIndicator(
        dotsCount: 2,
        position: currentPage,
        decorator: DotsDecorator(
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    ));
  }
}
