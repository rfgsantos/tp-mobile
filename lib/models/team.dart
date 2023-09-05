import 'package:equatable/equatable.dart';
import 'package:tpmobile/models/user.dart';

import 'base.dart';

class Team extends Base {
  String name;
  String? image;
  String description;
  List<Member> members;

  Team(
      {required this.name,
      this.image,
      required this.description,
      required this.members,
      DateTime? updated_at,
      DateTime? created_at,
      int? updated_by,
      int? created_by,
      int? id})
      : super(
            updated_at: updated_at,
            created_at: created_at,
            created_by: created_by,
            updated_by: updated_by,
            id: id);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
        description: json['description'],
        name: json['name'],
        image: json['image'],
        members:
            (json['members'] as List).map((e) => Member.fromJson(e)).toList(),
        id: json['id'],
        updated_at: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        created_at: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updated_by: json['updated_by'],
        created_by: json['created_by']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'image': image,
      'description': description,
      'members': members.map((e) => e.toJson()).toList(),
      ...super.toJson()
    };
  }

  @override
  List<Object?> get props => [name, id, description, members, image];
}

class Role extends Equatable {
  int? id;
  String name;

  Role({required this.name, this.id});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(name: json['name'], id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }

  @override
  List<Object?> get props => [id, name];
}

class Member extends Equatable {
  int? id;
  User? user;
  List<Role>? roles;

  Member({this.user, this.roles, this.id});

  factory Member.empty() => Member(roles: List<Role>.empty(growable: true));

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        id: json['id'],
        user: User.fromJson(json['user']),
        roles: (json['roles'] as List)
            .map((role) => Role.fromJson(role))
            .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'roles': roles?.map((e) => e.toJson()).toList()
    };
  }

  @override
  List<Object?> get props => [user, roles];
}
