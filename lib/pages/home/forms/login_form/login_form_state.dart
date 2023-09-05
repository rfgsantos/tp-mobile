import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/utils/validators/password_validator.dart';

import '../../../../utils/validators/email_validator.dart';

class LoginFormState extends Equatable {
  final Email email;
  final Password password;
  final FormzStatus status;
  final String? errorMessage;

  const LoginFormState(
      {this.email = const Email.pure(),
      this.password = const Password.pure(isLogin: true),
      this.status = FormzStatus.pure,
      this.errorMessage});

  @override
  List<Object> get props => [email, password, status];

  LoginFormState copyWith(
      {Email? email,
      Password? password,
      FormzStatus? status,
      String? errorMessage}) {
    return LoginFormState(
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
