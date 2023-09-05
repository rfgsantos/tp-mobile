import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/models/team.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_cubit.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_form.dart';
import 'package:tpmobile/pages/teams/forms/team_form/team_state.dart';
import 'package:tpmobile/utils/widgets/fullscreen_dialog.dart';

class TeamDialog extends StatelessWidget {
  Team? team;

  TeamDialog({super.key, this.team});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamFormCubit>(
      create: (_) => TeamFormCubit(team: team),
      child: BlocBuilder<TeamFormCubit, TeamFormState>(
        builder: (BuildContext context, TeamFormState state) =>
            FullScreenDialog<TeamForm, TeamFormCubit, TeamFormState>(
          dialogTitle: team != null ? team?.name ?? '' : 'Create team',
          widgetBody: const TeamForm(),
          actions: [
            IconButton(
                onPressed:
                    state.status.isValid || !state.status.isSubmissionInProgress
                        ? () => team != null
                            ? context.read<TeamFormCubit>().editTeam()
                            : context.read<TeamFormCubit>().saveNewTeam()
                        : null,
                icon: const Icon(Icons.save))
          ],
        ),
      ),
    );
  }
}
