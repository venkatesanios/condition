import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../Models/condition_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/condition_provider.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/HoursMinutesSeconds.dart';
import '../../../widget/validateMqtt.dart';
enum Conditiontype { Program, Moisture, Level }

class ConditionScreen extends StatefulWidget {
  const ConditionScreen(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID,
        required this.isProgram, this.serialNumber});
  final userId, controllerId, serialNumber;
  final String deviceID;
  final bool isProgram;

  @override
  State<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        // if (constraints.maxWidth <= 600) {
        // Render mobile content
        return ConditionUI(
          userId: overAllPvd.userId,
          controllerId: overAllPvd.controllerId,
          deviceID: overAllPvd.imeiNo, isProgram: widget.isProgram,
          serialNumber: widget.serialNumber,
        );
      },
    );
  }
}

class ConditionUI extends StatefulWidget {
  const ConditionUI(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID, required this.isProgram, this.serialNumber});

  final userId, controllerId, serialNumber;
  final String deviceID;
  final bool isProgram;

  @override
  State<ConditionUI> createState() => _ConditionUIState();
}

class _ConditionUIState extends State<ConditionUI>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // int selectIndexRow = 0;
  int tabclickindex = 0;
  dynamic jsonData;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late MqttPayloadProvider mqttPayloadProvider;
  List<String> conditionHdrList = [
    'SNo',
    'Name',
    'Enable',
    'Scan Time',
    'Condition IsTrue',
    'Start Time',
    'Stop Time',
    'conditionBypass',
  ];
  String usedProgramDropDownStr = '--Select Category--';
  List<UserNames>? usedProgramDropDownList = [];
  List<String>? AfterProgramDropDownList = [];
  String afterDropDownStr2 = '';
  String befireDropDownStr3 = '';
  String usedProgramDropDownStr2 = '';
  String usedProgramDropDownStr3 = '';
  String dropDownValues = '';
  ConditionModel _conditionModel = ConditionModel();
  String hint = 'Enter Flow Values';
  String dropDownTitle = '';
  String valueForWhenTrue = '';
  int selectIndexRow = 0;
  String programStr = '';
  String zoneStr = '';
  List<String> operatorList = [
    '&& -Both are true',
    '|| -Anyone true',
    '^ -No one true'
  ];
  List<String> manualoperatorList = ['High', 'Low'];
  String selectedOperator = '';
  String selectedValue = '';
  String selectedCondition = '';
  List<String> conditionList = [];
  List<ConditionLibrary>? conditionLibrary = [];
  Conditiontype selectedSegment = Conditiontype.Program;
  int applycheck = 1;
  late ConditionProvider sensorProvider;
  int firstcheck = 0;

  @override
  void initState() {
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);

    super.initState();
    fetchData();
    // initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (_conditionModel.data != null &&
        _conditionModel.data!.conditionProgram != null &&
        _conditionModel.data!.conditionProgram!.isNotEmpty) {
      setState(() {
        _tabController = TabController(
            length: _conditionModel.data!.conditionProgram!.length,
            vsync: this);
        _tabController.addListener(_handleTabSelection);
        for (var i = 0;
        i < _conditionModel.data!.condition!.length;
        i++) {
          conditionList.add(_conditionModel.data!.condition![i].name!);
        }
      });
    }
  }

  void _handleTabSelection() {
    setState(() {
      int selectedTabIndex = _tabController.index;
      changeval(selectedTabIndex);
    });
    // }
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    print('body $body');
    final response = await HttpService()
        .postRequest("getUserPlanningConditionLibrary", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _conditionModel = ConditionModel.fromJson(jsondata1);
        _conditionModel.data!.dropdown!.insert(0, '--Select Category--');
        if (_conditionModel.data != null &&
            _conditionModel.data!.conditionProgram != null &&
            _conditionModel.data!.conditionProgram!.isNotEmpty) {
          setState(() {
            if (selectedSegment == Conditiontype.Program) {
              _tabController = TabController(
                  length: _conditionModel.data!.conditionProgram!.length,
                  vsync: this);
              _tabController.addListener(_handleTabSelection);
              conditionLibrary = _conditionModel.data!.conditionProgram!;
              for (var i = 0;
              i < _conditionModel.data!.condition!.length;
              i++) {
                conditionList.add(_conditionModel.data!.condition![i].name!);
              }
            } else if (selectedSegment == Conditiontype.Moisture) {
              _tabController = TabController(
                  length: _conditionModel.data!.conditionMoisture!.length,
                  vsync: this);
              _tabController.addListener(_handleTabSelection);
              conditionLibrary = _conditionModel.data!.conditionMoisture!;
              for (var i = 0;
              i < _conditionModel.data!.condition!.length;
              i++) {
                conditionList.add(_conditionModel.data!.condition![i].name!);
              }
            } else {
              _tabController = TabController(
                  length: _conditionModel.data!.conditionLevel!.length,
                  vsync: this);
              _tabController.addListener(_handleTabSelection);
              conditionLibrary = _conditionModel.data!.conditionLevel!;
              for (var i = 0;
              i < _conditionModel.data!.condition!.length;
              i++) {
                conditionList.add(_conditionModel.data!.condition![i].name!);
              }
            }
          });
        }
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  void checklistdropdown() async {
    usedProgramDropDownList = [];
    dropDownTitle = '';
    hint = '';

    if (usedProgramDropDownStr.contains('Program')) {
      usedProgramDropDownList = _conditionModel.data!.program;
      dropDownTitle = 'Program';
      hint = 'Programs';
    }
    if (usedProgramDropDownStr.contains('Contact')) {
      usedProgramDropDownList = _conditionModel.data!.contact;
      dropDownTitle = 'Contact';
      hint = 'Contacts';
    }
    if (usedProgramDropDownStr.contains('Level')) {
      usedProgramDropDownList = _conditionModel.data!.levelSensor;
      dropDownTitle = 'Sensor';
      hint = 'Values';
    }
    if (usedProgramDropDownStr.contains('Moisture')) {
      usedProgramDropDownList = _conditionModel.data!.moistureSensor;
      dropDownTitle = 'Sensor';
      hint = 'Values';
    }
    if (usedProgramDropDownStr.contains('Analog')) {
      usedProgramDropDownList = _conditionModel.data!.analogSensor;
      dropDownTitle = 'Sensor';
      hint = 'Values';
    }
    if (usedProgramDropDownStr.contains('Digital')) {
      usedProgramDropDownList = _conditionModel.data!.digitalSensor;
      dropDownTitle = 'Sensor';
      hint = 'Values';
    }
    if (usedProgramDropDownStr.contains('Water')) {
      usedProgramDropDownList = _conditionModel.data!.waterMeter;
      dropDownTitle = 'Water Meter';
      hint = 'Flow';
    }
    if (usedProgramDropDownStr.contains('Conbined')) {
      usedProgramDropDownList = _conditionModel.data!.condition;
      dropDownTitle = 'Expression';
      hint = 'Expression';
    }
    if (usedProgramDropDownStr.contains('Pressure Switch')) {
      usedProgramDropDownList = _conditionModel.data!.pressureSwitch;
      dropDownTitle = 'Pressure values';
      hint = 'values';
    }
    if (usedProgramDropDownStr.contains('Top Tank is High')) {
      print('usedProgramDropDownStr======> $usedProgramDropDownStr');
      usedProgramDropDownList = _conditionModel.data!.topFloathigh;
      dropDownTitle = 'Float values';
      hint = 'values';
    }
    if (usedProgramDropDownStr.contains('Sump Tank is Hig')) {
      print('usedProgramDropDownStr======> $usedProgramDropDownStr');
      usedProgramDropDownList = _conditionModel.data!.sumpFloathigh;
      dropDownTitle = 'Float values';
      hint = 'values';
    }
    if (usedProgramDropDownStr.contains('Top Tank is Low')) {
      print('usedProgramDropDownStr======> $usedProgramDropDownStr');
      usedProgramDropDownList = _conditionModel.data!.topFloatlow;
      dropDownTitle = 'Float values';
      hint = 'values';
    }
    if (usedProgramDropDownStr.contains('Sump Tank is Low')) {
      print('usedProgramDropDownStr======> $usedProgramDropDownStr');
      usedProgramDropDownList = _conditionModel.data!.sumpFloatlow;
      dropDownTitle = 'Float values';
      hint = 'values';
    }
    if (usedProgramDropDownStr.contains('Manual Button')) {
      usedProgramDropDownList = _conditionModel.data!.manualButton;
      dropDownTitle = 'Manual Button';
      hint = 'values';
    }

    if (usedProgramDropDownStr.contains('Zone')) {
      usedProgramDropDownList = _conditionModel.data!.sequence;
      dropDownTitle = 'Zone values';
      hint = 'values';
    }
    if (usedProgramDropDownList!.isNotEmpty) {
      usedProgramDropDownStr2 = usedProgramDropDownStr2 == ''
          ? '${usedProgramDropDownList?[0].name}'
          : usedProgramDropDownStr2;
    }
    // if (usedProgramDropDownList!.isNotEmpty) {
    //   usedProgramDropDownStr3 = usedProgramDropDownStr3 == ''
    //       ? '${usedProgramDropDownList?[0].name}'
    //       : usedProgramDropDownStr3;
    // }
  }

  String conditionselection(String name, String id, String value) {
    print('conditionselection ---> name$name id $id value$value');

    programStr = '';
    zoneStr = '';
    String conditionselectionstr = '';
    if (usedProgramDropDownStr.contains('Program')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]}';
      programStr = id;
    }
    if (usedProgramDropDownStr.contains('Analog Sensor')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split(' is');
      conditionselectionstr =
      '$id is ${usedprogramdropdownstrarr[1]} value $value ';
    }
    if (usedProgramDropDownStr.contains('Contact')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '$name value is $value ';
    }
    if (usedProgramDropDownStr.contains('Water')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]} $value';
    }
    if (usedProgramDropDownStr.contains('Conbined')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
    }
    if (usedProgramDropDownStr.contains('Zone')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
      zoneStr = name;
    }
    if (usedProgramDropDownStr.contains('Tank')) {
      if (value.isEmpty) {
        value = "High";
      }
      conditionselectionstr = '${usedProgramDropDownStr} Value is  $value';
      zoneStr = name;
    }
    if (usedProgramDropDownStr.contains('Switch')) {
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
      zoneStr = name;
    }
    if (usedProgramDropDownStr.contains('Manual Button')) {
      if (value.isEmpty) {
        value = "High";
      }
      var usedprogramdropdownstrarr = usedProgramDropDownStr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
      zoneStr = name;
    }
    if (usedProgramDropDownStr.contains('Digital Sensor')) {
      if (value.isEmpty) {
        value = "High";
      }
      conditionselectionstr = '$usedProgramDropDownStr is $value';
      zoneStr = name;
    }
    if (usedProgramDropDownStr.contains('Sensor')) {
      conditionselectionstr = '$name $id is $value';
      programStr = id;
    }
    print('conditionselectionstr $conditionselectionstr');
    return conditionselectionstr;
  }

  @override
  Widget build(BuildContext context) {
    firstcheck =  firstcheck+1;
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);

    AfterProgramDropDownList?.clear();
    for (var i = 0; i < (_conditionModel.data?.program!.length ?? 0); i++) {
      AfterProgramDropDownList?.add(
          _conditionModel.data!.program![i].name.toString());
    }
    AfterProgramDropDownList!.insert(0, '--Select Category--');
    return Scaffold(
      backgroundColor: Color(0xffE6EDF5),
      appBar: AppBar(
        title: Text('Conditions Library'),automaticallyImplyLeading: false,
      ),
      body: buildcodition(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myTheme.primaryColorDark,
        foregroundColor: Colors.white,
        onPressed: () async {
          setState(() {
            if (applycheck == 1) {
              conditionLibrary![selectIndexRow].conditionIsTrueWhen =
                  conditionselection(usedProgramDropDownStr,
                      usedProgramDropDownStr2, valueForWhenTrue);
              conditionLibrary![selectIndexRow].program = programStr;
              conditionLibrary![selectIndexRow].zone = zoneStr;
              conditionLibrary![selectIndexRow].dropdown1 =
                  usedProgramDropDownStr;
              conditionLibrary![selectIndexRow].dropdown2 =
                  usedProgramDropDownStr2;
              conditionLibrary![selectIndexRow].dropdownValue = valueForWhenTrue;
              updateconditions();
            } else {
              applybuttonclick(selectIndexRow);
              conditionLibrary![selectIndexRow].conditionIsTrueWhen =
                  conditionselection(usedProgramDropDownStr,
                      usedProgramDropDownStr2, valueForWhenTrue);
              conditionLibrary![selectIndexRow].program = programStr;
              conditionLibrary![selectIndexRow].zone = zoneStr;
              conditionLibrary![selectIndexRow].dropdown1 =
                  usedProgramDropDownStr;
              conditionLibrary![selectIndexRow].dropdown2 =
                  usedProgramDropDownStr2;
              conditionLibrary![selectIndexRow].dropdownValue = valueForWhenTrue;
              updateconditions();
            }
          });
        },
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ),
    );
    // }
  }

  @override
  Widget buildcodition(BuildContext context) {
    return Container(
      color: Color(0xffE6EDF5),
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          SegmentedButton<Conditiontype>(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context)
                      .primaryColor; // Use primary color for selected segments
                }
                return Color(0xffE6EDF5);
              }),
              foregroundColor:
              MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Theme.of(context).primaryColor;
              }),
              iconColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Theme.of(context).primaryColor;
              }),
            ),
            segments: const <ButtonSegment<Conditiontype>>[
              ButtonSegment<Conditiontype>(
                  value: Conditiontype.Program,
                  label: Text(
                    'Program',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.list_alt)),
              ButtonSegment<Conditiontype>(
                  value: Conditiontype.Moisture,
                  label: Text(
                    'Moisture',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.water_drop_outlined)),
              ButtonSegment<Conditiontype>(
                  value: Conditiontype.Level,
                  label: Text(
                    'Level',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.water_outlined)),
            ],
            selected: <Conditiontype>{selectedSegment},
            onSelectionChanged: (Set<Conditiontype> newSelection) {
              setState(() {
                selectedSegment = newSelection.first;
                if (selectedSegment == Conditiontype.Program) {
                  conditionLibrary = _conditionModel.data!.conditionProgram!;
                } else if (selectedSegment == Conditiontype.Moisture) {
                  conditionLibrary = _conditionModel.data!.conditionMoisture!;
                } else {
                  conditionLibrary = _conditionModel.data!.conditionLevel!;
                }
                _tabController.index = 0;
                changeval(0);
                print('selectedSegment ---onclick----> $selectedSegment');
              });
            },
          ),
          conditionLibrary!.length <= 0
              ? Container(
            height: 300,
            width: 300,
            child: const Center(
                child: Text(
                  "There are no conditions found",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center,
                )),
          )
              : DefaultTabController(
            length: conditionLibrary?.length ?? 0,
            initialIndex: 0, // Number of tabs
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    labelColor: myTheme.primaryColorDark,
                    controller: _tabController,
                    indicatorColor: myTheme.primaryColorDark,
                    isScrollable: true,
                    tabs: [
                      for (var i = 0; i < conditionLibrary!.length; i++)
                        Tab(
                          text: conditionLibrary![i].name ?? 'Condition',
                        ),
                    ],
                    onTap: (value) {
                      setState(() {
                        tabclickindex = value;
                        changeval(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child:
                    TabBarView(controller: _tabController, children: [
                      for (var i = 0; i < conditionLibrary!.length; i++)
                        ConditionTab(i, conditionLibrary),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Priv(name) {
    print(name);
  }

  changeval(int Selectindexrow) {
    usedProgramDropDownStr = conditionLibrary![Selectindexrow].dropdown1!;
    usedProgramDropDownStr2 = conditionLibrary![Selectindexrow].dropdown2!;
    dropDownValues = conditionLibrary![Selectindexrow].dropdownValue!;
    checklistdropdown();
  }

//TODO:-  ConditionTab
  Widget ConditionTab(int i, List<ConditionLibrary>? conditionLibrary) {
    // changeval(i);// this is change to tab index value re-Assign dropdown lists
    selectIndexRow = i;
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    if (_conditionModel.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (conditionLibrary!.length <= 0) {
      return const Center(
          child: Text(
            'This Condition Not Found ',
            style: TextStyle(color: Colors.black, fontSize: 20),
            textAlign: TextAlign.center,
          ));
    } else {
      if (_tabController.index == i) {
        String conditiontrue = conditionLibrary![i].conditionIsTrueWhen!;
        bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropDownValues);
        bool containsOnlyOperators =
        RegExp(r'^[&|^]+$').hasMatch(dropDownValues);
        if ((usedProgramDropDownStr.contains('Combined') == true)) {
          if (conditionList.contains(usedProgramDropDownStr2)) {
            usedProgramDropDownStr2 = conditionLibrary[i].dropdown2!;
          } else {
            usedProgramDropDownStr2 = "";
          }
        } else {
          List<String> names = usedProgramDropDownList!
              .map((contact) => contact.name as String)
              .toList();
          if (names.contains(usedProgramDropDownStr2)) {
            usedProgramDropDownStr2 = conditionLibrary[i].dropdown2!;
          } else {
            if (usedProgramDropDownList!.length > 0) {
              usedProgramDropDownStr2 = '${usedProgramDropDownList![0].name}';
            }
          }
          if (usedProgramDropDownStr2.isEmpty &&
              usedProgramDropDownList!.isNotEmpty) {
            usedProgramDropDownStr2 = '${usedProgramDropDownList![0].name}';
          }
        }
        if (conditiontrue.contains("&&")) {
          selectedOperator = "&&";
        } else if (conditiontrue.contains("||")) {
          selectedOperator = "||";
        } else if (conditiontrue.contains("^")) {
          selectedOperator = "^";
        } else {
          selectedOperator = "";
        }
        return SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: myTheme.primaryColorDark.withOpacity(0.6),
              ),
              child: Center(
                  child: Text(
                    '${i + 1}. ${conditionLibrary![i].id}',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            SizedBox(
              height: 5,
            ),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[1]),
                  trailing: Text(conditionLibrary![i].name.toString()),
                )),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[2]),
                  trailing: Switch(
                    value: conditionLibrary![i].enable ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].enable = value;
                      });
                    }),
                  ),
                )),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[3]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${conditionLibrary![i].duration}' != ''
                            ? '${conditionLibrary![i].duration}'
                            : '00:00:00',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: HoursMinutesSeconds(
                                initialTime:
                                '${conditionLibrary![i].duration}' != ''
                                    ? '${conditionLibrary![i].duration}'
                                    : '00:00:00',
                                onPressed: () {
                                  setState(() {
                                    conditionLibrary![i].duration =
                                    '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )),
            InkWell(
              onTap: () async {
                setState(() {
                  // _showFormulaBottomSheet(conditionLibrary![i].id!, i);
                });
              },
              child: Card(
                  elevation: 0.1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(conditionHdrList[4]),
                    trailing: Container(
                        width: 200,
                        child: Text(
                          conditionLibrary![i].conditionIsTrueWhen.toString(),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        )),
                  )),
            ),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[5]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${conditionLibrary![i].fromTime}' != ''
                            ? '${conditionLibrary![i].fromTime}'
                            : '00:00:00',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: HoursMinutesSeconds(
                                initialTime:
                                '${conditionLibrary![i].fromTime}' != ''
                                    ? '${conditionLibrary![i].fromTime}'
                                    : '00:00:00',
                                onPressed: () {
                                  setState(() {
                                    conditionLibrary![i].fromTime =
                                    '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[6]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${conditionLibrary![i].untilTime}' !=
                            ''
                            ? '${conditionLibrary![i].untilTime == '00:00:00' ? '23:59:59' : conditionLibrary![i].untilTime}'
                            : '23:59:59',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: HoursMinutesSeconds(
                                initialTime:
                                '${conditionLibrary![i].untilTime}' !=
                                    ''
                                    ? '${conditionLibrary![i].untilTime == '00:00:00' ? '23:59:59' : conditionLibrary![i].untilTime}'
                                    : '23:59:59',
                                onPressed: () {
                                  setState(() {
                                    conditionLibrary![i].untilTime =
                                    '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )),
            Card(
                elevation: 0.1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(conditionHdrList[7]),
                  trailing: Switch(
                    value: conditionLibrary![i].conditionBypass ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].conditionBypass = value;
                      });
                    }),
                  ),
                )),
            Card( elevation: 0.1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),child: conditionselectionsidemenu( i),),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  print('pplycheck 12');
                  applycheck = 1;
                  setState(() {
                    applybuttonclick(i);
                  });

                },
                child: const Text('Apply Changes'))
          ]),
        );
      } else
        return Center();
    }
  }

  applybuttonclick(int i)
  {
    setState(() {
      finddetails(
          usedProgramDropDownStr, usedProgramDropDownStr2);
      if (usedProgramDropDownStr.contains('Program')) {
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, '');
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        // conditionLibrary![i]
        //     .dropdownValue = '';
        conditionLibrary![i].usedByProgram =
            programStr;

        List<UserNames>? program = _conditionModel.data!.program!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Contact'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(
                usedProgramDropDownStr, '', dropDownValues);
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program = _conditionModel.data!.contact!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Manual'))
      {
        print('conditionLibrary![i].dropdown3 ${conditionLibrary![i].dropdown3} usedProgramDropDownStr3$usedProgramDropDownStr3 usedProgramDropDownStr $usedProgramDropDownStr usedProgramDropDownStr2 $usedProgramDropDownStr2');
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(
                usedProgramDropDownStr,
                usedProgramDropDownStr2,
                conditionLibrary![i].dropdown3!);
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].dropdown3 = usedProgramDropDownStr3.isEmpty ? conditionLibrary![i].dropdown3 : usedProgramDropDownStr3;
        conditionLibrary![i].dropdown3 = conditionLibrary![i]
            .dropdown3!
            .contains('High')
            ? "High"
            : conditionLibrary![i]
            .dropdown3!
            .contains('Low')
            ? 'Low'
            : 'High';
        // conditionLibrary![i].dropdown3 = usedProgramDropDownStr3;
        conditionLibrary![i].dropdownValue = '';
        List<UserNames>? program =
        _conditionModel.data!.manualButton!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Analog'))
      {
        print('usedProgramDropDownStr2 analog --> $usedProgramDropDownStr3');
        String id =
        findHId('$usedProgramDropDownStr2', _conditionModel.data!.analogSensor!);

        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, dropDownValues);

        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].dropdown3 = '';
        conditionLibrary![i].usedByProgram = '';
        conditionLibrary![i].dropdownValue = dropDownValues;
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.analogSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Digital'))
      {
        print('usedProgramDropDownStr2 Digital --> $usedProgramDropDownStr3');
        String id =
        findHId('$usedProgramDropDownStr2', _conditionModel.data!.digitalSensor!);



        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].dropdown3 = usedProgramDropDownStr3.isEmpty ? conditionLibrary![i].dropdown3 : usedProgramDropDownStr3;
        conditionLibrary![i].dropdown3 = conditionLibrary![i]
            .dropdown3!
            .contains('High')
            ? "High"
            : conditionLibrary![i]
            .dropdown3!
            .contains('Low')
            ? 'Low'
            : 'High';
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, usedProgramDropDownStr3.isEmpty ? conditionLibrary![i].dropdown3! : usedProgramDropDownStr3);

        conditionLibrary![i].usedByProgram = '';
        conditionLibrary![i].dropdownValue = '';
        List<UserNames>? program =
        _conditionModel.data!.digitalSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Moisture'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, dropDownValues);
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.analogSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Level'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, dropDownValues);
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.analogSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Water'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.waterMeter!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('condition'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
        '$usedProgramDropDownStr $usedProgramDropDownStr2 $dropDownValues $usedProgramDropDownStr3';
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        // conditionLibrary![i].program = dropdownvalues;

        List<ConditionLibrary>? program = conditionLibrary;
        if (program != null) {
          String sNo = getSNoByNamecondition(
              program, usedProgramDropDownStr2);
          if (sNo != null) {
            conditionLibrary![i].program = '$sNo';
          } else {
            conditionLibrary![i].program = '0';
          }
        }
      }
      else if (usedProgramDropDownStr.contains('Zone'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = '';
        conditionLibrary![i].program = '0';
      }
      else if (usedProgramDropDownStr.contains('Tank'))
      {
        print('tank dropdown3:$usedProgramDropDownStr3 model:${conditionLibrary![i].dropdown3}');
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].dropdown3 = usedProgramDropDownStr3.isEmpty ? conditionLibrary![i].dropdown3 : usedProgramDropDownStr3;
        conditionLibrary![i].dropdown3 = conditionLibrary![i]
            .dropdown3!
            .contains('High')
            ? "High"
            : conditionLibrary![i]
            .dropdown3!
            .contains('Low')
            ? 'Low'
            : 'High';

        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, usedProgramDropDownStr3.isEmpty ? conditionLibrary![i].dropdown3! : usedProgramDropDownStr3);

        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.analogSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else if (usedProgramDropDownStr.contains('Switch'))
      {
        conditionLibrary![i].conditionIsTrueWhen =
            conditionselection(usedProgramDropDownStr,
                usedProgramDropDownStr2, dropDownValues);
        conditionLibrary![i].dropdown1 =
            usedProgramDropDownStr;
        conditionLibrary![i].dropdown2 =
            usedProgramDropDownStr2;
        conditionLibrary![i].usedByProgram = '';
        // conditionLibrary![i]
        //     .dropdownValue = dropdownvalues;
        List<UserNames>? program =
        _conditionModel.data!.analogSensor!;
        String? sNo =
        getSNoByName(program, usedProgramDropDownStr2);
        if (sNo != null) {
          conditionLibrary![i].program = '$sNo';
        } else {
          conditionLibrary![i].program = '0';
        }
      }
      else
      {
        conditionLibrary![i].conditionIsTrueWhen =
        '';
        conditionLibrary![i].dropdown1 = '';
        conditionLibrary![i].dropdown2 = '';
        // conditionLibrary![i]
        //     .dropdownValue = '';
        conditionLibrary![i].program = '0';
        conditionLibrary![i].usedByProgram = '--Select Category--';
      }
    });
  }

  Widget conditionselectionsidemenu(int index) {
    print('index----> $index');
    final valueController = TextEditingController();
    sensorProvider = Provider.of<ConditionProvider>(context, listen: true);
    print('usedProgramDropDownStr start $usedProgramDropDownStr');
    print('usedProgramDropDownStr2 start $usedProgramDropDownStr2');
    print('usedProgramvalues start $dropDownValues');

    usedProgramDropDownStr = usedProgramDropDownStr.isNotEmpty
        ? usedProgramDropDownStr == '--Select Category--'
        ? conditionLibrary![index].dropdown1!
        : usedProgramDropDownStr
        : conditionLibrary![index].dropdown1!;
    print('usedProgramDropDownStr final $usedProgramDropDownStr');
    usedProgramDropDownStr2 = usedProgramDropDownStr2.isNotEmpty
        ? usedProgramDropDownStr2
        : conditionLibrary![index].dropdown2!;
    print('usedProgramDropDownStr2  final$usedProgramDropDownStr2');
    usedProgramDropDownStr3 = usedProgramDropDownStr3.isNotEmpty
        ? usedProgramDropDownStr3
        : conditionLibrary![index].dropdown3!;
    dropDownValues = dropDownValues.isNotEmpty
        ? dropDownValues
        : conditionLibrary![index].dropdownValue!;
    print('dropDownValues  final$dropDownValues');
    print('dropDownValues3  final first $usedProgramDropDownStr3');
    checklistdropdown();
    // print('usedProgramDropDownStr:$usedProgramDropDownStr usedProgramDropDownStr2:$usedProgramDropDownStr2 usedProgramDropDownStr3:$usedProgramDropDownStr3 dropdownValue:$dropDownValues');
    String conditiontrue = conditionLibrary![index].conditionIsTrueWhen!;
    // bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropDownValues);
    valueController.text =
    RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(dropDownValues)
        ? dropDownValues
        : '';
    bool containsOnlyOperators =
    RegExp(r'^(&&|\|\||\^) -.*$').hasMatch(dropDownValues);
//dropdownflist is program,contact.... 1-st dropdown
    List<String>? dropdownflist = _conditionModel.data!.dropdown!;

    if (selectedSegment == Conditiontype.Program) {
      if (conditionLibrary!.length >= 3) {
        dropdownflist = _conditionModel.data!.dropdown!
            .where(
                (item) => !item.contains("Moisture") && !item.contains("Level"))
            .toList();
      } else {
        dropdownflist = _conditionModel.data!.dropdown!
            .where((item) =>
        !item.contains("Moisture") &&
            !item.contains("Level") &&
            !item.contains("Combined"))
            .toList();
      }
    } else if (selectedSegment == Conditiontype.Moisture) {
      if (conditionLibrary!.length >= 3) {
        // dropdownflist = Moiturelistcombained;
        dropdownflist = _conditionModel.data!.dropdown!
            .where((item) =>
        item.contains("Moisture") || item.contains("Combined"))
            .toList();
      } else {
        dropdownflist = _conditionModel.data!.dropdown!
            .where((item) => item.contains("Moisture"))
            .toList();
        // dropdownflist = Moiturelist;
      }
      dropdownflist.insert(0, '--Select Category--');
    } else {
      if (conditionLibrary!.length >= 3) {
        // dropdownflist = Moiturelistcombained;
        dropdownflist = _conditionModel.data!.dropdown!
            .where(
                (item) => item.contains("Level") || item.contains("Combined"))
            .toList();
      } else {
        dropdownflist = _conditionModel.data!.dropdown!
            .where((item) => item.contains("Level"))
            .toList();
        // dropdownflist = Moiturelist;
      }
      dropdownflist.insert(0, '--Select Category--');
    }

    if ((usedProgramDropDownStr.contains('Combined') == true)) {
      if (conditionList.contains(usedProgramDropDownStr2)) {
        usedProgramDropDownStr2 = conditionLibrary![index].dropdown2!;
        usedProgramDropDownStr3 = conditionLibrary![index].dropdown3!;
      } else {
        usedProgramDropDownStr2 = "";
        usedProgramDropDownStr3 = "";
      }
    } else {
      List<String> names = usedProgramDropDownList!
          .map((contact) => contact.name as String)
          .toList();
      if (names.contains(usedProgramDropDownStr2)) {
        usedProgramDropDownStr2 = usedProgramDropDownStr2;
      } else {
        if (usedProgramDropDownList!.length > 0) {
          usedProgramDropDownStr2 = '${usedProgramDropDownList![0].name}';
        }
      }
      // usedProgramDropDownStr3 = "";
    }
    if (usedProgramDropDownStr2.isEmpty &&
        usedProgramDropDownList!.isNotEmpty) {
      usedProgramDropDownStr2 = '${usedProgramDropDownList![0].name}';
    }

    if (conditiontrue.contains("&&")) {
      selectedOperator = "&&";
    } else if (conditiontrue.contains("||")) {
      selectedOperator = "||";
    } else if (conditiontrue.contains("^")) {
      selectedOperator = "^";
    } else {
      selectedOperator = "";
    }
    print('dropdownflist-----> $dropdownflist');
    print('usedProgramDropDownStr-----> $usedProgramDropDownStr');
    print('dropDownValues3  final  $usedProgramDropDownStr3');
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: const Border(),
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          // const Text('When in Used'),

          //First Dropdown values
          DropdownButton(
            items: dropdownflist.map((String? items) {
              return DropdownMenuItem(
                value: items,
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      items!,
                      style: const TextStyle(fontSize: 12.5),
                    )),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                print('pplycheck 6 $value');
                // sensorProvider.updateapplycheck(0);
                applycheck = 0;
                usedProgramDropDownStr = value.toString();
                conditionLibrary![selectIndexRow].dropdown1 = value!;
                checklistdropdown();
                finddetails(usedProgramDropDownStr, usedProgramDropDownStr2);
              });
            },
            value: usedProgramDropDownStr == '--Select Category--' ||
                usedProgramDropDownStr == ''
                ? conditionLibrary![selectIndexRow].dropdown1!.isEmpty
                ? (_conditionModel.data!.dropdown![0])
                : conditionLibrary![selectIndexRow].dropdown1!.toString()
                : usedProgramDropDownStr,
          ),
          if (usedProgramDropDownList?.length != 0) Text(dropDownTitle),
          if (usedProgramDropDownStr.contains('Combined') == false &&
              usedProgramDropDownList?.length != 0 &&
              usedProgramDropDownStr.contains('Manual') == false &&
              usedProgramDropDownStr.contains('Tank') == false)
            DropdownButton(
              hint: const Text(''),
              items: usedProgramDropDownList?.map((UserNames items) {
                return DropdownMenuItem(
                  value: '${items.name}',
                  child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('${items.name}')),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  print('pplycheck 7');
                  applycheck = 0;
                  // sensorProvider.updateapplycheck(0);
                  usedProgramDropDownStr2 = value.toString();
                  conditionLibrary![selectIndexRow].dropdown2 =
                      value.toString();

                  var hid = findHId(
                      value.toString(), _conditionModel.data!.analogSensor!);
                  var srno = findSNo(
                      value.toString(), _conditionModel.data!.analogSensor!);

                  finddetails(
                      usedProgramDropDownStr, usedProgramDropDownStr2);
                });
              },
              value: usedProgramDropDownStr2,
            ),
          if (usedProgramDropDownStr.contains('Manual') == true)
            Column(
              children: [
                DropdownButton(
                  hint: const Text(''),
                  items: usedProgramDropDownList?.map((UserNames items) {
                    return DropdownMenuItem(
                      value: '${items.name}',
                      child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('${items.name}')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      print('pplycheck manual $value');
                      applycheck = 0;
                      // sensorProvider.updateapplycheck(0);
                      usedProgramDropDownStr2 = value.toString();
                      conditionLibrary![selectIndexRow].dropdown2 =
                          value.toString();
                      // var hid = findHId(value.toString(),
                      //     _conditionModel.data!.manualButton!);
                      // var srno = findSNo(value.toString(),
                      //     _conditionModel.data!.manualButton!);
                      // finddetails(
                      //     usedProgramDropDownStr, usedProgramDropDownStr2);
                    });
                  },
                  value: usedProgramDropDownStr2,
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('High')
                      ? "High"
                      : conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('Low')
                      ? 'Low'
                      : 'High',
                  onChanged: (value) {
                    setState(() {
                      print('pplycheck manual$value');
                      applycheck = 0;
                      // sensorProvider.updateapplycheck(0);
                      usedProgramDropDownStr3 = value!;
                      conditionLibrary![selectIndexRow].dropdown3 = value;
                    });
                  },
                  items: manualoperatorList.map((operator) {
                    return DropdownMenuItem(
                      value: operator,
                      child: Text(operator),
                    );
                  }).toList(),
                ),
              ],
            ),
          if (usedProgramDropDownStr.contains('Tank') == true)
            Column(
              children: [
                DropdownButton(
                  hint: const Text(''),
                  items: usedProgramDropDownList?.map((UserNames items) {
                    return DropdownMenuItem(
                      value: '${items.name}',
                      child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('${items.name}')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      print('pplycheck manual $value');
                      applycheck = 0;
                      // sensorProvider.updateapplycheck(0);
                      usedProgramDropDownStr2 = value.toString();
                      conditionLibrary![selectIndexRow].dropdown2 =
                          value.toString();
                      // var hid = findHId(value.toString(),
                      //     _conditionModel.data!.manualButton!);
                      // var srno = findSNo(value.toString(),
                      //     _conditionModel.data!.manualButton!);
                      // finddetails(
                      //     usedProgramDropDownStr, usedProgramDropDownStr2);
                    });
                  },
                  value: usedProgramDropDownStr2,
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('High')
                      ? "High"
                      : conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('Low')
                      ? 'Low'
                      : 'High',
                  onChanged: (value) {
                    setState(() {
                      print('pplycheck manual$value');
                      applycheck = 0;
                      // sensorProvider.updateapplycheck(0);
                      usedProgramDropDownStr3 = value!;
                      conditionLibrary![selectIndexRow].dropdown3 = value;
                    });
                  },
                  items: manualoperatorList.map((operator) {
                    return DropdownMenuItem(
                      value: operator,
                      child: Text(operator),
                    );
                  }).toList(),
                ),
              ],
            ),
          if (usedProgramDropDownStr.contains('Digital'))
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child:  DropdownButton<String>(
                  value: conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('High')
                      ? "High"
                      : conditionLibrary![selectIndexRow]
                      .dropdown3!
                      .contains('Low')
                      ? 'Low'
                      : 'High',
                  onChanged: (value) {
                    setState(() {
                      print('pplycheck PSP$value');
                      applycheck = 0;
                      // sensorProvider.updateapplycheck(0);
                      usedProgramDropDownStr3 = value!;
                      conditionLibrary![selectIndexRow].dropdown3 = value;
                    });
                  },
                  items: manualoperatorList.map((operator) {
                    return DropdownMenuItem(
                      value: operator,
                      child: Text(operator),
                    );
                  }).toList(),
                ),
              ),
            ),
          if (usedProgramDropDownStr.contains('Analog') || usedProgramDropDownStr.contains('Moisture') || usedProgramDropDownStr.contains('Level') || usedProgramDropDownStr.contains('Contact') ||
              usedProgramDropDownStr.contains('Water') ||
              usedProgramDropDownStr.contains('Zone'))
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: TextFormField(
                  controller: valueController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  // initialValue: containsOnlyNumbers ? dropdownvalues : null,
                  showCursor: true,
                  inputFormatters: usedProgramDropDownStr.contains('Sensor')
                      ? [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,3}(\.\d{0,3})?$'))
                  ]
                      : [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  decoration: InputDecoration(
                      hintText: hint, border: const OutlineInputBorder()),
                  onChanged: (value) {
                    print('pplycheck 8');
                    applycheck = 0;
                    // sensorProvider.updateapplycheck(0);
                    dropDownValues = value;
                    conditionLibrary![selectIndexRow].dropdownValue =
                        dropDownValues;
                  },
                ),
              ),
            ),
          if (usedProgramDropDownStr.contains('Combined'))
            Padding(
                padding: const EdgeInsets.all(20.0),
                //Dropdown for operator  values
                child: Column(
                  children: [
                    //Dropdown for Condition 2 values for first condition selections
                    DropdownButton<String>(
                      value: usedProgramDropDownStr2.isEmpty
                          ? null
                          : usedProgramDropDownStr2,
                      hint: Text(usedProgramDropDownStr2.isEmpty ? 'Select an option' : '$usedProgramDropDownStr2'),
                      onChanged: (value) {
                        setState(() {
                          print('pplycheck 9');
                          applycheck = 0;
                          // sensorProvider.updateapplycheck(0);
                          usedProgramDropDownStr2 = value!;
                          conditionLibrary![selectIndexRow].dropdown2 = value;
                        });
                      },
                      items: filterlist(
                          conditionList,
                          conditionList[selectIndexRow],
                          conditionLibrary![selectIndexRow].dropdown3)
                          .map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child:Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(condition,
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Tooltip(
                                  message: conditiondescriptionlistAssign(condition) ,
                                  child: Text(conditiondescriptionlistAssign(condition),
                                      style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,softWrap: true, maxLines: 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: containsOnlyOperators ? dropDownValues : null,
                      hint: const Text('Select Operator'),
                      onChanged: (value) {
                        setState(() {
                          print('pplycheck 10');
                          applycheck = 0;
                          // sensorProvider.updateapplycheck(0);
                          dropDownValues = value!;
                          conditionLibrary![selectIndexRow].dropdownValue =
                              value;
                        });
                      },
                      items: operatorList.map((operator) {
                        return DropdownMenuItem(
                          value: operator,
                          child: Text(operator),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 16),
                    //Dropdown for Condition 2 values based on first and second values
                    DropdownButton<String>(
                      value: usedProgramDropDownStr3.isEmpty
                          ? null
                          : usedProgramDropDownStr3,
                      hint: Text(usedProgramDropDownStr3.isEmpty ? 'Select an option' : '$usedProgramDropDownStr3'),
                      onChanged: (value) {
                        setState(() {
                          print('pplycheck 11');
                          applycheck = 0;
                          // sensorProvider.updateapplycheck(0);
                          usedProgramDropDownStr3 = value!;
                          conditionLibrary![selectIndexRow].dropdown3 = value;
                        });
                      },
                      items: filterlist(
                          conditionList,
                          conditionList[selectIndexRow],
                          conditionLibrary![selectIndexRow].dropdown2)
                          .map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child:Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(condition,
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Tooltip(
                                  message: conditiondescriptionlistAssign(condition) ,
                                  child: Text(conditiondescriptionlistAssign(condition),
                                      style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,softWrap: true, maxLines: 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )),
          const SizedBox(
            height: 20,
          ),
          IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(sensorProvider.SensorDetails),
              )),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  List<String> filterlist(List<String> conditionlist, String removevalue, String? removevalue2) {
    print('conditionlist-------->$conditionlist ----removevalue $removevalue -removevalue2 $removevalue2-');
    conditionlist =
        conditionlist.where((item) => item != '$removevalue').toList();
    if (removevalue2!.isNotEmpty) {
      conditionlist =
          conditionlist.where((item) => item != '$removevalue2').toList();
    }
    print('conditionlist----final---->$conditionlist');

    return conditionlist;
  }

  updateconditions() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    List<Map<String, dynamic>> programJson = _conditionModel
        .data!.conditionProgram!
        .map((condition) => condition.toJson())
        .toList();
    List<Map<String, dynamic>> levelJson = _conditionModel.data!.conditionLevel!
        .map((condition) => condition.toJson())
        .toList();
    List<Map<String, dynamic>> moistureJson = _conditionModel
        .data!.conditionMoisture!
        .map((condition) => condition.toJson())
        .toList();

    // var conditionJson = _conditionModel.data!.conditionLevel.to
    Map<String, dynamic> conditionJo2n = _conditionModel.data!.toJson();
    Map<String, dynamic> finaljson = {
      "program": programJson,
      "moisture": moistureJson,
      "level": levelJson
    };
    String Mqttsenddata = toMqttFormat(conditionLibrary);
    Map<String, dynamic> payLoadFinal = {
      "1000": [
        {"1001": Mqttsenddata},
      ]
    };
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "condition": finaljson,
      "hardware": payLoadFinal,
      "createUser": overAllPvd.userId
    };
    // final response = await HttpService()
    //     .postRequest("createUserPlanningConditionLibrary", body);
    // final jsonDataresponse = json.decode(response.body);
    // GlobalSnackBar.show(
    //     context, jsonDataresponse['message'], response.statusCode);


    if (MQTTManager().isConnected == true) {
      await validatePayloadSent(
          dialogContext: context,
          context: context,
          mqttPayloadProvider: mqttPayloadProvider,
          acknowledgedFunction: () async {
            final response = await HttpService().postRequest("createUserPlanningConditionLibrary", body);
            final jsonDataResponse = json.decode(response.body);
            GlobalSnackBar.show(context, jsonDataResponse['message'], response.statusCode);
            Future.delayed(Duration(seconds: 1), () async{
              if(widget.isProgram) {
                final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
                await irrigationProvider.getUserProgramCondition(widget.userId, widget.controllerId, widget.serialNumber);
                Navigator.pop(context);
              }
            });
          },
          payload: payLoadFinal,
          payloadCode: '1000',
          deviceId: overAllPvd.imeiNo);
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
  }

  String? getSNoByName(List<UserNames> data, String name) {
    UserNames? user = data.firstWhere((element) => element.name == name,
        orElse: () => UserNames());
    return user.sNo.toString();
  }

  String getSNoByNamecondition(List<ConditionLibrary>? data, String name) {
    ConditionLibrary user = data!.firstWhere((element) => element.name == name,
        orElse: () => ConditionLibrary());
    return user.sNo;
  }
  String conditiondescriptionlistAssign(String conditionlist)
  {
    String desc = '';
    for (var condition in _conditionModel.data!.condition!) {
      if (condition.name == conditionlist) {
        desc = '${condition.conditionIsTrueWhen}';
      }
    }
    return desc;
  }

  String toMqttFormat(
      List<ConditionLibrary>? data,
      ) {
    String mqttData = '';
    String ccheckType = '1.';
    for (var ccheck = 0; ccheck < 3; ccheck++) {
      if (ccheck == 0) {
        ccheckType = '1.';
        data = _conditionModel.data!.conditionProgram!;
      } else if (ccheck == 1) {
        ccheckType = '2.';
        data = _conditionModel.data!.conditionMoisture!;
      } else if (ccheck == 2) {
        ccheckType = '3.';
        data = _conditionModel.data!.conditionLevel!;
      }
      data?.forEach((item) {
        // for (var i = 0; i < data!.length; i++) {
        String enableValue = item.enable! ? '1' : '0';
        String notifigation = item.notification! ? '1' : '0';
        String conditionBypass = item.conditionBypass! ? '1' : '0';
        String conditionIsTrueWhenValue = '0,0,0,0';

        //  TODO:/// 1-program,contact,...,2-running,clossing,opening....,3-which program,contact....,4-values of sensors ----    sno is used to only program and contact and id
        if (item.dropdown1!.contains('Program')) {
          int sno =
          findSNo('${item.dropdown2}', _conditionModel.data!.program!);
          if (item.conditionIsTrueWhen!.contains('not running')) {
            conditionIsTrueWhenValue = "1,$sno,11,0";
          } else if (item.conditionIsTrueWhen!.contains('running')) {
            conditionIsTrueWhenValue = "1,$sno,10,0";
          } else if (item.conditionIsTrueWhen!.contains('starting')) {
            conditionIsTrueWhenValue = "1,$sno,8,0";
          } else if (item.conditionIsTrueWhen!.contains('ending')) {
            conditionIsTrueWhenValue = "1,$sno,9,0";
          } else {
            conditionIsTrueWhenValue = "1,0,1,0";
          }
        } else if (item.dropdown1!.contains('Contact')) {
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.contact!);
          if (item.dropdown1!.contains('opened')) {
            conditionIsTrueWhenValue = "2,$id,15,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('closed')) {
            conditionIsTrueWhenValue = "2,$id,16,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('opening')) {
            conditionIsTrueWhenValue = "2,$id,17,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('closing')) {
            conditionIsTrueWhenValue = "2,$id,18,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "2,0,1,0";
          }
        } else if (item.dropdown1!.contains('Zone')) {
          String sno =
          findSNostr('${item.dropdown2}', _conditionModel.data!.sequence!);
          if (item.dropdown1!.contains('low flow than')) {
            conditionIsTrueWhenValue = "3,$sno,14,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('high flow than')) {
            conditionIsTrueWhenValue = "3,$sno,13,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('no flow than')) {
            conditionIsTrueWhenValue = "3,$sno,12,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "3,0,1,0";
          }
        } else if (item.dropdown1!.contains('Water')) {
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.waterMeter!);
          if (item.dropdown1!.contains('higher than')) {
            conditionIsTrueWhenValue = "4,$id,4,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('lower than')) {
            conditionIsTrueWhenValue = "4,$id,5,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "4,0,1,0";
          }
        } else if (item.dropdown1!.contains('Level Sensor')) {
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.levelSensor!);
          if (item.dropdown1!.contains('higher than')) {
            conditionIsTrueWhenValue = "9,$id,4,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('lower than')) {
            conditionIsTrueWhenValue = "9,$id,5,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "9,0,1,0";
          }
        } else if (item.dropdown1!.contains('Moisture Sensor')) {
          print(' mos item.dropdownValue ${item.dropdownValue}');
          print('item.dropdown2 ${item.dropdown2}');
          String id = findHId(
              '${item.dropdown2}', _conditionModel.data!.moistureSensor!);
          if (item.dropdown1!.contains('higher than')) {
            conditionIsTrueWhenValue = "8,$id,4,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('lower than')) {
            conditionIsTrueWhenValue = "8,$id,5,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "8,0,1,0";
          }
          // print('mos conditionIsTrueWhenValue until${item.untilTime}duration${item.duration}from${item.fromTime} $conditionIsTrueWhenValue');
        } else if (item.dropdown1!.contains('Analog Sensor')) {
          print('Analog');
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.analogSensor!);

          if (item.dropdown1!.contains('higher than')) {
            conditionIsTrueWhenValue = "5,$id,4,${item.dropdownValue}";
          } else if (item.dropdown1!.contains('lower than')) {
            conditionIsTrueWhenValue = "5,$id,5,${item.dropdownValue}";
          } else {
            conditionIsTrueWhenValue = "5,0,1,0";
          }
        } else if (item.dropdown1!.contains('Digital Sensor')) {
          String id = findHId(
              '${item.dropdown2}', _conditionModel.data!.digitalSensor!);
          if (item.dropdown1!.contains('Digital Sensor')) {
            conditionIsTrueWhenValue =
            "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
            // } else if (item.dropdown1!.contains('lower than')) {
            //   conditionIsTrueWhenValue = "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
          } else {
            conditionIsTrueWhenValue = "5,0,1,0";
          }
        } else if (item.dropdown1!.contains('Manual')) {
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.manualButton!);
          print("manual $id");
          if (item.conditionIsTrueWhen!.contains('High')) {
            conditionIsTrueWhenValue = "5,$id,6,1";
          } else if (item.conditionIsTrueWhen!.contains('Low')) {
            conditionIsTrueWhenValue = "5,$id,6,0";
          } else {
            conditionIsTrueWhenValue = "5,0,1,0";
          }
          print('id$id');
        } else if (item.dropdown1!.contains('Tank is ')) {
          String id =
          findHId('${item.dropdown2}', _conditionModel.data!.float!);
          if (item.dropdown1!.contains('Top Tank is High')) {
            conditionIsTrueWhenValue =
            "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
          } else if (item.dropdown1!.contains('Top Tank is Low')) {
            conditionIsTrueWhenValue =
            "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
          } else if (item.dropdown1!.contains('Sump Tank is High')) {
            conditionIsTrueWhenValue =
            "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
          } else if (item.dropdown1!.contains('Sump Tank is Low')) {
            conditionIsTrueWhenValue =
            "5,$id,6,${item.dropdown3 == 'Low' ? '0' : '1'}";
          } else {
            conditionIsTrueWhenValue = "5,0,6,0";
          }
        }
        //  Combine =
        else if (item.dropdown1!.contains('condition'))
        {
          String sno1 =
          findSNostr('${item.dropdown2}', _conditionModel.data!.condition!);
          String sno2 =
          findSNostr('${item.dropdown3}', _conditionModel.data!.condition!);

          String operator = item.dropdownValue!;
          if (operator.contains("&&")) {
            operator = "1";
          } else if (operator.contains("||")) {
            operator = "2";
          } else if (operator.contains("^")) {
            operator = "3";

            ///Future
          } else if (operator == "=<") {
            operator = "4";
          } else if (operator == ">=") {
            operator = "5";
          } else if (operator == "==") {
            operator = "6";
          } else if (operator == "!=") {
            operator = "7";
          } else {
            operator = "0";
          }

          if (item.dropdown1!.contains('Combined condition is true')) {
            conditionIsTrueWhenValue = "6,$sno1,$operator,$sno2";
          }
          else if (item.dropdown1!.contains('Combined condition is false'))
          {
            if(operator == "1")
            {
              operator = "2";
            }
            else if(operator == "2")
            {
              operator = "1";
            }
            conditionIsTrueWhenValue = "7,$sno1,$operator,$sno2";
          }
          else {
            conditionIsTrueWhenValue = "5,0,1,0";
          }
          print('conditionIsTrueWhenValue--${item.name}---$conditionIsTrueWhenValue');
        } else {
          conditionIsTrueWhenValue = "1,0,1,0";
        }
        mqttData +=
        '${item.sNo},${item.name},$enableValue,${item.duration},${item.fromTime},${item.untilTime == "00:00:00" ? "23:59:59" : item.untilTime},$notifigation,$conditionIsTrueWhenValue,$conditionBypass;';
      });
    }
    print("Mqtt Data -------> $mqttData");
    return mqttData;
  }

  int findSNo(String searchString, List<UserNames> waterMeters) {
    for (var waterMeter in waterMeters) {
      if (waterMeter.name == searchString) {
        return waterMeter.sNo;
      }
    }
    return 0;
  }

  String findHId(String searchString, List<UserNames> waterMeters) {
    for (var waterMeter in waterMeters) {
      if (waterMeter.name == searchString) {
        return waterMeter.hid!;
      }
    }
    return '';
  }

  finddetails(
      String searchString,
      String sensorsstr,
      ) {
    String details = '';
    sensorProvider = Provider.of<ConditionProvider>(context, listen: false);
    late List<UserNames> waterMeters;
    late String typestring;
    if (searchString.contains('Water meter')) {
      typestring = 'Water meter';
      waterMeters = _conditionModel.data!.waterMeter!;
    } else if (searchString.contains('Zone')) {
      typestring = 'Sequence';
      waterMeters = _conditionModel.data!.sequence!;
    } else if (searchString.contains('Analog Sensor')) {
      typestring = 'Analog Sensor';
      waterMeters = _conditionModel.data!.analogSensor!;
    }  else if (searchString.contains('Digital Sensor')) {
      typestring = 'Digital Sensor';
      waterMeters = _conditionModel.data!.digitalSensor!;
    }
    else if (searchString.contains('Moisture Sensor')) {
      typestring = 'Moisture Sensor';
      waterMeters = _conditionModel.data!.moistureSensor!;
    } else if (searchString.contains('Level Sensor')) {
      typestring = 'Level Sensor';
      waterMeters = _conditionModel.data!.levelSensor!;
    } else if (searchString.contains('Pressure Switch')) {
      typestring = 'Pressure Switch';
      waterMeters = _conditionModel.data!.pressureSwitch!;
    }
    else if (searchString.contains('Top Tank is High')) {
      typestring = 'Top Tank Float';
      waterMeters = _conditionModel.data!.topFloathigh!;
    }
    else if (searchString.contains('Sump Tank is High')) {
      typestring = 'Sump Tank Float';
      waterMeters = _conditionModel.data!.sumpFloathigh!;
    }
    else if (searchString.contains('Top Tank is Low')) {
      typestring = 'Top Tank Float';
      waterMeters = _conditionModel.data!.topFloatlow!;
    }
    else if (searchString.contains('Sump Tank is Low')) {
      typestring = 'Sump Tank Float';
      waterMeters = _conditionModel.data!.sumpFloatlow!;
    }
    else if (searchString.contains('Manual Button')) {
      typestring = 'Manual Button';
      waterMeters = _conditionModel.data!.manualButton!;
    } else {
      typestring = '';
      waterMeters = [];
    }
    // print('waterMeters--test--->${waterMeters.map((e) => print(e.toJson()))}');
    if (typestring != '' && typestring != 'Manual Button') {
      for (var waterMeter in waterMeters) {
        if (waterMeter.name == sensorsstr) {
          List<dynamic> irrigationLine = waterMeter.irrigationLine ?? ['', ''];
          String irrigationLinestring = irrigationLine.join(' , ');
          details =
          'This $typestring used for ${waterMeter.locationName ?? ''}, $irrigationLinestring';
          if (typestring == 'Sequence') {
            var zonepo = waterMeter.id!.split('.');
            details =
            'This $typestring used for ${waterMeter.locationName} in ${zonepo[1]}  Sequence';
          }
          else if (typestring == 'Digital Sensor' || typestring == 'Analog Sensor')
          {
            details =
            'This $typestring used for ${waterMeter.locationName}';
          }
        }
      }
    } else {
      details = '';
    }
    // sensorProvider.updateSensorData('');
    //  details = '';
    print('finddetailsvalue is $details');
    sensorProvider.updateSensorData(details);
  }

  String findId(String searchString, List<UserNames> waterMeters) {
    for (var waterMeter in waterMeters) {
      if (waterMeter.name == searchString) {
        return waterMeter.id!;
      }
    }
    return '';
  }
  String findSNostr(String searchString, List<UserNames> waterMeters) {
    for (var waterMeter in waterMeters) {
      if (waterMeter.name == searchString) {
        return waterMeter.sNo;
      }
    }
    return '0';
  }
}