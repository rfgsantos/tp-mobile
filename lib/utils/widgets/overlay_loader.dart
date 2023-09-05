import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayLoader extends StatelessWidget {
  final String message;
  double value = 0.0;

  OverlayLoader({super.key, required this.message, this.value = 0.0});

  @override
  Widget build(BuildContext context) => Stack(children: [
        const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black)),
        Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          value != 0
              ? CircularProgressIndicator(
                  value: value,
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(message, style: const TextStyle(color: Colors.white))
        ]))
      ]);
}
