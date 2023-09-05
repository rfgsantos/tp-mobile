import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/profile/profile_cubit.dart';
import 'package:tpmobile/pages/profile/profile_state.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_cubit.dart';
import 'package:tpmobile/utils/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<ProfileFormCubit, ProfileFormState>(
        listener: (BuildContext context, ProfileFormState state) {
          if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  errorSnackBar(context, message: state.errorMessage));
          }

          if (state.status.isSubmissionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  successSnackBar(context, message: state.successMessage));
          }
        },
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ProfileImage(),
            const SizedBox(height: 16),
            _ProfileUsernameInput(),
            const SizedBox(height: 8),
            _ProfileEmailInput(),
            const SizedBox(height: 8),
            _ProfileFirstnameInput(),
            const SizedBox(height: 8),
            _ProfileLastNameInput(),
            const SizedBox(height: 8),
            _ProfilePhoneNumberNameInput(),
          ],
        )),
      );
}

class _ProfileImage extends StatefulWidget {
  const _ProfileImage();

  @override
  State<StatefulWidget> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<_ProfileImage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _file = null;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileFormCubit, ProfileFormState>(
          buildWhen: (previous, current) =>
              previous.profile_image != current.profile_image,
          builder: (context, state) =>
              _file != null || state.profile_image.value != null
                  ? GestureDetector(
                      onTap: _showModalBottomSheet,
                      child: Container(
                          height: 300,
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: imageToShow(state, _file)))
                  : GestureDetector(
                      onTap: _showModalBottomSheet,
                      child: Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          color: Colors.black12,
                          width: double.infinity,
                          child: const Icon(
                            Icons.image,
                            size: 40,
                          ))));

  Widget imageToShow(ProfileFormState state, XFile? file) {
    return file != null
        ? Image.file(File(_file?.path ?? ''))
        : Image.memory(
            const Base64Decoder().convert(state.profile_image.value ?? ""));
  }

  void _handleImageCallback(ImageSource source) {
    _picker.pickImage(source: source).then((XFile? value) {
      if (value != null) {
        setState(() {
          _file = value;
        });
        context.read<ProfileFormCubit>().changeFile(value);
      }
    }).catchError((error) => print(error));
    Navigator.pop(context);
  }

  void _showModalBottomSheet() => showModalBottomSheet(
      context: context,
      builder: (context) => Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                    onPressed: () => _handleImageCallback(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Camera")),
                TextButton.icon(
                    onPressed: () => _handleImageCallback(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"))
              ])));
}

class _ProfileUsernameInput extends StatelessWidget {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileFormCubit,
          ProfileFormState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) => TextFormField(
            initialValue: state.username.value,
            key: const Key("edit_team_name"),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () =>
                      context.read<ProfileFormCubit>().usernameChanged(value));
            },
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Username',
                helperText: '',
                errorText:
                    state.username.invalid ? 'Username already exists' : null),
          ));
}

class _ProfileEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) => TextFormField(
                initialValue: state.email.value,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) =>
                    context.read<ProfileFormCubit>().emailChanged(value),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Email',
                    helperText: '',
                    errorText:
                        state.email.invalid ? 'Field is required' : null),
              ));
}

class _ProfileFirstnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) => TextFormField(
                initialValue: state.first_name.value,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) =>
                    context.read<ProfileFormCubit>().firstNameChanged(value),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'First name',
                    helperText: '',
                    errorText:
                        state.first_name.invalid ? 'Field is required' : null),
              ));
}

class _ProfileLastNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) => TextFormField(
                initialValue: state.last_name.value,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) =>
                    context.read<ProfileFormCubit>().lastNameChanged(value),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Last name',
                    helperText: '',
                    errorText:
                        state.last_name.invalid ? 'Field is required' : null),
              ));
}

class _ProfilePhoneNumberNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) => TextFormField(
                initialValue: state.phone_number.value,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) =>
                    context.read<ProfileFormCubit>().lastNameChanged(value),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Phone number',
                    helperText: '',
                    errorText: state.phone_number.invalid
                        ? 'Field is required'
                        : null),
              ));
}
