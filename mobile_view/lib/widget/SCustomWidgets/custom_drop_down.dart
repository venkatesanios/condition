import 'package:flutter/material.dart';

class CustomDropdownWidget extends StatelessWidget {
  final List<String> dropdownItems;
  final String selectedValue;
  final Function(String?) onChanged;
  final bool includeNoneOption;

  const CustomDropdownWidget({
    Key? key,
    required this.dropdownItems,
    required this.selectedValue,
    required this.onChanged,
    this.includeNoneOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> items = [];

    if (includeNoneOption) {
      items.add(
        const DropdownMenuItem<String>(
          value: 'None',
          child: Text('None'),
        ),
      );
    }

    items.addAll(dropdownItems.where((name) => name != null).map((pumpName) {
        return DropdownMenuItem<String>(
          value: pumpName,
          child: Text(pumpName),
        );
      }).toList(),
    );

    return DropdownButton<String>(
      isExpanded: true,
      underline: Container(),
      value: selectedValue,
      items: items,
      onChanged: onChanged,
    );
  }
}
