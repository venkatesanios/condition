import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
 import 'package:provider/provider.dart';
 import '../../../../constants/http_service.dart';
import '../../../Models/Customer/GroupsModel.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/SelectedGroupProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/validateMqtt.dart';
import '../Dashboard/Mobile Dashboard/sidedrawer.dart';
import 'groupdetailsscreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';


class MyGroupScreen extends StatefulWidget {
  const MyGroupScreen(
      {super.key,
      required this.userId,
      required this.controllerId,
      required this.deviceID});
  final userId, controllerId, deviceID;
  @override
  MyGroupScreenState createState() => MyGroupScreenState();
}

class MyGroupScreenState extends State<MyGroupScreen> with ChangeNotifier {
   final _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> jsonData = {};
  Groupedname _groupedName = Groupedname();
  Timer? _timer;
  String selectedGroupNew = '';
  List<Group>? groupNamesNew = [];
  final ScrollController _controller = ScrollController();
  final ScrollController _controller2 = ScrollController();
   late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchData();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response =
        await HttpService().postRequest("getUserPlanningNamedGroup", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsonData1 = jsonDecode(response.body);
        _groupedName = Groupedname.fromJson(jsonData1);

        _timer = Timer(const Duration(milliseconds: 500), () {
          groupNamesNew = _groupedName.data?.group;
          var groupSelect =
              Provider.of<SelectedGroupProvider>(context, listen: false);
          groupSelect.clearvalues();

          if (_groupedName.data!.group!.isNotEmpty) {
            selectedGroupNew = groupNamesNew!.first.id!;
            groupSelect.updateSelectedGroup(groupNamesNew!.first.name!);

            List<String> valveID = [];
            for (var i = 0;
                i < _groupedName.data!.group![0].valve!.length;
                i++) {
              String vid = _groupedName.data!.group![0].valve![i].id ?? '';
              valveID.add(vid.split("VL.").last);
            }

            groupSelect.updateselectedvalve(valveID);
          }
        });
      });
    } else {
      // _showSnackBar(response.body);
    }
  }

  void _showDetailsScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DetailsSection(
          data: _groupedName.data!.toJson(),
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showAlertDialog(
    BuildContext context,
    String title,
    String msg,
    bool btnCount,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            btnCount
                ? TextButton(
                    child: const Text("cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : Container(),
          ],
        );
      },
    );
  }

  bool colorChange(List<dynamic> selectList, String srNo) {
    if (selectList.isNotEmpty) {
      for (var i = 0; i < selectList.length; i++) {
        if (selectList[i]['sNo'].toString() == srNo) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }
   @override
  Widget build(BuildContext context) {
     var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
     mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
     var groupSelect = Provider.of<SelectedGroupProvider>(context, listen: true);
    if (_groupedName.data == null) {
      return const Center(
          child: Text(
        'Currently no group available add first Product Limit',
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
      ));
    } else if (_groupedName.data!.group!.length <= 0) {
      return const Center(
          child: Text(
        'Currently no group available add first Product Limit',
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
      ));
    } else {
      return Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Color(0xffE6EDF5),
          body: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //TODO:- icon Group Details Icon
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     // const Text('List of Groups'),
                //     const SizedBox(
                //       width: 10,
                //     ),
                //
                //     Padding(
                //       padding: const EdgeInsets.only(right: 20.0),
                //       child: IconButton(
                //         icon: const Icon(Icons.info),
                //         onPressed: () {
                //           _groupedName.data!.group!.isNotEmpty
                //               ? _showDetailsScreen(context)
                //               : _showAlertDialog(context, 'Warning',
                //                   'Currently no group available', false);
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                //TODO:- new tabbar
                Expanded(
                  child: DefaultTabController(
                    animationDuration: const Duration(milliseconds: 888),
                    length: _groupedName.data!.group!.length ?? 0,
                    child: Scaffold(
                      backgroundColor: Color(0xffE6EDF5),
                      appBar: AppBar(title: Text('Groups'),automaticallyImplyLeading: false,),
                      body: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, bottom: 10, right: 8, top: 8),
                        child: Center(
                          child: Container(
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
                                          color: myTheme.primaryColorDark,
                                        ),
                                      ),
                                      isScrollable: true,
                                      unselectedLabelColor: Colors.black,
                                      labelColor: Colors.white,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      tabs: [
                                        for (var i = 0;
                                            i <
                                                _groupedName
                                                    .data!.group!.length;
                                            i++)
                                          Tab(
                                            text:
                                                '${_groupedName.data!.group![i].name}',
                                          ),
                                      ],
                                      onTap: (value) {
                                        setState(() {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              selectedGroupNew = _groupedName
                                                  .data!.group![value].id!;
                                              groupSelect.updateSelectedGroup(
                                                  _groupedName.data!
                                                      .group![value].name!);
                                              groupSelect
                                                  .updateSelectedGroupsrno(
                                                      _groupedName.data!
                                                          .group![value].sNo!);
                                              groupSelect.updateSelectedGroupid(
                                                  _groupedName.data!
                                                          .group![value].id ??
                                                      '');
                                              groupSelectValveUpdate(
                                                  _groupedName
                                                      .data!.group![value],
                                                  context);
                                            });
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  _groupedName
                                                      .data!.group!.length;
                                              i++)
                                            lineValvesShow(context),
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
                //TODO:- Group
                // groupnamenew(context),
                //TODO:- Line
                // lineValvesshow(context),
                const SizedBox(
                  height: 10,
                ),
                //Show Lines and selection valve
              ],
            ),
          ),
          floatingActionButton: Row(
            children: [
              const Spacer(),
              FloatingActionButton(
                backgroundColor: myTheme.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.info),
                onPressed: () {
                  _groupedName.data!.group!.isNotEmpty
                      ? _showDetailsScreen(context)
                      : _showAlertDialog(context, 'Warning',
                      'Currently no group available', false);
                },
              ),
              const SizedBox(
                width: 10,
              ),
              //ToDo: Delete Button
              FloatingActionButton(
                backgroundColor: myTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: () async {
                  _groupedName.data!.group![groupSelect.selectedGroupsrno]
                      .valve = List.empty();
                  var group = _groupedName.data!.toJson();
                  String mqttSendData =
                  toMqttFormat(_groupedName.data!.group);
                  Map<String, dynamic> payLoadFinal = {
                    "1300": [
                      {"1301": mqttSendData},
                    ]
                  };
                  Map<String, Object> body = {
                    "userId": overAllPvd.userId,
                    "controllerId": overAllPvd.controllerId,
                    "group": group['group'],
                    "hardware":payLoadFinal,
                    "createUser": overAllPvd.userId
                  };

                  setState(() async {


                    if (MQTTManager().isConnected == true) {
                      await validatePayloadSent(
                          dialogContext: context,
                          context: context,
                          mqttPayloadProvider: mqttPayloadProvider,
                          acknowledgedFunction: () async {
                            final response = await HttpService().postRequest(
                                "createUserPlanningNamedGroup", body);
                            final jsonDataResponse = json.decode(response.body);
                            // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
                            GlobalSnackBar.show(
                                context,
                                jsonDataResponse['message'],
                                response.statusCode);
                          },
                          payload: payLoadFinal,
                          payloadCode: '1300',
                          deviceId: overAllPvd.imeiNo);
                    } else {
                      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
                    }
                  });
                },
                child: const Icon(Icons.delete),
              ),
              const SizedBox(
                width: 10,
              ),
              //ToDo: Send button
              FloatingActionButton(
                backgroundColor: myTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: () async {
                  var group = _groupedName.data!.toJson();
                  Map<String, Object> body = {
                    "userId": overAllPvd.userId,
                    "controllerId": overAllPvd.controllerId,
                    "group": group['group'],
                    "createUser": overAllPvd.userId
                  };

                  String mqttDendData = toMqttFormat(_groupedName.data!.group);
                  Map<String, dynamic> payLoadFinal = {
                    "1300": [
                      {"1301": mqttDendData},
                    ]
                  };
                  if (MQTTManager().isConnected == true) {
                    await validatePayloadSent(
                        dialogContext: context,
                        context: context,
                        mqttPayloadProvider: mqttPayloadProvider,
                        acknowledgedFunction: () async {
                          final response = await HttpService().postRequest(
                              "createUserPlanningNamedGroup", body);
                          final jsonDataResponse = json.decode(response.body);
                          // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
                          GlobalSnackBar.show(
                              context,
                              jsonDataResponse['message'],
                              response.statusCode);
                        },
                        payload: payLoadFinal,
                        payloadCode: '1300',
                        deviceId: overAllPvd.imeiNo);
                  } else {
                    GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
                  }
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
          // ),
        );
      });
    }
  }

  String toMqttFormat(
    List<Group>? data,
  ) {
    String mqttData = '';

    for (var i = 0; i < data!.length; i++) {
      int sno = data[i].sNo!;
      String id = '';
      String name = data[i].name!;
      String line = data[i].location!;
      List<Valveselect>? valve = data[i].valve!;
      String valveSrNo = '';
      for (var j = 0; j < valve.length; j++) {
        int usNo = valve[j].sNo!;
        id = valve[j].hid!;
        valveSrNo += '$usNo';
        if (j < valve.length - 1) {
          valveSrNo += '_';
        }
      }
      mqttData += '$sno,$id,$name,$line,$valveSrNo;';
    }
    return mqttData;
  }

  @override
  Widget selectvalveName(BuildContext context) {
    var groupSelect = Provider.of<SelectedGroupProvider>(context, listen: true);

    return Container(
        // height: 50,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${groupSelect.selectedGroup} : ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            groupSelect.selectedvalve.isNotEmpty
                ? Chip(
                    label: Text(
                      '${groupSelect.selectedvalve.join(' & ')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    ),
                  )
                : Container(),
          ],
        ));
    //Group Details Icon
  }

  @override
  Widget groupNameNew(BuildContext context) {
    var groupSelect = Provider.of<SelectedGroupProvider>(context, listen: true);
    return Column(
      children: [
        Wrap(
          spacing: 0.5,
          children: groupNamesNew?.map((group) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: group.name!.isNotEmpty
                      ? FilterChip(
                          label: Text(group.name ?? ''),
                          backgroundColor: groupSelect.selectedGroup == group.id
                              ? Colors.amber
                              : Colors.blueGrey[100],
                          selectedColor: Colors.amber,
                          selected: selectedGroupNew == group.id,
                          showCheckmark: false,
                          onSelected: (isSelected) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                selectedGroupNew = group.id!;
                                groupSelect.updateSelectedGroup(group.name!);
                                groupSelect.updateSelectedGroupsrno(group.sNo!);
                                groupSelect
                                    .updateSelectedGroupid(group.id ?? '');
                                groupSelectValveUpdate(group, context);
                              });
                            });
                          },
                        )
                      : Container(),
                );
              }).toList() ??
              [],
        ),
      ],
    );
  }

  Widget lineValvesShow(BuildContext context) {
    var groupSelect = Provider.of<SelectedGroupProvider>(context, listen: true);
    return ListView.builder(
      controller: _controller,
      itemCount: _groupedName.data!.line!.length,
      itemBuilder: (context, index) {
        return MediaQuery.sizeOf(context).width > 600
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 220,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child:   Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // child: Icon(Icons.line_axis_outlined, color: Theme.of(context).primaryColor),
                                  child: SvgPicture.asset(
                                    'assets/images/default.svg',
                                  ),
                                ),

                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '${_groupedName.data!.line![index].name}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Text(
                                    'list of valves',
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                            height: 50,
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 70,
                            child: Scrollbar(
                              trackVisibility: true,
                              child: ListView.builder(
                                controller: _controller2,
                                scrollDirection: Axis.horizontal,
                                itemCount: _groupedName
                                        .data!.line![index].valve!.length,
                                itemBuilder: (context, innerIndex) {
                                  String vid =
                                      '${_groupedName.data!.line![index].valve![innerIndex].id}'
                                          .split("VL.")
                                          .last;

                                  //Edit Valve selection
                                  return InkWell(
                                    onTap: () {
                                      Valveselect selectvalve = _groupedName
                                          .data!
                                          .line![index]
                                          .valve![innerIndex];

                                      Group group = _groupedName.data!.group![
                                          groupSelect.selectedGroupsrno];

                                      // String valveid = _groupedName.data!.line![index]
                                      //         .valve![innerIndex].id ??
                                      //     '';
                                      String Lineid =
                                          _groupedName.data!.line![index].id ??
                                              '';
                                      setState(() {
                                        groupSelection(group, selectvalve,
                                            Lineid, context);
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.all(4),
                                      child: Center(
                                        child: CircleAvatar(
                                          backgroundColor: groupSelectionSolor(
                                              _groupedName.data!.group![
                                              groupSelect
                                                  .selectedGroupsrno],
                                              _groupedName
                                                  .data!
                                                  .line![index]
                                                  .valve![innerIndex],
                                              context)
                                              ? myTheme.primaryColor
                                              : const Color(0xFFE3FFF5),
                                          child: Text(vid,style: TextStyle(color: groupSelectionSolor(
                                              _groupedName.data!.group![
                                              groupSelect
                                                  .selectedGroupsrno],
                                              _groupedName
                                                  .data!
                                                  .line![index]
                                                  .valve![innerIndex],
                                              context)
                                              ? Colors.white
                                              : Colors.black)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0.4,
                shadowColor:Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                // child: Icon(Icons.line_axis_outlined, color: Theme.of(context).primaryColor),
                                child: SvgPicture.asset(
                                  'assets/images/default.svg',
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '${_groupedName.data!.line![index].name}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 55, right: 55),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 70,
                          child: Scrollbar(
                            trackVisibility: true,
                            child: ListView.builder(
                              controller: _controller2,
                              scrollDirection: Axis.horizontal,
                              itemCount: _groupedName
                                      .data!.line![index].valve!.length ??
                                  0,
                              itemBuilder: (context, innerIndex) {
                                String vid =
                                    '${_groupedName.data!.line![index].valve![innerIndex].id}'
                                        .split("VL.")
                                        .last;

                                //Edit Valve selection
                                return InkWell(
                                  onTap: () {
                                    Valveselect selectvalve = _groupedName
                                        .data!.line![index].valve![innerIndex];

                                    Group group = _groupedName.data!
                                        .group![groupSelect.selectedGroupsrno];

                                    // String valveid = _groupedName.data!.line![index]
                                    //     .valve![innerIndex].id ??
                                    //     '';
                                    String Lineid =
                                        _groupedName.data!.line![index].id ??
                                            '';
                                    setState(() {
                                      groupSelection(
                                          group, selectvalve, Lineid, context);
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    margin: const EdgeInsets.all(4),
                                    child: Center(
                                        child: CircleAvatar(
                                          backgroundColor: groupSelectionSolor(
                                              _groupedName.data!.group![
                                              groupSelect
                                                  .selectedGroupsrno],
                                              _groupedName.data!.line![index]
                                                  .valve![innerIndex],
                                              context)
                                              ? myTheme.primaryColor
                                              : const Color(0xFFE3FFF5),
                                          child: Text(vid,style: TextStyle(color: groupSelectionSolor(
                                              _groupedName.data!.group![
                                              groupSelect
                                                  .selectedGroupsrno],
                                              _groupedName
                                                  .data!
                                                  .line![index]
                                                  .valve![innerIndex],
                                              context)
                                              ? Colors.white
                                              : Colors.black)
                                          ),
                                        )),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
      },
    );
  }

  void groupSelection(
      Group group, Valveselect selectValve, String id, BuildContext context) {
    if (group.location == id) {
      bool idExists = false;
      for (var i = 0; i < group.valve!.length; i++) {
        if (group.valve![i].id == selectValve.id) {
          group.valve!.removeAt(i);
          idExists = true;
        }
      }
      if (!idExists) {
        group.valve!.add(selectValve);
      }
    } else {
      group.location = id;
      group.valve = [];
      group.valve!.add(selectValve);
    }
    groupSelectValveUpdate(group, context);
  }

  bool groupSelectionSolor(
      Group group, Valveselect selectValve, BuildContext context) {
    bool isValveMatch = group.valve!.any((valve) => valve.id == selectValve.id);
    // groupselectvalveupdate(group, context);
    return isValveMatch;
  }

  void groupSelectValveUpdate(Group group, BuildContext context) {
    var groupSelect =
        Provider.of<SelectedGroupProvider>(context, listen: false);
    List<String> valveID = [];
    for (var i = 0; i < group.valve!.length; i++) {
      String vid = group.valve![i].id ?? '';
      valveID.add(vid.split("VL.").last);
    }
    groupSelect.updateselectedvalve(valveID);
  }

  void updateGroupWithMissingValves(List<Group> line, List<Group> group) {
    for (var groupItem in group) {
      var lineItem = line.firstWhere(
          (lineItem) => lineItem.id == groupItem.location,
          orElse: () => Group());

      if (lineItem.valve != null) {
        groupItem.valve ??= [];
        groupItem.valve!.removeWhere((groupValve) =>
            !lineItem.valve!.any((lineValve) => lineValve.id == groupValve.id));
        var missingValves = lineItem.valve!.where((lineValve) => !groupItem
            .valve!
            .any((groupValve) => groupValve.id == lineValve.id));
        groupItem.valve!.addAll(missingValves);
      }
    }
  }
}
