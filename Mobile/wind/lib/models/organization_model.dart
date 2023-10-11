class Organization {
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

  void fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _name = json['name'];
    _shortName = json['shortName'];
    _imageUrl = json['image']['url'];
    _imageAltText = json['image']['altText'];
  }
}

class OrganizationManager {
  static final OrganizationManager _instance = OrganizationManager._internal();

  factory OrganizationManager() {
    return _instance;
  }

  OrganizationManager._internal();

  final List<Organization> _organizationList = [];

  List<Organization> get getOrganizationList => _organizationList;

  void addItem(Organization organization) {
    _organizationList.add(organization);
  }

  void clearItems() {
    _organizationList.clear();
  }

  bool isOrganizationsEmpty() {
    return _organizationList.isEmpty ? true : false;
  }

  Organization getOrganizationById(String id) {
    return _organizationList.firstWhere((element) => element.getId == id);
  }
}
