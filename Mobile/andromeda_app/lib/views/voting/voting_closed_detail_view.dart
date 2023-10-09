import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/views/voting/bar_chart.dart';
import 'package:andromeda_app/views/voting/filter.dart';
import 'package:andromeda_app/views/voting/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:andromeda_app/models/voting_model.dart';
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

  late FilterParameters _filterParameters;

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

  @override
  void initState() {
    super.initState();
    _filterParameters = FilterParameters.defaultParameters();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVotingQuestion(),
            const SizedBox(height: 16),
            _buildVoteCounts(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildChartsCard(controller),
            ),
            _buildDotsIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingQuestion() {
    return Text(
      widget.voting.question,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVoteCounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Anzahl der Stimmen: $_totalVotes",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Anzahl Gäste Stimmen: $_guestVotes",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsCard(PageController controller) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
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
      padding: const EdgeInsets.fromLTRB(10, 20, 5, 0),
      child: VotingPieChart(
        userList: widget.userList,
        filterParameters: _filterParameters,
        filteredVoteCounts: getFilteredVoteCounts(widget.voting),
      ),
    );
  }

  Widget _buildVotingBarChart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 5, 0),
      child: VotingBarChart(
        voting: widget.voting,
        userList: widget.userList,
        filterParameters: _filterParameters,
        filteredVoteCounts: getFilteredVoteCounts(widget.voting),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: DotsIndicator(
        dotsCount: 2,
        position: currentPage,
        decorator: const DotsDecorator(
          activeColor: Colors.orange,
        ),
      ),
    ));
  }
}
