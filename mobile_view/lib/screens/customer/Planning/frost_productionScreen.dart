import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import '../../../Models/Customer/frost_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/overall_use.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';
 enum SegmentController { Frost, Rain, }
class FrostMobUI extends StatefulWidget {
  const FrostMobUI(
      {Key? key, required this.userId, required this.controllerId, this.deviceID});
  final userId, controllerId,deviceID;
  @override
  State<FrostMobUI> createState() => _ConditionUIState();
}

class _ConditionUIState extends State<FrostMobUI>
    with SingleTickerProviderStateMixin {
  FrostProtectionModel _frostProtectionModel = FrostProtectionModel();
  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];
  int _currentSelection = 0;
  SegmentController selectedSegment = SegmentController.Frost;

  final Map<int, Widget> _children = {
    0: const Text(' Frost Protection '),
    1: const Text(' Rain Delay '),
  };

  @override
  void initState() {
    super.initState();
    fetchData();
    // MqttWebClient().init();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningFrostProtectionAndRainDelay", body);
    print(body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _frostProtectionModel = frostProtectionModelFromJson(response.body);
      });
      //MqttWebClient().onSubscribed('tweet/');
    } else {
      //_showSnackBar(response.body);
    }
  }


  //
  // SegmentController selectedSegment = SegmentController.Frost; // Define a default selected segment
  //
  // SegmentedButton<SegmentController>(
  // style: ButtonStyle(
  // backgroundColor: MaterialStateProperty.all(myTheme.primaryColor.withOpacity(0.1)),
  // overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
  // if (states.contains(MaterialState.selected)) {
  // return myTheme.primaryColor.withOpacity(0.2); // Adjust the opacity or color as needed
  // }
  // return null;
  // }),
  // iconColor: MaterialStateProperty.all(myTheme.primaryColor),
  // ),
  // segments: const <ButtonSegment<SegmentController>>[
  // ButtonSegment<SegmentController>(
  // value: SegmentController.Frost,
  // label: Text('Frost Protection'),
  // icon: Icon(Icons.festival_rounded),
  // ),
  // ButtonSegment<SegmentController>(
  // value: SegmentController.Rain,
  // label: Text('Rain Delay'),
  // icon: Icon(Icons.water_drop),
  // ),
  // ],
  // selected: selectedSegment,
  // onSelectionChanged: (Set<SegmentController> newSelection) {
  // setState(() {
  // selectedSegment = newSelection.first;
  // if (selectedSegment == SegmentController.Frost) {
  // _currentSelection = 0;
  // buildFrostselection();
  // } else {
  // _currentSelection = 1;
  // rain();
  // }
  // });
  // },
  // )





  @override
  Widget build(BuildContext context) {
    if (_frostProtectionModel.frostProtection == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_frostProtectionModel.frostProtection!.isEmpty) {
      return const Center(
          child: Text(
              'Currently No Frost Production & Rain Delay Sets Available'));
    } else {
      return Scaffold(backgroundColor: Color(0xffE6EDF5),
        appBar: AppBar(title: Text('Frost Production'),automaticallyImplyLeading: false,),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SegmentedButton<SegmentController>(
                       style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context).primaryColor; // Use primary color for selected segments
                          }
                          return Color(0xffE6EDF5);
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                           return Theme.of(context).primaryColor;
                        }),
                          iconColor:MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                           return Theme.of(context).primaryColor;
                        }),
                      ),
                       segments: const <ButtonSegment<SegmentController>>[
                        ButtonSegment<SegmentController>(
                            value: SegmentController.Frost,
                            label: Text('Frost Protection'),
                            icon: Icon(Icons.festival_rounded)),
                        ButtonSegment<SegmentController>(
                            value: SegmentController.Rain,
                            label: Text('Rain Delay'),
                            icon: Icon(Icons.water_drop)),
                      ],

                      selected: <SegmentController>{selectedSegment},
                      onSelectionChanged: (Set<SegmentController> newSelection) {
                        setState(() {
                           selectedSegment = newSelection.first;
                           if (selectedSegment == SegmentController.Frost) {
                            _currentSelection = 0;
                            buildFrostselection();
                          }  else {
                            _currentSelection = 1;
                            rain();
                          }
                        });
                      },
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 10),
                _currentSelection == 1 ? rain() : buildFrostselection(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: myTheme.primaryColorDark,
          foregroundColor: Colors.white,
          onPressed: () async {
            setState(() {
              updateConditions();
            });
          },
          tooltip: 'Send',
          child: const Icon(Icons.send),
        ),
      );
    }
  }


  Widget buildFrostselection() {
    List<FrostProtection>? Listofvalue = _frostProtectionModel.frostProtection;

    if (MediaQuery
        .of(context)
        .size
        .width > 600) {
      return Center(
        child: Container(
            width: 1000,
            height: 400,
            child: DataTable2(
              headingRowColor: MaterialStateProperty.all<Color>(
                  primaryColorDark),
              // fixedCornerColor: myTheme.primaryColor,
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 400,
              headingRowDecoration: const BoxDecoration(  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),),),
              decoration: BoxDecoration(
                border: const Border(bottom: BorderSide(color: Colors.black),left: BorderSide(color: Colors.black),right: BorderSide(color: Colors.black)),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // border: TableBorder.all(width: 0.5),
              // fixedColumnsColor: Colors.amber,
              headingRowHeight: 50,
              columns: [
                DataColumn2(
                  fixedWidth: 70,
                  label: Center(
                      child: Text(
                        'Sno',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
                DataColumn2(
                  label: Center(
                      child: Text(
                        'Names',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold, color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
                DataColumn2(
                  fixedWidth: 150,
                  label: Center(
                      child: Text(
                        'VALUE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold, color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
              ],
              rows: List<DataRow>.generate(Listofvalue!.length, (index) => DataRow(
                // color: index % 2 == 0 ? MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05))
                //     : MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                  cells: [
                    DataCell(Center(child: Text('${index + 1}'))),
                    DataCell(Center(child: Text(Listofvalue[index].title!))),
                    DataCell(Center(child: Listofvalue[index].widgetTypeId == 2 ?  Container(
                      child: Switch(
                        value: Listofvalue[index].value == '1',
                        onChanged: ((value) {
                          setState(() {
                            Listofvalue[index].value = !value ? '0' : '1';
                            _frostProtectionModel.frostProtection![index].value = !value ? '0' : '1';
                          });
                          // Listofvalue?[index].value = value;
                        }),
                      ),
                    )  :  Container(
                        child: ListTile(
                          trailing: SizedBox(
                              width: 100,
                              child: Center(
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  onChanged: (text) {
                                    setState(() {
                                      _currentSelection == 0
                                          ? _frostProtectionModel
                                          .frostProtection![index].value = text
                                          : _frostProtectionModel.rainDelay![index]
                                          .value =
                                          text;
                                    });
                                  },
                                  decoration: const InputDecoration(hintText: '0',border: InputBorder.none),
                                  initialValue:
                                  '${Listofvalue[index].value == ''
                                      ? ''
                                      : Listofvalue[index].value}' ??
                                      '',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Value is required';
                                    } else {
                                      setState(() {
                                        _currentSelection == 0
                                            ? _frostProtectionModel
                                            .frostProtection![index].value = value
                                            : _frostProtectionModel
                                            .rainDelay![index].value = value;
                                      });
                                    }
                                    return null;
                                  },
                                ),
                              )),
                        )))),
                  ])),

            )),
      );
    }
     else{
      return Expanded(
        child: ListView.builder(
          itemCount: Listofvalue?.length ?? 0,
          itemBuilder: (context, index) {
            int iconcode = int.parse(Listofvalue?[index].iconCodePoint ?? "");
            String C = '\u00B0C';
            String iconfontfamily =
                Listofvalue?[index].iconFontFamily ?? "MaterialIcons";
            if (Listofvalue?[index].widgetTypeId == 1) {
              return Container(
                  child: Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        '${Listofvalue?[index].title}', style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,),
                        softWrap: true,),
                      trailing: SizedBox(
                          width: 50,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            onChanged: (text) {
                              setState(() {
                                _currentSelection == 0
                                    ? _frostProtectionModel
                                    .frostProtection![index].value = text
                                    : _frostProtectionModel.rainDelay![index]
                                    .value =
                                    text;
                              });
                            },
                            decoration: const InputDecoration(hintText: '0',border: InputBorder.none),
                            initialValue:
                            '${Listofvalue?[index].value == ''
                                ? ''
                                : Listofvalue?[index].value}' ??
                                '',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Value is required';
                              } else {
                                setState(() {
                                  _currentSelection == 0
                                      ? _frostProtectionModel
                                      .frostProtection![index].value = value
                                      : _frostProtectionModel
                                      .rainDelay![index].value = value;
                                });
                              }
                              return null;
                            },
                          )),
                    ),
                  ));
            } else {
              return Container(
                child: Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text('${Listofvalue?[index].title}', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,),
                      softWrap: true,),
                    // leading:
                    //     Icon(IconData(iconcode, fontFamily: iconfontfamily)),
                    trailing: Switch(
                      value: Listofvalue?[index].value == '1',
                      onChanged: ((value) {
                        setState(() {
                          Listofvalue?[index].value = !value ? '0' : '1';
                          _currentSelection == 0
                              ? _frostProtectionModel.frostProtection![index]
                              .value = !value ? '0' : '1'
                              : _frostProtectionModel.rainDelay![index].value =
                          !value ? '0' : '1';
                        });
                        // Listofvalue?[index].value = value;
                      }),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      );
    }
  }

  Widget rain() {
    print('rain');
    // List<FrostProtection>? Listofvalue = _currentSelection == 0
    //     ? _frostProtectionModel.frostProtection
    //     : _frostProtectionModel.rainDelay;
    List<FrostProtection>? Listofvalue =  _frostProtectionModel.rainDelay;

    if (MediaQuery
        .of(context)
        .size
        .width > 600) {
      return Center(
        child: Container(
            width: 1000,
            height: 400,
            child: DataTable2(
              headingRowColor: MaterialStateProperty.all<Color>(
                  primaryColorDark),
              // fixedCornerColor: myTheme.primaryColor,
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              headingRowDecoration: const BoxDecoration(  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),),),
              decoration: BoxDecoration(
                border: const Border(bottom: BorderSide(color: Colors.black),left: BorderSide(color: Colors.black),right: BorderSide(color: Colors.black)),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // fixedColumnsColor: Colors.amber,
              headingRowHeight: 50,
              columns: [
                DataColumn2(
                  fixedWidth: 70,
                  label: Center(
                      child: Text(
                        'Sno',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
                DataColumn2(
                  label: Center(
                      child: Text(
                        'Names',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize:
                                16,
                            fontWeight: FontWeight.bold, color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
                DataColumn2(
                  fixedWidth: 150,
                  label: Center(
                      child: Text(
                        'VALUE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize:
                                16,
                            fontWeight: FontWeight.bold, color: Colors.white
                        ),
                        softWrap: true,
                      )),
                ),
              ],
              rows: List<DataRow>.generate(Listofvalue!.length, (index) =>
                  DataRow(
                    // color: index % 2 == 0 ? MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05))
                    // : MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                      cells: [
                        DataCell(Center(child: Text('${index + 1}'))),
                        DataCell(Center(child: Text(Listofvalue[index].title!))),
                        DataCell(Center(
                            child: Listofvalue[index].widgetTypeId == 2 ? Switch(
                              value: Listofvalue[index].value == '1',
                              onChanged: ((value) {
                                setState(() {
                                  Listofvalue[index].value = !value ? '0' : '1';
                                  // _currentSelection == 0
                                  //     ? _frostProtectionModel.frostProtection![index]
                                  //     .value = !value ? '0' : '1'
                                  //     :
                                  _frostProtectionModel.rainDelay![index].value = !value ? '0' : '1';
                                });
                                // Listofvalue?[index].value = value;
                              }),
                            ) : Center(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                onChanged: (text) {
                                  setState(() {
                                    _frostProtectionModel.rainDelay![index]
                                        .value =
                                        text;
                                  });
                                },
                                initialValue:
                                '${Listofvalue[index].value == ''
                                    ? ''
                                    : Listofvalue[index].value}' ??
                                    '',
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: InputBorder.none,
                                  suffixText: '${Listofvalue[index].title}' ==
                                      'CRITICAL TEMPERATURE'
                                      ? '°C'
                                      : '',
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Value is required';
                                  } else {
                                    setState(() {

                                      _frostProtectionModel
                                          .rainDelay![index].value = value;
                                    });
                                  }
                                  return null;
                                },
                              ),
                            ))),
                      ])),

            )),
      );
    }
    else {
      return Expanded(
        child: ListView.builder(
          itemCount: Listofvalue?.length ?? 0,
          itemBuilder: (context, index) {
            int.parse(Listofvalue?[index].iconCodePoint ?? "");
            String c = '\u00B0C';
            if (Listofvalue?[index].widgetTypeId == 1) {
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text('${Listofvalue?[index].title}', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,),
                    softWrap: true,),
                  trailing: SizedBox(
                      width: 50,
                      child: TextFormField(
                        onChanged: (text) {
                          setState(() {
                            _currentSelection == 0
                                ? _frostProtectionModel
                                .frostProtection![index].value = text
                                : _frostProtectionModel.rainDelay![index]
                                .value =
                                text;
                          });
                        },
                        initialValue:
                        '${Listofvalue?[index].value == ''
                            ? ''
                            : Listofvalue?[index].value}' ??
                            '',
                        decoration: InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          suffixText: '${Listofvalue?[index].title}' ==
                              'CRITICAL TEMPERATURE'
                              ? '°C'
                              : '',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Value is required';
                          } else {
                            setState(() {
                              _currentSelection == 0
                                  ? _frostProtectionModel
                                  .frostProtection![index].value = value
                                  : _frostProtectionModel
                                  .rainDelay![index].value = value;
                            });
                          }
                          return null;
                        },
                      )),
                ),
              );
            } else {
              return Container(
                child: Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      '${Listofvalue?[index].title}', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,),
                      softWrap: true,),
                    trailing: Switch(
                      value: Listofvalue?[index].value == '1',
                      onChanged: ((value) {
                        setState(() {
                          Listofvalue?[index].value = !value ? '0' : '1';
                          _currentSelection == 0
                              ? _frostProtectionModel.frostProtection![index]
                              .value = !value ? '0' : '1'
                              : _frostProtectionModel.rainDelay![index].value =
                          !value ? '0' : '1';
                        });
                        // Listofvalue?[index].value = value;
                      }),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      );
    }
  }

  String toMqttformat(
      List<FrostProtection>? data,
      ) {
    String Mqttdata = '';
    Mqttdata += '${data?[0].sNo},${data?[0].value},${data?[1].value},${data?[2].value},${data?[3].value == '' ? "0" : data?[3].value},${data?[4].value},${data?[5].value},${data?[6].value};';
    return Mqttdata;
  }

  updateConditions() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    String mqttSendData = toMqttformat(_currentSelection == 0
        ? _frostProtectionModel.frostProtection
        : _frostProtectionModel.rainDelay);
    String mqttDataCode = _currentSelection == 0 ? '1800' : '1700';
    String mqttDataSubCode = _currentSelection == 0 ? '1801' : '1701';

    String payLoadFinal = jsonEncode({
      mqttDataCode: [
        {mqttDataSubCode: mqttSendData},
      ]
    });

    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');

    List<Map<String, dynamic>> frostProtection = _frostProtectionModel
        .frostProtection!
        .map((frost) => frost.toJson())
        .toList();
    List<Map<String, dynamic>> rainDelay = _frostProtectionModel.rainDelay!
        .map((frost) => frost.toJson())
        .toList();
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "frostProtection": frostProtection,
      "rainDelay": rainDelay,
      "hardware": payLoadFinal,
      "createUser": overAllPvd.userId
    };
    final response = await HttpService()
        .postRequest("createUserPlanningFrostProtectionAndRainDelay", body);
    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);
  }
}