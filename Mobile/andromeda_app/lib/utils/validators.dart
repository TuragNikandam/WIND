import 'package:andromeda_app/services/user_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Validators {
  static String? validateUsername(String username) {
    if (username.isEmpty || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
      return "Ungültiger Benutzername. Er muss alphanumerisch und nicht leer sein.";
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (!EmailValidator.validate(email)) {
      return "Ungültige E-Mail Adresse.";
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(password)) {
      return "Das Passwort muss mindestens 8 Zeichen, einen Großbuchstaben, eine Zahl und ein Sonderzeichen (@,\$,!,%,*,?,&) enthalten.";
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return "Kennwort und Bestätigungskennwort stimmen nicht überein.";
    }
    return null;
  }

  static String? validateBirthYear(int birthYear) {
    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear;

    if (0 <= age && age < 16) {
      return 'Sie müssen mindestens 16 Jahre alt sein, um wählen zu können. [Quelle: machs-ab-16.de, Zugriff: 28.08.2023]'; //[Erfahren Sie mehr](https://www.bundeswahlleiterin.de/service/glossar/w/wahlalter.html#id-0)
    }
    else if (age > 135) {
      return 'Ungültiges Geburtsjahr. Bitte geben Sie ein gültiges Alter ein.';
    }
    else if (age < 0)
    {
      return 'Ungültiges Geburtsjahr. Das Geburtsjahr liegt in der Zukunft.';
    }
    return null;
  }

  static String? validateZipCode(int zipCode) {
    // Convert int to String for RegExp matching
    String zipCodeStr = zipCode.toString();

    if (!RegExp(r'^\d{5}$').hasMatch(zipCodeStr)) {
      return 'Ungültige Postleitzahl. Bitte geben Sie eine gültige deutsche Postleitzahl ein.';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Bitte füllen Sie das Feld $fieldName aus.';
    }
    return null;
  }

  static Future<String?> usernameExists(BuildContext context, String username) async {
    UserService userService = Provider.of<UserService>(context, listen: false);
    if(await userService.usernameExists(username))
    {
      return 'Der Benutzername exisitiert bereits.\nBitte wählen Sie einen anderen Namen.';
    }
    return null;
  }

  static Future<String?> emailExists(BuildContext context, String email) async {
    UserService userService = Provider.of<UserService>(context, listen: false);
    if(await userService.emailExists(email))
    {
      return 'Die E-Mail Adresse exisitiert bereits.\nLoggen Sie sich ein oder wählen Sie eine andere Adresse.';
    }
    return null;
  }
}
