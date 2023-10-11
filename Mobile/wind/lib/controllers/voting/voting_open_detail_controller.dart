import 'package:wind/models/user_model.dart';
import 'package:wind/models/voting_model.dart';
import 'package:wind/services/voting_service.dart';
import 'package:wind/utils/session_expired_exception.dart';
import 'package:wind/views/utils/session_expired_dialog.dart';
import 'package:wind/views/voting/voting_open_detail_view.dart';
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

  @override
  void initState() {
    super.initState();
    _voting = widget.voting;
    votingService = Provider.of<VotingService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return VotingOpenDetailView(
        voting: _voting,
        userHasVoted: _voting.options
            .any((option) => option.votedUsers.contains(user.getId)),
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
            if (error is SessionExpiredException) {
              showSessionExpiredDialog(context);
            }
          }
        });
  }
}
