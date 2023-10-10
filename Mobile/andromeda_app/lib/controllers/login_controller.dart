import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/master_data_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:andromeda_app/utils/validators.dart';
import 'package:andromeda_app/views/guests/guest_main_view.dart';
import 'package:andromeda_app/views/login_view.dart';
import 'package:andromeda_app/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginController extends StatefulWidget {
  static const String route = '/login';
  @override
  State<LoginController> createState() => _LoginControllerState();

  const LoginController({super.key});
}

class _LoginControllerState extends State<LoginController> {
  late UserService userService;
  late MasterDataService masterDataService;
  late User user;
  late NavigationService navigationService;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    masterDataService = Provider.of<MasterDataService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    Validators.loadBlacklist();
  }

  Future<void> _login(String username, String password) async {
    try {
      await userService.login(username, password);
      User newUser = await userService.getCurrentUser();
      user.updateAllFields(newUser);
      await masterDataService.loadMasterData();
      if (!mounted) return; // Check if the widget is still in the widget tree
      navigationService.navigateAndRemoveAll(context, MainView.route);
    } catch (error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verbindung fehlgeschlagen.')),
      );
    }
  }

  Future<void> _loginAsGuest() async {
    try {
      await userService.loginAsGuest();
      User newUser = await userService.getCurrentUser();
      user.updateAllFields(newUser);
      await masterDataService.loadMasterData();
      if (!mounted) return; // Check if the widget is still in the widget tree
      navigationService.navigateAndRemoveAll(context, GuestMainView.route);
    } catch (error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verbindung fehlgeschlagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(
        onLogin: (String username, String password) {
          _login(username, password);
        },
        onLoginAsGuest: () => _loginAsGuest());
  }
}
