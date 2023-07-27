class User {
  String userId;
  String userName;
  String? email;

  User({required this.userId, required this.userName, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'], // Update 'user_id' to 'id' if the key in the JSON response is 'id'.
      userName: json['name'],
      email: json['email'], // It's safe to assign directly as it's already nullable.
    );
  }
}
