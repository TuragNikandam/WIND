class Discussion {
  String _id = "";
  String _title = "";
  DateTime _creationDate = DateTime(0);
  String _authorId = "";
  String _username = "";
  String _topicId = "";
  int _postCount = 0;

  // Getters
  String get getId => _id;
  String get getTitle => _title;
  DateTime get getCreationDate => _creationDate;
  String get getAuthorId => _authorId;
  String get getUsername => _username;
  String get getTopicId => _topicId;
  int get getPostCount => _postCount;

  // Setters
  void setId(String id) {
    _id = id;
  }

  void setTitle(String title) {
    _title = title;
  }

  void setCreationDate(DateTime creationDate) {
    _creationDate = creationDate;
  }

  void setAuthorId(String authorId) {
    _authorId = authorId;
  }

  void setUsername(String username) {
    _username = username;
  }

  void setTopicId(String topicId) {
    _topicId = topicId;
  }

  void setPostCount(int postCount) {
    _postCount = postCount;
  }

  // Create a Discussion object from JSON
  static Discussion fromJson(Map<String, dynamic> json) {
    Discussion discussion = Discussion();
    discussion.setId(json['_id'] ?? "");
    discussion.setTitle(json['title'] ?? "");
    discussion.setCreationDate(
        DateTime.parse(json['creationDate'] ?? DateTime(0).toString()));
    discussion.setAuthorId(json['author']['_id'] ?? "");
    discussion.setUsername(json['author']['username'] ?? 'Unbekannt');
    discussion.setTopicId(json['topic'] ?? "");
    discussion.setPostCount(json['postCount'] ?? 0);
    return discussion;
  }

  // Convert Discussion object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': _title,
      'author': _authorId,
      'topic': _topicId,
    };
  }
}

class DiscussionPost {
  String _id = "";
  String _content = "";
  DateTime _creationDate = DateTime(0);
  String _username = "";
  String _authorId = "";
  String _discussionId = "";
  String _partyId = "";
  bool _partyIsVisible = false;

  // Getters
  String get getId => _id;
  String get getContent => _content;
  DateTime get getCreationDate => _creationDate;
  String get getUsername => _username;
  String get getAuthorId => _authorId;
  String get getDiscussionId => _discussionId;
  String get getPartyId => _partyId;
  bool get getPartyIsVisible => _partyIsVisible;

  // Setters
  void setId(String id) {
    _id = id;
  }

  void setContent(String content) {
    _content = content;
  }

  void setCreationDate(DateTime creationDate) {
    _creationDate = creationDate;
  }

  void setUsername(String username) {
    _username = username;
  }

  void setAuthorId(String authorId) {
    _authorId = authorId;
  }

  void setDiscussionId(String discussionId) {
    _discussionId = discussionId;
  }

  void setPartyId(String partyId) {
    _partyId = partyId;
  }

  void setPartyIsVisible(bool isVisible) {
    _partyIsVisible = isVisible;
  }

  // Create a DiscussionPost object from JSON
  static DiscussionPost fromJson(Map<String, dynamic> json) {
    DiscussionPost post = DiscussionPost();
    post.setId(json['_id'] ?? "");
    post.setContent(json['content'] ?? "");
    post.setCreationDate(
        DateTime.parse(json['creationDate'] ?? DateTime(0).toString()));
    post.setAuthorId(json['author']["_id"] ?? "");
    post.setUsername(json['author']['username'] ?? 'Unbekannt');
    post.setPartyId(json['author']["party"]["id"] ?? "");
    post.setPartyIsVisible(json['author']["party"]["visible"] ?? false);
    post.setDiscussionId(json['discussionId'] ?? "");
    return post;
  }

  // Convert DiscussionPost object to JSON
  Map<String, dynamic> toJson() {
    return {
      'content': _content,
      'author': _authorId,
    };
  }
}
