import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view/dashboard/dashboard_screen.dart';

class OrganizationProvider with ChangeNotifier {
  int _selectedOrganizationIndex = 0;
  List<Map<String, dynamic>> _organizationList = [];
  String? _selectedOrgId;
  String? get selectedOrgId => _selectedOrgId;

  int get selectedOrganizationIndex => _selectedOrganizationIndex;

  List<Map<String, dynamic>> get organizationList => _organizationList;

  Future<void> fetchOrganizationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final storedOrgId = prefs.getString('org_id'); // Retrieve stored org_id

    final url = 'http://43.205.97.189:8000/api/Organization/MyOrganizations';
    try {
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Response: ${response.body}');
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _organizationList = data.cast<Map<String, dynamic>>();

        // Find the index of the organization with the stored org_id
        int defaultOrgIndex = _organizationList.indexWhere(
                (org) => org['org_id'] == storedOrgId);

        if (defaultOrgIndex != -1) {
          _selectedOrganizationIndex = defaultOrgIndex;
        }

        // Notify listeners after updating and sorting the list
        notifyListeners();
      } else {
        throw Exception('Failed to load organization list');
      }
    } catch (e) {
      print('Error fetching organization list: $e');
      throw Exception('Failed to load organization list');
    }
  }

  void switchOrganization(int newIndex, BuildContext context) {
    _selectedOrganizationIndex = newIndex;
    notifyListeners();

    String selectedOrgId = _organizationList[newIndex]["org_id"];
    String selectedName = _organizationList[newIndex]["name"];
    _storeSelectedOrgId(selectedOrgId, selectedName);

    Navigator.pushNamedAndRemoveUntil(
      context,
      DashboardScreen.routeName, // Replace with the route name of your User Dashboard screen
          (route) => false, // This will remove all routes from the stack
    );
  }

  Future<void> _storeSelectedOrgId(String selectedOrgId,String selectedName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("selectedOrgId", selectedOrgId);
      await prefs.setString("selectedName", selectedName);
      print("Successfully saved selectedOrgId in the App: $selectedOrgId");
      print("Successfully saved selectedName in the App: $selectedName");
    } catch (e) {
      print("Error storing selectedOrgId in the App: $e");
    }
  }

  void setSelectedOrgId(String? orgId) {
    _selectedOrgId = orgId;
    notifyListeners();
  }

// Other methods and properties in the OrganizationProvider class...
}

