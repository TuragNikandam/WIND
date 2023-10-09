import 'package:andromeda_app/controllers/forum/discussion_controller.dart';
import 'package:andromeda_app/controllers/forum/forum_controller.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForumMenu extends StatefulWidget {
  const ForumMenu({super.key});

  @override
  State<ForumMenu> createState() => _ForumMenuState();
}

class _ForumMenuState extends State<ForumMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationService =
        Provider.of<NavigationService>(context, listen: false);
    return Navigator(
      key: navigationService.forumKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case ForumController.route:
            builder = (BuildContext _) => const ForumController();
            break;
          case DiscussionController.route:
            builder = (BuildContext _) {
              final Map args = settings.arguments as Map;
              final discussion = args['discussion'];
              return DiscussionController(discussion: discussion);
            };
            break;
          default:
            builder = (BuildContext _) => const ForumController();
        }
        return PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => builder(ctx),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: settings,
        );
        // No transition: return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
