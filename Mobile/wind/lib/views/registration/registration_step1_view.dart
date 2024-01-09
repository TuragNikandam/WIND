import 'package:wind/models/party_model.dart';
import 'package:wind/models/user_model.dart';
import 'package:wind/views/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep1View extends StatefulWidget {
  final Function(String?, bool, Function(BuildContext, String)) onStep2;
  final List<Party> parties;

  const RegistrationStep1View(
      {super.key, required this.onStep2, required this.parties});

  @override
  State<RegistrationStep1View> createState() => _RegistrationStep1ViewState();
}

class _RegistrationStep1ViewState extends State<RegistrationStep1View> {
  late User user;
  late double spaceHeight;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    return Scaffold(
      appBar: AppBar(title: const Text('Parteipräferenz')),
      body: Padding(
        padding: EdgeInsets.all(spaceHeight * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
                isExpanded: true,
                value: user.getSelectedParty.isEmpty
                    ? null
                    : user.getSelectedParty,
                hint: const Text('Partei'),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      user.setSelectedParty(newValue);
                    }
                  });
                },
                items:
                    widget.parties.map<DropdownMenuItem<String>>((Party party) {
                  return DropdownMenuItem<String>(
                    value: party.getId,
                    child: Text("${party.getName} (${party.getShortName})"),
                  );
                }).toList()),
            Row(
              children: [
                const Text('Im Profil anzeigen?'),
                Switch(
                  value: user.getShowPartyInProfile,
                  onChanged: (bool value) {
                    setState(() {
                      user.setShowPartyInProfile(value);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: spaceHeight),
            ElevatedButton(
              onPressed: () => widget.onStep2(user.getSelectedParty,
                  user.getShowPartyInProfile, _showError),
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String errorMessage) {
    Dialogs.showErrorDialog(
        context, 'Fehler beim Registrieren', 'Behebe ich!', errorMessage);
  }
}
