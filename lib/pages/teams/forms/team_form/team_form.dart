import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_cubit.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_state.dart';
import 'package:tpmobile/services/teams_repository.dart';
import 'package:tpmobile/services/user_repository.dart';
import 'package:tpmobile/utils/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/team.dart';
import '../../../../models/user.dart';
import '../../../../services/setup_di.dart';

class TeamForm extends StatelessWidget {
  const TeamForm({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<TeamFormCubit, TeamFormState>(
        listener: (BuildContext context, TeamFormState state) {
          if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  errorSnackBar(context, message: state.errorMessage));
          }

          if (state.status.isSubmissionSuccess) {
            if (state.action == TeamFormAction.saveTeam) {
              Navigator.of(context).pop();
            }
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
            const _TeamImage(),
            const SizedBox(height: 16),
            _TeamNameInput(),
            const SizedBox(height: 8),
            _DescriptionInput(),
            _AddMembersRow(),
            const SizedBox(height: 16),
            const _Members()
          ],
        )),
      );
}

class _TeamImage extends StatefulWidget {
  const _TeamImage();

  @override
  State<StatefulWidget> createState() => _TeamImageState();
}

class _TeamImageState extends State<_TeamImage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _file = null;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TeamFormCubit, TeamFormState>(
          buildWhen: (previous, current) => previous.image != current.image,
          builder: (context, state) =>
              _file != null || state.image.value != null
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

  Widget imageToShow(TeamFormState state, XFile? file) {
    return file != null
        ? Image.file(File(_file?.path ?? ''))
        : Image.memory(const Base64Decoder().convert(state.image.value ?? ""));
  }

  void _handleImageCallback(ImageSource source) {
    _picker.pickImage(source: source).then((XFile? value) {
      if (value != null) {
        setState(() {
          _file = value;
        });
        context.read<TeamFormCubit>().changeFile(value);
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

class _TeamNameInput extends StatelessWidget {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TeamFormCubit, TeamFormState>(
          buildWhen: (previous, current) => previous.name != current.name,
          builder: (context, state) => TextFormField(
                initialValue: state.name.value,
                key: const Key("edit_team_name"),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500),
                      () => context.read<TeamFormCubit>().nameChanged(value));
                },
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Name',
                    helperText: '',
                    errorText:
                        state.name.invalid ? 'Team name already exists' : null),
              ));
}

class _DescriptionInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TeamFormCubit, TeamFormState>(
          builder: (context, state) => TextFormField(
                initialValue: state.description.value,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                key: const Key("edit_team_description"),
                onChanged: (value) =>
                    context.read<TeamFormCubit>().descriptionChanged(value),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Description',
                    helperText: '',
                    errorText:
                        state.description.invalid ? 'Field is required' : null),
              ));
}

class _AddMembersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Team members",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
                width: 22,
                height: 22,
                child: FloatingActionButton.small(
                  onPressed: () => context.read<TeamFormCubit>().addMember(),
                  child: const Icon(
                    Icons.add,
                    size: 15,
                  ),
                ))
          ],
        ),
      );
}

class _Members extends StatefulWidget {
  const _Members();

  @override
  State createState() => _MembersState();
}

class _MembersState extends State<_Members> {
  final TeamsRepository _teamsRepository = getIt<TeamsRepository>();
  List<Role> roles = [];

  @override
  void initState() {
    _teamsRepository.getRoles().then((List<Role> value) {
      setState(() {
        roles = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TeamFormCubit, TeamFormState>(
          buildWhen: (previous, current) =>
              previous.members != current.members || roles.isNotEmpty,
          builder: (context, state) => ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Divider(
                      color: Colors.black54,
                      thickness: 0.5,
                    ),
                  ),
              itemCount: state.members.value.length,
              itemBuilder: (BuildContext context, int index) => index == 0
                  ? _MemberRow(state.members.value[index], index, roles)
                  : Dismissible(
                      key: const ValueKey(0),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        context.read<TeamFormCubit>().removeMember(index);
                      },
                      background: Container(
                          color: Colors.red,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.delete, color: Colors.white),
                                        Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ])))),
                      child: _MemberRow(
                          state.members.value[index], index, roles))));
}

class _MemberRow extends StatelessWidget {
  final Member member;
  final int index;
  final List<Role> roles;
  final UserRepository _userRepository = getIt<UserRepository>();

  static String _displayEmailForUser(User userOption) => userOption.email;

  static String _displayNameForRole(Role roleOption) => roleOption.name;

  _MemberRow(this.member, this.index, this.roles);

  @override
  Widget build(BuildContext context) => BlocBuilder<TeamFormCubit,
          TeamFormState>(
      builder: (context, state) => Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Autocomplete<User>(
                    initialValue:
                        TextEditingValue(text: member.user?.email ?? ''),
                    displayStringForOption: _displayEmailForUser,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<User>.empty();
                      }
                      return _userRepository
                          .getUserByEmail(textEditingValue.text);
                    },
                    fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) =>
                        TextFormField(
                      enabled: index != 0,
                      focusNode: focusNode,
                      controller: textEditingController,
                      onFieldSubmitted: (String value) => print("on submitted"),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.search)),
                    ),
                    onSelected: (User selection) => context
                        .read<TeamFormCubit>()
                        .addUserToMember(selection, index),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Autocomplete<Role>(
                          displayStringForOption: _displayNameForRole,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Role>.empty();
                            }
                            return roles.where((element) => element.name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) =>
                              TextFormField(
                                focusNode: focusNode,
                                controller: textEditingController,
                                onEditingComplete: onFieldSubmitted,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Role',
                                    prefixIcon: Icon(Icons.search)),
                              ),
                          onSelected: (Role selection) {
                            print("selected");
                            context
                                .read<TeamFormCubit>()
                                .addRoleToUser(selection, index);
                          })
                    ],
                  ),
                ),
              ],
            ),
            Row(children: [
              ...?member.roles
                  ?.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Chip(
                          label: Text(
                            e.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 14,
                          ),
                          onDeleted: () => context
                              .read<TeamFormCubit>()
                              .removeRole(e, index),
                        ),
                      ))
                  .toList()
            ])
          ]));
}
