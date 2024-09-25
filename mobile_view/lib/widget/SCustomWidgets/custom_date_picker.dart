import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class DatePickerField extends StatefulWidget {
//   final DateTime value;
//   final Widget? child;
//   final void Function(DateTime) onChanged;
//   final DateTime? firstDate;
//   final bool showInitialDate;
//
//   const DatePickerField({
//     Key? key,
//     required this.value,
//     required this.onChanged,
//     this.firstDate,
//     this.showInitialDate = false,
//     this.child,
//   }) : super(key: key);
//
//   @override
//   _DatePickerFieldState createState() => _DatePickerFieldState();
// }
//
// class _DatePickerFieldState extends State<DatePickerField> {
//   TextEditingController dateController = TextEditingController();
//   final dateFormat = DateFormat('dd-MM-yyyy');
//
//   @override
//   void initState() {
//     super.initState();
//     dateController.text = dateFormat.format(widget.value);
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime initialDate = widget.value;
//     DateTime firstDate = widget.firstDate ?? DateTime.now();
//
//     // Ensure initialDate is on or after firstDate
//     if (initialDate.isBefore(firstDate)) {
//       initialDate = firstDate;
//     }
//
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: DateTime(2101),
//     );
//
//     if (picked != null) {
//       setState(() {
//         dateController.text = dateFormat.format(picked);
//         widget.onChanged(picked);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     dateController.text = dateFormat.format(widget.value);
//     return InkWell(
//       onTap: () => _selectDate(context),
//       child: widget.child ?? Text(
//         dateController.text,
//         style: Theme.of(context).textTheme.bodyMedium,
//       ),
//     );
//   }
// }

class DatePickerField extends StatefulWidget {
  final DateTime value;
  final Widget? child;
  final void Function(DateTime) onChanged;
  final DateTime? firstDate;
  final bool showInitialDate;
  const DatePickerField({super.key, required this.value, required this.onChanged, this.firstDate, this.showInitialDate = false, this.child});

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  TextEditingController dateController = TextEditingController();
  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    dateController.text = dateFormat.format(widget.value);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked;
    if(widget.showInitialDate) {
      picked = await showDatePicker(
        context: context,
        initialDate: widget.value,
        firstDate: DateTime(2000),
        currentDate: widget.firstDate ?? DateTime.now(),
        lastDate: DateTime(2101),
      );
    } else {
      picked = await showDatePicker(
          context: context,
          currentDate: DateTime.now(),
          // initialDate: widget.value,
          firstDate: widget.firstDate ?? DateTime.now(),
          lastDate: DateTime(2101));
    }
    if (picked != null) {
      setState(() {
        dateController.text = dateFormat.format(picked!);
        widget.onChanged(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dateController.text = dateFormat.format(widget.value);
    return InkWell(
      onTap: () => _selectDate(context),
      child: widget.child ?? Text(dateController.text, style: Theme.of(context).textTheme.bodyMedium,),
    );
  }
}
