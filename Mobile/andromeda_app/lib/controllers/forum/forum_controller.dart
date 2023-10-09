import 'dart:async';

import 'package:andromeda_app/controllers/forum/discussion_controller.dart';
import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/services/discussion_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:andromeda_app/views/forum/forum_view.dart';
import 'package:andromeda_app/views/utils/session_expired_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForumController extends StatefulWidget {
  static const String route = "/forum";

  @override
  State<ForumController> createState() => _ForumControllerState();

  const ForumController({super.key});
}

class _ForumControllerState extends State<ForumController> {
  late DiscussionService discussionService;
  late NavigationService navigationService;
  List<Discussion> _discussions = List.empty();
  final int countValue = 1;

  Future<List<Discussion>> _fetchDiscussions() async {
    try {
      var discussions = await discussionService.getAllDiscussions();
      _discussions = discussions;
      return discussions;
    } catch (error) {
      if (error is SessionExpiredException) {
        showSessionExpiredDialog(context);
        return List.empty();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden der Diskussionen.')),
        );
      });
      return List.empty();
    }
  }

  @override
  void initState() {
    super.initState();
    discussionService = Provider.of<DiscussionService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchDiscussions(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Discussion>> snapshot) {
          if (snapshot.hasData) {
            return ForumView(
                discussions: _discussions,
                onFetchDiscussions: _fetchDiscussions,
                onShowDiscussion: (Discussion discussion) {
                  navigationService.navigate(
                      context, DiscussionController.route,
                      isRootNavigator: false,
                      arguments: {'discussion': discussion});
                });
          }
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ));
        });
  }
}
