import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/models/user.dart';
import 'package:tpmobile/utils/validators/email_validator.dart';
import 'package:tpmobile/utils/validators/file_validator.dart';
import 'package:tpmobile/utils/validators/username_validator.dart';

import '../../utils/validators/required_text_validator.dart';
import '../../utils/validators/simple_text_validator.dart';
import '../../utils/widgets/status.dart';

class ProfileFormState extends Equatable implements Status {
  ExistingName username;
  Email email;
  RequiredText first_name;
  RequiredText last_name;
  SimpleText phone_number;
  FileValidator<String> profile_image;
  FormzStatus status;
  String? errorMessage;
  String? successMessage;

  ProfileFormState(
      {this.username = const ExistingName.pure(),
      this.email = const Email.pure(),
      this.first_name = const RequiredText.pure(),
      this.last_name = const RequiredText.pure(),
      this.profile_image = const FileValidator.pure(),
      this.phone_number = const SimpleText.pure(),
      this.status = FormzStatus.pure,
      this.errorMessage,
      this.successMessage});

  ProfileFormState.fromUser(User user,
      {this.username = const ExistingName.pure(),
      this.email = const Email.pure(),
      this.first_name = const RequiredText.pure(),
      this.last_name = const RequiredText.pure(),
      this.profile_image = const FileValidator.pure(),
      this.phone_number = const SimpleText.pure(),
      this.status = FormzStatus.pure,
      this.errorMessage,
      this.successMessage}) {
    username = ExistingName.dirty(user.username, initialValue: user.username);
    email = Email.dirty(user.email);
    first_name = RequiredText.dirty(user.first_name);
    last_name = RequiredText.dirty(user.last_name);
    profile_image = FileValidator.dirty(user.profile_image ?? '');
    phone_number = SimpleText.dirty(user.phone_number ?? '');
    status = Formz.validate(inputs);
  }

  @override
  List<Object?> get props => [username, first_name, last_name, email, status];

  List<FormzInput> get inputs =>
      [username, first_name, last_name, email, profile_image, phone_number];

  ProfileFormState copyWith(
      {ExistingName? username,
      Email? email,
      RequiredText? first_name,
      RequiredText? last_name,
      SimpleText? phone_number,
      FileValidator<String>? profile_image,
      FormzStatus? status,
      String? errorMessage,
      String? successMessage}) {
    return ProfileFormState(
        username: username ?? this.username,
        first_name: first_name ?? this.first_name,
        last_name: last_name ?? this.last_name,
        email: email ?? this.email,
        status: status ?? this.status,
        profile_image: profile_image ?? this.profile_image,
        phone_number: phone_number ?? this.phone_number,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage);
  }
}
