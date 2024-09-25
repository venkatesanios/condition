import 'package:flutter/material.dart';

class GlobalSnackBar {
  final String message;
  final int code;

  const GlobalSnackBar({
    required this.message, required this.code
  });

  static show(BuildContext context, String message, int code)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: code == 200? null : Colors.redAccent,
      ),
    );
  }
}