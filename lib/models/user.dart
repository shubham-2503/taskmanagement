class User {
  String userId;
  String userName;
  String? email;

  User({required this.userId, required this.userName,this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      userName: json['user_name'],
      email: json.containsKey('email') ? json['email'] : '',
    );
  }
}


