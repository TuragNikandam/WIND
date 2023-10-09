import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/views/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/views/utils/dialogs.dart';

class ProfileView extends StatefulWidget {
  final User user;
  final List<Party> parties;
  final List<Organization> organizations;
  final Function(User, Function(BuildContext, String)) onUpdateProfile;
  final Function() logout;

  const ProfileView({
    Key? key,
    required this.user,
    required this.onUpdateProfile,
    required this.parties,
    required this.organizations,
    required this.logout,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
  }

  Uri? getUriByStringURL(String url) {
    try {
      return Uri.parse(url);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [_buildLogoutFunction()],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildProfileForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProfileForm() => [
        _buildProfileAvatar(),
        const SizedBox(height: 20),
        _buildProfileName(),
        _buildEmail(),
        _buildPartySection(),
        _buildOrganizationSection(),
        _buildPrivateInfoSection(),
        _buildUpdateButton(),
      ];

  Widget _buildLogoutFunction() => Center(
      child: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            widget.logout();
          }));

  Widget _buildProfileAvatar() => Center(
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: MyApp.secondaryColor,
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
        ),
      );

  Widget _buildProfileName() => Center(
        child: Text(
          widget.user.getUsername,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildEmail() => Center(
        child: Text(
          widget.user.getEmail,
          style: const TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildPartySection() => _buildCardContainer(
        "Parteizugehörigkeit",
        [
          _buildPartyPreferenceDropdown(),
          _buildSwitchRow(
            'Im Profil sichtbar?',
            widget.user.getShowPartyInProfile,
            (bool value) {
              setState(() {
                widget.user.setShowPartyInProfile(value);
              });
            },
          ),
        ],
      );

  Widget _buildOrganizationSection() => _buildCardContainer(
        "Organisationszugehörigkeit",
        [
          _buildOrganizationList(),
          _buildSwitchRow(
            'Im Profil sichtbar?',
            widget.user.getShowOrganizationsInProfile,
            (bool value) {
              setState(() {
                widget.user.setShowOrganizationsInProfile(value);
              });
            },
          ),
        ],
      );

  Widget _buildCardContainer(String title, List<Widget> children) => Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // rounded corner radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10), // space below title
              ...children
            ],
          ),
        ),
      );

  Widget _buildPartyPreferenceDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
          labelText: 'Ihre Partei', hintText: 'Wählen...'),
      value: widget.user.getSelectedParty,
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            widget.user.setSelectedParty(newValue);
          }
        });
      },
      items: widget.parties
          .map<DropdownMenuItem<String>>(
              (Party party) => DropdownMenuItem<String>(
                    value: party.getId,
                    child: Text(party.getName, overflow: TextOverflow.visible),
                  ))
          .toList(),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 28.0,
            width: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: value ? Colors.green[400] : Colors.grey[300],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 300),
                  left: value ? 30.0 : 0.0,
                  right: value ? 0.0 : 30.0,
                  child: SizedBox(
                    height: 28,
                    child: InkWell(
                      onTap: () {
                        onChanged(!value);
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: value
                            ? Icon(Icons.check_circle,
                                color: Colors.white, key: UniqueKey())
                            : Icon(Icons.remove_circle_outline,
                                color: Colors.white, key: UniqueKey()),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrganizationList() {
    // Extract IDs of selected organizations
    final selectedOrganizationIds = widget.user.getSelectedOrganizations;

    // Filter out already selected organizations
    final unselectedOrganizations = widget.organizations
        .where((org) => !selectedOrganizationIds.contains(org.getId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meine Organisationen:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.user.getSelectedOrganizations.length,
            itemBuilder: (context, index) {
              final organization = OrganizationManager().getOrganizationById(
                  widget.user.getSelectedOrganizations[index]);
              return buildChip(
                organization.getShortName,
                buildOrganizationImage(
                    organization,
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(organization.getShortName[0],
                          style: const TextStyle(color: Colors.white)),
                    )),
                () {
                  setState(() {
                    final organization = widget.user.getSelectedOrganizations;
                    organization.removeAt(index);
                    widget.user.setSelectedOrganizations(organization);
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Wählbare Organisationen:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: unselectedOrganizations.length,
            itemBuilder: (context, index) {
              final organization = unselectedOrganizations[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    final organizations = widget.user.getSelectedOrganizations;
                    organizations.add(organization.getId);
                    widget.user.setSelectedOrganizations(organizations);
                  });
                },
                child: buildChip(
                    organization.getShortName,
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    null),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildChip(String label, Widget image, VoidCallback? onDelete) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chip(
        avatar: image,
        label: Text(label),
        deleteIcon: onDelete == null
            ? null
            : const Icon(
                Icons.delete,
                color: Colors.red,
              ),
        onDeleted: onDelete,
      ),
    );
  }

  Widget buildOrganizationImage(Organization organization, Widget avatar) {
    Uri? uri = getUriByStringURL(organization.getImageUrl);
    return ClipOval(
      child: FadeInImage(
        image: NetworkImage(uri.toString()),
        imageErrorBuilder: (BuildContext context, Object y, StackTrace? z) {
          return avatar;
        },
        height: 90,
        width: 90,
        fit: BoxFit.cover,
        placeholder: const AssetImage("assets/images/placeholder.png"),
      ),
    );
  }

  Widget _buildPrivateInfoSection() => _buildCardContainer(
        "Persönliches",
        [
          const SizedBox(height: 10),
          _buildBirthyearField(),
          _buildGenderDropdown(),
          _buildReligionDropdown(),
          const SizedBox(height: 24),
          _buildZipCodeField(),
        ],
      );

  Widget _buildBirthyearField() {
    return TextFormField(
      initialValue: widget.user.getBirthYear.toString(),
      decoration: const InputDecoration(
        labelText: 'Geburtsjahr',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16.0),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        widget.user.setBirthYear(int.parse(value.isEmpty ? '0' : value));
      },
    );
  }

  Widget _buildZipCodeField() {
    return TextFormField(
      initialValue: widget.user.getZipCode.toString(),
      decoration: const InputDecoration(
        labelText: 'Postleitzahl',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16.0),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        widget.user.setZipCode(int.parse(value));
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Geschlechtszugehörigkeit'),
      value: widget.user.getGender,
      items: GenderText.getTexts().map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) widget.user.setGender(value);
      },
    );
  }

  Widget _buildReligionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Religionszugehörigkeit'),
      value: widget.user.getReligion,
      items: ReligionText.getTexts().map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) widget.user.setReligion(value);
      },
    );
  }

  void _showError(BuildContext context, String errorMessage) {
    Dialogs.showErrorDialog(
        context, 'Fehler beim Aktualisieren', 'Behebe ich!', errorMessage);
  }

  Widget _buildUpdateButton() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          // Show loading indicator
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Aktualisiere...")),
                  ],
                ),
              );
            },
          );
          await Future.delayed(
              const Duration(milliseconds: 850)); // Dummy wait time
          if (context.mounted) Navigator.of(context).pop();
          widget.onUpdateProfile(widget.user, _showError);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10), // Same corner radius as the container
          ),
        ),
        child: const Text('Profil aktualisieren'),
      ),
    );
  }
}
