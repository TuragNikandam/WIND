import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:andromeda_app/utils/validators.dart';
import 'package:andromeda_app/views/registration/registration_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationController extends StatefulWidget {
  @override
  State<RegistrationController> createState() => _RegistrationControllerState();

  const RegistrationController({super.key});
}

class _RegistrationControllerState extends State<RegistrationController> {
  late UserService userService;
  late User user;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
  }

  Future<String?> _validate(BuildContext context, String username, String email,
      String password, String confirmPassword) async {
    return Validators.validateUsername(username) ??
        Validators.validateEmail(email) ??
        Validators.validatePassword(password) ??
        Validators.validateConfirmPassword(password, confirmPassword) ??
        await Validators.usernameExists(context, username) ??
        await Validators.emailExists(context, email);
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationView(
      onStep1: (String username, String email, String password,
          String confirmPassword, Function showError) {
        _validate(context, username, email, password, confirmPassword)
            .then((errorMessage) {
          if (errorMessage == null) {
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(password);
            Navigator.pushNamed(context, '/registration_step1');
          } else {
            showError(context, errorMessage);
          }
        }).catchError((onError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verbindung fehlgeschlagen.')),
          );
        });
      },
    );
  }
}
