import 'package:flutter/material.dart';

typedef ConfirmationDialog = Future<bool?> Function(BuildContext context,
    {String? message});

ConfirmationDialog dialog = (BuildContext context,
        {String? message = "Proceed with operation?",
        String? title = "Confirmation"}) =>
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(title ?? ''),
              content: Text(message ?? ''),
              actions: [
                TextButton(
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            ));
