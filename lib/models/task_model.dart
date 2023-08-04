class Task {
  final String? taskId;
  final String taskName; // Changed "title" to "taskName"
  final List<String> assignedTo;
  final String? assignedTeam;
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
    this.assignedTeam,
    required this.status,
    this.owner,
    this.createdBy,
    this.description,
    required this.priority,
    this.dueDate,
  });
}