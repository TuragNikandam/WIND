import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/utils/validators.dart';
import 'package:andromeda_app/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiscussionView extends StatefulWidget {
  final Discussion discussion;
  final List<DiscussionPost> posts;
  final Function() onFetchDiscussionPosts;
  final Function(DiscussionPost post) onSendDiscussionPost;

  const DiscussionView({
    Key? key,
    required this.discussion,
    required this.posts,
    required this.onFetchDiscussionPosts,
    required this.onSendDiscussionPost,
  }) : super(key: key);

  @override
  State<DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView> {
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");
  List<DiscussionPost> posts = List.empty(growable: true);
  late User user;
  double avatarRadius = 15.0;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    posts = widget.posts;
  }

  Widget buildUserColumn(DiscussionPost post, bool isCurrentUser) {
    return isCurrentUser
        ? Container()
        : GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ProfileView(post.getAuthorId, context).showProfile();
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: MyApp.secondaryColor,
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                Text(
                  post.getUsername,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                Text(post.getPartyIsVisible
                    ? PartyManager().getPartyById(post.getPartyId).getShortName
                    : "")
              ],
            ),
          );
  }

  Widget _buildSpeechBubble(
      DiscussionPost post, bool pointToRight, double width) {
    String formattedDate = dateFormat.format(post.getCreationDate);
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          painter: SpeechBubblePainter(
              pointToRight: pointToRight, avatarRadius: avatarRadius),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                pointToRight ? 20 : 10, 10, pointToRight ? 10 : 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  post.getContent,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (formKey.currentState!.validate()) {
      DiscussionPost newPost = DiscussionPost();
      newPost.setContent(_textController.text);
      newPost.setAuthorId(user.getId);

      _textController.clear();

      await widget.onSendDiscussionPost(newPost);
      posts = await widget.onFetchDiscussionPosts();
      setState(() {});

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
          if (_scrollController.offset <
              _scrollController.position.maxScrollExtent) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
            );
          }
        }
      });
    }
    //TODO: leer oder Language Filter hat zugeschlagen
    else {}
  }

  String? customValidator(String? value){
    if (value == null || value.isEmpty) {
      return 'Bitte schreibe einen Beitrag.';
    }
    return Validators.hasStringBadWord(value) ? "Ihre Eingabe enthält nicht erlaubte Wörter" : null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Diskussion')),
      backgroundColor: const Color.fromRGBO(232, 220, 202, 0.3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                onRefresh: () async {
                  posts = await widget.onFetchDiscussionPosts();
                  setState(() {});
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: screenHeight * 0.05,
                        maxHeight: screenHeight * 0.05,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: Tooltip(
                                message: widget.discussion.getTitle,
                                triggerMode: TooltipTriggerMode.tap,
                                child: Text(
                                  widget.discussion.getTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          DiscussionPost post = posts[index];
                          bool isCurrentUser = post.getAuthorId == user.getId;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                    width: screenWidth * 0.2,
                                    child: buildUserColumn(post, isCurrentUser)),
                                SizedBox(
                                    width: screenWidth * 0.55,
                                    child: _buildSpeechBubble(post,
                                        isCurrentUser, screenWidth * 0.55)),
                                SizedBox(
                                  width: screenWidth * 0.2,
                                  child: buildUserColumn(post, !isCurrentUser),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Form(
                      autovalidateMode: AutovalidateMode.disabled,
                      key: formKey,
                      child: TextFormField(
                        validator: customValidator,
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Sag was du denkst...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  final bool pointToRight;
  final double avatarRadius;

  SpeechBubblePainter({required this.pointToRight, required this.avatarRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 10, 0)
      ..lineTo(size.width - 10, size.height)
      ..lineTo(0, size.height);

    double tailCenter = size.height * 0.5 - avatarRadius;

    if (pointToRight) {
      path
        ..moveTo(size.width - 10, tailCenter - 10)
        ..lineTo(size.width, tailCenter)
        ..lineTo(size.width - 10, tailCenter + 10);
    } else {
      path
        ..moveTo(0, tailCenter - 10)
        ..lineTo(-10, tailCenter)
        ..lineTo(0, tailCenter + 10);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueGrey, // Different background color
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Border at the bottom
            width: 1.0,
          ),
        ),
        boxShadow: [
          // Shadow for elevation
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, 3.0),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
