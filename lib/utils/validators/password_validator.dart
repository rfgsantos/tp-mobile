import 'package:formz/formz.dart';

enum PasswordValidationError { invalid, eightLetters, upperCase, lowerCase }

class Password extends FormzInput<String, PasswordValidationError> {
  static final _passwordEightLetters = RegExp(r'^[A-Za-z0-9]{8,}');
  static final _passwordUpperCase = RegExp(r'[A-Z]{1,}');
  static final _passwordLowerCase = RegExp(r'[a-z]');

  final Map<PasswordValidationError, String> errorMessages = const {
    PasswordValidationError.eightLetters: 'Minimum 8 characters',
    PasswordValidationError.upperCase: 'Minimum one uppercase letter',
    PasswordValidationError.lowerCase: 'Must contain lowercase letters'
  };

  final bool isLogin;

  const Password.dirty(super.value, {this.isLogin = false}) : super.dirty();

  const Password.pure({this.isLogin = false}) : super.pure('');

  Map<PasswordValidationError, bool> get _errors => {
        PasswordValidationError.eightLetters:
            _passwordEightLetters.hasMatch(value),
        PasswordValidationError.upperCase: _passwordUpperCase.hasMatch(value),
        PasswordValidationError.lowerCase: _passwordLowerCase.hasMatch(value),
      };

  String composeMessage() {
    return _errors.entries
        .where((element) => !element.value)
        .map((e) => errorMessages[e.key])
        .join("\n");
  }

  @override
  PasswordValidationError? validator(String value) {
    bool loginCondition =
        value.isNotEmpty && _passwordEightLetters.hasMatch(value ?? '');

    bool registerCondition = _passwordEightLetters.hasMatch(value ?? '') &&
        _passwordLowerCase.hasMatch(value ?? '') &&
        _passwordUpperCase.hasMatch(value ?? '') &&
        value.isNotEmpty;

    return isLogin
        ? loginCondition
            ? null
            : PasswordValidationError.invalid
        : registerCondition
            ? null
            : PasswordValidationError.invalid;
  }
}
