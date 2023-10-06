import 'package:andromeda_app/controllers/news_detail_controller.dart';
import 'package:andromeda_app/models/news_article_model.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/services/news_service.dart';
import 'package:andromeda_app/views/news_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsController extends StatefulWidget {
  static const String route = "/news";

  @override
  State<NewsController> createState() => _NewsControllerState();

  const NewsController({super.key});
}

class _NewsControllerState extends State<NewsController> {
  late NewsService newsService;
  late NavigationService navigationService;
  List<NewsArticle> _newsArticles = List.empty();
  final int countValue = 1;

  Future<List<NewsArticle>> _fetchNews() async {
    try {
      final news = await newsService.getAllNews();
      _newsArticles = news;
      return news;
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden der News.')),
        );
      });
      return List.empty();
    }
  }

  void _updateNewsViews(NewsArticle newsArticle) {
    try {
      setState(() {
        newsArticle.setViewCount(newsArticle.getViewCount + countValue);
        newsService.updateNewsViewCount(newsArticle.getId, countValue);
      });
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden der News.')),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    newsService = Provider.of<NewsService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: _fetchNews(),
          builder: (BuildContext context,
              AsyncSnapshot<List<NewsArticle>> snapshot) {
            if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
              return NewsView(
                  newsArticles: _newsArticles,
                  onFetchNewsArticle: _fetchNews,
                  onShowNewsArticle: (NewsArticle newsArticle) {
                     _updateNewsViews(newsArticle);
                    navigationService.navigate(
                        context, NewsDetailController.route,
                        isRootNavigator: false,
                        arguments: {'newsArticle': newsArticle});
                  });
            }
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ));
          });
  }
}
