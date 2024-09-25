import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/screens/NewPreference/settings_screen.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:provider/provider.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/preference_provider.dart';
import '../../widget/SCustomWidgets/custom_snack_bar.dart';
import '../customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';

const payloadTopic = "AppToFirmware";

class PreferenceMainScreen extends StatefulWidget {
  final int userId, controllerId, customerId;
  final String deviceId;
  const PreferenceMainScreen({super.key, required this.userId, required this.controllerId, required this.deviceId, required this.customerId});

  @override
  State<PreferenceMainScreen> createState() => _PreferenceMainScreenState();
}

class _PreferenceMainScreenState extends State<PreferenceMainScreen> with TickerProviderStateMixin{
  late PreferenceProvider preferenceProvider;
  late OverAllUse overAllPvd;
  late TabController _tabController;
  final HttpService httpService = HttpService();
  bool settingsSelected = false;
  late MqttPayloadProvider mqttPayloadProvider;
  bool showWidget = false;
  bool isCompleted = false;
  bool shouldSendAll = false;
  bool shouldSendFailedPayloads = false;
  List oroPumpList = [];
  List selectedOroPumpList = [];
  bool breakLoop = false;

  @override
  void initState() {
    // TODO: implement initState
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    preferenceProvider.getUserPreference(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId);
    _tabController = TabController(
      // length: preferenceProvider.label.length,
        length: 1,
        vsync: this
    );
    preferenceProvider.updateTabIndex(0);
    _tabController.addListener(() {
      preferenceProvider.updateTabIndex(_tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    preferenceProvider.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen:  true);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    if(preferenceProvider.generalDataResult != null && preferenceProvider.commonPumpSettings!.isNotEmpty) {
      if(oroPumpList.isEmpty) {
        for(var i = 0; i < preferenceProvider.commonPumpSettings!.length; i++){
          oroPumpList.add(preferenceProvider.commonPumpSettings![i].deviceId);
        }
        selectedOroPumpList = oroPumpList;
      }
    }
    if(preferenceProvider.generalDataResult != null){
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Scaffold(
              appBar: constraints.maxWidth < 800
                  ? AppBar(
                surfaceTintColor: Colors.white,
                title: Text("Pump Settings", style: TextStyle(color: Theme.of(context).primaryColor,),),
                centerTitle: false,
                // actions: [
                //   if(preferenceProvider.commonPumpSettings!.isNotEmpty)
                //     MaterialButton(
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(5)
                //       ),
                //       color: Theme.of(context).primaryColor,
                //       onPressed: () {
                //         setState(() {
                //           if(preferenceProvider.passwordValidationCode == 200) {
                //             preferenceProvider.calibrationSetting!.forEach((element) {
                //               element.settingList.forEach((setting) {
                //                 preferenceProvider.defaultCalibration!.forEach((defaultSetting) {
                //                   if(defaultSetting.type == setting.type) {
                //                     for(var i = 0; i < setting.setting.length; i++) {
                //                       setting.setting[i].value = defaultSetting.setting[i].value;
                //                     }
                //                   }
                //                 });
                //               });
                //             });
                //           } else {
                //             preferenceProvider.commonPumpSettings!.forEach((element) {
                //               element.settingList.forEach((setting) {
                //                 preferenceProvider.defaultSetting!.forEach((defaultSetting) {
                //                   if(defaultSetting.type == setting.type) {
                //                     for(var i = 0; i < setting.setting.length; i++) {
                //                       setting.setting[i].value = defaultSetting.setting[i].value;
                //                     }
                //                   }
                //                 });
                //               });
                //             });
                //             preferenceProvider.individualPumpSetting!.forEach((element) {
                //               element.settingList.forEach((setting) {
                //                 preferenceProvider.defaultSetting!.forEach((defaultSetting) {
                //                   if(defaultSetting.type == setting.type) {
                //                     for(var i = 0; i < setting.setting.length; i++) {
                //                       setting.setting[i].value = defaultSetting.setting[i].value;
                //                     }
                //                   }
                //                 });
                //               });
                //             });
                //           }
                //         });
                //       },
                //       child: Text("Set default", style: TextStyle(color: Colors.white, fontSize: 12),),
                //     )
                // ],
                // bottom: constraints.maxWidth < 800
                //     ?
                // PreferredSize(
                //   preferredSize: const Size.fromHeight(80.0),
                //   child: Container(
                //     width: double.infinity,
                //     color: Theme.of(context).colorScheme.background,
                //     child: TabBar(
                //       controller: _tabController,
                //       isScrollable: false,
                //       tabs: [
                //         for (int i = 0; i <  preferenceProvider.label.length; i++)
                //           CustomTab(
                //             height: 80,
                //             label: preferenceProvider.label[i],
                //             content: preferenceProvider.icons[i],
                //             tabIndex: i,
                //             selectedTabIndex: preferenceProvider.selectedTabIndex,
                //           ),
                //       ],
                //     ),
                //   ),
                // )
                //     : null,
              ) : PreferredSize(preferredSize: const Size(0, 0), child: Container()),
              body: DefaultTabController(
                length: preferenceProvider.label.length,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SettingsScreen(viewSettings: false, userId: overAllPvd.userId,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(preferenceProvider.passwordValidationCode == 200 && preferenceProvider.calibrationSetting![0].settingList[1].controllerReadStatus == "0"
                      ? getCalibrationPayload(isToGem: [1, 2].contains(preferenceProvider.generalData!.categoryId)).split(';')[0].isNotEmpty
                      : getFailedPayload(sendAll: false, isToGem: [1, 2].contains(preferenceProvider.generalData!.categoryId)).split(';')[0].isNotEmpty)
                  // if(preferenceProvider.commonPumpSettings!.isNotEmpty ? ((preferenceProvider.commonPumpSettings?.any((element) => element.settingList.any((e) => e.controllerReadStatus == "0")) ?? false) || (preferenceProvider.individualPumpSetting?.any((element) => element.settingList.any((e) => e.controllerReadStatus == "0")) ?? false)) : false)
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: Colors.orange.shade300,
                      onPressed: () async {
                        final failedPayload = preferenceProvider.passwordValidationCode == 200
                            ? getCalibrationPayload(isToGem: [1, 2].contains(preferenceProvider.generalData!.categoryId)).split(';')
                            : getFailedPayload(sendAll: false, isToGem: [1, 2].contains(preferenceProvider.generalData!.categoryId)).split(';');
                        // print(failedPayload);
                        List temp = List.from(selectedOroPumpList);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (BuildContext context, StateSetter stateSetter) {
                                  return AlertDialog(
                                    content: Container(
                                      height: 350,
                                      width: 300,
                                      // padding: EdgeInsets.all(16),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            for (var i = 0; i < preferenceProvider.commonPumpSettings!.length; i++)
                                              CheckboxListTile(
                                                  title: Text(preferenceProvider.commonPumpSettings![i].deviceName),
                                                  subtitle: Text(preferenceProvider.commonPumpSettings![i].deviceId),
                                                  value: temp.contains(preferenceProvider.commonPumpSettings![i].deviceId),
                                                  onChanged: (newValue) {
                                                    stateSetter(() {
                                                      setState(() {
                                                        if (temp.contains(preferenceProvider.commonPumpSettings![i].deviceId)) {
                                                          temp.remove(preferenceProvider.commonPumpSettings![i].deviceId);
                                                        } else {
                                                          temp.add(preferenceProvider.commonPumpSettings![i].deviceId);
                                                        }
                                                      });
                                                    });
                                                  }
                                              ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: failedPayload.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                final isToGem = [1, 2].contains(preferenceProvider.generalData!.categoryId);
                                                var payloadToDecode = isToGem ? failedPayload[i].split('+')[4] : failedPayload[i];
                                                var decodedData = jsonDecode(payloadToDecode);
                                                var key = decodedData.keys.first;
                                                int oroPumpIndex = 0;
                                                if (isToGem) {
                                                  oroPumpIndex = preferenceProvider.commonPumpSettings!.indexWhere((element) => element.deviceId == failedPayload[i].split('+')[2]);
                                                }
                                                return temp.contains(preferenceProvider.commonPumpSettings![oroPumpIndex].deviceId) ? ListTile(
                                                  leading: Container(
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: linearGradientLeading,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${i + 1}',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    '${preferenceProvider.commonPumpSettings![oroPumpIndex].deviceName}',
                                                    style: TextStyle(fontWeight: FontWeight.w400),
                                                  ),
                                                  subtitle: Text(
                                                    '${statusMessages[key]!}',
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                  ),
                                                ) : Container();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      FilledButton(
                                          onPressed: temp.isNotEmpty ? () async {
                                            await Future.delayed(Duration.zero, () {
                                              setState(() {
                                                shouldSendFailedPayloads = true;
                                                selectedOroPumpList = List.from(temp);
                                              });
                                            });
                                            Navigator.pop(context);
                                            await sendFunction();
                                          } : null,
                                          child: Text("Resend")
                                      ),
                                      FilledButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel")
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                        );
                      },
                      child: Text("Failed", style: TextStyle(color: Colors.black),),
                    ),
                  SizedBox(width: 20,),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      await Future.delayed(Duration.zero, () {
                        setState(() {
                          // oroPumpList.clear();
                          shouldSendFailedPayloads = false;
                        });
                      });
                      if(preferenceProvider.commonPumpSettings!.isEmpty || preferenceProvider.commonPumpSettings!.length <= 1) {
                        sendFunction();
                      } else {
                        selectPumpToSend();
                      }
                    },
                    child: Text("${preferenceProvider.passwordValidationCode == 200 ? "Send calibration": "Send preference"}", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          }
      );
    }
    else {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(semanticsLabel: "Loading")
        ),
      );
    }
  }

  void selectPumpToSend() {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return AlertDialog(
                  title: Text("Select the pump"),
                  content: Container(
                    height: 200,
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for(var i = 0; i < preferenceProvider.commonPumpSettings!.length; i++)
                              CheckboxListTile(
                                  title: Text(preferenceProvider.commonPumpSettings![i].deviceName),
                                  subtitle: Text(preferenceProvider.commonPumpSettings![i].deviceId),
                                  value: selectedOroPumpList.contains(preferenceProvider.commonPumpSettings![i].deviceId),
                                  onChanged: (newValue){
                                    stateSetter(() {
                                      setState(() {
                                        if(selectedOroPumpList.contains(preferenceProvider.commonPumpSettings![i].deviceId)){
                                          selectedOroPumpList.remove(preferenceProvider.commonPumpSettings![i].deviceId);
                                        } else {
                                          selectedOroPumpList.add(preferenceProvider.commonPumpSettings![i].deviceId);
                                        }
                                      });
                                    });
                                  }
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      child: Text("CANCEL", style: TextStyle(color: Colors.red),),
                    ),
                    TextButton(
                      onPressed: selectedOroPumpList.isNotEmpty ? () async{
                        Navigator.of(context).pop();
                        await sendFunction();
                      } : null,
                      child: Text("SEND"),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  static const Map<String, String> statusMessages = {
    "100": "Other settings",
    "200": "Voltage settings",
    "400-1": "Current settings for pump 1",
    "300-1": "Delay settings for pump 1",
    "500-1": "RTC settings for pump 1",
    "600-1": "Schedule config for pump 1",
    "400-2": "Current settings for pump 2",
    "300-2": "Delay settings for pump 2",
    "500-2": "RTC settings for pump 2",
    "600-2": "Schedule config for pump 2",
    "400-3": "Current settings for pump 3",
    "300-3": "Delay settings for pump 3",
    "500-3": "RTC settings for pump 3",
    "600-3": "Schedule config for pump 3",
    "900": "Calibration settings",
  };

  Future<void> sendFunction() async {
    mqttPayloadProvider.preferencePayload = {};
    breakLoop = false;
    Map<String, dynamic> userData = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "createUser": overAllPvd.userId
    };

    Map<String, dynamic> payloadForSlave = {
      "400": [
        {"401": ""},
        {"402": ""},
        {"403": onDelayTimer()},
        {"404": ""},
        {"405": ""},
        {"406": "${overAllPvd.userId}"}
      ]
    };
    final isToGem = [1,2].contains(preferenceProvider.generalData!.categoryId);

    final payload = shouldSendFailedPayloads ? getFailedPayload(isToGem: isToGem, sendAll: false) : getPayload(isToGem: isToGem, sendAll: false);
    final payloadParts = payload.split("?")[0].split(';');

    final payloadForGem = preferenceProvider.passwordValidationCode == 200
        ? getCalibrationPayload(isToGem: isToGem).split("?")[0].split(';')
        : payloadParts[0].isEmpty
        ? shouldSendFailedPayloads
        ? getFailedPayload(isToGem: isToGem, sendAll: true).split("?")[0].split(';')
        : getPayload(isToGem: isToGem, sendAll: true).split("?")[0].split(';')
        : payloadParts;

    // print(payloadForGem);

    try {
      if(preferenceProvider.passwordValidationCode != 200 && isToGem) {
        MQTTManager().publish(jsonEncode(payloadForSlave), "AppToFirmware/${preferenceProvider.generalData!.deviceId}");
      }

      if(preferenceProvider.commonPumpSettings!.isNotEmpty) {
        for (var i = 0; i < payloadForGem.length; i++) {
          var payloadToDecode = isToGem ? payloadForGem[i].split('+')[4] : payloadForGem[i];
          var decodedData = jsonDecode(payloadToDecode);
          var key = decodedData.keys.first;
          int oroPumpIndex = 0;
          if(isToGem) {
            oroPumpIndex = preferenceProvider.commonPumpSettings!.indexWhere((element) => element.deviceId == payloadForGem[i].split('+')[2]);
          }
          setState(() {
            if(key.contains("100")) preferenceProvider.commonPumpSettings![oroPumpIndex].settingList[1].controllerReadStatus = "0";
            if(key.contains("200")) preferenceProvider.commonPumpSettings![oroPumpIndex].settingList[0].controllerReadStatus = "0";
            int pumpIndex = 0;
            for (var individualPump in preferenceProvider.individualPumpSetting ?? []) {
              if (preferenceProvider.commonPumpSettings![oroPumpIndex].deviceId == individualPump.deviceId) {
                pumpIndex++;
                for (var individualPumpSetting in individualPump.settingList) {
                  switch (individualPumpSetting.type) {
                    case 23:
                      if(key.contains("400-$pumpIndex")) individualPumpSetting.controllerReadStatus= "0";
                      break;
                    case 22:
                      if(key.contains("300-$pumpIndex") || key.contains("500-$pumpIndex")) individualPumpSetting.controllerReadStatus = "0";
                      break;
                    case 25:
                      if(key.contains("600-$pumpIndex")) individualPumpSetting.controllerReadStatus = "0";
                      break;
                  }
                }
              }
            }
            if(preferenceProvider.passwordValidationCode == 200 && preferenceProvider.calibrationSetting!.isNotEmpty) {
              if(key.contains("900")) preferenceProvider.calibrationSetting![oroPumpIndex].settingList[1].controllerReadStatus = "0";
            }
          });
        }
        await processPayloads(
            context: context,
            mqttPayloadProvider: mqttPayloadProvider,
            payload: preferenceProvider.passwordValidationCode == 200 ? getCalibrationPayload(isToGem: isToGem).split(';') : payloadForGem,
            preferenceProvider: preferenceProvider,
            isToGem: isToGem
        );
      }

      await Future.delayed(Duration.zero, () {
        userData.addAll({
          'general': preferenceProvider.generalData!.toJson(),
          'contacts': [],
          'settings': preferenceProvider.individualPumpSetting?.map((item) => item.toJson()).toList(),
          'pumps': [],
          'calibrationSetting':  preferenceProvider.calibrationSetting?.map((item) => item.toJson()).toList(),
          'commonPumps': preferenceProvider.commonPumpSettings?.map((item) => item.toJson()).toList(),
          'notifications': {
            'event': preferenceProvider.eventNotificationData?.map((item) => item.toJson()).toList(),
            'alarm': preferenceProvider.alarmNotificationData?.map((item) => item.toJson()).toList(),
          },
          'hardware': payloadForSlave,
        });
      });

      await Future.delayed(Duration.zero, () async {
        final createUserPreference = await httpService.postRequest('createUserPreference', userData);
        final message = jsonDecode(createUserPreference.body);
        await showSnackBar(message: message['message']);
      });
    } catch (error, stackTrace) {
      showSnackBar(message: "Failed to update due to: $error");
      print("Error in preference sending: $error");
      print("Stack trace in preference sending: $stackTrace");
    }
  }

  Future<void> showSnackBar({required String message}) async{
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  message));
  }

  String onDelayTimer() {
    List<String> result = [];

    preferenceProvider.individualPumpSetting!.forEach((element) {
      String combinedResult = '${element.toGem()},${element.oDt()}';
      result.add(combinedResult);
    });

    return result.join(';');
  }

  String getPayload({required bool isToGem, required bool sendAll}) {
    List<String> result = [];
    for (var commonSetting in preferenceProvider.commonPumpSettings!) {
      List<String> temp = [];
      int oroPumpSerialNumber = commonSetting.serialNumber;
      String deviceId = commonSetting.deviceId;
      int categoryId = commonSetting.categoryId;
      int interfaceType = commonSetting.interfaceTypeId;
      int referenceNumber = commonSetting.referenceNumber;
      if(selectedOroPumpList.contains(deviceId)) {
        for (var settingCategory in commonSetting.settingList) {
          if (!sendAll ? (settingCategory.type == 24 && settingCategory.changed) : settingCategory.type == 24) {
            final payload = jsonEncode({"200": jsonEncode({"sentSms": 'voltageconfig,${getSettingValue(settingCategory)}'})});
            temp.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
          } else if (!sendAll ? (settingCategory.type == 26 && settingCategory.changed) : settingCategory.type == 26) {
            final payload = jsonEncode({"100": jsonEncode({"sentSms": 'ctConfig,${getSettingValue(settingCategory)}'})});
            temp.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
          }
        }

        int pumpIndex = 0;
        for (var individualPump in preferenceProvider.individualPumpSetting ?? []) {
          // print("individualPump deviceId ==> ${individualPump.deviceId}");
          // print("commonSetting deviceId ==> ${commonSetting.deviceId}");
          if (commonSetting.deviceId == individualPump.deviceId) {
            List<String> currentConfigList = [];
            List<String> delayConfigList = [];
            List<String> rtcConfigList = [];
            List<String> scheduleConfigList = [];
            pumpIndex++;
            for (var individualPumpSetting in individualPump.settingList) {
              switch (individualPumpSetting.type) {
                case 23:
                  if (!sendAll ? individualPumpSetting.changed : true) {
                    final payload = jsonEncode({"400-$pumpIndex": jsonEncode({"sentSms": 'currentconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    currentConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                  }
                  break;
                case 22:
                  if (!sendAll ? individualPumpSetting.changed : true) {
                    final payload = jsonEncode({"300-$pumpIndex": jsonEncode({"sentSms": 'delayconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    delayConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                    final payload2 = jsonEncode({"500-$pumpIndex": jsonEncode({"sentSms": 'rtcconfig,$pumpIndex,${getRtcValue(individualPumpSetting)}'})});
                    rtcConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload2+${categoryId}": payload2);
                  }
                  break;
                case 25:
                  if (!sendAll ? individualPumpSetting.changed : true) {
                    final payload = jsonEncode({"600-$pumpIndex": jsonEncode({"sentSms": 'scheduleconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    scheduleConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                  }
                  break;
              }
            }

            if (currentConfigList.isNotEmpty) temp.add(currentConfigList.join('_'));
            if (delayConfigList.isNotEmpty) temp.add(delayConfigList.join('_'));
            if (rtcConfigList.isNotEmpty) temp.add(rtcConfigList.join('_'));
            if (scheduleConfigList.isNotEmpty) temp.add(scheduleConfigList.join('_'));
          }
        }
      }

      result.addAll(temp);
    }

    return result.join(';');
  }

  String getFailedPayload({required bool isToGem, required bool sendAll}) {

    List<String> result = [];
    for (var commonSetting in preferenceProvider.commonPumpSettings!) {
      List<String> temp = [];
      int oroPumpSerialNumber = commonSetting.serialNumber;
      int categoryId = commonSetting.categoryId;
      String deviceId = commonSetting.deviceId;
      int interfaceType = commonSetting.interfaceTypeId;
      int referenceNumber = commonSetting.referenceNumber;
      if(selectedOroPumpList.contains(deviceId)){
        for (var settingCategory in commonSetting.settingList) {
          if (!sendAll ? (settingCategory.type == 24 && settingCategory.controllerReadStatus == "0") : settingCategory.type == 24) {
            final payload = jsonEncode({"200": jsonEncode({"sentSms": 'voltageconfig,${getSettingValue(settingCategory)}'})});
            temp.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
          } else if (!sendAll ? (settingCategory.type == 26 && settingCategory.controllerReadStatus == "0") : settingCategory.type == 26) {
            final payload = jsonEncode({"100": jsonEncode({"sentSms": 'ctConfig,${getSettingValue(settingCategory)}'})});
            temp.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
          }
        }

        int pumpIndex = 0;
        for (var individualPump in preferenceProvider.individualPumpSetting ?? []) {
          if (commonSetting.deviceId == individualPump.deviceId) {
            List<String> currentConfigList = [];
            List<String> delayConfigList = [];
            List<String> rtcConfigList = [];
            List<String> scheduleConfigList = [];
            pumpIndex++;
            for (var individualPumpSetting in individualPump.settingList) {
              switch (individualPumpSetting.type) {
                case 23:
                  if (!sendAll ? (individualPumpSetting.controllerReadStatus == "0") : true) {
                    final payload = jsonEncode({"400-$pumpIndex": jsonEncode({"sentSms": 'currentconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    currentConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                  }
                  break;
                case 22:
                  if (!sendAll ? (individualPumpSetting.controllerReadStatus == "0") : true) {
                    final payload = jsonEncode({"300-$pumpIndex": jsonEncode({"sentSms": 'delayconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    delayConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                    final payload2 = jsonEncode({"500-$pumpIndex": jsonEncode({"sentSms": 'rtcconfig,$pumpIndex,${getRtcValue(individualPumpSetting)}'})});
                    rtcConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload2+${categoryId}": payload2);
                  }
                  break;
                case 25:
                  if (!sendAll ? (individualPumpSetting.controllerReadStatus == "0") : true) {
                    final payload = jsonEncode({"600-$pumpIndex": jsonEncode({"sentSms": 'scheduleconfig,$pumpIndex,${getSettingValue(individualPumpSetting)}'})});
                    scheduleConfigList.add(isToGem ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}": payload);
                  }
                  break;
              }
            }

            if (currentConfigList.isNotEmpty) temp.add(currentConfigList.join('_'));
            if (delayConfigList.isNotEmpty) temp.add(delayConfigList.join('_'));
            if (rtcConfigList.isNotEmpty) temp.add(rtcConfigList.join('_'));
            if (scheduleConfigList.isNotEmpty) temp.add(scheduleConfigList.join('_'));
          }
        }
      }

      result.addAll(temp);
    }

    return result.join(';');
  }

  String getCalibrationPayload({required bool isToGem}) {
    List result = [];

    for (var commonSetting in preferenceProvider.calibrationSetting!) {
      List temp = [];
      List temp2 = [];
      int oroPumpSerialNumber = commonSetting.serialNumber;
      String deviceId = commonSetting.deviceId;
      int categoryId = commonSetting.categoryId;
      int interfaceType = commonSetting.interfaceTypeId;
      int referenceNumber = commonSetting.referenceNumber;

      if(selectedOroPumpList.contains(deviceId)) {
        for (var settingCategory in commonSetting.settingList) {
          if (settingCategory.type == 27) {
            final payload = jsonEncode({
              "900": jsonEncode({"sentSms": 'calibration,${getSettingValue(settingCategory)}'})
            });
            temp.add(isToGem
                ? "$oroPumpSerialNumber+$referenceNumber+$deviceId+$interfaceType+$payload+${categoryId}"
                : payload);
            // print("payload ==>$payload");
          } else if (settingCategory.type == 28) {
            var splitParts = [];
            if(isToGem) {
              splitParts = temp[0].split('+');
            }
            var tempMap = jsonDecode(jsonDecode(isToGem ? splitParts[4] : temp[0])['900']);
            temp2 = tempMap['sentSms'].toString().split(',');
            temp2.add('${getSettingValue(settingCategory)}');
            tempMap['sentSms'] = temp2.join(',');
            if(isToGem) {
              splitParts[4] = jsonEncode({"900": jsonEncode(tempMap)});
              temp[0] = splitParts.join('+');
            } else {
              temp[0] = jsonEncode({"900": jsonEncode(tempMap)});
            }
          } else if (settingCategory.type == 29) {
            var splitParts = [];
            if(isToGem) {
              splitParts = temp[0].split('+');
            }
            var tempMap = jsonDecode(jsonDecode(isToGem ? splitParts[4] : temp[0])['900']);
            temp2 = tempMap['sentSms'].toString().split(',');
            temp2.add('${getSettingValue(settingCategory)}');
            tempMap['sentSms'] = temp2.join(',');
            if(isToGem) {
              splitParts[4] = jsonEncode({"900": jsonEncode(tempMap)});
              temp[0] = splitParts.join('+');
            } else {
              temp[0] = jsonEncode({"900": jsonEncode(tempMap)});
            }
          }
        }
      }

      result.addAll(temp);
    }

    return result.join(';');
  }

  String getRtcValue(settingCategory) {
    List listToAdd = [];
    settingCategory.setting.forEach((setting) {
      String? value;
      if(setting.title == "RTC") {
        listToAdd.add(setting.value ? 1 : 0);
      }
      if(setting.title == "RTC TIMER") {
        List<String> rtcTimes = [];

        for(var i = 0; i < setting.rtcSettings!.length; i++){
          final onTime = setting.rtcSettings![i].onTime;
          final offTime = setting.rtcSettings![i].offTime;
          rtcTimes.add('${onTime.replaceAll(":", ",")},${offTime.replaceAll(":", ",")}');
        }
        value = rtcTimes.join(',');
      }
      if(value != null) {
        listToAdd.add(value);
      }
    });
    return listToAdd.join(",");
  }

  dynamic getSettingValue(settingCategory) {
    List<String> values = [];

    for (var setting in settingCategory.setting) {
      String? value;
      if (setting.value is bool) {
        if(setting.title != 'RTC') {
          value = setting.value ? "1" : "0";
        }
      } else if (setting.value is String) {
        switch (setting.widgetTypeId) {
          case 3:
            if(setting.title.contains("LIGHT")) {
              final result = setting.value.toString().split(':');
              value = setting.value.isEmpty ? "00,00" : "${result[0]},${result[1]}";
            } else {
              value = setting.value.isEmpty ? "00,00,00" : setting.value.replaceAll(":", ",");
            }
            break;
          case 1:
            value = setting.value.isEmpty ? "000" : setting.value;
            break;
          default:
            value = setting.value.isEmpty ? "0" : setting.value;
            break;
        }
      }
      if (value != null) values.add(value);
    }

    return values.join(",");
  }

  void showProgressDialog(BuildContext context, String message, String referenceNumber, int index, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: linearGradientLeading,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text("Sending $message ($referenceNumber)"),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Expanded(child: Text("Please wait for controller response...")),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (index + 1) / total,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('${index+1}/$total'),
                        // Text('${((index + 1) / total * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        stateSetter(() {
                          setState(() {
                            breakLoop = true;
                          });
                        });
                      },
                      child: Text("Cancel")
                  )
                ],
              );
            }
        );
      },
    );
  }

  void showAlertDialog({required String message, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message, style: TextStyle(color: Colors.red, fontSize: 16),),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> waitForControllerResponse2({
    required BuildContext dialogContext,
    required BuildContext context,
    required MqttPayloadProvider mqttPayloadProvider,
    required void Function() acknowledgedFunction,
    required String payload,
    required String deviceId,
    required int index,
    required String key,
    bool isToGem = false,
    required int total
  }) async {
    try {
      Map<String, dynamic> gemPayload = {};

      if (isToGem) {
        gemPayload = {
          "5900": [
            {"5901": payload},
            {"5902": "${overAllPvd.userId}"},
          ]
        };
      }

      await MQTTManager().publish(isToGem ? jsonEncode(gemPayload) : jsonDecode(payload)[key], "AppToFirmware/$deviceId");

      bool isAcknowledged = false;
      int maxWaitTime = 40;
      int elapsedTime = 0;
      int oroPumpIndex = 0;
      if(isToGem) {
        oroPumpIndex = preferenceProvider.commonPumpSettings!.indexWhere((element) => element.deviceId == payload.split('+')[2]);
      }

      showProgressDialog(dialogContext, statusMessages[key]!, preferenceProvider.commonPumpSettings![oroPumpIndex].deviceName, index, total);

      while (elapsedTime < maxWaitTime && !breakLoop) {
        await Future.delayed(const Duration(seconds: 1));
        elapsedTime++;
        if (mqttPayloadProvider.preferencePayload.isNotEmpty && mqttPayloadProvider.preferencePayload['cM'].contains(key)) {
          isAcknowledged = true;
          break;
        }
      }

      Navigator.of(dialogContext).pop();

      if (isAcknowledged) {
        preferenceProvider.updateControllerReaStatus(key: key, oroPumpIndex: oroPumpIndex);
        // setState(() {
        //   if(key.contains("100")) preferenceProvider.commonPumpSettings![oroPumpIndex].settingList[1].controllerReadStatus = "1";
        //   if(key.contains("200")) preferenceProvider.commonPumpSettings![oroPumpIndex].settingList[0].controllerReadStatus = "1";
        //   int pumpIndex = 0;
        //   for (var individualPump in preferenceProvider.individualPumpSetting ?? []) {
        //     if (preferenceProvider.commonPumpSettings![oroPumpIndex].deviceId == individualPump.deviceId) {
        //       pumpIndex++;
        //       for (var individualPumpSetting in individualPump.settingList) {
        //         switch (individualPumpSetting.type) {
        //           case 23:
        //             if(key.contains("400-$pumpIndex")) individualPumpSetting.controllerReadStatus= "1";
        //             break;
        //           case 22:
        //             if(key.contains("300-$pumpIndex") || key.contains("500-$pumpIndex")) individualPumpSetting.controllerReadStatus = "1";
        //             break;
        //           case 25:
        //             if(key.contains("600-$pumpIndex")) individualPumpSetting.controllerReadStatus = "1";
        //             break;
        //         }
        //       }
        //     }
        //   }
        //   if(preferenceProvider.passwordValidationCode == 200 && preferenceProvider.calibrationSetting!.isNotEmpty) {
        //     if(key.contains("900")) preferenceProvider.calibrationSetting![oroPumpIndex].settingList[1].controllerReadStatus = "1";
        //   }
        // });
        acknowledgedFunction();
      } else if(breakLoop){
        showAlertDialog(message: "Sending cancelled", context: dialogContext);
      } else {
        showAlertDialog(message: "${statusMessages[key]!} is failed to send for ${preferenceProvider.commonPumpSettings![oroPumpIndex].deviceName} (${preferenceProvider.commonPumpSettings![oroPumpIndex].deviceId})", context: dialogContext);
      }

      return isAcknowledged;
    } catch (error, stackTrace) {
      // Navigator.of(dialogContext).pop();
      print(stackTrace);
      showAlertDialog(message: error.toString(), context: dialogContext);
      return false;
    }
  }

  Future<void> processPayloads({
    required BuildContext context,
    required MqttPayloadProvider mqttPayloadProvider,
    required List<String> payload,
    required PreferenceProvider preferenceProvider,
    required bool isToGem
  }) async {
    for (var i = 0; i < payload.length; i++) {
      var payloadToDecode = isToGem ? payload[i].split('+')[4] : payload[i];
      var decodedData = jsonDecode(payloadToDecode);
      var key = decodedData.keys.first;
      // print(decodedData);
      bool isAcknowledged = await waitForControllerResponse2(
          dialogContext: context,
          context: context,
          acknowledgedFunction: () {},
          mqttPayloadProvider: mqttPayloadProvider,
          payload: payload[i],
          index: i,
          deviceId: "${preferenceProvider.generalData!.deviceId}",
          key: key,
          isToGem: isToGem,
          total: payload.length
      );

      if (!isAcknowledged) {
        break;
      }
    }
  }
}