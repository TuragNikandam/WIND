import 'package:andromeda_app/views/utils/dialogs.dart';
import 'package:flutter/material.dart';

class RegistrationView extends StatefulWidget {
  final Function(String, String, String, String, Function(BuildContext, String)) onStep1;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrierung'),
        automaticallyImplyLeading: false, // This removes the "Back" button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFieldWithIcon(
              controller: _usernameController,
              labelText: 'Benutzername',
              icon: Icons.help_outline,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-Mail Adresse'),
            ),
            const SizedBox(height: 16),
            _buildPasswordTextField(_passwordController, 'Passwort'),
            const SizedBox(height: 16),
            _buildPasswordTextField(
                _confirmPasswordController, 'Passwort bestätigen'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => widget.onStep1(
                  _usernameController.text,
                  _emailController.text,
                  _passwordController.text,
                  _confirmPasswordController.text,
                  _showError),
              child: const Text('Registrieren'),
            ),
            const SizedBox(height: 16),
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
        suffixIcon: IconButton(
          icon: Icon(icon),
          onPressed: () {
            //TODO: Tooltip
          },
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
    Dialogs.showErrorDialog(context, 'Fehler beim Registrieren', 'Behebe ich!', errorMessage);
  }
}
