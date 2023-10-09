import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/utils/session_expired_exception.dart';
import 'package:andromeda_app/views/utils/session_expired_dialog.dart';
import 'package:flutter/material.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:provider/provider.dart';

class ProfileView {
  final String userId;
  late UserService userService;
  late User user;
  Future<void>? _cachedProfileData;
  final BuildContext parentContext;

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
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
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
            color: Colors.deepOrange,
          ));
        } else if (snapshot.hasError) {
          return const Text("Fehler beim Laden des Benutzers");
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
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Column(
        children: [
          _buildProfileAvatar(context),
          Expanded(
            child: ListView(
              children: [
                const Spacer(),
                _buildInfoCard(
                    "Email-Adresse", Icons.email, user.getEmail, context),
                _buildInfoCard(
                    "Alter",
                    Icons.cake,
                    user.getBirthYear.toString(),
                    context), // Should be actual age
                _buildInfoCard(
                    "Geschlecht", Icons.people, user.getGender, context),
                _buildInfoCard(
                    "Religion", Icons.book, user.getReligion, context),
                _buildInfoCard("Postleitzahl", Icons.location_pin,
                    user.getZipCode.toString(), context),
                _buildInfoCard(
                    "Partei",
                    Icons.gavel,
                    "${PartyManager().getPartyById(user.getSelectedParty).getName} (${PartyManager().getPartyById(user.getSelectedParty).getShortName})",
                    context),
                _buildInfoCard(
                    "Organisation", Icons.business, "Orgaaaaa", context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: MyApp.secondaryColor,
          child: Icon(Icons.person,
              size: MediaQuery.of(context).size.width * 0.1,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, IconData icon, String value, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
