import 'package:equatable/equatable.dart';
import 'package:tpmobile/models/stage.dart';
import 'package:tpmobile/models/team.dart';

import 'base.dart';

class Plan extends Base {
  String name;
  String? description;
  DateTime start_date;
  DateTime arrival_date;
  String? state;
  String? image;
  Team team;
  String? identifier;

  Plan(
      {required this.name,
      this.description,
      required this.start_date,
      required this.arrival_date,
      this.state,
      this.image,
      required this.team,
      this.identifier,
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

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
      name: json['name'],
      description: json['description'],
      start_date: DateTime.parse(json['start_date']),
      arrival_date: DateTime.parse(json['arrival_date']),
      image: json['image'],
      team: Team.fromJson(json['team']),
      identifier: json['identifier'],
      state: json['state'],
      id: json['id'],
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updated_by: json['updated_by'],
      created_by: json['created_by']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'description': description,
        'start_date': start_date.toString(),
        'arrival_date': arrival_date.toString(),
        'identifier': identifier,
        'state': state,
        'team': team.toJson(),
        ...super.toJson()
      };

  @override
  List<Object?> get props => [
        name,
        id,
        description,
        state,
        arrival_date,
        start_date,
        image,
        identifier
      ];
}

class PlanWrapper extends Equatable {
  final Plan plan;
  final List<StageSummaryFullWrapper> summaries;

  const PlanWrapper({required this.plan, required this.summaries});

  @override
  List<Object?> get props => [plan, summaries];

  Map<String, dynamic> toJson() => {
        'plan': plan.toJson(),
        'summaries': summaries.map((e) => e.toJson()).toList()
      };

  factory PlanWrapper.fromJson(Map<String, dynamic> json) => PlanWrapper(
      plan: Plan.fromJson(json['plan']),
      summaries: (json['summaries'] as List)
          .map((e) => StageSummaryFullWrapper.fromJson(e))
          .toList());
}
