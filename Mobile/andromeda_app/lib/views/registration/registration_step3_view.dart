import 'package:andromeda_app/views/utils/dialogs.dart';
import 'package:andromeda_app/views/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationStep3View extends StatefulWidget {
  final Function(int, int, String?, String?, Function(BuildContext, String)) onRegister;
  const RegistrationStep3View({super.key, required this.onRegister});

  @override
  State<RegistrationStep3View> createState() => _RegistrationStep3ViewState();
}

class _RegistrationStep3ViewState extends State<RegistrationStep3View> {
  final _birthYearController = TextEditingController();
  final _zipCodeController = TextEditingController();
  String? _selectedGender;
  String? _selectedReligion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persönliche Daten')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFieldWithIcon(
              controller: _birthYearController,
              labelText: 'Geburtsjahr',
              icon: Icons.help_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildDropdownWithIcon(
              value: _selectedGender,
              hint: 'Geschlechtszugehörigkeit auswählen',
              items: GenderText.getTexts(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              icon: Icons.help_outline,
            ),
            const SizedBox(height: 16),
            _buildDropdownWithIcon(
              value: _selectedReligion,
              hint: 'Religionszugehörigkeit auswählen',
              items: ReligionText.getTexts(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedReligion = newValue;
                });
              },
              icon: Icons.help_outline,
            ),
            const SizedBox(height: 16),
            _buildTextFieldWithIcon(
              controller: _zipCodeController,
              labelText: 'Postleitzahl',
              icon: Icons.help_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => widget.onRegister(
                int.parse(_birthYearController.text.isEmpty ? "0" : _birthYearController.text), 
                int.parse(_zipCodeController.text.isEmpty ? "0" : _zipCodeController.text), 
                _selectedGender, 
                _selectedReligion, 
                _showError),
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(icon),
          onPressed: () {
            //TODO: Tooltip
          },
        ),
      ),
    );
  }

  Widget _buildDropdownWithIcon({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(icon),
          onPressed: () {
            //TODO: Tooltip
          },
        ),
      ),
    );
  }

  void _showError(BuildContext context, String errorMessage) {
    Dialogs.showErrorDialog(context, 'Fehler beim Registrieren', 'Behebe ich!', errorMessage);
  }

}
