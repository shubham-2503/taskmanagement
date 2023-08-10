class UserInvitationStatus {
  String userId;
  String name;
  String email;
  String roleId;
  String roleName;
  String mobile;
  bool? status;

  UserInvitationStatus({
    required this.name,
    required this.userId,
    required this.email,
    required this.roleId,
    required this.roleName,
    required this.mobile,
    this.status,
  });

  factory UserInvitationStatus.fromJson(Map<String, dynamic> json) {
    return UserInvitationStatus(
      userId: json['user_id'],
      email: json['email'],
      roleId: json['role_id'],
      roleName: json['role_name'],
      name: json['name'],
      mobile: json['mobile'],
      status: json['status'],
    );
  }
}
