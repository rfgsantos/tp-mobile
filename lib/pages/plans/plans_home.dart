import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tpmobile/pages/plans/plan_card.dart';
import 'package:tpmobile/services/authentication_repository.dart';
import 'package:tpmobile/services/internet_connection.dart';

import '../../models/plan.dart';
import '../../models/stage.dart';
import '../../services/plan_repository.dart';
import '../../services/setup_di.dart';
import '../../utils/widgets/internet_authentication.dart';
import '../../utils/widgets/navigation_drawer/navigation_drawer.dart';

class PlansHomePage extends StatefulWidget {
  static String route = "plans";

  const PlansHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _PlansHomePageState();
}

class _PlansHomePageState extends State<PlansHomePage> {
  final PlansRepository _plansRepository = getIt<PlansRepository>();

  final List<PlanWrapper> _plans = [];

  @override
  void initState() {
    getPlans();
    super.initState();
  }

  Future<void> getPlans() async {
    final List<PlanWrapper> localPlans = [];
    _plansRepository
        .getPlansFullSummary()
        .then((plans) => localPlans.addAll(plans))
        .whenComplete(() => setState(() {
              _plans.clear();
              _plans.addAll(localPlans);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plans")),
      drawer: const NavigationDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: InternetAuthenticationChecker(
            authenticatedWidget: _plans.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () => getPlans(),
                    child: ListView.builder(
                      itemCount: _plans.length,
                      itemBuilder: (builder, index) =>
                          PlanCard(planWrapper: _plans[index]),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            internetFailing: FutureBuilder(
              future: getListOfRegions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData &&
                    (snapshot.data?.length ?? 0) > 0) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) => PlanCard(
                        planWrapper: PlanWrapper(
                            plan: Plan.fromJson(
                                snapshot.data?[index].metadata['plan']),
                            summaries: (snapshot
                                    .data?[index].metadata['summary'] as List)
                                .map((e) => StageSummaryFullWrapper.fromJson(e))
                                .toList())),
                  );
                } else {
                  return Container();
                }
              },
            ),
          )),
    );
  }
}
