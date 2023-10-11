import 'package:wind/main.dart';
import 'package:wind/models/organization_model.dart';
import 'package:wind/models/party_model.dart';
import 'package:wind/utils/session_expired_exception.dart';
import 'package:wind/utils/uri_helper.dart';
import 'package:wind/views/utils/session_expired_dialog.dart';
import 'package:flutter/material.dart';
import 'package:wind/models/user_model.dart';
import 'package:wind/services/user_service.dart';
import 'package:provider/provider.dart';

class ProfileView {
  final String userId;
  late UserService userService;
  late User user;
  Future<void>? _cachedProfileData;
  final BuildContext parentContext;
  late BuildContext currentContext;

  double spaceHeight = 0.0;
  double spaceWidth = 0.0;
  double radius = 0.0;

  ProfileView(this.userId, this.parentContext) {
    _cachedProfileData = _fetchProfileData(parentContext);
  }

  void showProfile() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: parentContext,
      builder: (BuildContext context) {
        spaceHeight = MediaQuery.of(context).size.height * 0.015;
        spaceWidth = MediaQuery.of(context).size.width * 0.015;
        radius = MediaQuery.of(context).size.height * 0.06;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: _buildUser(context),
        );
      },
    );
  }

  Widget _buildUser(BuildContext context) {
    return FutureBuilder<void>(
      future: _cachedProfileData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ));
        } else if (snapshot.hasError) {
          return const Center(child: Text("Fehler beim Laden des Benutzers"));
        } else {
          return Center(
            child: _buildProfile(context),
          );
        }
      },
    );
  }

  Future<void> _fetchProfileData(context) async {
    userService = Provider.of<UserService>(context, listen: false);
    try {
      user = await userService.getUserById(userId);
    } on SessionExpiredException catch (_) {
      showSessionExpiredDialog(context);
      rethrow;
    }
  }

  Widget _buildProfile(BuildContext context) {
    currentContext = context;
    final tileData = _createTileData();
    return Padding(
      padding: EdgeInsets.only(
          top: spaceHeight, right: spaceHeight, left: spaceHeight),
      child: Column(
        children: [
          _buildProfileAvatar(),
          SizedBox(height: spaceHeight),
          Expanded(
            child: ListView(
              children: [
                if (user.getShowPartyInProfile)
                  _buildInfoCard(
                      "Partei",
                      Icons.gavel,
                      "${PartyManager().getPartyById(user.getSelectedParty).getName} "
                          "(${PartyManager().getPartyById(user.getSelectedParty).getShortName})\n"),
                if (user.getShowOrganizationsInProfile)
                  _buildImageInfoCard("Organisationen", Icons.business,
                      _buildImageList(context)),
                if (user.getShowPersonalInformationInProfile)
                  buildMultiInfoCard("Persönliches", tileData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImageList(BuildContext context) {
    List<Widget> imagesWithText = List<Widget>.empty(growable: true);
    List<String> organizations = user.getSelectedOrganizations;

    for (var id in organizations.take(3)) {
      CircleAvatar avatar = CircleAvatar(
        radius: radius / 3,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          OrganizationManager().getOrganizationById(id).getShortName[0],
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      );

      imagesWithText.add(
        Column(
          children: [
            ClipOval(
              child: UriHelper.getUriByStringURL(OrganizationManager()
                          .getOrganizationById(id)
                          .getImageUrl) !=
                      null
                  ? FadeInImage(
                      image: NetworkImage(OrganizationManager()
                          .getOrganizationById(id)
                          .getImageUrl),
                      imageErrorBuilder:
                          (BuildContext context, Object y, StackTrace? z) {
                        return avatar;
                      },
                      height: radius / 1.5,
                      width: radius / 1.5,
                      fit: BoxFit.cover,
                      placeholder:
                          const AssetImage("assets/images/placeholder.gif"),
                    )
                  : avatar,
            ),
            Text(
              "${OrganizationManager().getOrganizationById(id).getShortName}\n",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return imagesWithText;
  }

  List<Map<String, dynamic>> _createTileData() {
    return [
      //{'title': 'Email-Adresse', 'icon': Icons.email, 'value': user.getEmail},
      {
        'title': 'Geburtsjahr',
        'icon': Icons.cake,
        'value': user.getBirthYear.toString()
      },
      {'title': 'Geschlecht', 'icon': Icons.people, 'value': user.getGender},
      {'title': 'Religion', 'icon': Icons.book, 'value': user.getReligion},
      //{
      //  'title': 'Postleitzahl',
      //  'icon': Icons.location_pin,
      //  'value': user.getZipCode.toString()
      //},
    ];
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: MyApp.secondaryColor,
              child:
                  Icon(Icons.person, size: radius * 1.5, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: spaceHeight),
        _buildProfileName(),
      ],
    );
  }

  Widget _buildProfileName() => Center(
        child: Text(
          user.getUsername,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildInfoCard(String title, IconData icon, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaceHeight * 1.2),
      ),
      margin: EdgeInsets.symmetric(vertical: spaceHeight),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(currentContext).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildImageInfoCard(String title, IconData icon, List<Widget> images) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spaceHeight * 1.2),
        ),
        margin: EdgeInsets.symmetric(vertical: spaceHeight),
        child: ListTile(
          leading: Icon(icon, color: Theme.of(currentContext).primaryColor),
          title: Padding(
              padding: EdgeInsets.only(bottom: spaceHeight / 2),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: images
                    .expand((image) => [
                          image,
                          SizedBox(
                            width: spaceWidth,
                            height: spaceHeight,
                          )
                        ])
                    .toList(),
              )),
        ));
  }

  Widget buildMultiInfoCard(
      String cardTitle, List<Map<String, dynamic>> tileData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaceHeight * 1.2),
      ),
      margin: EdgeInsets.symmetric(vertical: spaceHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(spaceHeight * 1.2),
            child: Text(
              cardTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...tileData.map((data) {
            return ListTile(
              leading: Icon(data['icon'] as IconData,
                  color: Theme.of(currentContext).primaryColor),
              title: Text(data['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['value'] as String),
            );
          }).toList(),
        ],
      ),
    );
  }
}
