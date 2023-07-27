import 'package:Taskapp/models/user.dart';

class Team {
  final String id;
  final String name;
  List<String> users;
  final String? createdBy;
  final String? modifiedBy;
  final String? createdDate;
  final String? modifiedDate;

  Team({
    required this.id,
    required this.name,
    required this.users,
    this.createdBy,
    this.modifiedBy,
    this.createdDate,
    this.modifiedDate,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawUsers = json['users'];
    final List<String> users = rawUsers != null
        ? List<String>.from(rawUsers.whereType<String>()) // Filter out non-String entries
        : [];

    return Team(
      id: json['teamID'] ?? '',
      name: json['teamName'] ?? '',
      users: users,
      createdBy: json['created_by'],
      modifiedBy: json['modified_by'],
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
    );
  }
}

class MyTeam {
  final String teamId;
  final String teamName;
  final List<String>? users;

  MyTeam({
    required this.teamId,
    required this.teamName,
    this.users,
  });

  factory MyTeam.fromJson(Map<String, dynamic> json) {
    return MyTeam(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      users: (json['users'] as List<dynamic>?)?.map((userJson) => userJson['name'].toString()).toList() ?? [],
    );
  }
}


