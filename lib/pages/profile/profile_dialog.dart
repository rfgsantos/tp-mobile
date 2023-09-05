import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/pages/profile/profile_cubit.dart';
import 'package:tpmobile/pages/profile/profile_form.dart';
import 'package:tpmobile/pages/profile/profile_state.dart';

import '../../models/user.dart';
import '../../utils/widgets/fullscreen_dialog.dart';

class ProfileDialog extends StatelessWidget {
  User? user;

  ProfileDialog({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileFormCubit>(
      create: (_) => ProfileFormCubit(user: user),
      child: BlocBuilder<ProfileFormCubit, ProfileFormState>(
        builder: (BuildContext context, ProfileFormState state) =>
            FullScreenDialog<ProfileForm, ProfileFormCubit, ProfileFormState>(
          dialogTitle: 'Profile',
          widgetBody: const ProfileForm(),
          actions: [
            IconButton(
                onPressed:
                    state.status.isValid || !state.status.isSubmissionInProgress
                        ? () => context.read<ProfileFormCubit>().saveProfile()
                        : null,
                icon: const Icon(Icons.save))
          ],
        ),
      ),
    );
  }
}
