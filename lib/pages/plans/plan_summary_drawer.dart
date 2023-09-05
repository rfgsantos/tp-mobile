import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/plan.dart';
import '../../models/stage.dart';
import '../../services/plan_repository.dart';
import '../../services/setup_di.dart';

class PlanSummaryDrawer extends StatelessWidget {
  final PlanWrapper plan;
  final BehaviorSubject<Map<String, Map<String, dynamic>>> closestPoint;
  final PlansRepository _plansRepository = getIt<PlansRepository>();
  final stopwatch = Stopwatch();

  PlanSummaryDrawer(
      {super.key, required this.plan, required this.closestPoint});

  bool isClosest(Map<String, Map<String, dynamic>> closestPoint, int index,
          StageSummaryFullWrapper ssfw) =>
      index == closestPoint['closest_point']?['index'] &&
      closestPoint['stage_summary']?['summary']['id'] ==
          ssfw.summary.summary?.id;

  void finishPlan(int stageId) async {
    _plansRepository.endStage(stageId).then((value) => print(value));
  }

  Iterable<Widget> widgetPoints(snapshot) => plan.summaries
      .map((StageSummaryFullWrapper ssfw) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Stage ${ssfw.summary.summary?.order}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
                ...ssfw.points.asMap().entries.map(
                    (MapEntry<int, StagePointsSummary> e) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: RichText(
                            text: TextSpan(
                                children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.sailing,
                                      color: isClosest(
                                              snapshot.data ?? {}, e.key, ssfw)
                                          ? Colors.blue
                                          : Colors.transparent)),
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.arrow_right,
                                      color: isClosest(
                                              snapshot.data ?? {}, e.key, ssfw)
                                          ? Colors.blue
                                          : Colors.black)),
                              TextSpan(text: e.value.latlontext)
                            ],
                                style: TextStyle(
                                    color: isClosest(
                                            snapshot.data ?? {}, e.key, ssfw)
                                        ? Colors.blue
                                        : Colors.black))))),
                Center(
                    child: ElevatedButton.icon(
                  onPressed: () => finishPlan(ssfw.summary.summary?.id ?? 0),
                  label: Text("End stage ${ssfw.summary.summary?.order}"),
                  icon: const Icon(Icons.sports_score),
                ))
              ]))
      .toList();

  @override
  Widget build(BuildContext context) => Drawer(
      backgroundColor: Colors.white,
      child: Stack(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                stream: closestPoint.stream,
                builder: (context, snapshot) => !snapshot.hasData
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                            top: 24 + MediaQuery.of(context).padding.top,
                            bottom: 24),
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              const Text("Points summary",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              ...widgetPoints(snapshot)
                            ]))))),
      ]));
}
