import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/home/forms/register_form/register_form_cubit.dart';
import 'package:tpmobile/pages/home/forms/register_form/register_form_state.dart';

import '../../../../utils/widgets/snackbars.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterFormCubit, RegisterFormState>(
        listener: (BuildContext context, RegisterFormState state) {
          if (state.status.isSubmissionSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  successSnackBar(context, message: 'Registration complete'));
          }
          if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  errorSnackBar(context, message: 'Registration unsuccessful'));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UsernameInput(),
            _EmailInput(),
            _FirstNameInput(),
            _LastNameInput(),
            _PasswordInput(),
            _PhoneNumberInput(),
            const SizedBox(height: 8),
            _RegisterButton()
          ],
        ));
  }
}

class _UsernameInput extends StatelessWidget {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) => previous.username != current.username,
        builder: (context, state) => TextFormField(
              key: const Key("register_form_username"),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(
                    const Duration(milliseconds: 500),
                    () => context
                        .read<RegisterFormCubit>()
                        .usernameChanged(value));
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Username',
                helperText: '',
                errorText:
                    state.username.invalid ? 'Username already exists' : null,
              ),
            ));
  }
}

class _FirstNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) =>
            previous.first_name != current.first_name,
        builder: (BuildContext context, RegisterFormState state) =>
            TextFormField(
              key: const Key("register_form_firstname"),
              onChanged: (value) =>
                  context.read<RegisterFormCubit>().firstNameChanged(value),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'First name',
                  helperText: '',
                  errorText:
                      state.first_name.invalid ? 'Required field' : null),
            ));
  }
}

class _LastNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) =>
            previous.last_name != current.last_name,
        builder: (BuildContext context, RegisterFormState state) =>
            TextFormField(
              key: const Key("register_form_lastname"),
              onChanged: (value) =>
                  context.read<RegisterFormCubit>().lastNameChanged(value),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Last name',
                  helperText: '',
                  errorText:
                      state.first_name.invalid ? 'Required field' : null),
            ));
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (BuildContext context, RegisterFormState state) =>
            TextFormField(
              key: const Key("register_form_email"),
              onChanged: (value) =>
                  context.read<RegisterFormCubit>().emailChanged(value),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Email',
                  helperText: '',
                  errorText: state.email.invalid ? 'Email is invalid' : null),
            ));
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (BuildContext context, RegisterFormState state) =>
            TextFormField(
              key: const Key("register_form_password"),
              obscureText: true,
              onChanged: (value) =>
                  context.read<RegisterFormCubit>().passwordChanged(value),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  helperText: '',
                  errorMaxLines: 4,
                  errorText: state.password.invalid
                      ? state.password.composeMessage()
                      : null),
            ));
  }
}

class _PhoneNumberInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) =>
            previous.phone_number != current.phone_number,
        builder: (BuildContext context, RegisterFormState state) =>
            TextFormField(
              key: const Key("register_form_phone_number"),
              onChanged: (value) =>
                  context.read<RegisterFormCubit>().phoneNumberChanged(value),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Phone number',
                  helperText: 'Optional',
                  errorText: state.phone_number.invalid
                      ? 'Invalid phone number'
                      : null),
            ));
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (BuildContext context, RegisterFormState state) => state
                .status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    key: const Key("register_form_button"),
                    onPressed: state.status.isValidated
                        ? () => context.read<RegisterFormCubit>().register()
                        : null,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Register")),
              ));
  }
}
