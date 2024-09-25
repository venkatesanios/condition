import 'package:flutter/material.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  CustomCalendar({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime firstDateOfMonth;
  late DateTime lastDateOfMonth;
  late List<DateTime> monthDays;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _generateCalendar(selectedDate);
  }

  void _generateCalendar(DateTime date) {
    firstDateOfMonth = DateTime(date.year, date.month, 1);
    lastDateOfMonth = DateTime(date.year, date.month + 1, 0);
    monthDays = List.generate(
      lastDateOfMonth.day,
          (index) => DateTime(date.year, date.month, index + 1),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + delta, 1);
      _generateCalendar(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        _buildWeekPager(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          "${getMonthName(selectedDate.month)} ${selectedDate.year}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: daysOfWeek
          .map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: day == "Sun" || day == "Sat" ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildWeekPager() {
    return Container(
      height: 50,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1),
        itemCount: (monthDays.length / 7).ceil(),
        itemBuilder: (context, index) {
          return _buildWeekGrid(index);
        },
      ),
    );
  }

  Widget _buildWeekGrid(int weekIndex) {
    int firstWeekdayOfMonth = firstDateOfMonth.weekday % 7;
    int startIndex = weekIndex * 7 - firstWeekdayOfMonth;
    startIndex = startIndex < 0 ? 0 : startIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        int dayIndex = startIndex + index;
        if (dayIndex < 0 || dayIndex >= monthDays.length) {
          return Expanded(child: Container());
        }
        DateTime day = monthDays[dayIndex];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = day;
              });
              widget.onDateSelected(day);
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: selectedDate == day ? Colors.blue : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: selectedDate == day ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}