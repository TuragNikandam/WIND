class NewsArticle {
  String _id = '';
  String _headline = '';
  ArticleImage _image = ArticleImage();
  String _content = '';
  String _topicId = '';
  String _createdBy = '';
  List<String> _sources = List.empty(growable: true);
  DateTime _creationDate = DateTime(0);
  int _viewCount = 0;

  // Getters
  String get getId => _id;
  String get getHeadline => _headline;
  ArticleImage get getImage => _image;
  String get getContent => _content;
  String get getTopic => _topicId;
  String get getCreatedBy => _createdBy;
  DateTime get getCreationDate => _creationDate;
  int get getViewCount => _viewCount;
  List<String> get getSources => _sources;

  // Setters
  void setId(String id) {
    _id = id;
  }

  void setHeadline(String headline) {
    _headline = headline;
  }

  void setImage(ArticleImage img) {
    _image = img;
  }

  void setContent(String content) {
    _content = content;
  }

  void setTopicId(String topicId) {
    _topicId = topicId;
  }

  void setCreatedBy(String userId) {
    _createdBy = userId;
  }

  void setCreationDate(DateTime date) {
    _creationDate = date;
  }

  void setViewCount(int count) {
    _viewCount = count;
  }

  void setSources(List<String> sources) {
    _sources = sources;
  }

  // Static method to create a NewsArticle object from a JSON map
  static NewsArticle fromJson(Map<String, dynamic> json) {
    NewsArticle article = NewsArticle();
    article.setId(json['_id'] ?? '');
    article.setHeadline(json['headline'] ?? '');
    article.setImage(ArticleImage.fromJson(json['image'] ?? {}));
    article.setContent(json['content'] ?? '');
    article.setTopicId(json['topic'] ?? '');
    article.setCreatedBy(json['createdBy'] ?? '');
    article.setCreationDate(
        DateTime.parse(json['creationDate'] ?? DateTime(0).toString()));
    article.setViewCount(json['viewCount'] ?? 0);
    article.setSources(
        List<String>.from(json['sources'] ?? List.empty(growable: true)));
    return article;
  }

  // Method to convert NewsArticle object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'headline': _headline,
      'image': _image.toJson(),
      'content': _content,
      'topic': _topicId,
      'createdBy': _createdBy,
    };
  }
}

class ArticleImage {
  String _url = '';
  String _altText = '';

  // Getters
  String get getUrl => _url;
  String get getAltText => _altText;

  // Setters
  void setUrl(String u) {
    _url = u;
  }

  void setAltText(String text) {
    _altText = text;
  }

  // Static method to create an Image object from a JSON map
  static ArticleImage fromJson(Map<String, dynamic> json) {
    ArticleImage img = ArticleImage();
    img.setUrl(json['url'] ?? '');
    img.setAltText(json['altText'] ?? '');
    return img;
  }

  // Method to convert Image object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'url': _url,
      'altText': _altText,
    };
  }
}

class NewsArticleComment {
  String _content = '';
  String _username = '';
  String _authorId = '';
  String _links = '';
  DateTime _creationDate = DateTime(0);

  String get getContent => _content;
  String get getAuthorId => _authorId;
  String get getUsername => _username;
  DateTime get getCreationDate => _creationDate;
  String get getLinks => _links;

  void setContent(String content) {
    _content = content;
  }

  void setAuthorId(String authorId) {
    _authorId = authorId;
  }

  void setUsername(String username) {
    _username = username;
  }

  void setCreationDate(DateTime creationDate) {
    _creationDate = creationDate;
  }

  void setLinks(String links) {
    _links = links;
  }

  // Static method to create an Image object from a JSON map
  static NewsArticleComment fromJson(Map<String, dynamic> json) {
    NewsArticleComment comment = NewsArticleComment();
    comment.setContent(json['content'] ?? '');
    comment.setAuthorId(json['author']['_id'] ?? '');
    comment.setUsername(json['author']['username'] ?? 'Unbekannt');
    comment.setCreationDate(DateTime.parse(json['date'] ?? DateTime(0)));
    comment.setLinks(json['links'] ?? '');
    return comment;
  }

  // Method to convert object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'content': _content,
      'author': _authorId,
      'links': _links,
    };
  }
}
