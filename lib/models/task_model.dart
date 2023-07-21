class Task {
  final String taskName; // Changed "title" to "taskName"
  final String assignedTo;
  final String? assignedTeam;
  final String status;
  final String? owner;
  final String? description;
  final String priority;
  String? dueDate;

  Task({
    required this.taskName,
    required this.assignedTo,
    this.assignedTeam,
    required this.status,
    this.owner,
    this.description,
    required this.priority,
    this.dueDate,
  });
}