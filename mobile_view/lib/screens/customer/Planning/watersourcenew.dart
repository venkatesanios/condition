import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
 import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

 import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../models/WaterSource.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/validateMqtt.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';

class watersourceUI1 extends StatefulWidget {
  const watersourceUI1(
      {Key? key,
      required this.userId,
      required this.controllerId,
      required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  State<watersourceUI1> createState() => _watersourceUI1State();
}

class _watersourceUI1State extends State<watersourceUI1>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  Watersource _watersource = Watersource();
  int tabclickindex = 0;
  List<String> dropdownlist = ["Static", "Flow", "Nominal"];
  final _formKey = GlobalKey<FormState>();
  // int _currentIndex = 0;
  int _selectedIndex = 0;
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    print('fetchData${overAllPvd.userId} overAllPvd.controller ${overAllPvd.controllerId}');

    // _watersource = Watersource.fromJson(json);
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    print('body : $body');
    final response =
        await HttpService().postRequest("getUserPlanningWaterSource", body);
    print('\n\n\n\n response: $response');
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _watersource = Watersource.fromJson(jsondata1);
      });
    } else {
      //_showSnackBar(response.body);
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

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);

     if (_watersource.code != 200) {
      return Center(
          child: Text(
              _watersource.message ?? 'Currently No Water source Available'));
    } else if (_watersource.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_watersource.data!.isEmpty) {
      return const Center(child: Text('Currently No Water source Available'));
    } else {

      if (MediaQuery.sizeOf(context).width > 600) {
        return DefaultTabController(
          length: _watersource.data!.length,// Color(0xffE6EDF5)
          child: Scaffold( backgroundColor: Color(0xffE6EDF5),
            body: Padding(
               padding: const EdgeInsets.only(left: 8, bottom: 80, right: 8, top: 8),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width > 1100
                      ? 1100
                      : MediaQuery.sizeOf(context).width,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 10, bottom: 10),
                      child: Column(
                        children: [
                           Padding(
                            padding: const EdgeInsets.only(right: 120),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_left),
                                  onPressed: _selectedIndex > 0
                                      ? _decrementIndex
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_right),
                                  onPressed: _selectedIndex <
                                          _watersource.data!.length - 1
                                      ? _incrementIndex
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Row(children: [
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    itemCount: _watersource.data!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                          });
                                          print('Tapped on ${index}');
                                        },
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   border: Border.all(color: Colors.white54),
                                          //  ),
                                           color: _selectedIndex == index
                                              ?  myTheme.primaryColorDark
                                              : null,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  _watersource
                                                          .data?[index].name ??
                                                      '',
                                                  style: TextStyle(
                                                    color:
                                                        _selectedIndex == index
                                                            ? Colors.white
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                color: Colors.grey,
                                                thickness: 0.1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        child: buildTab(
                                          _watersource
                                              .data?[_selectedIndex].source,
                                          _selectedIndex,
                                          _watersource
                                              .data![_selectedIndex].id!,
                                          _watersource
                                              .data![_selectedIndex].name!,
                                        ),
                                      )),
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor:  myTheme.primaryColorDark,
              foregroundColor: Colors.white,
              onPressed: () async {
                setState(() {
                  updateRadiationSet();
                });
              },
              tooltip: 'Send',
              child: const Icon(Icons.send),
            ),
          ),
        );
      } else {
         return DefaultTabController(
          animationDuration: const Duration(milliseconds: 888),
          length: _watersource.data!.length,
          child: Scaffold(backgroundColor: Color(0xffE6EDF5),
            appBar: AppBar(title: Text('Water Source'),automaticallyImplyLeading: false,),
             body: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 80, right: 8, top: 8),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width > 1100
                      ? 1100
                      : MediaQuery.sizeOf(context).width,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          height: MediaQuery.sizeOf(context).width > 600 ? 50 : 40,
                          child: TabBar(
                            // controller: _tabController,
                            indicatorWeight: 4,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: myTheme.primaryColorDark,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 10,
                                  color:
                                  myTheme.primaryColorDark),
                            ),
                            isScrollable: true,
                            unselectedLabelColor: Colors.black,
                            labelColor: Colors.white,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold),
                            tabs: [
                              for (var i = 0;
                              i <
                                  _watersource
                                      .data!.length;
                              i++)
                                Tab(
                                  text: '${_watersource.data![i].name}',
                                ),
                            ],
                            onTap: (value) {
                              setState(() {
                                tabclickindex = value;
                                changeval(value);
                              });
                            },
                          ),
                        ),
                        SingleChildScrollView(
                            child: Container(
                              height: 400,
                              child: TabBarView(children: [
                              for (var i = 0; i < _watersource.data!.length; i++)
                                buildTab(
                                  _watersource.data![i].source,
                                  i,
                                  _watersource.data![i].id!,
                                  _watersource.data![i].name!,
                                )
                                                        ]),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: myTheme.primaryColorDark,
              foregroundColor: Colors.white,
              onPressed: () async {
                setState(() {
                  updateRadiationSet();
                });
              },

              tooltip: 'Send',
              child: const Icon(Icons.send),
            ),
          ),
        );
      }
    }
  }

  double Changesize(int? count, int val) {
    count ??= 0;
    double size = (count * val).toDouble();
    return size;
  }

  changeval(int Selectindexrow) {}
  Widget buildTab(
      List<Source>? Listofvalue, int i, String sourceid, String sourcename) {
    final numpumpController = TextEditingController();
    final usedlineController = TextEditingController();
    final flowController = TextEditingController();

    numpumpController.text = Listofvalue?[1].value ?? '0';
    usedlineController.text = Listofvalue?[2].value ?? '0';
    flowController.text = Listofvalue?[3].value ?? '0';

    if (MediaQuery.of(context).size.width > 600) {
      String? dropdownval = Listofvalue?[0].value;
      dropdownlist.contains(dropdownval) == true
          ? dropdownval
          : dropdownval = 'Static';
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DataTable2(
            headingRowColor: MaterialStateProperty.all<Color>(myTheme.primaryColorDark,
            ),
            // fixedCornerColor: myTheme.primaryColor,
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            // border: TableBorder.all(
            //     width: 0.5, borderRadius: BorderRadius.circular(5.0)),
            fixedColumnsColor: myTheme.primaryColorLight,
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
                      color: Colors.white),
                  softWrap: true,
                )),
              ),
              DataColumn2(
                label: Center(
                    child: Text(
                  'Water Source Name',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  softWrap: true,
                )),
              ),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Center(
                    child: Text(
                  "${Listofvalue?[0].sNo}",
                ))),
                DataCell(Text(
                  "${Listofvalue?[0].title}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(DropdownButton(
                    items: dropdownlist.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(items)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        Listofvalue?[0].value = value!;
                        dropdownval = Listofvalue?[0].value;
                      });
                    },
                    value: Listofvalue?[0].value == ''
                        ? dropdownlist[0]
                        : Listofvalue?[0].value)),
              ]),
              DataRow(cells: [
                DataCell(Center(
                    child: Text(
                  "${Listofvalue?[1].sNo}",
                ))),
                DataCell(Text(
                  "${Listofvalue?[1].title}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(
                  TextFormField(
                    controller: numpumpController,
                    textAlign: TextAlign.center,
                    onChanged: (text) {
                      setState(() {
                        Listofvalue?[1].value = text;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: '0', border: InputBorder.none),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // initialValue: Listofvalue?[1].value == ''
                    //     ? ''
                    //     : Listofvalue?[1].value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Warranty is required';
                      } else {
                        setState(() {
                          Listofvalue?[1].value = value;
                        });
                      }
                      return null;
                    },
                  ),
                ),
              ]),
              DataRow(cells: [
                DataCell(Center(
                    child: Text(
                  "${Listofvalue?[2].sNo}",
                ))),
                DataCell(Text(
                  "${Listofvalue?[2].title}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(
                  TextFormField(
                    controller: usedlineController,
                    textAlign: TextAlign.center,
                    onChanged: (text) {
                      setState(() {
                        Listofvalue?[2].value = text;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: '0', border: InputBorder.none),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // initialValue: Listofvalue?[2].value == ''
                    //     ? ''
                    //     : Listofvalue?[2].value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Warranty is required';
                      } else {
                        setState(() {
                          Listofvalue?[2].value = value;
                        });
                      }
                      return null;
                    },
                  ),
                ),
              ]),
              DataRow(cells: [
                DataCell(Center(
                    child: Text(
                  "${Listofvalue?[3].sNo}",
                ))),
                DataCell(Text(
                  "${Listofvalue?[3].title}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )),
                DataCell(
                  TextFormField(
                    controller: flowController,
                    textAlign: TextAlign.center,
                    onChanged: (text) {
                      setState(() {
                        Listofvalue?[3].value = text;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: '0', border: InputBorder.none),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // initialValue: Listofvalue?[3].value == ''
                    //     ? ''
                    //     : Listofvalue?[3].value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Warranty is required';
                      } else {
                        setState(() {
                          Listofvalue?[3].value = value;
                        });
                      }
                      return null;
                    },
                  ),
                ),
              ]),
            ]),
      );
    } else {
      return Column(
        children: [
          Card(
            elevation: 0.1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
                title: Text(
                  sourcename,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
                trailing: Text(sourceid,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Listofvalue?.length ?? 0,
              itemBuilder: (context, index) {
                if (Listofvalue?[index].widgetTypeId == 1) {
                  return Column(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 0.1,
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',
                              style: TextStyle(
                                fontSize:
                                    16,
                                fontWeight: FontWeight.bold,
                              )),
                          trailing: SizedBox(
                              width: 100,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                onChanged: (text) {
                                  setState(() {
                                    Listofvalue?[index].value = text;
                                  });
                                },
                                decoration: const InputDecoration(hintText: '0'),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                initialValue: Listofvalue?[index].value == ''
                                    ? ''
                                    : Listofvalue?[index].value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Warranty is required';
                                  } else {
                                    setState(() {
                                      Listofvalue?[index].value = value;
                                    });
                                  }
                                  return null;
                                },
                              )),
                        ),
                      ),
                    ],
                  );
                } else if (Listofvalue?[index].widgetTypeId == 2) {
                  return Column(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 0.1,
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',
                              style: TextStyle(
                                fontSize:
                                    16,
                                fontWeight: FontWeight.bold,
                              )),
                          trailing: Switch(
                            value: Listofvalue?[index].value == '1',
                            onChanged: ((value) {
                              setState(() {
                                Listofvalue?[index].value = !value ? '0' : '1';
                              });
                              // Listofvalue?[index].value = value;
                            }),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (Listofvalue?[index].widgetTypeId == 3) {
                   String? dropDownVal = Listofvalue?[index].value;
                  dropdownlist.contains(dropDownVal) == true
                      ? dropDownVal
                      : dropDownVal = 'Static';
                  return Column(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 0.1,
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',
                              style: TextStyle(
                                fontSize:16,
                                fontWeight: FontWeight.bold,
                              )),
                          trailing: Container(
                            color: Colors.white70,
                            width: 100,
                            child: DropdownButton(
                                items: dropdownlist.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(items)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    Listofvalue?[index].value = value!;
                                    dropDownVal = Listofvalue?[index].value;
                                  });
                                },
                                value: Listofvalue?[index].value == ''
                                    ? dropdownlist[0]
                                    : Listofvalue?[index].value),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (Listofvalue?[index].widgetTypeId == 5) {
                  // String? dropdownval = Listofvalue?[index].value;
                  return Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',
                              style: TextStyle(
                                fontSize:
                                    16,
                                fontWeight: FontWeight.bold,
                              )),
                          trailing: SizedBox(
                            width: 100,
                            child: Container(
                                child: Center(
                              child: InkWell(
                                child: Text(
                                  '${Listofvalue?[index].value}' != ''
                                      ? '${Listofvalue?[index].value}'
                                      : '00:00',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                onTap: () async {
                                  String? time = await _selectTime(context);
                                  setState(() {
                                    if (time != null) {
                                      Listofvalue?[index].value = time;
                                    }
                                  });
                                },
                              ),
                            )),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [Container()],
                  );
                }
              },
            ),
          ),
        ],
      );
    }
  }

  updateRadiationSet() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    List<Map<String, dynamic>> waterSource =
        _watersource.data!.map((condition) => condition.toJson()).toList();
    String mqttSendData = toMqttFormat(_watersource.data);

    Map<String, dynamic> payLoadFinal = {
      "1600": [
        {"1601": mqttSendData},
      ]
    };
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "waterSource": waterSource,
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
                .postRequest("createUserPlanningWaterSource", body);
            final jsonDataResponse = json.decode(response.body);
            GlobalSnackBar.show(
                context, jsonDataResponse['message'], response.statusCode);
          },
          payload: payLoadFinal,
          payloadCode: '1600',
          deviceId: overAllPvd.imeiNo
      );
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
  }

  String toMqttFormat(
    List<Datum>? data,
  ) {
    String MqttData = '';
    data?.forEach((item) {
      int sno = item.sNo!;
      // String id = '${item.hid!}';
      // List<String> time = [];
      String name = '${item.name}';
      // String line = '${data[i].source}';
      String mode = '0';
      if (item.source![0].value! == 'Static') {
        mode = '0';
      } else if (item.source![0].value! == 'Flow') {
        mode = '1';
      } else if (item.source![0].value! == 'Nominal') {
        mode = '2';
      } else {
        mode = '0';
      }
      String pump =
          item.source![1].value!.isEmpty ? '0' : item.source![1].value!;
      String line =
          item.source![2].value!.isEmpty ? '0' : item.source![2].value!;
      String flow =
          item.source![3].value!.isEmpty ? '0' : item.source![3].value!;
      MqttData += '$sno,$name,$pump,$line,$flow,$mode;';
    });


    return MqttData;
  }

  void _incrementIndex() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _watersource.data!.length;
      // _selectedIndex = _currentIndex;
    });
  }

  void _decrementIndex() {
    setState(() {
      _selectedIndex = (_selectedIndex - 1) % _watersource.data!.length;
      // _selectedIndex = _currentIndex;
    });
  }
}
