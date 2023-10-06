import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String id = "";
  String username = "";
  String email = "";
  String password = "";
  String selectedParty = "";
  List<String> selectedOrganizations = List.empty(growable: true);
  bool showPartyInProfile = false;
  bool showOrganizationsInProfile = false;
  int birthYear = 0000;
  String gender = "";
  String religion = "";
  int zipCode = 0000;
  bool isGuest = false;

  // Getters
  String get getId => id;
  String get getUsername => username;
  String get getEmail => email;
  String get getPassword => password;
  String get getSelectedParty => selectedParty;
  List<String> get getSelectedOrganizations => selectedOrganizations;
  bool get getShowPartyInProfile => showPartyInProfile;
  bool get getShowOrganizationsInProfile => showOrganizationsInProfile;
  int get getBirthYear => birthYear;
  String get getGender => gender;
  String get getReligion => religion;
  int get getZipCode => zipCode;
  bool get getIsGuest => isGuest;

  // Setters
  void setId(String value) {
    id = value;
    notifyListeners();
  }

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setSelectedParty(String value) {
    selectedParty = value;
    notifyListeners();
  }

  void setSelectedOrganizations(List<String> value) {
    selectedOrganizations = value;
    notifyListeners();
  }

  void setShowPartyInProfile(bool value) {
    showPartyInProfile = value;
    notifyListeners();
  }

  void setShowOrganizationsInProfile(bool value) {
    showOrganizationsInProfile = value;
    notifyListeners();
  }

  void setBirthYear(int value) {
    birthYear = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setReligion(String value) {
    religion = value;
    notifyListeners();
  }

  void setZipCode(int value) {
    zipCode = value;
    notifyListeners();
  }

  void setIsGuest(bool value) {
    isGuest = value;
    notifyListeners();
  }

  void updateAllFields(User newUser) {
    setId(newUser.getId);
    setUsername(newUser.getUsername);
    setEmail(newUser.getEmail);
    setPassword(newUser.getPassword);
    setSelectedParty(newUser.getSelectedParty);
    setSelectedOrganizations(newUser.getSelectedOrganizations);
    setShowPartyInProfile(newUser.getShowPartyInProfile);
    setShowOrganizationsInProfile(newUser.getShowOrganizationsInProfile);
    setBirthYear(newUser.getBirthYear);
    setGender(newUser.getGender);
    setReligion(newUser.getReligion);
    setZipCode(newUser.getZipCode);
    setIsGuest(newUser.getIsGuest);
  }

// Static method to create a User object from a JSON map
  static User fromJson(Map<String, dynamic> json) {
    User user = User();
    user.setId(json['_id'] ?? "");
    user.setUsername(json['username'] ?? "");
    user.setEmail(json['email'] ?? "");
    user.setPassword(json['password'] ?? "");
    user.setBirthYear(json['birthyear'] ?? 0);
    user.setGender(json['gender']);
    user.setReligion(json['religion']);
    user.setZipCode(json['zip_code'] ?? 0);
    user.setShowPartyInProfile(json['party']['visible'] ?? false);
    user.setSelectedParty(json['party']['id']);
    user.setShowOrganizationsInProfile(
        json['organizations']['visible'] ?? false);
    user.setSelectedOrganizations(
        List<String>.from(json['organizations']['ids'] ?? List.empty()));
    user.setIsGuest(json['is_guest'] ?? false);
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'party': {
        'visible': showPartyInProfile,
        'id': selectedParty,
      },
      'organizations': {
        'visible': showOrganizationsInProfile,
        'ids': selectedOrganizations,
      },
      'birthyear': birthYear,
      'gender': gender,
      'religion': religion,
      'zip_code': zipCode,
      'is_guest': isGuest,
    };
  }
}
