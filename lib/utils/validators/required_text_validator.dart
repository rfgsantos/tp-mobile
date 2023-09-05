import 'package:formz/formz.dart';

enum RequiredTextValidationError { invalid }

class RequiredText extends FormzInput<String, RequiredTextValidationError> {
  const RequiredText.dirty(super.value) : super.dirty();

  const RequiredText.pure() : super.pure('');

  @override
  RequiredTextValidationError? validator(String value) {
    return value.isNotEmpty ? null : RequiredTextValidationError.invalid;
  }
}
