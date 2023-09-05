import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/utils/validators/password_validator.dart';
import 'package:tpmobile/utils/validators/required_text_validator.dart';

import '../../../../utils/validators/email_validator.dart';
import '../../../../utils/validators/phone_number_validator.dart';
import '../../../../utils/validators/username_validator.dart';

class RegisterFormState extends Equatable {
  final Email email;
  final Password password;
  final ExistingName username;
  final RequiredText last_name;
  final RequiredText first_name;
  final PhoneNumber phone_number;
  final FormzStatus status;
  final String? errorMessage;

  const RegisterFormState(
      {this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.username = const ExistingName.pure(),
      this.first_name = const RequiredText.pure(),
      this.last_name = const RequiredText.pure(),
      this.phone_number = const PhoneNumber.pure(),
      this.status = FormzStatus.pure,
      this.errorMessage});

  @override
  List<Object> get props =>
      [email, password, username, last_name, first_name, phone_number, status];

  List<FormzInput> get inputs =>
      [email, password, username, last_name, first_name, phone_number];

  RegisterFormState copyWith(
      {Email? email,
      Password? password,
      ExistingName? username,
      RequiredText? first_name,
      RequiredText? last_name,
      PhoneNumber? phone_number,
      FormzStatus? status,
      String? errorMessage}) {
    return RegisterFormState(
        email: email ?? this.email,
        password: password ?? this.password,
        username: username ?? this.username,
        first_name: first_name ?? this.first_name,
        last_name: last_name ?? this.last_name,
        phone_number: phone_number ?? this.phone_number,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
