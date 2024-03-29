import 'package:wind/main.dart';
import 'package:wind/models/discussion_model.dart';
import 'package:wind/models/party_model.dart';
import 'package:wind/models/user_model.dart';
import 'package:wind/utils/validators.dart';
import 'package:wind/views/profile/profile_view.dart';
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

  double spaceHeight = 0.0;
  double screenWidth = 0.0;
  double spaceWidth = 0.0;
  double screenHeight = 0.0;
  double radius = 0.0;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    posts = widget.posts;
  }

  Widget buildUserColumn(DiscussionPost post, bool isCurrentUser) {
    return isCurrentUser
        ? Container()
        : InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ProfileView(post.getAuthorId, context).showProfile();
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: MyApp.secondaryColor,
                  child: Icon(Icons.person,
                      color: Colors.white, size: radius * 1.2),
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

  Widget _buildSpeechBubble(DiscussionPost post, bool pointToRight,
      double width, bool isCurrentUser) {
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
                spaceWidth * 1.3, spaceHeight, spaceWidth * 1.3, spaceHeight),
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
  }

  String? _customValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte schreibe einen Beitrag.';
    }
    return Validators.hasStringBadWord(value)
        ? "Ihre Eingabe enthält nicht erlaubte Wörter"
        : null;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.height * 0.023;

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
                                showDuration: const Duration(seconds: 10),
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.03),
                                    child: Text(
                                      widget.discussion.getTitle,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ))),
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
                            padding: EdgeInsets.all(spaceWidth),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                    width: screenWidth * 0.2,
                                    child:
                                        buildUserColumn(post, isCurrentUser)),
                                SizedBox(
                                    width: screenWidth * 0.55,
                                    child: _buildSpeechBubble(
                                        post,
                                        isCurrentUser,
                                        screenWidth * 0.55,
                                        isCurrentUser)),
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
              padding: EdgeInsets.symmetric(
                  horizontal: spaceHeight, vertical: spaceWidth / 2),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Form(
                      autovalidateMode: AutovalidateMode.disabled,
                      key: formKey,
                      child: TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator: _customValidator,
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Sag was du denkst...',
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _handleSend,
                    child: CircleAvatar(
                      radius: radius,
                      backgroundColor: MyApp.secondaryColor,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
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
