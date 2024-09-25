import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/http_service.dart';
import '../../../../../widget/SCustomWidgets/custom_segmented_control.dart';
import '../../../../../widget/SCustomWidgets/custom_snack_bar.dart';
import '../../../Planning/NewIrrigationProgram/irrigation_program_main.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class HourlyData extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int nodeControllerId;
  const HourlyData({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0});

  @override
  State<HourlyData> createState() => _HourlyDataState();
}

class _HourlyDataState extends State<HourlyData> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late OverAllUse overAllPvd;
  List<MotorDataHourly> motorDataList = [];
  List<PageController> pageController= [];
  List<MotorData> chartData = [];
  List<double> currPageValue = [];
  double scaleFactor = 0.8;
  List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));

  @override
  void initState() {
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    super.initState();
    getPumpControllerData();
  }

  Future<void> getPumpControllerData({int selectedIndex = 0}) async {
    setState(() {
      if (selectedIndex == 1) {
        dates = List.generate(7, (index) => DateTime.now().subtract(Duration(days: index)));
      } else if (selectedIndex == 2) {
        dates = List.generate(30, (index) => DateTime.now().subtract(Duration(days: index)));
      } else if(selectedIndex == 0){
        dates.last = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      } else {
        dates.last = DateTime.parse(dates.last.toString().split(' ')[0]);
      }
    });

    var data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.last),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.first),
      "needSum" : selectedIndex != 0
    };
    try {
      final getPumpController = await HttpService().postRequest(widget.nodeControllerId == 0 ? "getUserPumpHourlyLog" : "getUserNodePumpHourlyLog", data);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        // print(response);
        // print(getPumpController.body);
        // print(data);
        Future.delayed(Duration(microseconds: 1000));
        setState(() {
          chartData = [];
          if (response['data'] is List) {
            List<dynamic> dataList = response['data'];
            motorDataList = dataList.map((item) => MotorDataHourly.fromJson(item)).toList();
            for (var i = 0; i < motorDataList[0].numberOfPumps; i++) {
              List<Color> colors = [Colors.lightBlueAccent.shade100.withOpacity(0.6), Colors.lightGreenAccent.withOpacity(0.6), Colors.greenAccent.withOpacity(0.6)];
              chartData.add(
                  MotorData(
                      "M${i + 1}",
                      [motorDataList[0].motorRunTime1, motorDataList[0].motorRunTime2, motorDataList[0].motorRunTime3][i],
                      colors[i]
                  )
              );
            }

          } else {
            motorDataList = [];
            chartData = [];
            log('Data is not a List');
          }
        });
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("Error ==> $e");
      log("StackTrace ==> $stackTrace");
    }
  }

  Future<void> showSnackBar({required String message}) async{
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  message));
  }

  Future<void> exportMotorDataToExcel(List<MotorDataHourly> motorDataList, name, context) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('Date'),
      // TextCellValue('Number of Pumps'),
      TextCellValue('Two Phase Power On Time'),
      TextCellValue('Overall Cumulative Flow'),
      TextCellValue('Flow Rate'),
      TextCellValue('Pressure'),
      TextCellValue('Level'),
      TextCellValue('Two Phase Last Power On Time'),
      TextCellValue('Three Phase Power On Time'),
      TextCellValue('Three Phase Last Power On Time'),
      TextCellValue('Power Off Time'),
      TextCellValue('Last Power On Time'),
      TextCellValue('Total Power On Time'),
      TextCellValue('Total Power Off Time'),
      TextCellValue('Motor Run Time 1'),
      TextCellValue('Motor Idle Time 1'),
      TextCellValue('Last Date Run Time 1'),
      TextCellValue('Last Date Run Flow 1'),
      TextCellValue('Dry Run Trip Time 1'),
      TextCellValue('Cyclic Trip Time 1'),
      TextCellValue('Other Trip Time 1'),
      TextCellValue('Total Flow Today 1'),
      TextCellValue('Motor Run Time 2'),
      TextCellValue('Motor Idle Time 2'),
      TextCellValue('Last Date Run Time 2'),
      TextCellValue('Last Date Run Flow 2'),
      TextCellValue('Dry Run Trip Time 2'),
      TextCellValue('Cyclic Trip Time 2'),
      TextCellValue('Other Trip Time 2'),
      TextCellValue('Total Flow Today 2'),
      TextCellValue('Motor Run Time 3'),
      TextCellValue('Motor Idle Time 3'),
      TextCellValue('Last Date Run Time 3'),
      TextCellValue('Last Date Run Flow 3'),
      TextCellValue('Dry Run Trip Time 3'),
      TextCellValue('Cyclic Trip Time 3'),
      TextCellValue('Other Trip Time 3'),
      TextCellValue('Total Flow Today 3'),
    ]);

    // Append rows of data
    for (var data in motorDataList) {
      sheet.appendRow([
        TextCellValue(data.date),
        // TextCellValue(data.numberOfPumps.toString()),
        TextCellValue(data.twoPhasePowerOnTime),
        TextCellValue(data.overAllCumulativeFlow),
        TextCellValue(data.flowRate),
        TextCellValue(data.pressure),
        TextCellValue(data.level),
        TextCellValue(data.twoPhaseLastPowerOnTime),
        TextCellValue(data.threePhasePowerOnTime),
        TextCellValue(data.threePhaseLastPowerOnTime),
        TextCellValue(data.powerOffTime),
        TextCellValue(data.lastPowerOnTime),
        TextCellValue(data.totalPowerOnTime),
        TextCellValue(data.totalPowerOffTime),
        TextCellValue(data.motorRunTime1),
        TextCellValue(data.motorIdleTime1),
        TextCellValue(data.lastDateRunTime1),
        TextCellValue(data.lastDateRunFlow1),
        TextCellValue(data.dryRunTripTime1),
        TextCellValue(data.cyclicTripTime1),
        TextCellValue(data.otherTripTime1),
        TextCellValue(data.totalFlowToday1),
        TextCellValue(data.motorRunTime2),
        TextCellValue(data.motorIdleTime2),
        TextCellValue(data.lastDateRunTime2),
        TextCellValue(data.lastDateRunFlow2),
        TextCellValue(data.dryRunTripTime2),
        TextCellValue(data.cyclicTripTime2),
        TextCellValue(data.otherTripTime2),
        TextCellValue(data.totalFlowToday2),
        TextCellValue(data.motorRunTime3),
        TextCellValue(data.motorIdleTime3),
        TextCellValue(data.lastDateRunTime3),
        TextCellValue(data.lastDateRunFlow3),
        TextCellValue(data.dryRunTripTime3),
        TextCellValue(data.cyclicTripTime3),
        TextCellValue(data.otherTripTime3),
        TextCellValue(data.totalFlowToday3),
      ]);
    }

    // Save the file
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      try {
        String downloadsDirectoryPath = "/storage/emulated/0/Download";
        String filePath = "$downloadsDirectoryPath/$name.xlsx";
        File file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(fileBytes);
        // Check if file exists
        if (await file.exists()) {
          // Scaffold.of(context).showSnackBar()
          Navigator.pop(context);
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text('$name Download Successfully at'),
              content: Text('$filePath'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Ok')
                )
              ],
            );
          });

          showSnackBar(message: "Excel file saved successfully at $filePath");

          print("Excel file saved successfully at $filePath");
        } else {
          Navigator.pop(context);
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text('$name Download failed..'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Ok')
                )
              ],
            );
          });
          log("Failed to save the Excel file.");
        }
      } catch (e) {
        log("Error saving the Excel file: $e");
      }
    } else {
      log("Error encoding the Excel file.");
    }
  }

  @override
  Widget build(BuildContext context) {
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: const Color(0xffF9FEFF),
      body: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  if(selectedIndex == 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        boxShadow: customBoxShadow,
                        color: Colors.white,
                      ),
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
                          getPumpControllerData();
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: customBoxShadow
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          selectedIndex == 0
                              ? "${getWeekdayName(DateTime.now().weekday)}, ${getMonthName(DateTime.now().month)} ${DateTime.now().day}"
                              : selectedIndex == 1
                              ? "Last 7 days"
                              : "Last 30 days",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          selectedIndex == 0
                              ? "Today"
                              : "${DateFormat('MMM d yyyy').format(dates.first)} - ${DateFormat('MMM d yyyy').format(dates.last)}",
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                        tileColor: Colors.white,
                        trailing: IconButton(
                          onPressed: (){
                            showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now()
                            ).then((pickedDateRange) {
                              if (pickedDateRange != null) {
                                setState(() {
                                  dates.first = pickedDateRange.start;
                                  dates.last = pickedDateRange.end;
                                  dates = List.generate(pickedDateRange.end.difference(pickedDateRange.start).inDays, (index) => pickedDateRange.start.add(Duration(days: index)));
                                });
                              } else {
                                print('Date range picker was canceled');
                              }
                            }).whenComplete(() {
                              getPumpControllerData();
                            });
                          },
                          icon: const Icon(Icons.calendar_month, color: Colors.white,),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)
                          ),
                        ),
                      ),
                    ),
                  CustomSegmentedControl(
                      segmentTitles: const {
                        0: "Daily",
                        1: "Weekly",
                        2: "Monthly",
                      },
                      groupValue: selectedIndex,
                      onChanged: (newValue) {
                        setState(() {
                          selectedIndex = newValue!;
                        });
                        getPumpControllerData(selectedIndex: newValue!);
                      }
                  ),
                  const SizedBox(height: 10),
                  buildDailyDataView(constraints: constraints),
                ],
              );
            }
        ),
      ),
      floatingActionButton: MaterialButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (dialogContext){
                  var fileName = 'Power graph';
                  return AlertDialog(
                    title: Text('File name'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: fileName,
                          onChanged: (value){
                            fileName = value;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder()
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async{
                            await exportMotorDataToExcel(motorDataList,fileName,dialogContext);
                            Navigator.pop(context);
                          },
                          child: Text('Click to download')
                      )
                    ],
                  );
                }
            );
          },
        child: Icon(Icons.download, color: Colors.white,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.zero,
        minWidth: 40,
        height: 40,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget buildDailyDataView({required BoxConstraints constraints}) {
    final selectedCondition = selectedIndex == 0;
    return Expanded(
      child: motorDataList.isNotEmpty ? ListView.builder(
          itemCount: selectedCondition ? motorDataList.length : 1,
          itemBuilder: (BuildContext context, int index) {
            if(motorDataList[index].numberOfPumps != 0) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: customBoxShadow
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(selectedCondition)
                          buildHeader(index),
                        const SizedBox(height: 10,),
                        buildScale(scale: generateScale(selectedCondition
                            ? const Duration(hours: 24)
                            : parseTime(motorDataList[index].totalPowerOnTime.toString()))
                        ),
                        const SizedBox(height: 10,),
                        buildAnimatedContainer(
                            color: const Color(0xff15C0E6),
                            value: parseTime(motorDataList[index].totalPowerOnTime.toString()),
                            motor: "Total Power -",
                            highestValue: selectedIndex == 0 ? const Duration(hours: 24) : parseTime(motorDataList[index].totalPowerOnTime.toString())
                        ),
                        const SizedBox(height: 10,),
                        buildMotorStatusContainers(index: index, numberOfPumps: motorDataList[index].numberOfPumps),
                        const SizedBox(height: 10,),
                        // buildLegend(),
                        // const SizedBox(height: 10,),
                        // DoughnutChart(
                        //   chartData: chartData,
                        //   totalPowerDuration: parseTime(motorDataList[index].totalPowerOnTime),
                        // ),
                        buildFooter(motorDataList[index]),
                        // if(motorDataList[index].numberOfPumps == 1)
                        //   buildMotorDetails(motorIndex: 0, dayIndex: index)
                        // else
                        buildPageView(dayIndex: index, constraints: constraints, numberOfPumps: motorDataList[index].numberOfPumps)
                      ],
                    ),
                  ),
                  const SizedBox(height: 70,)
                ],
              );
            } else {
              return Container();
            }
          }
      ) : Center(child: Text("Data not found"),),
    );
  }

  Widget buildMotorDetails({required int motorIndex, required int dayIndex,}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildItemContainer(
          title1: 'Motor run time',
          title2: "Motor idle time",
          value1: [motorDataList[dayIndex].motorRunTime1, motorDataList[dayIndex].motorRunTime2, motorDataList[dayIndex].motorRunTime3][motorIndex],
          value2: [motorDataList[dayIndex].motorIdleTime1, motorDataList[dayIndex].motorIdleTime2, motorDataList[dayIndex].motorIdleTime3][motorIndex],
        ),
        buildItemContainer(
          title1: 'Dry run trip time',
          title2: 'Cyclic trip time',
          value1: [motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex],
          value2: [motorDataList[dayIndex].cyclicTripTime1, motorDataList[dayIndex].cyclicTripTime2, motorDataList[dayIndex].cyclicTripTime3][motorIndex],
        ),
        buildItemContainer(
          title1: 'Other trip time',
          title2: 'Total flow today',
          value1: [motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex],
          value2: "${[motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3][motorIndex]} Litres",
        ),
      ],
    );
  }

  Widget buildItemContainer2({
    required String title1,
    required String title2,
    required int index,
    required int numberOfPumps,
    List<String>? value1,
    List<String>? value2,
    required String unit1,
    required String unit2
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          // border: Border(
          //   top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
          // )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title1, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < numberOfPumps; i++)
                Expanded(flex: 2, child: Text(value1![i], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              if(numberOfPumps != 3)
                Expanded(flex: 2, child: Text(unit1, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title2, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < numberOfPumps; i++)
                Expanded(flex: 2, child: Text(value2![i], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              if(numberOfPumps != 3)
                Expanded(flex: 2, child: Text(unit2, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPageView({required int dayIndex, required BoxConstraints constraints, required int numberOfPumps}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: double.maxFinite,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Container()),
                        for(var i = 0; i < numberOfPumps; i++)
                          Expanded(flex: 2, child: Text("Motor ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        if(numberOfPumps != 3)
                          const Expanded(flex: 2, child: Text("Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                  )
              ),
              buildItemContainer2(
                  title1: 'Motor run time',
                  title2: "Motor idle time",
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [changeFormat(motorDataList[dayIndex].motorRunTime1), changeFormat(motorDataList[dayIndex].motorRunTime2), changeFormat(motorDataList[dayIndex].motorRunTime3)],
                  value2: [changeFormat(motorDataList[dayIndex].motorIdleTime1), changeFormat(motorDataList[dayIndex].motorIdleTime2), changeFormat(motorDataList[dayIndex].motorIdleTime3)],
                  unit1: "HH:MM",
                  unit2: "HH:MM"
              ),
              buildItemContainer2(
                  title1: 'Dry run trip time',
                  title2: 'Cyclic trip time',
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [changeFormat(motorDataList[dayIndex].dryRunTripTime1), changeFormat(motorDataList[dayIndex].dryRunTripTime2), changeFormat(motorDataList[dayIndex].dryRunTripTime3)],
                  value2: [changeFormat(motorDataList[dayIndex].cyclicTripTime1), changeFormat(motorDataList[dayIndex].cyclicTripTime2), changeFormat(motorDataList[dayIndex].cyclicTripTime3)],
                  unit1: "HH:MM",
                  unit2: "HH:MM"
              ),
              buildItemContainer2(
                  title1: 'Other trip time',
                  title2: 'Total flow today',
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [changeFormat(motorDataList[dayIndex].dryRunTripTime1), changeFormat(motorDataList[dayIndex].dryRunTripTime2), changeFormat(motorDataList[dayIndex].dryRunTripTime3)],
                  value2: [motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3],
                  unit1: "HH:MM",
                  unit2: "Litres"
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildHeader(int index) {
    return Card(
        surfaceTintColor: const Color(0xffb6f6e5),
        color: const Color(0xffb4e3ed),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                DateFormat('MMM d yyyy').format(motorDataList[index].date != "" ? DateTime.parse(motorDataList[index].date) : DateTime.now()),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
          ),
        )
    );
  }

  Widget buildMotorStatusContainers({required int index, required int numberOfPumps}) {
    List<Widget> containers = [];
    for (var i = 0; i < numberOfPumps; i++) {
      // print(motorDataList[index].totalPowerOnTime);
      containers.add(
          Column(
            children: [
              buildAnimatedContainer(
                  color: [Colors.lightBlueAccent.shade100.withOpacity(0.6), Colors.lightGreenAccent.withOpacity(0.6), Colors.greenAccent.withOpacity(0.6)][i],
                  value: [parseTime(motorDataList[index].motorRunTime1), parseTime(motorDataList[index].motorRunTime2), parseTime(motorDataList[index].motorRunTime3)][i],
                  motor: "Motor ${i + 1} consumed",
                  highestValue: selectedIndex == 0 ? Duration(hours: 24): parseTime(motorDataList[index].totalPowerOnTime)
              ),
              const SizedBox(height: 10,)
            ],
          )
      );
    }
    return Column(children: containers);
  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            buildLegendItem(color: const Color(0xff15C0E6), label: "Power Status"),
            const SizedBox(width: 30,),
            buildLegendItem(color: const Color(0xff10E196), label: "Motor Status"),
          ],
        )
      ],
    );
  }

  Widget buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color)),
        const SizedBox(width: 10,),
        Text(label, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14))
      ],
    );
  }

  Widget buildFooter(MotorDataHourly motorDataHourly) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildFooterItem("Cumulative flow", "Litres", motorDataHourly.overAllCumulativeFlow, "Pressure", motorDataHourly.pressure != "-" ? motorDataHourly.pressure : "", motorDataHourly.pressure != "-" ? "bar" : ""),
            SizedBox(height: 7,),
            buildFooterItem("Flow rate", "Lps", motorDataHourly.flowRate, "Level", motorDataHourly.level != "-" ? motorDataHourly.level : "", motorDataHourly.level != "-" ? "feet" : ""),
            SizedBox(height: 7,),
            buildFooterItem("Total power on time", "", changeFormat(motorDataHourly.totalPowerOnTime), "Total power off time", changeFormat(motorDataHourly.totalPowerOffTime), "")
          ],
        )
    );
  }

  Widget buildFooterItem(String label1, String unit1, String value1, String label2, String value2, String unit2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(label1, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
              Text("$value1 $unit1", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            children: [
              Text(label2, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
              Text("$value2 $unit2", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ],
          ),
        )
      ],
    );
  }

  Widget buildItemContainer({
    required String title1,
    required String title2,
    required String value1,
    required String value2
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          buildItemRow(
              title1: title1,
              title2: title2,
              value1: value1,
              value2: value2
          )
        ],
      ),
    );
  }

  Widget buildItemRow({required String title1, required String title2, required String value1, required String value2}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildItem(title: title1, value: value1, color: Theme.of(context).primaryColor),
          buildItem(title: title2, value: value2, color: Colors.red)
        ],
      ),
    );
  }

  Widget buildItem({required String title, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class PieChartData {
  final String name;
  final double percentage;
  final String duration;
  final Color color;

  PieChartData(this.name, this.percentage, this.duration, this.color);
}

class DoughnutChart extends StatelessWidget {
  final List<MotorData> chartData;
  final Duration totalPowerDuration;
  const DoughnutChart({super.key, required this.chartData, required this.totalPowerDuration});

  @override
  Widget build(BuildContext context) {

    List<PieChartData> pieChartData = chartData.map((motor) {
      Duration motorDuration = parseTime(motor.powerConsumed);
      double percentage = totalPowerDuration.inMilliseconds != 0 ? (motorDuration.inMilliseconds / totalPowerDuration.inMilliseconds) * 100 : 0;
      return PieChartData(motor.name, percentage, motor.powerConsumed, motor.color);
    }).toList();

    Duration totalMotorDuration = const Duration();
    for (var motor in chartData) {
      totalMotorDuration += parseTime(motor.powerConsumed);
      // print(totalMotorDuration);
    }
    Duration balancePowerDuration = totalPowerDuration - totalMotorDuration;
    double balancePercentage = totalPowerDuration.inMilliseconds != 0 ? (balancePowerDuration.inMilliseconds / totalPowerDuration.inMilliseconds) * 100 : 0;
    pieChartData.add(PieChartData('Rem', balancePercentage, balancePowerDuration.toString().split('.')[0], const Color(0xff15C0E6)));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}"
          Text("Total duration: ${totalPowerDuration.inHours.toString().padLeft(2, '0')}:${(totalPowerDuration.inMinutes % 60).toString().padLeft(2, '0')}"),
          SizedBox(
            height: 180,
            child: SfCircularChart(
              // annotations: <CircularChartAnnotation>[
              //   CircularChartAnnotation(
              //     widget: Text(
              //       '${pieChartData[0].percentage.toStringAsFixed(1)}%',
              //       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     ),
              //   ),
              // ],
              series: <CircularSeries>[
                DoughnutSeries<PieChartData, String>(
                  dataSource: pieChartData,
                  xValueMapper: (PieChartData data, _) => data.name,
                  yValueMapper: (PieChartData data, _) => data.percentage,
                  dataLabelMapper: (PieChartData data, _) => '${data.name}: ${changeFormat(data.duration)}',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    labelPosition: ChartDataLabelPosition.outside,
                    labelAlignment: ChartDataLabelAlignment.auto,
                  ),
                  pointColorMapper: (PieChartData data, _) => data.color,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Duration parseTime(String timeString) {
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitHours = twoDigits(duration.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
}

Widget buildPageItem({
  required BuildContext context,
  required int index,
  required Widget subChild,
  required Widget child,
  required int pageControllerIndex,
  required currPageValue,
  required height,
  required scaleFactor
}) {
  double currentPage = currPageValue[pageControllerIndex];
  // print("_currPageValue"+currPageValue.toString());
  // print("index"+index.toString());
  double currScale;
  double currTrans;
  if (index == currentPage.floor()) {
    currScale = 1 - (currentPage - index) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else if (index == currentPage.floor() + 1) {
    currScale = scaleFactor + (currentPage - index + 1) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else if (index == currentPage.floor() - 1) {
    currScale = 1 - (currentPage - index) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else {
    currScale = 0.8;
    currTrans = height * (1 - currScale) / 2;
  }

  Matrix4 matrix = Matrix4.identity()
    ..setEntry(0, 0, 1)
    ..setEntry(1, 1, currScale)
    ..setEntry(2, 2, 1)
    ..setTranslationRaw(0, currTrans, 0);

  return Transform(
    transform: matrix,
    child: Stack(
      children: [
        Container(
          // height: 200,
          // width: double.maxFinite,
          margin: const EdgeInsets.only(bottom: 20, top: 20, right: 5, left: 5),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(15),
          //     boxShadow: neumorphicButtonShadow,
          //     color: Colors.white
          // ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            color: index.isEven
                ? const Color.fromARGB(255, 114, 218, 232)
                : const Color.fromARGB(255, 94, 101, 239),
          ),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: child
              )
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: subChild,
          ),
        ),
      ],
    ),
  );
}

Widget buildDayWidget({
  required BuildContext context,
  required String date,
  required String day,
  required String month,
  Color backgroundColor = Colors.white,
  Color textColor = Colors.black,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20)
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.normal, fontSize: 10),),
        Text(date, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(month, style: TextStyle(color: textColor, fontWeight: FontWeight.normal, fontSize: 10)),
      ],
    ),
  );
}

String getWeekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return '';
  }
}

String getMonthName(int month) {
  switch (month) {
    case DateTime.january:
      return 'January';
    case DateTime.february:
      return 'February';
    case DateTime.march:
      return 'March';
    case DateTime.april:
      return 'April';
    case DateTime.may:
      return 'May';
    case DateTime.june:
      return 'June';
    case DateTime.july:
      return 'July';
    case DateTime.august:
      return 'August';
    case DateTime.september:
      return 'September';
    case DateTime.october:
      return 'October';
    case DateTime.november:
      return 'November';
    case DateTime.december:
      return 'December';
    default:
      return '';
  }
}

class MotorData {
  final String name;
  final String powerConsumed;
  final Color color;

  MotorData(this.name, this.powerConsumed, this.color);
}

class MotorDataHourly {
  final String date;
  final int numberOfPumps;
  final String twoPhasePowerOnTime;
  final String overAllCumulativeFlow;
  final String flowRate;
  final String pressure;
  final String level;
  final String twoPhaseLastPowerOnTime;
  final String threePhasePowerOnTime;
  final String threePhaseLastPowerOnTime;
  final String powerOffTime;
  final String lastPowerOnTime;
  final String totalPowerOnTime;
  final String totalPowerOffTime;
  final String motorRunTime1;
  final String motorIdleTime1;
  final String lastDateRunTime1;
  final String lastDateRunFlow1;
  final String dryRunTripTime1;
  final String cyclicTripTime1;
  final String otherTripTime1;
  final String totalFlowToday1;
  final String motorRunTime2;
  final String motorIdleTime2;
  final String lastDateRunTime2;
  final String lastDateRunFlow2;
  final String dryRunTripTime2;
  final String cyclicTripTime2;
  final String otherTripTime2;
  final String totalFlowToday2;
  final String motorRunTime3;
  final String motorIdleTime3;
  final String lastDateRunTime3;
  final String lastDateRunFlow3;
  final String dryRunTripTime3;
  final String cyclicTripTime3;
  final String otherTripTime3;
  final String totalFlowToday3;

  MotorDataHourly({
    required this.date,
    required this.overAllCumulativeFlow,
    required this.flowRate,
    required this.pressure,
    required this.level,
    required this.numberOfPumps,
    required this.twoPhasePowerOnTime,
    required this.twoPhaseLastPowerOnTime,
    required this.threePhasePowerOnTime,
    required this.threePhaseLastPowerOnTime,
    required this.powerOffTime,
    required this.lastPowerOnTime,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
    required this.motorRunTime1,
    required this.motorIdleTime1,
    required this.lastDateRunTime1,
    required this.lastDateRunFlow1,
    required this.dryRunTripTime1,
    required this.cyclicTripTime1,
    required this.otherTripTime1,
    required this.totalFlowToday1,
    required this.motorRunTime2,
    required this.motorIdleTime2,
    required this.lastDateRunTime2,
    required this.lastDateRunFlow2,
    required this.dryRunTripTime2,
    required this.cyclicTripTime2,
    required this.otherTripTime2,
    required this.totalFlowToday2,
    required this.motorRunTime3,
    required this.motorIdleTime3,
    required this.lastDateRunTime3,
    required this.lastDateRunFlow3,
    required this.dryRunTripTime3,
    required this.cyclicTripTime3,
    required this.otherTripTime3,
    required this.totalFlowToday3,
  });
  factory MotorDataHourly.fromJson(Map<String, dynamic> json){
    int getFirstNonZeroIndex(String value) {
      if (value == "-" || value == "0.0") {
        return -1;
      }

      for (int i = 0; i < value.length; i++) {
        if (int.parse(value[i]) > 0) {
          return i;
        }
      }

      return -1;
    }

    String getCumulativeFlow(Map<String, dynamic> json, String key) {
      final value = json[key];
      int firstIndex = getFirstNonZeroIndex(value);

      if (firstIndex == -1) {
        return "0";
      }

      return value.substring(firstIndex);
    }

    return MotorDataHourly(
      date: json['date'],
      numberOfPumps: json['numberOfPumps'],
      twoPhasePowerOnTime: json['twoPhasePowerOnTime'],
      twoPhaseLastPowerOnTime: json['twoPhaseLastPowerOnTime'],
      threePhasePowerOnTime: json['threePhasePowerOnTime'],
      overAllCumulativeFlow: getCumulativeFlow(json, 'overAllCumulativeFlow'),
      flowRate: json['flowRate'],
      pressure: json['pressure'],
      level: json['level'],
      threePhaseLastPowerOnTime: json['threePhaseLastPowerOnTime'],
      powerOffTime: json['powerOffTime'],
      lastPowerOnTime: json['lastPowerOnTime'],
      totalPowerOnTime: json['totalPowerOnTime'],
      totalPowerOffTime: json['totalPowerOffTime'],
      motorRunTime1: json['motorRunTime1'],
      motorIdleTime1: json['motorIdleTime1'],
      lastDateRunTime1: json['lastDateRunTime1'],
      lastDateRunFlow1: json['lastDateRunFlow1'],
      dryRunTripTime1: json['dryRunTripTime1'],
      cyclicTripTime1: json['cyclicTripTime1'],
      otherTripTime1: json['otherTripTime1'],
      totalFlowToday1: getCumulativeFlow(json, 'totalFlowToday1'),
      motorRunTime2: json['motorRunTime2'],
      motorIdleTime2: json['motorIdleTime2'],
      lastDateRunTime2: json['lastDateRunTime2'],
      lastDateRunFlow2: json['lastDateRunFlow2'],
      dryRunTripTime2: json['dryRunTripTime2'],
      cyclicTripTime2: json['cyclicTripTime2'],
      otherTripTime2: json['otherTripTime2'],
      totalFlowToday2: getCumulativeFlow(json, 'totalFlowToday2'),
      motorRunTime3: json['motorRunTime3'],
      motorIdleTime3: json['motorIdleTime3'],
      lastDateRunTime3: json['lastDateRunTime3'],
      lastDateRunFlow3: json['lastDateRunFlow3'],
      dryRunTripTime3: json['dryRunTripTime3'],
      cyclicTripTime3: json['cyclicTripTime3'],
      otherTripTime3: json['otherTripTime3'],
      totalFlowToday3: getCumulativeFlow(json, 'totalFlowToday3'),
      // totalFlowToday3: json['totalFlowToday3'],
    );
  }
}

List<String> generateScale(Duration highestValue) {
  final int highestValueInMinutes = highestValue.inMinutes;
  const int segmentCount = 3;
  final List<String> scale = [];
  for (var i = 0; i <= segmentCount; i++) {
    final valueInMinutes = (highestValueInMinutes / segmentCount * i).toInt();
    final value = Duration(minutes: valueInMinutes);
    scale.add("${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}");
  }
  return scale;
}

Widget buildScale({required List<String> scale}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: scale.map((value) => Text(value, style: const TextStyle(color: Color(0xff9291A5)))).toList(),
  );
}

String changeFormat(String value) {
  List<String> stringList = value.split(":");
  stringList.removeLast();
  String result = stringList.join(":");
  // print("result string ==> $result");
  return result;
}

Widget buildAnimatedContainer({required Color color, required Duration value, required String motor, required Duration highestValue}) {
  final percentage = highestValue.inMilliseconds != 0
      ? (value.inMilliseconds / highestValue.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    height: 30,
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xffF5F7F9),
              borderRadius: BorderRadius.circular(2)
          ),
        ),
        AnimatedFractionallySizedBox(
          widthFactor: percentage > 1 ? 1 : percentage,
          duration: const Duration(milliseconds: 1000),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Center(
            child: motor.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    motor,
                    style: TextStyle(
                        color: !motor.contains("Motor") ? percentage >= 0.8 ? Colors.white : Colors.black : Colors.black
                    )
                ),
                const SizedBox(width: 5,),
                Text(
                    "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                        color: !motor.contains("Motor") ? percentage >= 0.8 ? Colors.white : Colors.black : Colors.black
                    )
                ),
              ],
            )
                : Text(
                "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}",
                style: TextStyle(
                    color: percentage >= 0.5 ? Colors.white : Colors.black
                )
            )
        )
      ],
    ),
  );
}
