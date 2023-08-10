import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectDataProvider extends ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners(); // Notify listeners that the data has changed
  }
}
