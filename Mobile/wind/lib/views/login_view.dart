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
  bool loginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Willkommen bei W.I.N.D.'),
        automaticallyImplyLeading: false, // Removes the "back"-Button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/WIND_logo.png",
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Benutzername'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Passwort'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ElevatedButton(
                onPressed: loginPressed
                    ? null
                    : () {
                        setState(() {
                          loginPressed = true;
                        });
                        widget.onLogin(
                            _usernameController.text, _passwordController.text);
                        loginPressed = false;
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Login'),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Forgot password screen to implement.
                  },
                  child: const Text('Passwort vergessen?'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Kein Account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registration');
                    },
                    child: const Text('Registrieren'),
                  ),
                ],
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (!loginPressed) {
                      loginPressed = true;
                      widget.onLoginAsGuest();
                    }
                  },
                  child: const Text('Als Gast fortfahren'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
