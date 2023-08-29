class LoginResponse {
  late bool status;
  late LoginData data;
  late String message;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = LoginData.fromJson(json['data']);
    message = json['message'];
  }
}

class LoginData {
  late String jwtToken;
  late OrgDetail orgDetail;

  LoginData.fromJson(Map<String, dynamic> json) {
    jwtToken = json['jwtToken'];
    orgDetail = OrgDetail.fromJson(json['org_detail']);
  }
}

class OrgDetail {
  late String orgId;
  late bool subsStatus;
  late String createdDate;
  late bool isSubscribed;

  OrgDetail.fromJson(Map<String, dynamic> json) {
    orgId = json['org_id'];
    subsStatus = json['subs_status'];
    createdDate = json['created_date'];
    isSubscribed = json['is_subscribed'];
  }
}
