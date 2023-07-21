import 'package:Taskapp/models/project_team_model.dart';
import 'package:Taskapp/models/task_model.dart';
import 'package:Taskapp/models/user.dart';
import '../view/projects/myProjects/project_assigned.dart';
import '../view/projects/projectDetailsScreen.dart';

class Project {
  String id;
  String name;
  String owner;
  String status;
  String? dueDate;
  List<Task>? tasks;
  List<Team>? teams;
  List<User>? users;

  Project({
    required this.id,
    required this.name,
    required this.owner,
    required this.status,
    this.dueDate,
    this.tasks,
    this.teams,
    this.users,
  });
}