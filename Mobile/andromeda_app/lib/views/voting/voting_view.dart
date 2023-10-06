import 'package:andromeda_app/models/topic_model.dart';
import 'package:andromeda_app/views/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:andromeda_app/models/voting_model.dart';
import 'package:intl/intl.dart';

class VotingView extends StatefulWidget {
  final Function(Voting, bool, Function(BuildContext, String)) onShowVoting;
  final Function(bool) onRefresh;
  final List<Voting> activeVotings;
  final List<Voting> closedVotings;

  const VotingView({
    Key? key,
    required this.onShowVoting,
    required this.activeVotings,
    required this.closedVotings,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<VotingView> createState() => _VotingViewState();
}

class _VotingViewState extends State<VotingView> {
  String _searchText = "";
  List<Voting> _filteredActiveVotings = [];
  List<Voting> _filteredClosedVotings = [];
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");

  void _showError(BuildContext context, String errorMessage) {
    Dialogs.showErrorDialog(
        context, 'Fehler beim laden der Abstimmung', 'Okay', errorMessage);
  }

  @override
  void initState() {
    super.initState();
    _filteredActiveVotings = widget.activeVotings;
    _filteredClosedVotings = widget.closedVotings;
  }

  List<Voting> _filterVotings(List<Voting> votings) {
    return votings.where((voting) {
      return voting.question
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          voting.topic
              .toString()
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          dateFormat.format(voting.expirationDate).contains(_searchText);
    }).toList();
  }

  void _updateFilteredVotings() {
    setState(() {
      _filteredActiveVotings = _filterVotings(widget.activeVotings);
      _filteredClosedVotings = _filterVotings(widget.closedVotings);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Wahlen'),
            actions: [_buildSearchFunction()],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Column(
                children: [
                  const Divider(
                    color: Colors.black,
                    height: 1,
                    thickness: 1,
                  ),
                  Stack(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Offen'),
                          Tab(text: 'Beendet'),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: MediaQuery.of(context).size.width / 2 - 0.5,
                        child: const VerticalDivider(
                          color: Colors.grey,
                          width: 1,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: _buildVotingForm(),
            ),
          )),
    );
  }

  List<Widget> _buildVotingForm() =>
      [_buildVotingsList(true), _buildVotingsList(false)];

  Widget _buildVotingsList(bool isOpenVotings) {
    List<Voting> votings =
        isOpenVotings ? _filteredActiveVotings : _filteredClosedVotings;

    return RefreshIndicator(
        onRefresh: () async {
          isOpenVotings
              ? _filteredActiveVotings =
                  _filterVotings(await widget.onRefresh(isOpenVotings))
              : _filteredClosedVotings =
                  _filterVotings(await widget.onRefresh(isOpenVotings));
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.separated(
              itemCount: votings.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(color: Colors.black54);
              },
              itemBuilder: (context, index) {
                final Voting voting = votings[index];
                return InkWell(
                    onTap: () =>
                        widget.onShowVoting(voting, isOpenVotings, _showError),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        TopicManager()
                                            .getTopicById(voting.topic)
                                            .getName,
                                        style: const TextStyle(
                                            color: Colors.orange),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        voting.question,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(isOpenVotings
                                          ? "Endet am: ${dateFormat.format(voting.expirationDate)}"
                                          : "Beendet"),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person),
                                          const SizedBox(width: 5),
                                          Text(
                                              '${voting.options.map((e) => e.votedUsers).expand((e) => e).toSet().length}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => widget.onShowVoting(
                                    voting, isOpenVotings, _showError),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () => widget.onShowVoting(
                                    voting, isOpenVotings, _showError),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            ),
                          ],
                        )));
              },
            )));
  }

  Widget _buildSearchFunction() => Center(
          child: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          TextEditingController searchController =
              TextEditingController(text: _searchText);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Suchen'),
                content: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Suchtext',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchText = value;
                    _updateFilteredVotings();
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      _searchText = "";
                      _updateFilteredVotings();
                      Navigator.pop(context);
                    },
                    child: const Text('Leeren'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Suchen'),
                  ),
                ],
              );
            },
          );
        },
      ));
}
