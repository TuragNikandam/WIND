import 'package:wind/models/topic_model.dart';
import 'package:wind/models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wind/models/voting_model.dart';
import 'package:provider/provider.dart';

class VotingOpenDetailView extends StatefulWidget {
  final Function(String, List<String>) onVote;
  final Voting voting;
  final bool userHasVoted;

  const VotingOpenDetailView(
      {Key? key,
      required this.onVote,
      required this.voting,
      required this.userHasVoted})
      : super(key: key);

  @override
  State<VotingOpenDetailView> createState() => _VotingOpenDetailViewState();
}

class _VotingOpenDetailViewState extends State<VotingOpenDetailView> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
  }

  double spaceHeight = 0.0;
  double spaceWidth = 0.0;
  double screenHeight = 0.0;
  double radius = 0.0;
  List<String> selectedOptionIds = [];

  void _updateLocalModelAfterVote() {
    // Loop through each selected option ID
    for (String optionId in selectedOptionIds) {
      // Find the corresponding option in the voting model
      Option? option = widget.voting.options.firstWhereOrNull(
        (option) => option.id == optionId,
      );

      // Increment the vote count of the option
      if (option != null) {
        option.incrementVoteCount(user.getId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.width * 0.06;
    return Scaffold(
      appBar: AppBar(title: const Text("Voting Detail")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spaceHeight * 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildVotingDetailForm(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVotingDetailForm() => [
        _buildHeaderText(),
        SizedBox(height: spaceHeight),
        _buildVotingQuestion(),
        SizedBox(height: spaceHeight),
        _buildVoteOptions(),
        SizedBox(height: spaceHeight * 3),
        _buildVoteButton()
      ];

  Widget _buildHeaderText() {
    return Text(
      TopicManager().getTopicById(widget.voting.topic).getName,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildVotingQuestion() {
    return Text(
      widget.voting.question,
      style: const TextStyle(fontSize: 18),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildVoteOptions() {
    return SizedBox(
        height: screenHeight * 0.5,
        child: ListView.separated(
          itemCount: widget.voting.options.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: spaceHeight);
          },
          itemBuilder: (context, index) {
            final option = widget.voting.options[index];
            final isSelected = selectedOptionIds.contains(option.id);

            return InkWell(
                onTap: widget.userHasVoted
                    ? null
                    : () {
                        setState(() {
                          if (widget.voting.multipleChoices) {
                            if (isSelected) {
                              selectedOptionIds.remove(option.id);
                            } else {
                              selectedOptionIds.add(option.id);
                            }
                          } else {
                            selectedOptionIds = [option.id];
                          }
                        });
                      },
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(radius * 2),
                    ),
                    child:
                        Stack(children: _buildOptionsList(option, isSelected)),
                  ),
                ));
          },
        ));
  }

  List<Widget> _buildOptionsList(Option option, bool isSelected) {
    List<Widget> optionsList = [];

    int totalVotes = widget.voting.options.fold(
        0, (prev, option) => prev + option.voteCount); // Calculate total votes
    final double fillRatio =
        totalVotes == 0 ? 0 : (option.voteCount / totalVotes);
    final double percentage = (fillRatio * 100).roundToDouble();
    final bool userHasVotedForThisOption =
        option.votedUsers.contains(user.getId);

    if (widget.userHasVoted) {
      optionsList.add(
        ListTile(
          title: Text(option.text),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              userHasVotedForThisOption
                  ? const Icon(Icons.check, color: Colors.green)
                  : Container(),
              SizedBox(width: spaceWidth),
              Text("$percentage%"),
            ],
          ),
        ),
      );
      optionsList.add(Positioned.fill(
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fillRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ));
    } else {
      optionsList.add(
        ListTile(
          leading: widget.voting.multipleChoices
              ? Checkbox(
                  value: isSelected,
                  onChanged: null,
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).primaryColor;
                    }
                    return null;
                  }),
                )
              : Radio(
                  value: option.id,
                  groupValue:
                      selectedOptionIds.isEmpty ? null : selectedOptionIds[0],
                  onChanged: null,
                  activeColor: Theme.of(context).primaryColor,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).primaryColor;
                    }
                    return null;
                  })),
          title: Text(option.text),
        ),
      );
    }

    return optionsList;
  }

  Widget _buildVoteButton() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // The button color
        borderRadius: BorderRadius.circular(radius * 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // Vertical shadow only
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0), // Even spread
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: selectedOptionIds.isEmpty
            ? null
            : () async {
                await widget.onVote(widget.voting.id, selectedOptionIds);

                // Update the local model
                _updateLocalModelAfterVote();
                selectedOptionIds.clear();
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              horizontal: spaceWidth * 6, vertical: spaceHeight * 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          elevation: 0, // No elevation for the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                radius * 0.5), // Same corner radius as the container
          ),
        ),
        child: const Text('Abstimmen'),
      ),
    );
  }
}
