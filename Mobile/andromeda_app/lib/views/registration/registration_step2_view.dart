import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep2View extends StatefulWidget {
  final Function(List<String>, bool) onStep3;
  final List<Organization> organizations;

  const RegistrationStep2View(
      {super.key, required this.onStep3, required this.organizations});

  @override
  State<RegistrationStep2View> createState() => _RegistrationStep2ViewState();
}

class _RegistrationStep2ViewState extends State<RegistrationStep2View> {
  late User user;
  bool _showInProfile = false;
  List<String> _selectedOrganizationIds = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    _selectedOrganizationIds = user.getSelectedOrganizations;
    _showInProfile = user.getShowOrganizationsInProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organisationen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.organizations.length,
              itemBuilder: (context, index) {
                final org = widget.organizations[index];
                return CheckboxListTile(
                  title: Text("${org.getName} (${org.getShortName})"),
                  value: _selectedOrganizationIds.contains(org.getId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedOrganizationIds.add(org.getId);
                      } else {
                        _selectedOrganizationIds.remove(org.getId);
                      }
                    });
                  },
                );
              },
            ),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onStep3(
                    _selectedOrganizationIds.toList(), _showInProfile);
              },
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}
