import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_view/state_management/MqttPayloadProvider.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:provider/provider.dart';

import '../../../ListOfFertilizerInSet.dart';
import '../../../Models/Customer/system_definition_model.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/system_definition_provider.dart';
import '../../../widget/SCustomWidgets/custom_animated_switcher.dart';
import '../../../widget/SCustomWidgets/custom_list_tile.dart';
import '../../../widget/SCustomWidgets/custom_native_time_picker.dart';
import '../../../widget/SCustomWidgets/custom_snack_bar.dart';
import '../Planning/NewIrrigationProgram/program_library.dart';
import '../Planning/NewIrrigationProgram/schedule_screen.dart';
import '../ScheduleView.dart';

const LinearGradient linearGradientLeading = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff1D808E), Color(0xff044851)],
);
class SystemDefinition extends StatefulWidget {
  final int userId;
  final int controllerId;
  final String deviceId;
  const SystemDefinition({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.deviceId
  });

  @override
  State<SystemDefinition> createState() => _SystemDefinitionState();
}

class _SystemDefinitionState extends State<SystemDefinition> {
  final HttpService httpService = HttpService();
  late OverAllUse overAllPvd;
  late SystemDefinitionProvider systemDefinitionProvider;
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    systemDefinitionProvider = Provider.of<SystemDefinitionProvider>(context, listen: false);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        systemDefinitionProvider.getUserPlanningSystemDefinition(overAllPvd.userId, overAllPvd.controllerId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    systemDefinitionProvider = Provider.of<SystemDefinitionProvider>(context, listen: true);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    final screenSize = MediaQuery.of(context).size.width;
    return systemDefinitionProvider.irrigationLineSystemData != null ? RefreshIndicator(
      onRefresh: () => systemDefinitionProvider.getUserPlanningSystemDefinition(overAllPvd.userId, overAllPvd.controllerId),
      child: Scaffold(
        appBar: screenSize <= 600 ? AppBar(
          title: const Text("System Definition"),
          bottom: PreferredSize(
              preferredSize: const Size(double.maxFinite, 40),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(var i = 0; i < systemDefinitionProvider.irrigationLineSystemData!.length; i++)
                      buildSideBarMenuList(
                        context: context,
                        title: systemDefinitionProvider.irrigationLineSystemData![i].name,
                        dataList: systemDefinitionProvider.irrigationLineSystemData!.map((e) => e.name).toList(),
                        index: i,
                        selected: systemDefinitionProvider.selectedIrrigationLine == i,
                        onTap: (index) {
                          systemDefinitionProvider.updateSelectedProgramCategory(index);
                        },
                      ),
                  ],
                ),
              )
          ),
        ) : PreferredSize(preferredSize: Size.zero, child: Container()),
        body: (systemDefinitionProvider.irrigationLineSystemData != null)
            ? LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              children: [
                if (screenSize >= 600)
                  buildCustomSideMenuBar(
                    context: context,
                    title: "System Definition",
                    constraints: constraints,
                    children: [
                      for(var i = 0; i < systemDefinitionProvider.irrigationLineSystemData!.length; i++)
                        buildSideBarMenuList(
                          context: context,
                          constraints: constraints,
                          title: systemDefinitionProvider.irrigationLineSystemData![i].name,
                          dataList: systemDefinitionProvider.irrigationLineSystemData!.map((e) => e.name).toList(),
                          index: i,
                          selected: systemDefinitionProvider.selectedIrrigationLine == i,
                          onTap: (index) {
                            systemDefinitionProvider.updateSelectedProgramCategory(index);
                          },
                        ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: systemDefinitionProvider.irrigationLineSystemData!.length,
                      itemBuilder: (BuildContext context, int lineIndex) {
                        if(systemDefinitionProvider.selectedIrrigationLine == lineIndex) {
                          return screenSize <= 600 ? Column(
                            children: [
                              if(systemDefinitionProvider.selectedIrrigationLine == 0)
                                const SizedBox(height: 15,),
                              if(systemDefinitionProvider.selectedIrrigationLine == 0)
                                buildSwitchTile(
                                  title: "All irrigation line should run while power off",
                                  value: systemDefinitionProvider.enableAll,
                                  onChanged: (newValue) {
                                    setState(() {
                                      systemDefinitionProvider.enableAll = newValue;
                                      for(var i = 0; i < systemDefinitionProvider.irrigationLineSystemData!.length; i++) {
                                        if(systemDefinitionProvider.enableAll) {
                                          systemDefinitionProvider.irrigationLineSystemData![i].systemDefinition.irrigationLineOn = true;
                                        } else {
                                          systemDefinitionProvider.irrigationLineSystemData![i].systemDefinition.irrigationLineOn = false;
                                        }
                                      }
                                    });
                                  },
                                  icon: Icons.clear_all,
                                ),
                              const SizedBox(height: 15,),
                              buildSwitchTile(
                                title: "Should run while power off",
                                value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.irrigationLineOn,
                                onChanged: (newValue) {
                                  setState(() {
                                    systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.irrigationLineOn = newValue;
                                    if(systemDefinitionProvider.irrigationLineSystemData!.every((element) => element.systemDefinition.irrigationLineOn == true)){
                                      systemDefinitionProvider.enableAll = true;
                                    } else {
                                      systemDefinitionProvider.enableAll = false;
                                    }
                                  });
                                },
                                icon: Icons.power_settings_new,
                              ),
                              const SizedBox(height: 15,),
                              buildSwitchTile(
                                title: "Enable energy save function",
                                value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status,
                                onChanged: (newValue) {
                                  setState(() {
                                    systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status = newValue;
                                  });
                                },
                                icon: Icons.energy_savings_leaf,
                              ),
                              const SizedBox(height: 10,),
                              if (systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildScheduleItem(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          context: context,
                                          title: 'Start day time',
                                          iconColor: Colors.green,
                                          backGroundColor: cardColor,
                                          icon: Icons.start,
                                          color: Colors.white,
                                          child: CustomNativeTimePicker(
                                              initialValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime,
                                              is24HourMode: false,
                                              onChanged: (newValue){
                                                setState(() {
                                                  systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime = newValue;
                                                });
                                              }),
                                        ),
                                      ),
                                      Expanded(
                                        child: buildScheduleItem(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          context: context,
                                          title: 'Stop day time',
                                          iconColor: Colors.red.withOpacity(0.7),
                                          backGroundColor: cardColor,
                                          color: Colors.white,
                                          icon: Icons.stop,
                                          child: CustomNativeTimePicker(
                                              initialValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime,
                                              is24HourMode: false,
                                              onChanged: (newValue){
                                                setState(() {
                                                  systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime = newValue;
                                                });
                                              }
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10,),
                              buildSwitchTile(
                                title: "Pause by days",
                                value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine,
                                onChanged: (newValue) {
                                  setState(() {
                                    systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine = newValue;
                                  });
                                },
                                icon: Icons.pause,
                              ),
                              const SizedBox(height: 15,),
                              if (systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                      boxShadow: customBoxShadow
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            gradient: linearGradientLeading,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text("S.No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                            Expanded(child: Text("Days", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                                            Expanded(child: Text("From", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                            Expanded(child: Text("To", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
                                            Expanded(child: Text("Yes/No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                          ],
                                        ),
                                      ),
                                      for(var i = 0; i < 7; i++)
                                        buildDayTimePicker(
                                            day: systemDefinitionProvider.days[i],
                                            dayTimeRange: systemDefinitionProvider.daysFromAndToTimes(lineIndex: lineIndex)[i],
                                            dayCount: systemDefinitionProvider.values[i],
                                            checkBoxValue: systemDefinitionProvider.isSelectedList(lineIndex: lineIndex)[i],
                                            constraints: constraints,
                                            lineIndex: lineIndex
                                        )
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 80,),
                            ],
                          ) : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(8),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            children: [
                                              Text(systemDefinitionProvider.irrigationLineSystemData![lineIndex].name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                                            ],
                                          )
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        children: [
                                          SizedBox(width: constraints.maxWidth * 0.02,),
                                          Checkbox(
                                              value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status = newValue!;
                                                });
                                              }
                                          ),
                                          SizedBox(width: constraints.maxWidth * 0.02,),
                                          const Text("Energy save function"),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      CustomAnimatedSwitcher(
                                        condition: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(width: constraints.maxWidth * 0.02,),
                                            SizedBox(width: constraints.maxWidth * 0.02,),
                                            SizedBox(width: constraints.maxWidth * 0.02,),
                                            const Text("Start day time"),
                                            SizedBox(width: constraints.maxWidth * 0.05,),
                                            buildTimePicker(
                                                currentValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime,
                                                onTap: (newValue) {
                                                  setState(() {
                                                    systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime = newValue;
                                                  });
                                                },
                                                is24HourMode: false
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.05),
                                            const Text("End day time"),
                                            SizedBox(width: constraints.maxWidth * 0.05,),
                                            buildTimePicker(
                                                currentValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime,
                                                onTap: (newValue) {
                                                  setState(() {
                                                    systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime = newValue;
                                                  });
                                                },
                                                is24HourMode: false
                                            ),
                                          ],
                                        ),),
                                      const SizedBox(height: 20,),
                                      CustomAnimatedSwitcher(condition: true, child: Row(
                                        children: [
                                          SizedBox(width: constraints.maxWidth * 0.02,),
                                          Checkbox(
                                              value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine = newValue!;
                                                });
                                              }
                                          ),
                                          SizedBox(width: constraints.maxWidth * 0.02,),
                                          const Text("Pause by days"),
                                        ],
                                      )),
                                      const SizedBox(height: 20,),
                                      CustomAnimatedSwitcher(
                                          condition: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("Days", style: Theme.of(context).textTheme.bodyLarge,),
                                                  const SizedBox(height: 10,),
                                                  Text("From", style: Theme.of(context).textTheme.bodyLarge),
                                                  const SizedBox(height: 10,),
                                                  Text("To", style: Theme.of(context).textTheme.bodyLarge),
                                                ],
                                              ),
                                              for(var i = 0; i < 7; i++)
                                                buildDayTimePicker(
                                                    day: systemDefinitionProvider.days[i],
                                                    dayTimeRange: systemDefinitionProvider.daysFromAndToTimes(lineIndex: lineIndex)[i],
                                                    dayCount: systemDefinitionProvider.values[i],
                                                    checkBoxValue: systemDefinitionProvider.isSelectedList(lineIndex: lineIndex)[i],
                                                    constraints: constraints,
                                                    lineIndex: lineIndex
                                                )
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                // Container(
                                //   decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius: BorderRadius.circular(8)
                                //   ),
                                //   padding: const EdgeInsets.all(10),
                                //   child: Column(
                                //     children: [
                                //       Container(
                                //           padding: const EdgeInsets.all(8),
                                //           width: double.infinity,
                                //           decoration: BoxDecoration(
                                //               color: Theme.of(context).primaryColor.withOpacity(0.2),
                                //               borderRadius: BorderRadius.circular(8)
                                //           ),
                                //           child: Text("Power off recovery ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),)
                                //       ),
                                //       const SizedBox(height: 20,),
                                //       Row(
                                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Row(
                                //             children: [
                                //               SizedBox(width: constraints.maxWidth * 0.02,),
                                //               const Text("When the power is out for longer than"),
                                //               SizedBox(width: constraints.maxWidth * 0.02,),
                                //               buildTimePicker(systemDefinitionProvider.powerOffRecoveryModel!.duration, (newValue) {
                                //                 systemDefinitionProvider.updateValues(newValue, "duration");
                                //               }, true),
                                //             ],
                                //           ),
                                //           Row(
                                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //             children: List.generate(systemDefinitionProvider.options.length, (index) {
                                //               return Row(
                                //                 children: [
                                //                   Checkbox(
                                //                     value: systemDefinitionProvider.powerOffRecoveryModel!.selectedOption.contains(systemDefinitionProvider.options[index])
                                //                         ? true : false,
                                //                     onChanged: (newValue) {
                                //                       systemDefinitionProvider.updateCheckBoxesForOption(newValue, systemDefinitionProvider.options[index], index);
                                //                     },
                                //                   ),
                                //                   Text(systemDefinitionProvider.options[index]),
                                //                   const SizedBox(width: 20,)
                                //                 ],
                                //               );
                                //             }).toList(),
                                //           ),
                                //         ],
                                //       )
                                //     ],
                                //   ),
                                // )
                              ],
                            ),
                          );
                        }
                        return Container();
                      }
                  ),
                )
              ],
            );
          },
        )
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: MaterialButton(
          minWidth: 100,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          textColor: Colors.white,
          onPressed: () async{
            // print(systemDefinitionProvider.irrigationLineSystemData!.map((e) => e.toMqtt()).toList().join("\n"));
            Map<String, dynamic> dataToMqtt = {
              "2200": [
                {
                  "2201": systemDefinitionProvider.irrigationLineSystemData!.map((e) => e.toMqtt()).toList().join(";"),
                },
                {
                  "2202": "${overAllPvd.userId}"
                }
              ]
            };

            Map<String, dynamic> userData = {
              "userId": overAllPvd.userId,
              "controllerId": overAllPvd.controllerId,
              "createUser": overAllPvd.userId,
              "systemDefinition" : systemDefinitionProvider.irrigationLineSystemData!.map((e) => e.toJson()).toList(),
              "hardware": dataToMqtt
            };
            // print(dataToMqtt);
            try {
              await validatePayloadSent(
                  dialogContext: context,
                  context: context,
                  mqttPayloadProvider: mqttPayloadProvider,
                  acknowledgedFunction: () {
                    setState(() {
                      // userData['controllerReadStatus'] = "1";
                      // if(userData['controllerReadStatus'] == "0") {
                      //   userData['hardware'] = {};
                      // }
                    });
                    // showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller", context: context);
                  },
                  payload: dataToMqtt,
                  payloadCode: "2200",
                  deviceId: overAllPvd.imeiNo
              ).whenComplete(() {
                Future.delayed(const Duration(seconds: 1), () async {
                  final createUserPlanningSystemDefinition = await httpService.postRequest('createUserPlanningSystemDefinition', userData);
                  // print(userData['systemDefinition']);
                  final response = jsonDecode(createUserPlanningSystemDefinition.body);
                  if(createUserPlanningSystemDefinition.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                  }
                });
              });
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
              debugPrint("Error: $error");
            }
          },
          child: const Text("Send"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    ) : CircularProgressIndicator();
  }

  Widget buildTimePicker(
      {required String currentValue, required Function(String) onTap, required bool is24HourMode}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomNativeTimePicker(
          initialValue: currentValue,
          is24HourMode: is24HourMode,
          onChanged: (newTime ) => onTap(newTime)
      ),
    );
  }

  Widget buildSwitchTile(
      {required String title, required bool value, required Function(bool) onChanged, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: customBoxShadow
      ),
      child: CustomSwitchTile(
        title: title,
        showCircleAvatar: true,
        value: value,
        icon: icon,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildTimerTile(
      {required String subtitle,
        required String initialValue,
        required Function(String) onChanged,
        required IconData icon,
        required bool is24HourMode}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: customBoxShadow
      ),
      child: CustomTimerTile(
        subtitle: subtitle,
        initialValue: initialValue,
        onChanged: onChanged,
        isSeconds: false,
        icon: icon,
        isNative: true,
        is24HourMode: is24HourMode,
      ),
    );
  }

  Widget buildDayTimePicker(
      {required String day,
        required DayTimeRange dayTimeRange,
        required dayCount,
        required checkBoxValue,
        required int lineIndex,
        required constraints}) {
    return Consumer<SystemDefinitionProvider>(builder: (BuildContext context, SystemDefinitionProvider systemDefinitionProvider, child) {
      return constraints.maxWidth <= 600 ?
      CustomTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: day,
        trailing: SizedBox(
          width: constraints.maxWidth <= 600 ? constraints.maxWidth * 0.55 : constraints.maxWidth * 0.25,
          child: buildTimeRow(
              from: dayTimeRange.from,
              to: dayTimeRange.to,
              onChanged: (newFrom, newTo) => systemDefinitionProvider.updateDayTimeRange(dayTimeRange, newFrom, newTo),
              checkBox: checkBoxValue,
              onChangedBool: (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue, lineIndex),
              constraints: constraints
          ),
        ),
        content: dayCount,
      ) :
      Column(
        children: [
          Row(
            children: [
              Text(day, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
              Checkbox(value: checkBoxValue, onChanged: (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue, lineIndex))
            ],
          ),
          buildTimeRow(
              from: dayTimeRange.from,
              to: dayTimeRange.to,
              onChanged: (newFrom, newTo) => systemDefinitionProvider.updateDayTimeRange(dayTimeRange, newFrom, newTo),
              checkBox: checkBoxValue,
              onChangedBool: (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue, lineIndex),
              constraints: constraints
          )
        ],
      );
    });
  }

  Widget buildTimeRow(
      {required String from,
        required String to,
        required Function(String, String) onChanged,
        required bool checkBox,
        required Function(bool?) onChangedBool,
        required constraints}) {
    return constraints.maxWidth <= 600 ?
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: from, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(newTime, to)
          ),
        ),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: to, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(from, newTime)
          ),
        ),
        Checkbox(value: checkBox, onChanged: onChangedBool),
      ],
    ) :
    Column(
      children: [
        const SizedBox(height: 10,),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: from, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(newTime, to)
          ),
        ),
        const SizedBox(height: 10,),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: to, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(from, newTime)
          ),
        )
      ],
    );
  }
}

// if (systemDefinitionProvider.selectedSegment == 0) {
//   return Column(
//     children: [
//       const SizedBox(height: 15,),
//       buildSwitchTile(
//         title: "Enable energy save function",
//         value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status,
//         onChanged: (newValue) {
//           setState(() {
//             systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status = newValue;
//           });
//           print(newValue);
//           print(systemDefinitionProvider.selectedSegment);
//         },
//         icon: Icons.energy_savings_leaf,
//       ),
//       const SizedBox(height: 10,),
//       if (systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.status)
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 15),
//           child: Row(
//             children: [
//               Expanded(
//                 child: buildScheduleItem(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   context: context,
//                   title: 'Start day time',
//                   iconColor: Colors.green,
//                   backGroundColor: cardColor,
//                   icon: Icons.start,
//                   color: Colors.white,
//                   child: CustomNativeTimePicker(
//                       initialValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime,
//                       is24HourMode: false,
//                       onChanged: (newValue){
//                         setState(() {
//                           systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.startDayTime = newValue;
//                         });
//                       }),
//                 ),
//               ),
//               Expanded(
//                 child: buildScheduleItem(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   context: context,
//                   title: 'Stop day time',
//                   iconColor: Colors.red.withOpacity(0.7),
//                   backGroundColor: cardColor,
//                   color: Colors.white,
//                   icon: Icons.stop,
//                   child: CustomNativeTimePicker(
//                       initialValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime,
//                       is24HourMode: false,
//                       onChanged: (newValue){
//                         setState(() {
//                           systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.stopDayTime = newValue;
//                         });
//                       }
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       const SizedBox(height: 10,),
//       buildSwitchTile(
//         title: "Pause by days",
//         value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine,
//         onChanged: (newValue) {
//           setState(() {
//             systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine = newValue;
//           });
//         },
//         icon: Icons.pause,
//       ),
//       const SizedBox(height: 15,),
//       if (systemDefinitionProvider.irrigationLineSystemData![lineIndex].systemDefinition.pauseMainLine)
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: Colors.white,
//             boxShadow: customBoxShadow
//           ),
//           child: Column(
//             children: [
//               for(var i = 0; i < 7; i++)
//                 buildDayTimePicker(
//                     day: systemDefinitionProvider.days[i],
//                     dayTimeRange: systemDefinitionProvider.daysFromAndToTimes(lineIndex: lineIndex)[i],
//                     dayCount: systemDefinitionProvider.values[i],
//                     checkBoxValue: systemDefinitionProvider.isSelectedList(lineIndex: lineIndex)[i],
//                     constraints: constraints,
//                     lineIndex: lineIndex
//                 )
//             ],
//           ),
//         ),
//     const SizedBox(height: 80,),
//     ],
//   );
// } else {
//   return ListView(
//     shrinkWrap: true,
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     children: [
//       buildTimerTile(
//           subtitle: "When the power is out for longer than",
//           initialValue: systemDefinitionProvider.irrigationLineSystemData![lineIndex].powerOffRecovery.duration,
//           onChanged: (newValue) {
//             setState(() {
//               systemDefinitionProvider.irrigationLineSystemData![lineIndex].powerOffRecovery.duration = newValue;
//             });
//           },
//           icon: Icons.timer,
//           is24HourMode: true
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(systemDefinitionProvider.options.length, (index) {
//           return Row(
//             children: [
//               Checkbox(
//                 value: systemDefinitionProvider.irrigationLineSystemData![lineIndex].powerOffRecovery.selectedOption.contains(systemDefinitionProvider.options[index]),
//                 onChanged: (newValue) {
//                   systemDefinitionProvider.updateCheckBoxesForOption(newValue, systemDefinitionProvider.options[index], index, lineIndex);
//                 },
//               ),
//               Text(systemDefinitionProvider.options[index]),
//               const SizedBox(width: 20,)
//             ],
//           );
//         }).toList(),
//       ),
//       const SizedBox(height: 80,),
//     ],
//   );
// }