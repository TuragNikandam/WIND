import 'dart:async';

import 'package:andromeda_app/controllers/profile_controller.dart';
import 'package:flutter/material.dart';

OverlayEntry createSessionExpiredOverlay(
    BuildContext originalContext, Completer<OverlayEntry> overlayCompleter) {
  return OverlayEntry(
    builder: (BuildContext context) {
      // Get screen size
      Size screenSize = MediaQuery.of(context).size;

      // Calculate dimensions relative to screen size
      double overlayWidth = screenSize.width * 0.8; // 80% of screen width
      double overlayHeight = screenSize.height * 0.2; // 20% of screen height

      // Calculate position to center the overlay
      double top = (screenSize.height - overlayHeight) / 2;
      double left = (screenSize.width - overlayWidth) / 2;

      return Positioned(
        top: top,
        left: left,
        child: Material(
          elevation: 4,
          child: Container(
            width: overlayWidth,
            height: overlayHeight,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    'Deine Sitzung ist abgelaufen, bitte logge dich erneut ein.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    overlayCompleter.future.then((overlay) {
                      overlay.remove();
                    });
                    Navigator.pushNamedAndRemoveUntil(
                        originalContext, '/', (_) => false);
                  },
                  child: const Text('Das mache ich'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
