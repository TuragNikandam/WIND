import 'dart:async';
import 'package:andromeda_app/models/news_article_model.dart';
import 'package:andromeda_app/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService extends BaseService {
  final BaseService baseService;
  // Composition this.baseService
  NewsService(this.baseService);

  Future<List<NewsArticle>> getAllNews() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/news');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await getJWTToken() ?? ""}',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<NewsArticle> news =
            jsonResponse.map((json) => NewsArticle.fromJson(json)).toList();
        return news;
      } else {
        throw Exception('Failed to fetch news!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> updateNewsViewCount(String newsArticleId, int stepCount) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/news/$newsArticleId');
    NewsArticle newsArticleBackend = await getNewsArticle(newsArticleId);
    newsArticleBackend
        .setViewCount(newsArticleBackend.getViewCount + stepCount);
    try {
      final response = await http
          .put(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode({
              'viewCount': newsArticleBackend.getViewCount,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) {
        throw Exception('Failed to update news article!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<NewsArticle> getNewsArticle(String newsArticleId) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/news/$newsArticleId');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return NewsArticle.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch news!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<NewsArticleComment>> getNewsArticleComments(
      String newsArticleId) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/news/$newsArticleId/comment');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<NewsArticleComment> comments = jsonResponse
            .map((json) => NewsArticleComment.fromJson(json))
            .toList();
        return comments;
      } else {
        throw Exception('Failed to fetch news comments!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> createNewsArticleComments(
      String newsArticleId, NewsArticleComment newsArticleComment) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/news/$newsArticleId/comment');

    try {
      final response = await http
          .post(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode(newsArticleComment.toJson()),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to send comment request!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }
}
