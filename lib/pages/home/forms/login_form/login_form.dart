import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/home/forms/login_form/login_form_cubit.dart';
import 'package:tpmobile/pages/home/forms/login_form/login_form_state.dart';

import '../../../../utils/widgets/snackbars.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginFormCubit, LoginFormState>(
      listener: (BuildContext context, LoginFormState state) {
        if (state.status.isSubmissionSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                successSnackBar(context, message: 'Login successfully'));
        }
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(errorSnackBar(context,
                message: state.errorMessage ?? 'Login unsuccessful'));
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 4),
        _EmailInput(),
        const SizedBox(height: 4),
        _PasswordInput(),
        const SizedBox(height: 4),
        _LoginButton()
      ]),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LoginFormCubit, LoginFormState>(
          buildWhen: (previous, current) => previous.email != current.email,
          builder: (context, state) => TextFormField(
                key: const Key('login_form_email'),
                onChanged: (email) =>
                    context.read<LoginFormCubit>().emailChanged(email),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Email',
                    helperText: '',
                    errorText: state.email.invalid ? 'Invalid email' : null),
              ));
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LoginFormCubit, LoginFormState>(
          buildWhen: (previous, current) =>
              previous.password != current.password,
          builder: (context, state) => TextField(
                key: const Key("login_form_password"),
                onChanged: (password) =>
                    context.read<LoginFormCubit>().passwordChanged(password),
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  helperText: '',
                  errorText: state.password.invalid ? 'Invalid password' : null,
                ),
              ));
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(
          BuildContext context) =>
      BlocBuilder<LoginFormCubit, LoginFormState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => state.status.isSubmissionInProgress
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      key: const Key("login_form_button"),
                      onPressed: state.status.isValidated
                          ? () => context.read<LoginFormCubit>().login()
                          : null,
                      child: const Text("Login"))));
}
