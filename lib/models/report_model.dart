class Task {
  final String id;
  final String taskName;
  final DateTime dueDate;
  final String status;
  final String priority;
  final String createdBy;
  final String description;

  Task({
    required this.id,
    required this.taskName,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.description,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskName: json['task_name'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      priority: json['priority'],
      createdBy: json['created_by'],
      description: json['description'],
    );
  }
}

class Project {
  final String id;
  final String taskName;
  final DateTime dueDate;
  final String type;
  final String createdBy;
  final String status;

  Project({
    required this.id,
    required this.taskName,
    required this.dueDate,
    required this.type,
    required this.createdBy,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      taskName: json['task_name'],
      dueDate: DateTime.parse(json['dueDate']),
      type: json['type'],
      createdBy: json['created_by'],
      status: json['status'],
    );
  }
}
