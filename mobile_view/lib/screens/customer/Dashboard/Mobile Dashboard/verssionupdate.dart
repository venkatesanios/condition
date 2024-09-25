import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/controllerlogfile.dart';

import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../constants/snack_bar.dart';
import '../../../../constants/theme.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../../../state_management/overall_use.dart';
import 'package:provider/provider.dart';

import '../../../../widget/validateMqtt.dart';

class ResetVerssion extends StatefulWidget {
  @override
  _ResetVerssionState createState() => _ResetVerssionState();
}

class _ResetVerssionState extends State<ResetVerssion> {

  List<Map<String, dynamic>> mergedList = [];
  late MqttPayloadProvider mqttPayloadProvider;
  String statusStr = 'Status';
  IconData iconData = Icons.start;
  Color iconcolor = Colors.transparent;
  String imeicheck = '' ;
  int checkrst = 0 ;


  valAssing(List<dynamic> data )
  {
    mergedList = [];
    for (var group in data) {
      var userGroupId = group['userGroupId'];
      var groupName = group['groupName'];
      var active = group['active'];
      var masterList = group['master'];

      for (var device in masterList) {
        mergedList.add({
          'userGroupId': userGroupId,
          'groupName': groupName,
          'active': active,
          'controllerId': device['controllerId'],
          'deviceId': device['deviceId'],
          'deviceName': device['deviceName'],
          'categoryId': device['categoryId'],
          'categoryName': device['categoryName'],
          'modelId': device['modelId'],
          'modelName': device['modelName'],
          'latestVersion': device['latestVersion'] ?? '',
          'currentVersion': device['currentVersion'] ?? '',
        });
      }
    }
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    Map<String, Object> body = {
      "userId": overAllPvd.userId
    };
    final response = await HttpService()
        .postRequest("getUserDeviceFirmwareDetails", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata = jsonDecode(response.body);
        valAssing(jsondata['data']);
        MQTTManager().connect();
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    fetchData();
  }


  ResetAll()   async{

    statusStr = 'Started';
    iconData = Icons.restart_alt;
    iconcolor = Colors.blue;
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    Map<String, dynamic> payLoadFinal = {
      "5700": [
        {"5701": "2"},
      ]
    };

    MQTTManager().publish(jsonEncode(payLoadFinal), "AppToFirmware/${overAllPvd.imeiNo}");
  }
  Update() async{
    statusStr = 'Started';
    iconData = Icons.start;
    iconcolor = Colors.blue;
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    Map<String, dynamic> payLoadFinal = {
      "5700": [
        {"5701": "3"},
      ]
    };
    MQTTManager().publish(jsonEncode(payLoadFinal), "AppToFirmware/${overAllPvd.imeiNo}");

    GlobalSnackBar.show(context,  mqttPayloadProvider.messageFromHw, 200);
    // MQTTManager().publish(payLoadFinal, 'OroGemLog/${overAllPvd.imeiNo}');

    // if (MQTTManager().isConnected == true) {
    // await validatePayloadSent(
    // dialogContext: context,
    // context: context,
    // mqttPayloadProvider: mqttPayloadProvider,
    // acknowledgedFunction: (){},
    // payload: payLoadFinal,
    // payloadCode: '4200',
    // deviceId: overAllPvd.imeiNo);
    // } else {
    // GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    // }
  }
  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    status();
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(
        title: Text('Controller Info'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 40,
              mainAxisSpacing: 40,
            ),
            padding: EdgeInsets.all(10),
            itemCount: mergedList.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10,),
                        Text(
                          mergedList[index]['categoryName']!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade100)),
                          onPressed:
                              (){
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => controllerlog(),
                                ),
                              );
                            });
                          },
                          icon: Icon(Icons.arrow_circle_right_outlined),
                        ),
                      ],
                    ),
                    Container(height: 1,color: Colors.black,),
                    SizedBox(height: 20,),
                    Text(
                      mergedList[index]['deviceId']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('SiteName:${mergedList[index]['groupName'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),

                    SizedBox(height: 10),
                    Text('Model:${mergedList[index]['modelName'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10),
                    Text('Controller version:${mergedList[index]['currentVersion'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10),
                    Text('Server version:${mergedList[index]['latestVersion']!}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10),
                    imeicheck != mergedList[index]['deviceId']! ?  statusStr != 'Status'  ? Container(
                      width: 200,
                      child:  Icon(
                        iconData,
                        color: iconcolor,
                        size: 40.0,
                      ),
                    ) : Container() : Container(),
                    imeicheck != mergedList[index]['deviceId']! ? Text('${statusStr}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),) : Text('Status'),

                    // Center(child: Text('${mqttPayloadProvider.messageFromHw ?? 'Status'} ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)),
                    Container(height: 1,color: Colors.grey,),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FilledButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                            onPressed: () => resetItem(index),
                            child: Text('Restart'),
                          ),
                          SizedBox(width: 10),

                          FilledButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                            onPressed: () => updateItem(index),
                            child: mergedList[index]['currentVersion'] !=
                                mergedList[index]['latestVersion']
                                ? const BlinkingText(
                              text: 'Update!', // Provide text here
                              style: TextStyle(color: Colors.white),
                              blinkDuration: Duration(milliseconds: 500),
                            )
                                : Text("Update"),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  status()
  {
    Map<String, dynamic>? ctrldata = mqttPayloadProvider.messageFromHw;
    if((ctrldata != null && ctrldata.isNotEmpty))
    {
      var name = ctrldata['Name'];
      // String message = ctrldata['Message'];
      var code = ctrldata['Code'];
      // imeicheck = ctrldata['DeviceId'];
      if(name.contains('Started') )
      {
        statusStr = 'Started';
        iconData = Icons.start;
        iconcolor = Colors.blue;
      }
      else if(name.contains('Restarting') )
      {

        statusStr = 'Restarting...';
        iconData = Icons.incomplete_circle;
        iconcolor = Colors.teal;
      }
      else if(name.contains('Turned') )
      {
        iconData = Icons.check_circle;
        statusStr = checkrst == 0 ? 'Last update:${ctrldata['Time']}' : 'Last Restart:${ctrldata['Time']}';
        iconcolor = Colors.green;
        // checkrst = 0;
        // startDelay();
      }
      else if(name.contains('wrong') )
      {
        statusStr = '${ctrldata['Message']}';
        iconData = Icons.error;
        iconcolor = Colors.red;
      }
      else
      {
        statusStr = 'Status';
        iconcolor = Colors.transparent;
      }
    }

  }
// void startDelay() async {
//   await Future.delayed(Duration(seconds: 0));
//      print('status--------------------------------startDelay------_>');
//     statusStr = 'Status';
//  }






  void resetItem(int index) {
    setState(() {
      _showDialogcheck(context,"Restart");

    });
  }
  void updateItem(int index) {
    setState(() {
      _showDialogcheck(context,"Update");

    });
  }

  void _showDialogcheck(BuildContext context , String update) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text("Are you sure you want to $update?\n First, stop. If you confirm that you want to stop, then update your controller by clicking the 'Sure' button."),
          actions: [
            TextButton(

              onPressed: () {
                update == "Update" ?  Update() :  ResetAll();
                Navigator.of(context).pop();
              },
              child: Text('Sure'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration blinkDuration;

  const BlinkingText({
    Key? key,
    required this.text,
    this.style = const TextStyle(fontSize: 20, color: Colors.red),
    this.blinkDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.blinkDuration,
      reverseDuration: widget.blinkDuration,
    )..repeat(reverse: true);

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
