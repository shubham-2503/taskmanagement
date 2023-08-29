class Task {
  final String? taskId;
  final String taskName;
  List<String> assignedTo;
  List<String> assignedTeam;
  final String status;
  final String? owner;
  final String? createdBy;
  final String? description;
  final String priority;
  final String? dueDate;

  Task({
    this.taskId,
    required this.taskName,
    required this.assignedTo,
    required this.assignedTeam,
    required this.status,
    this.owner,
    this.createdBy,
    this.description,
    required this.priority,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'],
      taskName: json['taskName'],
      assignedTo: List<String>.from(json['assignedTo']),
      assignedTeam: List<String>.from(json['assignedTeam']),
      status: json['status'],
      owner: json['owner'],
      createdBy: json['createdBy'],
      description: json['description'],
      priority: json['priority'],
      dueDate: json['dueDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'assignedTo': assignedTo,
      'assignedTeam': assignedTeam,
      'status': status,
      'owner': owner,
      'createdBy': createdBy,
      'description': description,
      'priority': priority,
      'dueDate': dueDate,
    };
  }
}
