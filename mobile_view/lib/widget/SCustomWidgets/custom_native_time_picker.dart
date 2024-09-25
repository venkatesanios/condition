import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state_management/overall_use.dart';
import '../HoursMinutesSeconds.dart';

class CustomNativeTimePicker extends StatelessWidget {
  final String initialValue;
  final bool is24HourMode;
  final Function(String) onChanged;
  final TextStyle? style;
  final bool isNewTimePicker;

  const CustomNativeTimePicker({super.key,
    required this.initialValue,
    required this.is24HourMode,
    required this.onChanged,
    this.style,
    this.isNewTimePicker = false
  });

  @override
  Widget build(BuildContext context) {
    final overAllPvd = Provider.of<OverAllUse>(context);
    return InkWell(
      child: Text(
        initialValue,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () async {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: HoursMinutesSeconds(
                  initialTime: initialValue,
                  onPressed: () {
                    onChanged('${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}');
                    Navigator.pop(context);
                  },
                ),
              );
            });
    // else {
        //   TimeOfDay? selectedTime;
        //
        //   if (initialValue != '') {
        //     try {
        //       if(!is24HourMode) {
        //         List<String> timeParts = initialValue.split(' ');
        //
        //         if (timeParts.length == 2) {
        //           String time = timeParts[0];
        //           String period = timeParts[1];
        //
        //           List<String> timeDigits = time.split(':');
        //           if (timeDigits.length == 2) {
        //             int hour = int.parse(timeDigits[0]);
        //             int minute = int.parse(timeDigits[1]);
        //
        //             if (period == 'PM' && hour < 12) {
        //               hour += 12;
        //             } else if (period == 'AM' && hour == 12) {
        //               hour = 0;
        //             }
        //
        //             selectedTime = TimeOfDay(hour: hour, minute: minute);
        //           } else {
        //             print("Invalid time format");
        //           }
        //         } else {
        //           print("Invalid time format");
        //         }
        //       } else {
        //         List<String> timeParts = initialValue.split(':');
        //
        //         if (timeParts.length == 2) {
        //           int hour = int.parse(timeParts[0]);
        //           int minute = int.parse(timeParts[1]);
        //
        //           selectedTime = TimeOfDay(hour: hour, minute: minute);
        //         } else {
        //           print("Invalid time format");
        //         }
        //       }
        //     } catch (e) {
        //       print("Error parsing time: $e");
        //     }
        //   } else {
        //     selectedTime = TimeOfDay.fromDateTime(DateTime.now());
        //   }
        //   selectedTime = await showTimePicker(
        //     context: context,
        //     initialTime: selectedTime ?? TimeOfDay.now(),
        //     builder: (BuildContext context, Widget? child) {
        //       return MediaQuery(
        //         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: is24HourMode),
        //         child: child!,
        //       );
        //     },
        //   );
        //
        //   if (selectedTime != null) {
        //     List<String> splitString1 = selectedTime.format(context).split(" ");
        //     List<String> splitString2 = splitString1[0].split(":");
        //     String hour = int.parse(splitString2[0]) < 10 ? splitString2[0].padLeft(2, "0") : splitString2[0];
        //     String minute = int.parse(splitString2[1]) < 10 ? splitString2[1].padLeft(2, "0") : splitString2[1];
        //     String formattedTime = is24HourMode
        //         ? "${selectedTime.hour.toString().padLeft(2,"0")}:${selectedTime.minute.toString().padLeft(2, "0")}"
        //         : "$hour:$minute ${splitString1[1]}";
        //
        //     onChanged(formattedTime);
        //   }
        // }
      },
    );
  }
}
