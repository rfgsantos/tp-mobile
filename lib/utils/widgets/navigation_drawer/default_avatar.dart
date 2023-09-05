import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({super.key});

  @override
  Widget build(BuildContext context) => const CircleAvatar(
        radius: 52,
        backgroundImage: NetworkImage(
            "https://www.caribbeangamezone.com/wp-content/uploads/2018/03/avatar-placeholder.png"),
      );
}
