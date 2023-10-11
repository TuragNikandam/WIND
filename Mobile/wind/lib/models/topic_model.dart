class Topic {
  String _id = "";
  String _name = "";
  String _description = "";

  String get getId => _id;
  String get getName => _name;
  String get getDescription => _description;

  // Create a Party object from JSON
  void fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _name = json['name'];
    _description = json['description'];
  }
}

class TopicManager {
  static final TopicManager _instance = TopicManager._internal();

  factory TopicManager() {
    return _instance;
  }

  TopicManager._internal();

  final List<Topic> _topicList = [];

  List<Topic> get getTopicList => _topicList;

  void addItem(Topic topic) {
    _topicList.add(topic);
  }

  bool isTopicsEmpty() {
    return _topicList.isEmpty ? true : false;
  }

  Topic getTopicById(String id) {
    return _topicList.firstWhere((element) => element.getId == id);
  }
}
