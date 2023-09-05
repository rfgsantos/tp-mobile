class Register {
  String username;
  String last_name;
  String first_name;
  String email;
  String password;
  String? phone_number;

  Register(
      {required this.username,
      required this.last_name,
      required this.first_name,
      required this.password,
      required this.email,
      this.phone_number});

  factory Register.fromJson(Map<String, dynamic> json) => Register(
      username: json["username"] ?? '',
      last_name: json["last_name"] ?? '',
      first_name: json["firstName"] ?? '',
      email: json["email"] ?? '',
      password: json["password"] ?? '',
      phone_number: json["phone_number"] ?? '');

  Map<String, dynamic> toJson() => {
        "username": username,
        "last_name": last_name,
        "first_name": first_name,
        "email": email,
        "password": password,
        "phone_number": phone_number
      };
}
