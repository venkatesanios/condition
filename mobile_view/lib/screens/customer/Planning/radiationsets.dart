import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

 import '../../../Models/Customer/radiation_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/validateMqtt.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';

class RadiationSetUI extends StatefulWidget {
  const RadiationSetUI({
    Key? key,
    required this.userId,
    required this.controllerId,
    this.deviceId,
  });
  final userId, controllerId, deviceId;

  @override
  State<RadiationSetUI> createState() => _RadiationSetUIState();
}

class _RadiationSetUIState extends State<RadiationSetUI>
    with SingleTickerProviderStateMixin {
  dynamic jsonData;
  TimeOfDay _selectedTime = TimeOfDay.now();
  RqadiationSet _radiationSet = RqadiationSet();
  int tabClickIndex = 0;

  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    fetchData();
    //MqttWebClient().init();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response =
        await HttpService().postRequest("getUserPlanningRadiationSet", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsonData1 = jsonDecode(response.body);
        _radiationSet = RqadiationSet.fromJson(jsonData1);
      });
      //MqttWebClient().onSubscribed('tweet/');
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

    if (_radiationSet.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_radiationSet.data!.isEmpty) {
      return const Center(child: Text('Currently No Radiation Sets Available'));
    } else {
      return DefaultTabController(
        length: _radiationSet.data!.length,
          child: Scaffold(backgroundColor: Color(0xffE6EDF5),
            appBar: AppBar(title: Text('Radiation Set'),automaticallyImplyLeading: false,),
           body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //TODO:- NewTabBar
                Expanded(
                  child: DefaultTabController(
                    animationDuration: const Duration(milliseconds: 888),
                    length: _radiationSet.data!.length,
                    child: Scaffold(
                       backgroundColor: const Color(0xffE6EDF5),

                      body: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, bottom: 10, right: 8, top: 8),
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
                                    height:
                                        MediaQuery.sizeOf(context).width > 600
                                            ? 50
                                            : 40,
                                    child: TabBar(
                                      // controller: _tabController,
                                      indicatorWeight: 4,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: BoxDecoration(
                                        color: myTheme.primaryColorDark,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 10,
                                            color: myTheme.primaryColorDark),
                                      ),
                                      isScrollable: true,
                                      unselectedLabelColor: Colors.black,
                                      labelColor: Colors.white,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      tabs: [
                                        for (var i = 0;
                                            i < _radiationSet.data!.length;
                                            i++)
                                          Tab(
                                            text:
                                                '${_radiationSet.data![i].name}',
                                          ),
                                      ],
                                      onTap: (value) {
                                        setState(() {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {});
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          for (var i = 0;
                                              i < _radiationSet.data!.length;
                                              i++)
                                            buildTab(_radiationSet.data!, i)
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //TODO:- Line
                const SizedBox(
                  height: 5,
                ),
                //Show Lines and selection valve
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: myTheme.primaryColorDark,
            foregroundColor: Colors.white,
            onPressed: () async {
              setState(() {
                updateRadiationRet();
              });
            },
            tooltip: 'Send',
            child: const Icon(Icons.send),
          ),
        ),
      );
    }
  }

  Widget buildTab(List<Datum>? list, int i) {
    debugPrint("${MediaQuery.sizeOf(context).width}");
    if (MediaQuery.sizeOf(context).width > 600) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.shade100,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height - 300,
              width: MediaQuery.of(context).size.width < 400
                  ? 450
                  : MediaQuery.of(context).size.width > 1100
                      ? 1100
                      : MediaQuery.of(context).size.width,
              child: DataTable2(
                dataRowHeight:
                    MediaQuery.of(context).size.width < 800 ? 65.0 : 50,
                headingRowHeight:
                    MediaQuery.of(context).size.width < 800 ? 65.0 : 50,
                headingRowColor:
                    MaterialStateProperty.all<Color>(primaryColorDark),
                // fixedCornerColor: myTheme.primaryColor,
                // minWidth:450,
                // fixedLeftColumns: 1,
                // border: TableBorder.all(),
                columns: [
                  DataColumn2(
                      size: ColumnSize.L,
                      label: Text(
                        'Time Interval 24 Hrs',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize:
                                16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                  DataColumn2(
                      size: ColumnSize.L,
                      label: Center(
                        child: Text(
                          '00:01 - 5:59',
                          textAlign: TextAlign.right,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                  DataColumn2(
                      size: ColumnSize.L,
                      label: Center(
                        child: Text(
                          '05:59 - 15:59',
                          textAlign: TextAlign.right,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                  DataColumn2(
                    size: ColumnSize.L,
                    label: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Center(
                        child: Text(
                          '15:59 - 23:59',
                          textAlign: TextAlign.right,
                          softWrap: true,
                          style: TextStyle(
                              fontSize:16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                      //color: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                      cells: [
                        DataCell(Text(
                          "Accumulated radiation threshold ",
                          style: TextStyle(
                            fontSize:
                                 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(
                          onTap: () {
                            setState(() {});
                          },
                          TextFormField(
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: list![i].accumulated1 != ''
                                ? list[i].accumulated1
                                : '',
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              setState(() {
                                list[i].accumulated1 = value;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                            initialValue: list[i].accumulated2 != ''
                                ? list[i].accumulated2
                                : '',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              setState(() {
                                list[i].accumulated2 = value;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                            initialValue: list[i].accumulated3 != ''
                                ? list[i].accumulated3
                                : '',
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                list[i].accumulated3 = value;
                              });
                            },
                          ),
                        ),
                      ]),
                  DataRow(
                      //color: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                      cells: [
                        DataCell(Text(
                          "Min interval (hh:mm)",
                          style: TextStyle(
                            fontSize:
                                 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].minInterval1 != '' ? list[i].minInterval1 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].minInterval1 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].minInterval2 != '' ? list[i].minInterval2 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].minInterval2 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].minInterval3 != '' ? list[i].minInterval3 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].minInterval3 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                  DataRow(
                      //color: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                      cells: [
                        DataCell(Text(
                          "Max interval (hh:mm)",
                          style: TextStyle(
                            fontSize:
                                 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].maxInterval1 != '' ? list[i].maxInterval1 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].maxInterval1 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].maxInterval2 != '' ? list[i].maxInterval2 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].maxInterval2 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: InkWell(
                              child: Text(
                                '${list[i].maxInterval3 != '' ? list[i].maxInterval3 : '00:00'}',
                                style: TextStyle(
                                  fontSize:

                                          16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                String? time = await _selectTime(context);
                                setState(() {
                                  if (time != null) {
                                    list[i].maxInterval3 = time;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                  DataRow(
                      //color: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                      cells: [
                        DataCell(Text(
                          " Co - efficient",
                          style: TextStyle(
                            fontSize:
                                 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(
                          TextFormField(
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            initialValue: '',
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                            initialValue: list[i].coefficient != ''
                                ? list[i].coefficient
                                : '',
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                list[i].coefficient = value;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            initialValue: '',
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        ),
                      ]),
                  DataRow(
                      //color: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                      cells: [
                        DataCell(Text(
                          " Used by program",
                          style: TextStyle(
                            fontSize:
                                 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(
                          TextFormField(
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            initialValue: '',
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                            initialValue: list[i].usedByProgram != ''
                                ? list[i].usedByProgram
                                : '',
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                list[i].usedByProgram = value;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            initialValue: '',
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          height: 900,
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Accumulated radiation (00:01-05:59) ',
                    softWrap: true,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '0'),
                      initialValue: list?[i].accumulated1 != ''
                          ? list![i].accumulated1
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list?[i].accumulated1 = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Accumulated radiation (06:00-15:59) ',
                    softWrap: true,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '0'),
                      initialValue: list?[i].accumulated2 != ''
                          ? list![i].accumulated2
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list?[i].accumulated2 = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Accumulated radiation (16:00-23:59) ',
                    softWrap: true,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '0'),
                      initialValue: list?[i].accumulated3 != ''
                          ? list![i].accumulated3
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list?[i].accumulated3 = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Min Intervel (00:01-05:59)',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].minInterval1}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list![i].minInterval1 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Min Intervel (06:00-15:59) ',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].minInterval2}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list![i].minInterval2 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Min Intervel (16:00-23:59) ',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].minInterval3}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list![i].minInterval3 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Max Intervel (00:01-05:59)',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].maxInterval1}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list![i].maxInterval1 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Max Intervel (06:00-15:59) ',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].maxInterval2}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list![i].maxInterval2 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Max Intervel (16:00-23:59) ',
                    softWrap: true,
                  ),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${list![i].maxInterval3}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time != null) {
                            list[i].maxInterval3 = time;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Co-Efficient',
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '0'),
                      initialValue: list?[i].coefficient != ''
                          ? list![i].coefficient
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list?[i].coefficient = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Used by Program',
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '0'),
                      initialValue: list?[i].usedByProgram != ''
                          ? list![i].usedByProgram
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list?[i].usedByProgram = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  updateRadiationRet() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    List<Map<String, dynamic>> radiationSet =
        _radiationSet.data!.map((condition) => condition.toJson()).toList();
    String mqttSendData = toMqttFormat(_radiationSet.data);
    print('radiationSet:$radiationSet');
    Map<String, dynamic> payLoadFinal = {
      "1900": [
        {"1901": mqttSendData},
      ]
    };
     Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "radiationSet": radiationSet,
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
                .postRequest("createUserPlanningRadiationSet", body);
            final jsonDataResponse = json.decode(response.body);
            GlobalSnackBar.show(
                context, jsonDataResponse['message'], response.statusCode);
          },
          payload: payLoadFinal,
          payloadCode: '1900',
          deviceId: overAllPvd.imeiNo
      );
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }

  }

  String toMqttFormat(
    List<Datum>? data,
  ) {
    String mqttData = '';
    for (var i = 0; i < data!.length; i++) {
      mqttData +=
          '${data[i].sNo}.1,${data[i].hid},${data[i].name},${data[i].coefficient == null || data[i].coefficient == '' ? '0' : data[i].coefficient},00:01:00,05:59:00,${data[i].accumulated1 == null || data[i].accumulated1 == '' ? '0' : data[i].accumulated1},${data[i].minInterval1},${data[i].maxInterval1};${data[i].sNo}.2,${data[i].id},${data[i].name},${data[i].coefficient == null || data[i].coefficient == '' ? '0' : data[i].coefficient},05:59:00,15:59:00,${data[i].accumulated2 == null || data[i].accumulated2 == '' ? '0' : data[i].accumulated2},${data[i].minInterval2},${data[i].maxInterval2};${data[i].sNo}.3,${data[i].id},${data[i].name},${data[i].coefficient == null || data[i].coefficient == '' ? '0' : data[i].coefficient},15:59:00,23:59:00,${data[i].accumulated3 == null || data[i].accumulated3 == '' ? '0' : data[i].accumulated3},${data[i].minInterval3},${data[i].maxInterval3};';
    }
    return mqttData;
  }
}
