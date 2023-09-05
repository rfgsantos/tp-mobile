import 'package:equatable/equatable.dart';

class User {
  int id;
  String email;
  String username;
  String last_name;
  String first_name;
  String? phone_number;
  String? profile_image;

  User(
      {required this.id,
      required this.email,
      required this.username,
      required this.last_name,
      required this.first_name,
      this.phone_number,
      this.profile_image});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      username: json['username'],
      phone_number: json['phone_number'],
      profile_image: json['profile_image']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "first_name": first_name,
        "last_name": last_name,
        "phone_number": phone_number,
        "profile_image": profile_image
      };

  String getCompleteName() => "$first_name $last_name";

  @override
  String toString() {
    return """
    id: $id 
    username: $username
    email: $email
    first_name: $first_name
    last_name: $last_name
    phone_number: $phone_number
    profile_image: $profile_image
    """;
  }
}
