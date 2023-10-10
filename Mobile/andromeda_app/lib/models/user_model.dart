import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String _id = "";
  String _username = "";
  String _email = "";
  String _password = "";
  String _selectedParty = "";
  List<String> _selectedOrganizations = List.empty(growable: true);
  bool _showPartyInProfile = false;
  bool _showOrganizationsInProfile = false;
  int _birthYear = 0000;
  String _gender = "";
  String _religion = "";
  int _zipCode = 0000;
  bool _isGuest = false;
  bool _showPersonalInformationInProfile = false;

  // Getters
  String get getId => _id;
  String get getUsername => _username;
  String get getEmail => _email;
  String get getPassword => _password;
  String get getSelectedParty => _selectedParty;
  List<String> get getSelectedOrganizations => _selectedOrganizations;
  bool get getShowPartyInProfile => _showPartyInProfile;
  bool get getShowOrganizationsInProfile => _showOrganizationsInProfile;
  int get getBirthYear => _birthYear;
  String get getGender => _gender;
  String get getReligion => _religion;
  int get getZipCode => _zipCode;
  bool get getIsGuest => _isGuest;
  bool get getShowPersonalInformationInProfile =>
      _showPersonalInformationInProfile;

  // Setters
  void setId(String value) {
    _id = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setSelectedParty(String value) {
    _selectedParty = value;
    notifyListeners();
  }

  void setSelectedOrganizations(List<String> value) {
    _selectedOrganizations = value;
    notifyListeners();
  }

  void setShowPartyInProfile(bool value) {
    _showPartyInProfile = value;
    notifyListeners();
  }

  void setShowOrganizationsInProfile(bool value) {
    _showOrganizationsInProfile = value;
    notifyListeners();
  }

  void setBirthYear(int value) {
    _birthYear = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setReligion(String value) {
    _religion = value;
    notifyListeners();
  }

  void setZipCode(int value) {
    _zipCode = value;
    notifyListeners();
  }

  void setIsGuest(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  void setShowPersonalInformationInProfile(bool value) {
    _showPersonalInformationInProfile = value;
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
    setShowOrganizationsInProfile(newUser.getShowPersonalInformationInProfile);
  }

// Static method to create a User object from a JSON map
  static User fromJson(Map<String, dynamic> json) {
    User user = User();
    user.setId(json['_id'] ?? "");
    user.setEmail(json['email'] ?? "");
    user.setUsername(json['username'] ?? "");
    user.setBirthYear(json['birthyear'] ?? 0);
    user.setGender(json['gender']);
    user.setReligion(json['religion']);
    user.setZipCode(json['zipCode'] ?? 0);
    user.setShowPartyInProfile(json['party']['visible'] ?? false);
    user.setSelectedParty(json['party']['id']);
    user.setShowOrganizationsInProfile(
        json['organizations']['visible'] ?? false);
    user.setSelectedOrganizations(
        List<String>.from(json['organizations']['ids'] ?? List.empty()));
    user.setIsGuest(json['isGuest'] ?? false);
    user.setShowOrganizationsInProfile(
        json['personalInformationVisible'] ?? false);
    return user;
  }

  Map<String, dynamic> toJsonRegister() {
    return {
      'username': _username,
      'password': _password,
      'email': _email,
      'party': {
        'visible': _showPartyInProfile,
        'id': _selectedParty,
      },
      'organizations': {
        'visible': _showOrganizationsInProfile,
        'ids': _selectedOrganizations,
      },
      'birthyear': _birthYear,
      'gender': _gender,
      'religion': _religion,
      'zipCode': _zipCode,
      'isGuest': _isGuest,
      'personalInformationVisible': _showPersonalInformationInProfile,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'username': _username,
      'email': _email,
      'party': {
        'visible': _showPartyInProfile,
        'id': _selectedParty,
      },
      'organizations': {
        'visible': _showOrganizationsInProfile,
        'ids': _selectedOrganizations,
      },
      'birthyear': _birthYear,
      'gender': _gender,
      'religion': _religion,
      'zipCode': _zipCode,
      'isGuest': _isGuest,
      'personalInformationVisible': _showPersonalInformationInProfile,
    };
  }
}
