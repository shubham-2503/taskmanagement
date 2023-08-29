import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => [..._tasks]; // Return a copy of the tasks list

  void setTasks(List<Task> newTasks) {
    _tasks = newTasks;
    notifyListeners(); // Notify listeners to update the UI
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // Notify listeners to update the UI
  }

  void deleteTask(String taskId) {
    _tasks.remove(taskId);
    notifyListeners();
  }
}


class TaskCountManager {
  final SharedPreferences _prefs;
  TaskCountManager(this._prefs);

  Future<int> fetchTotalTaskCount() async {
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

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
    };

    final response1 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId'), headers: headers);
    final response2 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Task/teamsTask?org_id=$orgId'), headers: headers);

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final data1 = jsonDecode(response1.body);
      final data2 = jsonDecode(response2.body);

      List<dynamic> alltasks = [];
      alltasks.addAll(data1);
      alltasks.addAll(data2);

      Set<String> taskIds = {}; // Use a Set to remove duplications
      taskIds.addAll(alltasks.map((task) => task['id'] as String));

      int totalTaskCount = taskIds.length;
      print("Total task Count: $totalTaskCount"); // Print the count

      return totalTaskCount;
    } else {
      throw Exception('Failed to fetch task data');
    }
  }

  Future<void> incrementTaskCount() async {
    int currentCount = await fetchTotalTaskCount();
    int newCount = currentCount + 1;
    await _prefs.setInt('totalTaskCount', newCount);
    print("New Count: $newCount");
  }

  Future<void> decrementTaskCount() async {
    int currentCount = await fetchTotalTaskCount();
    int newCount = currentCount - 1;
    print("NewCount: $newCount");
    await _prefs.setInt('totalTaskCount', newCount);
  }

  Future<int> fetchCompletedTaskCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId");

    if (orgId == null) {
      orgId = prefs.getString('org_id') ?? "";
    }

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
    };

    final response1 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId'), headers: headers);
    final response2 = await http.get(Uri.parse('http://43.205.97.189:8000/api/Task/teamsTask?org_id=$orgId'), headers: headers);

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final data1 = jsonDecode(response1.body);
      final data2 = jsonDecode(response2.body);

      List<dynamic> allTasks = [];
      allTasks.addAll(data1);
      allTasks.addAll(data2);

      int completedTaskCount = allTasks.where((task) => task['status'] == 'Completed').length;
      print("Completed task Count: $completedTaskCount");

      return completedTaskCount;
    } else {
      throw Exception('Failed to fetch task data');
    }
  }

  Future<void> updateTaskCount() async {
    try {
      int totalTaskCount = await fetchTotalTaskCount(); // Use the fetchTotalProjectCount function
      await _prefs.setInt('totalTaskCount', totalTaskCount);
      print("FinalProjectCount: $totalTaskCount");
    } catch (e) {
      print('Error updating project count: $e');
    }
  }

  Future<void> incrementCompletedTaskCount() async {
    int currentCount = await fetchCompletedTaskCount();
    int newCount = currentCount + 1;
    await _prefs.setInt('completedTaskCount', newCount);
    print("New Completed Task Count: $newCount");
  }

  Future<void> decrementCompletedTaskCount() async {
    int currentCount = await fetchCompletedTaskCount();
    int newCount = currentCount - 1;
    print("New Completed Task Count: $newCount");
    await _prefs.setInt('completedTaskCount', newCount);
  }

  Future<void> updateCompletedTaskCount() async {
    try {
      int completedTaskCount = await fetchCompletedTaskCount();
      await _prefs.setInt('completedTaskCount', completedTaskCount);
      print("Final Completed Task Count: $completedTaskCount");
    } catch (e) {
      print('Error updating completed task count: $e');
    }
  }
}