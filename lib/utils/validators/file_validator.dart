import 'dart:io';
import 'package:formz/formz.dart';

enum FileValidatorErrors { invalid }

class FileValidator<T> extends FormzInput<T?, FileValidatorErrors> {
  final bool isRequired;

  const FileValidator.pure({this.isRequired = false}) : super.pure(null);

  const FileValidator.dirty(super.value, {this.isRequired = false})
      : super.dirty();

  @override
  FileValidatorErrors? validator(value) =>
      isRequired && value == null ? FileValidatorErrors.invalid : null;
}
