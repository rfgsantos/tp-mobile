import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tpmobile/pages/plans/plan_details.dart';

import '../../models/plan.dart';

class PlanCard extends StatelessWidget {
  final PlanWrapper planWrapper;

  const PlanCard({super.key, required this.planWrapper});

  static Route<void> _detailsDialogRoute(context, arguments) {
    return MaterialPageRoute(
        builder: (context) =>
            PlanDetails(planWrapper: PlanWrapper.fromJson(arguments)));
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
            GestureDetector(
              onTap: () => Navigator.restorablePush<void>(
                  context, _detailsDialogRoute,
                  arguments: planWrapper.toJson()),
              child: Container(
                  height: 200,
                  child: planWrapper.plan.image != null
                      ? Image.memory(const Base64Decoder()
                          .convert(planWrapper.plan.image ?? ""))
                      : Image.asset("assets/xmarksthespot.png")),
            )
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planWrapper.plan.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 24)),
                      Text(
                        "Team: ${planWrapper.plan.team.name}",
                        style: const TextStyle(fontSize: 16),
                      )
                    ]))),
        Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 5, bottom: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            IconButton(
                onPressed: () => Navigator.restorablePush<void>(
                    context, _detailsDialogRoute,
                    arguments: planWrapper.toJson()),
                icon: const Icon(Icons.info_outline)),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.red))
          ]),
        )
      ]),
    );
  }
}
