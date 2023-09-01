import 'package:flutter/foundation.dart';

class TasksFilterNotifier extends ChangeNotifier {
  Map<String, String?> _selectedFilters = {};

  Map<String, String?> get selectedFilters => _selectedFilters;

  void updateFilters(Map<String, String?> newFilters) {
    _selectedFilters = newFilters;
    notifyListeners();
  }

  // Method to remove a filter
   void removeFilter(String filterKey) {
    _selectedFilters.remove(filterKey);
    notifyListeners(); // Notify listeners to update the UI
  }
}
