class OtpSentResponse {
  late int response;
  late bool status;
  late UserData data;
  late String message;

  OtpSentResponse.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    status = json['status'];
    data = UserData.fromJson(json['data']);
    message = json['message'];
  }
}

class UserData {
  late String userId;
  late String email;
  late String roleId;

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    roleId = json['role_id'];
  }
}
