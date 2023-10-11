import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _singleton = NavigationService._internal();

  factory NavigationService() {
    return _singleton;
  }

  NavigationService._internal();

  final newsKey = GlobalKey<NavigatorState>();
  final forumKey = GlobalKey<NavigatorState>();
  final votingKey = GlobalKey<NavigatorState>();
  final profilePageKey = GlobalKey<NavigatorState>();

  Future<void> navigate(BuildContext context, String route,
          {bool isDialog = false,
          bool isRootNavigator = true,
          Map<String, dynamic>? arguments}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .pushNamed(route, arguments: arguments);

  Future<void> navigateAndRemoveAll(BuildContext context, String route,
          {bool isRootNavigator = true, Map<String, dynamic>? arguments}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false,
              arguments: arguments);
}
