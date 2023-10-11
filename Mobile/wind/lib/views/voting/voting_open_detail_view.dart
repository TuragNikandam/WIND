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
    return Scaffold(
      appBar: AppBar(title: const Text("Voting Detail")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
        const SizedBox(height: 16),
        _buildVotingQuestion(),
        const SizedBox(height: 16),
        _buildVoteOptions(),
        const SizedBox(height: 16),
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
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.voting.options.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 16);
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
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(children: _buildOptionsList(option, isSelected)),
          ),
        );
      },
    );
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
              const SizedBox(width: 8),
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
              borderRadius: BorderRadius.circular(30),
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
                      return Theme.of(context)
                          .primaryColor; // Sets the fill color to transparent when selected
                    }
                    return null; // Default (can also set to another color if needed)
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
                      return Theme.of(context)
                          .primaryColor; // Sets the fill color to transparent when selected
                    }
                    return null; // Default (can also set to another color if needed)
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
        borderRadius: BorderRadius.circular(10),
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
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          elevation: 0, // No elevation for the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10), // Same corner radius as the container
          ),
        ),
        child: const Text('Abstimmen'),
      ),
    );
  }
}
