import 'package:andromeda_app/controllers/registration/registration_step3_controller.dart';
import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/master_data_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/views/registration/registration_step2_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep2Controller extends StatefulWidget {
  static const String route = "/registration_step2";
  @override
  State<RegistrationStep2Controller> createState() =>
      _RegistrationStep2ContollerState();

  const RegistrationStep2Controller({super.key});
}

class _RegistrationStep2ContollerState
    extends State<RegistrationStep2Controller> {
  late User user;
  late MasterDataService masterDataService;
  late NavigationService navigationService;
  late List<Organization> organizations;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    organizations = OrganizationManager().getOrganizationList;
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationStep2View(
      organizations: organizations,
      onStep3: (List<String> organizations, bool visable) {
        user.setSelectedOrganizations(organizations);
        user.setShowOrganizationsInProfile(visable);
        navigationService.navigate(context, RegistrationStep3Controller.route);
      },
    );
  }
}
