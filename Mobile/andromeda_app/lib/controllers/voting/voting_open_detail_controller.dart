import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/models/voting_model.dart';
import 'package:andromeda_app/services/voting_service.dart';
import 'package:andromeda_app/views/voting/voting_open_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VotingOpenDetailController extends StatefulWidget {
  final Voting voting;
  static const String route = "/voting/open";
  final Function onUpdate;

  const VotingOpenDetailController(
      {required this.voting, super.key, required this.onUpdate});

  @override
  State<VotingOpenDetailController> createState() =>
      _VotingOpenDetailControllerState();
}

class _VotingOpenDetailControllerState
    extends State<VotingOpenDetailController> {
  late VotingService votingService;
  late Voting _voting;
  late User user;
  bool userHasVoted = false;
  bool _isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    _voting = widget.voting;
    votingService = Provider.of<VotingService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);

    // Check if the user has already voted
    _checkIfUserHasVoted();
  }

  Future<void> _checkIfUserHasVoted() async {
    try {
      bool hasVoted = await votingService.hasUserVoted(_voting.id, context);
      setState(() {
        userHasVoted = hasVoted;
        _isLoading = false; // Stop the loading state
      });
    } catch (error) {
      // Handle error, for example, you could set userHasVoted to false
      print("Error checking if user has voted: $error");
      setState(() {
        _isLoading = false; // Stop the loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return VotingOpenDetailView(
        voting: _voting,
        userHasVoted: userHasVoted,
        onVote: (String votingId, List<String> selectedOptionIds) async {
          try {
            await votingService.vote(votingId, selectedOptionIds, context);
            setState(() {
              var selectedOptions = widget.voting.options
                  .where((option) => selectedOptionIds.contains(option.id));
              for (var option in selectedOptions) {
                option.incrementVoteCount(user.getId);
              }
              widget.onUpdate();
              userHasVoted = true;
            });
          } catch (error) {
            // Handle error
            print("Error while voting: $error");
          }
        });
  }
}
