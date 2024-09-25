import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/preview_screen.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../widget/SCustomWidgets/custom_animated_switcher.dart';
import '../../../../widget/SCustomWidgets/custom_data_table.dart';
import '../../../../widget/SCustomWidgets/custom_date_picker.dart';
import '../../../../widget/SCustomWidgets/custom_drop_down.dart';
import '../../../../widget/SCustomWidgets/custom_list_tile.dart';
import '../../../../widget/SCustomWidgets/custom_native_time_picker.dart';
import '../../ScheduleView.dart';
import 'conditions_screen.dart';
import 'irrigation_program_main.dart';
final lightColor1 = const Color(0xffD6EDFC);
final darkColor1 = const Color(0xff39a4fc);
final lightColor2 = const Color(0xffF9DEFB);
final darkColor2 = const Color(0xfff569fc);
final lightColor3 = const Color(0xffE3DAFF);
final darkColor3 = const Color(0xff7452ff);
final lightColor4 = const Color(0xffE3DAFF);
final darkColor4 = const Color(0xff8054fd);
final color5 = const Color(0xffFFF6ED);
final cardColor = const Color(0xffE7F0F2);
final dateFormat = DateFormat('dd-MM-yyyy');
class ScheduleScreen extends StatefulWidget {
  final int serialNumber;
  const ScheduleScreen({super.key, required this.serialNumber});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late IrrigationProgramMainProvider irrigationProgramProvider;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController pageController = PageController();
  String tempNoOfDays = '';
  final iconList = [Icons.playlist_remove_rounded, Icons.timer, Icons.water_drop, Icons.local_florist];

  @override
  void initState() {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      irrigationProgramProvider.updateCurrentRtcIndex(0);
    });
    super.initState();
  }

  void addTab(rtcType) {
    setState(() {
      if (rtcType.length < 6) {
        rtcType.addAll({
          "rtc${rtcType.length + 1}": {"onTime": "00:00:00", "offTime": "00:00:00", "interval": "00:00:00", "noOfCycles": "1", "maxTime": "00:00:00", "condition": false, "stopMethod": "Continuous"}
        });
        if(MediaQuery.of(context).size.width < 800) {
          pageController.animateToPage(
          rtcType.length - 1,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.bounceOut,
        );
        }
      } else {
        showAdaptiveDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("Cannot add more than 6 RTC's"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text("OK"))
              ],
            );
          },
        );
      }
    });
  }

  void deleteTab(rtcType) {
    if(rtcType.length != 1) {
      setState(() {
        rtcType.length > 1 ? rtcType.remove(rtcType.keys.last) : null;
      });
      pageController.animateToPage(
        rtcType.length - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Number of RTC's should be at least 1"),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: true);
    final noScheduleCondition = irrigationProgramProvider.selectedScheduleType != irrigationProgramProvider.scheduleTypes[0]
        && irrigationProgramProvider.selectedScheduleType != irrigationProgramProvider.scheduleTypes[3];
    final rtcType = irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[1]
        ? irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList
        : irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[2]
        ? irrigationProgramProvider.sampleScheduleModel!.scheduleByDays
        : irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList;
    final functionCondition = irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[1]
        ? irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList.rtc
        : irrigationProgramProvider.sampleScheduleModel!.scheduleByDays.rtc;
    final allowStopMethodCondition = irrigationProgramProvider.sampleScheduleModel!.defaultModel.allowStopMethod;
    final defaultOffTime = irrigationProgramProvider.sampleScheduleModel!.defaultModel.rtcOffTime;
    final defaultMaxTime = irrigationProgramProvider.sampleScheduleModel!.defaultModel.rtcMaxTime;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.025),
              child: Column(
                children: [
                  //Change Rtc Type button
                  if(MediaQuery.of(context).size.width < 800)
                    buildPopUpMenuButton(
                      context: context,
                      dataList: irrigationProgramProvider.scheduleTypes,
                      onSelected: (selectedValue) => irrigationProgramProvider.updateSelectedScheduleType(selectedValue),
                      offset: const Offset(0, 70),
                      child:  Card(
                        child: buildListTile(
                          context: context,
                          title: irrigationProgramProvider.selectedScheduleType,
                          subTitle: "Select schedule type",
                          icon: Icons.schedule,
                          color: cardColor,
                          isNeedBoxShadow: false,
                          trailing: SizedBox(
                              width: 40,
                              child: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor)
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(irrigationProgramProvider.selectedScheduleType,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                        ),
                        buildPopUpMenuButton(
                            context: context,
                            dataList: irrigationProgramProvider.scheduleTypes,
                            onSelected: (selectedValue) => irrigationProgramProvider.updateSelectedScheduleType(selectedValue),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).primaryColor
                                // border: Border.all(color: Colors.grey)
                              ),
                              child: const Row(
                                children: [
                                  Text("Change schedule type", style: TextStyle(color: Colors.white),),
                                  SizedBox(width: 5,),
                                  Icon(Icons.edit, color: Colors.white,)
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  const SizedBox(height: 10,),
                  //RTC and Schedule details
                  CustomAnimatedSwitcher(
                    condition: noScheduleCondition,
                    child: Column(
                      children: [
                        /*Rtc Details table*/
                        for(var i = 0; i < 2; i++)
                          CustomAnimatedSwitcher(
                            condition: [
                              irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[1],
                              irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[2],
                            ][i],
                            child: MediaQuery.of(context).size.width > 800 ?
                            buildRtcDetails(
                                functionCondition: functionCondition,
                                constraints: constraints,
                                rtcType: rtcType,
                                context: context,
                                allowStopMethodCondition: allowStopMethodCondition,
                                defaultOffTime: defaultOffTime,
                                defaultMaxTime: defaultMaxTime
                            ) : buildRtcDetailsForMobile(
                                functionCondition: functionCondition,
                                constraints: constraints,
                                rtcType: rtcType,
                                context: context,
                                allowStopMethodCondition: allowStopMethodCondition,
                                defaultOffTime: defaultOffTime,
                                defaultMaxTime: defaultMaxTime,
                                pageController: pageController
                            ),
                          ),
                        const SizedBox(height: 10,),
                        if(noScheduleCondition)
                          CustomAnimatedSwitcher(
                              condition: irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[1],
                              child: buildScheduleList(context: context, constraints: constraints, noScheduleType: noScheduleCondition)
                          ),
                        if(noScheduleCondition)
                          CustomAnimatedSwitcher(
                              condition: irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[2],
                              child: buildScheduleList(context: context, constraints: constraints, noScheduleType: noScheduleCondition)
                          ),
                        const SizedBox(height: 50,),
                      ],
                    ),
                  ),
                  CustomAnimatedSwitcher(
                    condition: irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[3],
                    child: buildNewScheduleType(context: context),
                  ),
                  const SizedBox(height: 50,),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget buildNewScheduleType({required BuildContext context}) {
    final dayCountSchedule = irrigationProgramProvider.sampleScheduleModel!.dayCountSchedule.schedule;

    Widget buildOnTime() {
      return buildCustomListTile(
        context: context,
        title: "On Time",
        isTimePicker: true,
        initialValue: dayCountSchedule["onTime"],
        onTimeChanged: (newValue) => irrigationProgramProvider.updateDayCountSchedule(property: "onTime", newValue: newValue),
        icon: Icons.timer,
      );
    }

    Widget buildInterval() {
      return buildCustomListTile(
        context: context,
        title: "Interval",
        isTimePicker: true,
        initialValue: dayCountSchedule["interval"],
        onTimeChanged: (newValue) => irrigationProgramProvider.updateDayCountSchedule(property: "interval", newValue: newValue),
        icon: Icons.timer,
      );
    }

    Widget buildCheckBox() {
      return buildCustomListTile(
        context: context,
        title: "Should limit the cycle",
        isCheckBox: true,
        checkBoxValue: dayCountSchedule["shouldLimitCycles"],
        onCheckBoxChanged: (newValue) => irrigationProgramProvider.updateDayCountSchedule(property: "shouldLimitCycles", newValue: newValue),
        icon: Icons.event_repeat,
      );
    }

    Widget buildNumberOfCycles() {
      return buildCustomListTile(
        context: context,
        title: "No. of cycles",
        isTextForm: true,
        initialValue: dayCountSchedule["noOfCycles"],
        onChanged: (newValue) => irrigationProgramProvider.updateDayCountSchedule(property: "noOfCycles", newValue: newValue),
        icon: Icons.repeat,
      );
    }
    return MediaQuery.of(context).size.width > 1200
        ? Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildOnTime(),
            ),
            const SizedBox(width: 20,),
            Expanded(
              child: buildInterval(),
            ),
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            Expanded(
              child: buildCheckBox(),
            ),
            const SizedBox(width: 20,),
            Expanded(
              child: CustomAnimatedSwitcher(
                condition: dayCountSchedule["shouldLimitCycles"],
                child: buildNumberOfCycles(),
              ),
            ),
          ],
        ),
      ],
    )
        : Column(
      children: [
        buildOnTime(),
        const SizedBox(height: 20,),
        buildInterval(),
        const SizedBox(height: 20,),
        buildCheckBox(),
        const SizedBox(height: 20,),
        CustomAnimatedSwitcher(
          condition: dayCountSchedule["shouldLimitCycles"],
          child: buildNumberOfCycles(),
        ),
      ],
    );
  }

  Widget buildScheduleList({required BuildContext context, required BoxConstraints constraints, required bool noScheduleType}) {
    final scheduleType = irrigationProgramProvider.selectedScheduleType;
    final schedule = scheduleType == irrigationProgramProvider.scheduleTypes[1]
        ? irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList.schedule
        : irrigationProgramProvider.sampleScheduleModel!.scheduleByDays.schedule;

    var startDate = irrigationProgramProvider.startDate(serialNumber: widget.serialNumber);
    var endDate = DateTime.parse(schedule['endDate']).isBefore(DateTime.parse(startDate))
        ? DateTime.now().toString() :(schedule['endDate'] ?? DateTime.now().toString());
    final isForceToEndDate = schedule['isForceToEndDate'] ?? false;
    var noOfDays = ((schedule['noOfDays'] == "" || schedule['noOfDays'] == "0") ? "1": schedule['noOfDays']) ?? '1';
    final runDays = ((schedule['runDays'] == "" || schedule['runDays'] == "0") ? "1": schedule['runDays']) ?? '1';
    final runListLimit = irrigationProgramProvider.sampleScheduleModel?.defaultModel.runListLimit ?? 0;
    final skipDays = schedule['skipDays'] ?? '0';
    final dateRange = (DateTime.parse(endDate).difference(DateTime.parse(startDate))).inDays;
    // final firstDate = DateTime.parse(startDate).add(Duration(days: (scheduleType == irrigationProgramProvider.scheduleTypes[1] ? int.parse(noOfDays) : 0)
    //     + int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0") - (irrigationProgramProvider.selectedScheduleType == irrigationProgramProvider.scheduleTypes[1] ? 2 : 1)));
    final firstDate = DateTime.parse(startDate).add(
        Duration(days:
        (scheduleType == irrigationProgramProvider.scheduleTypes[1]
            ? (int.parse(noOfDays) -1)
            : int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0")
        )));
    // endDate = dateRange < (scheduleType == irrigationProgramProvider.scheduleTypes[1] ? int.parse(noOfDays) : 0)
    //     + int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0")
    //     ? firstDate
    //     : DateTime.parse(endDate);

    endDate = dateRange <
        (scheduleType == irrigationProgramProvider.scheduleTypes[1]
            ? (int.parse(noOfDays) -1)
            : int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0"))
        ? firstDate
        : DateTime.parse(endDate);

    List<String> days = List.generate(int.parse(noOfDays != '' ? noOfDays : '0'), (index) => 'DAY ${index + 1}');
    var type = schedule['type'];

    // print("endDate ==> ${endDate.runtimeType}");
    // print("startDate ==> ${startDate}");
    // print("startDate ==> ${schedule['endDate'].runtimeType}");
    // print("dateRange ==> ${dateRange}");
    schedule['endDate'] = endDate.toString();
    return Column(
      children: [
        if(MediaQuery.of(context).size.width >= 800)
          Row(
            children: [
              Checkbox(
                value: isForceToEndDate,
                onChanged: (newValue) {
                  irrigationProgramProvider.updateForceToEndDate2(newValue: newValue);
                },
              ),
              const SizedBox(width: 10,),
              const Text("Force to stop on End date"),
            ],
          ),
        if(MediaQuery.of(context).size.width >= 800)
          const SizedBox(height: 30,),
        MediaQuery.of(context).size.width > 1200 ?
        Row(
          children: [
            Expanded(
              child: buildCustomListTile(
                context: context,
                isDatePicker: true,
                title: "Start date",
                icon: Icons.calendar_month,
                dateType: DateTime.parse(irrigationProgramProvider.startDate(serialNumber: widget.serialNumber)),
                onDateChanged: (newDate) => irrigationProgramProvider.updateDate(newDate, "startDate"),
              ),
            ),
            const SizedBox(width: 15,),
            Expanded(
                child: scheduleType == irrigationProgramProvider.scheduleTypes[1]
                    ? CustomAnimatedSwitcher(
                  condition: scheduleType == irrigationProgramProvider.scheduleTypes[1],
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: customBoxShadow
                    ),
                    child: CustomTile(
                      title: 'No. of days to cycle',
                      content: Icons.format_list_numbered,
                      trailing: SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: () {
                            _textEditingController.text = noOfDays;
                            _textEditingController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _textEditingController.text.length,
                            );
                            showAdaptiveDialog(
                              context: context,
                              builder: (ctx) => Consumer<IrrigationProgramMainProvider>(
                                builder: (context, irrigationProgramProvider, child) {
                                  return AlertDialog(
                                    title: const Text("Number of days"),
                                    content: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(RegExp('[^0-9a-zA-Z]')),
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      enableInteractiveSelection: false,
                                      controller: _textEditingController,
                                      autofocus: true,
                                      onChanged: (newValue) {
                                        tempNoOfDays = newValue;
                                        irrigationProgramProvider.validateInputAndSetErrorText(tempNoOfDays, runListLimit);
                                        irrigationProgramProvider.initializeDropdownValues(tempNoOfDays == '' ? '1' : tempNoOfDays, noOfDays, schedule['type']);
                                      },
                                      decoration: InputDecoration(
                                        errorText: irrigationProgramProvider.errorText,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // irrigationProgramProvider.updateNumberOfDays(tempNoOfDays, 'noOfDays', irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList);
                                          if (irrigationProgramProvider.errorText == null) {
                                            Navigator.of(context).pop();
                                            irrigationProgramProvider.updateNumberOfDays(tempNoOfDays, 'noOfDays', irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList);
                                          }
                                        },
                                        child: const Text("OKAY"),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(noOfDays, style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                      ),
                    ),
                  ),
                )
                    : CustomAnimatedSwitcher(
                  condition: scheduleType == irrigationProgramProvider.scheduleTypes[2],
                  child: buildCustomListTile(
                    context: context,
                    isTextForm: true,
                    title: "Run days",
                    icon: Icons.directions_run,
                    daysType: runDays,
                    onChanged: (newValue) => irrigationProgramProvider.updateNumberOfDays(newValue, 'runDays', irrigationProgramProvider.sampleScheduleModel!.scheduleByDays),
                  ),
                )
            ),
            const SizedBox(width: 15,),
            Expanded(
                child: scheduleType == irrigationProgramProvider.scheduleTypes[1]
                    ? CustomAnimatedSwitcher(
                    condition: (noOfDays != '0' && noOfDays != '') && (isForceToEndDate),
                    child: buildCustomListTile(
                      context: context,
                      title: "End date",
                      icon: Icons.calendar_month,
                      isDatePicker: true,
                      dateType: endDate,
                      firstDate: firstDate,
                      onDateChanged: (newDate) => irrigationProgramProvider.updateDate(newDate, "endDate"),
                    )
                )
                    : CustomAnimatedSwitcher(
                  condition: scheduleType == irrigationProgramProvider.scheduleTypes[2],
                  child: buildCustomListTile(
                    context: context,
                    title: "Skip days",
                    icon: Icons.skip_next,
                    isTextForm: true,
                    daysType: skipDays,
                    onChanged: (newValue) => irrigationProgramProvider.updateNumberOfDays(newValue, 'skipDays', irrigationProgramProvider.sampleScheduleModel!.scheduleByDays),
                  ),
                )
            ),
            const SizedBox(width: 15,),
            if(scheduleType == irrigationProgramProvider.scheduleTypes[2])
              Expanded(
                  child: CustomAnimatedSwitcher(
                      condition: (runDays != '0' && runDays != '') && (isForceToEndDate),
                      child: buildCustomListTile(
                        context: context,
                        title: "End date",
                        icon: Icons.calendar_month,
                        isDatePicker: true,
                        dateType: endDate,
                        firstDate: firstDate,
                        onDateChanged: (newDate) => irrigationProgramProvider.updateDate(newDate, "endDate"),
                      )
                  )
              )
          ],
        )
            : Container(
          height: (scheduleType == irrigationProgramProvider.scheduleTypes[2]) ? 260 : 230,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Expanded(
                        child: buildScheduleItem(
                            context: context,
                            color: lightColor4,
                            iconColor: darkColor4,
                            backGroundColor: darkColor2.withOpacity(0.3),
                            title: "Stop on end date",
                            icon: Icons.stop,
                            showIcon: !isForceToEndDate,
                            subTitle: "Description",
                            showSubTitle: !isForceToEndDate,
                            additionalInfo: !isForceToEndDate ? "Not Needed" : "Needed",
                            child: Switch(
                              value: isForceToEndDate,
                              activeColor: Colors.white,
                              activeTrackColor: darkColor4,
                              onChanged: (newValue) {
                                irrigationProgramProvider.updateForceToEndDate2(newValue: newValue);
                              },
                            )
                        ),
                      ),
                      // if(isForceToEndDate)
                      // const SizedBox(height: 10,),
                      if(isForceToEndDate)
                        Expanded(
                          child: Container(
                            child: DatePickerField(
                              value: endDate,
                              firstDate: firstDate,
                              onChanged: (newDate) => irrigationProgramProvider.updateDate(newDate, "endDate"),
                              child: buildScheduleItem(
                                  context: context,
                                  color: cardColor,
                                  backGroundColor: lightColor4,
                                  title: "End date",
                                  iconColor: darkColor1,
                                  icon: Icons.date_range,
                                  // additionalInfo: "",
                                  child: Text(dateFormat.format(endDate))
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(width: 10,),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: DatePickerField(
                            value: DateTime.parse(irrigationProgramProvider.startDate(serialNumber: widget.serialNumber)),
                            firstDate: DateTime.now(),
                            onChanged: (newDate) => irrigationProgramProvider.updateDate(newDate, "startDate"),
                            child: buildScheduleItem(
                                context: context,
                                color: lightColor1,
                                backGroundColor: lightColor4,
                                title: "Start date",
                                iconColor: darkColor1,
                                icon: Icons.calendar_today,
                                additionalInfo: "",
                                child: Text(dateFormat.format(DateTime.parse(irrigationProgramProvider.startDate(serialNumber: widget.serialNumber))))
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 10,),
                      if(scheduleType == irrigationProgramProvider.scheduleTypes[1])
                        InkWell(
                          onTap: () {
                            _textEditingController.text = noOfDays;
                            _textEditingController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _textEditingController.text.length,
                            );
                            showAdaptiveDialog(
                              context: context,
                              builder: (ctx) => Consumer<IrrigationProgramMainProvider>(
                                builder: (context, irrigationProgramProvider, child) {
                                  return AlertDialog(
                                    title: const Text("Number of days"),
                                    content: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(RegExp('[^0-9a-zA-Z]')),
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      controller: _textEditingController,
                                      autofocus: true,
                                      onChanged: (newValue) {
                                        tempNoOfDays = newValue;
                                        irrigationProgramProvider.validateInputAndSetErrorText(tempNoOfDays, runListLimit);
                                        irrigationProgramProvider.initializeDropdownValues(tempNoOfDays == '' ? '0' : tempNoOfDays, noOfDays, schedule['type']);
                                      },
                                      decoration: InputDecoration(
                                        errorText: irrigationProgramProvider.errorText,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // irrigationProgramProvider.updateNumberOfDays(tempNoOfDays, 'noOfDays', irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList);
                                          if (irrigationProgramProvider.errorText == null) {
                                            Navigator.of(context).pop();
                                            irrigationProgramProvider.updateNumberOfDays(tempNoOfDays, 'noOfDays', irrigationProgramProvider.sampleScheduleModel!.scheduleAsRunList);
                                          }
                                        },
                                        child: const Text("OKAY"),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                          child: buildScheduleItem(
                            context: context,
                            color: lightColor2,
                            iconColor: darkColor2,
                            backGroundColor: lightColor3,
                            icon: Icons.event_repeat,
                            title: "Number of days cycle",
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              children: [
                                const SizedBox(height: 10,),
                                Text(noOfDays, style: Theme.of(context).textTheme.bodyMedium,),
                              ],
                            ),
                          ),
                          // child: Text(noOfDays, style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                      if(scheduleType == irrigationProgramProvider.scheduleTypes[2])
                        buildScheduleItem(
                          context: context,
                          color: lightColor2,
                          backGroundColor: lightColor4,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          title: "Run days",
                          iconColor: darkColor2,
                          icon: Icons.run_circle_outlined,
                          additionalInfo: "",
                          child: SizedBox(
                            height: 20,
                            width: 50,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              enableInteractiveSelection: false,
                              textAlign: TextAlign.center,
                              initialValue: runDays,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (newValue) => irrigationProgramProvider.updateNumberOfDays(newValue, 'runDays', irrigationProgramProvider.sampleScheduleModel!.scheduleByDays),
                            ),
                          ),
                        ),
                      if(scheduleType == irrigationProgramProvider.scheduleTypes[2])
                        buildScheduleItem(
                          context: context,
                          color: Colors.white70,
                          backGroundColor: lightColor4,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          title: "Skip days",
                          iconColor: Colors.grey,
                          icon: Icons.skip_next,
                          additionalInfo: "",
                          child: SizedBox(
                            height: 20,
                            width: 50,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              enableInteractiveSelection: false,
                              textAlign: TextAlign.center,
                              initialValue: skipDays,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (newValue) => irrigationProgramProvider.updateNumberOfDays(newValue, 'skipDays', irrigationProgramProvider.sampleScheduleModel!.scheduleByDays),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if(scheduleType == irrigationProgramProvider.scheduleTypes[1])
          SizedBox(height: MediaQuery.of(context).size.width > 800 ? 30 : 10,),
        if(scheduleType == irrigationProgramProvider.scheduleTypes[1] && int.parse(noOfDays) > 1)
          CustomAnimatedSwitcher(
            condition: int.parse(noOfDays) != 0,
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: cardColor,
                  // boxShadow: customBoxShadow
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Set All Days", style: TextStyle(fontWeight: FontWeight.bold),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for(int i = 0; i < irrigationProgramProvider.scheduleOptions.length; i++)
                            ElevatedButton(
                              onPressed: () => irrigationProgramProvider.setAllSame(i),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  bool areAllItemsSame = irrigationProgramProvider.sampleScheduleModel?.scheduleAsRunList.schedule['type']!.every((item) {
                                    return item == irrigationProgramProvider.scheduleOptions[i];
                                  });
                                  if (irrigationProgramProvider.selectedButtonIndex == i || areAllItemsSame) {
                                    return Theme.of(context).colorScheme.primary;
                                  } else {
                                    return Colors.white;
                                  }
                                }),
                                surfaceTintColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  bool areAllItemsSame = irrigationProgramProvider.sampleScheduleModel?.scheduleAsRunList.schedule['type']!.every((item) {
                                    return item == irrigationProgramProvider.scheduleOptions[i];
                                  });
                                  if (irrigationProgramProvider.selectedButtonIndex == i || areAllItemsSame) {
                                    return Theme.of(context).colorScheme.primary;
                                  } else {
                                    return Colors.white;
                                  }
                                }),
                                elevation: MaterialStateProperty.all(3),
                                // side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor,  width: 0.3)),
                                foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  bool areAllItemsSame = irrigationProgramProvider.sampleScheduleModel?.scheduleAsRunList.schedule['type']!.every((item) {
                                    return item == irrigationProgramProvider.scheduleOptions[i];
                                  });
                                  if (irrigationProgramProvider.selectedButtonIndex == i || areAllItemsSame) {
                                    return Colors.white;
                                  } else {
                                    return Theme.of(context).colorScheme.primary;
                                  }
                                }),
                              ),
                              child: MediaQuery.of(context).size.width > 800 ? Text(irrigationProgramProvider.scheduleOptions[i]) : Icon(iconList[i]),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: MediaQuery.of(context).size.width > 800 ? 30 : 10,),
        if(scheduleType == irrigationProgramProvider.scheduleTypes[1])
          CustomAnimatedSwitcher(
            condition: int.parse(noOfDays) != 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _scrollController.jumpTo(_scrollController.offset - details.primaryDelta! / 2);
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Center(
                        child: Row(
                          children: [
                            for(var index = 0; index < int.parse(noOfDays); index++)
                              Row(
                                children: [
                                  buildPopUpMenuButton(
                                      context: context,
                                      dataList: irrigationProgramProvider.scheduleOptions,
                                      selected: (type != null && type.isNotEmpty) ? type[index] : irrigationProgramProvider.scheduleOptions[2],
                                      onSelected: (newValue) {
                                        irrigationProgramProvider.updateDropdownValue(index, newValue);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        surfaceTintColor: cardColor,
                                        color: cardColor,
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(days[index]),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text('${(type != null && type.isNotEmpty) ? type[index] : irrigationProgramProvider.scheduleOptions[2]}', style: TextStyle(color: Theme.of(context).primaryColor),),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(width: 10,),
                                              Container(
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: linearGradientLeading,
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.transparent,
                                                    radius: 20,
                                                    child: Icon((type != null && type.isNotEmpty) ? (type[index] == irrigationProgramProvider.scheduleOptions[0]
                                                        ? iconList[0]
                                                        : type[index] == irrigationProgramProvider.scheduleOptions[1]
                                                        ? iconList[1]
                                                        : type[index] == irrigationProgramProvider.scheduleOptions[2]
                                                        ? iconList[2]
                                                        : iconList[3]) : iconList[2],
                                                      color: Colors.white,),
                                                    // child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                  ),
                                  const SizedBox(width: 10,)
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     IconButton(
                //       icon: const Icon(Icons.arrow_back_ios),
                //       onPressed: () {
                //         _scrollController.animateTo(
                //           _scrollController.position.pixels - 200,
                //           duration: const Duration(milliseconds: 500),
                //           curve: Curves.easeInOut,
                //         );
                //       },
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.arrow_forward_ios),
                //       onPressed: () {
                //         _scrollController.animateTo(
                //           _scrollController.position.pixels + 200,
                //           duration: const Duration(milliseconds: 500),
                //           curve: Curves.easeInOut,
                //         );
                //       },
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        if(scheduleType == irrigationProgramProvider.scheduleTypes[1])
          const SizedBox(height: 30,),
      ],
    );
  }

  Widget buildRtcDetails({required BoxConstraints constraints,
    required rtcType, required BuildContext context, required functionCondition,
    required bool allowStopMethodCondition, required bool defaultOffTime, required bool defaultMaxTime}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: customBoxShadow
          ),
          child: CustomDataTable(
              headerText: "RTC Details",
              icon: Icons.schedule,
              columnSpacing: constraints.maxWidth * 0.049,
              columns: [
                buildDataColumn(label: "RTC", widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.1 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.05, isFixedSize: true),
                if(allowStopMethodCondition)
                  buildDataColumn(label: "Stop method", widthRatio: constraints.maxWidth * 0.1, isFixedSize: true),
                buildDataColumn(label: "On time", widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08, isFixedSize: true),
                buildDataColumn(label: "Interval", widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08, isFixedSize: true),
                buildDataColumn(label: "No. of cycles", widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08, isFixedSize: true),
                if(allowStopMethodCondition || defaultOffTime)
                  buildDataColumn(label: "Off time", widthRatio: constraints.maxWidth * 0.08, isFixedSize: true),
                if(allowStopMethodCondition || defaultMaxTime)
                  buildDataColumn(label: "Max Time", widthRatio: constraints.maxWidth * 0.08, isFixedSize: true),
              ],
              dataList: rtcType.rtc.values.toList(),
              rowsPerPage: rtcType.rtc.keys.toList().length,
              cellBuilders: [
                    (data, index) => buildDataCell(dataItem: "RTC ${index + 1}",
                    widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.1 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.05),
                if(allowStopMethodCondition)
                      (data, index) => buildDataCell(
                      dataItem: "Stop Method",
                      widthRatio: constraints.maxWidth * 0.1,
                      isFixedSize: true,
                      child: CustomDropdownWidget(
                          dropdownItems: irrigationProgramProvider.stopMethods,
                          selectedValue: data['stopMethod'] ?? irrigationProgramProvider.stopMethods[0],
                          includeNoneOption: false,
                          onChanged: (newValue) => irrigationProgramProvider.updateRtcProperty(newValue, index, 'stopMethod', rtcType)
                      )
                  ),
                    (data, index) => buildDataCell(
                    dataItem: data['onTime'],
                    child: CustomNativeTimePicker(
                      initialValue: data['onTime'],
                      is24HourMode: false,
                      onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'onTime', rtcType),
                    ),
                    isFixedSize: true,
                    widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08
                ),
                    (data, index) => buildDataCell(
                  dataItem: data['interval'],
                  widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08,
                  child: CustomNativeTimePicker(
                    initialValue: data['interval'],
                    is24HourMode: true,
                    onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'interval', rtcType),
                  ),
                  isFixedSize: true,
                ),
                    (data, index) => buildDataCell(
                  dataItem: data['noOfCycles'],
                  widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08,
                  child: SizedBox(
                    height: 30,
                    width: constraints.maxWidth * 0.03,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      initialValue: data['noOfCycles'],
                      keyboardType: TextInputType.number,
                      enableInteractiveSelection: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (newValue){
                        irrigationProgramProvider.updateRtcProperty(newValue, index, 'noOfCycles', rtcType);
                      },
                    ),
                  ),
                  isFixedSize: true,
                ),
                if(allowStopMethodCondition || defaultOffTime)
                      (data, index) => buildDataCell(
                    dataItem: data['offTime'],
                    widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08,
                    child: (data['stopMethod'] == irrigationProgramProvider.stopMethods[1] || defaultOffTime) ?
                    CustomNativeTimePicker(
                      initialValue: data['offTime'],
                      is24HourMode: false,
                      onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'offTime', rtcType),
                    ) :
                    const Text('N/A'),
                    isFixedSize: true,
                  ),
                if(allowStopMethodCondition || defaultMaxTime)
                      (data, index) => buildDataCell(
                    dataItem: data['maxTime'],
                    widthRatio: !allowStopMethodCondition ? (defaultMaxTime || defaultOffTime) ? constraints.maxWidth * 0.155 : constraints.maxWidth * 0.175 : constraints.maxWidth * 0.08,
                    child: (data['stopMethod'] == irrigationProgramProvider.stopMethods[2] || defaultMaxTime) ?
                    CustomNativeTimePicker(
                      initialValue: data['maxTime'],
                      is24HourMode: false,
                      onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'maxTime', rtcType),
                    ) :
                    const Text('N/A'),
                    isFixedSize: true,
                  ),
              ]
          ),
        ),
        Positioned(
          top: 10,
          right: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for(var i = 0; i < 2; i++)
                Row(
                  children: [
                    buildActionButton(
                      context: context,
                      key: ["addRtc", "delRtc"][i],
                      icon: [Icons.add, Icons.delete][i],
                      label: ['Add', 'Delete'][i],
                      labelColor: [Colors.green, Colors.red, Theme.of(context).primaryColor][i],
                      onPressed: [() => addTab(functionCondition), () => deleteTab(functionCondition)][i],
                    ),
                    const SizedBox(width: 10,),
                  ],
                )
            ],
          ),
        )
      ],
    );
  }

  Widget buildRtcDetailsForMobile({
    required BoxConstraints constraints,
    required rtcType,
    required BuildContext context,
    required functionCondition,
    required bool allowStopMethodCondition,
    required bool defaultOffTime,
    required bool defaultMaxTime,
    required PageController pageController,
  }) {
    int pageCount = rtcType.rtc.keys.length;

    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: pageCount,
              physics: const AlwaysScrollableScrollPhysics(),
              onPageChanged: (int index) {
                if (irrigationProgramProvider.currentRtcIndex != index) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      irrigationProgramProvider.updateCurrentRtcIndex(index);
                    });
                  });
                }
              },
              itemBuilder: (BuildContext context, int index) {
                return buildRtcCard(index, context, rtcType, allowStopMethodCondition, defaultOffTime, defaultMaxTime, irrigationProgramProvider);
              },
            ),
          ),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if(pageCount > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for(var i = 0; i < pageCount; i++)
                        AnimatedContainer(
                          width: irrigationProgramProvider.currentRtcIndex == i ? 20: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(5),
                            color: irrigationProgramProvider.currentRtcIndex == i ? Theme.of(context).primaryColor : Colors.grey,
                          ), duration: Duration(milliseconds: 1000),
                        ),
                    ],
                  ),
                SizedBox(
                  width: (constraints.maxWidth / 2) - (pageCount > 4 ? 55 : 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for(var i = 0; i < 2; i++)
                        IconButton(
                          onPressed: [() => addTab(functionCondition), () => deleteTab(functionCondition)][i],
                          icon: Icon([Icons.add, Icons.delete][i], color: [Colors.green, Colors.red][i],),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.05))
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget buildRtcCard(int index, BuildContext context, rtcType, allowStopMethodCondition, defaultOffTime, defaultMaxTime, IrrigationProgramMainProvider irrigationProgramProvider) {
    DateTime startDate = DateTime.parse(irrigationProgramProvider.startDate(serialNumber: widget.serialNumber));
    DateTime currentDate = DateTime.now();

    bool isSameDate = (startDate.year == currentDate.year &&
        startDate.month == currentDate.month &&
        startDate.day == currentDate.day);
    String timeString = rtcType.rtc.values.toList()[index]['onTime'].toString();

    List<String> timeParts = timeString.split(':');
    int onHour = int.parse(timeParts[0]);
    int onMinute = int.parse(timeParts[1]);
    int onSecond = int.parse(timeParts[2]);

    DateTime now = DateTime.now();

    DateTime onTime = DateTime(now.year, now.month, now.day, onHour, onMinute, onSecond);

    bool isBefore = onTime.isBefore(DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second));
    // isSameDate
    //     ? isBefore
    //     ? DateTime(now.hour, now.minute, now.second).toString()
    //     : rtcType.rtc.values.toList()[index]['onTime']
    //     : rtcType.rtc.values.toList()[index]['onTime']
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 220,
            width: MediaQuery.of(context).size.width - 60,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              // gradient: linearGradientLeading,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              // boxShadow: customBoxShadow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20,),
                buildCardSection(
                  title: "Stop method",
                  color: const Color(0xffF0F6FF),
                  // color: Color(0xff629df5),
                  context: context,
                  isColumn: false,
                  // provider: irrigationProgramProvider,
                  child: allowStopMethodCondition
                      ? buildPopUpMenuButton(
                    context: context,
                    dataList: irrigationProgramProvider.stopMethods,
                    onSelected: (selectedValue) => irrigationProgramProvider.updateRtcProperty(selectedValue, index, 'stopMethod', rtcType),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(rtcType.rtc.values.toList()[index]['stopMethod'] ?? irrigationProgramProvider.stopMethods[0], style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5,),
                        Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor, size: 20),
                      ],
                    ),
                  ) : Text(defaultOffTime ? "Off time" : defaultMaxTime ? "Max time" : "Continuous"),
                ),
                // const SizedBox(height: 5,),
                Row(
                  children: [
                    Expanded(
                        child: buildCardSection(
                            title: "On time",
                            context: context,
                            color: const Color(0xffF0FCF5),
                            // color: Color(0xffFF534D),
                            // provider: irrigationProgramProvider,
                            child: CustomNativeTimePicker(
                              //DateTime.parse(irrigationProgramProvider.startDate.toString()).isAtSameMomentAs(DateTime.now()) ? DateTime.parse(rtcType.rtc.values.toList()[index]['onTime'].toString()).isBefore(DateTime.now()) ? DateTime.now() : rtcType.rtc.values.toList()[index]['onTime'] : rtcType.rtc.values.toList()[index]['onTime']
                              initialValue: rtcType.rtc.values.toList()[index]['onTime'],
                              is24HourMode: true,
                              onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'onTime', rtcType),
                            )
                        )
                    ),
                    // const SizedBox(width: 5,),
                    Expanded(
                        child: buildCardSection(
                            title: "Interval",
                            context: context,
                            color: const Color(0xffFFEEF4),
                            // color: Color(0xffFF60A3),
                            // provider: irrigationProgramProvider,
                            child: CustomNativeTimePicker(
                              initialValue: rtcType.rtc.values.toList()[index]['interval'],
                              is24HourMode: true,
                              onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'interval', rtcType),
                            )
                        )
                    ),
                  ],
                ),
                // const SizedBox(height: 5,),
                Row(
                  children: [
                    Expanded(
                        child: buildCardSection(
                          title: "Number of cycles",
                          context: context,
                          color: const Color(0xffF0FCF5),
                          // color: Color(0xff31CF70),
                          // provider: irrigationProgramProvider,
                          child: SizedBox(
                            height: 20,
                            width: 50,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              enableInteractiveSelection: false,
                              textAlign: TextAlign.center,
                              initialValue: rtcType.rtc.values.toList()[index]['noOfCycles'],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'noOfCycles', rtcType),
                            ),
                          ),
                        )
                    ),
                    // const SizedBox(width: 5,),
                    if(defaultOffTime || rtcType.rtc.values.toList()[index]['stopMethod'] == irrigationProgramProvider.stopMethods[1])
                      Expanded(
                          child: buildCardSection(
                              title: "Off time",
                              context: context,
                              color: const Color(0xffFFF3F3),
                              // color: Color(0xffFAC744),
                              // provider: irrigationProgramProvider,
                              child: CustomNativeTimePicker(
                                initialValue: rtcType.rtc.values.toList()[index]['offTime'],
                                is24HourMode: true,
                                onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'offTime', rtcType),
                              )
                          )
                      ),
                    if(defaultMaxTime || rtcType.rtc.values.toList()[index]['stopMethod'] == irrigationProgramProvider.stopMethods[2])
                      Expanded(
                          child: buildCardSection(
                              title: "Max time",
                              context: context,
                              // provider: irrigationProgramProvider,
                              child: CustomNativeTimePicker(
                                initialValue: rtcType.rtc.values.toList()[index]['maxTime'],
                                is24HourMode: true,
                                onChanged: (newTime) => irrigationProgramProvider.updateRtcProperty(newTime, index, 'maxTime', rtcType),
                              )
                          )
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text("RTC ${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildScheduleItem({
  required BuildContext context,
  required String title,
  String? subTitle,
  String? additionalInfo,
  bool showSubTitle = false,
  bool showIcon = false,
  EdgeInsets? padding,
  required Color iconColor,
  required Color backGroundColor,
  required Widget child,
  required Color color,
  IconData? icon}){
  return Card(
    elevation: 3,
    child: Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: customBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(showIcon)
            CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Icon(icon, color: iconColor,)),
          Row(
            children: [
              if(!showIcon)
                CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Icon(icon, color: iconColor,)),
              if(!showIcon)
                const SizedBox(width: 10,),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold,),)),
            ],
          ),
          if(showSubTitle)
            Text(subTitle!, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(!showSubTitle || additionalInfo != null)
                Text(additionalInfo ?? "", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),),
              child
            ],
          )
        ],
      ),
    ),
  );
}

Widget buildCardSection({required String title, required BuildContext context,
  bool isColumn = true, required Widget child, Color? color}) {
  return Card(
    // color: const Color(0xffE7F0F2),
    color: color,
    // surfaceTintColor: const Color(0xffE7F0F2),
    surfaceTintColor: color,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: isColumn ? 5 : 12, horizontal: 10),
      decoration: BoxDecoration(
        // color: const Color(0xffE7F0F2),
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isColumn
          ? Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
          const SizedBox(height: 5,),
          child
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          child
        ],
      ),
    ),
  );
}

Widget buildPopUpMenuButton({required BuildContext context, selected,
  required List<String> dataList, required void Function(String) onSelected, required Widget child, Offset offset = Offset.zero}){
  return PopupMenuButton<String>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    surfaceTintColor: Colors.white,
    itemBuilder: (context) {
      return dataList.map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Center(child: Text(value, style: TextStyle(color: selected == value ? Theme.of(context).primaryColor : null),)),
        );
      }).toList();
    },
    onSelected: onSelected,
    offset: offset,
    child: child,
  );
}

Widget buildCustomListTile({
  required BuildContext context,
  required String title,
  daysType,
  void Function(String)? onChanged,
  bool isTextForm = false,
  bool isTimePicker = false,
  bool isDatePicker = false,
  bool isCheckBox = false,
  bool isSwitch = false,
  initialValue,
  dateType,
  firstDate,
  EdgeInsets? padding,
  void Function(DateTime)? onDateChanged,
  void Function(String)? onTimeChanged,
  bool checkBoxValue = false,
  void Function(bool?)? onCheckBoxChanged,
  bool switchValue = false,
  void Function(bool)? onSwitchChanged,
  required icon}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: customBoxShadow
    ),
    child: isTextForm ?
    CustomTextFormTile(
      subtitle: title,
      hintText: '00',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
        LengthLimitingTextInputFormatter(2),
      ],
      initialValue: daysType ?? initialValue,
      onChanged: onChanged ?? (newValue) {},
      icon: icon,
    )
        :
    CustomTile(
      title: title,
      content: icon,
      trailing: IntrinsicWidth(
        child: isTimePicker ?
        CustomNativeTimePicker(
            initialValue: initialValue,
            is24HourMode: false,
            // style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
            onChanged: onTimeChanged ?? (newValue) {}
        )
            : isDatePicker ?
        DatePickerField(
          value: dateType,
          firstDate: firstDate,
          onChanged: onDateChanged ?? (DateTime dateTime) {},
        )
            : isCheckBox
            ? Checkbox(value: checkBoxValue, onChanged: onCheckBoxChanged ?? (bool? value) {})
            : isSwitch
            ? Switch(value: switchValue, onChanged: onSwitchChanged) : const SizedBox(),
      ),
    ),
  );
}