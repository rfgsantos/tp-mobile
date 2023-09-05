import 'package:flutter/material.dart';

typedef CustomSnackBar = SnackBar Function(BuildContext context,
    {String? message});

CustomSnackBar successSnackBar =
    (BuildContext context, {String? message}) => SnackBar(
          content: Text(message ?? 'Operation successful'),
          backgroundColor: Colors.green,
        );

CustomSnackBar errorSnackBar = (BuildContext context, {String? message}) =>
    SnackBar(
        content: Text(message ?? 'An unexpected error occurred'),
        backgroundColor: Colors.red);
