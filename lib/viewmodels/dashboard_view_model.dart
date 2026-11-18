import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void selectTab(int index) {
    if (index < 0 || index > 3 || index == _selectedTab) return;
    _selectedTab = index;
    notifyListeners();
  }
}
