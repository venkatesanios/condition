import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/preference_provider.dart';
import '../../ListOfFertilizerInSet.dart';
import '../../widget/SCustomWidgets/custom_animated_switcher.dart';
import '../../widget/SCustomWidgets/custom_native_time_picker.dart';
import '../../widget/SCustomWidgets/custom_segmented_control.dart';
import '../customer/Planning/NewIrrigationProgram/schedule_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool viewSettings;
  final int userId;
  final dynamic value;
  const SettingsScreen({super.key, required this.viewSettings, this.value, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin{
  late PreferenceProvider preferenceProvider;
  late MqttPayloadProvider mqttPayloadProvider;
  late TabController tabController1;
  late TabController tabController2;
  int selectedPumpIndex1 = 0;
  int selectedPumpIndex2 = 0;
  int selectedSetting = 0;
  bool doCalibration = false;
  TextEditingController passwordController = TextEditingController();

  final otherSettingsIcons = [
    MdiIcons.lightbulbMultipleOutline,
    MdiIcons.alphaRCircleOutline,
    MdiIcons.alphaYCircleOutline,
    MdiIcons.alphaBCircleOutline,
    MdiIcons.formatLineHeight,
    MdiIcons.windowMinimize,
    MdiIcons.windowMaximize,
    MdiIcons.restart,
    MdiIcons.lightbulbCfl,
    MdiIcons.lightbulbCfl,
    MdiIcons.lightbulbCflOff,
    MdiIcons.toggleSwitch,
    MdiIcons.timerSand,
    MdiIcons.lightbulbCflOff,
    MdiIcons.toggleSwitch,
    MdiIcons.timerSand,
    MdiIcons.motionSensor,
  ];

  final voltageSettingsIcons = [
    MdiIcons.speedometerSlow,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbMultiple,
    MdiIcons.lightbulbMultiple,
    MdiIcons.speedometer,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbMultiple,
    MdiIcons.lightbulbMultiple,
    MdiIcons.scaleUnbalanced,
    MdiIcons.flashTriangle,
    MdiIcons.stepBackward,
    MdiIcons.stepBackward,
  ];

  final timerSettingsIcons = [
    MdiIcons.timerPlay,
    MdiIcons.starCog,
    MdiIcons.battery,
    MdiIcons.batteryClock,
    MdiIcons.messageAlert,
    MdiIcons.timerSettings,
    MdiIcons.radioactive,
    MdiIcons.fanClock,
    MdiIcons.timerSync,
    MdiIcons.timerPlay,
    MdiIcons.timerStop,
    MdiIcons.timerRefresh,
    MdiIcons.timerSand,
  ];

  final currentSettingIcons = [
    MdiIcons.waterAlert,
    MdiIcons.timerSand,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbMultiple,
    MdiIcons.restart,
    MdiIcons.timer,
    MdiIcons.restartAlert,
    MdiIcons.timer,
    MdiIcons.counter,
    Icons.lock_reset,
    MdiIcons.stackOverflow,
    MdiIcons.timerSand,
    MdiIcons.lightbulbGroup,
    MdiIcons.lightbulbMultiple,
    MdiIcons.overscan,
    MdiIcons.overscan,
    MdiIcons.lightbulbMultiple,
    MdiIcons.lightbulbMultiple,
    MdiIcons.lightbulbMultiple,
  ];

  final additionalSettingsIcons = [
    MdiIcons.storageTank,
    MdiIcons.bucket,
    MdiIcons.calendar,
    Icons.directions_run,
    MdiIcons.skipNextOutline,
  ];

  final voltageCalibrationIcons = [
    MdiIcons.alphaRCircleOutline,
    MdiIcons.alphaYCircleOutline,
    MdiIcons.alphaBCircleOutline,
  ];

  final otherCalibrationIcons = [
    MdiIcons.clipboardFlow,
    Icons.compress,
    MdiIcons.windowMaximize,
    MdiIcons.waterCheck,
    MdiIcons.storeSettings,
    MdiIcons.carCoolantLevel,
  ];

  @override
  void initState() {
    // TODO: implement initState
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    tabController1 = TabController(
        length: preferenceProvider.commonPumpSettings?.length ?? 0,
        vsync: this
    );
    tabController2 = TabController(
        length: preferenceProvider.individualPumpSetting?.length ?? 0,
        vsync: this
    );
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if(preferenceProvider.commonPumpSettings!.isEmpty) {
          setState(() {
            selectedSetting = 1;
          });
        }
        tabController1 = TabController(
            length: preferenceProvider.commonPumpSettings?.length ?? 0,
            vsync: this
        )..addListener(() {
          setState(() {
            selectedPumpIndex1 = tabController1.index;
          });
        });
        tabController2 = TabController(
            length: preferenceProvider.individualPumpSetting?.length ?? 0,
            vsync: this
        )..addListener(() {
          setState(() {
            selectedPumpIndex2 = tabController2.index;
          });
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    tabController1.dispose();
    tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: true);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              const SizedBox(height: 10,),
              if(preferenceProvider.commonPumpSettings!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomSegmentedControl(
                    segmentTitles: const {
                      0: 'Common setting',
                      1: 'Individual setting',
                      2: 'Calibration'
                    },
                    groupValue: selectedSetting,
                    onChanged: (value) {
                      setState(() {
                        selectedSetting = value!;
                        if(!widget.viewSettings) {
                          if(selectedSetting == 2) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Consumer(
                                      builder: (BuildContext context, PreferenceProvider preferenceProvider, _) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller: passwordController,
                                                autofocus: true,
                                                decoration: const InputDecoration(
                                                    hintText: "Enter password"
                                                ),
                                              ),
                                              const SizedBox(height: 10,),
                                              if(preferenceProvider.passwordValidationCode == 404)
                                                const Text('Invalid password', style: TextStyle(color: Colors.red),)
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: (){
                                                  passwordController.text = "";
                                                  preferenceProvider.passwordValidationCode = 0;
                                                  selectedSetting = 1;
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("CANCEL")
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  await Future.delayed(Duration.zero, () {
                                                    preferenceProvider.passwordValidationCode = 0;
                                                  });
                                                  await preferenceProvider.checkPassword(userId: widget.userId, password: passwordController.text);
                                                  if(preferenceProvider.passwordValidationCode == 200) {
                                                    Navigator.of(context).pop();
                                                    passwordController.text = "";
                                                  }
                                                },
                                                child: Text("OK")
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                }
                            );
                          } else {
                            preferenceProvider.passwordValidationCode = 0;
                          }
                        }
                      });
                    },
                  ),
                ),
              DefaultTabController(
                  length: selectedSetting != 1 ? preferenceProvider.commonPumpSettings!.length: preferenceProvider.individualPumpSetting!.length,
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      TabBar(
                        controller: selectedSetting != 1 ? tabController1 : tabController2,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        tabs: [
                          if(selectedSetting != 1)
                            ...preferenceProvider.commonPumpSettings!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final element = entry.value;
                              return buildTabItem(index: index, itemName: element.deviceName, selectedIndex: selectedPumpIndex1);
                            })
                          else
                            ...preferenceProvider.individualPumpSetting!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final element = entry.value;
                              return buildTabItem(index: index, itemName: element.name, selectedIndex: selectedPumpIndex2);
                            })
                        ],
                      ),
                    ],
                  )
              ),
              if(selectedSetting != 2)
                Expanded(
                    child: TabBarView(
                      controller: selectedSetting != 1 ? tabController1 : tabController2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if(selectedSetting == 0)
                          for(var commonSettingIndex = 0; commonSettingIndex < preferenceProvider.commonPumpSettings!.length; commonSettingIndex++)
                            buildSettingsCategory(
                                context: context,
                                settingList: preferenceProvider.commonPumpSettings![commonSettingIndex].settingList,
                                constraints: constraints,
                                pumpIndex: commonSettingIndex
                            )
                        else if(selectedSetting == 1)
                          for(var pumpSettingIndex = 0; pumpSettingIndex < preferenceProvider.individualPumpSetting!.length; pumpSettingIndex++)
                            buildSettingsCategory(
                                context: context,
                                settingList: preferenceProvider.individualPumpSetting![pumpSettingIndex].settingList,
                                constraints: constraints,
                                pumpIndex: pumpSettingIndex
                            )
                        // for(var index = 0; index < (selectedSetting == 0 ? preferenceProvider.commonPumpSettings!.length : preferenceProvider.individualPumpSetting!.length); index++)
                        //   Text("${index+1}")
                      ],
                    )
                ),
              if(selectedSetting == 2 && widget.viewSettings ? true : (preferenceProvider.passwordValidationCode == 200))
                Expanded(
                    child: TabBarView(
                      controller: selectedSetting != 1 ? tabController1 : tabController2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for(var calibrationSettingIndex = 0; calibrationSettingIndex < preferenceProvider.calibrationSetting!.length; calibrationSettingIndex++)
                          buildSettingsCategory(
                              context: context,
                              settingList: preferenceProvider.calibrationSetting![calibrationSettingIndex].settingList,
                              constraints: constraints,
                              pumpIndex: calibrationSettingIndex
                          )
                      ],
                    )
                ),
            ],
          );
        }
    );
  }

  Widget buildSettingsCategory({required BuildContext context, required List settingList, required BoxConstraints constraints, required int pumpIndex}) {
    try {
      return ListView(
        children: [
          for(var categoryIndex = 0; categoryIndex < settingList.length; categoryIndex++)
            Container(
              margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 700 ? 15 : 200, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(settingList[categoryIndex].name, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: customBoxShadow
                    ),
                    child: Column(
                      children: [
                        for(var settingIndex = 0; settingIndex < settingList[categoryIndex].setting.length; settingIndex++)
                          if(settingList[categoryIndex].setting[settingIndex].title != "RTC TIMER")
                            buildCustomListTileWidget(
                                context: context,
                                title: settingList[categoryIndex].setting[settingIndex].title,
                                widgetType: widget.viewSettings ? 6 : settingList[categoryIndex].setting[settingIndex].widgetTypeId,
                                value: widget.viewSettings
                                    ? settingList[categoryIndex].setting[settingIndex].title == "RTC"
                                    ? getValueForRtc(
                                  type: settingList[categoryIndex].type,
                                  categoryIndex: categoryIndex,
                                  pumpIndex: pumpIndex,
                                  settingIndex: settingIndex,
                                )[0]
                                    : (getValue(
                                    type: settingList[categoryIndex].type,
                                    categoryIndex: categoryIndex,
                                    pumpIndex: pumpIndex,
                                    settingIndex: settingIndex
                                ).split(',')[settingIndex])
                                    : settingList[categoryIndex].setting[settingIndex].value,
                                leading: Container(
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white
                                      // gradient: linearGradientLeading,
                                    ),
                                    child: CircleAvatar(
                                        backgroundColor: cardColor,
                                        child: Icon(
                                            settingList[categoryIndex].type == 26
                                                ? otherSettingsIcons[settingIndex]
                                                : settingList[categoryIndex].type == 24
                                                ? voltageSettingsIcons[settingIndex]
                                                : settingList[categoryIndex].type == 22
                                                ? timerSettingsIcons[settingIndex]
                                                : settingList[categoryIndex].type == 23
                                                ? currentSettingIcons[settingIndex]
                                                : (settingList[categoryIndex].type == 27 || settingList[categoryIndex].type == 28)
                                                ? voltageCalibrationIcons[settingIndex]
                                                : settingList[categoryIndex].type == 29
                                                ? otherCalibrationIcons[settingIndex]
                                                : additionalSettingsIcons[settingIndex],
                                            color: Theme.of(context).primaryColor
                                        )
                                    )
                                ),
                                onValueChange: (newValue) {
                                  setState(() {
                                    if(settingList[categoryIndex].type == 26) {
                                      if (settingList[categoryIndex].setting[settingIndex].serialNumber == 15 ||
                                          settingList[categoryIndex].setting[settingIndex].serialNumber == 16) {

                                        if (settingList[categoryIndex].setting[settingIndex].serialNumber == 15) {
                                          settingList[categoryIndex].setting[settingIndex].value = true;
                                          settingList[categoryIndex].setting.firstWhere((setting) => setting.serialNumber == 16).value = false;
                                        } else if (settingList[categoryIndex].setting[settingIndex].serialNumber == 16) {
                                          settingList[categoryIndex].setting[settingIndex].value = true;
                                          settingList[categoryIndex].setting.firstWhere((setting) => setting.serialNumber == 15).value = false;
                                        }
                                      }
                                    }
                                    settingList[categoryIndex].changed = true;
                                    settingList[categoryIndex].setting[settingIndex].value = newValue;
                                  });
                                  // print("settingList[categoryIndex].changed ==> ${settingList[categoryIndex].changed}");
                                },
                                conditionToShow:  widget.viewSettings ? true : getConditionToShow(
                                  type: settingList[categoryIndex].type,
                                  serialNumber: settingList[categoryIndex].setting[settingIndex].serialNumber,
                                  value: settingList[categoryIndex].setting[settingIndex].value,
                                ),
                                hidden: settingList[categoryIndex].setting[settingIndex].hidden,
                                enabled: preferenceProvider.commonPumpSettings!.isEmpty
                                    ? settingList[categoryIndex].setting[settingIndex].title == "ON DELAY TIMER"
                                    : true
                            )
                          else
                            CustomAnimatedSwitcher(
                              condition: widget.viewSettings ? true : (conditions['rtc'] ?? false),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: Center(child: Text('RTC', style: Theme.of(context).textTheme.bodyLarge))),
                                      Expanded(child: Center(child: Text('On Time', style: Theme.of(context).textTheme.bodyLarge))),
                                      Expanded(child: Center(child: Text('Off Time', style: Theme.of(context).textTheme.bodyLarge))),
                                    ],
                                  ),
                                  const SizedBox(height: 20,),
                                  Column(
                                    children: [
                                      if (settingList[categoryIndex].setting[settingIndex].rtcSettings != null)
                                        ...settingList[categoryIndex].setting[settingIndex].rtcSettings!.asMap().entries.map((entry) {
                                          final int rtcIndex = entry.key;
                                          final rtcSetting = entry.value;

                                          List<String> value = [];
                                          if(widget.viewSettings) {
                                            String rtcSettingsValue = getValueForRtc(
                                              type: settingList[categoryIndex].type,
                                              categoryIndex: categoryIndex,
                                              pumpIndex: pumpIndex,
                                              settingIndex: settingIndex,
                                            ).split(',').skip(1).join(',');
                                            List<String> valuesList = rtcSettingsValue.split(',');
                                            value = extractValues(rtcIndex, valuesList);
                                          }

                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        '${rtcIndex + 1}',
                                                        style: Theme.of(context).textTheme.bodyLarge,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: widget.viewSettings && (rtcIndex).isOdd ? Text(value[0]) : CustomNativeTimePicker(
                                                        initialValue: rtcSetting.onTime.isNotEmpty ? rtcSetting.onTime : "00:00:00",
                                                        onChanged: (newTime) {
                                                          setState(() {
                                                            settingList[categoryIndex].changed = true;
                                                            rtcSetting.onTime = newTime;
                                                          });
                                                          print(settingList[categoryIndex].changed);
                                                        },
                                                        is24HourMode: true,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: widget.viewSettings && (rtcIndex).isEven ? Text(value[1]) : CustomNativeTimePicker(
                                                        initialValue: rtcSetting.offTime.isNotEmpty ? rtcSetting.offTime : "00:00:00",
                                                        onChanged: (newTime) {
                                                          setState(() {
                                                            settingList[categoryIndex].changed = true;
                                                            rtcSetting.offTime = newTime;
                                                          });
                                                        },
                                                        is24HourMode: true,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                            ],
                                          );
                                        })
                                    ],
                                  )
                                ],
                              ),
                            )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  if(categoryIndex == settingList.length -1)
                    const SizedBox(height: 50,)
                ],
              ),
            )
        ],
      );
    } catch(error, stackTrace) {
      // throw Exception('This is a test exception');
      print("error ==> $error");
      print("stackTrace ==> $stackTrace");
      return const Center(child: Text("Unexpected error"));
    }
  }

  List<String> extractValues(int rtcIndex, List<String> valuesList) {
    int startIndex = rtcIndex * 2;
    return valuesList.sublist(startIndex, startIndex + 2);
  }

  String getValue({required int type, required int categoryIndex, required int pumpIndex, required int settingIndex}) {
    String valueToShow = "";

    for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++) {
      var rtcTimeTemp = "";
      var delayTimeTemp = "";
      // print("pumpIndex ==> $pumpIndex");
      // print("i ==> $i");
      if(i != 0) {
        if(i-1 == pumpIndex) {
          var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
          for (var element in decodedList) {
            Map<String, dynamic> decode = element;
            decode.forEach((key, value) {
              switch (type) {
                case 26:
                  if (key == "ctconfig") valueToShow = value;
                  break;
                case 24:
                  if (key == "voltageconfig") valueToShow = value;
                  break;
                case 22:
                  if (key == "delayconfig") delayTimeTemp = value;
                  if (key == "rtcconfig") rtcTimeTemp = value;
                  final list = [...delayTimeTemp.split(','), ...rtcTimeTemp.split(',').sublist(1)];
                  valueToShow = list.join(',');
                  break;
                case 23:
                  if (key == "currentconfig") valueToShow = value;
                  break;
                case 25:
                  if (key == "scheduleconfig") valueToShow = value;
                  break;
              // case 27:
              // if (key == "calibration") valueToShow = value;
              // break;
              // case 28:
              // if (key == "calibration") valueToShow = value;
              // print(valueToShow.split());
              // break;
              }
            });
          }
        }
      } else {
        var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
        for (var element in decodedList) {
          Map<String, dynamic> decode = element;
          decode.forEach((key, value) {
            switch (type) {
              case 26:
                if (key == "ctconfig") valueToShow = value;
                break;
              case 24:
                if (key == "voltageconfig") valueToShow = value;
                break;
              case 22:
                if (key == "delayconfig") delayTimeTemp = value;
                if (key == "rtcconfig") rtcTimeTemp = value;
                final list = [...delayTimeTemp.split(','), ...rtcTimeTemp.split(',').sublist(1)];
                valueToShow = list.join(',');
                break;
              case 23:
                if (key == "currentconfig") valueToShow = value;
                break;
              case 25:
                if (key == "scheduleconfig") valueToShow = value;
                break;
              case 27:
                if (key == "calibration") valueToShow = value;
                break;
              case 28:
                if (key == "calibration") valueToShow = value.split(',').skip(3).join(',');
                break;
              case 29:
                if (key == "calibration") valueToShow = value.split(',').skip(6).join(',');
                break;
            }
          });
        }
      }
    }

    // print(valueToShow);
    // print(keyToDebug);
    return valueToShow;
  }

  String getValueForRtc({required int type, required int categoryIndex, required int pumpIndex, required int settingIndex}) {
    String valueToShow = "";

    for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++) {
      if(i-1 == pumpIndex) {
        var rtcTimeTemp = "";
        var delayTimeTemp = "";
        var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
        for (var element in decodedList) {
          Map<String, dynamic> decode = element;
          decode.forEach((key, value) {
            switch (type) {
              case 22:
                if (key == "rtcconfig") rtcTimeTemp = value;
                valueToShow = delayTimeTemp+rtcTimeTemp;
                break;
            }
          });
        }
      }
    }
    return valueToShow;
  }

  Map<String, bool> conditions = {
    'phaseValue': false,
    'lowVoltage': false,
    'highVoltage': false,
    'startingCapacitor': false,
    'starterFeedback': false,
    'maxTime': false,
    'cyclicTime': false,
    'rtc': false,
    'dryRun': false,
    'dryRunRestart': false,
    'dryRunOcc': false,
    'overLoad': false,
    'schedule': false,
    'light': false,
    'peakHour': false,
  };

  bool getConditionToShow({required int type, required int serialNumber, required value}) {
    bool result = true;
    void setCondition(String key) {
      conditions[key] = value;
    }
    switch (type) {
      case 26:
        if (serialNumber == 1) setCondition('phaseValue');
        if (serialNumber == 9) setCondition('light');
        if (serialNumber == 12) setCondition('peakHour');
        if ([10,11].contains(serialNumber)) result = conditions['light']!;
        if ([13,14].contains(serialNumber)) result = conditions['peakHour']!;
        break;

      case 24:
        if (serialNumber == 1) setCondition('lowVoltage');
        if (serialNumber == 6) setCondition('highVoltage');
        if ([2,3].contains(serialNumber)) result = conditions['lowVoltage']!;
        if ([4,5].contains(serialNumber)) result = conditions['phaseValue']! && conditions['lowVoltage']!;
        if ([7,8].contains(serialNumber)) result = conditions['highVoltage']!;
        if ([9,10].contains(serialNumber)) result = conditions['phaseValue']! && conditions['highVoltage']!;
        break;

      case 22:
        if (serialNumber == 3) setCondition('startingCapacitor');
        if (serialNumber == 4) result = conditions['startingCapacitor']!;
        if (serialNumber == 5) setCondition('starterFeedback');
        if (serialNumber == 6) result = conditions['starterFeedback']!;
        if (serialNumber == 7) setCondition('maxTime');
        if (serialNumber == 8) result = conditions['maxTime']!;
        if (serialNumber == 9) setCondition('cyclicTime');
        if ([10,11].contains(serialNumber)) result = conditions['cyclicTime']!;
        if (serialNumber == 12) setCondition('rtc');
        if (serialNumber == 13) result = conditions['rtc']!;
        break;

      case 23:
        if (serialNumber == 1) setCondition('dryRun');
        if (serialNumber == 4) result = conditions['phaseValue']! && conditions['dryRun']!;
        if ([2, 3, 5, 6, 7, 8, 9, 10].contains(serialNumber)) result = conditions['dryRun']!;
        if (serialNumber == 5) setCondition('dryRunRestart');
        if (serialNumber == 6) result = conditions['dryRun']! && conditions['dryRunRestart']!;
        if (serialNumber == 7) setCondition('dryRunOcc');
        if ([8,9].contains(serialNumber)) result = conditions['dryRun']! && conditions['dryRunOcc']!;
        if (serialNumber == 11) setCondition('overLoad');
        if (serialNumber == 14) result = conditions['phaseValue']! && conditions['overLoad']!;
        if ([12, 13, 15].contains(serialNumber)) result = conditions['overLoad']!;
        break;

      case 25:
        if (serialNumber == 3) setCondition('schedule');
        if ([4,5].contains(serialNumber)) result = conditions['schedule']!;

      default:
        break;
    }

    return result;
  }

  Widget buildTabItem({required int index, required String itemName, required int selectedIndex}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: index == selectedIndex ? Theme.of(context).primaryColor : cardColor
        ),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(itemName, style: TextStyle(color: index == selectedIndex ? Colors.white : Theme.of(context).primaryColor),),
            )
        )
    );
  }
}

Widget buildCustomListTileWidget({
  required BuildContext context,
  required String title,
  String? subTitle,
  bool showTrailing = true,
  required int widgetType,
  dynamic value,
  void Function(dynamic newValue)? onValueChange,
  required Widget leading,
  bool conditionToShow = true,
  required bool hidden,
  bool enabled = true
}) {
  Widget customWidget;
  switch(widgetType) {
    case 1:
      customWidget = SizedBox(
        width: 80,
        child: TextFormField(
          enabled: enabled,
          initialValue: value is String ? value : "",
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('[^0-9.]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: InputDecoration(
            hintText: "000",
            contentPadding: EdgeInsets.symmetric(vertical: 5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8),),
                borderSide: BorderSide.none
            ),
            fillColor: cardColor,
            filled: true,
            // errorText: errorText
          ),
          onChanged: (newValue) {
            onValueChange?.call(newValue);
          },
        ),
      );
      break;
    case 2:
      customWidget = Switch(
        value: enabled ? (value != "" ? value : false) ?? false : false,
        onChanged: (newValue) {
          if(enabled) onValueChange?.call(newValue);
        },
      );
      break;
    case 3:
      customWidget = enabled ? CustomNativeTimePicker(
        initialValue: value is String ? value : "",
        is24HourMode: true,
        onChanged: (newValue) {
          enabled ? onValueChange?.call(newValue) : null;
        },
      ) : Text(value,  overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14),);
      break;
    case 4:
      customWidget = SizedBox(
        width: 80,
        child: TextFormField(
          enabled: enabled,
          initialValue: value is String ? value : "",
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              hintText: "000",
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: InputBorder.none,
              fillColor: cardColor
            // errorText: errorText
          ),
          onChanged: (newValue) {
            onValueChange?.call(newValue);
          },
        ),
      );
      break;
    case 6:
      customWidget = SizedBox(
        width: 80,
        child: Text(
          value ?? "Wait",
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14),
        ),
      );
      break;
    default:
      customWidget = Text('Unsupported Widget Type: $widgetType');
      break;
  }
  return Visibility(
    visible: !hidden,
    child: CustomAnimatedSwitcher(
      condition: conditionToShow,
      child: ListTile(
        contentPadding: subTitle != null ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        horizontalTitleGap: 20,
        leading: IntrinsicWidth(child: leading),
        title: Text(title),
        subtitle: subTitle != null ? Text(subTitle) : null,
        trailing: showTrailing ? IntrinsicWidth(child: customWidget) : null,
      ),
    ),
  );
}