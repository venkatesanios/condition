import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
  }) : super(
    key: key,
    content: Text(message, style: const TextStyle(fontSize: 16),),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(milliseconds: 2000),
    action: SnackBarAction(
      label: 'Close',
      onPressed: () {},
    ),
  );
}