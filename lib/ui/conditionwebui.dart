import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';

 import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../constants/MQTTManager.dart';
import '../constants/theme.dart';
import '../model/condition_model.dart';

enum Calendar { Program, Moisture, Level }

class ConditionwebUI extends StatefulWidget {
  const ConditionwebUI(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.imeiNo});
  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionwebUI> createState() => _ConditionwebUIState();
}

class _ConditionwebUIState extends State<ConditionwebUI>
    with TickerProviderStateMixin {
  dynamic jsondata;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> conditionhdrlist = [
    'SNo',
    'Name',
    'Enable',
    'State',
    'Duration',
    'Condition IsTrue',
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
  String programstr = '';
  String zonestr = '';
  List<String> operatorList = ['&&', '||', '^'];
  String selectedOperator = '';
  String selectedValue = '';
  String selectedCondition = '';
  List<String> conditionList = [];
  List<ConditionLibrary>? conditionLibrary = [];

  Calendar selectedSegment = Calendar.Program;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (_conditionModel.data != null &&
        _conditionModel.data!.conditionProgram != null &&
        _conditionModel.data!.conditionProgram!.isNotEmpty) {
      setState(() {
        for (var i = 0;
        i < _conditionModel.data!.conditionProgram!.length;
        i++) {
          conditionList.add(_conditionModel.data!.conditionProgram![i].name!);
        }
      });
    }
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningConditionLibrary", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _conditionModel = ConditionModel.fromJson(jsondata1);
        _conditionModel.data!.dropdown!.insert(0, '');
        conditionLibrary = _conditionModel.data!.conditionProgram!;
      });
    } else {
      //_showSnackBar(response.body);
    }
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

  int _currentSelection = 0;

  final Map<int, Widget> _children = {
    0: const Text(' Program '),
    1: const Text(' Moisture '),
    2: const Text(' Level '),
  };
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
    print(usedprogramdropdownlist);
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

  Widget build(BuildContext context) {
    if (_conditionModel.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (conditionLibrary!.length <= 0 || conditionLibrary!.isEmpty) {
      return Container(
        child: const Center(
            child: Text(
              'Condition Not Found',
              style: TextStyle(color: Colors.black, fontSize: 20),
            )),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                build1(context)
                //  _currentSelection == 0 ? rain() : buildFrostselection(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            updateconditions();
          },
          tooltip: 'Send',
          child: const Icon(Icons.send),
        ),
      );
    }
  }

  Widget build1(BuildContext context) {
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
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DataTable2(
                  headingRowColor:
                  MaterialStateProperty.all<Color>(primaryColorDark),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 1000,
                  fixedLeftColumns: 2,
                  border: TableBorder.all(),
                  columns: [
                    for (int i = 0; i < conditionhdrlist.length; i++)
                      i == 0
                          ? DataColumn2(
                        fixedWidth: 60,
                        label: Center(
                            child: Text(
                              conditionhdrlist[i].toString(),
                              style: TextStyle(
                                  fontSize: _fontSizeheading(),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              softWrap: true,
                            )),
                      )
                          : i == 2 ||
                          i == 3 ||
                          i == 4 ||
                          i == 6 ||
                          i == 7 ||
                          i == 8
                          ? DataColumn2(
                        fixedWidth: 100,
                        label: Center(
                            child: Text(
                              conditionhdrlist[i].toString(),
                              style: TextStyle(
                                  fontSize: _fontSizeheading(),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              softWrap: true,
                            )),
                      )
                          : DataColumn2(
                        size: ColumnSize.M,
                        label: Center(
                            child: Text(
                              conditionhdrlist[i].toString(),
                              style: TextStyle(
                                  fontSize: _fontSizeheading(),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              softWrap: true,
                            )),
                      ),
                  ],
                  rows: List<DataRow>.generate(
                      conditionLibrary!.length,
                          (index) => DataRow(
                        color: MaterialStateColor.resolveWith((states) {
                          if (index == Selectindexrow) {
                            return primaryColorDark
                                .withOpacity(0.5); // Selected row color
                          }
                          return primaryColorDark.withOpacity(0.05);
                        }),
                        cells: [
                          for (int i = 0; i < conditionhdrlist.length; i++)
                            if (conditionhdrlist[i] == 'Enable')
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                Center(
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: Switch(
                                      value:
                                      conditionLibrary![index].enable ??
                                          false,
                                      onChanged: ((value) {
                                        setState(() {
                                          Selectindexrow = index;
                                          conditionLibrary![index].enable =
                                              value;
                                        });
                                      }),
                                    ),
                                  ),
                                ),
                              )
                            else if (conditionhdrlist[i] == 'Notification')
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                Center(
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: Switch(
                                      value: conditionLibrary![index]
                                          .notification ??
                                          false,
                                      onChanged: ((value) {
                                        setState(() {
                                          Selectindexrow = index;
                                          conditionLibrary![index]
                                              .notification = value;
                                        });
                                      }),
                                    ),
                                  ),
                                ),
                              )
                            else if (conditionhdrlist[i] == 'Duration')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                          child: Text(
                                            '${conditionLibrary![index].duration}',
                                            style: TextStyle(
                                                fontSize: _fontSizelabel()),
                                          ),
                                          onTap: () async {
                                            String? time =
                                            await _selectTime(context);
                                            setState(() {
                                              if (time != null) {
                                                Selectindexrow = index;
                                                conditionLibrary![index]
                                                    .duration = time;
                                              }
                                            });
                                          },
                                        )))
                              else if (conditionhdrlist[i] == 'Unit Hour')
                                  DataCell(onTap: () {
                                    setState(() {
                                      Selectindexrow = index;
                                    });
                                  },
                                      Center(
                                          child: InkWell(
                                            child: Text(
                                              '${conditionLibrary![index].untilTime}',
                                              style: TextStyle(
                                                  fontSize: _fontSizelabel()),
                                            ),
                                            onTap: () async {
                                              String? time =
                                              await _selectTime(context);
                                              setState(() {
                                                if (time != null) {
                                                  Selectindexrow = index;
                                                  conditionLibrary![index]
                                                      .untilTime = time;
                                                }
                                              });
                                            },
                                          )))
                                else if (conditionhdrlist[i] == 'From Hour')
                                    DataCell(onTap: () {
                                      setState(() {
                                        Selectindexrow = index;
                                      });
                                    },
                                        Center(
                                            child: InkWell(
                                              child: Text(
                                                '${conditionLibrary![index].fromTime}',
                                                style: TextStyle(
                                                    fontSize: _fontSizelabel()),
                                              ),
                                              onTap: () async {
                                                String? time =
                                                await _selectTime(context);
                                                setState(() {
                                                  if (time != null) {
                                                    Selectindexrow = index;
                                                    conditionLibrary![index]
                                                        .fromTime = time;
                                                  }
                                                });
                                              },
                                            )))
                                  else if (conditionhdrlist[i] == 'SNo')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: Text(
                                                '${conditionLibrary![index].sNo}',
                                              )))
                                    else if (conditionhdrlist[i] == 'ID')
                                        DataCell(onTap: () {
                                          setState(() {
                                            Selectindexrow = index;
                                          });
                                        },
                                            Center(
                                                child: Text(
                                                  '${conditionLibrary![index].id}',
                                                )))
                                      else if (conditionhdrlist[i] == 'Name')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                    '${conditionLibrary![index].name}',
                                                    style: TextStyle(
                                                        fontSize: _fontSizelabel()),
                                                  )))
                                        else if (conditionhdrlist[i] ==
                                              'Condition IsTrue')
                                            DataCell(onTap: () {
                                              setState(() {
                                                Selectindexrow = index;
                                              });
                                            },
                                                Center(
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.vertical,
                                                      child: Container(
                                                        child: Text(
                                                          '${conditionLibrary![index].conditionIsTrueWhen}',
                                                          style: TextStyle(
                                                              fontSize: _fontSizelabel()),
                                                        ),
                                                      ),
                                                    )))
                                          else if (conditionhdrlist[i] == 'State')
                                              DataCell(onTap: () {
                                                setState(() {
                                                  Selectindexrow = index;
                                                });
                                              },
                                                  Center(
                                                      child: Text(
                                                        '${conditionLibrary![index].state}',
                                                        style: TextStyle(
                                                            fontSize: _fontSizelabel()),
                                                      )))
                                            else if (conditionhdrlist[i] == 'Used Program')
                                                DataCell(onTap: () {
                                                  setState(() {
                                                    Selectindexrow = index;
                                                  });
                                                },
                                                    Center(
                                                        child: Text(
                                                          '${conditionLibrary![index].usedByProgram}',
                                                          style: TextStyle(
                                                              fontSize: _fontSizelabel()),
                                                        )))
                                              else
                                                DataCell(onTap: () {
                                                  setState(() {
                                                    Selectindexrow = index;
                                                  });
                                                },
                                                    Center(
                                                        child: Text(
                                                          '',
                                                          style: TextStyle(
                                                              fontSize: _fontSizelabel()),
                                                        )))
                        ],
                      ))
                // )
              ),
            ),
            SizedBox(
              width: 300,
              child: buildconditionselection(
                conditionLibrary![Selectindexrow].id,
                Selectindexrow,
              ),
            )
          ],
          //  )
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () async {
          //     updateconditions();
          //   },
          //   tooltip: 'Send',
          //   child: const Icon(Icons.send),
          // ),
        ),
      );
    }
  }

  Widget buildconditionselection(String? title, int index) {
    changeval();
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
                      conditionLibrary![Selectindexrow].usedByProgram = '';
                      // conditionLibrary![Selectindexrow]
                      //     .dropdownValue = dropdownvalues;
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

  changeval() {
    usedprogramdropdownstr = conditionLibrary![Selectindexrow].dropdown1!;
    usedprogramdropdownstr2 = conditionLibrary![Selectindexrow].dropdown2!;
    // valueforwhentrue =
    //     conditionLibrary![Selectindexrow].dropdownValue!;
    dropdownvalues = conditionLibrary![Selectindexrow].dropdownValue!;
    checklistdropdown();
  }

  List<String> filterlist(List<String> conditionlist, String removevalue) {
    conditionlist =
        conditionlist.where((item) => item != '$removevalue').toList();
    return conditionlist;
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

    // var conditionJson = _conditionModel
    //     .data!.conditionLevel.to
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
      "1000": [
        {"1001": Mqttsenddata},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
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
        } else if (data[i].conditionIsTrueWhen!.contains('running')) {
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
      // S_No,Name,ConditonOnOff,ScanTime,StartTime,StopTime,NotificationOnOff,ConditionCategory,Object_Condition1,Operator,SetValue_Condition2
    }
    print(Mqttdata);
    return Mqttdata;

  }

  double? _fontSizeheading() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 5;
    // print('${fontSize <= 9 ? 11 : fontSize}');
    // return fontSize <= 9 ? 12 : fontSize;
    return 15;
  }

  double? _fontSizelabel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 3;
    //  print('${fontSize <= 9 ? 10 : fontSize < 14 ? 14 : fontSize}');
    return 11.5;
  }
}
