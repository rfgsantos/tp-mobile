import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tpmobile/pages/profile/profile_state.dart';
import 'package:tpmobile/services/user_repository.dart';
import 'package:tpmobile/utils/validators/required_text_validator.dart';
import 'package:tpmobile/utils/validators/username_validator.dart';
import 'dart:io';
import '../../../../models/user.dart';
import '../../../../services/setup_di.dart';
import '../../services/authentication_repository.dart';
import '../../utils/validators/email_validator.dart';
import '../../utils/validators/file_validator.dart';
import '../../utils/validators/simple_text_validator.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  final UserRepository _userRepository = getIt<UserRepository>();
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();
  User? user;
  XFile? file;

  ProfileFormCubit({this.user})
      : super(user != null
            ? ProfileFormState.fromUser(user)
            : ProfileFormState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.email);
    emit(state.copyWith(
        email: email, status: Formz.validate([email, ...inputs])));
  }

  void changeFile(XFile file) {
    this.file = file;
    final profileImage = FileValidator<String>.dirty(
        base64Encode(File(file.path).readAsBytesSync()));
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.profile_image);
    emit(state.copyWith(
        profile_image: profileImage,
        status: Formz.validate([profileImage, ...inputs])));
  }

  void usernameChanged(String value) {
    if (state.username.initialValue == value) {
      emit(state.copyWith(
          username: ExistingName.dirty(value,
              initialValue: state.username.initialValue),
          status: Formz.validate([...state.inputs])));
    } else {
      _userRepository.usernameExists(value).then((bool exists) {
        final username = ExistingName.dirty(value,
            exists: exists, initialValue: state.username.initialValue);
        List<FormzInput> inputs = [...state.inputs];
        inputs.remove(state.username);
        emit(state.copyWith(
            username: username, status: Formz.validate([username, ...inputs])));
      });
    }
  }

  void firstNameChanged(String value) {
    final firstName = RequiredText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.first_name);
    emit(state.copyWith(
        first_name: firstName, status: Formz.validate([firstName, ...inputs])));
  }

  void lastNameChanged(String value) {
    final lastName = RequiredText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.last_name);
    emit(state.copyWith(
        last_name: lastName, status: Formz.validate([lastName, ...inputs])));
  }

  void phoneNumberChanged(String value) {
    final phoneNumber = SimpleText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.phone_number);
    emit(state.copyWith(
        phone_number: phoneNumber,
        status: Formz.validate([phoneNumber, ...inputs])));
  }

  void saveProfile() {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    User user = User(
        id: this.user?.id ?? 0,
        email: state.email.value,
        first_name: state.first_name.value,
        last_name: state.last_name.value,
        username: state.username.value);

    _userRepository.saveProfile(file, user).then((User value) {
      emit(state.copyWith(
          status: FormzStatus.submissionSuccess,
          successMessage: 'Profile saved sucessfully'));
      _authenticationRepository.userSink.add(value);
    }).catchError((error) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure,
          errorMessage: 'Error saving profile'));
    });
  }
}
