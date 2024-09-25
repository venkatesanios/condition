import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_view/screens/NewPreference/settings_screen.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:provider/provider.dart';

import '../../constants/MQTTManager.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../../state_management/preference_provider.dart';

class ViewSettings extends StatefulWidget {
  final int userId, controllerId;
  const ViewSettings({super.key, required this.userId, required this.controllerId});

  @override
  State<ViewSettings> createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {

  late MqttPayloadProvider mqttPayloadProvider;
  late PreferenceProvider preferenceProvider;
  late OverAllUse overAllPvd;
  Timer? timer;
  Timer? dialogTimer;
  bool showCannotCommunicateMessage = false;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    requestViewSettings();
  }

  @override
  void dispose() {
    timer?.cancel();
    dialogTimer?.cancel();
    super.dispose();
  }

  Future<void> requestViewSettings() async {
    setState(() {
      mqttPayloadProvider.viewSettingsList = [];
      showCannotCommunicateMessage = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      MQTTManager().publish(jsonEncode({
        "sentSms": "viewconfig"
      }), "AppToFirmware/${overAllPvd.imeiNo}");
    }).then((value) {
      preferenceProvider.getUserPreference(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId);
    });

    timer = Timer(const Duration(seconds: 20), () {
      if (mqttPayloadProvider.viewSettingsList.isEmpty) {
        retryRequest();
      } else {
        setState(() {
          showCannotCommunicateMessage = false;
        });
      }
    });
  }

  void retryRequest() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          timer?.cancel();
          dialogTimer = Timer(const Duration(seconds: 10), () {
            Navigator.of(context).pop();
            setState(() {
              if(mqttPayloadProvider.viewSettingsList.isEmpty) {
                showCannotCommunicateMessage = true;
              } else {
                showCannotCommunicateMessage = false;
              }
            });
          });
          return AlertDialog(
              title: const Text("Warning!", style: TextStyle(color: Colors.red),),
              content: Text('${mqttPayloadProvider.getAppConnectionState == MQTTConnectionState.connected ? "Controller is not responding" : mqttPayloadProvider.getAppConnectionState.name.toUpperCase()}. Retrying...')
          );
        }
    );
    requestViewSettings();
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: true);
    if (showCannotCommunicateMessage) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("View settings"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sorry! Cannot communicate", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              ElevatedButton(
                onPressed: (){
                  retryRequest();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }
    if(mqttPayloadProvider.viewSettingsList.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("View settings"),
        ),
        // body: buildWidget(),
        body: SettingsScreen(viewSettings: true, value: "hello", userId: widget.userId,),
        floatingActionButton: MaterialButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          elevation: 15,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          onPressed: () {
            // requestViewSettings();
            // getValue();
            print(mqttPayloadProvider.viewSettingsList);
          },
          child: Text("Request again".toUpperCase()),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("View settings"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
  }

  void getValue() {
    for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++) {
      var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
      for (var element in decodedList) {
        Map<String, dynamic> decode = element;
        decode.forEach((key, value) {
          print("$key ==> $value");
        });
      }
    }
  }

  Widget buildWidget() {
    return Column(
      children: [
        for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++)
          if (i == 0)
            Column(
              children: [
                for (var j = 0; j < mqttPayloadProvider.viewSettingsList[i].length; j++)
                  Text(mqttPayloadProvider.viewSettingsList[i][j].toString())
              ],
            )
          else
            Text(mqttPayloadProvider.viewSettingsList[i].toString()),
      ],
    );
  }
}
