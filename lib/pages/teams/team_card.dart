import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/team.dart';
import 'forms/team_view.dart';
import 'team_dialog.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  static Route<void> _editDialogRoute(context, arguments) {
    return MaterialPageRoute(
        builder: (context) => TeamDialog(team: Team.fromJson(arguments)),
        fullscreenDialog: true);
  }

  static Route<void> _viewTeamDialogRoute(context, arguments) {
    return MaterialPageRoute(
        builder: (context) => TeamView(team: Team.fromJson(arguments)),
        fullscreenDialog: true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Ink.image(
              image: team.image != null
                  ? Image.memory(
                          const Base64Decoder().convert(team.image ?? ""))
                      .image
                  : Image.asset("assets/team.png").image,
              fit: BoxFit.cover,
              height: 240,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Text(team.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24)),
            )
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  team.description ?? '',
                  style: const TextStyle(fontSize: 16),
                ))),
        Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 5, bottom: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            IconButton(
                onPressed: () => Navigator.restorablePush<void>(
                    context, _viewTeamDialogRoute,
                    arguments: team.toJson()),
                icon: const Icon(Icons.info_outline)),
            IconButton(
                onPressed: () => Navigator.restorablePush<void>(
                    context, _editDialogRoute,
                    arguments: team.toJson()),
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.red))
          ]),
        )
      ]),
    );
  }
}
