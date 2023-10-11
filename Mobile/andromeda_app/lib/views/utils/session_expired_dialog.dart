import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showSessionExpiredDialog(BuildContext context) async {
  NavigationService navigationService =
      Provider.of<NavigationService>(context, listen: false);
  User user = Provider.of<User>(context, listen: false);
  UserService userService = Provider.of<UserService>(context, listen: false);
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Sitzung abgelaufen'),
        content: const Text(
            'Deine Sitzung ist abgelaufen, bitte logge dich erneut ein.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Das mache ich'),
            onPressed: () async {
              user.updateAllFields(User());

              await userService.setJWTToken({'token': ''});

              if (context.mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                navigationService.navigateAndRemoveAll(context, '/login');
              }
            },
          ),
        ],
      );
    },
  );
}
