import 'package:flutter/material.dart';
import 'package:tpmobile/pages/boats/boats_home.dart';
import 'package:tpmobile/pages/plans/plans_home.dart';
import 'package:tpmobile/pages/teams/teams_home.dart';
import 'package:tpmobile/services/authentication_repository.dart';
import 'package:tpmobile/services/setup_di.dart';

import 'pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();

  @override
  void initState() {
    super.initState();
    _authenticationRepository.checkAndValidateToken();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Travelling planner',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const HomePage(),
        routes: {
          HomePage.route: (context) => const HomePage(),
          BoatsHomePage.route: (context) => const BoatsHomePage(),
          PlansHomePage.route: (context) => const PlansHomePage(),
          TeamsHomePage.route: (context) => const TeamsHomePage()
        },
      );
}
