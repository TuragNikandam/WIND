import 'package:andromeda_app/models/news_article_model.dart';
import 'package:andromeda_app/models/topic_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsView extends StatefulWidget {
  final List<NewsArticle> newsArticles;
  final Function(NewsArticle) onShowNewsArticle;
  final Future<List<NewsArticle>> Function() onFetchNewsArticle;

  const NewsView({
    Key? key,
    required this.newsArticles,
    required this.onShowNewsArticle,
    required this.onFetchNewsArticle,
  }) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");
  Set<String> activeTopics = {};
  List<NewsArticle> newsArticles = List.empty();

  @override
  void initState() {
    super.initState();
    newsArticles = widget.newsArticles;
    for (var newsArticle in newsArticles) {
      activeTopics
          .add(TopicManager().getTopicById(newsArticle.getTopic).getName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Newsfeed'),
        ),
        body: SafeArea(
            child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(children: _buildTopicFilters()),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          newsArticles = await widget.onFetchNewsArticle();
                          setState(() {});
                        },
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          shrinkWrap: true,
                          children: _buildNewsArticle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
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
              color: isActive ? Colors.white : Colors.grey,
            ),
            backgroundColor: isActive ? Theme.of(context).primaryColor : const Color(0xffffffff),
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

  List<Widget> _buildNewsArticle() {
    List<Widget> news = List.empty(growable: true);
    newsArticles.sort((a, b) => b.getCreationDate.compareTo(a.getCreationDate));

    for (var newsArticle in newsArticles) {
      if (activeTopics.contains(
          TopicManager().getTopicById(newsArticle.getTopic).getName)) {
        news.add(
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: InkWell(
              onTap: () {
                widget.onShowNewsArticle(newsArticle);
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              TopicManager()
                                  .getTopicById(newsArticle.getTopic)
                                  .getName,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                              child: Text(
                                newsArticle.getHeadline,
                                textAlign: TextAlign.start,
                                maxLines: 3,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                            Text(
                              dateFormat.format(newsArticle.getCreationDate),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Color(0x9d858383),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.visibility,
                                  color: Color(0x72212435),
                                  size: 16,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                  child: Text(
                                    newsArticle.getViewCount.toString(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 12,
                                      color: Color(0x72000000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: FadeInImage(
                          image: NetworkImage(newsArticle.getImage.getUrl),
                          imageErrorBuilder:
                              (BuildContext context, Object y, StackTrace? z) {
                            return const Icon(
                              Icons.broken_image,
                              color: Colors.black26,
                            );
                          },
                          height: 90,
                          width: 100,
                          fit: BoxFit.fill,
                          placeholder:
                              const AssetImage("assets/images/placeholder.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    if (news.isEmpty) {
      news.add(_buildEmptyNewsContent());
    }
    return news;
  }

  Widget _buildEmptyNewsContent() {
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
          'Nichts zu informieren...',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
