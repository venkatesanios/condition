import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget? child;
  final List<Widget> actions;

  // Provide a default value of null for the child parameter
  const CustomAlertDialog({Key? key, required this.title, required this.content, required this.actions, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red,),
          const SizedBox(width: 10),
          child ?? Text(title),
        ],
      ),
      content: Text(content),
      actions: actions,
    );
  }
}
