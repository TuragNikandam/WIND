import 'dart:async';

import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/views/guests/guest_no_permission_view.dart';
import 'package:andromeda_app/views/utils/bottom_navigation_bar.dart';
import 'package:andromeda_app/views/utils/enums/navigation_menu.dart';
import 'package:andromeda_app/views/utils/menus/news_menu.dart';
import 'package:andromeda_app/views/utils/menus/voting_menu.dart';
import 'package:flutter/material.dart';

class GuestMainView extends StatefulWidget {
  const GuestMainView({super.key});
  static const String route = "/guest/main";

  @override
  State<GuestMainView> createState() => _GuestMainViewState();
}

class _GuestMainViewState extends State<GuestMainView> {
  int _currentIndex = 0; // Set the first View as "Home"

  final List<Widget> _children = [
    const NewsMenu(),
    const GuestNoPermissionView(),
    const VotingMenu(),
    const GuestNoPermissionView(),

    // ... other pages
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BottomNavBar.instance.setOnNavigationIndexChanged((index) {
        _currentIndex = index;
      });
    });
  }

  void onTabSelected(int index, NavigationMenu navigationType) {
    setState(() {
      _currentIndex = index;
      BottomNavBar.instance.setCurrentNavigationType = navigationType;
    });
  }

  FutureOr<bool> onBackButtonPressed() async {
    bool exitingApp = true;

    switch (_currentIndex) {
      case 0: // News
        if (NavigationService().newsKey.currentState != null &&
            NavigationService().newsKey.currentState!.canPop()) {
          NavigationService().newsKey.currentState!.pop();
          exitingApp = false;
        }
        break;
      case 1: // Forum
        if (NavigationService().forumKey.currentState != null &&
            NavigationService().forumKey.currentState!.canPop()) {
          NavigationService().forumKey.currentState!.pop();
          exitingApp = false;
        }
        break;
      case 2: // Voting
        if (NavigationService().votingKey.currentState != null &&
            NavigationService().votingKey.currentState!.canPop()) {
          NavigationService().votingKey.currentState!.pop();
          exitingApp = false;
        }
        break;
      case 3: // Profile Page
        if (NavigationService().profilePageKey.currentState != null &&
            NavigationService().profilePageKey.currentState!.canPop()) {
          NavigationService().profilePageKey.currentState!.pop();
          exitingApp = false;
        }
        break;
      default:
        return false;
    }
    if (exitingApp) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return await onBackButtonPressed();
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _children,
          ),
          bottomNavigationBar: BottomNavBarWidget(
            navigationType: NavigationMenu.values[_currentIndex],
            onTabSelected: onTabSelected,
          ),
        ));
  }
}
