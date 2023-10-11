import 'package:wind/controllers/news/news_controller.dart';
import 'package:wind/controllers/news/news_detail_controller.dart';
import 'package:wind/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsMenu extends StatefulWidget {
  const NewsMenu({super.key});

  @override
  State<NewsMenu> createState() => _NewsMenuState();
}

class _NewsMenuState extends State<NewsMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationService =
        Provider.of<NavigationService>(context, listen: false);
    return Navigator(
      key: navigationService.newsKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case NewsController.route:
            builder = (BuildContext _) => const NewsController();
            break;
          case NewsDetailController.route:
            builder = (BuildContext _) {
              final newsArticle = (settings.arguments as Map)['newsArticle'];
              return NewsDetailController(newsArticle: newsArticle);
            };
            break;
          default:
            builder = (BuildContext _) => const NewsController();
        }
        return PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => builder(ctx),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: settings,
        );
        //No transition: return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
