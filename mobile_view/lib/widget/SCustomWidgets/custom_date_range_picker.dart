import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerField extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final void Function(DateTime, DateTime) onChanged;
  final DateTime? firstDate;

  const DateRangePickerField({
    Key? key,
    required this.startDate,
    this.firstDate,
    required this.endDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DateRangePickerField> createState() => _DateRangePickerFieldState();
}

class _DateRangePickerFieldState extends State<DateRangePickerField> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    fromDate.text = dateFormat.format(widget.startDate);
    toDate.text = dateFormat.format(widget.endDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      // useRootNavigator: false,
      initialDateRange: DateTimeRange(
        start: dateFormat.parse(fromDate.text),
        end: dateFormat.parse(toDate.text),
      ),
      currentDate: widget.firstDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        fromDate.text = dateFormat.format(picked.start);
        toDate.text = dateFormat.format(picked.end);
        widget.onChanged(picked.start, picked.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => _selectDate(context),
      color: Colors.white.withOpacity(0.8),
      splashColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              "Date Range",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 20,
            ),
            Text("${fromDate.text} - ${toDate.text}"),
          ],
        ),
      ),
    );
  }
}
