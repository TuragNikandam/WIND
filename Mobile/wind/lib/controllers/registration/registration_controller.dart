import 'package:wind/controllers/registration/registration_step1_controller.dart';
import 'package:wind/models/user_model.dart';
import 'package:wind/services/navigation_service.dart';
import 'package:wind/utils/validators.dart';
import 'package:wind/views/registration/registration_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationController extends StatefulWidget {
  static const String route = '/registration';
  @override
  State<RegistrationController> createState() => _RegistrationControllerState();

  const RegistrationController({super.key});
}

class _RegistrationControllerState extends State<RegistrationController> {
  late User user;
  late NavigationService navigationService;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user.updateAllFields(User());
    });
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
            navigationService.navigate(
                context, RegistrationStep1Controller.route);
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
