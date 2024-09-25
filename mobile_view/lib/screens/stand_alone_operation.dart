import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ListOfFertilizerInSet.dart';
import '../Models/Customer/stand_alone_data_model.dart';
import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../state_management/MqttPayloadProvider.dart';
import '../widget/SCustomWidgets/custom_alert_dialog.dart';
import '../widget/SCustomWidgets/custom_native_time_picker.dart';
import '../widget/SCustomWidgets/custom_segmented_control.dart';
import '../widget/SCustomWidgets/custom_snack_bar.dart';
import 'customer/Planning/NewIrrigationProgram/program_library.dart';
import 'customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'customer/Planning/NewIrrigationProgram/selection_screen.dart';
import 'customer/Planning/NewIrrigationProgram/sequence_screen.dart';

class ManualOperationScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int customerId;
  final String deviceId;
  const ManualOperationScreen({super.key, required this.userId, required this.controllerId, required this.customerId, required this.deviceId});

  @override
  State<ManualOperationScreen> createState() => _ManualOperationScreenState();
}

class _ManualOperationScreenState extends State<ManualOperationScreen> with TickerProviderStateMixin{
  late ManualOperationData manualOperationData;
  late MqttPayloadProvider mqttPayloadProvider;
  List<ProgramData> programData = [];
  List<LineOrSequence> lineOrSequence = [];
  Map<String, dynamic> initialData = {};
  final List<String> devices = ["Valves", "Others"];
  int selectedSegment = 0;
  int selectedSerialNumber = 0;
  String selectedMode = "Manual";
  dynamic lastSelectedSequence;
  dynamic lastSelectedIndex;
  dynamic lastSelectedLocalSite;
  int startFlag = 0;
  int selectedMethod = 1;
  String programCategory = "";

  @override
  void initState() {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    manualOperationData = ManualOperationData.fromJson({});
    Future.delayed(Duration.zero, () async{
      await getUserProgramNameList(userId: widget.userId, controllerId: widget.controllerId);
      await getUserManualOperation(userId: widget.userId, controllerId: widget.controllerId);
      await getCustomerDashboardByManual(userId: widget.userId, controllerId: widget.controllerId, serialNumber: initialData['serialNumber']);
    });
    super.initState();
  }

  Future<void> getCustomerDashboardByManual({required int userId, required int controllerId, required int serialNumber}) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      print(userData);
      final getUserProgramSequence = await HttpService().postRequest('getCustomerDashboardByManual', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        // print(convertedJson['data']);
        if(mounted) {
          setState(() {
            manualOperationData = ManualOperationData.fromJson(convertedJson['data']);
            lineOrSequence = List.from(convertedJson['data']['lineOrSequence'].map((json) => LineOrSequence.fromJson(json)));
            selectedMethod = manualOperationData.method;
            startFlag = manualOperationData.startFlag;
            lastSelectedSequence = lineOrSequence.any((element) => element.lineOrSequence.selected == true) ? lineOrSequence.indexWhere((element) => element.lineOrSequence.selected == true) : null;
            lastSelectedIndex = manualOperationData.centralFilterSite.any((element) => element.site.selected == true) ? manualOperationData.centralFilterSite.indexWhere((element) => element.site.selected == true) : null;
            lastSelectedLocalSite = manualOperationData.localFilterSite.any((element) => element.site.selected == true) ? manualOperationData.localFilterSite.indexWhere((element) => element.site.selected == true) : null;
            // lastSelectedIndex = lineOrSequence.any((element) => element.lineOrSequence.selected == true) ? lineOrSequence.indexWhere((element) => element.lineOrSequence.selected == true) : null;
            // print("lastSelectedSequence ==> $lastSelectedSequence");
            // print("lastSelectedIndex ==> $lastSelectedIndex");
            // print("lastSelectedLocalSite ==> $lastSelectedLocalSite");
            // lastSelectedIndex = lineOrSequence[lastSelectedIndex].lineOrSequence.selected;
          });
        }
        // print(manualOperationData.lineOrSequence.map((e) => e.toJson()));
      } else {
        if (kDebugMode) {
          print("HTTP Request failed or received an unexpected response.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  Future<void> getUserManualOperation({required int userId, required int controllerId}) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };
      final getUserProgramSequence = await HttpService().postRequest('getUserManualOperation', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        // print("serialNumber ==> ${convertedJson['data']['serialNumber']}");
        setState(() {
          initialData = convertedJson['data'];
          selectedSerialNumber = initialData['serialNumber'];
          if(selectedSerialNumber == 0) {
            selectedMode = "Manual";
          } else {
            selectedMode = programData.firstWhere((element) => element.serialNumber == selectedSerialNumber).programName;
          }
          // selectedMode = (initialData['programName'] == "Default" || initialData['programName'] == "") ? "Manual" : initialData['programName'];
          // print("selectedMode ==> $selectedMode");
        });
        // print("initialData ==> $initialData");
      } else {
        if (kDebugMode) {
          print("HTTP Request failed or received an unexpected response.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  Future<void> getUserProgramNameList({required int userId, required int controllerId}) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };
      final getUserProgramSequence = await HttpService().postRequest('getUserProgramNameList', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        // print(convertedJson);
        if(mounted) {
          setState(() {
            programData = List.from(convertedJson['data'].map((json) => ProgramData.fromJson(json)));
          });
        }
      } else {
        if (kDebugMode) {
          print("HTTP Request failed or received an unexpected response.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Standalone operation", style: TextStyle(fontWeight: FontWeight.normal),),
        surfaceTintColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomSegmentedControl(
                    segmentTitles: const {
                      0: 'Valves',
                      1: 'Others',
                    },
                    groupValue: selectedSegment,
                    onChanged: (value) {
                      setState(() {
                        selectedSegment = value!;
                      });
                    },
                  ),
                  buildButton(
                      context: context,
                      // type: "Mode :- ",
                      dataList: ["Manual", ...programData.map((e) => e.programName)],
                      onSelected: (selectedValue) {
                        setState(() {
                          selectedMode = selectedValue;
                          if(selectedMode != "Manual") {
                            lastSelectedSequence = null;
                            lastSelectedIndex = null;
                            lastSelectedLocalSite = null;
                            selectedSerialNumber = programData.firstWhere((element) => element.programName == selectedValue).serialNumber;
                          }
                        });
                        if(selectedMode == "Manual") {
                          selectedSerialNumber = 0;
                          getCustomerDashboardByManual(userId: widget.userId, controllerId: widget.controllerId, serialNumber: 0);
                        } else {
                          final serialNumber = programData.firstWhere((element) => element.programName == selectedValue).serialNumber;
                          setState(() {
                            programCategory = programData.firstWhere((element) => element.programName == selectedValue).programCategory;
                          });
                          getCustomerDashboardByManual(userId: widget.userId, controllerId: widget.controllerId, serialNumber: serialNumber);
                          // selectedSequence = "";
                          // Future.delayed(const Duration(milliseconds: 500), () {
                          //   setState(() {
                          //     selectedSequence = lineOrSequence.map((e) => e.lineOrSequence.name).toList()[0];
                          //   });
                          // });
                        }
                      },
                      selected: selectedMode
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20,),
            if(selectedSegment == 1)
              Column(
                children: [
                  const SizedBox(height: 10,),
                  if(manualOperationData.sourcePump.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                      context: context,
                      title: "Source pump",
                      data: manualOperationData.sourcePump,
                      darkColor: darkColor1,
                      lightColor: lightColor1,
                      leading: Image.asset(
                        'assets/images/source_pump1.png',
                      ),
                    ),
                  if(manualOperationData.irrigationPump.isNotEmpty)
                    buildDeviceSection(
                      context: context,
                      title: "Irrigation pump",
                      data: manualOperationData.irrigationPump,
                      darkColor: darkColor2,
                      lightColor: lightColor2,
                      leading: Image.asset(
                        'assets/images/source_pump1.png',
                      ),
                    ),
                  if(manualOperationData.mainValve.isNotEmpty)
                    buildDeviceSection(
                      context: context,
                      title: "Main valve",
                      data: manualOperationData.mainValve,
                      lightColor: yellowLight,
                      darkColor: yellowDark,
                      leading: Image.asset(
                        'assets/images/m_valve.png',
                      ),
                    ),
                  if(manualOperationData.centralFertilizerSite.isNotEmpty && selectedMode == "Manual")
                    for(var index = 0; index < manualOperationData.centralFertilizerSite.length; index++)
                      buildDeviceSection(
                          context: context,
                          title: manualOperationData.centralFertilizerSite[index].site.name,
                          data: manualOperationData.centralFertilizerSite[index].itemData,
                          lightColor: yellowLight,
                          darkColor: yellowDark,
                          categoryId: manualOperationData.centralFertilizerSite[index].site.id,
                          categoryIndex: index,
                          leading: Image.asset(
                            'assets/images/central_fertilizer_site2.png',
                          ),
                          checkCondition: true,
                          categoryData2: manualOperationData.centralFertilizerSite
                      ),
                  if(manualOperationData.localFertilizerSite.isNotEmpty && selectedMode == "Manual")
                    for(var index = 0; index < manualOperationData.localFertilizerSite.length; index++)
                      buildDeviceSection(
                        context: context,
                        title: "${manualOperationData.localFertilizerSite[index].site.name} \n(Local Fertilizer)",
                        // title: "Local fertilizer site",
                        data: manualOperationData.localFertilizerSite[index].itemData,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        categoryId: manualOperationData.localFertilizerSite[index].site.id,
                        categoryIndex: index,
                        checkCondition: true,
                        categoryData2: manualOperationData.localFertilizerSite,
                        leading: Image.asset(
                          'assets/images/irrigation_line1.png',
                        ),
                      ),
                  if(manualOperationData.centralFilterSite.isNotEmpty)
                    for(var index = 0; index < manualOperationData.centralFilterSite.length; index++)
                      buildDeviceSection(
                        context: context,
                        title: manualOperationData.centralFilterSite[index].site.name,
                        data: manualOperationData.centralFilterSite[index].itemData,
                        categoryId: manualOperationData.centralFilterSite[index].site.id,
                        categoryIndex: index,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        checkCondition: true,
                        categoryData2: manualOperationData.centralFilterSite,
                        leading: Image.asset(
                          'assets/images/central_filtration_site.png',
                        ),
                      ),
                  if(manualOperationData.localFilterSite.isNotEmpty)
                    for(var index = 0; index < manualOperationData.localFilterSite.length; index++)
                      buildDeviceSection(
                        context: context,
                        title: "${manualOperationData.localFilterSite[index].site.name} \n(Local filter)",
                        data: manualOperationData.localFilterSite[index].itemData,
                        categoryId: manualOperationData.localFilterSite[index].site.id,
                        categoryIndex: index,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        checkCondition: true,
                        categoryData2: manualOperationData.localFilterSite,
                        leading: Image.asset(
                          'assets/images/irrigation_line1.png',
                        ),
                      ),
                  if(manualOperationData.agitator.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                      context: context,
                      title: "Agitator",
                      data: manualOperationData.agitator,
                      lightColor: yellowLight,
                      darkColor: yellowDark,
                      leading: SvgPicture.asset(
                        'assets/images/agitator_o.svg',
                      ),
                    ),
                  if(manualOperationData.boosterPump.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                      context: context,
                      title: "Booster pump",
                      data: manualOperationData.boosterPump,
                      lightColor: yellowLight,
                      darkColor: yellowDark,
                      leading: Image.asset(
                        'assets/images/booster_pump1.png',
                      ),
                    ),
                  if(manualOperationData.selector.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                        context: context,
                        title: "Selector",
                        data: manualOperationData.selector,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        leading: Image.asset(
                            "assets/images/selector.png"
                        )
                    ),
                  if(manualOperationData.fan.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                        context: context,
                        title: "Fan",
                        data: manualOperationData.fan,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        leading: Image.asset(
                            "assets/images/fan.png"
                        )
                    ),
                  if(manualOperationData.fogger.isNotEmpty && selectedMode == "Manual")
                    buildDeviceSection(
                        context: context,
                        title: "Fogger",
                        data: manualOperationData.fogger,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        leading: Image.asset(
                            "assets/images/fogger1.png"
                        )
                    ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // if(selectedMode != "Manual" && lineOrSequence.isNotEmpty && selectedSequence.isNotEmpty)
                          //   buildButton(
                          //       context: context,
                          //       dataList: lineOrSequence.map((e) => e.lineOrSequence.name).toList(),
                          //       onSelected: (selectedValue) {
                          //         setState(() {
                          //           selectedSequence = selectedValue;
                          //         });
                          //       },
                          //       selected: selectedSequence
                          //   ),
                          // if(selectedMethod == programMethods[1])
                          Container(
                              margin: const EdgeInsets.only(top: 10, right: 10, bottom: 20, left: 10),
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: customBoxShadow,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    // value: isDefaultMethod,
                                      value: manualOperationData.method == 3,
                                      onChanged: (newValue) {
                                        setState(() {
                                          manualOperationData.method = 3;
                                          // if(isDurationMethod || isFlowMethod) {
                                          //   isDurationMethod = false;
                                          //   isFlowMethod = false;
                                          //   isDefaultMethod = true;
                                          // } else {
                                          //   isDefaultMethod = !isDefaultMethod;
                                          // }
                                        });
                                      }
                                  ),
                                  Text('Timeless', overflow: TextOverflow.ellipsis, style: TextStyle(color: manualOperationData.method == 3 ? Colors.black : Colors.grey),),
                                ],
                              )
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10, right: 10, bottom: 20),
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: customBoxShadow,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    // value: isDurationMethod,
                                      value: manualOperationData.method == 1,
                                      onChanged: (newValue) {
                                        setState(() {
                                          manualOperationData.method = 1;
                                          // if(isDurationMethod) {
                                          //   isDurationMethod = false;
                                          //   if(!isFlowMethod) {
                                          //     isDefaultMethod = true;
                                          //   }
                                          // } else {
                                          //   isDurationMethod = true;
                                          //   isDefaultMethod = false;
                                          //   isFlowMethod = false;
                                          // }
                                        });
                                      }
                                  ),
                                  Text("Duration :", overflow: TextOverflow.ellipsis, style: TextStyle(color: manualOperationData.method == 1 ? Colors.black : Colors.grey)),
                                  const SizedBox(width: 10,),
                                  manualOperationData.method == 1
                                      ? CustomNativeTimePicker(
                                    initialValue: manualOperationData.time,
                                    is24HourMode: true,
                                    onChanged: (newValue){
                                      setState(() {
                                        manualOperationData.time = newValue;
                                      });
                                    },
                                  )
                                      : Text(manualOperationData.time, style: TextStyle(color: manualOperationData.method == 1 ? Colors.black : Colors.grey)),
                                  // Text(manualOperationData.time, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                                ],
                              )
                          ),
                          if(selectedMode != "Manual")
                            Container(
                                margin: const EdgeInsets.only(top: 10, right: 10, bottom: 20),
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: customBoxShadow,
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Checkbox(
                                      // value: isFlowMethod,
                                        value: manualOperationData.method == 2,
                                        onChanged: (newValue) {
                                          setState(() {
                                            manualOperationData.method = 2;
                                            // if(isFlowMethod) {
                                            //   isFlowMethod = false;
                                            //   if(!isDurationMethod) {
                                            //     isDefaultMethod = true;
                                            //   }
                                            // } else {
                                            //   isDurationMethod = false;
                                            //   isDefaultMethod = false;
                                            //   isFlowMethod = true;
                                            // }
                                          });
                                        }
                                    ),
                                    Text('Flow :', overflow: TextOverflow.ellipsis, style: TextStyle(color: manualOperationData.method == 2 ? Colors.black : Colors.grey)),
                                    const SizedBox(width: 10,),
                                    SizedBox(
                                      height: 40,
                                      width: 100,
                                      child: TextFormField(
                                        // maxLength: 7,
                                        enabled: manualOperationData.method == 2,
                                        initialValue: manualOperationData.flow,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                          border: OutlineInputBorder(),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                          LengthLimitingTextInputFormatter(7),
                                        ],
                                        onChanged: (newValue) {
                                          setState(() {
                                            manualOperationData.flow = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                            )
                        ],
                      ),
                    ),
                  ),
                  if(lineOrSequence.isNotEmpty)
                    for(var index = 0; index < lineOrSequence.length; index++)
                      buildDeviceSection(
                        context: context,
                        title: lineOrSequence[index].lineOrSequence.name,
                        data: lineOrSequence[index].valves,
                        lightColor: yellowLight,
                        darkColor: yellowDark,
                        categoryIndex: index,
                        categoryId: lineOrSequence[index].lineOrSequence.id,
                        categoryData: lineOrSequence,
                        trailing: lineOrSequence[index].lineOrSequence.id.toString().contains("SEQ")
                            ?
                        Switch(
                            value: lineOrSequence[index].lineOrSequence.selected,
                            onChanged: (newValue){
                              setState(() {
                                if(lastSelectedSequence != null) {
                                  if (lastSelectedSequence != index) {
                                    lineOrSequence[lastSelectedSequence].lineOrSequence.selected = false;
                                    lastSelectedSequence = index;
                                  }
                                } else {
                                  lastSelectedSequence = index;
                                  print(lastSelectedSequence);
                                }
                                lineOrSequence[index].lineOrSequence.selected = !lineOrSequence[index].lineOrSequence.selected;
                              });
                            }
                        ) : null,
                        leading: Image.asset(
                          'assets/images/valve.png',
                        ),
                      ),
                  // if(lineOrSequence.isNotEmpty)
                  //   for(var index = 0; index < (selectedMode == "Manual" ? lineOrSequence.length : 1); index++)
                  //     buildDeviceSection(
                  //       context: context,
                  //       title: selectedMode == "Manual"
                  //           ? lineOrSequence[index].lineOrSequence.name
                  //           : (selectedSequence.isNotEmpty ? lineOrSequence.firstWhere((element) => element.lineOrSequence.name == selectedSequence).lineOrSequence.name : ""),
                  //       data: selectedMode == "Manual"
                  //           ? lineOrSequence[index].valves
                  //           : (selectedSequence.isNotEmpty ? lineOrSequence.firstWhere((element) => element.lineOrSequence.name == selectedSequence).valves : []),
                  //       lightColor: yellowLight,
                  //       darkColor: yellowDark,
                  //       leading: SvgPicture.asset(
                  //         'assets/SVGPicture/valve.svg',
                  //       ),
                  //     ),
                ],
              ),
            const SizedBox(height: 80,)
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: customBoxShadow
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.keyboard_double_arrow_left),
                  Text('Go Back'),
                ],
              ),
            ),
            Row(
              children: [
                buildFloatingActionButton(
                    context: context,
                    label: "Start",
                    icon: Icons.play_arrow,
                    labelColor: Colors.white,
                    buttonColor: Colors.green,
                    onPressed: () {
                      setState(() {
                        manualOperationData.startFlag = 1;
                      });
                      sendFunction();
                    }
                ),
                const SizedBox(width: 10,),
                buildFloatingActionButton(
                    context: context,
                    label: " Stop",
                    icon: Icons.stop,
                    labelColor: Colors.white,
                    buttonColor: Colors.red,
                    onPressed: () {
                      setState(() {
                        manualOperationData.startFlag = 0;
                      });
                      sendFunction();
                    }
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void sendFunction() async {
    var selectedData = {};
    var selectedValves = [];
    List sNoList = [];
    String zoneSno = '';
    selectedData = manualOperationData.toJson();
    for (var element in lineOrSequence) {
      if(selectedMode == "Manual") {
        for (var element in element.valves) {
          if(element.selected == true) {
            selectedValves.add(element.toJson());
          } else {
            selectedValves.remove(element.toJson());
          }
        }
      } else {
        if(element.lineOrSequence.selected == true) {
          selectedValves.add(element.lineOrSequence.toJson());
          zoneSno = element.lineOrSequence.sNo;
          // print(selectedValves);
        }
        // else {
        //   programCategory = "";
        //   selectedValves.remove(element.lineOrSequence.toJson());
        // }
      }
    }
    // print('selectedValves : ${selectedValves}');
    selectedData['selected'].addAll(selectedValves);
    // print("selectedData ==> $selectedData");
    for(var element in selectedData['selected']) {
      sNoList.add(element['sNo'].toString());
    }
    // print(selectedData['selected']);
    final manualModePayload = {
      "800": [
        {
          "801": "${manualOperationData.startFlag},${sNoList.join('_')},${manualOperationData.method},${manualOperationData.method == 1 ? manualOperationData.time : manualOperationData.method == 2 ? manualOperationData.flow : ""}"
        },
        {
          "802": "${widget.userId}"
        }
      ]
    };

    String getSelectedItemData(List<NameData> list) {
      List<String> result = [];
      if(list.isNotEmpty) {
        for (var element in list) {
          if (element.selected) {
            print(element.hid);
            if(element.hid.contains("FL")) {
              result.add("1");
            } else {
              result.add(element.hid);
            }
          }
          else {
            if(element.hid.contains("FL")) {
              result.add("0");
            } else {
              result.remove(element.hid);
            }
          }
        }
      }
      // print("result ==> $result");
      return result.join("_");
    }
    String getSelectedSiteData(List<SiteData> list) {
      List<String> result = [];
      if(list.isNotEmpty) {
        for (var element in list) {
          for (var item in element.itemData) {
            if (item.selected) {
              if(item.location == element.site.hid) {
                if(!result.contains(element.site.hid)) {
                  result.add(element.site.hid);
                }
              } else {
                result.remove(element.site.hid);
              }
            }
          }
        }
      }
      // print(result);
      return result.join("_");
    }
    var selectedPumpIds = "";
    var selectedMainValveIds = "";
    var selectedCentralFilterSiteIds = "";
    var selectedCentralFiltersIds = "";
    var selectedLocalFilterSiteIds = "";
    var selectedLocalFiltersIds = "";
    var selectedFoggerIds = "";
    var selectedFanIds = "";
    if(manualOperationData.sourcePump.isNotEmpty) {
      selectedPumpIds += getSelectedItemData(manualOperationData.sourcePump);
    }
    if(manualOperationData.irrigationPump.isNotEmpty) {
      selectedPumpIds += getSelectedItemData(manualOperationData.irrigationPump);
    }
    if(manualOperationData.mainValve.isNotEmpty) {
      selectedMainValveIds += getSelectedItemData(manualOperationData.mainValve);
    }
    if(manualOperationData.localFertilizerSite.isNotEmpty) {
      selectedLocalFilterSiteIds += getSelectedSiteData(manualOperationData.localFertilizerSite);
    }
    if(manualOperationData.centralFilterSite.isNotEmpty) {
      selectedCentralFilterSiteIds += getSelectedSiteData(manualOperationData.centralFilterSite);
    }
    if (manualOperationData.centralFilterSite.isNotEmpty) {
      List<String> temp2 = [];

      for (var element in manualOperationData.centralFilterSite) {
        List<String> temp = [];

        if(element.site.hid == selectedCentralFilterSiteIds) {
          for (var item in element.itemData) {
            if (item.location == element.site.hid) {
              if (item.selected) {
                temp.add('1');
              } else {
                temp.add('0');
              }
            }
          }
        }

        if (temp.isNotEmpty) {
          temp2 = temp;
        }
      }

      selectedCentralFiltersIds = temp2.join('_');
    }
    if(manualOperationData.localFilterSite.isNotEmpty) {
      selectedLocalFilterSiteIds += getSelectedSiteData(manualOperationData.localFilterSite);
    }
    if(manualOperationData.localFilterSite.isNotEmpty) {
      List<String> temp2 = [];

      for (var element in manualOperationData.localFilterSite) {
        List<String> temp = [];

        if(element.site.hid == selectedLocalFilterSiteIds) {
          for (var item in element.itemData) {
            if (item.location == element.site.hid) {
              if (item.selected) {
                temp.add('1');
              } else {
                temp.add('0');
              }
            }
          }
        }

        if (temp.isNotEmpty) {
          temp2 = temp;
        }
      }

      selectedLocalFiltersIds = temp2.join('_');
    }
    if(manualOperationData.fan.isNotEmpty) {
      selectedFanIds += getSelectedItemData(manualOperationData.fan);
    }
    if(manualOperationData.fogger.isNotEmpty) {
      selectedFoggerIds += getSelectedItemData(manualOperationData.fogger);
    }

    // print("selectedCentralFilterSiteIds ==> $selectedCentralFilterSiteIds");
    // print("selectedCentralFiltersIds ==> $selectedCentralFiltersIds");
    // print("selectedCentralFilterSiteIds ==> $selectedLocalFilterSiteIds");
    // print("selectedCentralFiltersIds ==> $selectedLocalFiltersIds");

    final programSno = selectedMode != "Manual" ? programData.firstWhere((element) => element.programName == selectedMode).serialNumber : "";
    final programCategory = selectedMode != "Manual"
        ? programData.firstWhere((element) => element.programName == selectedMode).programCategory
        : "";

    final programModePayload = {
      "3900": [
        {
          "3901":
          "${manualOperationData.startFlag},"
              "$programCategory,"
              "$programSno,"
              "$zoneSno,"
              "$selectedPumpIds,"
              "$selectedMainValveIds,"
              "$selectedCentralFilterSiteIds,"
              "$selectedCentralFiltersIds,"
              "$selectedLocalFilterSiteIds,"
              "$selectedLocalFiltersIds,"
              "$selectedFanIds,"
              "$selectedFoggerIds,"
              "${manualOperationData.method},"
              "${manualOperationData.method == 1 ? manualOperationData.time : manualOperationData.method == 2 ? manualOperationData.flow : ""}"
        },
        {
          "3902": "${widget.userId}"
        }
      ]
    };
    final body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "serialNumber": selectedSerialNumber,
      "programName": selectedMode,
      // "startFlag": "2",
      "startFlag": manualOperationData.startFlag,
      "method": manualOperationData.method,
      "duration": manualOperationData.time,
      "flow": manualOperationData.flow,
      "selection": manualOperationData.startFlag == 1 ? selectedData['selected'] : [],
      "fromDashboard": false,
      "hardware": selectedMode == "Manual" ? manualModePayload : programModePayload,
      // "manualOperation": manualOperationDataToSend,
      "createUser": widget.userId
    };
    // print("programModePayload ==> $programModePayload");
    if(selectedData['selected'].isNotEmpty) {
      mqttPayloadProvider.messageFromHw = null;
      try {
        validatePayloadSent(
            dialogContext: context,
            context: context,
            mqttPayloadProvider: mqttPayloadProvider,
            acknowledgedFunction: () => null,
            payload: selectedMode == "Manual" ? manualModePayload : programModePayload,
            payloadCode: selectedMode == "Manual" ? "800" : "3900",
            deviceId: widget.deviceId
        ).whenComplete(() async{
          if(
          (mqttPayloadProvider.messageFromHw['PayloadCode'] == "3900" && mqttPayloadProvider.messageFromHw['Code'] == "200")
              || (mqttPayloadProvider.messageFromHw['PayloadCode'] == "800" && mqttPayloadProvider.messageFromHw['Code'] == "200")
          ) {
            final createUserProgram = await HttpService().postRequest('createUserManualOperation', body);
            // print("body while send ==> $body");
            final response = jsonDecode(createUserProgram.body);
            // print("response ==> $response");
            Future.delayed(Duration.zero, () {
              if(createUserProgram.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
              }
            });
            Navigator.of(context).pop();
          }
          else {
            print("error");
          }
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
        if (kDebugMode) {
          print("Error: $error");
        }
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
                title: "Warning",
                content: "Nothing is selected to turn on. Please select at least one device!",
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK")
                  )
                ]
            );
          }
      );
    }
  }

  Future<void> validateWithAck(dialogContext, payload, code) async {
    try {
      await MQTTManager().publish(jsonEncode(payload), "AppToFirmware/${widget.deviceId}");

      bool isAcknowledged = false;
      int maxWaitTime = 10;
      int elapsedTime = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Please wait..."),
                ],
              ),
            ),
          );
        },
      );

      while (elapsedTime < maxWaitTime) {
        await Future.delayed(const Duration(seconds: 1));
        elapsedTime++;

        if (mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['PayloadCode'] == code) {
          isAcknowledged = true;
          break;
        }
      }

      Navigator.of(context).pop();

      if (isAcknowledged) {
        if (mqttPayloadProvider.messageFromHw['Code'] == "200") {
          showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller");
        } else {
          showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller");
        }
      } else {
        showAlertDialog(message: "Controller is not responding");
      }
    } catch (error, stackTrace) {
      Navigator.of(context).pop(); // Hide loading indicator in case of error
      print("Error $error");
      print("stackTrace $stackTrace");
      showAlertDialog(message: error.toString());
    }
  }

  void showAlertDialog({required String message, Widget? child}) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: child ?? Text(message),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK")
              )
            ],
          );
        }
    );
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
  }

  Widget buildButton({required BuildContext context,
    required dataList, required void Function(String) onSelected,
    required selected,
    String? type
  }) {
    return buildPopUpMenuButton(
      context: context,
      dataList: dataList,
      onSelected: onSelected,
      offset: const Offset(0, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(type != null)
            Text(type),
          const SizedBox(width: 10,),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            decoration: BoxDecoration(
              // color: const Color(0xffE0FFF7),
              gradient: linearGradientLeading,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2, 4),
                  blurRadius: 8,
                  color: const Color(0xffCFCFCF).withOpacity(0.25),
                ),
              ],
              // border: Border.all(color: Theme.of(context).primaryColor, width: 0.1)
            ),
            child: Row(
              children: [
                Text(selected, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
                const SizedBox(width: 5,),
                Icon(Icons.keyboard_arrow_down, color: Colors.white,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeviceSection({required BuildContext context,
    required String title, required List<NameData> data,
    required darkColor, required lightColor, leading, categoryIndex, String? categoryId,
    List<LineOrSequence>? categoryData,
    trailing,
    bool checkCondition = false,
    List<SiteData>? categoryData2,
  }) {
    // const lightColor = Color(0xffE3FFF5);
    final darkColor = Theme.of(context).primaryColor.withOpacity(0.8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLineAndValveContainerUpdated(
            context: context,
            height: trailing != null ? 120 : 100,
            title: title,
            showSubList: false,
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle
              ),
              child: leading,
            ),
            trailing: trailing,
            dataList: data,
            children: [
              for (var index = 0; index < data.length; index++)
                IntrinsicWidth(
                  child: Container(
                    // decoration: BoxDecoration(
                    //   boxShadow: [
                    //     BoxShadow(
                    //       offset: const Offset(0, 4),
                    //       blurRadius: 4,
                    //       color: const Color(0xffCFCFCF).withOpacity(0.25),
                    //     ),
                    //   ],
                    // ),
                    child: MaterialButton(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      onPressed: (){
                        setState(() {
                          if(selectedMode != "Manual") {
                            bool isCFISI = categoryId?.contains("CFISI") ?? false;
                            bool isIL = (categoryId?.contains("IL") ?? false) && title.contains('filter');
                            // Helper function to deselect items based on category ID
                            void deselectItems(int? index) {
                              if (index == null || categoryData2 == null) return;
                              var category = categoryData2[index];

                              if (isCFISI) {
                                for (var element in category.itemData) {
                                  element.selected = false;
                                }
                              } else if (isIL) {
                                for (var element in category.itemData) {
                                  element.selected = false;
                                }
                              } else {
                                category.site.selected = false;
                              }
                            }

                            if(isCFISI) {
                              if (lastSelectedIndex != null && lastSelectedIndex != categoryIndex) {
                                deselectItems(lastSelectedIndex);
                                lastSelectedIndex = categoryIndex;
                              } else if (lastSelectedIndex == null) {
                                lastSelectedIndex = categoryIndex;
                              }
                            }

                            if(isIL) {
                              if (lastSelectedLocalSite != null && lastSelectedLocalSite != categoryIndex) {
                                deselectItems(lastSelectedLocalSite);
                                lastSelectedLocalSite = categoryIndex;
                              } else if (lastSelectedLocalSite == null) {
                                lastSelectedLocalSite = categoryIndex;
                              }
                            }
                          }

                          // Toggle selection if category ID does not contain "SEQ"
                          print(categoryId?.contains("SEQ"));
                          if(!(categoryId?.contains("SEQ") ?? false)) {
                            data[index].selected = !data[index].selected;
                          }
                        });
                      },
                      elevation: 0,
                      // elevation: data[index].selected ? 5 : 0,
                      // splashColor: Theme.of(context).primaryColor,
                      animationDuration: const Duration(milliseconds: 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      color: data[index].selected ? Color(0xffC8EAE7): Color(0xffF2F2F2),
                      // color: data[index].selected ? darkColor.withOpacity(0.2): lightColor.withOpacity(0.3),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(data[index].name, style: TextStyle(fontWeight: FontWeight.w600, ),),
                              if(data[index].location.isNotEmpty && (title == "Source pump" || title == "Irrigation pump" || title == "Main valve" || (categoryId?.contains("SEQ") ?? false)))
                                Text("Location: ${data[index].location}", style: TextStyle( fontWeight: FontWeight.normal),),
                            ],
                          ),
                          SizedBox(width: 5,),
                          data[index].selected
                              ? CircleAvatar(
                            radius: 15,
                            backgroundColor: cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: leading,
                            ),
                          )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}

Widget buildFloatingActionButton({required BuildContext context,
  required void Function()? onPressed, IconData? icon, required String label, Color? buttonColor, Color? labelColor}) {
  return MaterialButton(
    onPressed: onPressed,
    color: buttonColor,
    elevation: 10,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
    ),
    child: Row(
      children: [
        if(icon != null)
          Icon(icon, color: labelColor,),
        if(icon != null)
          const SizedBox(width: 5,),
        Text(label, style: TextStyle(color: labelColor),),
      ],
    ),
  );
}
