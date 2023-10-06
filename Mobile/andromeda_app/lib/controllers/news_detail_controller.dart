import 'package:andromeda_app/models/news_article_model.dart';
import 'package:andromeda_app/services/news_service.dart';
import 'package:andromeda_app/views/news_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsDetailController extends StatefulWidget {
  final NewsArticle newsArticle;
  static const String route = "/news/detail";

  const NewsDetailController({required this.newsArticle, super.key});

  @override
  State<NewsDetailController> createState() => _NewsDetailControllerState();
}

class _NewsDetailControllerState extends State<NewsDetailController> {
  late NewsArticle _newsArticle;
  late NewsService _newsService;
  List<NewsArticleComment> _comments = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _newsArticle = widget.newsArticle;
    _newsService = Provider.of<NewsService>(context, listen: false);
  }

  Future<List<NewsArticleComment>?> _fetchNewsArticleComments() async {
    try {
      var comments =
          await _newsService.getNewsArticleComments(_newsArticle.getId);
      comments.sort((a, b) => b.getCreationDate.compareTo(a.getCreationDate));
      _comments = comments;
      return comments;
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden der Kommentare.')),
        );
      });
    }
    return null;
  }

  Future<void> _sendNewsArticleComments(NewsArticleComment comment) async {
    try {
      await _newsService.createNewsArticleComments(_newsArticle.getId, comment);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            Future.delayed(const Duration(milliseconds: 1350), () {
              Navigator.of(context).pop(true);
            });

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 50.0,
                      ),
                      const Text(
                        'Anfrage erfolgreich',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      });
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fehler beim Versenden der Kommentareanfrage.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchNewsArticleComments(),
        builder: (BuildContext context,
            AsyncSnapshot<List<NewsArticleComment>?> snapshot) {
          if (snapshot.hasData) {
            return NewsDetailView(
                newsArticle: _newsArticle,
                comments: _comments,
                onSendComments: (NewsArticleComment comment) {
                  _sendNewsArticleComments(comment);
                });
          }
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ));
        });
  }
}
