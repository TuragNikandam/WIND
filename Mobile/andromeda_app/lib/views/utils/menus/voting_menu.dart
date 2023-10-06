import 'package:andromeda_app/controllers/voting/voting_closed_detail_controller.dart';
import 'package:andromeda_app/controllers/voting/voting_controller.dart';
import 'package:andromeda_app/controllers/voting/voting_open_detail_controller.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/views/guests/guest_no_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VotingMenu extends StatefulWidget {
  const VotingMenu({super.key});

  @override
  State<VotingMenu> createState() => _VotingMenuState();
}

class _VotingMenuState extends State<VotingMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationService =
        Provider.of<NavigationService>(context, listen: false);
    return Navigator(
      key: navigationService.votingKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case VotingController.route:
            builder = (BuildContext _) => const VotingController();
            break;

          case VotingClosedDetailController.route:
            builder = (BuildContext _) {
              final closedVoting = (settings.arguments as Map)['voting'];
              return VotingClosedDetailController(
                voting: closedVoting,
              );
            };
            break;
          case VotingOpenDetailController.route:
            builder = (BuildContext _) {
              final Map args = settings.arguments as Map;
              final openVoting = args['voting'];
              final Function() onUpdate = args['onUpdate'] as Function();
              return VotingOpenDetailController(
                voting: openVoting,
                onUpdate: onUpdate,
              );
            };
            break;

          case GuestNoPermissionView.route:
            builder = (BuildContext _) {
              return const GuestNoPermissionView();
            };
            break;

          default:
            builder = (BuildContext _) => const VotingController();
        }
        return PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => builder(ctx),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: settings,
        );
        // No transition: return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
