import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/home/forms/login_form/login_form_state.dart';
import 'package:tpmobile/utils/shared_preferences_helper.dart';

import '../../../../models/login.dart';
import '../../../../services/authentication_repository.dart';
import '../../../../services/setup_di.dart';
import '../../../../utils/validators/email_validator.dart';
import '../../../../utils/validators/password_validator.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();
  final SharedPreferencesHelper _sharedPreferencesHelper =
      getIt<SharedPreferencesHelper>();

  LoginFormCubit() : super(const LoginFormState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
        email: email, status: Formz.validate([email, state.password])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value, isLogin: true);
    emit(state.copyWith(
        password: password, status: Formz.validate([state.email, password])));
  }

  void login() {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    _authenticationRepository
        .logIn(
            LoginInfo(email: state.email.value, password: state.password.value))
        .then((TokenResponse value) {
      _sharedPreferencesHelper.setUserToken(userToken: value.token);
      _authenticationRepository.statusSink
          .add(AuthenticationStatus.authenticated);
      _authenticationRepository.getUserDetails().then((value) {
        _authenticationRepository.userSink.add(value);
        _sharedPreferencesHelper.setKeyValueObject<Map<String, dynamic>>(
            key: SharedPreferencesHelper.user, value: value.toJson());
      });
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    }).catchError((error) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure,
          errorMessage: (error as DioError).response?.data['message']['error']
              [0]));
    });
  }
}
