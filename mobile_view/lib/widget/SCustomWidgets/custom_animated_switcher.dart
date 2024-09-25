import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final bool condition;

  const CustomAnimatedSwitcher({super.key,
    required this.child,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: condition ? child : Container(),
    );
  }
}
