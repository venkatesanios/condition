import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget {
  final dynamic content;
  final String? label;
  final int tabIndex;
  final int selectedTabIndex;
  final double? radius;
  final double? height;

  const CustomTab({super.key,
    required this.content,
    this.label,
    required this.tabIndex,
    required this.selectedTabIndex,
    this.radius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color avatarColor = tabIndex == selectedTabIndex
        ? Theme.of(context).primaryColor
        : Color(0xffE7F0F2);

    Color contentColor = tabIndex == selectedTabIndex
        ? Colors.white
        : Colors.black;
    return Tab(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 5),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: avatarColor,
              child: content is IconData
                  ? Icon(content, color: contentColor)
                  : Text(
                content,
                style: TextStyle(
                    color: contentColor,
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
                ),
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(label!),
          ],
        ],
      ),
    );
  }
}
