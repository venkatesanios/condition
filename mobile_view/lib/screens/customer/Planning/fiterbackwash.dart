import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../FertilizerSet.dart';
import '../../../Models/Customer/back_wash_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/HoursMinutesSeconds.dart';
import 'package:provider/provider.dart';

import '../../../widget/validateMqtt.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';
class FilterBackwashUI1 extends StatefulWidget {
  const FilterBackwashUI1(
      {Key? key,
        required this.userId,
        required this.controllerId,
        this.deviceID});
  final userId, controllerId, deviceID;

  @override
  State<FilterBackwashUI1> createState() => _FilterBackwashUI1State();
}

class _FilterBackwashUI1State extends State<FilterBackwashUI1>
    with SingleTickerProviderStateMixin {
  late MqttPayloadProvider mqttPayloadProvider;

  // late TabController _tabController;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 0);
  Filterbackwash _filterbackwash = Filterbackwash();
  int tabclickindex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    super.initState();
    //MqttWebClient().init();
    fetchData();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    print(body);
    print(overAllPvd.imeiNo);

    final response = await HttpService()
        .postRequest("getUserPlanningFilterBackwashing", body);
    print(body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _filterbackwash = Filterbackwash.fromJson(jsondata1);
        MQTTManager().connect();
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    if (_filterbackwash.code != 200) {
      return Center(
          child:
          Text(_filterbackwash.message ?? 'Currently No Filter Available'));
    } else if (_filterbackwash.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_filterbackwash.data!.isEmpty) {
      return const Center(child: Text('Currently No Filter Available'));
    } else {
      return LayoutBuilder(builder: (context, constaint) {
        return Container(
          width: constaint.maxWidth,
          height: constaint.maxHeight,
          child: DefaultTabController(
            animationDuration: const Duration(milliseconds: 888),
            length: _filterbackwash.data!.length ?? 0,
            child: Scaffold(
              backgroundColor: Color(0xffE6EDF5),
              appBar: AppBar(title: Text('Filter BackWash'),automaticallyImplyLeading: false,),
              body: SizedBox(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      height: 50,
                      child: TabBar(
                        indicatorWeight: 4,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: myTheme.primaryColorDark,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 10, color: myTheme.primaryColorDark),
                        ),
                        isScrollable: true,
                        unselectedLabelColor: Colors.black,
                        labelColor: Colors.white,
                        labelStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          for (var i = 0; i < _filterbackwash.data!.length; i++)
                            Tab(
                              text: '${_filterbackwash.data![i].name}',
                            ),
                          // ),
                        ],
                        onTap: (value) {
                          setState(() {
                            tabclickindex = value;
                            changeval(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TabBarView(children: [
                        for (var i = 0; i < _filterbackwash.data!.length; i++)
                          MediaQuery.sizeOf(context).width > 600
                              ? buildTab(
                              _filterbackwash.data![i].filter,
                              i,
                              _filterbackwash.data![i].name,
                              _filterbackwash.data![i].sNo ?? 0,
                              constaint.maxWidth,
                              constaint.maxHeight)
                              : buildTabMob(
                            _filterbackwash.data![i].filter,
                            i,
                            _filterbackwash.data![i].name,
                            _filterbackwash.data![i].sNo ?? 0,
                          )
                      ]),
                    ),
                  ],
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
          ),
        );
      });
    }
  }

  double Changesize(int? count, int val) {
    count ??= 0;
    double size = (count * val).toDouble();
    return size;
  }

  changeval(int Selectindexrow) {}

  Widget buildTab(List<Filter>? Listofvalue, int i, String? name, int srno,
      double width, double height) {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    final RegExp _regex = RegExp(r'^([0-9]|[1-9][0-9])(\.[0-9])?$');
    return Row(
      children: [
        Container(
          width: width,
          height: height - 100,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customizeGridView(
                  maxWith: width / 3 < 350 ? 350 : width / 3,
                  maxheight: 60,
                  screenWidth: width,
                  listOfWidget: [
                    for (var j = 0; j < Listofvalue![0].value!.length; j++)
                      SizedBox(
                        width: 400,
                        height: 60,
                        child: Card(
                          elevation: 7,
                          child: ListTile(
                            title: Text(
                              '${Listofvalue?[0].value[j]['name']} ON TIME',
                              style: TextStyle(
                                fontSize:
                                14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            trailing: SizedBox(
                              width: 90,
                              child: Container(
                                child: Center(
                                  child: InkWell(
                                    child: Text(
                                      '${Listofvalue?[0].value![j]['value']}' !=
                                          ''
                                          ? '${Listofvalue?[0].value![j]['value']}'
                                          : '00:00:00',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: HoursMinutesSeconds(
                                              initialTime:
                                              '${Listofvalue?[0].value![j]['value']}' !=
                                                  ''
                                                  ? '${Listofvalue?[0].value![j]['value']}'
                                                  : '00:00:00',
                                              onPressed: () {
                                                setState(() {
                                                  Listofvalue?[0].value![j]
                                                  ['value'] =
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    for (var i = 1; i < Listofvalue!.length; i++)
                      SizedBox(
                        width: 400,
                        height: 60,
                        child: filterCard(Listofvalue, i, Listofvalue[i].sNo!),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          color: myTheme.primaryColor,
        )
      ],
    );
  }

  Widget filterCard(
      List<Filter>? Listofvalue,
      int index,
      int srno,
      ) {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    final RegExp _regex = RegExp(r'^([0-9]|[1-9][0-9])(\.[0-9])?$');
    if (Listofvalue?[index].widgetTypeId == 1) {
      if (Listofvalue?[index].title == "DIFFERENTIAL PRESSURE VALUE") {
        return SizedBox(
          height: 60,
          width: 400,
          child: Card(
            elevation: 7,
            //color: myTheme.primaryColorLight.withOpacity(0.4),
            child: ListTile(
              title: Text(
                '${Listofvalue?[index].title}',
                style: TextStyle(
                  fontSize:  14,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
              trailing: SizedBox(
                  width: 100,
                  height: 60,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          onChanged: (text) {
                            setState(() {
                              Listofvalue?[index].value = text;
                            });
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              hintText: '0.0', border: InputBorder.none),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'^\d{1,2}(\.\d{0,1})?$|^99(\.0)?$|^99\.9$')),
                          ],
                          initialValue: Listofvalue?[index].value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Warranty is required';
                            } else {
                              setState(() {
                                if (!_regex.hasMatch(value)) {
                                } else {}
                                Listofvalue?[index].value = value;
                              });
                            }
                            return null;
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                            width: 30,
                            // height: 60,
                            child: Text(
                              'bar',
                              style: TextStyle(
                                fontSize:
                                14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            )),
                      )
                    ],
                  )),
            ),
          ),
        );
      }
      return SizedBox(
        height: 60,
        width: 400,
        child: Card(
          elevation: 7,
          //color: myTheme.primaryColorLight.withOpacity(0.4),
          child: ListTile(
            title: Text(
              '${Listofvalue?[index].title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  onChanged: (text) {
                    setState(() {
                      Listofvalue?[index].value = text;
                    });
                  },
                  decoration: const InputDecoration(
                      hintText: '0', border: InputBorder.none),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: Listofvalue?[index].value ?? '',
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
      );
    } else if (Listofvalue?[index].widgetTypeId == 2) {
      return SizedBox(
        height: 60,
        width: 400,
        child: Card(
          elevation: 7,
          //color: myTheme.primaryColorLight.withOpacity(0.4),
          child: ListTile(
            title: Text(
              '${Listofvalue?[index].title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.not_started_outlined),
              onPressed: () {
                manualonoff(srno);
              },
            ),
          ),
        ),
      );
    } else if (Listofvalue?[index].widgetTypeId == 3) {
      final dropdownlist = [
        'Stop Irrigation',
        'Continue Irrigation',
        'No Fertilization',
        'Open Valves',
      ];
      String dropdownval = Listofvalue?[index].value;
      dropdownlist.contains(dropdownval) == true
          ? dropdownval
          : dropdownval = 'Stop Irrigation';
      return SizedBox(
        height: 60,
        width: 400,
        child: Card(
          elevation: 7,
          //color: myTheme.primaryColorLight.withOpacity(0.4),
          child: ListTile(
            title: Text(
              '${Listofvalue?[index].title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            trailing: SizedBox(
              // color: Color.fromARGB(255, 28, 123, 137),
              width: 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: myTheme.primaryColorDark,
                ),
                child: DropdownButton(
                    iconEnabledColor: Colors.white,
                    dropdownColor: myTheme.primaryColorDark,
                    items: dropdownlist.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Container(
                            child: Text(
                              items,
                              style: const TextStyle(color: Colors.white),
                            )),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        Listofvalue?[index].value = value!;
                        dropdownval = Listofvalue?[index].value;
                      });
                    },
                    value: Listofvalue?[index].value == ''
                        ? dropdownlist[0]
                        : Listofvalue?[index].value),
              ),
            ),
          ),
        ),
      );
    } else if (Listofvalue?[index].widgetTypeId == 5 &&
        Listofvalue?[index].title != "FILTER ON TIME") {
      return SizedBox(
        height: 60,
        width: 400,
        child: Card(
          elevation: 6,
          //color: myTheme.primaryColorLight.withOpacity(0.4),
          child: ListTile(
            title: Text(
              '${Listofvalue?[index].title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            trailing: SizedBox(
              width: 100,
              child: Container(
                  child: Center(
                    child: InkWell(
                      child: Text(
                        '${Listofvalue?[index].value}' != ''
                            ? '${Listofvalue?[index].value}'
                            : '00:00:00',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: HoursMinutesSeconds(
                                  initialTime: '${Listofvalue?[index].value}' != ''
                                      ? '${Listofvalue?[index].value}'
                                      : '00:00:00',
                                  onPressed: () {
                                    setState(() {
                                      Listofvalue?[index].value =
                                      '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            });
                      },
                    ),
                  )),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildTabMob(
      List<Filter>? listOfValue,
      int i,
      String? name,
      int srNo,
      ) {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    final RegExp regex = RegExp(r'^([0-9]|[1-9][0-9])(\.[0-9])?$');
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Color(0xffE6EDF5),
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
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 60),
              child: ListView.builder(
                itemCount: listOfValue?.length ?? 0,
                itemBuilder: (context, index) {
                  if (listOfValue?[index].widgetTypeId == 1) {
                    if (listOfValue?[index].title ==
                        "DIFFERENTIAL PRESSURE VALUE") {
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
                                '${listOfValue?[index].title}',
                                style: TextStyle(
                                  fontSize:   14,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          onChanged: (text) {
                                            setState(() {
                                              listOfValue?[index].value =
                                                  text;
                                            });
                                          },
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true),
                                          decoration: const InputDecoration(
                                              hintText: '0.0',
                                              border: InputBorder.none),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'^\d{1,2}(\.\d{0,1})?$|^99(\.0)?$|^99\.9$')),
                                            // FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}$')),
                                          ],
                                          initialValue:
                                          listOfValue?[index].value ?? '',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Warranty is required';
                                            } else {
                                              setState(() {
                                                if (!regex.hasMatch(value)) {
                                                } else {}
                                                listOfValue?[index].value =
                                                    value;
                                              });
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                            width: 30,
                                            child: Text(
                                              'bar',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      );
                    }
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
                              '${listOfValue?[index].title}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            trailing: SizedBox(
                                width: 100,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  onChanged: (text) {
                                    setState(() {
                                      listOfValue?[index].value = text;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      hintText: '0',
                                      border: InputBorder.none),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  initialValue:
                                  listOfValue?[index].value ?? '',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Warranty is required';
                                    } else {
                                      setState(() {
                                        listOfValue?[index].value = value;
                                      });
                                    }
                                    return null;
                                  },
                                )),
                          ),
                        ),
                      ],
                    );
                  } else if (listOfValue?[index].widgetTypeId == 2) {
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
                              '${listOfValue?[index].title}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            trailing: SizedBox(
                              width: 80,
                              child: IconButton(
                                icon: const Icon(Icons.not_started_outlined),
                                onPressed: () {
                                  manualonoff(srNo);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (listOfValue?[index].widgetTypeId == 3) {
                    final dropDownList = [
                      'Stop Irrigation',
                      'Continue Irrigation',
                      'No Fertilization',
                      'Open Valves',
                    ];
                    String dropDownVal = listOfValue?[index].value;
                    dropDownList.contains(dropDownVal) == true
                        ? dropDownVal
                        : dropDownVal = 'Stop Irrigation';

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
                              '${listOfValue?[index].title}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            trailing: SizedBox(
                              width: 180,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton(
                                    items: dropDownList.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Container(
                                            child: Text(
                                              items,
                                            )),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        listOfValue?[index].value = value!;
                                        dropDownVal =
                                            listOfValue?[index].value;
                                      });
                                    },
                                    value: listOfValue?[index].value == ''
                                        ? dropDownList[0]
                                        : listOfValue?[index].value),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (listOfValue?[index].widgetTypeId == 5 &&
                      listOfValue?[index].title != "FILTER ON TIME") {
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
                              '${listOfValue?[index].title}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Container(
                                  child: Center(
                                    child: InkWell(
                                      child: Text(
                                        '${listOfValue?[index].value}' != ''
                                            ? '${listOfValue?[index].value}'
                                            : '00:00:00',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: HoursMinutesSeconds(
                                                  initialTime: '${listOfValue?[index].value}' != ''
                                                      ? '${listOfValue?[index].value}'
                                                      : '00:00:00',
                                                  // initialTime:
                                                  //     '${listOfValue?[index].value}' !=
                                                  //             ''
                                                  //         ? '${listOfValue?[index].value}'
                                                  //         : '00:00:00',
                                                  onPressed: () {
                                                    setState(() {
                                                      listOfValue?[index].value =
                                                      '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              );
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
                      children: [
                        SizedBox(
                          height: Changesize(
                              listOfValue?[index].value.length, 60),
                          width: double.infinity,
                          child: ListView.builder(
                              itemCount:
                              listOfValue?[index].value!.length ?? 0,
                              itemBuilder: (context, flusingindex) {
                                return Column(
                                  children: [
                                    Card(
                                      elevation: 0.1,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          '${listOfValue?[index].value[flusingindex]['name']} ON TIME',
                                          style: TextStyle(
                                            fontSize:14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                        trailing: SizedBox(
                                          width: 90,
                                          child: Container(
                                              child: Center(
                                                child: InkWell(
                                                  child: Text(
                                                    '${listOfValue?[index].value![flusingindex]['value']}' !=
                                                        ''
                                                        ? '${listOfValue?[index].value![flusingindex]['value']}'
                                                        : '00:00:00',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  onTap: () async {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title:
                                                            HoursMinutesSeconds(
                                                              initialTime:
                                                              '${listOfValue?[0].value![flusingindex]['value']}' !=
                                                                  ''
                                                                  ? '${listOfValue?[0].value![flusingindex]['value']}'
                                                                  : '00:00:00',
                                                              // initialTime:
                                                              //     '${listOfValue?[index].value![flusingindex]['value']}' !=
                                                              //             ''
                                                              //         ? '${listOfValue?[index].value![flusingindex]['value']}'
                                                              //         : '00:00:00',
                                                              onPressed: () {
                                                                setState(() {
                                                                  listOfValue?[index]
                                                                      .value![flusingindex]
                                                                  [
                                                                  'value'] =
                                                                  '${overAllPvd.hrs.toString().padLeft(2, '0')}:${overAllPvd.min.toString().padLeft(2, '0')}:${overAllPvd.sec.toString().padLeft(2, '0')}';
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          );
                                                        });
                                                  },
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  updateRadiationSet() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    List<Map<String, dynamic>> filterBackWash =
    _filterbackwash.data!.map((condition) => condition.toJson()).toList();
    String mqttSendData = toMqttFormat(_filterbackwash.data);

     Map<String, dynamic> payLoadFinal = {
      "900": [
        {"901": mqttSendData},
      ]
    };
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "filterBackwash": filterBackWash,
      "hardware":payLoadFinal,
      "createUser": overAllPvd.userId
    };

    if (MQTTManager().isConnected == true) {
      await validatePayloadSent(
          dialogContext: context,
          context: context,
          mqttPayloadProvider: mqttPayloadProvider,
          acknowledgedFunction: () async{
            final response = await HttpService()
                .postRequest("createUserPlanningFilterBackwashing", body);
            final jsonDataResponse = json.decode(response.body);
            // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
            GlobalSnackBar.show(
                context, jsonDataResponse['message'], response.statusCode);
          },
          payload: payLoadFinal,
          payloadCode: '900',
          deviceId: overAllPvd.imeiNo
      );
    } else {
      // Map<String, dynamic>
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
    // if (MQTTManager().isConnected == true) {
    //   MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
    //   GlobalSnackBar.show(
    //       context, jsonDataResponse['message'], response.statusCode);
    // } else {
    //   GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    // }
  }

  manualonoff(int index) async {
    String payLoadFinal = jsonEncode({
      "4000": [
        {"4001": index},
      ]
    });
    if (MQTTManager().isConnected == true) {
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
      GlobalSnackBar.show(context, 'Manual ON/OFF Send', 200);
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
  }

  String toMqttFormat(
      List<Datum>? data,
      ) {
    String mqttData = '';
    for (var i = 0; i < data!.length; i++) {
      int sno = data[i].sNo!;
      String id = data[i].hid!;
      List<String> time = [];
      for (var j = 0; j < data[i].filter![0].value.length; j++) {
        time.add('${data[i].filter![0].value[j]['value']}');
      }
      String flushingTime = time.join('_');
      String filterInterval = data[i].filter![1].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![1].value!}';
      String flushingInterval = data[i].filter![2].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![2].value!}';
      String whileFlushing = '2';
      if (data[i].filter![3].value! == 'Continue Irrigation') {
        whileFlushing = '1';
      } else if (data[i].filter![3].value! == 'Stop Irrigation') {
        whileFlushing = '2';
      } else if (data[i].filter![3].value! == 'No Fertilization') {
        whileFlushing = '3';
      } else if (data[i].filter![3].value! == 'Open Valves') {
        whileFlushing = '4';
      }
      String cycles =
      data[i].filter![4].value!.isEmpty ? '0' : data[i].filter![4].value!;
      String pressureValues =
      data[i].filter![5].value!.isEmpty ? '0' : data[i].filter![5].value!;
      String deltaPressureDelay = data[i].filter![6].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![6].value!}';
      String dwellTimeMainFilter = data[i].filter![8].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![8].value!}';
      String afterDeltaPressureDelay = data[i].filter![7].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![7].value!}';
      mqttData +=
      '$sno,$id,$flushingTime,$filterInterval,$flushingInterval,$whileFlushing,$cycles,$pressureValues,$deltaPressureDelay,$dwellTimeMainFilter,$afterDeltaPressureDelay;';
    }
    return mqttData;
  }
}
