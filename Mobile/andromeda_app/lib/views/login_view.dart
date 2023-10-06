import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  final Function(String, String) onLogin;
  final Function() onLoginAsGuest;

  const LoginView(
      {super.key, required this.onLogin, required this.onLoginAsGuest});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false, // Removes the "back"-Button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Benutzername'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onLogin(
                  _usernameController.text, _passwordController.text),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Forgot password screen to implement.
              },
              child: const Text('Passwort vergessen?'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Kein Account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context,
                        '/registration');
                  },
                  child: const Text('Registrieren'),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                widget.onLoginAsGuest();
              },
              child: const Text('Als Gast fortfahren'),
            ),
          ],
        ),
      ),
    );
  }
}
