import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../models/team.dart';

class TeamView extends StatelessWidget {
  final Team team;

  const TeamView({super.key, required this.team});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Team details")),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _TeamImage(team: team),
                const SizedBox(height: 12),
                _TeamDetails(team: team),
                const SizedBox(height: 12),
                _TeamMembers(team: team)
              ]),
            )),
      );
}

class _TeamImage extends StatelessWidget {
  final Team team;

  const _TeamImage({required this.team});

  @override
  Widget build(BuildContext context) => Container(
      height: 300,
      child: team.image != null
          ? Image.memory(const Base64Decoder().convert(team.image ?? ""))
          : Image.asset("assets/team.png"));
}

class _TeamDetails extends StatelessWidget {
  final Team team;

  const _TeamDetails({required this.team});

  @override
  Widget build(BuildContext context) => Column(children: [
        TextFormField(
            enabled: false,
            initialValue: team.name,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Name',
            )),
        TextFormField(
            enabled: false,
            initialValue: team.description,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Description',
            ))
      ]);
}

class _TeamMembers extends StatelessWidget {
  final Team team;

  const _TeamMembers({required this.team});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text("Team members",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 16,
          ),
          ...team.members.map((Member m) => _memberDisplay(m)).toList()
        ],
      );

  Widget _memberDisplay(Member member) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: member.user?.profile_image != null
                  ? Image.memory(const Base64Decoder()
                          .convert(member.user?.profile_image ?? ""))
                      .image
                  : Image.asset("assets/avatar.png").image,
            ),
            Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.user?.getCompleteName() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(member.roles
                            ?.map((Role role) => role.name)
                            .join(", ") ??
                        '')
                  ],
                ))
          ],
        ),
      );
}
