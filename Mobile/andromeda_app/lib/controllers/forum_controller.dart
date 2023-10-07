import 'dart:async';

import 'package:andromeda_app/controllers/discussion_controller.dart';
import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/services/discussion_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:andromeda_app/views/forum_view.dart';
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
  bool _isLoading = true;

  Future<List<Discussion>> _fetchDiscussions() async {
    try {
      var discussions = await discussionService.getAllDiscussions();
      setState(() {
        _discussions = discussions;
        _isLoading = false;
      });
      return discussions;
    } catch (error) {
      if (error is SessionExpiredException) {
        showSessionExpiredDialog(context);
        return List.empty();
      }

      print(error);
      setState(() {
        _isLoading = false;
      });
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

    _fetchDiscussions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.deepOrange,
        )),
      );
    } else {
      return ForumView(
          discussions: _discussions,
          onFetchDiscussions: _fetchDiscussions,
          onShowDiscussion: (Discussion discussion) {
            navigationService.navigate(context, DiscussionController.route,
                isRootNavigator: false, arguments: {'discussion': discussion});
          });
    }
  }
}
