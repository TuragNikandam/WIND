import 'package:andromeda_app/controllers/registration/registration_step2_controller.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/master_data_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/utils/validators.dart';
import 'package:andromeda_app/views/registration/registration_step1_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationStep1Controller extends StatefulWidget {
  static const String route = "/registration_step3";
  @override
  State<RegistrationStep1Controller> createState() =>
      _RegistrationStep1ContollerState();

  const RegistrationStep1Controller({super.key});
}

class _RegistrationStep1ContollerState
    extends State<RegistrationStep1Controller> {
  late User user;
  late MasterDataService masterDataService;
  late NavigationService navigationService;
  List<Party> _parties = List.empty();
  bool _isLoading = true; // Control the loading state

  Future<void> _fetchMasterData() async {
    try {
      await masterDataService.loadMasterData();
      setState(() {
        _parties = PartyManager().getPartyList;
        _isLoading = false; // Stop the loading state
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop the loading state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verbindung fehlgeschlagen.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);
    masterDataService = Provider.of<MasterDataService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
    _fetchMasterData(); // Call the method to start fetching data
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If loading, show the CircularProgressIndicator
      return const Scaffold(
        backgroundColor: Colors.white, // White background
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.deepOrange,
        )),
      );
    } else {
      return RegistrationStep1View(
        parties: _parties,
        onStep2: (String? selectedParty, bool visible, Function showError) {
          String? errorText =
              Validators.validateNotEmpty(selectedParty, "Partei");
          if (errorText != null) {
            showError(context, errorText);
          } else {
            user.setSelectedParty(selectedParty!);
            user.setShowPartyInProfile(visible);
            navigationService.navigate(
                context, RegistrationStep2Controller.route);
          }
        },
      );
    }
  }
}
