import 'package:andromeda_app/controllers/voting/voting_closed_detail_controller.dart';
import 'package:andromeda_app/controllers/voting/voting_open_detail_controller.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/models/voting_model.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/services/voting_service.dart';
import 'package:andromeda_app/views/guests/guest_no_permission_view.dart';
import 'package:andromeda_app/views/voting/voting_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VotingController extends StatefulWidget {
  static const String route = "/voting";
  @override
  State<VotingController> createState() => _VotingControllerState();

  const VotingController({super.key});
}

class _VotingControllerState extends State<VotingController> {
  late VotingService votingService;
  late NavigationService navigationService;
  List<Voting> _activeVotings = List.empty();
  List<Voting> _closedVotings = List.empty();
  bool _isLoading = true;
  late User user;

  Future<List<Voting>> refreshData(bool isOpenVoting) async {
    if (isOpenVoting) {
      return await _fetchActiveVotings();
    } else {
      return await _fetchClosedVotings();
    }
  }

  Future<List<Voting>> _fetchActiveVotings() async {
    try {
      // Await the API call
      final fetchedVotings = await votingService.getActiveVotings();
      setState(() {
        _activeVotings = fetchedVotings;
        _isLoading = false; // Stop the loading state
      });
      return fetchedVotings;
    } catch (error) {
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
      return List.empty();
    }
  }

  Future<List<Voting>> _fetchClosedVotings() async {
    try {
      // Await the API call
      final fetchedVotings = await votingService.getClosedVotings();
      setState(() {
        _closedVotings = fetchedVotings;
        _isLoading = false; // Stop the loading state
      });
      return fetchedVotings;
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop the loading state
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fehler beim Laden der beendeten Votings.')),
        );
      });
      return List.empty();
    }
  }

  @override
  void initState() {
    super.initState();
    votingService = Provider.of<VotingService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
    _fetchClosedVotings();
    _fetchActiveVotings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If loading, show the CircularProgressIndicator
      return const Scaffold(
        backgroundColor: Colors.white, // White background
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.deepOrange,
        )),
      );
    } else if (_activeVotings.isEmpty || _closedVotings.isEmpty) {
      // Return an empty widget; navigation will occur if there's an error
      return const Scaffold(
        backgroundColor: Colors.white, // White background
      );
    } else {
      return VotingView(
          activeVotings: _activeVotings,
          closedVotings: _closedVotings,
          onShowVoting:
              (Voting voting, bool isOpenVotings, Function showError) {
            if (isOpenVotings) {
              navigationService.navigate(
                  context, VotingOpenDetailController.route,
                  isRootNavigator: false,
                  arguments: {
                    'voting': voting,
                    'onUpdate': () => setState(() {})
                  });
            } else {
              if (user.getIsGuest) {
                navigationService.navigate(context, GuestNoPermissionView.route,
                    isRootNavigator: false);
              } else {
                navigationService.navigate(
                    context, VotingClosedDetailController.route,
                    isRootNavigator: false, arguments: {'voting': voting});
              }
            }
          },
          onRefresh: refreshData);
    }
  }
}
