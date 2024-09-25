import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_view/screens/Customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';
import 'package:mobile_view/widget/SCustomWidgets/custom_segmented_control.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../constants/http_service.dart';
import '../../../../../state_management/overall_use.dart';
import '../../../../../widget/SCustomWidgets/custom_timeline_widget.dart';
import '../../../Planning/NewIrrigationProgram/preview_screen.dart';

class NewPumpLogScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int nodeControllerId;
  const NewPumpLogScreen({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0});

  @override
  State<NewPumpLogScreen> createState() => _NewPumpLogScreenState();
}

class _NewPumpLogScreenState extends State<NewPumpLogScreen> {
  late OverAllUse overAllPvd;
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String message = "";
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<PumpLogData> pumpLogData = [];
  Map<int, String> segments = {};
  int selectedIndex = 0;
  bool showGraph = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> getUserPumpLog() async {
    Map<String, dynamic> data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getPumpController = await HttpService().postRequest(widget.nodeControllerId == 0 ? "getUserPumpLog" : "getUserNodePumpLog", data);
      final response = jsonDecode(getPumpController.body);
      pumpLogData.clear();
      segments.clear();
      selectedIndex = 0;
      message = "";
      showGraph = false;
      // print(getPumpController.body);
      // print(data);
      if (getPumpController.statusCode == 200) {
        await Future.delayed(Duration.zero, () {
          setState(() {
            if (response['data'] is List) {
              pumpLogData = (response['data'] as List).map((i) => PumpLogData.fromJson(i)).toList();
              for(var i = 0; i < pumpLogData.length; i++) {
                if(pumpLogData[i].motor1.isNotEmpty) {
                  segments.addAll({0: "Motor 1"});
                }
                if(pumpLogData[i].motor2.isNotEmpty) {
                  segments.addAll({1: "Motor 2"});
                }
                if(pumpLogData[i].motor3.isNotEmpty) {
                  segments.addAll({2: "Motor 3"});
                }
                if(pumpLogData[i].motor2.isNotEmpty) {
                  selectedIndex = 1;
                } else if(pumpLogData[i].motor3.isNotEmpty) {
                  selectedIndex = 2;
                } else {
                  selectedIndex = 0;
                }
              }
            } else {
              message = '${response['message']}';
              print('Data is not a List');
            }
          });
        });
        setState(() {
          if (pumpLogData.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            });
          }
        });

      } else {
        print('Failed to load data');
      }
    } catch (e, stackTrace) {
      print("$e");
      print("stackTrace ==> $stackTrace");
    }
  }

  @override
  void initState() {
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    if(mounted) {
      getUserPumpLog();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getUserPumpLog,
        child: SafeArea(
          child: Column(
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
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    getUserPumpLog();
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(segments.isNotEmpty && segments.length != 1)
                      CustomSegmentedControl(
                          segmentTitles: segments,
                          groupValue: selectedIndex,
                          onChanged: (newValue) {
                            setState(() {
                              selectedIndex = newValue!;
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut
                              );
                            });
                          }
                      )
                    else
                      Container(),
                    // Container(
                    //   width: 100,
                    //   height: 40,
                    //   decoration: BoxDecoration(
                    //       color: const Color(0xff1D808E),
                    //       borderRadius: BorderRadius.circular(8)
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       Checkbox(
                    //           checkColor: Colors.teal,
                    //           fillColor: WidgetStateProperty.all(const Color(0xFFF4FFFB)),
                    //           value: showGraph,
                    //           onChanged: (value){
                    //             setState(() {
                    //               showGraph = !showGraph;
                    //             });
                    //           }
                    //       ),
                    //       Icon(Icons.bar_chart, color: Colors.white,)
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
              // SizedBox(height: 10,),
              // if(showGraph)
              //   // Expanded(child: TimeGraph(data: getTimeData(),))
              //   MotorLogChart(motor1Logs: pumpLogData[0].motor1, motor2Logs: pumpLogData[0].motor2, motor3Logs: pumpLogData[0].motor3,)
              // else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: pumpLogData.isNotEmpty ? pumpLogData.length : 1,
                  itemBuilder: (context, index) {
                    if(pumpLogData.isNotEmpty) {
                      final logData = pumpLogData[index];
                      return Timeline2(
                        events: selectedIndex == 1 ? logData.motor2 : selectedIndex == 2 ? logData.motor3 : logData.motor1,
                      );
                    } else {
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(message),
                          ElevatedButton(onPressed: (){
                            getUserPumpLog();
                          }, child: Text("Reload"))
                        ],
                      ));
                    };
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Timeline2 extends StatelessWidget {
  final List<EventLog> events;

  Timeline2({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...events.map((event) => TimelineEventCard(event: event)).toList()
      ],
    );
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

class TimelineEventCard extends StatelessWidget {
  final EventLog event;

  TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    //   padding: EdgeInsets.all(16),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(12),
    //     boxShadow: customBoxShadow,
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "${event.onTime}",
    //         style: TextStyle(
    //           color: Colors.black,
    //           fontSize: 12,
    //         ),
    //       ),
    //       SizedBox(height: 8),
    //       Row(
    //         children: [
    //           Icon(Icons.event_note, color: Colors.blue),
    //           SizedBox(width: 8),
    //           Text(
    //             event.onReason,
    //             style: TextStyle(
    //               fontSize: 16,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ],
    //       ),
    //       SizedBox(height: 8),
    //       Row(
    //         children: [
    //           Icon(Icons.event_busy, color: Colors.red),
    //           SizedBox(width: 8),
    //           Text(
    //             event.offReason,
    //             style: TextStyle(
    //               fontSize: 14,
    //               color: Colors.black,
    //               fontWeight: FontWeight.w300,
    //             ),
    //           ),
    //         ],
    //       ),
    //       SizedBox(height: 8),
    //       Row(
    //         children: [
    //           Icon(Icons.access_time, color: Colors.orange),
    //           SizedBox(width: 8),
    //           Text(
    //             "Duration: ${event.duration}",
    //             style: TextStyle(
    //               fontSize: 14,
    //               color: Colors.black,
    //               fontWeight: FontWeight.w300,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
    return TimeLine(
      itemGap: 0,
      padding: const EdgeInsets.symmetric(vertical: 0),
      indicatorSize: 80,
      gutterSpacing: 0,
      indicators: [
        buildTimeLineIndicators(context: context, event: event)
      ],
      children: [
        Container(
          margin: EdgeInsets.only(right: 10, top: 8, bottom: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
            border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), right: BorderSide(color: Theme.of(context).primaryColor, width: 0.5)),
            boxShadow: customBoxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(MdiIcons.powerOff, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        capitalizeFirstLetter(event.onReason),
                        style: TextStyle(
                          // fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Icon(MdiIcons.powerOff, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        capitalizeFirstLetter(event.offReason),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Duration: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 14)),
                        TextSpan(text: '${event.duration}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildTimeLineIndicators({context, required EventLog event}) {
    // DateTime onTime = DateFormat('HH:mm:ss').parse(event.onTime);
    // DateTime offTime = DateFormat('HH:mm:ss').parse(event.offTime);
    // String formattedOnTime = DateFormat('hh:mm a').format(onTime);
    // String formattedOffTime = DateFormat('hh:mm a').format(offTime);
    return Container(
        margin: EdgeInsets.only(left: 10, top: 8, bottom: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: linearGradientLeading,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), left: BorderSide(color: Theme.of(context).primaryColor, width: 0.5)),
          boxShadow: customBoxShadow,
        ),
        // width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${event.onTime}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white),),
            Text("to", style: TextStyle(fontSize: 12,  color: Colors.white),),
            Text("${event.offTime}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,  color: Colors.white),),
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 5),
            //     width: 5,
            //     decoration: BoxDecoration(
            //         // gradient: linearGradientLeading,
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(5)
            //     ),
            //     // color: status.color,
            //   ),
            // )
            // Text("${event.duration}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
          ],
        )
    );
  }
}

class PumpLogData {
  final String date;
  // final MotorLogs log;
  final List<EventLog> motor1;
  final List<EventLog> motor2;
  final List<EventLog> motor3;

  PumpLogData({required this.date, required this.motor1, required this.motor2, required this.motor3});

  factory PumpLogData.fromJson(Map<String, dynamic> json) {
    return PumpLogData(
      date: json['logDate'],
      // log: MotorLogs.fromJson(json['log']),
      motor1: (json['motor1'] as List<dynamic>)
          .map((e) => EventLog.fromJson(e as String))
          .toList(),
      motor2: (json['motor2'] as List<dynamic>)
          .map((e) => EventLog.fromJson(e as String))
          .toList(),
      motor3: (json['motor3'] as List<dynamic>)
          .map((e) => EventLog.fromJson(e as String))
          .toList(),
    );
  }
}

class MotorLogs {
  final List<EventLog> motor1;
  final List<EventLog> motor2;
  final List<EventLog> motor3;

  MotorLogs({required this.motor1, required this.motor2, required this.motor3});

  factory MotorLogs.fromJson(Map<String, dynamic> json) {
    List<EventLog> motor1Data = (json['motor1'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    List<EventLog> motor2Data = (json['motor2'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    List<EventLog> motor3Data = (json['motor3'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    return MotorLogs(
      motor1: motor1Data,
      motor2: motor2Data,
      motor3: motor3Data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motor1': motor1,
      'motor2': motor2,
      'motor3': motor3,
    };
  }
}

class EventLog {
  final String onReason;
  final String offReason;
  final String onTime;
  final String offTime;
  final String duration;
  final Color background;
  final bool isAllDay;

  EventLog({
    required this.onReason,
    required this.offReason,
    required this.onTime,
    required this.offTime,
    required this.duration,
    required this.background,
    required this.isAllDay
  });

  factory EventLog.fromJson(String data) {
    // print("data in the event model ==> $data");
    return EventLog(
      onReason: data.split(",")[0],
      onTime: data.split(",")[1],
      offReason: data.split(",")[2],
      offTime: data.split(",")[3],
      duration: data.split(",")[4],
      background: data.split(",")[0].contains("ON") ? Colors.green : Colors.red,
      isAllDay: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "onReason": onReason,
      "offReason": offReason,
      "onTime": onTime,
      "offTime": offTime,
      "duration": duration,
      "background": background,
      "isAllDay": isAllDay,
    };
  }
}

class ChartData {
  final DateTime time;
  final String event;
  final double value;

  ChartData(this.time, this.event, this.value);
}

List<ChartData> getChartData(List<EventLog> logs) {
  List<ChartData> chartData = [];
  for (var log in logs) {
    DateTime onTime = DateTime.parse(log.onTime);
    DateTime offTime = DateTime.parse(log.offTime);
    // Duration duration = DateTime.parse(log.onTime);

    chartData.add(ChartData(onTime, 'On', 1));
    chartData.add(ChartData(offTime, 'Off', 1));
    // chartData.add(ChartData(onTime.add(duration), 'Duration', 1));
  }
  return chartData;
}

class MotorLogChart extends StatelessWidget {
  final List<EventLog> motor1Logs;
  final List<EventLog> motor2Logs;
  final List<EventLog> motor3Logs;

  MotorLogChart({required this.motor1Logs, required this.motor2Logs, required this.motor3Logs});

  @override
  Widget build(BuildContext context) {
    List<ChartData> motor1Data = getChartData(motor1Logs);
    List<ChartData> motor2Data = getChartData(motor2Logs);
    List<ChartData> motor3Data = getChartData(motor3Logs);

    return Scaffold(
      appBar: AppBar(title: Text('Motor Logs')),
      body: SfCartesianChart(
        title: ChartTitle(text: 'Motor Logs'),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        primaryXAxis: DateTimeAxis(title: AxisTitle(text: 'Time')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Event Count')),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: [
          BarSeries<ChartData, DateTime>(
            name: 'Motor 1',
            dataSource: motor1Data,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            dataLabelMapper: (ChartData data, _) => data.event,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            color: Colors.blue,
          ),
          BarSeries<ChartData, DateTime>(
            name: 'Motor 2',
            dataSource: motor2Data,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            dataLabelMapper: (ChartData data, _) => data.event,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            color: Colors.orange,
          ),
          BarSeries<ChartData, DateTime>(
            name: 'Motor 3',
            dataSource: motor3Data,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            dataLabelMapper: (ChartData data, _) => data.event,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class TimeData {
  final String label;
  final DateTime onTime;
  final DateTime offTime;
  final Duration duration;

  TimeData({
    required this.label,
    required this.onTime,
    required this.offTime,
    required this.duration,
  });

  // Convert DateTime to minutes from the start of the day
  double get onTimeInMinutes => onTime.difference(DateTime(onTime.year, onTime.month, onTime.day)).inMinutes.toDouble();
  double get offTimeInMinutes => offTime.difference(DateTime(offTime.year, offTime.month, offTime.day)).inMinutes.toDouble();
  double get durationInMinutes => duration.inMinutes.toDouble();
}

class TimeGraph extends StatelessWidget {
  final List<TimeData> data;

  TimeGraph({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('On Time, Off Time, and Duration')),
      body: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: [
          StackedBarSeries<TimeData, String>(
            dataSource: data,
            xValueMapper: (TimeData time, _) => time.label,
            yValueMapper: (TimeData time, _) => time.onTimeInMinutes,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          StackedBarSeries<TimeData, String>(
            dataSource: data,
            xValueMapper: (TimeData time, _) => time.label,
            yValueMapper: (TimeData time, _) => time.offTimeInMinutes,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          StackedBarSeries<TimeData, String>(
            dataSource: data,
            xValueMapper: (TimeData time, _) => time.label,
            yValueMapper: (TimeData time, _) => time.onTimeInMinutes + time.durationInMinutes,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

List<TimeData> getTimeData() {
  return [
    TimeData(label: 'Event 1', onTime: DateTime(2024, 8, 1, 8, 0), offTime: DateTime(2024, 8, 1, 10, 0), duration: Duration(hours: 2)),
    TimeData(label: 'Event 2', onTime: DateTime(2024, 8, 1, 11, 0), offTime: DateTime(2024, 8, 1, 14, 0), duration: Duration(hours: 3)),
    TimeData(label: 'Event 3', onTime: DateTime(2024, 8, 1, 15, 0), offTime: DateTime(2024, 8, 1, 17, 0), duration: Duration(hours: 2)),
  ];
}

