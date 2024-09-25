import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/preview_screen.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/program_library.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/selection_screen.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/sequence_screen.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/water_and_fertilizer_screen.dart';
import 'package:mobile_view/state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../widget/SCustomWidgets/custom_alert_dialog.dart';
import '../../../../widget/SCustomWidgets/custom_snack_bar.dart';
import '../../../../widget/SCustomWidgets/custom_tab.dart';
import '../../Dashboard/Mobile Dashboard/home_screen.dart';
import 'alarm_screen.dart';
import 'conditions_screen.dart';
import 'done_screen.dart';

const LinearGradient linearGradientLeading = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff1D808E), Color(0xff044851)],
);

class IrrigationProgram extends StatefulWidget {
  final int userId;
  final int controllerId;
  final String deviceId;
  final int serialNumber;
  final String? programType;
  final bool? conditionsLibraryIsNotEmpty;
  final bool fromDealer;
  const IrrigationProgram({Key? irrigationProgramKey,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    this.programType,
    this.conditionsLibraryIsNotEmpty, required this.deviceId, required this.fromDealer}) :super(key: irrigationProgramKey);

  @override
  State<IrrigationProgram> createState() => _IrrigationProgramState();
}

class _IrrigationProgramState extends State<IrrigationProgram> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IrrigationProgramMainProvider irrigationProvider = IrrigationProgramMainProvider();
  late MqttPayloadProvider mqttPayloadProvider;
  bool isPressed = false;
  final HttpService httpService = HttpService();
  final delete = const SnackBar(content: Center(child: Text('The sequence is erased!')));
  final singleSelection = const SnackBar(content: Center(child: Text('Single valve selection is enabled')));
  final multipleSelection = const SnackBar(content: Center(child: Text('Multiple valve selection is enabled')));
  dynamic apiData = {};
  dynamic waterAndFertData = [];
  late List<String> labels;
  late List<IconData> icons;

  @override
  void initState() {
    super.initState();
    final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    Tuple<List<String>, List<IconData>> result = irrigationProvider.getLabelAndIcon(sno: widget.serialNumber, programType: widget.programType, conditionLibrary: widget.conditionsLibraryIsNotEmpty);
    labels = result.labels;
    icons = result.icons;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // var programPvd = Provider.of<IrrigationProgramProvider>(context,listen: false);
        getData(irrigationProvider, widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.updateTabIndex(0);
        irrigationProvider.doneData(widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramSequence(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
        irrigationProvider.scheduleData(widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramCondition(widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramSelection(widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramCondition(widget.userId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramAlarm(widget.userId, widget.controllerId, widget.serialNumber);
      });
      _tabController = TabController(
        length: labels.length,
        vsync: this,
      );
      _tabController.addListener(() {
        irrigationProvider.updateTabIndex(_tabController.index);
      });
    }
  }

  void getData(IrrigationProgramMainProvider programPvd, userId, controllerId, serialNumber)async{
    programPvd.clearWaterFert();
    try{
      HttpService service = HttpService();
      var fert = await service.postRequest('getUserPlanningFertilizerSet', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response = await service.postRequest('getUserProgramWaterAndFert', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response1 = await service.postRequest('getUserConstant', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var jsonData = response.body;
      var jsonData1 = response1.body;
      var jsonData2 = fert.body;
      var myData = jsonDecode(jsonData);
      var myData1 = jsonDecode(jsonData1);
      var myData2 = jsonDecode(jsonData2);
      programPvd.editApiData(myData['data']['default']);
      programPvd.editSequenceData(myData['data']['waterAndFert']);
      programPvd.editRecipe(myData2['data']['fertilizerSet']['fertilizerSet']);
      programPvd.editConstantSetting(myData1['data']['constant']);
    }catch(e){
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // irrigationProvider.clearDispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  void _navigateToNextTab() {
    _tabController.animateTo((_tabController.index + 1) % _tabController.length);
  }

  void _navigateToPreviousTab() {
    _tabController.animateTo((_tabController.index - 1 + _tabController.length) % _tabController.length);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    final irrigationProgram = ((mainProvider.programDetails?.programType == "Irrigation Program")
        || (mainProvider.selectedProgramType == "Irrigation Program"));
    int selectedIndex = mainProvider.selectedTabIndex;
    // print("irrigation program class");

    if(mainProvider.irrigationLine != null || mainProvider.programDetails != null) {
      final program = mainProvider.programDetails!.programName.isNotEmpty
          ? mainProvider.programName == ''? "Program ${mainProvider.programCount+1}" : mainProvider.programName
          : mainProvider.programDetails!.defaultProgramName;
      return LayoutBuilder(
        builder: (context, constraints
            ) {
          return DefaultTabController(
            length: labels.length,
            child: Scaffold(
              appBar: MediaQuery.of(context).size.width < 600
                  ? AppBar(
                // title: Text(mainProvider.programName != '' ? mainProvider.programName : 'New Program'),
                title: Text(widget.serialNumber == 0 ? "New Program" : program, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    mainProvider.programLibraryData(widget.userId, widget.controllerId);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor,),
                ),
                bottom: constraints.maxWidth < 600
                    ?
                PreferredSize(
                  preferredSize: const Size.fromHeight(80.0),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.background,
                    child: TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      tabs: [
                        for (int i = 0; i <  labels.length; i++)
                          InkWell(
                            onTap: () {
                              if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                                validatorFunction(context, mainProvider);
                              } else {
                                validateSelection(index: i);
                              }
                            },
                            child: CustomTab(
                              height: 80,
                              label: labels[i],
                              content: icons[i],
                              tabIndex: i,
                              selectedTabIndex: mainProvider.selectedTabIndex,
                            ),
                          ),
                      ],
                    ),
                  ),
                ) : null,
              )
                  : PreferredSize(preferredSize: const Size(0, 0), child: Container()),
              backgroundColor: const Color(0xffF9FEFF),
              body: Row(
                children: <Widget>[
                  if (constraints.maxWidth > 500)
                    Container(
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
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const BackButton(color: Colors.white,),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: Text(
                                      widget.serialNumber == 0 ? "New Program" : program,
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
                          ),
                          for (int i = 0; i <  labels.length; i++)
                            Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  title: !(constraints
                                      .maxWidth > 500 && constraints
                                      .maxWidth <= 600)
                                      ? Text(labels[i], style: const TextStyle(color: Colors.white),) : null,
                                  leading: Icon(icons[i], color: Colors.white,),
                                  selected: _tabController.index == i,
                                  onTap: () {
                                    // _navigateToTab(i);
                                    if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                                      validatorFunction(context, mainProvider);
                                    } else {
                                      validateSelection(index: i);
                                    }
                                    // if(_tabController.index == 0 && (irrigationProvider.programName.isEmpty || widget.serialNumber == 0) ){
                                    //   validatorFunction(context, mainProvider);
                                    // } else {
                                    //   _navigateToTab(i);
                                    // }
                                  },
                                  selectedTileColor: _tabController.index == i ? const Color(0xff2999A9) : null,
                                  hoverColor: _tabController.index == i ? const Color(0xff2999A9) : null
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children:  [
                        for (int i = 0; i < labels.length; i++)
                          _buildTabContent(
                              index: i,
                              isIrrigationProgram: irrigationProgram,
                              conditionsLibraryIsNotEmpty: (widget.conditionsLibraryIsNotEmpty ?? false)
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(selectedIndex != 0)
                    buildActionButtonColored(
                        key: "prevPage",
                        icon: Icons.navigate_before,
                        label: "Back",
                        onPressed: () {
                          _navigateToPreviousTab();
                        },
                      context: context
                    ),
                  const SizedBox(width: 20,),
                  if(selectedIndex != labels.length-1)
                    buildActionButtonColored(
                        key: "nextPage",
                        icon: Icons.navigate_next,
                        label: "Next",
                        context: context,
                        onPressed: () {
                          if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                            validatorFunction(context, mainProvider);
                          } else {
                            validateSelection2();
                          }
                          // if(_tabController.index == 0 && (irrigationProvider.programName.isEmpty || widget.serialNumber == 0)){
                          //   validatorFunction(context, mainProvider);
                          // } else {
                          //   _navigateToNextTab();
                          // }
                        }
                    ),
                  if(selectedIndex == labels.length-1)
                    buildActionButtonColored(
                        key: "send",
                        icon: Icons.send,
                        label: "Save",
                        context: context,
                        onPressed: () {
                          mainProvider.programLibraryData(widget.userId, widget.controllerId);
                          sendFunction();
                        }
                    ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          );
        },
      );
    } else {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }
  }

  void validateSelection({required int index}) {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);

    if(widget.programType == "Irrigation Program") {
      if(labels.length == 7 ? _tabController.index == 2 : _tabController.index == 3){
        if(mainProvider.selectionModel!.data.headUnits!.isNotEmpty && mainProvider.selectionModel!.data.headUnits!.every((element) => element.selected == false)) {
          showValidationAlert(content: "Please select at least one head unit!");
        } else if(!(mainProvider.isPumpStationMode) && mainProvider.selectionModel!.data.irrigationPump!.isNotEmpty && mainProvider.selectionModel!.data.irrigationPump!.every((element) => element.selected == false)){
          showValidationAlert(
              content: "Are you sure to proceed without pump selection?",
              ignoreValidation: mainProvider.selectionModel!.data.irrigationPump!.length > 1
          );
        } else if(mainProvider.isPumpStationMode) {
          mainProvider.calculateTotalFlowRate();
          if(mainProvider.pumpStationValveFlowRate < mainProvider.totalValveFlowRate) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red,),
                        Text("Warning!", style: TextStyle(color: Colors.red),)
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Pump station range is not sufficient for total zone's valve flow rate!", style: TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pump station range', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Text('${mainProvider.pumpStationValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total zone valve flow rate', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Text('${mainProvider.totalValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK")
                      )
                    ],
                  );
                }
            );
          } else {
            _navigateToTab(index);
          }
        } else {
          _navigateToTab(index);
        }
      } else{
        _navigateToTab(index);
      }
    } else {
      _navigateToTab(index);
    }
  }

  void validateSelection2() {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if(widget.programType == "Irrigation Program") {
      if(labels.length == 7 ? _tabController.index == 2 : _tabController.index == 3){
        if(mainProvider.selectionModel!.data.headUnits!.isNotEmpty && mainProvider.selectionModel!.data.headUnits!.every((element) => element.selected == false)) {
          showValidationAlert(content: "Please select at least one head unit!");
        } else if(!(mainProvider.isPumpStationMode) && mainProvider.selectionModel!.data.irrigationPump!.isNotEmpty && mainProvider.selectionModel!.data.irrigationPump!.every((element) => element.selected == false)){
          showValidationAlert(
              content: "Are you sure to proceed without pump selection?",
              ignoreValidation: mainProvider.selectionModel!.data.irrigationPump!.length >= 1
          );
        } else if(mainProvider.isPumpStationMode) {
          mainProvider.calculateTotalFlowRate();
          if(mainProvider.pumpStationValveFlowRate <= mainProvider.totalValveFlowRate) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red,),
                        Text("Warning!", style: TextStyle(color: Colors.red),)
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Pump station range is not sufficient for total zone's valve flow rate!", style: TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pump station range', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Text('${mainProvider.pumpStationValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total zone valve flow rate', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Text('${mainProvider.totalValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK")
                      )
                    ],
                  );
                }
            );
          } else {
            _navigateToNextTab();
          }
        }
        else {
          _navigateToNextTab();
        }
      } else{
        _navigateToNextTab();
      }
    } else {
      _navigateToNextTab();
    }
  }

  void showValidationAlert({required String content, bool ignoreValidation = false}) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
              title: "Warning",
              content: content,
              actions: [
                TextButton(
                    onPressed: () {
                      if(!ignoreValidation) {
                        Navigator.of(context).pop();
                      } else {
                        _navigateToNextTab();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(ignoreValidation ? "Yes" : "OK")
                ),
                if(ignoreValidation)
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No", style: TextStyle(color: Colors.red),)
                  )
              ]
          );
        }
    );
  }

  void sendFunction() async{
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    Map<String, dynamic> dataToMqtt = {};
    dataToMqtt = mainProvider.dataToMqtt(widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber, widget.programType);
    var userData = {
      "defaultProgramName": mainProvider.defaultProgramName,
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "createUser": widget.userId,
      "serialNumber": widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber,
    };
    if(mainProvider.irrigationLine!.sequence.isNotEmpty) {
      // print(mainProvider.selectionModel.data!.toJson());
      var dataToSend = {
        "sequence": mainProvider.irrigationLine!.sequence,
        "schedule": mainProvider.sampleScheduleModel!.toJson(),
        "conditions": mainProvider.sampleConditions!.toJson(),
        "waterAndFert": mainProvider.sequenceData,
        "selection": mainProvider.selectionModel!.data.toJson(),
        "alarm": mainProvider.newAlarmList!.toJson(),
        "programName": mainProvider.programName,
        "priority": mainProvider.priority,
        "delayBetweenZones": mainProvider.programDetails!.delayBetweenZones,
        "adjustPercentage": mainProvider.programDetails!.adjustPercentage,
        "incompleteRestart": mainProvider.isCompletionEnabled ? "1" : "0",
        "controllerReadStatus": 0,
        "programType": mainProvider.selectedProgramType,
        "hardware": dataToMqtt
      };
      userData.addAll(dataToSend);
      // print(dataToMqtt['2500'][1]['2502'].split(',').join('\n'));
      // print(dataToMqtt['2500'][1]['2502'].split(',').length);
      try {
        // MQTTManager().publish(jsonEncode(dataToMqtt), "AppToFirmware/${widget.deviceId}");
        await validatePayloadSent(
            dialogContext: context,
            context: context,
            mqttPayloadProvider: mqttPayloadProvider,
            acknowledgedFunction: () {
              setState(() {
                userData['controllerReadStatus'] = "1";
              });
              // showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller", context: context);
            },
            payload: dataToMqtt,
            payloadCode: "2500",
            deviceId: widget.deviceId
        ).whenComplete(() {
          Future.delayed(const Duration(seconds: 2), () async {
            final createUserProgram = await httpService.postRequest('createUserProgram', userData);
            final response = jsonDecode(createUserProgram.body);
            if(createUserProgram.statusCode == 200) {
              await irrigationProvider.programLibraryData(widget.userId, widget.controllerId);
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
              irrigationProvider.updateBottomNavigation(1);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId, fromDealer: widget.fromDealer,)),
              );
            }
          });
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
        print("Error: $error");
      }
      // print(mainProvider.selectionModel.data!.localFertilizerSet!.map((e) => e.toJson()));
    }
    else {
      showAdaptiveDialog<Future>(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Warning',
            content: "Select valves to be sequence for Irrigation Program",
            actions: [
              TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
            ],
          );
        },
      );
    }
  }

  void validatorFunction(BuildContext context, IrrigationProgramMainProvider mainProvider) {
    if(mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
      final indexWhereEmpty = mainProvider.irrigationLine!.sequence.indexWhere((element) => element['valve'].isEmpty);
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text('Verify to delete'),
            content: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'The sequence is empty at ', style: TextStyle(color: Colors.black)),
                  TextSpan(text: '${mainProvider.irrigationLine!.sequence[indexWhereEmpty]['name']}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    // if(mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isNotEmpty)) {
    //   _showAdaptiveDialog(context, mainProvider);
    // } else {
    //   final indexWhereEmpty = mainProvider.irrigationLine!.sequence.indexWhere((element) => element['valve'].isEmpty);
    //   showAdaptiveDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         // title: Text('Verify to delete'),
    //         content: RichText(
    //           text: TextSpan(
    //             children: [
    //               const TextSpan(text: 'The sequence is empty at ',),
    //               TextSpan(text: '${mainProvider.irrigationLine!.sequence[indexWhereEmpty]['name']}',
    //                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
    //             ],
    //           ),
    //         ),
    //         actions: [
    //           TextButton(
    //             child: const Text("OK"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  void _showAdaptiveDialog(BuildContext context, IrrigationProgramMainProvider programProvider,) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          Consumer<IrrigationProgramMainProvider>(
            builder: (context, programProvider, child) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: programProvider.scheduleTypes.map((e) {
                    return RadioListTile(
                        title: Text(e),
                        value: e,
                        groupValue: programProvider.selectedScheduleType,
                        onChanged: (newValue) => programProvider.updateSelectedScheduleType(newValue));
                  }).toList(),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        _navigateToNextTab();
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('OK')),
                ],
              );
            },
          ),
    );
  }

  Widget _buildTabContent({required int index, required bool isIrrigationProgram, required bool conditionsLibraryIsNotEmpty}) {
    switch (index) {
      case 0:
        return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
      case 1:
        return ScheduleScreen(serialNumber: widget.serialNumber,);
      case 2:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, deviceId: widget.deviceId,)
            : const SelectionScreen()
            : WaterAndFertilizerScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,);
      case 3:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? const SelectionScreen()
            : WaterAndFertilizerScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,)
            : const NewAlarmScreen2();
      case 4:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? WaterAndFertilizerScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,)
            : const NewAlarmScreen2()
            : AdditionalDataScreen(serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,);
      case 5:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? const NewAlarmScreen2()
            : AdditionalDataScreen(serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,)
            : const PreviewScreen();
      case 6:
        return conditionsLibraryIsNotEmpty
            ? AdditionalDataScreen(serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram,)
            : const PreviewScreen();
      case 7:
        return conditionsLibraryIsNotEmpty
            ? const PreviewScreen()
            : Container();
      default:
        return Container();
    }
  }
}

Widget buildActionButtonColored({required String key, required IconData icon, required String label, required VoidCallback onPressed, required BuildContext context}) {
  return MaterialButton(
    key: Key(key),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25)
    ),
    color: Theme.of(context).primaryColor,
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Icon(icon, color: Colors.white,),
    ),
  );
}

Widget buildCustomSideMenuBar(
    {required BuildContext context, required String title, required BoxConstraints constraints, required List<Widget> children, Widget? bottomChild}) {
  return Container(
    // width: constraints
    // .maxWidth * 0.15,
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
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
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