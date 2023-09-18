import 'package:Taskapp/models/project_team_model.dart';
import 'package:Taskapp/models/task_model.dart';
import 'package:Taskapp/models/user.dart';
import '../view/projects/myProjects/project_assigned.dart';
import '../view/projects/projectDetailsScreen.dart';

class Project {
  String id;
  String? uniqueId;
  String name;
  String description;
  String owner;
  String status;
  String? dueDate;
  List<Task>? tasks;
  List<Team>? teams;
  List<User>? users;
  bool? active = true; // Active parameter

  Project({
    required this.id,
    this.uniqueId,
    required this.name,
    required this.owner,
    required this.status,
    required this.description,
    this.dueDate,
    this.tasks,
    this.teams,
    this.users,
    this.active, // Active parameter
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
      description: json['description'],
      owner: json['owner'],
      status: json['status'],
      dueDate: json['dueDate'],
    );
  }
}
