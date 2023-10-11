import 'package:wind/services/navigation_service.dart';
import 'package:wind/views/utils/enums/navigation_menu.dart';
import 'package:flutter/material.dart';

typedef OnNavigationIndexChanged = void Function(int);

class BottomNavBar {
  BottomNavBar._privateConstructor();

  static final BottomNavBar _instance = BottomNavBar._privateConstructor();

  static BottomNavBar get instance => _instance;

  NavigationMenu _currentNavigationType = NavigationMenu.news;

  NavigationMenu get getCurrentNavigationType => _currentNavigationType;

  OnNavigationIndexChanged? _onNavigationIndexChanged;

  set setCurrentNavigationType(NavigationMenu index) {
    _currentNavigationType = index;
    if (_onNavigationIndexChanged != null) {
      _onNavigationIndexChanged!(navigationTypeToIndex(_currentNavigationType));
    }
  }

  void setOnNavigationIndexChanged(OnNavigationIndexChanged callback) {
    _onNavigationIndexChanged = callback;
  }

  int navigationTypeToIndex(NavigationMenu type) {
    return NavigationMenu.values.indexOf(type);
  }

  NavigationMenu indexToNavigationType(int index) {
    return NavigationMenu.values[index];
  }
}

class BottomNavBarWidget extends StatefulWidget {
  final NavigationMenu navigationType;
  final Function(int index, NavigationMenu type) onTabSelected;
  const BottomNavBarWidget(
      {super.key, required this.navigationType, required this.onTabSelected});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBarWidget> {
  final navBarInstance = BottomNavBar.instance;
  static const TextStyle unselecetedStyle =
      TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle selecetedStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    navBarInstance.setCurrentNavigationType = widget.navigationType;
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      currentIndex: navBarInstance.getCurrentNavigationType.index,
      unselectedLabelStyle: unselecetedStyle,
      selectedLabelStyle: selecetedStyle,
      selectedIconTheme:
          IconThemeData(color: Theme.of(context).primaryColor, size: 30),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.black,
      onTap: (int index) {
        navBarInstance.getCurrentNavigationType.index == index
            ? popAllRoutes(index)
            : widget.onTabSelected(index, NavigationMenu.values[index]);
      },
      items: [
        _buildNavBarItem("News", Icons.home, NavigationMenu.news),
        _buildNavBarItem("Forum", Icons.forum, NavigationMenu.forum),
        _buildNavBarItem("Wahlen", Icons.ballot, NavigationMenu.voting),
        _buildNavBarItem(
            "Profil", Icons.account_circle, NavigationMenu.profilepage),
        // ... Add more items here
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
      String? label, IconData? icon, NavigationMenu type) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Icon(
          icon,
        ),
      ),
      label: label,
    );
  }

  void popAllRoutes(int index) {
    switch (index) {
      case 0: // News
        if (NavigationService().newsKey.currentState != null &&
            NavigationService().newsKey.currentState!.canPop()) {
          NavigationService()
              .newsKey
              .currentState!
              .popUntil((route) => route.isFirst);
        }
        return;
      case 1: // Forum
        if (NavigationService().forumKey.currentState != null &&
            NavigationService().forumKey.currentState!.canPop()) {
          NavigationService()
              .forumKey
              .currentState!
              .popUntil((route) => route.isFirst);
        }
        return;
      case 2: // Voting
        if (NavigationService().votingKey.currentState != null &&
            NavigationService().votingKey.currentState!.canPop()) {
          NavigationService()
              .votingKey
              .currentState!
              .popUntil((route) => route.isFirst);
        }
        return;
      case 3: // Profile Page skipped (no depth)
        break;
      default:
        break;
    }
  }
}
