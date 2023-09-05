import 'package:formz/formz.dart';

import '../../models/team.dart';

enum ListValidatorError { empty }

class ListValidator<T> extends FormzInput<List<T>, ListValidatorError> {
  final List<T> members;

  const ListValidator.pure({this.members = const []}) : super.pure(members);

  const ListValidator.dirty(super.value, {this.members = const []})
      : super.dirty();

  @override
  ListValidatorError? validator(List<T> value) {
    return value.isEmpty ? ListValidatorError.empty : null;
  }
}
