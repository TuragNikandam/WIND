import 'package:wind/models/user_model.dart';
import 'package:wind/services/navigation_service.dart';
import 'package:wind/services/user_service.dart';
import 'package:wind/utils/validators.dart';
import 'package:wind/views/main_view.dart';
import 'package:wind/views/registration/registration_step3_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep3Controller extends StatefulWidget {
  static const String route = "/registration_step3";
  @override
  State<RegistrationStep3Controller> createState() =>
      _RegistrationStep3ContollerState();

  const RegistrationStep3Controller({super.key});
}

class _RegistrationStep3ContollerState
    extends State<RegistrationStep3Controller> {
  late UserService userService;
  late User user;
  late NavigationService navigationService;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
  }

  String? _validate(
      int birthYear, int zipCode, String? gender, String? religion) {
    return Validators.validateBirthYear(birthYear) ??
        Validators.validateNotEmpty(gender, "Geschlechtszugehörigkeit") ??
        Validators.validateNotEmpty(religion, "Religionszugehörigkeit") ??
        Validators.validateZipCode(zipCode);
  }

  Future<bool> _submitRegistration() async {
    try {
      await userService.register(user);
      User newUser = await userService.getCurrentUser();
      user.updateAllFields(newUser);
      if (!mounted) {
        return false; // Check if the widget is still in the widget tree
      }
      navigationService.navigateAndRemoveAll(context, MainView.route);
    } catch (error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrierung fehlgeschlagen.')),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationStep3View(
      onRegister: (int birthYear, int zipCode, String? gender, String? religion,
          bool showInProfile, Function showError) {
        String? errorMessage = _validate(birthYear, zipCode, gender, religion);
        if (errorMessage == null) {
          user.setBirthYear(birthYear);
          user.setZipCode(zipCode);
          user.setGender(gender!);
          user.setReligion(religion!);
          user.setShowPersonalInformationInProfile(showInProfile);
          _submitRegistration();
        } else {
          showError(context, errorMessage);
        }
      },
    );
  }
}
