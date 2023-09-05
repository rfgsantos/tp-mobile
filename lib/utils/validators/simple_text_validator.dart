import 'package:formz/formz.dart';

enum SimpleTextValidationError { valid }

class SimpleText extends FormzInput<String, SimpleTextValidationError> {
  const SimpleText.dirty(super.value) : super.dirty();

  const SimpleText.pure() : super.pure('');

  @override
  SimpleTextValidationError? validator(String value) {
    return null;
  }
}
