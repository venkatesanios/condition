import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../ListOfFertilizerInSet.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/SCustomWidgets/custom_animated_switcher.dart';
import '../../../widget/SCustomWidgets/custom_snack_bar.dart';
import '../../../widget/SCustomWidgets/custom_timeline_widget.dart';
import '../../state_management/schedule_view_provider.dart';
import '../Customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';
import '../Customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'Planning/NewIrrigationProgram/program_library.dart';

class ScheduleViewScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int customerId;
  final String deviceId;

  const ScheduleViewScreen({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.customerId,
    required this.deviceId,
  });

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> with TickerProviderStateMixin{
  late ScheduleViewProvider scheduleViewProvider;
  late AnimationController _animationController;
  late OverAllUse overAllPvd;
  bool isToday = false;
  HttpService httpService = HttpService();
  // DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String message = "";
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime today = DateTime.now();

  DateTime scheduleDateWithoutTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime todayWithoutTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Future.delayed(Duration.zero, () {
  // scheduleViewProvider.date = selectedDate;
  // }).then((value) {
  // scheduleViewProvider.fetchData(overAllPvd.imeiNo, overAllPvd.userId, overAllPvd.controllerId, context);
  // scheduleViewProvider.updateSelectedProgramCategory(0);
  // });
  @override
  void initState() {
    super.initState();
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    scheduleViewProvider.payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    scheduleViewProvider.selectedStatusList = [];
    // scheduleViewProvider.selectedProgramList = [];
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scheduleViewProvider.fetchData(overAllPvd.imeiNo, overAllPvd.userId, overAllPvd.controllerId, context);
        scheduleViewProvider.updateSelectedProgramCategory(0);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: true);
    scheduleDateWithoutTime = DateTime(scheduleViewProvider.date.year, scheduleViewProvider.date.month, scheduleViewProvider.date.day);
    final screenSize = MediaQuery.of(context).size.width;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async{
          scheduleViewProvider.fetchData(overAllPvd.imeiNo, overAllPvd.userId, overAllPvd.controllerId, context);
        },
        child: !scheduleViewProvider.isLoading
            ? Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: customBoxShadow,
                color: Colors.white,
              ),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2100, 12, 31),
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
                  return isSameDay(scheduleViewProvider.date, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    scheduleViewProvider.date = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  scheduleViewProvider.fetchData(overAllPvd.imeiNo, overAllPvd.userId, overAllPvd.controllerId, context);
                  scheduleViewProvider.updateSelectedProgramCategory(0);
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < scheduleViewProvider.programCategories.length; i++)
                                buildSideBarMenuList(
                                  context: context,
                                  title: scheduleViewProvider.programCategories[i].split('_').join(', ').toString(),
                                  dataList: scheduleViewProvider.programCategories,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(scheduleViewProvider.programCategories[i].split('_').join(', ').toString(), style: TextStyle(color: scheduleViewProvider.selectedProgramCategory == i ? Colors.white : Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                                      SizedBox(width: 5,),
                                      CircleAvatar(
                                          radius: 12,
                                          backgroundColor: scheduleViewProvider.selectedProgramCategory == i ? Colors.white : Theme.of(context).primaryColor,
                                          child: Text("${scheduleViewProvider.scheduleCountList[i]}", style: TextStyle(color: scheduleViewProvider.selectedProgramCategory == i ? Theme.of(context).primaryColor: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                                      )
                                    ],
                                  ),
                                  index: i,
                                  selected: scheduleViewProvider.selectedProgramCategory == i,
                                  onTap: (index) {
                                    scheduleViewProvider.updateSelectedProgramCategory(index);
                                  },
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0), Colors.grey.withOpacity(0.5)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(scheduleViewProvider.convertedList.isNotEmpty)
                          buildActionRow(),
                        if(scheduleViewProvider.convertedList.isNotEmpty && (scheduleViewProvider.selectedStatusList.isNotEmpty ? ((scheduleViewProvider.selectedStatusList.length == 1 ? scheduleViewProvider.selectedStatusList[0] == "Pending" : false) && scheduleViewProvider.selectedProgramList.length == 1) : false))
                          IconButton(
                            color: Theme.of(context).primaryColor,
                            iconSize: 35,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(5)
                            // ),
                            onPressed: (){
                              scheduleViewProvider.changeToValue = "";
                              scheduleViewProvider.selectedRtc = "";
                              scheduleViewProvider.selectedCycle = "";
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (context, StateSetter stateSetter) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                buildPopUpMenuButton(
                                                    context: context,
                                                    dataList: scheduleViewProvider.convertedList
                                                        .where((element) => element["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory]
                                                        && (element["Status"] == 0 || element["Status"] == 4)
                                                        && (element['ProgramName'] == scheduleViewProvider.selectedProgramList[0]))
                                                        .map((e) => e['RtcNumber'].toString()).toSet()
                                                        .toList(),
                                                    onSelected: (newValue){
                                                      stateSetter(() {
                                                        scheduleViewProvider.selectedRtc = newValue;
                                                        scheduleViewProvider.changeToValue = '';
                                                        scheduleViewProvider.selectedCycle = '';
                                                        scheduleViewProvider.selectedZone = '';
                                                      });
                                                    },
                                                    offset: const Offset(0, 50),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(gradient: linearGradientLeading, borderRadius: BorderRadius.circular(5)),
                                                      child: Row(
                                                        children: [
                                                          const Text("Select RTC", style: TextStyle(color: Colors.white),),
                                                          const SizedBox(width: 10,),
                                                          Text(scheduleViewProvider.selectedRtc, style: const TextStyle(color: Colors.white)),
                                                        ],
                                                      ),
                                                    )
                                                ),
                                                const SizedBox(height: 20,),
                                                if(scheduleViewProvider.convertedList.isNotEmpty
                                                    && (scheduleViewProvider.selectedStatusList.isNotEmpty ? ((scheduleViewProvider.selectedStatusList.length == 1 ? scheduleViewProvider.selectedStatusList[0] == "Pending" : false)
                                                        && scheduleViewProvider.selectedProgramList.length == 1 && scheduleViewProvider.selectedRtc.isNotEmpty) : false))
                                                  buildPopUpMenuButton(
                                                      context: context,
                                                      dataList: scheduleViewProvider.convertedList
                                                          .where((element) => element["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory]
                                                          && (element["Status"] == 0 || element["Status"] == 4)
                                                          && (element['ProgramName'] == scheduleViewProvider.selectedProgramList[0]) && (element['RtcNumber'] == int.parse(scheduleViewProvider.selectedRtc)))
                                                          .map((e) => e['CycleNumber'].toString()).toSet()
                                                          .toList(),
                                                      onSelected: (newValue){
                                                        stateSetter(() {
                                                          scheduleViewProvider.selectedCycle = newValue;
                                                          scheduleViewProvider.changeToValue = '';
                                                          scheduleViewProvider.selectedZone = '';
                                                        });
                                                      },
                                                      offset: const Offset(0, 50),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(gradient: linearGradientLeading, borderRadius: BorderRadius.circular(5)),
                                                        child: Row(
                                                          children: [
                                                            const Text("Select Cycle", style: TextStyle(color: Colors.white),),
                                                            const SizedBox(width: 10,),
                                                            Text(scheduleViewProvider.selectedCycle, style: const TextStyle(color: Colors.white)),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                const SizedBox(height: 20,),
                                                if(scheduleViewProvider.convertedList.isNotEmpty
                                                    && (scheduleViewProvider.selectedStatusList.isNotEmpty ? ((scheduleViewProvider.selectedStatusList.length == 1 ? scheduleViewProvider.selectedStatusList[0] == "Pending" : false)
                                                        && scheduleViewProvider.selectedProgramList.length == 1 && scheduleViewProvider.selectedRtc.isNotEmpty && scheduleViewProvider.selectedCycle.isNotEmpty) : false))
                                                  buildPopUpMenuButton(
                                                      context: context,
                                                      dataList: scheduleViewProvider.convertedList
                                                          .where((element) => element["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory]
                                                          && (element["Status"] == 0 || element["Status"] == 4)
                                                          && (element['ProgramName'] == scheduleViewProvider.selectedProgramList[0])
                                                          && (element['RtcNumber'] == int.parse(scheduleViewProvider.selectedRtc))
                                                          && (element['CycleNumber'] == int.parse(scheduleViewProvider.selectedCycle)))
                                                          .map((e) => e['ZoneName'].toString())
                                                          .toList(),
                                                      onSelected: (newValue){
                                                        stateSetter(() {
                                                          scheduleViewProvider.convertedList.forEach((element) {
                                                            try {
                                                              if(element['ZoneName'] == newValue){
                                                                scheduleViewProvider.changeToValue = element['ScheduleOrder'].toString();
                                                                scheduleViewProvider.selectedZone = newValue;
                                                              }
                                                            } catch(error, stackTrace) {
                                                              print("Error : $error");
                                                              print("Stack Trace : $stackTrace");
                                                            }
                                                          });
                                                        });
                                                      },
                                                      offset: const Offset(0, 50),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(gradient: linearGradientLeading, borderRadius: BorderRadius.circular(5)),
                                                        child: Row(
                                                          children: [
                                                            const Text("Select schedule", style: TextStyle(color: Colors.white),),
                                                            const SizedBox(width: 10,),
                                                            Text(scheduleViewProvider.selectedZone, style: const TextStyle(color: Colors.white)),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    stateSetter(() {
                                                      // int changeToIndex = scheduleViewProvider.convertedList.indexWhere((element) => element["ScheduleOrder"].toString() == scheduleViewProvider.changeToValue);
                                                      int startIndex = scheduleViewProvider.convertedList.indexWhere((element) =>
                                                      element["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory] &&
                                                          (element["Status"] == 0 || element["Status"] == 4) &&
                                                          (element['ProgramName'] == scheduleViewProvider.selectedProgramList[0]) &&
                                                          (element['RtcNumber'] == int.parse(scheduleViewProvider.selectedRtc)) &&
                                                          (element['CycleNumber'] == int.parse(scheduleViewProvider.selectedCycle))
                                                      );
                                                      int lastIndex = scheduleViewProvider.convertedList.lastIndexWhere((element) =>
                                                      element["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory] &&
                                                          (element["Status"] == 0 || element["Status"] == 4) &&
                                                          (element['ProgramName'] == scheduleViewProvider.selectedProgramList[0]) &&
                                                          (element['RtcNumber'] == int.parse(scheduleViewProvider.selectedRtc)) &&
                                                          (element['CycleNumber'] == int.parse(scheduleViewProvider.selectedCycle))
                                                      );
                                                      int changeToIndex = scheduleViewProvider.convertedList.indexWhere((element) => element["ScheduleOrder"].toString() == scheduleViewProvider.changeToValue);
                                                      List temp = [];
                                                      scheduleViewProvider.convertedList.forEach((element) {
                                                        temp.add(element);
                                                      });
                                                      List temp2 = [
                                                        ...temp.sublist(startIndex, lastIndex+1)
                                                      ];
                                                      int startIndex2 = temp.indexOf(temp2[0]);
                                                      int changeIndex = temp2.indexOf(temp[changeToIndex]);
                                                      List head = temp.sublist(0, startIndex2);
                                                      List tail = temp.sublist(startIndex2 + temp2.length);
                                                      List temp3 = [
                                                        ...temp2.sublist(changeIndex),
                                                        ...temp2.sublist(0, changeIndex)
                                                      ];
                                                      scheduleViewProvider.convertedList = [...head, ...temp3, ...tail];
                                                    });
                                                    Navigator.of(context).pop();
                                                    scheduleViewProvider.changeToValue = "";
                                                    scheduleViewProvider.selectedRtc = "";
                                                    scheduleViewProvider.selectedCycle = "";
                                                    scheduleViewProvider.selectedZone = "";
                                                  },
                                                  child: const Text("Save")
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    stateSetter(() {
                                                      scheduleViewProvider.changeToValue = "";
                                                      scheduleViewProvider.selectedRtc = "";
                                                      scheduleViewProvider.selectedCycle = "";
                                                      scheduleViewProvider.selectedZone = "";
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")
                                              )
                                            ],
                                          );
                                        }
                                    );
                                  }
                              );
                            },
                            icon: Icon(Icons.change_circle),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // const SizedBox(height: 10,),
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: scheduleViewProvider.programList.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Row(
                      children: [
                        ChoiceChip(
                          label: Text(scheduleViewProvider.programList[i], style: TextStyle(color: scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.programList[i]) ? Colors.white : Colors.black),),
                          selected: scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.programList[i]),
                          side: BorderSide.none,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          checkmarkColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor,
                          color: MaterialStatePropertyAll(scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.programList[i]) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                          onSelected: (newValue) {
                            setState(() {
                              if (scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.programList[i])) {
                                scheduleViewProvider.selectedProgramList.remove(scheduleViewProvider.programList[i]);
                              } else {
                                scheduleViewProvider.selectedProgramList.add(scheduleViewProvider.programList[i]);
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 20,)
                      ],
                    );
                  }
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(child: _buildScheduleView(context: context,),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _animationController,
                child: const Icon(Icons.hourglass_bottom, size: 50),
              ),
              const SizedBox(height: 16.0),
              FadeTransition(
                opacity: _animationController,
                child: const Text("Fetching data..."),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: scheduleViewProvider.scheduleList.isNotEmpty && (scheduleDateWithoutTime.isAfter(todayWithoutTime) || scheduleDateWithoutTime.isAtSameMomentAs(todayWithoutTime)) ?
      MaterialButton(
        color: const Color(0xFFFFCB3A),
        splashColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        ),
        onPressed: scheduleViewProvider.scheduleGotFromMqtt ? () async {
          // var
          var listToMqtt = [];
          for (var i = 0; i < scheduleViewProvider.convertedList.length; i++) {
            String scheduleMap = ""
                "${scheduleViewProvider.convertedList[i]["S_No"]},"
                "${scheduleViewProvider.scheduleList["ScheduleOrder"][i]},"
                "${scheduleViewProvider.convertedList[i]["ScaleFactor"]},"
                "${scheduleViewProvider.convertedList[i]["SkipFlag"]},"
                "${scheduleViewProvider.convertedList[i]["Date"]},"
                "${scheduleViewProvider.convertedList[i]["ProgramCategory"]},"
                "${scheduleViewProvider.convertedList[i]["CentralFilterOnOff"]},"
                "${scheduleViewProvider.convertedList[i]["LocalFilterOnOff"]},"
                "${scheduleViewProvider.convertedList[i]["CentralFilterSelection"]},"
                "${scheduleViewProvider.convertedList[i]["LocalFilterSelection"]},"
                "${scheduleViewProvider.convertedList[i]["CentralFertOnOff"]},"
                "${scheduleViewProvider.convertedList[i]["LocalFertOnOff"]},"
                "${scheduleViewProvider.convertedList[i]["CentralFertChannelSelection"]},"
                "${scheduleViewProvider.convertedList[i]["LocalFertChannelSelection"]}"
                "";
            listToMqtt.add(scheduleMap);
          }
          var dataToHardware = {
            "2700": [{
              "2701": "${listToMqtt.join(";").toString()};"
            }]
          };
          var userData = {
            "userId": overAllPvd.userId,
            "controllerId": overAllPvd.controllerId,
            "modifyUser": overAllPvd.customerId,
            "sequence": scheduleViewProvider.convertedList,
            "scheduleDate": DateFormat('yyyy-MM-dd').format(scheduleViewProvider.date),
            "hardware": dataToHardware
          };
          try {
            var mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
            validatePayloadSent(
                dialogContext: context,
                context: context,
                mqttPayloadProvider: mqttPayloadProvider,
                acknowledgedFunction: () async{
                  final updateUserSequencePriority = await httpService.postRequest('updateUserSequencePriority', userData);
                  final response = jsonDecode(updateUserSequencePriority.body);
                  if(updateUserSequencePriority.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                  }
                  scheduleViewProvider.fetchData(overAllPvd.imeiNo, overAllPvd.userId, overAllPvd.controllerId, context);
                  scheduleViewProvider.updateSelectedProgramCategory(0);
                },
                payload: dataToHardware,
                payloadCode: "2700",
                deviceId: '${overAllPvd.imeiNo}'
            );
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
            log("Error: $error");
          }
        } : null,
        child: const Text("Send", style: TextStyle(fontWeight: FontWeight.bold)),
      )
          : Container(),
    );
  }

  Widget _buildScheduleView({required BuildContext context,}) {
    return scheduleViewProvider.convertedList.isNotEmpty
        ? !(scheduleViewProvider.selectedStatusList.isNotEmpty
        && (scheduleViewProvider.selectedStatusList[0] == scheduleViewProvider.statusList[0])
        && scheduleViewProvider.selectedStatusList.length == 1)
        ? ListView.builder(
      itemCount: scheduleViewProvider.convertedList.length,
      itemBuilder: (BuildContext context, int index) {
        final status = scheduleViewProvider.getStatusInfo(scheduleViewProvider.convertedList[index]["Status"].toString());
        final condition = scheduleViewProvider.selectedStatusList.isNotEmpty ? status.selectedStatus : true;
        final programCondition = scheduleViewProvider.selectedProgramList.isNotEmpty
            ? scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.convertedList[index]["ProgramName"])
            : true;
        final rtcCondition = scheduleViewProvider.selectedRtc.isNotEmpty
            ? int.parse(scheduleViewProvider.selectedRtc) == scheduleViewProvider.convertedList[index]["RtcNumber"]
            : true;
        final cycleCondition = scheduleViewProvider.selectedCycle.isNotEmpty
            ? int.parse(scheduleViewProvider.selectedCycle) == scheduleViewProvider.convertedList[index]["CycleNumber"]
            : true;
        return buildScheduleColumn(condition: rtcCondition && cycleCondition && programCondition && (condition ?? true), context: context, index: index);
      },
    )
        : ReorderableListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final status = scheduleViewProvider.getStatusInfo(scheduleViewProvider.convertedList[index]["Status"].toString());
          final condition = scheduleViewProvider.selectedStatusList.isNotEmpty ? status.selectedStatus : true;
          final programCondition = scheduleViewProvider.selectedProgramList.isNotEmpty
              ? scheduleViewProvider.selectedProgramList.contains(scheduleViewProvider.convertedList[index]["ProgramName"])
              : true;
          final rtcCondition = scheduleViewProvider.selectedRtc.isNotEmpty
              ? int.parse(scheduleViewProvider.selectedRtc) == scheduleViewProvider.convertedList[index]["RtcNumber"]
              : true;
          final cycleCondition = scheduleViewProvider.selectedCycle.isNotEmpty
              ? int.parse(scheduleViewProvider.selectedCycle) == scheduleViewProvider.convertedList[index]["CycleNumber"]
              : true;
          return ReorderableDragStartListener(
              key: ObjectKey(scheduleViewProvider.convertedList[index]['S_No']),
              index: index,
              child: buildScheduleColumn(condition: rtcCondition && cycleCondition && programCondition && (condition ?? true), context: context, index: index));
        },
        itemCount: scheduleViewProvider.convertedList.length,
        buildDefaultDragHandles: false,
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          // final scheduleOrder = scheduleViewProvider.convertedList.where((element) => element["ScheduleOrder"]);
          final item = scheduleViewProvider.convertedList.removeAt(oldIndex);
          scheduleViewProvider.convertedList.insert(newIndex, item);
        }
    )
        : Center(child: Text(scheduleViewProvider.scheduleGotFromMqtt ? "Schedule not found": scheduleViewProvider.messageFromHttp));
  }

  Widget buildActionRow() {
    return Row(
      children: [
        buildActionButton(
            context: context,
            key: "filter",
            // buttonColor: const Color(0xffFDC748),
            borderRadius: BorderRadius.circular(5),
            icon: Icons.filter_alt_outlined,
            label: "Filter",
            onPressed: () {
              showAdaptiveDialog(
                context: context,
                builder: (BuildContext context) {
                  List<String> tempSelectionList = List.from(scheduleViewProvider.selectedStatusList);

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter stateSetter) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < scheduleViewProvider.statusList.length; i++)
                              CheckboxListTile(
                                title: Text(scheduleViewProvider.statusList[i]),
                                value: tempSelectionList.contains(scheduleViewProvider.statusList[i]),
                                onChanged: (newValue) {
                                  stateSetter(() {
                                    if (tempSelectionList.contains(scheduleViewProvider.statusList[i])) {
                                      tempSelectionList.remove(scheduleViewProvider.statusList[i]);
                                    } else {
                                      tempSelectionList.add(scheduleViewProvider.statusList[i]);
                                    }
                                  });
                                  setState((){});
                                },
                              )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () {
                              stateSetter(() {
                                scheduleViewProvider.selectedStatusList = List.from(tempSelectionList);
                                setState((){});
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Apply"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
        ),
        // const SizedBox(width: 10,),
        // buildActionButton(
        //     context: context,
        //     key: "refresh",
        //     // buttonColor: const Color(0xffFDC748),
        //     borderRadius: BorderRadius.circular(5),
        //     icon: Icons.refresh,
        //     label: "Refresh",
        //     onPressed: () {
        //       scheduleViewProvider.fetchDataAfterDelay(widget.deviceId, widget.userId, widget.controllerId, context);
        //     }
        // ),
        // const SizedBox(width: 10,),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Icon(Icons.info, color: scheduleViewProvider.isFetchingCompleted
        //         ? scheduleViewProvider.scheduleGotFromMqtt
        //         ? Theme.of(context).primaryColor : const Color(0xffFDC748) : Colors.red),
        //     const SizedBox(width: 10,),
        //     // Text(
        //     //   scheduleViewProvider.isFetchingCompleted ? scheduleViewProvider.scheduleGotFromMqtt ? "Fetched from mqtt" : "Fetched from http" : "Can not fetch",
        //     //   style: TextStyle(
        //     //       color: scheduleViewProvider.isFetchingCompleted
        //     //           ? scheduleViewProvider.scheduleGotFromMqtt
        //     //           ? Theme.of(context).primaryColor : const Color(0xffFDC748) : Colors.red,
        //     //       fontWeight: FontWeight.bold),
        //     // ),
        //   ],
        // ),
      ],
    );
  }

  Widget buildScheduleColumn({required BuildContext context, required int index, required bool condition}) {
    return Column(
      children: [
        TimeLine(
          itemGap: 0,
          padding: const EdgeInsets.symmetric(vertical: 0),
          indicators: [
            buildTimeLineIndicators(
                context: context,
                index: index,
                // constraints: constraints,
                condition: condition
            )
          ],
          children: [
            buildScheduleList(
                context: context,
                index: index,
                // constraints: constraints,
                condition: condition
            )
          ],
        ),
        if(index == scheduleViewProvider.convertedList.length - 1)
          const SizedBox(height: 50,)
      ],
    );
  }

  Widget buildTimeLineIndicators({context, index, condition}) {
    final scheduleItem = scheduleViewProvider.convertedList[index];
    var status = scheduleViewProvider.getStatusInfo(scheduleItem["Status"].toString());
    // print(scheduleViewProvider.programCategories);
    if(scheduleViewProvider.programCategories.isNotEmpty && scheduleItem.isNotEmpty && scheduleItem["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory]) {
      if(condition) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, color: Theme.of(context).primaryColor,),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: status.color,
                ),
              ),
            )
          ],
        );
      } else {
        return Container(height: 0,);
      }
    } else {
      return Container(height: 0,);
    }
  }

  Widget buildScheduleList({context, index, constraints, condition}) {
    final scheduleItem = scheduleViewProvider.convertedList[index];
    var method = scheduleItem["IrrigationMethod"].toString();
    var inputValue = scheduleItem["IrrigationDuration_Quantity"].toString();
    var completedValue = method == "1"
        ? scheduleItem["IrrigationDurationCompleted"].toString()
        : scheduleItem["IrrigationQuantityCompleted"].toString();
    var pumps = scheduleItem['Pump'];
    var mainValves = scheduleItem['MainValve'];
    var valves = scheduleItem['SequenceData'];
    var startTime = scheduleItem["ScheduledStartTime"].toString();
    var toLeftDuration;
    var progressValue;
    if (method == "1") {
      List<String> inputTimeParts = inputValue.split(':');
      int inHours = int.parse(inputTimeParts[0]);
      int inMinutes = int.parse(inputTimeParts[1]);
      int inSeconds = int.parse(inputTimeParts[2]);

      List<String> timeComponents = completedValue.split(':');
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      Duration inDuration = Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
      Duration completedDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);

      toLeftDuration = (inDuration - completedDuration).toString().substring(0,7);
      progressValue = completedDuration.inMilliseconds / inDuration.inMilliseconds;
    } else {
      progressValue = int.parse(completedValue) / int.parse(inputValue);
      toLeftDuration = int.parse(inputValue) - int.parse(completedValue);
    }

    // DateTime scheduleDate = DateTime.parse(scheduleItem["Date"]);
    // DateTime today = DateTime.now();
    //
    // DateTime scheduleDateWithoutTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    // DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    DateFormat format24 = DateFormat("HH:mm:ss");
    DateTime time = format24.parse(startTime);

    DateFormat format12 = DateFormat("hh:mm a");
    String time12 = format12.format(time);

    var status = scheduleViewProvider.getStatusInfo(scheduleItem["Status"].toString());
    var reason = scheduleViewProvider.getStatusInfo(scheduleItem["ProgramStartStopReason"].toString());
    final screenSize = MediaQuery.of(context).size.width;
    if(scheduleViewProvider.programCategories.isNotEmpty && scheduleItem.isNotEmpty && scheduleItem["ProgramCategory"] == scheduleViewProvider.programCategories[scheduleViewProvider.selectedProgramCategory]) {
      if(condition) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startTime, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              surfaceTintColor: Colors.white,
              color: Colors.white,
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    // border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                                    // color: Colors.white,
                                    gradient: linearGradientLeading
                                ),
                                child: Center(
                                    child: Text(
                                      scheduleItem["ScheduleOrder"].toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ))),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: screenSize > 500 ? 2 : 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  scheduleItem["ProgramName"],
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                ),
                                Text(scheduleItem["ZoneName"], style: const TextStyle(fontWeight: FontWeight.bold),),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        status.statusString,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                if(screenSize < 500)
                                  MouseRegion(
                                    onHover: (onHover) {},
                                    child: Tooltip(
                                      message: completedValue,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border:
                                              Border.all(width: 0.3, color: Colors.black),
                                              borderRadius: BorderRadius.circular(10)),
                                          child: LinearProgressIndicator(
                                            value: progressValue.clamp(0.0, 1.0),
                                            backgroundColor: Colors.grey[300],
                                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                            minHeight: 10,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 80,
                          ),
                          if(screenSize > 500)
                            Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pumps.split('_').join(', ').toString()),
                                    const Text("Pumps", style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),)
                                  ],
                                )),
                          if(screenSize > 500)
                            const SizedBox(
                              width: 30,
                            ),
                          if(screenSize > 500)
                            Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: "RTC : ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: scheduleItem['RtcNumber'].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: "Cycle : ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: scheduleItem['CycleNumber'].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          if(screenSize > 500)
                            const SizedBox(
                              width: 30,
                            ),
                          if(screenSize > 500)
                            Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(valves.split('_').join(', ').toString()),
                                    const Text("Valves", style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),)
                                  ],
                                )),
                          if(screenSize > 500)
                            const SizedBox(
                                width: 30
                            ),
                          if(screenSize > 500)
                            Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(scheduleItem["ScaleFactor"].toString()),
                                    const Text("Scale Factor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),)
                                  ],
                                )),
                          if(screenSize > 500)
                            const SizedBox(
                              width: 10,
                            ),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: screenSize > 600
                                    ? TextButton(
                                    onPressed: (
                                        (status.statusCode == "0" || status.statusCode == "1" || status.statusCode == "4" || status.statusCode == "5")
                                            && (scheduleDateWithoutTime.isAfter(todayWithoutTime) || scheduleDateWithoutTime.isAtSameMomentAs(todayWithoutTime))) ?
                                        (){
                                      setState(() {
                                        scheduleItem["SkipFlag"] = scheduleItem["SkipFlag"] == 0 ? 1 : 0;
                                      });
                                    } : null,
                                    child: Text(scheduleItem["SkipFlag"] == 0 ? "Skip" : "Un skip"))
                                    : IconButton(
                                    onPressed: (
                                        (status.statusCode == "0" || status.statusCode == "1" || status.statusCode == "4" || status.statusCode == "5")
                                            && (scheduleDateWithoutTime.isAfter(todayWithoutTime) || scheduleDateWithoutTime.isAtSameMomentAs(todayWithoutTime))) ?
                                        (){
                                      setState(() {
                                        scheduleItem["SkipFlag"] = scheduleItem["SkipFlag"] == 0 ? 1 : 0;
                                      });
                                    } : null,
                                    icon: Icon(scheduleItem["SkipFlag"] == 0 ? Icons.skip_next : Icons.undo)),
                              )),
                          const SizedBox(width: 10,),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: IconButton(
                                    tooltip: "Edit",
                                    onPressed: (
                                        (status.statusCode == "0" || status.statusCode == "1" || status.statusCode == "4" || status.statusCode == "5")
                                            && (scheduleDateWithoutTime.isAfter(todayWithoutTime) || scheduleDateWithoutTime.isAtSameMomentAs(todayWithoutTime))) ?
                                        () {
                                      sideSheet(scheduleItem, constraints, index);
                                    } : null,
                                    icon: const Icon(Icons.edit)),
                              )
                          ),
                          if(screenSize < 500)
                            const SizedBox(
                              width: 10,
                            ),
                          if(screenSize < 500)
                            Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                      tooltip: "more",
                                      onPressed: (){
                                        showScheduleDetails(
                                            context: context,
                                            index: index
                                        );
                                      },
                                      icon: const Icon(Icons.more_vert)),
                                )
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      } else {
        return Container(height: 0);
      }
    } else {
      return Container(height: 0);
    }
  }

  void showScheduleDetails({required BuildContext context, index}) {
    final scheduleItem = scheduleViewProvider.convertedList[index];
    var method = scheduleItem["IrrigationMethod"].toString();
    var inputValue = scheduleItem["IrrigationDuration_Quantity"].toString();
    var completedValue = method == "1"
        ? scheduleItem["IrrigationDurationCompleted"].toString()
        : scheduleItem["IrrigationQuantityCompleted"].toString();
    var pumps = scheduleItem['Pump'];
    var mainValves = scheduleItem['MainValve'];
    var valves = scheduleItem['SequenceData'];
    var startTime = scheduleItem["ScheduledStartTime"].toString();
    var toLeftDuration;
    var progressValue;
    if (method == "1") {
      List<String> inputTimeParts = inputValue.split(':');
      int inHours = int.parse(inputTimeParts[0]);
      int inMinutes = int.parse(inputTimeParts[1]);
      int inSeconds = int.parse(inputTimeParts[2]);

      List<String> timeComponents = completedValue.split(':');
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      Duration inDuration = Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
      Duration completedDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);

      toLeftDuration = (inDuration - completedDuration).toString().substring(0,7);
      progressValue = completedDuration.inMilliseconds / inDuration.inMilliseconds;
    } else {
      progressValue = int.parse(completedValue) / int.parse(inputValue);
      toLeftDuration = int.parse(inputValue) - int.parse(completedValue);
    }

    DateTime scheduleDate = DateTime.parse(scheduleItem["Date"]);
    DateTime today = DateTime.now();

    DateTime scheduleDateWithoutTime = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);
    final screenSize = MediaQuery.of(context).size.width;
    var status = scheduleViewProvider.getStatusInfo(scheduleItem["Status"].toString());
    showModalBottomSheet(
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: MediaQuery.of(context).size.width > 1200 ? const EdgeInsets.all(10) : const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Completed: $completedValue",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "Actual: $inputValue",
                                style: const TextStyle(fontSize: 12,),
                              ),
                              Text(
                                "To left: $toLeftDuration",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: MediaQuery.of(context).size.width > 1200 ? const EdgeInsets.all(10) : const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Pumps"),
                            Text(pumps.split('_').join(', ').toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: MediaQuery.of(context).size.width > 1200 ? const EdgeInsets.all(10) : const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Main valves"),
                            Text(mainValves.split('_').join(', ').toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: MediaQuery.of(context).size.width > 1200 ? const EdgeInsets.all(10) : const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Valves"),
                            Text(valves.split('_').join(', ').toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50,),
              ],
            ),
          );
        }
    );
  }

  void sideSheet(scheduleItem, constraints, index) {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      // barrierColor: const Color(0xff6600),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                  // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.zero,
                  ),
                  height: double.infinity,
                  // width: constraints.maxWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Scale Factor"),
                            IntrinsicWidth(
                              child: TextFormField(
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                initialValue: scheduleItem["ScaleFactor"].toString(),
                                decoration: const InputDecoration(
                                    suffixText: "%"
                                ),
                                onChanged: (newValue){
                                  setState(() {
                                    scheduleItem["ScaleFactor"] = newValue != '' ? newValue : scheduleItem["ScaleFactor"];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                        if(scheduleItem['CentralFertilizerSiteName'] != "")
                          Column(
                            children: [
                              buildSwitch(context: context, index: index, itemName: "CentralFertOnOff", title: scheduleItem['CentralFertilizerSiteName'], stateSetter: stateSetter, scheduleItem: scheduleItem),
                              const SizedBox(height: 10,),
                              buildCheckBoxList(scheduleItem: scheduleItem, item: "CentralFertChannelSelection", name: "CentralFertChannelName", stateSetter: stateSetter, condition: scheduleItem["CentralFertOnOff"] != 0, index: index),
                              Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                            ],
                          ),
                        if(scheduleItem['LocalFertilizerSiteName'] != "")
                          Column(
                            children: [
                              buildSwitch(context: context, index: index, itemName: "LocalFertOnOff", title: scheduleItem['LocalFertilizerSiteName'], stateSetter: stateSetter, scheduleItem: scheduleItem),
                              const SizedBox(height: 10,),
                              buildCheckBoxList(scheduleItem: scheduleItem, item: "LocalFertChannelSelection", name: "LocalFertChannelName", stateSetter: stateSetter, condition: scheduleItem["LocalFertOnOff"] != 0, index: index),
                              Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                            ],
                          ),
                        if(scheduleItem['CentralFilterSiteName'] != "")
                          Column(
                            children: [
                              buildSwitch(context: context, index: index, itemName: "CentralFilterOnOff", title: scheduleItem['CentralFilterSiteName'], stateSetter: stateSetter, scheduleItem: scheduleItem),
                              const SizedBox(height: 10,),
                              buildCheckBoxList(scheduleItem: scheduleItem, item: "CentralFilterSelection", name: "CentralFilterName", stateSetter: stateSetter, condition: scheduleItem["CentralFilterOnOff"] != 0, index: index),
                              Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                            ],
                          ),
                        if(scheduleItem['LocalFilterSiteName'] != "")
                          Column(
                            children: [
                              buildSwitch(context: context, index: index, itemName: "LocalFilterOnOff", title: scheduleItem['LocalFilterSiteName'], stateSetter: stateSetter, scheduleItem: scheduleItem),
                              const SizedBox(height: 10,),
                              buildCheckBoxList(scheduleItem: scheduleItem, item: "LocalFilterSelection", name: "LocalFilterName", stateSetter: stateSetter, condition: scheduleItem["LocalFilterOnOff"] != 0, index: index),
                              Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                            ],
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget buildSwitch({
    required BuildContext context, required int index, required String itemName,
    required String title, required stateSetter, required scheduleItem}) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Switch(
            value: scheduleItem[itemName] == 1,
            onChanged: (newValue) {
              stateSetter(() {
                if(scheduleItem[itemName] == 1) {
                  scheduleItem[itemName] = 0;
                } else {
                  scheduleItem[itemName] = 1;
                }
              });
            },
          )
        ],
      ),
    );
  }

  Widget buildCheckBoxList({scheduleItem, item, name, stateSetter, condition, index}) {
    ScrollController localScrollController = ScrollController();
    return CustomAnimatedSwitcher(
      condition: condition,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          scheduleItem[name].split("_").length,
              (int itemIndex) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${scheduleItem[name].split("_")[itemIndex]}"),
                Checkbox(
                  value: scheduleItem[item].split("_")[itemIndex] == "1" ? true : false,
                  onChanged: (newValue) {
                    stateSetter(() {
                      List<String> channelSelectionList = scheduleItem[item].split("_");
                      channelSelectionList[itemIndex] = channelSelectionList[itemIndex] == "1" ? "0" : "1";
                      scheduleItem[item] = channelSelectionList.join("_");
                    });
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class StatusInfo {
  final Color color;
  final String statusString;
  final String reason;
  final IconData? icon;
  final String? statusCode;
  final bool? selectedStatus;

  StatusInfo(this.color, this.statusString, this.icon, this.statusCode, this.selectedStatus, this.reason);
}

Widget buildCustomSideMenuBar(
    {required BuildContext context, required String title, required BoxConstraints constraints, required List<Widget> children, Widget? bottomChild}) {
  return Container(
    width: constraints.maxWidth * 0.15,
    decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff1C7C8A),
            Color(0xff03464F)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          tileMode: TileMode.clamp,
        )
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const BackButton(color: Colors.white,),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...children
            ],
          ),
          bottomChild ?? Container()
        ],
      ),
    ),
  );
}

Widget buildSideBarMenuList(
    {required BuildContext context, BoxConstraints? constraints, required dataList,
      required String title, required index, icons, required bool selected, required void Function(int) onTap, Widget? child}) {
  return Material(
    type: MaterialType.transparency,
    child: MediaQuery.of(context).size.width > 600 ?
    ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 600 ? 12 : 25)
        ),
        title: child ?? Text(title, style: TextStyle(color: selected ? MediaQuery.of(context).size.width > 600 ? Colors.white : Colors.white : Theme.of(context).primaryColor),),
        leading: icons != null ? Icon(icons[index], color: Colors.white,) : null,
        selected: selected,
        onTap: () {
          onTap(index);
        },
        selectedTileColor: selected ? const Color(0xff2999A9)  : null,
        hoverColor: selected ? const Color(0xff2999A9) : null
    ) :
    InkWell(
        onTap: () {
          onTap(index);
        },
        // borderRadius: BorderRadius.circular(20),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.symmetric(horizontal: child == null ? 20: 10, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // boxShadow: customBoxShadow2,
                gradient: selected ? linearGradientLeading : null,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                color: selected ? Theme.of(context).primaryColor : Color(0xffF2F2F2)
            ),
            child: Center(
                child: child ?? Text(title, style: TextStyle(color: selected ? Colors.white : Theme.of(context).primaryColor),)
            )
        )
    ),
  );
}

Widget buildActionButton(
    {required BuildContext context, required String key, required IconData icon, required String label,
      required VoidCallback onPressed, Color? buttonColor, Color? labelColor, BorderRadius? borderRadius}) {
  return IconButton(
    key: Key(key),
    onPressed: onPressed,
    // color: buttonColor ?? Colors.white,
    // elevation: 1,
    // shape: RoundedRectangleBorder(
    //     borderRadius: borderRadius ?? BorderRadius.circular(15)
    // ),
    icon: Icon(icon, color: labelColor,),
  );
}