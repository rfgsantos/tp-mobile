import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/models/register.dart';
import 'package:tpmobile/pages/home/forms/register_form/register_form_state.dart';
import 'package:tpmobile/services/user_repository.dart';
import 'package:tpmobile/utils/validators/phone_number_validator.dart';
import 'package:tpmobile/utils/validators/required_text_validator.dart';
import 'package:tpmobile/utils/validators/username_validator.dart';
import 'package:tpmobile/utils/widgets/snackbars.dart';

import '../../../../services/authentication_repository.dart';
import '../../../../services/setup_di.dart';
import '../../../../utils/validators/email_validator.dart';
import '../../../../utils/validators/password_validator.dart';

class RegisterFormCubit extends Cubit<RegisterFormState> {
  final UserRepository _userRepository = getIt<UserRepository>();
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();

  RegisterFormCubit() : super(const RegisterFormState());

  void register() {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    _authenticationRepository
        .register(Register(
            last_name: state.last_name.value,
            first_name: state.first_name.value,
            email: state.email.value,
            username: state.username.value,
            password: state.password.value,
            phone_number: state.phone_number.value))
        .then((value) {
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    }).catchError((error) {
      emit(state.copyWith(
          errorMessage: (error as DioError).response?.data['message']['error']
              [0],
          status: FormzStatus.submissionFailure));
    });
  }

  void emailChanged(String value) {
    final email = Email.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.email);
    emit(state.copyWith(
        email: email, status: Formz.validate([email, ...inputs])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.password);
    emit(state.copyWith(
        password: password, status: Formz.validate([password, ...inputs])));
  }

  void usernameChanged(String value) {
    _userRepository.usernameExists(value).then((bool exists) {
      var username = ExistingName.dirty(value, exists: exists);
      List<FormzInput> inputs = [...state.inputs];
      inputs.remove(state.username);
      emit(state.copyWith(
          username: username, status: Formz.validate([username, ...inputs])));
    });
  }

  void lastNameChanged(String value) {
    final lastName = RequiredText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.last_name);
    emit(state.copyWith(
        last_name: lastName, status: Formz.validate([lastName, ...inputs])));
  }

  void firstNameChanged(String value) {
    final firstName = RequiredText.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.first_name);
    emit(state.copyWith(
        first_name: firstName, status: Formz.validate([firstName, ...inputs])));
  }

  void phoneNumberChanged(String value) {
    final phoneNumber = PhoneNumber.dirty(value);
    List<FormzInput> inputs = [...state.inputs];
    inputs.remove(state.phone_number);
    emit(state.copyWith(
        phone_number: phoneNumber,
        status: Formz.validate([phoneNumber, ...inputs])));
  }
}
