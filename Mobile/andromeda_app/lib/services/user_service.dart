import 'dart:async';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/base_service.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService extends BaseService {
  final BaseService baseService;
  // Composition
  UserService(this.baseService);

  Future<void> login(String username, String password) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/login');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        await setJWTToken(jsonDecode(response.body));
      } else {
        throw Exception('Login fehlgeschlagen!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> loginAsGuest() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/guest/login');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        await setJWTToken(jsonDecode(response.body));
      } else {
        throw Exception('Als Gast fortfahren fehlgeschlagen!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<void> register(User user) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/register');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(user.toJson()),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 201) {
        await login(user.getUsername, user.getPassword);
      } else {
        throw Exception('Registrierung fehlgeschlagen!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/user/current');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return User.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch user data!');
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

  Future<bool> usernameExists(String username) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/register/checkUsername');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'username': username,
            }),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 409) {
        return true;
      } else if (response.statusCode == 200) {
        return false;
      } else {
        throw Exception('Fehler beim Prüfen auf gültigen Benutzernamen!');
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

  Future<bool> emailExists(String email) async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/register/checkEmail');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 409) {
        return true;
      } else if (response.statusCode == 200) {
        return false;
      } else {
        throw Exception('Fehler beim Prüfen auf gültige E-Mail Adresse!');
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

  Future<bool> updateUserProfile(User updatedUser) async {
    final Uri url =
        Uri.parse('${baseService.apiBaseUrl}/user/${updatedUser.getId}');

    try {
      final response = await http
          .put(
            url,
            headers: await baseService.getStandardHeaders(),
            body: jsonEncode(updatedUser.toJson()),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update profile data!');
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

  Future<void> logout() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/user/logout');
    Map<String, dynamic> emptyTokenMap = {};
    emptyTokenMap['token'] = "";

    try {
      final response = await http
          .post(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      if (response.statusCode == 200) {
        await setJWTToken(emptyTokenMap);
      } else {
        throw Exception('Failed to logout!');
      }
    } on TimeoutException catch (tex) {
      print(tex);
      rethrow;
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    final Uri url = Uri.parse('${baseService.apiBaseUrl}/user');

    try {
      final response = await http
          .get(
            url,
            headers: await baseService.getStandardHeaders(),
          )
          .timeout(Duration(seconds: baseService.timeOutSeconds));

      await baseService.handleDefaultResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<User> users =
            jsonResponse.map((json) => User.fromJson(json)).toList();
        return users;
      } else {
        throw Exception('Failed to fetch user data!');
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
