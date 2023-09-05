import 'package:equatable/equatable.dart';

class Base extends Equatable {
  int? id;
  DateTime? updated_at;
  DateTime? created_at;
  int? updated_by;
  int? created_by;

  Base(
      {this.id,
      this.updated_at,
      this.created_at,
      this.updated_by,
      this.created_by});

  Map<String, dynamic> toJson() => {
        'id': id,
        'updated_at': updated_at.toString(),
        'created_at': created_at.toString(),
        'updated_by': updated_by,
        'created_by': created_by,
      };

  @override
  List<Object?> get props => throw UnimplementedError();
}
