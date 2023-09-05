import 'package:formz/formz.dart';

enum EmailValidationError { invalid }

class Email extends FormzInput<String, EmailValidationError> {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  const Email.dirty(super.value) : super.dirty();

  const Email.pure() : super.pure('');

  @override
  EmailValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) && value.isNotEmpty
        ? null
        : EmailValidationError.invalid;
  }
}
