import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/teams/team_dialog.dart';
import 'package:tpmobile/utils/validators/list_validator.dart';
import 'package:tpmobile/utils/validators/required_text_validator.dart';
import 'package:tpmobile/utils/validators/username_validator.dart';

import '../../../../models/team.dart';
import '../../../../utils/validators/file_validator.dart';
import '../../../../utils/widgets/status.dart';

enum TeamFormAction { deleteMember, saveTeam, noAction }

class TeamFormState extends Equatable implements Status {
  RequiredText description;
  ExistingName name;
  ListValidator<Member> members;
  FileValidator<String> image;
  FormzStatus status;
  String? errorMessage;
  String? successMessage;
  TeamFormAction action;

  TeamFormState(
      {this.name = const ExistingName.pure(),
      this.description = const RequiredText.pure(),
      this.members = const ListValidator<Member>.pure(),
      this.status = FormzStatus.pure,
      this.action = TeamFormAction.noAction,
      this.image = const FileValidator.pure(),
      this.errorMessage,
      this.successMessage});

  TeamFormState.fromTeam(Team team,
      {this.name = const ExistingName.pure(),
      this.description = const RequiredText.pure(),
      this.members = const ListValidator<Member>.pure(),
      this.image = const FileValidator.pure(),
      this.status = FormzStatus.pure,
      this.action = TeamFormAction.noAction,
      this.errorMessage,
      this.successMessage}) {
    name = ExistingName.dirty(team.name, initialValue: team.name);
    description = RequiredText.dirty(team.description);
    members = ListValidator.dirty(team.members);
    image = FileValidator.dirty(team.image);
    status = Formz.validate(inputs);
  }

  @override
  List<Object?> get props => [name, description, members, status];

  List<FormzInput> get inputs => [name, description, members];

  TeamFormState copyWith(
      {RequiredText? description,
      ExistingName? name,
      ListValidator<Member>? members,
      FormzStatus? status,
      TeamFormAction? action,
      FileValidator<String>? image,
      String? errorMessage,
      String? successMessage}) {
    return TeamFormState(
        name: name ?? this.name,
        description: description ?? this.description,
        members: members ?? this.members,
        status: status ?? this.status,
        image: image ?? this.image,
        action: action ?? this.action,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage);
  }
}
