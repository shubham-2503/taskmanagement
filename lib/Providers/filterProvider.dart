import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FilterProvider with ChangeNotifier {
  String? selectedStatus;
  String? selectedPriority;
  String? selectedReportType;
  String? startDate;
  String? endDate;

  Future<dynamic> applyFilters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }


    print("OrgId: $orgId");

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    // Construct the query parameters
    final queryParams = {
      'org_id': orgId,
      if (selectedReportType != null) 'report_type': selectedReportType,
      if (selectedPriority != null) 'priority': selectedPriority,
      if (selectedStatus != null) 'status': selectedStatus,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };

    final url = Uri.parse('http://43.205.97.189:8000/api/Common/taskReport?org_id=$orgId')
        .replace(queryParameters: queryParams);

    final headers = {
      'Authorization': 'Bearer $storedData',
    };

    try {
      final response = await http.get(url, headers: headers);

      print("Response: ${response.statusCode}");
      print("body:${response.body}");

      if (response.statusCode == 200) {
        // Handle success and parse the response body
        final responseData = json.decode(response.body);
        print("Successfully fetched the Reports");
        return responseData;
      } else {
        print("Failed to fetched the Reports: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetched the Reports");
    }
  }
}