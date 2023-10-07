import 'package:andromeda_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showSessionExpiredDialog(BuildContext context) async {
  NavigationService navigationService =
      Provider.of<NavigationService>(context, listen: false);
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navigationService.navigateAndRemoveAll(context, '/login');
            },
          ),
        ],
      );
    },
  );
}
