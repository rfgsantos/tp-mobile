import 'package:formz/formz.dart';

enum ExistingNameValidationError { exists }

class ExistingName extends FormzInput<String, ExistingNameValidationError> {
  final bool exists;
  final String initialValue;

  const ExistingName.dirty(value, {this.exists = false, this.initialValue = ''})
      : super.dirty(value);

  const ExistingName.pure({this.exists = false, this.initialValue = ''})
      : super.pure('');

  @override
  ExistingNameValidationError? validator(String value) {
    return value.isNotEmpty && !exists
        ? null
        : ExistingNameValidationError.exists;
  }
}
