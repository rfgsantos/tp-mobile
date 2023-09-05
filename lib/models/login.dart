class LoginInfo {
  String email;
  String password;

  LoginInfo({required this.email, required this.password});

  factory LoginInfo.fromJson(Map<String, dynamic> json) =>
      LoginInfo(email: json["email"], password: json["password"]);

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

class TokenResponse {
  String token;

  TokenResponse({required this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      TokenResponse(token: json["token"]);

  Map<String, dynamic> toJson() => {"token": token};
}
