import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/views/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/views/utils/dialogs.dart';

class ProfileEditView extends StatefulWidget {
  final User user;
  final List<Party> parties;
  final List<Organization> organizations;
  final Function(User, Function(BuildContext, String)) onUpdateProfile;
  final Function() logout;

  const ProfileEditView({
    Key? key,
    required this.user,
    required this.onUpdateProfile,
    required this.parties,
    required this.organizations,
    required this.logout,
  }) : super(key: key);

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late double spaceHeight;
  late double spaceWidth;
  late double radius;
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
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.height * 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [_buildLogoutFunction()],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(spaceHeight * 1.2),
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
        SizedBox(height: spaceHeight),
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
          child: CircleAvatar(
            radius: radius,
            backgroundColor: MyApp.secondaryColor,
            child: Icon(Icons.person, size: radius * 1.5, color: Colors.white),
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
          SizedBox(height: spaceHeight),
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
        margin: EdgeInsets.symmetric(vertical: spaceHeight / 2),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(radius / 2), // rounded corner radius
        ),
        child: Padding(
          padding: EdgeInsets.all(spaceHeight * 1.2),
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
              SizedBox(height: spaceHeight / 2), // space below title
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
      padding: EdgeInsets.only(top: spaceHeight * 1.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: spaceHeight * 2.15,
            width: spaceWidth * 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(spaceWidth * 3),
              color: value ? Colors.green[400] : Colors.redAccent,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 300),
                  left: value ? spaceWidth * 5 : 0.0,
                  right: value ? 0.0 : spaceWidth * 5,
                  child: SizedBox(
                    height: spaceHeight * 2.2,
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Meine Organisationen:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: (spaceHeight * 5 * selectedOrganizationIds.length),
            child: ReorderableListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = selectedOrganizationIds.removeAt(oldIndex);
                  selectedOrganizationIds.insert(newIndex, item);
                });
              },
              children: [
                for (int index = 0;
                    index < selectedOrganizationIds.length;
                    index++)
                  ReorderableDragStartListener(
                    index: index,
                    key: ValueKey(selectedOrganizationIds[index]),
                    child: Card(
                      child: ListTile(
                        leading: buildOrganizationImage(
                            OrganizationManager().getOrganizationById(
                                selectedOrganizationIds[index]),
                            CircleAvatar(
                              radius: radius / 3,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                  OrganizationManager()
                                      .getOrganizationById(
                                          selectedOrganizationIds[index])
                                      .getShortName[0],
                                  style: const TextStyle(color: Colors.white)),
                            )),
                        title: Text(OrganizationManager()
                            .getOrganizationById(selectedOrganizationIds[index])
                            .getShortName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: MyApp.secondaryColor),
                              onPressed: () {
                                setState(() {
                                  final organization = OrganizationManager()
                                      .getOrganizationById(
                                          selectedOrganizationIds[index]);
                                  selectedOrganizationIds.removeAt(index);
                                  unselectedOrganizations.add(organization);
                                });
                              },
                            ),
                            Icon(Icons.drag_handle,
                                color: Theme.of(context).primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: spaceHeight),
          const Text(
            'Organisationen:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: (unselectedOrganizations.isEmpty ? 0 : (spaceHeight * 4)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: unselectedOrganizations.length,
              itemBuilder: (context, index) {
                final organization = unselectedOrganizations[index];
                return buildChip(
                    organization.getShortName,
                    buildOrganizationImage(
                      OrganizationManager()
                          .getOrganizationById(organization.getId),
                      CircleAvatar(
                          radius: radius / 2,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                              OrganizationManager()
                                  .getOrganizationById(organization.getId)
                                  .getShortName[0],
                              style: const TextStyle(color: Colors.white))),
                    ),
                    const Icon(
                      Icons.add,
                      color: Colors.green,
                    ), () {
                  setState(() {
                    final organizations = widget.user.getSelectedOrganizations;
                    organizations.add(organization.getId);
                    widget.user.setSelectedOrganizations(organizations);
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChip(
      String label, Widget image, Widget action, VoidCallback? onDelete) {
    return Padding(
      padding: EdgeInsets.all(spaceHeight / 2),
      child: Chip(
        avatar: image,
        label: Text(label),
        deleteIcon: action,
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
        height: radius / 2,
        width: radius / 2,
        fit: BoxFit.cover,
        placeholder: const AssetImage("assets/images/placeholder.png"),
      ),
    );
  }

  Widget _buildPrivateInfoSection() => _buildCardContainer(
        "Persönliches",
        [
          SizedBox(height: spaceHeight),
          _buildBirthyearField(),
          SizedBox(height: spaceHeight),
          _buildGenderDropdown(),
          SizedBox(height: spaceHeight),
          _buildReligionDropdown(),
          SizedBox(height: spaceHeight * 2),
          _buildZipCodeField(),
          _buildSwitchRow(
            'Im Profil sichtbar?',
            widget.user.getShowPersonalInformationInProfile,
            (bool value) {
              setState(() {
                widget.user.setShowPersonalInformationInProfile(value);
              });
            },
          ),
        ],
      );

  Widget _buildBirthyearField() {
    return TextFormField(
      initialValue: widget.user.getBirthYear.toString(),
      decoration: InputDecoration(
        labelText: 'Geburtsjahr',
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.all(spaceHeight),
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
      decoration: InputDecoration(
        labelText: 'Postleitzahl',
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.all(spaceHeight),
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
      margin: EdgeInsets.only(top: spaceHeight / 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(spaceHeight),
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
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    Padding(
                        padding: EdgeInsets.only(top: spaceHeight),
                        child: const Text("Aktualisiere...")),
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
          padding: EdgeInsets.symmetric(
              horizontal: spaceWidth * 5, vertical: spaceHeight),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                spaceHeight), // Same corner radius as the container
          ),
        ),
        child: const Text('Profil aktualisieren'),
      ),
    );
  }
}
