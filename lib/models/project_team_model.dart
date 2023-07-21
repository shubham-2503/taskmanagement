class Team {
  String teamId;
  String teamName;

  Team({required this.teamId, required this.teamName});

  factory Team.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawUsers = json['users'];
    final List<String> users = rawUsers != null
        ? List<String>.from(rawUsers.whereType<String>()) // Filter out non-String entries
        : [];

    return Team(
      teamId: json['teamID'] ?? '',
      teamName: json['teamName'] ?? '',
    );
  }
}
