class Team {
  final String id;
  final String teamName;
  final List<String>? users;

  Team({
    required this.teamName,
    required this.id,
    this.users,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamName: json['teamName'] ?? '',
      id: json['teamId'] ?? '',
      users: List<String>.from(json['users'] ?? []),
    );
  }
}
