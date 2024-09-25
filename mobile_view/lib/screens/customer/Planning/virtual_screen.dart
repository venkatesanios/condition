import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
 import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/validateMqtt.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';

class VirtualMeterScreen extends StatefulWidget {
  const VirtualMeterScreen({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.deviceId,
  });
  final userId, controllerId, deviceId;

  @override
  State<VirtualMeterScreen> createState() => _VirtualMeterScreenState();
}

class _VirtualMeterScreenState extends State<VirtualMeterScreen>
    with SingleTickerProviderStateMixin {
  var jsondata;
  String formulastr = '';
  List<String> conditionhdrlist = [
    'Name',
    'Function',
    'Formula',
    'Protection Limit',
    'Object',
    'Action',
    'Ratio',
  ];
  List<String> functiondropdown = [
    '',
    'Open',
    'Close',
    'Running',
  ];
  List<String> functiondropdown1 = [
    '',
    'Irrigation',
    'Flow',
    'Network',
  ];
  List<String> formulaEditlist = [
    'SNo',
    'ID',
    '+',
    '-',
  ];
  List<dynamic> formulajson = [];
  List<dynamic> virtualMeterjson = [];
  String usedprogramdropdownstr = '';
  String hint = 'Enter Flow Values';
  String dropdowntitle = '';
  int Selectindexrow = 0;
  int tabclickindex = 0;

  List<String> conditionList = [];
  List<String> formulastrList = [];
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (jsondata['virtualWaterMeter'] != null &&
        jsondata['virtualWaterMeter'].isNotEmpty) {
      setState(() {
        formulajson = jsondata['virtualWaterMeter'];
        virtualMeterjson = jsondata['waterMeter'];
        formulastrList =
            jsondata['virtualWaterMeter'][Selectindexrow]['formula'].split(' ');
      });
    }
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningVirtualWaterMeter", body);
    if (response.statusCode == 200) {
      setState(() {
        final jsondata1 = jsonDecode(response.body);
        jsondata = jsondata1['data'];
        formulajson = jsondata1['data']['virtualWaterMeter'];
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    if (jsondata == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (jsondata['virtualWaterMeter'].isEmpty ||
        virtualMeterjson.isEmpty ||
        formulajson.isEmpty) {
      return const Center(child: Text('Currently No Virtual Meter Available'));
    } else {
      return Scaffold(
        backgroundColor: const Color(0xffE6EDF5),
        appBar: AppBar(title: Text('Virtual Screen'),automaticallyImplyLeading: false,),
         body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: MediaQuery.of(context).size.width >= 600
                    ? EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0)
                    : EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildDataTableWidget(),
                    MediaQuery.of(context).size.width >= 600
                        ? buildFormulaEditorWidgetweb()
                        : Container()
                    // buildFormulaEditorWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: myTheme.primaryColorDark,
          foregroundColor: Colors.white,
          onPressed: () async {
            updateconditions();
          },
          tooltip: 'Send',
          child: const Icon(Icons.send),
        ),
      );
    }
  }

  Widget buildDataTableWidget() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DataTable2(
                headingRowColor: MaterialStateProperty.all<Color>(
                    primaryColorDark),
                headingRowDecoration: BoxDecoration(
                  borderRadius: MediaQuery.of(context).size.width < 600
                      ? BorderRadius.zero
                      : const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                ),
                fixedCornerColor: myTheme.primaryColor,
                columnSpacing: 10,
                horizontalMargin: 10,
                minWidth: 800,
                decoration: BoxDecoration(
                  // border: const Border(
                  //     bottom: BorderSide(color: Colors.black),
                  //     left: BorderSide(color: Colors.black),
                  //     right: BorderSide(color: Colors.black)),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                fixedLeftColumns: 1,
                // MediaQuery.sizeOf(context).width < 1000 ? 1 : 0,
                fixedColumnsColor:
                    Selectindexrow == 0 ? primaryColorDark : primaryColorDark,
                columns: [
                  for (int i = 0; i < conditionhdrlist.length; i++)
                    DataColumn2(
                      label: Center(
                          child: Text(
                        conditionhdrlist[i].toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        softWrap: true,
                      )),
                    ),
                ],
                rows: List<DataRow>.generate(
                    formulajson.length,
                    (index) => DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            if (index == Selectindexrow) {
                              // return primaryColorDark;
                              return Colors.white;
                            } else {
                              return Colors.white;
                            }
                          }),
                          cells: [
                            for (int i = 0; i < conditionhdrlist.length; i++)
                              if ((conditionhdrlist[i] == 'Function'))
                                DataCell(
                                  onTap: () {
                                    setState(() {
                                      Selectindexrow = index;
                                    });
                                  },
                                  DropdownButton(
                                    // dropdownColor: myTheme.primaryColor,
                                    // focusColor: Colors.transparent,
                                    items:
                                        functiondropdown1.map((String? items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              items!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: _fontSize(),
                                                color: Selectindexrow == index
                                                    ? Colors.black
                                                    : Colors.black,
                                              ),
                                            )),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        formulajson[index]['function'] =
                                            value.toString();
                                        Selectindexrow = index;
                                      });
                                    },
                                    value: formulajson[index]['function'] == ''
                                        ? functiondropdown[0]
                                        : formulajson[index]['function'],
                                  ),
                                )
                              else if ((conditionhdrlist[i] == 'Action'))
                                DataCell(
                                  onTap: () {
                                    setState(() {
                                      Selectindexrow = index;
                                    });
                                  },
                                  DropdownButton(
                                    // dropdownColor: myTheme.primaryColor,
                                    items:
                                        functiondropdown.map((String? items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Center(
                                          child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(items!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: _fontSize(),
                                                    color:
                                                        Selectindexrow == index
                                                            ? Colors.black
                                                            : Colors.black,
                                                  ))),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        formulajson[index]['action'] =
                                            value.toString();
                                        Selectindexrow = index;
                                        // checklistdropdown();
                                        //   print(jsonEncode(_conditionModel.data!.dropdown));
                                      });
                                    },
                                    value: formulajson[index]['action'] == ''
                                        ? functiondropdown[0]
                                        : formulajson[index]['action'],
                                  ),
                                )
                              else if (conditionhdrlist[i] ==
                                  'Protection Limit')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: SizedBox(
                                          width: 50,
                                          child: Center(
                                            child: TextFormField(
                                              style: TextStyle(
                                                color: Selectindexrow == index
                                                    ? Colors.black
                                                    : Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                  hintText: '0',
                                                  border: InputBorder.none),
                                              onChanged: (text) {
                                                setState(() {
                                                  Selectindexrow = index;
                                                  formulajson[index]
                                                          ['protectionLimit'] =
                                                      text;
                                                });
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              initialValue:
                                                  '${formulajson[index]['protectionLimit']}' ??
                                                      '0',
                                            ),
                                          )),
                                    )))
                              else if (conditionhdrlist[i] == 'Name')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '${formulajson[index]['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Selectindexrow == index
                                              ? Colors.white
                                              : Colors.white,
                                        ),
                                      ),
                                    )))
                              else if (conditionhdrlist[i] == 'Object')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        formulajson[index]['object'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Selectindexrow == index
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                      ),
                                    )))
                              else if (conditionhdrlist[i] == 'Ratio')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '${formulajson[index]['radio']}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Selectindexrow == index
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                      ),
                                    )))
                              else if (conditionhdrlist[i] == 'Formula')
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                    if (MediaQuery.of(context).size.width < 600)
                                      _showFormulaBottomSheet();
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          child: Text(
                                            '${formulajson[index]['formula']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Selectindexrow == index
                                                  ? Colors.black
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )))
                              else
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: (conditionhdrlist[i] != 'ID')
                                          ? Text(
                                              '${conditionhdrlist[i]}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Selectindexrow == index
                                                    ? Colors.black
                                                    : Colors.black,
                                              ),
                                            )
                                          : Text('${index + 1}'),
                                    )))
                          ],
                          //                          onSelectChanged: (isSelected) {
                          //    print('Row $index selected: $isSelected');
                          // },
                        )))),
      ),
    );
  }

  double _fontSize() {
    // return MediaQuery.of(context).size.width < 600 ? 2 : 9;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 1;
    fontSize = 13;
    return fontSize;
  }

  Widget buildFormulaEditorWidget({required StateSetter stateSetter}) {
    formulastrList =
        jsondata['virtualWaterMeter'][Selectindexrow]['formula'].split(' ');
    // formulastrList = [];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              color: primaryColorDark.withOpacity(0.8),
              child: const Center(
                  child: Text(
                'Formula Editor',
                style: TextStyle(
                  color: Colors.white, // Set the text color to white
                ),
              )),
            ),
            formulastr.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(formulastrList.join(' ')),
                        )),
                  )
                : Container(),
            if (Selectindexrow != null)
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                        height: double.infinity,
                        width: 280,
                        child: DataTable2(
                            headingRowColor: MaterialStateProperty.all<Color>(
                                primaryColorDark),
                            showBottomBorder: true,
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 80,
                            fixedTopRows: 0,
                            fixedLeftColumns: 0,
                            border: TableBorder.all(
                                width: 1,
                                color: primaryColorDark.withOpacity(0.2)),
                            columns: [
                              for (int i = 0; i < formulaEditlist.length; i++)
                                DataColumn2(
                                  label: Center(
                                      child: Text(
                                    formulaEditlist[i].toString(),
                                    style: TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  )),
                                ),
                            ],
                            rows: List<DataRow>.generate(
                              virtualMeterjson.length,
                              (index) => DataRow(
                                color: MaterialStateColor.resolveWith((states) {
                                  return const Color.fromARGB(0, 176, 35, 35);
                                }),
                                cells: [
                                  for (int i = 0;
                                      i < formulaEditlist.length;
                                      i++)
                                    if (formulaEditlist[i] == '+')
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: checkboxvalassign(
                                                formulajson[Selectindexrow]
                                                    ['formula'],
                                                virtualMeterjson[index]['id'],
                                                true),
                                            onChanged: (bool? value) {
                                              stateSetter(() {
                                                if (value == true) {
                                                  if (formulastrList.contains(
                                                      '-${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.remove(
                                                        '-${virtualMeterjson[index]['id']}');
                                                    formulastrList.add(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  } else if (!formulastrList
                                                      .contains(
                                                          '+${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.add(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  } else {
                                                    formulastrList.remove(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  }
                                                } else {
                                                  formulastrList.remove(
                                                      '+${virtualMeterjson[index]['id']}');
                                                }
                                                String formulaString =
                                                    formulajson[Selectindexrow]
                                                            ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    else if (formulaEditlist[i] == '-')
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: checkboxvalassign(
                                                formulajson[Selectindexrow]
                                                    ['formula'],
                                                virtualMeterjson[index]['id'],
                                                false),
                                            onChanged: (bool? value) {
                                              stateSetter(() {
                                                if (value == true) {
                                                  if (formulastrList.contains(
                                                      '+${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.remove(
                                                        '+${virtualMeterjson[index]['id']}');
                                                    formulastrList.add(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  } else if (!formulastrList
                                                      .contains(
                                                          '-${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.add(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  } else {
                                                    formulastrList.remove(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  }
                                                } else {
                                                  formulastrList.remove(
                                                      '-${virtualMeterjson[index]['id']}');
                                                }
                                                String formulaString =
                                                    formulajson[Selectindexrow]
                                                            ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    else
                                      DataCell(
                                        Center(
                                          // '${virtualMeterjson[index]['sNo']}',
                                          child: InkWell(
                                            child: (formulaEditlist[i] != 'ID')
                                                ? Text(
                                                    '${index+1}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  )
                                                : Text(
                                                    '${virtualMeterjson[index]['id']}'),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ))),
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  stateSetter(() {
                    setState(() {
                      String formulaString = formulastrList.join(' ');
                      formulajson[Selectindexrow]['formula'] = formulaString;
                    });
                  });
                },
                child: const Text('Apply Changes')),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormulaEditorWidgetweb() {
    formulastrList =
        jsondata['virtualWaterMeter'][Selectindexrow]['formula'].split(' ');
    // formulastrList = [];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              color: primaryColorDark.withOpacity(0.8),
              child: const Center(
                  child: Text(
                'Formula Editor',
                style: TextStyle(
                  color: Colors.white, // Set the text color to white
                ),
              )),
            ),
            formulastr.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(formulastrList.join(' ')),
                        )),
                  )
                : Container(),
            if (Selectindexrow != null)
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                        height: double.infinity,
                        width: 280,
                        child: DataTable2(
                            headingRowColor: MaterialStateProperty.all<Color>(
                                primaryColorDark),
                            showBottomBorder: true,
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 80,
                            fixedTopRows: 0,
                            fixedLeftColumns: 0,
                            border: TableBorder.all(
                                width: 1,
                                color: primaryColorDark.withOpacity(0.2)),
                            columns: [
                              for (int i = 0; i < formulaEditlist.length; i++)
                                DataColumn2(
                                  label: Center(
                                      child: Text(
                                    formulaEditlist[i].toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  )),
                                ),
                            ],
                            rows: List<DataRow>.generate(
                              virtualMeterjson.length,
                              (index) => DataRow(
                                color: MaterialStateColor.resolveWith((states) {
                                  return const Color.fromARGB(0, 176, 35, 35);
                                }),
                                cells: [
                                  for (int i = 0;
                                      i < formulaEditlist.length;
                                      i++)
                                    if (formulaEditlist[i] == '+')
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: checkboxvalassign(
                                                formulajson[Selectindexrow]
                                                    ['formula'],
                                                virtualMeterjson[index]['id'],
                                                true),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  if (formulastrList.contains(
                                                      '-${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.remove(
                                                        '-${virtualMeterjson[index]['id']}');
                                                    formulastrList.add(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  } else if (!formulastrList
                                                      .contains(
                                                          '+${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.add(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  } else {
                                                    formulastrList.remove(
                                                        '+${virtualMeterjson[index]['id']}');
                                                  }
                                                } else {
                                                  formulastrList.remove(
                                                      '+${virtualMeterjson[index]['id']}');
                                                }
                                                String formulaString =
                                                    formulajson[Selectindexrow]
                                                            ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    else if (formulaEditlist[i] == '-')
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: checkboxvalassign(
                                                formulajson[Selectindexrow]
                                                    ['formula'],
                                                virtualMeterjson[index]['id'],
                                                false),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  if (formulastrList.contains(
                                                      '+${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.remove(
                                                        '+${virtualMeterjson[index]['id']}');
                                                    formulastrList.add(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  } else if (!formulastrList
                                                      .contains(
                                                          '-${virtualMeterjson[index]['id']}')) {
                                                    formulastrList.add(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  } else {
                                                    formulastrList.remove(
                                                        '-${virtualMeterjson[index]['id']}');
                                                  }
                                                } else {
                                                  formulastrList.remove(
                                                      '-${virtualMeterjson[index]['id']}');
                                                }
                                                String formulaString =
                                                    formulajson[Selectindexrow]
                                                            ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    else
                                      DataCell(
                                        Center(
                                          child: InkWell(
                                            child: (formulaEditlist[i] != 'ID')
                                                ? Text(
                                                    '${virtualMeterjson[index]['sNo']}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  )
                                                : Text(
                                                    '${virtualMeterjson[index]['id']}'),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ))),
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    String formulaString = formulastrList.join(' ');
                    formulajson[Selectindexrow]['formula'] = formulaString;
                  });
                },
                child: const Text('Apply Changes')),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showFormulaBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter stateSetter) {
          return buildFormulaEditorWidget(stateSetter: stateSetter);
        });
      },
    );
  }

  bool checkboxvalassign(String formulastr, String srno, bool minplus) {
    if (formulastr != '') {
      List<String> positiveParts = formulastr.replaceAll(' ', '').split('+');
      List<String> plusValues = [];
      List<String> minusValues = [];
      for (var part in positiveParts) {
        List<String> values = part.split('-');
        if (values.length > 1) {
          for (int i = 1; i < values.length; i++) {
            minusValues.add(values[i]);
          }
        }
        plusValues.add(values[0]);
      }
      plusValues.removeWhere((value) => value.isEmpty);
      if (minplus == true) {
        if (plusValues.contains(srno)) {
          return true;
        } else {
          return false;
        }
      } else {
        if (minusValues.contains(srno)) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  String generateFormulaString(List<dynamic> items) {
    List<String> plusList = [];
    List<String> minusList = [];

    for (var item in items) {
      if (item['plus']) {
        plusList.add(item['id']);
      }
      if (item['minus']) {
        minusList.add(item['id']);
      }
    }

    String plusString = '';
    if (plusList.isNotEmpty) {
      plusString = plusList.sublist(1).map((e) => '+ $e').join(' ');
    }

    String minusString =
        minusList.isNotEmpty ? minusList.map((e) => '- $e').join(' ') : '';

    String mergedString = plusString + ' ' + minusString;

    return mergedString;
  }

  updateconditions() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    initializeData();
    var mqttpaylod = toMqttformat(jsondata['virtualWaterMeter']);
    Map<String, dynamic> payLoadFinal = {
      "1500": [
        {"1501": mqttpaylod},
      ]
    };
    if (jsondata['waterMeter'].length > 0) {
      Map<String, Object> body = {
        "userId": overAllPvd.userId,
        "controllerId": overAllPvd.controllerId,
        "virtualWaterMeter": jsondata,
        "hardware": payLoadFinal,
        "createUser": overAllPvd.userId
      };


         if (MQTTManager().isConnected == true) {
          await validatePayloadSent(
              dialogContext: context,
              context: context,
              mqttPayloadProvider: mqttPayloadProvider,
              acknowledgedFunction: () async{
                final response = await HttpService()
                    .postRequest("createUserPlanningVirtualWaterMeter", body);
                final jsonDataResponse = json.decode(response.body);
                GlobalSnackBar.show(
                    context, jsonDataResponse['message'], response.statusCode);
              },
              payload: payLoadFinal,
              payloadCode: '1500',
              deviceId: overAllPvd.imeiNo
          );
        } else {
          GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
        }
      }

  }

  String toMqttformat(
    List<dynamic>? data,
  ) {
    String Mqttdata = '';
    for (var i = 0; i < data!.length; i++) {
      String protectionLimit = '${data[i]['protectionLimit']}';
      String function = '${data[i]['function']}';
      String action = '${data[i]['action']}';

      if (protectionLimit == 'Open') {
        protectionLimit = '1';
      } else if (protectionLimit == 'Close') {
        protectionLimit = '2';
      } else if (protectionLimit == 'Running') {
        protectionLimit = '3';
      } else {
        protectionLimit = '0';
      }

      if (action == 'Open') {
        action = '1';
      } else if (action == 'Close') {
        action = '2';
      } else if (action == 'Running') {
        action = '3';
      } else {
        action = '0';
      }
      Mqttdata +=
          '${data[i]['sNo']},${data[i]['hid']},${data[i]['name']},${data[i]['formula']},$protectionLimit,${data[i]['object'] == null || data[i]['object'] == '' ? '0' : data[i]['object']},$action,${data[i]['radio'] == null || data[i]['radio'] == '' ? '0' : data[i]['radio']};';
    }
    return Mqttdata;
  }
}
