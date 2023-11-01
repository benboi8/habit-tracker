import 'package:flutter/material.dart';

class NavigationManager {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Function to navigate to a specific page
  void navigateToPage(Widget page) {
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => page));
  }

  // Function to pop the top page from the stack
  void popPage() {
    navigatorKey.currentState?.pop();
  }

  // Function to replace the current page with a new page
  void replacePage(Widget newPage) {
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => newPage));
  }

  // Function to clear the navigation stack and set a new page as the root
  void setRootPage(Widget newRoot) {
    navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => newRoot), (route) => false);
  }

  // Function to get the currently open page route name
  String getCurrentPageName(BuildContext context) {
    if (navigatorKey.currentState != null && navigatorKey.currentState!.canPop()) {
      return ModalRoute.of(context)?.settings.name ?? '';
    } else {
      return '';
    }
  }
}
