import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthenticationMissing extends StatelessWidget {
  const AuthenticationMissing({super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(50.0),
      child: Center(
          child: Column(children: [
        Image.asset("assets/boat.png"),
        const SizedBox(height: 16),
        const Text(
          "It seems you are not logged in. Register to our platform now to access all features!",
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ])));
}

class InternetMissing extends StatelessWidget {
  const InternetMissing({super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(50.0),
      child: Center(
          child: Column(children: const [
        Icon(Icons.wifi_off, size: 300),
        Text("It seems you are offline. Turn on your internet connection.",
            style: TextStyle(fontWeight: FontWeight.bold))
      ])));
}
