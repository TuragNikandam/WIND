import 'dart:async';
import 'package:andromeda_app/services/base_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/organization_model.dart';
import '../models/party_model.dart';
import '../models/topic_model.dart';

class MasterDataService extends BaseService {
  final BaseService baseService;
  // Composition
  MasterDataService(this.baseService);

  Future<void> loadOrganizations() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/data/organization/');
    try {
      final response = await http
          .get(url, headers: await baseService.getStandardHeaders())
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        for (var json in jsonResponse) {
          Organization organization = Organization();
          organization.fromJson(json);
          OrganizationManager().addItem(organization);
        }
      } else {
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to fetch organizations!');
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

  Future<void> loadParties() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/data/party/');

    try {
      final response = await http
          .get(url, headers: await baseService.getStandardHeaders())
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        for (var json in jsonResponse) {
          Party party = Party();
          party.fromJson(json);
          PartyManager().addItem(party);
        }
      } else {
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to fetch partys!');
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

  Future<void> loadTopics() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/data/topic/');

    try {
      final response = await http
          .get(url, headers: await baseService.getStandardHeaders())
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        for (var json in jsonResponse) {
          Topic topic = Topic();
          topic.fromJson(json);
          TopicManager().addItem(topic);
        }
      } else {
        logger.e("Error log", error: "Response not ok: ${response.statusCode}");
        throw Exception('Failed to fetch topics!');
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

  Future<void> loadMasterData() async {
    await loadOrganizations();
    await loadParties();
    await loadTopics();
  }
}
