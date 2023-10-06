import 'dart:async';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/models/voting_model.dart';
import 'package:andromeda_app/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class VotingService extends BaseService {
  final BaseService baseService;
  // Composition this.baseService
  VotingService(this.baseService);

  Future<List<Voting>> getActiveVotings() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/voting/active/');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Voting> votings =
            jsonResponse.map((json) => Voting.fromJson(json)).toList();
        return votings;
      } else {
        throw Exception('Failed to fetch active votings!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<Voting>> getClosedVotings() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/voting/closed/');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Voting> votings =
            jsonResponse.map((json) => Voting.fromJson(json)).toList();
        return votings;
      } else {
        throw Exception('Failed to fetch closed votings!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> vote(String votingId, List<String> optionIds, context) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/voting/$votingId');

    User user = Provider.of<User>(context, listen: false);

    try {
      final response = await http
          .post(url,
              headers: await baseService.getStandardHeaders(),
              body: jsonEncode({
                "optionIds": optionIds,
                "userId": user.getId,
              }))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to vote!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> hasUserVoted(String votingId, context) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/voting/$votingId/hasUserVoted');

    User user = Provider.of<User>(context, listen: false);

    try {
      final response = await http
          .post(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode({
              "userId": user.getId,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['hasVoted'] ?? false;
      } else {
        throw Exception('Failed to check if user has voted!');
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
