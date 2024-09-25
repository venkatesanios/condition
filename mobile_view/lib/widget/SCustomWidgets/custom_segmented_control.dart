import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSegmentedControl extends StatelessWidget {
  final Map<int, String> segmentTitles;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final EdgeInsets padding;

  const CustomSegmentedControl({super.key,
    required this.segmentTitles,
    required this.groupValue,
    required this.onChanged,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: segmentTitles.map((key, title) {
        return MapEntry(
          key,
          Padding(
            padding: padding,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: groupValue == key ? Colors.black : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
      }),
      groupValue: groupValue,
      onValueChanged: onChanged,
      thumbColor: Colors.white,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }
}
