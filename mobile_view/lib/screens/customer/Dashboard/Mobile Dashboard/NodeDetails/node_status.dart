import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/Models/Customer/node_model.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/program_library.dart';
import 'package:mobile_view/state_management/overall_use.dart';

import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/MQTTManager.dart';
import '../../../../../constants/http_service.dart';
import '../../../../../constants/snack_bar.dart';
import '../../../../../constants/theme.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'NodeHourlyLog/node_horuly_log.dart';
import 'SensorLogData/sensor_log_data.dart';

class NodeStatus extends StatefulWidget {
  const NodeStatus({super.key});

  @override
  State<NodeStatus> createState() => _NodeStatusState();
}

class _NodeStatusState extends State<NodeStatus> {
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;

  @override
  void initState() {
    // TODO: implement initState
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);

    return payloadProvider.nodeData.isNotEmpty ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundColor:myTheme.primaryColorDark.withOpacity(0.2),
              //   child: Image.asset('assets/images/oro_gem.png', width: 40, height: 40,),
              // ),
              // Text(deviceData["deviceName"], style: const TextStyle(color: Colors.black, fontSize: 13)),
              // Text('${deviceData["categoryName"]} - Last sync : ${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: Colors.black,),),
              ListTile(
                title: Text("Node List".toUpperCase()),
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 18),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                trailing: IntrinsicWidth(
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) => NodeHrsLog(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,))
                            );
                          },
                          icon: Icon(Icons.auto_graph, color: Colors.deepOrangeAccent,)
                      ),
                      IconButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) => SensorHourlyLogs(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,))
                            );
                          },
                          icon: Icon(Icons.sensors, color: Colors.blueGrey,)
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 5),
                                CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                                SizedBox(width: 5),
                                Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                                SizedBox(width: 5),
                                Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 10),
                                CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                                SizedBox(width: 5),
                                Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 10),
                                CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                                SizedBox(width: 5),
                                Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            tooltip: 'Set serial for all Nodes',
                            icon: Icon(Icons.format_list_numbered, color: myTheme.primaryColorDark),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Are you sure! you want to proceed to reset all node ids?'),
                                    actions: <Widget>[
                                      MaterialButton(
                                        color: Colors.redAccent,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      MaterialButton(
                                        color: myTheme.primaryColor,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Map<String, dynamic> payLoadFinal = {
                                            "2300": [
                                              {"2301": ""},
                                            ]
                                          };
                                          validatePayloadSent(
                                              dialogContext: context,
                                              context: context,
                                              mqttPayloadProvider: payloadProvider,
                                              acknowledgedFunction: () {
                                                sentToServer('Set serial for all nodes comment sent successfully', payLoadFinal);
                                                showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Set serial for all Nodes successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                              },
                                              payload: payLoadFinal,
                                              payloadCode: '2300',
                                              deviceId: '${overAllPvd.imeiNo}'
                                          );

                                          // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                                          // GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            tooltip: 'Test Communication',
                            icon: Icon(Icons.network_check, color: myTheme.primaryColorDark),
                            onPressed: () async {
                              Map<String, dynamic> payLoadFinal = {
                                "4500": [
                                  {"4501": ""},
                                ]
                              };
                              validatePayloadSent(
                                  dialogContext: context,
                                  context: context,
                                  mqttPayloadProvider: payloadProvider,
                                  acknowledgedFunction: () {
                                    sentToServer('Test Communication comment sent successfully', payLoadFinal);
                                    showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Test Communication successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                  },
                                  payload: payLoadFinal,
                                  payloadCode: '4500',
                                  deviceId: '${overAllPvd.imeiNo}'
                              );
                              // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                              // GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                              // Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width:400,
                height: 35,
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 325,
                  headingRowHeight: 35.0,
                  headingRowColor: MaterialStateProperty.all<Color>(myTheme.primaryColorDark.withOpacity(0.3)),
                  columns: const [
                    DataColumn2(
                        label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                        fixedWidth: 35
                    ),
                    DataColumn2(
                      label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                      fixedWidth: 55,
                    ),
                    DataColumn2(
                      label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                      fixedWidth: 45,
                    ),
                    DataColumn2(
                      label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                      size: ColumnSize.M,
                      numeric: true,
                    ),
                    DataColumn2(
                      label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                      fixedWidth: 40,
                    ),
                  ],
                  rows: List<DataRow>.generate(0,(index) => const DataRow(cells: [],),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: payloadProvider.nodeData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ExpansionTile(
                          //initiallyExpanded: true,
                          trailing: payloadProvider.nodeData[index].rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                          const Icon(Icons.info_outline, color: primaryColorDark,),
                          backgroundColor: Colors.teal.shade50,
                          title: Row(
                            children: [
                              SizedBox(width: 35, child: Text('${payloadProvider.nodeData[index].serialNumber}', style: const TextStyle(fontSize: 13),)),
                              SizedBox(
                                width:55,
                                child: Center(child: CircleAvatar(radius: 7, backgroundColor:
                                payloadProvider.nodeData[index].status == 1? Colors.green.shade400:
                                payloadProvider.nodeData[index].status == 2? Colors.grey:
                                payloadProvider.nodeData[index].status == 3? Colors.redAccent:
                                payloadProvider.nodeData[index].status == 4? Colors.yellow:
                                Colors.grey,
                                )),
                              ),
                              SizedBox(width: 45, child: Center(child: Text('${payloadProvider.nodeData[index].referenceNumber}', style: const TextStyle(fontSize: 13),))),
                              Expanded(
                                 child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(payloadProvider.nodeData[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 13)),
                                    Text(payloadProvider.nodeData[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  tileColor: myTheme.primaryColor,
                                  textColor: Colors.black,
                                  title: const Text('Last feedback', style: TextStyle(fontSize: 10)),
                                  subtitle: Text(
                                    formatDateTime(payloadProvider.nodeData[index].lastFeedbackReceivedTime),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.solar_power_outlined, color: primaryColorDark),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${payloadProvider.nodeData[index].slrVolt} - V',
                                        style: const TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.battery_3_bar_rounded, color: primaryColorDark),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${payloadProvider.nodeData[index].batVolt} - V',
                                        style: const TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        tooltip: 'Serial set for all Relay',
                                        onPressed: () {
                                          Map<String, dynamic> payLoadFinal = {
                                            "2300": [
                                              {"2301": "${payloadProvider.nodeData[index].serialNumber}"},
                                            ]
                                          };
                                          validatePayloadSent(
                                              dialogContext: context,
                                              context: context,
                                              mqttPayloadProvider: payloadProvider,
                                              acknowledgedFunction: () {
                                                sentToServer('Serial set for the ${payloadProvider.nodeData[index].deviceName} all Relay', payLoadFinal);
                                                showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Serial set for all Relay successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                              },
                                              payload: payLoadFinal,
                                              payloadCode: '2300',
                                              deviceId: '${overAllPvd.imeiNo}'
                                          );
                                          // MQTTManager().publish(
                                          //     payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                                          // GlobalSnackBar.show(
                                          //     context, 'Your comment sent successfully', 200);
                                        },
                                        icon: const Icon(Icons.fact_check_outlined, color: Colors.teal),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    if (payloadProvider.nodeData[index].rlyStatus.isNotEmpty ||
                                        payloadProvider.nodeData[index].sensor.isNotEmpty)
                                      const SizedBox(
                                        width: double.infinity,
                                        height: 20,
                                        child: Row(
                                          children: [
                                            SizedBox(width: 10),
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.green,
                                            ),
                                            SizedBox(width: 5),
                                            Text('ON', style: TextStyle(fontSize: 12)),
                                            SizedBox(width: 20),
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.black45,
                                            ),
                                            SizedBox(width: 5),
                                            Text('OFF', style: TextStyle(fontSize: 12)),
                                            SizedBox(width: 20),
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.orange,
                                            ),
                                            SizedBox(width: 5),
                                            Text('ON in OFF', style: TextStyle(fontSize: 12)),
                                            SizedBox(width: 20),
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.redAccent,
                                            ),
                                            SizedBox(width: 5),
                                            Text('OFF in ON', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      width: double.infinity,
                                      height: calculateGridHeight(payloadProvider.nodeData[index].rlyStatus.length),
                                      child: GridView.builder(
                                        itemCount: payloadProvider.nodeData[index].rlyStatus.length, // Number of items in the grid
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 7,
                                          crossAxisSpacing: 5.0,
                                          mainAxisSpacing: 5.0,
                                          childAspectRatio: 1.2,
                                        ),
                                        itemBuilder: (BuildContext context, int indexGv) {
                                          return Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 13,
                                                backgroundColor: payloadProvider.nodeData[index].rlyStatus[indexGv]
                                                    .status ==
                                                    0
                                                    ? Colors.grey
                                                    : payloadProvider.nodeData[index].rlyStatus[indexGv].status ==
                                                    1
                                                    ? Colors.green
                                                    : payloadProvider.nodeData[index].rlyStatus[indexGv]
                                                    .status ==
                                                    2
                                                    ? Colors.orange
                                                    : payloadProvider.nodeData[index].rlyStatus[indexGv]
                                                    .status ==
                                                    3
                                                    ? Colors.redAccent
                                                    : Colors.black12, // Avatar background color
                                                child: Text(
                                                  (payloadProvider.nodeData[index].rlyStatus[indexGv].rlyNo)
                                                      .toString(),
                                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                (payloadProvider.nodeData[index].rlyStatus[indexGv].name)
                                                    .toString(),
                                                style:
                                                const TextStyle(color: Colors.black, fontSize: 10),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8, right: 8),
                                      child: Divider(
                                        thickness: 0.5,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: calculateGridHeight(payloadProvider.nodeData[index].sensor.length),
                                      child: GridView.builder(
                                        itemCount: payloadProvider.nodeData[index].sensor.length, // Number of items in the grid
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 7,
                                          crossAxisSpacing: 5.0,
                                          mainAxisSpacing: 5.0,
                                          childAspectRatio: 1.2,
                                        ),
                                        itemBuilder: (BuildContext context, int indexSnr) {
                                          return Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 13,
                                                backgroundColor: Colors.black38,
                                                child: Text(
                                                  (payloadProvider.nodeData[index].sensor[indexSnr].angIpNo !=
                                                      null
                                                      ? 'A-${payloadProvider.nodeData[index].sensor[indexSnr].angIpNo}'
                                                      : 'P-${payloadProvider.nodeData[index].sensor[indexSnr].pulseIpNo}')
                                                      .toString(),
                                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                                ),
                                              ),
                                              Text(
                                                (payloadProvider.nodeData[index].sensor[indexSnr].name).toString(),
                                                style: const TextStyle(color: Colors.black, fontSize: 10),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        if(index == payloadProvider.nodeData.length - 1)
                          SizedBox(
                            height: 50,
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: customBoxShadow
            ),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.keyboard_double_arrow_left),
                Text('Go Back'),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    ):
    Container(
        height: MediaQuery.sizeOf(context).height,
        width: 400,
        color: Colors.white,
        child: const Center(child: Text('Loading data...'))
    );
  }

  void sentToServer(String msg, dynamic payLoad) async
  {
    Map<String, Object> body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.imeiNo, "messageStatus": msg, "data": payLoad, "hardware": payLoad, "createUser": overAllPvd.userId};
    final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> validatePayloadSent({
    required BuildContext dialogContext,
    required BuildContext context,
    required MqttPayloadProvider mqttPayloadProvider,
    required void Function() acknowledgedFunction,
    required Map<String, dynamic> payload,
    required String payloadCode,
    required String deviceId
  }) async {
    try {
      await MQTTManager().publish(jsonEncode(payload), "AppToFirmware/$deviceId");

      bool isAcknowledged = false;
      int maxWaitTime = 10;
      int elapsedTime = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Please wait..."),
                ],
              ),
            ),
          );
        },
      );

      while (elapsedTime < maxWaitTime) {
        await Future.delayed(const Duration(seconds: 1));
        elapsedTime++;

        if (mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['PayloadCode'] == payloadCode) {
          isAcknowledged = true;
          break;
        }
      }

      Navigator.of(context).pop();

      if (isAcknowledged) {
        if (mqttPayloadProvider.messageFromHw['Code'] == "200") {
          acknowledgedFunction();
        } else {
          showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']}", context: context);
        }
      } else {
        showAlertDialog(message: "Controller is not responding", context: context);
      }
    } catch (error, stackTrace) {
      Navigator.of(context).pop();
      print(stackTrace);
      showAlertDialog(message: error.toString(), context: context);
    }
  }

  double calculateDynamicHeight(NodeModel node) {
    double baseHeight = 115;
    double additionalHeight = 0;

    if (node.rlyStatus.isNotEmpty) {
      additionalHeight += calculateGridHeight(node.rlyStatus.length);
    }
    if (node.sensor.isNotEmpty) {
      additionalHeight += calculateGridHeight(node.sensor.length);
    }
    return baseHeight + additionalHeight;
  }

  double calculateGridHeight(int itemCount) {
    int rows = (itemCount / 7).ceil();
    return rows * 45;
  }
  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return "No feedback received";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Invalid date format";
    }
  }
}
