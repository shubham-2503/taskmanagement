class LoginOtpModel {
  bool? success;
  int? userId;
  String? name;

  LoginOtpModel({this.success, this.userId, this.name});

  LoginOtpModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    userId = json['user_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    return data;
  }
}