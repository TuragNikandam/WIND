import 'package:flutter/foundation.dart';

class Option extends ChangeNotifier {
  String _id;
  String _text;
  int _voteCount;
  List<String> _votedUsers;

  Option({
    required String id,
    required String text,
    int voteCount = 0,
    List<String> votedUsers = const [],
  })  : _id = id,
        _text = text,
        _voteCount = voteCount,
        _votedUsers = votedUsers;

  // Getters
  String get id => _id;
  String get text => _text;
  int get voteCount => _voteCount;
  List<String> get votedUsers => _votedUsers;

  // Setters
  void setId(String value) {
    _id = value;
    notifyListeners();
  }

  void setText(String value) {
    _text = value;
    notifyListeners();
  }

  void setVoteCount(int value) {
    _voteCount = value;
    notifyListeners();
  }

  void setVotedUsers(List<String> value) {
    _votedUsers = value;
    notifyListeners();
  }

  void incrementVoteCount(String id) {
    _voteCount++;
    _votedUsers.add(id);
    notifyListeners();
  }

  // Static method to create an Option object from a JSON map
  static Option fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['_id'] ?? "",
      text: json['text'] ?? "",
      voteCount: json['voteCount'] ?? 0,
      votedUsers: List<String>.from(json['votedUsers'] ?? []),
    );
  }

  // Method to convert Option object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'text': _text,
      'voteCount': _voteCount,
      'votedUsers': _votedUsers,
    };
  }
}

class Voting extends ChangeNotifier {
  String _id = "";
  String _question = "";
  List<Option> _options = List.empty(growable: true);
  bool _multipleChoices = false;
  String _topic = "";
  DateTime _creationDate = DateTime(0);
  DateTime _expirationDate = DateTime(0);

  // Getters
  String get id => _id;
  String get question => _question;
  List<Option> get options => _options;
  bool get multipleChoices => _multipleChoices;
  String get topic => _topic;
  DateTime get creationDate => _creationDate;
  DateTime get expirationDate => _expirationDate;

  // Setters
  void setId(String value) {
    _id = value;
    notifyListeners();
  }

  void setQuestion(String value) {
    _question = value;
    notifyListeners();
  }

  void setOptions(List<Option> value) {
    _options = value;
    notifyListeners();
  }

  void setMultipleChoices(bool value) {
    _multipleChoices = value;
    notifyListeners();
  }

  void setTopic(String value) {
    _topic = value;
    notifyListeners();
  }

  void setCreationDate(DateTime value) {
    _creationDate = value;
    notifyListeners();
  }

  void setExpirationDate(DateTime value) {
    _expirationDate = value;
    notifyListeners();
  }

  // Static method to create a Voting object from a JSON map
  static Voting fromJson(Map<String, dynamic> json) {
    Voting voting = Voting();
    voting.setId(json['_id'] ?? "");
    voting.setQuestion(json['question'] ?? "");
    voting.setOptions(List<Option>.from(
        (json['options'] ?? []).map((e) => Option.fromJson(e))));
    voting.setMultipleChoices(json['multipleChoices'] ?? false);
    voting.setTopic(json['topic'] ?? "");
    voting.setCreationDate(
        DateTime.parse(json['creationDate'] ?? DateTime.now().toString()));
    voting.setExpirationDate(
        DateTime.parse(json['expirationDate'] ?? DateTime.now().toString()));

    return voting;
  }

  // Method to convert Voting object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'question': _question,
      'options': _options.map((e) => e.toJson()).toList(),
      'multipleChoices': _multipleChoices,
      'topic': _topic,
      'creationDate': _creationDate.toIso8601String(),
      'expirationDate': _expirationDate.toIso8601String(),
    };
  }
}
