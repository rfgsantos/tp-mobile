import 'package:flutter/material.dart';

class SideNavRoute {
  final String route;
  final String text;
  final IconData icon;
  final Widget page;

  const SideNavRoute(
      {required this.route,
      required this.text,
      required this.icon,
      required this.page});
}
