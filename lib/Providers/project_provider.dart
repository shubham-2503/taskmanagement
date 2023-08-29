import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';
import 'package:http/http.dart' as http;

class ProjectDataProvider extends ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => [..._projects];

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners(); // Notify listeners that the data has changed
  }

  void updateProjects(List<Project> updatedProjects) {
    _projects = updatedProjects;
    notifyListeners();
  }

  void setTasks(List<Project> newProject) {
    _projects = newProject;
    notifyListeners(); // Notify listeners to update the UI
  }

}

class ProjectCountManager {
  final SharedPreferences _prefs;
  ProjectCountManager(this._prefs);

  Future<int> fetchTotalProjectCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    print("OrgId: $orgId");

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
    };


    final response1 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Project/myTeamProjects?org_id=$orgId'), headers: headers);
    final response2 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Project/myProjects?org_id=$orgId'), headers: headers);

    if (response1.statusCode == 200 && response2.statusCode == 200 ) {
      final data1 = jsonDecode(response1.body);
      final data2 = jsonDecode(response2.body);

      List<dynamic> allProjects = [];
      allProjects.addAll(data1);
      allProjects.addAll(data2);

      Set<String> projectIds = {}; // Use a Set to remove duplications
      projectIds.addAll(allProjects.map((project) => project['project_id'] as String));

      int totalProjectCount = projectIds.length;
      print("Total Project Count: $totalProjectCount"); // Print the count

      return totalProjectCount;
    } else {
      throw Exception('Failed to fetch project data');
    }
  }

  Future<void> incrementProjectCount() async {
    int currentCount = await fetchTotalProjectCount();
    int newCount = currentCount + 1;
    await _prefs.setInt('totalProjectCount', newCount);
    print("New Count: $newCount");
  }

  Future<void> decrementProjectCount() async {
    int currentCount = await fetchTotalProjectCount();
    int newCount = currentCount - 1;
    print("NewCount: $newCount");
    await _prefs.setInt('totalProjectCount', newCount);
  }

  Future<void> updateProjectCount() async {
    try {
      int totalProjectCount = await fetchTotalProjectCount(); // Use the fetchTotalProjectCount function
      await _prefs.setInt('totalProjectCount', totalProjectCount);
      print("FinalProjectCount: $totalProjectCount");
    } catch (e) {
      print('Error updating project count: $e');
    }
  }
}

