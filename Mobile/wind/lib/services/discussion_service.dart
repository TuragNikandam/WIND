import 'dart:async';
import 'dart:convert';
import 'package:wind/models/discussion_model.dart';
import 'package:wind/services/base_service.dart';
import 'package:wind/utils/session_expired_exception.dart';
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
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to fetch discussions!');
      }
    } on TimeoutException catch (tex) {
      logger.e("Error log", error: tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      logger.e("Error log", error: sex);
      rethrow;
    } catch (ex) {
      logger.e("Error log", error: ex);
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
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to fetch posts!');
      }
    } on TimeoutException catch (tex) {
      logger.e("Error log", error: tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      logger.e("Error log", error: sex);
      rethrow;
    } catch (ex) {
      logger.e("Error log", error: ex);
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
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to update post!');
      }
    } on TimeoutException catch (tex) {
      logger.e("Error log", error: tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      logger.e("Error log", error: sex);
      rethrow;
    } catch (ex) {
      logger.e("Error log", error: ex);
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
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to create post!');
      }
    } on TimeoutException catch (tex) {
      logger.e("Error log", error: tex);
      rethrow;
    } on SessionExpiredException catch (sex) {
      logger.e("Error log", error: sex);
      rethrow;
    } catch (ex) {
      logger.e("Error log", error: ex);
      rethrow;
    }
  }
}
