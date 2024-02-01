import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

 import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../constants/snack_bar.dart';
import '../constants/theme.dart';
import '../custom/myswitch.dart';
import '../model/condition_model.dart';
import 'conditionwebui.dart';

enum Calendar { Program, Moisture, Level }

class ConditionScreen extends StatefulWidget {
  const ConditionScreen(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.imeiNo});
  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 600) {
          // Render mobile content
          return ConditionUI(
            userId: widget.userId,
            controllerId: widget.controllerId,
            imeiNo: widget.imeiNo,
          );
          ;
        } else {
          // Render web content
          return ConditionwebUI(
            userId: widget.userId,
            controllerId: widget.controllerId,
            imeiNo: widget.imeiNo,
          );
        }
      },
    );
  }
}

class ConditionUI extends StatefulWidget {
  const ConditionUI(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.imeiNo});

  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionUI> createState() => _ConditionUIState();
}

class _ConditionUIState extends State<ConditionUI>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic jsondata;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> conditionhdrlist = [
    'sNo',
    'ID',
    'Name',
    'Enable',
    'State',
    'Duration',
    'condition IsTrueWhen',
    'From Hour',
    'Unit Hour',
    'Notification',
    'Used Program',
  ];
  String usedprogramdropdownstr = '';
  List<UserNames>? usedprogramdropdownlist = [];
  String usedprogramdropdownstr2 = '';
  String dropdownvalues = '';
  ConditionModel _conditionModel = ConditionModel();
  String hint = 'Enter Flow Values';
  String dropdowntitle = '';
  String valueforwhentrue = '';
  int Selectindexrow = 0;
  int tabclickindex = 0;
  String programstr = '';
  String zonestr = '';
  String selectedOperator = '';
  List<ConditionLibrary>? conditionLibrary = [];
  Calendar selectedSegment = Calendar.Program;
  List<String> operatorList = ['&&', '||', '^'];
  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];

  int _currentSelection = 0;

  final Map<int, Widget> _segmenttab = {
    0: const Text(' Program '),
    1: const Text(' Moisture '),
    2: const Text(' Level '),
  };
  Map<String, dynamic> myjson = {
  "code": 200,
  "message": "User planning condition library listed successfully",
  "data": {
    "conditionLibrary": {
      "program": [
        {
          "sNo": 1,
          "id": "COND1",
          "location": "",
          "name": "Condition1",
          "enable": true,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Program 1 is  ending",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": true,
          "usedByProgram": "Program 1",
          "program": "Program 1",
          "zone": "",
          "dropdown1": "Program is ending",
          "dropdown2": "Program 1",
          "dropdownValue": ""
        },
        {
          "sNo": 2,
          "id": "COND2",
          "location": "",
          "name": "Condition2",
          "enable": true,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Program 1 is  running",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": false,
          "usedByProgram": "Program 1",
          "program": "Program 1",
          "zone": "",
          "dropdown1": "Program is running",
          "dropdown2": "Program 1",
          "dropdownValue": ""
        },
        {
          "sNo": 3,
          "id": "COND3",
          "location": "",
          "name": "Condition3",
          "enable": false,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Program 2 is  not running",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": true,
          "usedByProgram": "Program 2",
          "program": "Program 2",
          "zone": "",
          "dropdown1": "Program is not running",
          "dropdown2": "Program 2",
          "dropdownValue": ""
        }
      ],
      "moisture": [
        {
          "sNo": 1,
          "id": "COND1",
          "location": "",
          "name": "Condition1",
          "enable": true,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Moisture Sensor 1.1 is ture Sensor reading  value 34 ",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": true,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "Moisture Sensor reading is higher than",
          "dropdown2": "Moisture Sensor 1.1",
          "dropdownValue": "34"
        },
        {
          "sNo": 2,
          "id": "COND2",
          "location": "",
          "name": "Condition2",
          "enable": true,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Moisture Sensor 1.1 is  higher than value 1 ",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": true,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "Moisture Sensor reading is higher than",
          "dropdown2": "Moisture Sensor 1.1",
          "dropdownValue": "1"
        },
        {
          "sNo": 3,
          "id": "COND3",
          "location": "",
          "name": "Condition3",
          "enable": true,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Moisture Sensor 1.1 is ture Sensor reading  value 2 ",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": true,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "Moisture Sensor reading is lower than",
          "dropdown2": "Moisture Sensor 1.1",
          "dropdownValue": "2"
        }
      ],
      "level": [
        {
          "sNo": 1,
          "id": "COND1",
          "location": "",
          "name": "Condition1",
          "enable": false,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "Level Sensor 1.1 is  higher than value 12 ",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": false,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "Level Sensor reading is higher than",
          "dropdown2": "Level Sensor 1.1",
          "dropdownValue": "12"
        },
        {
          "sNo": 2,
          "id": "COND2",
          "location": "",
          "name": "Condition2",
          "enable": false,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": false,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "",
          "dropdown2": "",
          "dropdownValue": ""
        },
        {
          "sNo": 3,
          "id": "COND3",
          "location": "",
          "name": "Condition3",
          "enable": false,
          "state": "",
          "duration": "00:00",
          "conditionIsTrueWhen": "",
          "fromTime": "00:00",
          "untilTime": "00:00",
          "notification": false,
          "usedByProgram": "",
          "program": "",
          "zone": "",
          "dropdown1": "",
          "dropdown2": "",
          "dropdownValue": ""
        }
      ]
    },
    "default": {
      "dropdown": [
        "Program is running",
        "Program is not running",
        "Program is starting",
        "Program is ending",
        "Contact is opened",
        "Contact is closed",
        "Contact is opening",
        "Contact is closing",
        "Zone is low flow than",
        "Zone is high flow than",
        "Zone is no flow than",
        "Water meter flow is higher than",
        "Water meter flow is lower than",
        "Analog Sensor reading is higher than",
        "Analog Sensor reading is lower than",
        "Moisture Sensor reading is higher than",
        "Moisture Sensor reading is lower than",
        "Level Sensor reading is higher than",
        "Level Sensor reading is lower than",
        "Combined condition is true",
        "Combined condition is false"
      ],
      "program": [
        {
          "sNo": 1,
          "id": "PG1",
          "name": "Program 1",
          "location": ""
        },
        {
          "sNo": 2,
          "id": "PG2",
          "name": "Program 2",
          "location": ""
        },
        {
          "sNo": 3,
          "id": "PG3",
          "name": "Program 3",
          "location": ""
        },
        {
          "sNo": 4,
          "id": "PG4",
          "name": "Program 4",
          "location": ""
        }
      ],
      "analogSensor": [
        {
          "sNo": 7,
          "id": "AS1",
          "name": "Analog Sensor 1",
          "location": ""
        },
        {
          "sNo": 8,
          "id": "AS2",
          "name": "Analog Sensor 2",
          "location": ""
        },
        {
          "sNo": 9,
          "id": "AS3",
          "name": "Analog Sensor 3",
          "location": ""
        }
      ],
      "moistureSensor": [
        {
          "sNo": 119,
          "id": "MS1.1",
          "name": "Moisture Sensor 1.1",
          "location": "IL1"
        },
        {
          "sNo": 120,
          "id": "MS1.2",
          "name": "Moisture Sensor 1.2",
          "location": "IL1"
        },
        {
          "sNo": 117,
          "id": "MS2.1",
          "name": "Moisture Sensor 2.1",
          "location": "IL2"
        },
        {
          "sNo": 118,
          "id": "MS2.2",
          "name": "Moisture Sensor 2.2",
          "location": "IL2"
        }
      ],
      "levelSensor": [
        {
          "sNo": 121,
          "id": "LS1.1",
          "name": "Level Sensor 1.1",
          "location": "IL1"
        }
      ],
      "waterMeter": [
        {
          "sNo": 131,
          "id": "WMIL1.1",
          "name": "Water Meter IL 1.1",
          "location": "IL1"
        },
        {
          "sNo": 132,
          "id": "WMIL2.1",
          "name": "Water Meter IL 2.1",
          "location": "IL2"
        }
      ],
      "contact": [
        {
          "sNo": 35,
          "id": "CONT1",
          "name": "Contact 1",
          "location": ""
        },
        {
          "sNo": 36,
          "id": "CONT2",
          "name": "Contact 2",
          "location": ""
        },
        {
          "sNo": 37,
          "id": "CONT3",
          "name": "Contact 3",
          "location": ""
        },
        {
          "sNo": 38,
          "id": "CONT4",
          "name": "Contact 4",
          "location": ""
        }
      ],
      "condition": [
        {
          "sNo": 1,
          "id": "COND1",
          "location": "",
          "name": "Condition1"
        },
        {
          "sNo": 2,
          "id": "COND2",
          "location": "",
          "name": "Condition2"
        },
        {
          "sNo": 3,
          "id": "COND3",
          "location": "",
          "name": "Condition3"
        }
      ]
    }
  }
};
  @override
  void initState() {
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
        i < _conditionModel.data!.conditionProgram!.length;
        i++) {
          conditionList.add(_conditionModel.data!.conditionProgram![i].name!);
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
    // var jsondata1 = jsonDecode(myjson);

    // Map<String, Object> body = {
    //   "userId": widget.userId,
    //   "controllerId": widget.controllerId
    // };
    // final response = await HttpService()
    //     .postRequest("getUserPlanningConditionLibrary", body);
    // if (response.statusCode == 200) {
      setState(() {
         _conditionModel = ConditionModel.fromJson(myjson);
        _conditionModel.data!.dropdown!.insert(0, '');
        if (_conditionModel.data != null &&
            _conditionModel.data!.conditionProgram != null &&
            _conditionModel.data!.conditionProgram!.isNotEmpty) {
          setState(() {
            _tabController = TabController(
                length: _conditionModel.data!.conditionProgram!.length,
                vsync: this);
            _tabController.addListener(_handleTabSelection);
            conditionLibrary = _conditionModel.data!.conditionProgram!;
            for (var i = 0;
            i < _conditionModel.data!.conditionProgram!.length;
            i++) {
              conditionList
                  .add(_conditionModel.data!.conditionProgram![i].name!);
            }
          });
        }
      });
    // } else {
    //   //_showSnackBar(response.body);
    // }
  }

  @override
  void checklistdropdown() async {
    usedprogramdropdownlist = [];
    dropdowntitle = '';
    hint = '';

    if (usedprogramdropdownstr.contains('Program')) {
      usedprogramdropdownlist = _conditionModel.data!.program;
      dropdowntitle = 'Program';
      hint = 'Programs';
    }
    if (usedprogramdropdownstr.contains('Contact')) {
      usedprogramdropdownlist = _conditionModel.data!.contact;
      dropdowntitle = 'Contact';
      hint = 'Contacts';
    }
    if (usedprogramdropdownstr.contains('Level')) {
      usedprogramdropdownlist = _conditionModel.data!.levelSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Moisture')) {
      usedprogramdropdownlist = _conditionModel.data!.moistureSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Analog')) {
      usedprogramdropdownlist = _conditionModel.data!.analogSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Water')) {
      usedprogramdropdownlist = _conditionModel.data!.waterMeter;
      dropdowntitle = 'Water Meter';
      hint = 'Flow';
    }
    if (usedprogramdropdownstr.contains('Conbined')) {
      usedprogramdropdownlist = _conditionModel.data!.waterMeter;
      dropdowntitle = 'Expression';
      hint = 'Expression';
    }
    if (usedprogramdropdownlist!.isNotEmpty) {
      usedprogramdropdownstr2 = usedprogramdropdownstr2 == ''
          ? '${usedprogramdropdownlist?[0].name}'
          : usedprogramdropdownstr2;
    }
  }

  Future<String?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      _selectedTime = picked;
      final hour = _selectedTime.hour.toString().padLeft(2, '0');
      final minute = _selectedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return null;
  }

  String conditionselection(String name, String id, String value) {
    programstr = '';
    zonestr = '';
    String conditionselectionstr = '';
    if (usedprogramdropdownstr.contains('Program')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]}';
      programstr = id;
    }
    if (usedprogramdropdownstr.contains('Sensor')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr =
      '$id is ${usedprogramdropdownstrarr[1]} value $value ';
    }
    if (usedprogramdropdownstr.contains('Contact')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$name value is $value ';
    }
    if (usedprogramdropdownstr.contains('Water')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]} $value';
    }
    if (usedprogramdropdownstr.contains('Conbined')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
    }
    if (usedprogramdropdownstr.contains('Zone')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
      zonestr = name;
    }
    return conditionselectionstr;
  }

  @override
  Widget build(BuildContext context) {
    if (_conditionModel.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (conditionLibrary!.length <= 0) {
      return Container(
        child: const Center(
            child: Text(
              'Condition Not Found',
              style: TextStyle(color: Colors.black, fontSize: 20),
            )),
      );
    } else {
      return DefaultTabController(
        length: conditionLibrary!.length ?? 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            // appBar: AppBar(
            //   title: const Text('Conditions Library'),
            //   backgroundColor: Color.fromARGB(255, 31, 164, 231),
            //   //  _currentSelection == 0 ? rain() : buildFrostselection(),
            // ),
            body: buildcodition(context),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      conditionselection(usedprogramdropdownstr,
                          usedprogramdropdownstr2, valueforwhentrue);
                  conditionLibrary![Selectindexrow].program = programstr;
                  conditionLibrary![Selectindexrow].zone = zonestr;
                  conditionLibrary![Selectindexrow].dropdown1 =
                      usedprogramdropdownstr;
                  conditionLibrary![Selectindexrow].dropdown2 =
                      usedprogramdropdownstr2;
                  conditionLibrary![Selectindexrow].dropdownValue =
                      valueforwhentrue;
                  updateconditions();
                });
              },
              tooltip: 'Send',
              child: const Icon(Icons.send),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget buildcodition(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),

          SegmentedButton<Calendar>(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                  myTheme.primaryColor.withOpacity(0.1)),
              iconColor: MaterialStateProperty.all(myTheme.primaryColor),
            ),
            segments: const <ButtonSegment<Calendar>>[
              ButtonSegment<Calendar>(
                  value: Calendar.Program,
                  label: Text('Program'),
                  icon: Icon(Icons.list_alt)),
              ButtonSegment<Calendar>(
                  value: Calendar.Moisture,
                  label: Text('Moisture'),
                  icon: Icon(Icons.water_drop_outlined)),
              ButtonSegment<Calendar>(
                  value: Calendar.Level,
                  label: Text('Level'),
                  icon: Icon(Icons.water_outlined)),
            ],
            //   selected: {selectedSegment},
            //   onSelectionChanged: (Set<Calendar> newSelection) {
            //     setState(() {
            //       selectedSegment = newSelection.first;
            //     });
            //   },
            // ),

            selected: <Calendar>{selectedSegment},
            onSelectionChanged: (Set<Calendar> newSelection) {
              setState(() {
                print('selectedSegment$selectedSegment');
                selectedSegment = newSelection.first;

                if (selectedSegment == Calendar.Program) {
                  conditionLibrary =
                  _conditionModel.data!.conditionProgram!;
                } else if (selectedSegment == Calendar.Moisture) {
                  conditionLibrary =
                  _conditionModel.data!.conditionMoisture!;
                } else {
                  conditionLibrary =
                  _conditionModel.data!.conditionLevel!;
                }
              });
            },
          ),
          Expanded(
            child: DefaultTabController(
              length: conditionLibrary!.length, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color.fromARGB(255, 175, 73, 73),
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
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 255,
                    child: TabBarView(controller: _tabController, children: [
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

  changeval(int Selectindexrow) {
    usedprogramdropdownstr = conditionLibrary![Selectindexrow].dropdown1!;
    usedprogramdropdownstr2 = conditionLibrary![Selectindexrow].dropdown2!;
    // valueforwhentrue =
    //     _conditionModel.data!.conditionLibrary![Selectindexrow].dropdownValue!;
    dropdownvalues = conditionLibrary![Selectindexrow].dropdownValue!;

    checklistdropdown();
  }

//TODO:-  ConditionTab
  Widget ConditionTab(int i, List<ConditionLibrary>? conditionLibrary) {
    // tabclickindex = i;
    // changeval(i);
    // _handleTabSelection
    //  _tabController.index = i;
    if (_tabController.index == i) {
      String conditiontrue = conditionLibrary![i].conditionIsTrueWhen!;

      bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
      bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);

      if ((usedprogramdropdownstr.contains('Combined') == true)) {
        if (conditionList.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 = conditionLibrary[i].dropdown2!;
        } else {
          usedprogramdropdownstr2 = "";
        }
      } else {
        List<String> names = usedprogramdropdownlist!
            .map((contact) => contact.name as String)
            .toList();
        if (names.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 = conditionLibrary[i].dropdown2!;
        } else {
          if (usedprogramdropdownlist!.length > 0) {
            usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
          }
        }
        if (usedprogramdropdownstr2.isEmpty &&
            usedprogramdropdownlist!.isNotEmpty) {
          usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              height: 40,
              child:
              Center(child: Text('${i + 1}. ${conditionLibrary![i].id}')),
              color: Colors.amber,
            ),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[2]),
                  trailing: Text(conditionLibrary![i].name.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[3]),
                  trailing: MySwitch(
                    value: conditionLibrary![i].enable ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].enable = value;
                      });
                    }),
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[4]),
                  trailing: Text(conditionLibrary![i].state.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[5]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${conditionLibrary![i].duration}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time == null) {
                            conditionLibrary![i].duration = time;
                          }
                        });
                      },
                    ),
                  ),
                )),
            InkWell(
              onTap: () async {
                 setState(() {
                   _showFormulaBottomSheet(conditionLibrary![i].id!,i) ;
                });
              },
              child: Card(
                  child: ListTile(
                    title: Text(conditionhdrlist[6]),
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
                child: ListTile(
                  title: Text(conditionhdrlist[10]),
                  trailing: Text(
                    conditionLibrary![i].usedByProgram.toString(),
                    softWrap: true,
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[7]),
                  trailing: InkWell(
                    child: Text(
                      '${conditionLibrary![i].fromTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          conditionLibrary![i].fromTime = time;
                        }
                      });
                    },
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[8]),
                  trailing: InkWell(
                    child: Text(
                      '${conditionLibrary![i].untilTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          conditionLibrary![i].untilTime = time;
                        }
                      });
                    },
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[9]),
                  trailing: MySwitch(
                    value: conditionLibrary![i].notification ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].notification = value;
                      });
                    }),
                  ),
                )),
            //  Card(child: ListTile(title: Text(conditionhdrlist[9]),trailing: Text(_conditionModel.data!.conditionLibrary![i].usedByProgram.toString(),softWrap: true,),)),

            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (usedprogramdropdownstr.contains('Program')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, '');
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].usedByProgram =
                          programstr;

                      List<UserNames>? program = _conditionModel.data!.program!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Contact')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(
                              usedprogramdropdownstr, '', dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      List<UserNames>? program = _conditionModel.data!.contact!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Analog')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.analogSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Moisture')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.moistureSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Level')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.levelSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Water')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.waterMeter!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('condition')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      '$usedprogramdropdownstr ${conditionList[Selectindexrow]} $dropdownvalues $usedprogramdropdownstr2';
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow].program = dropdownvalues;

                      List<ConditionLibrary>? program = conditionLibrary;
                      if (program != null) {
                        String? sNo = getSNoByNamecondition(
                            program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Zone')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].program = '0';
                    } else {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      '';
                      conditionLibrary![Selectindexrow].dropdown1 = '';
                      conditionLibrary![Selectindexrow].dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].program = '0';
                    }
                  });
                },
                child: const Text('Apply Changes'))
            //  TextButton(onPressed: (){}, child: Text('Apply')),
          ]),
        ),
      );
    } else
      return Center();
  }
  void _showFormulaBottomSheet(String title,int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return buildconditionselection(title,index);
      },
    );
  }
  Widget buildconditionselection(String? title, int index) {
    changeval(index);
    String conditiontrue = conditionLibrary![index].conditionIsTrueWhen!;
    bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
    bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);
    List<String>? Moiturelist = [
      "",
      "Moisture Sensor reading is higher than",
      "Moisture Sensor reading is lower than",
    ];
    List<String> levelList = [
      "",
      "Level Sensor reading is higher than",
      "Level Sensor reading is lower than",
    ];
    List<String>? dropdownflist = _conditionModel.data!.dropdown!;

    if (selectedSegment == Calendar.Program) {
      dropdownflist = _conditionModel.data!.dropdown!
          .where(
              (item) => !item.contains("Moisture") && !item.contains("Level"))
          .toList();
    } else if (selectedSegment == Calendar.Moisture) {
      dropdownflist = Moiturelist;
    } else {
      dropdownflist = levelList;
    }
    print("dropdownflist$dropdownflist");

    if ((usedprogramdropdownstr.contains('Combined') == true)) {
      if (conditionList.contains(usedprogramdropdownstr2)) {
        usedprogramdropdownstr2 = conditionLibrary![index].dropdown2!;
      } else {
        usedprogramdropdownstr2 = "";
      }
    } else {
      List<String> names = usedprogramdropdownlist!
          .map((contact) => contact.name as String)
          .toList();
      if (names.contains(usedprogramdropdownstr2)) {
        usedprogramdropdownstr2 = usedprogramdropdownstr2;
      } else {
        if (usedprogramdropdownlist!.length > 0) {
          usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
        }
      }
    }
    if (usedprogramdropdownstr2.isEmpty &&
        usedprogramdropdownlist!.isNotEmpty) {
      usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
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
    if (selectedSegment == Calendar.Program) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                width: double.infinity,
                color: primaryColorDark,
                child: Center(
                    child: Text(
                      '$title',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
              ),
              // const Text('When in Used'),
              if (Selectindexrow != null)
              //First Dropdown values
                DropdownButton(
                  items: dropdownflist?.map((String? items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            items!,
                            style: TextStyle(fontSize: 12.5),
                          )),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      usedprogramdropdownstr = value.toString();
                      conditionLibrary![Selectindexrow].dropdown1 = value!;
                      checklistdropdown();
                    });
                  },
                  value: usedprogramdropdownstr == ''
                      ? conditionLibrary![Selectindexrow].dropdown1!.isEmpty
                      ? (_conditionModel.data!.dropdown![0])
                      : conditionLibrary![Selectindexrow]
                      .dropdown1!
                      .toString()
                      : usedprogramdropdownstr,
                ),
              if (usedprogramdropdownlist?.length != 0) Text(dropdowntitle),
              if (usedprogramdropdownstr.contains('Combined') == false &&
                  usedprogramdropdownlist?.length != 0)
                DropdownButton(
                  hint: Text(''),
                  items: usedprogramdropdownlist?.map((UserNames items) {
                    return DropdownMenuItem(
                      value: '${items.name}',
                      child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('${items.name}')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      usedprogramdropdownstr2 = value.toString();
                      conditionLibrary![Selectindexrow].dropdown2 =
                          value.toString();
                    });
                  },
                  value: usedprogramdropdownstr2,
                ),
              if (usedprogramdropdownstr.contains('Sensor') ||
                  usedprogramdropdownstr.contains('Contact') ||
                  usedprogramdropdownstr.contains('Water'))
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: TextFormField(
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      initialValue: containsOnlyNumbers ? dropdownvalues : null,
                      showCursor: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      decoration: InputDecoration(
                          hintText: hint, border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          dropdownvalues = value;
                          conditionLibrary![Selectindexrow].dropdownValue =
                              dropdownvalues;
                        });
                      },
                    ),
                  ),
                ),
              if (usedprogramdropdownstr.contains('Combined'))
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    //Dropdown for operator  values
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          value: containsOnlyOperators ? dropdownvalues : null,
                          hint: Text('Select Operator'),
                          onChanged: (value) {
                            setState(() {
                              dropdownvalues = value!;
                              conditionLibrary![Selectindexrow].dropdownValue =
                              value!;
                              print('dropdownValue $value');
                            });
                          },
                          items: operatorList.map((operator) {
                            return DropdownMenuItem(
                              value: operator,
                              child: Text(operator),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 16),
                        //Dropdown for Condition 2 values
                        DropdownButton<String>(
                          value: usedprogramdropdownstr2.isEmpty
                              ? null
                              : usedprogramdropdownstr2,
                          hint: Text('$usedprogramdropdownstr2'),
                          onChanged: (value) {
                            setState(() {
                              usedprogramdropdownstr2 = value!;
                              conditionLibrary![Selectindexrow].dropdown2 =
                              value!;
                              print('dropdown2 $value');
                            });
                          },
                          items: filterlist(
                              conditionList, conditionList[Selectindexrow])
                              .map((condition) {
                            return DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            );
                          }).toList(),
                        ),
                      ],
                    )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (usedprogramdropdownstr.contains('Program')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            conditionselection(usedprogramdropdownstr,
                                usedprogramdropdownstr2, '');
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = '';
                        conditionLibrary![Selectindexrow].usedByProgram =
                            programstr;

                        List<UserNames>? program = _conditionModel.data!
                            .program!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      } else if (usedprogramdropdownstr.contains('Contact')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            conditionselection(
                                usedprogramdropdownstr, '', dropdownvalues);
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        List<UserNames>? program = _conditionModel.data!
                            .contact!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      } else if (usedprogramdropdownstr.contains('Analog')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            conditionselection(usedprogramdropdownstr,
                                usedprogramdropdownstr2, dropdownvalues);
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        List<UserNames>? program =
                        _conditionModel.data!.analogSensor!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      }
                      else if (usedprogramdropdownstr.contains('Moisture')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            conditionselection(usedprogramdropdownstr,
                                usedprogramdropdownstr2, dropdownvalues);
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        List<UserNames>? program =
                        _conditionModel.data!.analogSensor!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      }
                      else if (usedprogramdropdownstr.contains('Level')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            conditionselection(usedprogramdropdownstr,
                                usedprogramdropdownstr2, dropdownvalues);
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        List<UserNames>? program =
                        _conditionModel.data!.analogSensor!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      } else if (usedprogramdropdownstr.contains('Water')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        List<UserNames>? program =
                        _conditionModel.data!.waterMeter!;
                        if (program != null) {
                          String? sNo =
                          getSNoByName(program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      } else if (usedprogramdropdownstr.contains('condition')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                        '$usedprogramdropdownstr ${conditionList[Selectindexrow]} $dropdownvalues $usedprogramdropdownstr2';
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 =
                            usedprogramdropdownstr2;
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = dropdownvalues;
                        // conditionLibrary![Selectindexrow].program = dropdownvalues;

                        List<ConditionLibrary>? program = conditionLibrary;
                        if (program != null) {
                          String? sNo = getSNoByNamecondition(
                              program, usedprogramdropdownstr2);
                          if (sNo != null) {
                            conditionLibrary![Selectindexrow].program = '$sNo';
                          } else {
                            conditionLibrary![Selectindexrow].program = '0';
                          }
                        }
                      } else if (usedprogramdropdownstr.contains('Zone')) {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown1 =
                            usedprogramdropdownstr;
                        conditionLibrary![Selectindexrow].dropdown2 = '';
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = '';
                        conditionLibrary![Selectindexrow].program = '0';
                      } else {
                        conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                        '';
                        conditionLibrary![Selectindexrow].dropdown1 = '';
                        conditionLibrary![Selectindexrow].dropdown2 = '';
                        // conditionLibrary![Selectindexrow]
                        //     .dropdownValue = '';
                        conditionLibrary![Selectindexrow].program = '0';
                        conditionLibrary![Selectindexrow].usedByProgram = '';
                      }
                    });
                  },
                  child: const Text('Apply Changes'))
            ],
          ),
        ),
      );
    }
    else
      {
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: double.infinity,
                  color: primaryColorDark,
                  child: Center(
                      child: Text(
                        '$title',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ),
                // const Text('When in Used'),
                if (Selectindexrow != null)
                //First Dropdown values
                  DropdownButton(
                    items: dropdownflist?.map((String? items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              items!,
                              style: TextStyle(fontSize: 12.5),
                            )),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        usedprogramdropdownstr = value.toString();
                        conditionLibrary![Selectindexrow].dropdown1 = value!;
                        checklistdropdown();
                      });
                    },
                    value: usedprogramdropdownstr == ''
                        ? conditionLibrary![Selectindexrow].dropdown1!.isEmpty
                        ? (_conditionModel.data!.dropdown![0])
                        : conditionLibrary![Selectindexrow]
                        .dropdown1!
                        .toString()
                        : usedprogramdropdownstr,
                  ),
                if (usedprogramdropdownlist?.length != 0) Text(dropdowntitle),
                   DropdownButton(
                    hint: Text(''),
                    items: usedprogramdropdownlist?.map((UserNames items) {
                      return DropdownMenuItem(
                        value: '${items.name}',
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('${items.name}')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        usedprogramdropdownstr2 = value.toString();
                        conditionLibrary![Selectindexrow].dropdown2 =
                            value.toString();
                      });
                    },
                    value: usedprogramdropdownstr2,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: TextFormField(
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        initialValue: containsOnlyNumbers ? dropdownvalues : null,
                        showCursor: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                        decoration: InputDecoration(
                            hintText: hint, border: OutlineInputBorder()),
                        onChanged: (value) {
                          setState(() {
                            dropdownvalues = value;
                            conditionLibrary![Selectindexrow].dropdownValue =
                                dropdownvalues;
                          });
                        },
                      ),
                    ),
                  ),
                if (usedprogramdropdownstr.contains('Combined'))
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      //Dropdown for operator  values
                      child: Column(
                        children: [
                          DropdownButton<String>(
                            value: containsOnlyOperators ? dropdownvalues : null,
                            hint: Text('Select Operator'),
                            onChanged: (value) {
                              setState(() {
                                dropdownvalues = value!;
                                conditionLibrary![Selectindexrow].dropdownValue =
                                value!;
                                print('dropdownValue $value');
                              });
                            },
                            items: operatorList.map((operator) {
                              return DropdownMenuItem(
                                value: operator,
                                child: Text(operator),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 16),
                          //Dropdown for Condition 2 values
                          DropdownButton<String>(
                            value: usedprogramdropdownstr2.isEmpty
                                ? null
                                : usedprogramdropdownstr2,
                            hint: Text('$usedprogramdropdownstr2'),
                            onChanged: (value) {
                              setState(() {
                                usedprogramdropdownstr2 = value!;
                                conditionLibrary![Selectindexrow].dropdown2 =
                                value!;
                                print('dropdown2 $value');
                              });
                            },
                            items: filterlist(
                                conditionList, conditionList[Selectindexrow])
                                .map((condition) {
                              return DropdownMenuItem(
                                value: condition,
                                child: Text(condition),
                              );
                            }).toList(),
                          ),
                        ],
                      )),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (usedprogramdropdownstr.contains('Program')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              conditionselection(usedprogramdropdownstr,
                                  usedprogramdropdownstr2, '');
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = '';
                          conditionLibrary![Selectindexrow].usedByProgram =
                              programstr;

                          List<UserNames>? program = _conditionModel.data!
                              .program!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        } else if (usedprogramdropdownstr.contains('Contact')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              conditionselection(
                                  usedprogramdropdownstr, '', dropdownvalues);
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          List<UserNames>? program = _conditionModel.data!
                              .contact!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        } else if (usedprogramdropdownstr.contains('Analog')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              conditionselection(usedprogramdropdownstr,
                                  usedprogramdropdownstr2, dropdownvalues);
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          List<UserNames>? program =
                          _conditionModel.data!.analogSensor!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        }
                        else if (usedprogramdropdownstr.contains('Moisture')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              conditionselection(usedprogramdropdownstr,
                                  usedprogramdropdownstr2, dropdownvalues);
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          List<UserNames>? program =
                          _conditionModel.data!.analogSensor!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        }
                        else if (usedprogramdropdownstr.contains('Level')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              conditionselection(usedprogramdropdownstr,
                                  usedprogramdropdownstr2, dropdownvalues);
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          List<UserNames>? program =
                          _conditionModel.data!.analogSensor!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        } else if (usedprogramdropdownstr.contains('Water')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          List<UserNames>? program =
                          _conditionModel.data!.waterMeter!;
                          if (program != null) {
                            String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        } else if (usedprogramdropdownstr.contains('condition')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          '$usedprogramdropdownstr ${conditionList[Selectindexrow]} $dropdownvalues $usedprogramdropdownstr2';
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 =
                              usedprogramdropdownstr2;
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = dropdownvalues;
                          // conditionLibrary![Selectindexrow].program = dropdownvalues;

                          List<ConditionLibrary>? program = conditionLibrary;
                          if (program != null) {
                            String? sNo = getSNoByNamecondition(
                                program, usedprogramdropdownstr2);
                            if (sNo != null) {
                              conditionLibrary![Selectindexrow].program = '$sNo';
                            } else {
                              conditionLibrary![Selectindexrow].program = '0';
                            }
                          }
                        } else if (usedprogramdropdownstr.contains('Zone')) {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown1 =
                              usedprogramdropdownstr;
                          conditionLibrary![Selectindexrow].dropdown2 = '';
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = '';
                          conditionLibrary![Selectindexrow].program = '0';
                        } else {
                          conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          '';
                          conditionLibrary![Selectindexrow].dropdown1 = '';
                          conditionLibrary![Selectindexrow].dropdown2 = '';
                          // conditionLibrary![Selectindexrow]
                          //     .dropdownValue = '';
                          conditionLibrary![Selectindexrow].program = '0';
                          conditionLibrary![Selectindexrow].usedByProgram = '';
                        }
                      });
                    },
                    child: const Text('Apply Changes'))
              ],
            ),
          ),
        );
      }
  }
   updateconditions() async {
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

    Map<String, dynamic> conditionJo2n = _conditionModel.data!.toJson();
    //    print('  print(conditionJso2n["conditionLibrary"]) ${conditionJo2n[
    // "conditionLibrary"]["program"]}');
    Map<String, dynamic> finaljson = {
      "program": programJson,
      "moisture": moistureJson,
      "level": levelJson
    };

    String Mqttsenddata = toMqttformat(conditionLibrary);
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "condition": finaljson,
      "createUser": widget.userId
    };
    final response = await HttpService()
        .postRequest("createUserPlanningConditionLibrary", body);
    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);

    String payLoadFinal = jsonEncode({
      "700": [
        {"708": Mqttsenddata},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}' );
  }

  List<String> filterlist(List<String> conditionlist, String removevalue) {
    conditionlist =
        conditionlist.where((item) => item != '$removevalue').toList();
    return conditionlist;
  }

  String? getSNoByName(List<UserNames> data, String name) {
    UserNames? user = data.firstWhere((element) => element.name == name,
        orElse: () => UserNames());
    return user.sNo.toString();
  }

  String? getSNoByNamecondition(List<ConditionLibrary>? data, String name) {
    ConditionLibrary user = data!.firstWhere((element) => element.name == name,
        orElse: () => ConditionLibrary());
    return user.sNo;
  }

  String toMqttformat(
      List<ConditionLibrary>? data,
      ) {
    String Mqttdata = '';
    for (var i = 0; i < data!.length; i++) {
      String enablevalue = data[i].enable! ? '1' : '0';
      String Notifigation = data[i].notification! ? '1' : '0';
      String conditionIsTrueWhenvalue = '0,0,0,0';
      String Combine = '';

      if (data[i].conditionIsTrueWhen!.contains('Program')) {
        if (data[i].conditionIsTrueWhen!.contains('running')) {
          conditionIsTrueWhenvalue = "1,1,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('not running')) {
          conditionIsTrueWhenvalue = "1,2,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('starting')) {
          conditionIsTrueWhenvalue = "1,3,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('ending')) {
          conditionIsTrueWhenvalue = "1,4,${data[i].program},0";
        } else {
          conditionIsTrueWhenvalue = "1,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Contact')) {
        if (data[i].conditionIsTrueWhen!.contains('opened')) {
          conditionIsTrueWhenvalue =
          "2,5,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('closed')) {
          conditionIsTrueWhenvalue =
          "2,6,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('opening')) {
          conditionIsTrueWhenvalue =
          "2,7,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('closing')) {
          conditionIsTrueWhenvalue =
          "2,8,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "2,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Zone')) {
        if (data[i].conditionIsTrueWhen!.contains('low flow than')) {
          conditionIsTrueWhenvalue = "6,9,0,0";
        } else if (data[i].conditionIsTrueWhen!.contains('high flow than')) {
          conditionIsTrueWhenvalue = "6,10,0,0";
        } else if (data[i].conditionIsTrueWhen!.contains('no flow than')) {
          conditionIsTrueWhenvalue = "6,11,0,0";
        } else {
          conditionIsTrueWhenvalue = "6,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Water')) {
        if (data[i].conditionIsTrueWhen!.contains('higher than')) {
          conditionIsTrueWhenvalue =
          "4,12,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('lower than')) {
          conditionIsTrueWhenvalue =
          "4,13,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "4,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Sensor')) {
        if (data[i].conditionIsTrueWhen!.contains('higher than')) {
          conditionIsTrueWhenvalue =
          "3,14,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('lower than')) {
          conditionIsTrueWhenvalue =
          "3,15,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "3,0,0,0";
        }
      }
      //  Combine =
      else if (data[i].conditionIsTrueWhen!.contains('condition')) {
        String operator = data[i].dropdownValue!;
        if (operator == "&&") {
          operator = "1";
        } else if (operator == "||") {
          operator = "2";
        } else if (operator == "^") {
          operator = "3";
        } else {
          operator = "0";
        }
        if (data[i]
            .conditionIsTrueWhen!
            .contains('Combined condition is true')) {
          conditionIsTrueWhenvalue =
          "5,16,${data[i].sNo},$operator,${data[i].program}";
        } else if (data[i]
            .conditionIsTrueWhen!
            .contains('Combined condition is false')) {
          conditionIsTrueWhenvalue =
          "5,17,${data[i].sNo},$operator,${data[i].program}";
        } else {
          conditionIsTrueWhenvalue = "5,0,0,0";
        }
      } else {
        conditionIsTrueWhenvalue = "0,0,0,0";
      }
      Mqttdata +=
      '${data[i].sNo},${data[i].name},$enablevalue,${data[i].duration}:00,${data[i].fromTime}:00,${data[i].untilTime}:00,$Notifigation,$conditionIsTrueWhenvalue;';
    }
    return Mqttdata;
  }
}