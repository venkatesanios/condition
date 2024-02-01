import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const MySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MySwitch> createState() => _CustomSwitchState();
}
class _CustomSwitchState extends State<MySwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Switch(value: widget.value, onChanged: widget.onChanged),
    );
  }
}
