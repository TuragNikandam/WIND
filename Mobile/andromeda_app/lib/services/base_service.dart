import 'dart:convert';
import 'dart:io';
import 'package:andromeda_app/services/dev_http_override.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BaseService {
  String? apiBaseUrl;
  final storage = const FlutterSecureStorage();
  final int timeOutSeconds = 3;

  BaseService() {
    _loadConfig();
    HttpOverrides.global = DevHttpOverrides();
  }

  Future<void> setJWTToken(Map<String, dynamic> decodedJSONToken) async {
    await storage.write(key: 'jwt_token', value: decodedJSONToken["token"]);
  }

  Future<String?> getJWTToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<Map<String, String>> getStandardHeaders() async {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${await getJWTToken() ?? ""}',
    };
  }

  Future<void> _loadConfig() async {
    // Prod config
    var configStringName = "apiBaseUrl";
    var configString =
        await rootBundle.loadString('config/app_config_prod.json');

    // If debug mode, dev config
    if (kDebugMode) {
      configString = await rootBundle.loadString('config/app_config_dev.json');
      if (Platform.isAndroid) {
        configStringName = 'android_apiBaseUrl';
      } else if (Platform.isIOS) {
        configStringName = 'ios_apiBaseUrl';
      }
    }
    final configData = jsonDecode(configString) as Map<String, dynamic>;
    apiBaseUrl = configData[configStringName];
  }

  Future<void> handleDefaultResponse(http.Response response) async {
    await _handleResponseHeaders(response.headers);

    if (response.statusCode == 401) {
      setJWTToken({"token": ''});
      throw SessionExpiredException('Token expired or not valid');
    }
  }

  Future<void> _handleResponseHeaders(Map<String, String> headers) async {
    // Capture the new token from the response headers
    String? newToken = headers['x-new-token'];

    if (newToken != null) {
      // Store the new token using setJWTToken
      await setJWTToken({"token": newToken});
    }
  }
}
