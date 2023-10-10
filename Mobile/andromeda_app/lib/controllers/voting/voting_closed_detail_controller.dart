import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/models/voting_model.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:andromeda_app/views/utils/session_expired_dialog.dart';
import 'package:andromeda_app/views/voting/voting_closed_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VotingClosedDetailController extends StatefulWidget {
  final Voting voting;
  static const String route = "/voting/closed";

  const VotingClosedDetailController({required this.voting, super.key});

  @override
  State<VotingClosedDetailController> createState() =>
      _VotingClosedDetailControllerState();
}

class _VotingClosedDetailControllerState
    extends State<VotingClosedDetailController> {
  late UserService userService;
  late Voting _voting;
  List<User> _allUsers = List.empty();
  List<User> _usersVoted = List.empty();
  bool _isLoading = true;

  Future _fetchAllUsers() async {
    try {
      final fetchedUsers = await userService.getAllUsers();
      setState(() {
        _allUsers = fetchedUsers;
        _isLoading = false; // Stop the loading state
      });
    } catch (error) {
      if (error is SessionExpiredException) {
        showSessionExpiredDialog(context);
        return;
      }
      setState(() {
        _isLoading = false; // Stop the loading state
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fehler beim Laden der laufenden Votings.')),
        );
      });
    }
  }

  void _getUsersForVoting(Voting voting) {
    // Create a set to store unique user IDs who voted
    Set<String> votedUserIds = {};

    // Loop through each option and collect all user IDs who voted
    for (Option option in voting.options) {
      votedUserIds.addAll(option.votedUsers);
    }

    // Filter _allUsers to only include users who voted
    _usersVoted =
        _allUsers.where((user) => votedUserIds.contains(user.getId)).toList();
  }

  @override
  void initState() {
    super.initState();
    _voting = widget.voting;
    userService = Provider.of<UserService>(context, listen: false);
    _fetchAllUsers().then((_) {
      _getUsersForVoting(_voting);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If loading, show the CircularProgressIndicator
      return const Scaffold(
        backgroundColor: Colors.white, // White background
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.blueGrey,
        )),
      );
    } else {
      return VotingClosedDetailView(voting: _voting, userList: _usersVoted);
    }
  }
}
