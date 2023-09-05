import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/widgets/navigation_drawer/navigation_drawer.dart';

class BoatsHomePage extends StatefulWidget {
  static String route = "boats";

  const BoatsHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _BoatsHomeState();
}

class _BoatsHomeState extends State<BoatsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Boats")),
      drawer: const NavigationDrawer(),
    );
  }
}
