import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/utils/uri_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep2View extends StatefulWidget {
  final Function(List<String>, bool) onStep3;
  final List<Organization> organizations;

  const RegistrationStep2View({
    super.key,
    required this.onStep3,
    required this.organizations,
  });

  @override
  State<RegistrationStep2View> createState() => _RegistrationStep2ViewState();
}

class _RegistrationStep2ViewState extends State<RegistrationStep2View> {
  late User user;
  bool _showInProfile = false;
  List<String> _selectedOrganizations = List.empty(growable: true);
  List<Organization> _unselectedOrganizations = List.empty(growable: true);
  late double spaceHeight;
  late double spaceWidth;
  late double radius;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    _selectedOrganizations = user.getSelectedOrganizations;
    _showInProfile = user.getShowOrganizationsInProfile;

    // Filter out already selected organizations
    _unselectedOrganizations = widget.organizations
        .where((org) => !_selectedOrganizations.contains(org.getId))
        .toList();
  }

  Widget buildChip(String label, Widget image, VoidCallback? onDelete) {
    return Padding(
      padding: EdgeInsets.all(spaceHeight),
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
    return ClipOval(
      child: UriHelper.getUriByStringURL(organization.getImageUrl) != null
          ? FadeInImage(
              image: NetworkImage(organization.getImageUrl),
              imageErrorBuilder:
                  (BuildContext context, Object y, StackTrace? z) {
                return avatar;
              },
              height: radius * 2,
              width: radius * 2,
              fit: BoxFit.cover,
              placeholder: const AssetImage("assets/images/placeholder.png"),
            )
          : avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    spaceWidth = MediaQuery.of(context).size.width * 0.015;
    radius = MediaQuery.of(context).size.height * 0.03;
    return Scaffold(
      appBar: AppBar(title: const Text('Organisationen')),
      body: Padding(
        padding: EdgeInsets.all(spaceHeight * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Panel for Available Organizations
            Container(
              padding: EdgeInsets.all(spaceHeight),
              color: MyApp.secondaryColor,
              child: Row(
                children: [
                  const Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                  SizedBox(width: spaceWidth * 2),
                  const Text(
                    'Organisationen:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: ListView.builder(
                itemCount: _unselectedOrganizations.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final organization = _unselectedOrganizations[index];
                  return Card(
                    child: ListTile(
                      leading: buildOrganizationImage(
                          organization,
                          CircleAvatar(
                            radius: radius,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                                OrganizationManager()
                                    .getOrganizationById(organization.getId)
                                    .getShortName[0],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 40)),
                          )),
                      title: Text(organization.getShortName),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedOrganizations.add(organization.getId);
                            _unselectedOrganizations.remove(organization);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spaceWidth),
            // Bottom Panel for Selected Organizations
            Container(
              padding: EdgeInsets.all(spaceHeight),
              color: MyApp.secondaryColor,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: spaceWidth),
                  const Text(
                    'Meine Organisationen:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: ReorderableListView(
                shrinkWrap: true,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _selectedOrganizations.removeAt(oldIndex);
                    _selectedOrganizations.insert(newIndex, item);
                  });
                },
                children: [
                  for (int index = 0;
                      index < _selectedOrganizations.length;
                      index++)
                    ReorderableDragStartListener(
                      index: index,
                      key: ValueKey(_selectedOrganizations[index]),
                      child: Card(
                        child: ListTile(
                          leading: buildOrganizationImage(
                              OrganizationManager().getOrganizationById(
                                  _selectedOrganizations[index]),
                              CircleAvatar(
                                radius: radius,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                    OrganizationManager()
                                        .getOrganizationById(
                                            _selectedOrganizations[index])
                                        .getShortName[0],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 40)),
                              )),
                          title: Text(OrganizationManager()
                              .getOrganizationById(
                                  _selectedOrganizations[index])
                              .getShortName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_rounded,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    final organization = OrganizationManager()
                                        .getOrganizationById(
                                            _selectedOrganizations[index]);
                                    _selectedOrganizations.removeAt(index);
                                    _unselectedOrganizations.add(organization);
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
            SizedBox(height: spaceHeight * 2),
            Row(
              children: [
                const Text('Im Profil anzeigen?'),
                Switch(
                  value: _showInProfile,
                  onChanged: (bool value) {
                    setState(() {
                      _showInProfile = value;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                widget.onStep3(_selectedOrganizations, _showInProfile);
              },
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}
