import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => [..._tasks]; // Return a copy of the tasks list

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // Notify listeners to update the UI
  }

  void deleteTask(String taskId) {
    _tasks.remove(taskId);
    notifyListeners();
  }
}
