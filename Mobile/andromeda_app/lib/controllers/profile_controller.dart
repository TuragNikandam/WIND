import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:andromeda_app/views/profile_edit_view.dart';
import 'package:provider/provider.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({super.key});

  @override
  State<ProfileController> createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  late User user;
  late UserService userService;
  List<Party> _parties = List.empty();
  List<Organization> _organizations = List.empty();

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    user = Provider.of<User>(context, listen: false);
    _parties = PartyManager().getPartyList;
    _organizations = OrganizationManager().getOrganizationList;
  }

  Future<bool> _updateProfile(User updatedUser) async {
    await userService.updateUserProfile(updatedUser);
    setState(() {
      user.updateAllFields(updatedUser);
    });
    return true;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await userService.logout();
    } catch (error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout fehlgeschlagen.')),
      );
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  String? _validate(User user) {
    return Validators.validateBirthYear(user.getBirthYear) ??
        Validators.validateNotEmpty(
            user.getGender, "Geschlechtszugehörigkeit") ??
        Validators.validateNotEmpty(
            user.getReligion, "Religionszugehörigkeit") ??
        Validators.validateZipCode(user.getZipCode);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      user: user,
      onUpdateProfile: (User updatedUser, Function showError) {
        String? errorMessage = _validate(updatedUser);
        if (errorMessage == null) {
          _updateProfile(updatedUser).then((userUpdated) {
            userUpdated
                ? ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Das hat geklappt!')),
                  )
                : showError(context, "Das hat nicht geklappt, sorry!");
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Das hat nicht geklappt, sorry!')));
          });
        } else {
          showError(context, errorMessage);
        }
      },
      parties: _parties,
      organizations: _organizations,
      logout: () {
        _logout(context);
      },
    );
  }
}
