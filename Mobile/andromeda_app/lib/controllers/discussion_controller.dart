import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/services/discussion_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:andromeda_app/views/discussion_view.dart';
import 'package:andromeda_app/views/utils/session_expired_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscussionController extends StatefulWidget {
  final Discussion discussion;
  static const String route = "/news/detail";

  const DiscussionController({super.key, required this.discussion});

  @override
  State<DiscussionController> createState() => _DiscussionControllerState();
}

class _DiscussionControllerState extends State<DiscussionController> {
  late Discussion _discussion;
  late DiscussionService _discussionService;
  List<DiscussionPost> _discussionPosts = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _discussion = widget.discussion;
    _discussionService = Provider.of<DiscussionService>(context, listen: false);
  }

  Future<List<DiscussionPost>?> _fetchDiscussionPosts() async {
    try {
      var posts = await _discussionService.getAllPosts(_discussion.getId);
      posts.sort((a, b) => a.getCreationDate.compareTo(b.getCreationDate));
      _discussionPosts = posts;
      return posts;
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
          const SnackBar(
              content: Text('Fehler beim Laden der Diskussionseinträge.')),
        );
      });
    }
    return null;
  }

  Future<void> _sendDiscussionPost(DiscussionPost post) async {
    try {
      await _discussionService.createPost(_discussion.getId, post);
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fehler beim Versenden des Diskussionsbeitrags.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDiscussionPosts(),
      builder: (BuildContext context, AsyncSnapshot<List<DiscussionPost>?> snapshot) {
      if (snapshot.hasData) {
        return DiscussionView(
            discussion: _discussion,
            posts: _discussionPosts,
            onSendDiscussionPost: _sendDiscussionPost,
            onFetchDiscussionPosts: _fetchDiscussionPosts);
      }
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.deepOrange,
      ));
    });
  }
}
