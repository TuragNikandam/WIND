import 'dart:async';
import 'dart:convert';
import 'package:andromeda_app/models/discussion_model.dart';
import 'package:andromeda_app/services/base_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:http/http.dart' as http;

class DiscussionService extends BaseService {
  final BaseService baseService;

  DiscussionService(this.baseService);

  Future<List<Discussion>> getAllDiscussions() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/discussion');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((json) => Discussion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch discussions!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      print(sex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<DiscussionPost>> getAllPosts(String discussionId) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/discussion/$discussionId/post');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((json) => DiscussionPost.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch posts!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      print(sex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> updatePost(
      String discussionId, String postId, DiscussionPost updatedPost) async {
    final Uri url = Uri.parse(
        '${baseService.apiBaseUrl}/discussion/$discussionId/post/$postId');

    try {
      final response = await http
          .put(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode(updatedPost.toJson()),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode != 200) {
        throw Exception('Failed to update post!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      print(sex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> createPost(String discussionId, DiscussionPost newPost) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/discussion/$discussionId/post');

    try {
      final response = await http
          .post(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode(newPost.toJson()),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode != 201) {
        throw Exception('Failed to create post!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      print(sex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }
}
