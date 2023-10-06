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
      return await votingService.getActiveVotings();
    } catch (error) {
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
      return await votingService.getClosedVotings();
    } catch (error) {
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

  Future<bool> fetchVotings() async {
    _activeVotings = await _fetchActiveVotings();
    _closedVotings = await _fetchClosedVotings();
    return _activeVotings.isNotEmpty && _closedVotings.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    votingService = Provider.of<VotingService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchVotings(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
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
                      navigationService.navigate(
                          context, GuestNoPermissionView.route,
                          isRootNavigator: false);
                    } else {
                      navigationService.navigate(
                          context, VotingClosedDetailController.route,
                          isRootNavigator: false,
                          arguments: {'voting': voting});
                    }
                  }
                },
                onRefresh: refreshData);
          }
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ));
        });
  }
}
