import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/models/topic_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumView extends StatefulWidget {
  final List<Discussion> discussions;
  final Function(Discussion) onShowDiscussion;
  final Future<List<Discussion>> Function() onFetchDiscussions;

  const ForumView({
    Key? key,
    required this.discussions,
    required this.onShowDiscussion,
    required this.onFetchDiscussions,
  }) : super(key: key);

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");
  Set<String> activeTopics = {};
  List<Discussion> discussions = List.empty();

  @override
  void initState() {
    super.initState();
    discussions = widget.discussions;
    for (var discussion in discussions) {
      activeTopics
          .add(TopicManager().getTopicById(discussion.getTopicId).getName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter discussions based on active topics
    List<Discussion> filteredDiscussions = discussions.where((discussion) {
      String topicName =
          TopicManager().getTopicById(discussion.getTopicId).getName;
      return activeTopics.contains(topicName);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: _buildTopicFilters(),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    discussions = await widget.onFetchDiscussions();
                    setState(() {});
                  },
                  child: ListView.separated(
                    itemCount: filteredDiscussions.isEmpty
                        ? 1
                        : filteredDiscussions.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(color: Colors.black54);
                    },
                    itemBuilder: (context, index) {
                      if (filteredDiscussions.isEmpty) {
                        return _buildEmptyDiscussionContent();
                      } else {
                        return _buildDiscussionItem(filteredDiscussions[index]);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTopicFilters() {
    List<Widget> topicFilters = List.empty(growable: true);
    List<String> topics =
        TopicManager().getTopicList.map((topic) => topic.getName).toList();
    topics.sort((a, b) => activeTopics.contains(a)
        ? -1
        : activeTopics.contains(b)
            ? 1
            : 0);

    for (var topic in topics) {
      bool isActive = activeTopics.contains(topic);

      topicFilters.add(GestureDetector(
        onTap: () {
          setState(() {
            if (isActive) {
              activeTopics.remove(topic);
            } else {
              activeTopics.add(topic);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Chip(
            labelPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            label: Text(topic),
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: isActive ? const Color(0xFF333333) : Colors.grey,
            ),
            backgroundColor: isActive ? Colors.orange : const Color(0xffffffff),
            elevation: 0,
            shadowColor: const Color(0xff808080),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: Color(0x688a8989), width: 1),
            ),
          ),
        ),
      ));
    }

    return topicFilters;
  }

  Widget _buildDiscussionItem(Discussion discussion) {
    return InkWell(
      onTap: () => widget.onShowDiscussion(discussion),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Tooltip(
                message: discussion.getUsername,
                triggerMode: TooltipTriggerMode.tap,
                child: _buildAvatarAndUsername(discussion),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TopicManager()
                          .getTopicById(discussion.getTopicId)
                          .getName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      discussion.getTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Color(0xff000000),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(discussion.getCreationDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        color: Color(0x9d858383),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_rounded,
                          color: Color(0x72212435),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          discussion.getPostCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            color: Color(0x72000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarAndUsername(Discussion discussion) {
    return SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: MyApp.secondaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                discussion.getUsername,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ));
  }

  Widget _buildEmptyDiscussionContent() {
    return const Column(
      children: [
        Stack(
          children: [
            Image(
              image: AssetImage("assets/images/sad_cat.png"),
            ),
          ],
        ),
        Text(
          'Nichts zu diskutieren...',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
