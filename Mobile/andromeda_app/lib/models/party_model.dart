class Party {
  String _id = "";
  String _name = "";
  String _shortName = "";
  String _imageUrl = "";
  String _imageAltText = "";

  String get getId => _id;
  String get getName => _name;
  String get getShortName => _shortName;
  String get getImageUrl => _imageUrl;
  String get getImageAltText => _imageAltText;

  // Create a Party object from JSON
  void fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _name = json['name'];
    _shortName = json['shortName'];
    _imageUrl = json['image']['url'];
    _imageAltText = json['image']['altText'];
  }
}

class PartyManager {
  static final PartyManager _instance = PartyManager._internal();

  factory PartyManager() {
    return _instance;
  }

  PartyManager._internal();

  final List<Party> _partyList = [];

  List<Party> get getPartyList => _partyList;

  void addItem(Party party) {
    _partyList.add(party);
  }

  void clearItems() {
    _partyList.clear();
  }

  bool isPartiesEmpty() {
    return _partyList.isEmpty ? true : false;
  }

  Party getPartyById(String id) {
    return _partyList.firstWhere((element) => element.getId == id);
  }
}
