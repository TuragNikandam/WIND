import 'package:wind/views/utils/dialogs.dart';
import 'package:flutter/material.dart';

class RegistrationView extends StatefulWidget {
  final Function(String, String, String, String, Function(BuildContext, String))
      onStep1;

  const RegistrationView({super.key, required this.onStep1});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  late double spaceHeight;
  bool isTermsAndConditionsChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    spaceHeight = MediaQuery.of(context).size.height * 0.015;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrierung'),
        automaticallyImplyLeading: false, // This removes the "Back" button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spaceHeight * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFieldWithIcon(
              controller: _usernameController,
              labelText: 'Benutzername',
              icon: Icons.help_outline,
            ),
            SizedBox(height: spaceHeight),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-Mail Adresse'),
            ),
            SizedBox(height: spaceHeight),
            _buildPasswordTextField(_passwordController, 'Passwort'),
            SizedBox(height: spaceHeight),
            _buildPasswordTextField(
                _confirmPasswordController, 'Passwort bestätigen'),
            SizedBox(height: spaceHeight * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          "Ich akzeptiere die AGBs und Datenschutzbestimmungen",
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        color: Colors.grey,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    "AGBs & Datenschutzbestimmungen"),
                                content: const Text(
                                    "Hier stehen die Informationen zu den AGBs und Datenschutzbestimmungen."),
                                actions: [
                                  TextButton(
                                    child: const Text("Klingt gut"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Checkbox(
                    value: isTermsAndConditionsChecked,
                    onChanged: ((value) => setState(() {
                          isTermsAndConditionsChecked = value!;
                        }))),
              ],
            ),
            SizedBox(height: spaceHeight),
            ElevatedButton(
              onPressed: () => isTermsAndConditionsChecked
                  ? widget.onStep1(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _confirmPasswordController.text,
                      _showError)
                  : _showError(context,
                      "Akzeptiere die AGB und Datenschutzbestimmungen um mit der Registrierung fortfahren zu können."),
              child: const Text('Registrieren'),
            ),
            SizedBox(height: spaceHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Bereits registriert?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Anmelden'),
                ),
              ],
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Tooltip(
          message:
              'Der Benutzername wird im Profil angezeigt.\nVermeide persönliche Informationen.',
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 10),
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
      TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  void _showError(BuildContext context, String errorMessage) {
    Dialogs.showErrorDialog(
        context, 'Fehler beim Registrieren', 'Behebe ich!', errorMessage);
  }
}
