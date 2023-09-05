import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_state.dart';
import 'package:tpmobile/services/authentication_repository.dart';
import 'package:tpmobile/services/teams_repository.dart';
import 'package:tpmobile/utils/validators/file_validator.dart';
import 'package:tpmobile/utils/validators/list_validator.dart';
import 'package:tpmobile/utils/validators/required_text_validator.dart';
import 'package:tpmobile/utils/validators/username_validator.dart';
import 'dart:io';
import '../../../../models/team.dart';
import '../../../../models/user.dart';
import '../../../../services/setup_di.dart';

class TeamFormCubit extends Cubit<TeamFormState> {
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();
  final TeamsRepository _teamsRepository = getIt<TeamsRepository>();
  Team? team;
  XFile? file;

  TeamFormCubit({this.team})
      : super(team != null ? TeamFormState.fromTeam(team) : TeamFormState()) {
    if (team == null) emit(initNewTeamState());
  }

  TeamFormState initNewTeamState() {
    User user = _authenticationRepository.user;
    List<Role> roles = _teamsRepository.roles;
    Member initialMember = Member(
        roles: roles.where((element) => element.name == 'Captain').toList(),
        user: user);
    return TeamFormState(members: ListValidator.pure(members: [initialMember]));
  }

  void descriptionChanged(String value) {
    final description = RequiredText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.description);
    emit(state.copyWith(
        description: description,
        status: Formz.validate([description, ...inputs])));
  }

  void nameChanged(String value) {
    if (state.name.initialValue == value) {
      emit(state.copyWith(
          name:
              ExistingName.dirty(value, initialValue: state.name.initialValue),
          status: Formz.validate([...state.inputs])));
    } else {
      _teamsRepository.teamNameExists(value).then((bool exists) {
        final name = ExistingName.dirty(value,
            exists: exists, initialValue: state.name.initialValue);
        List<FormzInput> inputs = [...state.inputs];
        inputs.remove(state.name);
        emit(state.copyWith(
            name: name, status: Formz.validate([name, ...inputs])));
      });
    }
  }

  void _membersChanged(List<Member> value) {
    final members = ListValidator.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.members);
    emit(state.copyWith(
        members: members, status: Formz.validate([members, ...inputs])));
  }

  void addMember({Member? member}) {
    final memberToAdd = member ?? Member.empty();
    final memberList = [...state.members.value, memberToAdd];
    _membersChanged(memberList);
  }

  void removeMember(int index) {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final memberList = List<Member>.from(state.members.value);

    if (memberList[index].id != null && team?.id != null) {
      _teamsRepository
          .deleteTemMemberById(team?.id ?? 0, memberList[index].id ?? 0)
          .then((_) {
        emit(state.copyWith(
            successMessage: 'Member removed successfully',
            status: FormzStatus.submissionSuccess,
            action: TeamFormAction.deleteMember));
        memberList.removeAt(index);
        _membersChanged(memberList);
      }).catchError((error) {
        emit(state.copyWith(
            successMessage: 'Error removing member',
            status: FormzStatus.submissionFailure,
            action: TeamFormAction.deleteMember));
      });
    } else {
      memberList.removeAt(index);
      _membersChanged(memberList);
      emit(state.copyWith(
          successMessage: 'Member removed successfully',
          status: FormzStatus.submissionSuccess,
          action: TeamFormAction.deleteMember));
    }
  }

  void removeRole(Role role, int index) {
    final memberList = List<Member>.from(state.members.value);
    memberList[index].roles?.remove(role);
    _membersChanged(memberList);
  }

  void addUserToMember(User user, int index) {
    List<Member> memberList = List<Member>.from(state.members.value);
    memberList[index].user = user;
    _membersChanged(memberList);
  }

  void addRoleToUser(Role role, int index) {
    final memberList = [...state.members.value];
    memberList[index].roles?.add(role);
    _membersChanged(memberList);
  }

  void changeFile(XFile file) {
    this.file = file;
    final image = FileValidator<String>.dirty(
        base64Encode(File(file.path).readAsBytesSync()));
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.image);
    emit(state.copyWith(
        image: image, status: Formz.validate([image, ...inputs])));
  }

  void editTeam() {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    Team _team = Team(
        name: state.name.value,
        description: state.description.value,
        members: state.members.value,
        image: state.image.value,
        id: team?.id);
    _teamsRepository.updateTeam(_team).then((Team value) {
      if (file != null) {
        addImageToTeam(value.id);
      } else {
        emit(state.copyWith(
            status: FormzStatus.submissionSuccess,
            action: TeamFormAction.saveTeam));
      }
    }).catchError((error) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    });
  }

  void saveNewTeam() {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    Team _team = Team(
        name: state.name.value,
        description: state.description.value,
        image: state.image.value,
        members: state.members.value);
    _teamsRepository.saveTeam(_team).then((Team value) {
      if (file != null) {
        addImageToTeam(value.id);
      } else {
        emit(state.copyWith(
            status: FormzStatus.submissionSuccess,
            action: TeamFormAction.saveTeam));
      }
    }).catchError((error) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    });
  }

  void addImageToTeam(int? teamId) {
    _teamsRepository.addImageToTeam(file, teamId).then((Team value) {
      emit(state.copyWith(
          status: FormzStatus.submissionSuccess,
          action: TeamFormAction.saveTeam));
    }).catchError((error) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    });
  }
}
