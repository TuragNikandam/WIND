import 'dart:async';

import 'package:andromeda_app/controllers/profile/profile_edit_controller.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/views/utils/bottom_navigation_bar.dart';
import 'package:andromeda_app/views/utils/enums/navigation_menu.dart';
import 'package:andromeda_app/views/utils/menus/forum_menu.dart';
import 'package:andromeda_app/views/utils/menus/news_menu.dart';
import 'package:andromeda_app/views/utils/menus/voting_menu.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});
  static const String route = "/main";

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0; // Set the first View as "Home"

  final List<Widget> _children = [
    // Controllers in the order of NavigationTypes
    const NewsMenu(),
    const ForumMenu(),
    const VotingMenu(),
    const ProfileController()
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
