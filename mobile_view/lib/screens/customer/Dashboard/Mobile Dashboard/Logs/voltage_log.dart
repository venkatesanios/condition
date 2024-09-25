import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_view/widget/SCustomWidgets/custom_segmented_control.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/http_service.dart';
import '../../../Planning/NewIrrigationProgram/irrigation_program_main.dart'; // For charts

class PumpVoltageLogScreen extends StatefulWidget {
  final int userId, controllerId, nodeControllerId;
  const PumpVoltageLogScreen({super.key, required this.userId, required this.controllerId, required this.nodeControllerId});

  @override
  State<PumpVoltageLogScreen> createState() => _PumpVoltageLogScreenState();
}

class _PumpVoltageLogScreenState extends State<PumpVoltageLogScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String message = "";
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int selectedIndex = 0;
  List<Map<String, dynamic>> voltageData = [];

  Future<void> getUserPumpLog() async {
    Map<String, dynamic> data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getPumpController = await HttpService().postRequest('getUserPumpVoltageLog', data);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        setState(() {
          if (response['data'] is List) {
            voltageData = List<Map<String, dynamic>>.from(response['data'][0]['voltageDetails']);
            message = ""; // Clear message on success
          } else {
            message = 'No data available for the selected date.';
          }
        });
      } else {
        setState(() {
          message = 'Failed to load data: ${response['message']}';
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        message = 'Error occurred: $e';
      });
      print("$e");
      print("stackTrace ==> $stackTrace");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted) {
      getUserPumpLog();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (voltageData.isNotEmpty || message.isNotEmpty) ? Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: customBoxShadow,
                color: Colors.white,
              ),
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.now(),
                calendarFormat: _calendarFormat,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    gradient: linearGradientLeading,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  getUserPumpLog();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            if (voltageData.isNotEmpty)
              CustomSegmentedControl(
                  segmentTitles: const {
                    0: "Voltage",
                    1: "Current",
                  },
                  groupValue: selectedIndex,
                  onChanged: (newValue) {
                    setState(() {
                      selectedIndex = newValue!;
                    });
                  }
              ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: getUserPumpLog,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (message.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              message,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: customBoxShadow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              labelRotation: 45,
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            primaryYAxis: NumericAxis(
                              labelFormat: selectedIndex == 0 ? '{value}V' : '{value}A',
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            title: ChartTitle(text: selectedIndex == 0 ? 'Voltage Graph' : 'Current Graph'),
                            legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              header: selectedIndex == 0 ? 'Voltage Info' : 'Current Info',
                              format: selectedIndex == 0 ? 'point.x: point.yV' : 'point.x: point.yA',
                            ),
                            series: <SplineSeries<Map<String, dynamic>, String>>[
                              SplineSeries<Map<String, dynamic>, String>(
                                dataSource: voltageData,
                                xValueMapper: (data, _) => 'Hour ${data['hour']}',
                                yValueMapper: (data, _) => int.tryParse(selectedIndex == 0 ? data['voltageR'] : data['currentR']) ?? 0,
                                name: selectedIndex == 0 ? 'Voltage R' : 'Current R',
                                markerSettings: MarkerSettings(isVisible: true),
                                color: Colors.red,
                              ),
                              SplineSeries<Map<String, dynamic>, String>(
                                dataSource: voltageData,
                                xValueMapper: (data, _) => 'Hour ${data['hour']}',
                                yValueMapper: (data, _) => int.tryParse(selectedIndex == 0 ? data['voltageY'] : data['currentY']) ?? 0,
                                name: selectedIndex == 0 ? 'Voltage Y' : 'Current Y',
                                markerSettings: MarkerSettings(isVisible: true),
                                color: Colors.yellow,
                              ),
                              SplineSeries<Map<String, dynamic>, String>(
                                dataSource: voltageData,
                                xValueMapper: (data, _) => 'Hour ${data['hour']}',
                                yValueMapper: (data, _) => int.tryParse(selectedIndex == 0 ? data['voltageB'] : data['currentB']) ?? 0,
                                name: selectedIndex == 0 ? 'Voltage B' : 'Current B',
                                markerSettings: MarkerSettings(isVisible: true),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      if (message.isEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return _buildVoltageLogCard(voltageData[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ) : Center(child: CircularProgressIndicator(),),
      ),
    );
  }

  Widget _buildVoltageLogCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hours', style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),
                    Container(
                      color: Colors.redAccent.shade100,
                      padding: EdgeInsets.all(8.0),
                      child: Text('R', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.amberAccent.shade100,
                      child: Text('Y', style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.lightBlueAccent.shade100,
                      child: Text('B', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ..._buildDataRows()
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    List<TableRow> rows = [];

    for (var entry in voltageData) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('${entry['hour']}'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageR'] : entry['currentR'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageY'] : entry['currentY'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageB'] : entry['currentB'],
                style: TextStyle(fontWeight: FontWeight.bold,),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}
