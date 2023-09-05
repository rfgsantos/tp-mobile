import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tpmobile/utils/widgets/status.dart';

class FullScreenDialog<T extends Widget, C extends Cubit<S>, S extends Status>
    extends StatelessWidget {
  final String dialogTitle;
  final T widgetBody;
  final List<Widget> actions;

  const FullScreenDialog(
      {super.key,
      required this.dialogTitle,
      required this.widgetBody,
      this.actions = const []});

  @override
  Widget build(BuildContext context) => BlocBuilder<C, S>(
      builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: Text(dialogTitle),
              actions: actions,
            ),
            body: Column(mainAxisSize: MainAxisSize.max, children: [
              state.status.isSubmissionInProgress
                  ? const LinearProgressIndicator(minHeight: 10)
                  : Container(),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(16), child: widgetBody))
            ]),
          ));
}
