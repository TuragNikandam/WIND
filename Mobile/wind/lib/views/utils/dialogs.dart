import 'package:flutter/material.dart';

class Dialogs {
  static void showErrorDialog(BuildContext context, String errorTitle,
      String errorButtonText, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(errorTitle),
          content: Text(
            errorMessage,
          ),
          actions: [
            TextButton(
              child: Text(errorButtonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
