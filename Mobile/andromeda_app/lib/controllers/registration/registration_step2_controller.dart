import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/master_data_service.dart';
import 'package:andromeda_app/views/registration/registration_step2_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep2Controller extends StatefulWidget {
  @override
  State<RegistrationStep2Controller> createState() =>
      _RegistrationStep2ContollerState();

  const RegistrationStep2Controller({super.key});
}

class _RegistrationStep2ContollerState
    extends State<RegistrationStep2Controller> {
  late User user;
  late MasterDataService masterDataService;
  List<Organization> _organizations = List.empty();

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    _organizations = OrganizationManager().getOrganizationList;
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationStep2View(
      organizations: _organizations,
      onStep3: (List<String> selectedOrganizations, bool visable) {
        user.setSelectedOrganizations(selectedOrganizations);
        user.setShowOrganizationsInProfile(visable);
        Navigator.pushNamed(context, '/registration_step3');
      },
    );
  }
}
