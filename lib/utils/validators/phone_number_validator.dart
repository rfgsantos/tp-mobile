import 'package:formz/formz.dart';

enum PhoneNumberValidationError { invalid }

class PhoneNumber extends FormzInput<String, PhoneNumberValidationError> {
  const PhoneNumber.dirty(super.value) : super.dirty();

  const PhoneNumber.pure() : super.pure('');

  @override
  PhoneNumberValidationError? validator(String value) {
    return null;
  }
}
