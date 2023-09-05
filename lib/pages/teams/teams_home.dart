import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpmobile/pages/teams/team_dialog.dart';
import 'package:tpmobile/pages/teams/team_card.dart';
import 'package:tpmobile/services/authentication_repository.dart';
import 'package:tpmobile/services/internet_connection.dart';
import 'package:tpmobile/services/teams_repository.dart';
import 'package:tpmobile/utils/widgets/internet_authentication.dart';

import '../../models/team.dart';
import '../../services/setup_di.dart';
import '../../utils/widgets/missing_widgets.dart';
import '../../utils/widgets/navigation_drawer/navigation_drawer.dart';

class TeamsHomePage extends StatefulWidget {
  static String route = "teams";

  const TeamsHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _TeamsHomeState();
}

class _TeamsHomeState extends State<TeamsHomePage> {
  final TeamsRepository _teamsRepository = getIt<TeamsRepository>();
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();
  final InternetConnectionService _internetConnectionService =
      getIt<InternetConnectionService>();

  List<Team> _teams = [];

  static Route<void> _newTeamDialogRoute(context, arguments) {
    return MaterialPageRoute(
        builder: (context) => TeamDialog(), fullscreenDialog: true);
  }

  @override
  void initState() {
    _internetConnectionService.connectionStream.listen((connected) {
      if (connected &&
          _authenticationRepository.status ==
              AuthenticationStatus.authenticated) {
        _teamsRepository.initRoles();
      }
    });
    getTeams();
    super.initState();
  }

  Future<void> getTeams() async {
    _teamsRepository.getMyTeams().then((value) {
      setState(() {
        _teams = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Teams")),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.restorablePush<void>(context, _newTeamDialogRoute),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        drawer: const NavigationDrawer(),
        body: InternetAuthenticationChecker(
          authenticatedWidget: Padding(
            padding: const EdgeInsets.all(15),
            child: RefreshIndicator(
                onRefresh: () => getTeams(),
                child: ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (builder, index) =>
                      TeamCard(team: _teams[index]),
                )),
          ),
        ));
  }
}
