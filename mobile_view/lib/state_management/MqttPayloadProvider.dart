import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/state_management/schedule_view_provider.dart';
import '../Models/Customer/node_model.dart';
import '../Models/PumpControllerModel/pump_controller_data_model.dart';
import '../Models/Weather_model.dart';
import '../constants/data_convertion.dart';
import '../constants/notifi_service.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  WeatherModel weatherModelinstance = WeatherModel();

  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;
  PumpControllerData? pumpControllerData;
  PumpControllerData? get dataModel => pumpControllerData;
  List<NodeModel> nodeData = <NodeModel>[];
  Map<String, dynamic> pumpControllerPayload = {};
  Map<String, dynamic> preferencePayload = {};
  List viewSettingsList = [];
  bool isCommunicatable = false;

  //Todo : Dashboard start
  int tryingToGetPayload = 0;
  dynamic wifiStrength = '';
  String version = '';
  int powerSupply = 0;
  dynamic listOfSite = [];
  dynamic listOfSharedUser = {};
  bool httpError = false;
  String selectedSiteString = '';
  int selectedSite = 0;
  int selectedMaster = 0;
  int selectedLine = 0;
  List<dynamic> nodeDetails = [];
  dynamic messageFromHw;
  List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  List<dynamic> nextSchedule = [];
  List<dynamic> upcomingProgram = [];
  List<dynamic> filtersCentral = [];
  List<dynamic> filtersLocal = [];
  List<dynamic> irrigationPump = [];
  List<dynamic> sourcePump = [];
  List<dynamic> fertilizerCentral = [];
  List<dynamic> fertilizerLocal = [];
  List<dynamic> flowMeter = [];
  List<dynamic> alarmList = [];
  List<dynamic> waterMeter = [];
  List<dynamic> sensorInLines = [];
  List<dynamic> lineData = [];
  String subscribeTopic = '';
  String publishTopic = '';
  String publishMessage= '';
  bool loading = false;
  int active = 1;
  Timer? timerForIrrigationPump;
  Timer? timerForSourcePump;
  Timer? timerForCentralFiltration;
  Timer? timerForLocalFiltration;
  Timer? timerForCentralFertigation;
  Timer? timerForLocalFertigation;
  Timer? timerForCurrentSchedule;
  int selectedCurrentSchedule = 0;
  int selectedNextSchedule = 0;
  int selectedProgram = 0;
  DateTime lastUpdate = DateTime.now();
  String sheduleLog = '';
  String uardLog = '';
  String uard0Log = '';
  String uard4Log = '';

  void editLoading(bool value){
    loading = value;
    notifyListeners();
  }

  void editPublishMessage(String message){
    publishMessage = message;
    notifyListeners();
  }

  void editSubscribeTopic(String topic){
    subscribeTopic = topic;
    notifyListeners();
  }

  void editPublishTopic(String topic){
    publishTopic = topic;
    notifyListeners();
  }

  void editLineData(dynamic data){
    // // print('editLineData : ${data}');
    lineData = [];
    for(var i in data){
      lineData.add(i);
    }
    lineData.insert(0,{'id' : 'All','location' : '','mode' : 0,'name' : 'All line','mainValve' : [],'valve' : []});
    for(var i in lineData){
      i['mode'] = 0;
    }
    notifyListeners();
  }

  void updateCurrentSchedule()async{
    if(timerForCurrentSchedule != null){
      timerForCurrentSchedule!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForCurrentSchedule = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in currentSchedule){
        if(i['Message'] == 'Running.'){
          if(i['OnDelayTime'] == '00:00:00'){
            if('${i['Duration_Qty']}'.contains(':')){
              int onDelay = dataConvert.parseTimeString(i['Duration_Qty']);
              int onDelayCompleted = dataConvert.parseTimeString(i['Duration_QtyCompleted']);
              int leftDelay = onDelay - onDelayCompleted;
              i['Duration_QtyLeft'] = dataConvert.formatTime(leftDelay);
              if(leftDelay > 0){
                onDelayCompleted += 1;
                i['Duration_QtyCompleted'] = dataConvert.formatTime(onDelayCompleted);
              }
            }else{
              if(i['Duration_QtyLeft'] > 0.0){
                i['Duration_QtyLeft'] = i['Duration_Qty'] - i['Duration_QtyCompleted'];
                i['Duration_QtyCompleted']  = i['Duration_QtyCompleted'] + double.parse(i['AverageFlowRate']);
              }
            }
          }
        }
        notifyListeners();
      }
    });

  }

  void updateLocalFertigationSite(){
    if(timerForLocalFertigation != null){
      timerForLocalFertigation!.cancel();
    }
    int seconds = 0;
    DataConvert dataConvert = DataConvert();
    timerForLocalFertigation = Timer.periodic(Duration(milliseconds: 100), (Timer timer){
      if(seconds == 1000){
        seconds = 0;
      }else{
        seconds += 100;
      }
      if(fertilizerLocal.any((element) => element['Fertilizer'].any((fert) => dataConvert.parseTimeStringForMilliSeconds(fert['Duration']) != dataConvert.parseTimeStringForMilliSeconds(fert['DurationCompleted'])))){
        for(var i in fertilizerLocal) {
          if (i['Fertilizer'].any((element) => element['Status'] != 0)){
            for(var channel in i['Fertilizer']){
              if(channel['Status'] != 0){
                int onDelay = dataConvert.parseTimeStringForMilliSeconds(channel['Duration']);
                if(channel['DurationCompleted'] == null){
                  channel['DurationCompleted'] = '00:00:00:000';
                }
                int onDelayCompleted = dataConvert.parseTimeStringForMilliSeconds(channel['DurationCompleted']);
                int leftDelay = onDelay - onDelayCompleted;
                channel['DurationLeft'] = dataConvert.formatTimeForMilliSeconds(leftDelay);
                if(leftDelay > 0){
                  onDelayCompleted += 100;
                  if(['1','2'].contains(channel['FertMethod'])){
                    if(channel['Status'] == 1){
                      channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                      if(channel['QtyLeft'] > 0.0){
                        channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                        channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                      }
                    }
                  }
                  else if(['3','4','5'].contains(channel['FertMethod'])){
                    if(channel['onOffMode'] == null){
                      channel['onOffMode'] = 1;
                      channel['onOffValue'] = 0;
                    }
                    if(channel['onOffMode'] == 1){
                      channel['onOffValue'] += 100;
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = channel['proportionalStatus'];
                      }
                      if(channel['proportionalStatus'] == 1){
                        channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                        if(channel['QtyLeft'] > 0.0){
                          channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                          channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                        }
                      }
                      if(channel['onOffValue'] == (double.parse(channel['OnTime']) * 1000)){
                        channel['onOffMode'] = 0;
                        channel['onOffValue'] = 0;
                      }
                    }else{
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = 4;
                      }
                      channel['onOffValue'] += 100;
                      if(channel['onOffValue'] == (double.parse(channel['OffTime']) * 1000)){
                        channel['onOffMode'] = 1;
                        channel['onOffValue'] = 0;
                      }
                    }
                  }

                }else{
                  channel['DurationCompleted'] = channel['Duration'];
                }
                notifyListeners();
              }
            }

          }
        }
      }
      // else{
      //   if(timerForLocalFertigation != null){
      //     timerForLocalFertigation!.cancel();
      //   }
      // }
    });
  }

  void updateCentralFertigationSite(){
    if(timerForCentralFertigation != null){
      timerForCentralFertigation!.cancel();
    }
    int seconds = 0;
    DataConvert dataConvert = DataConvert();
    timerForCentralFertigation = Timer.periodic(Duration(milliseconds: 100), (Timer timer){
      if(seconds == 1000){
        seconds = 0;
      }else{
        seconds += 100;
      }
      if(fertilizerCentral.any((element) => element['Fertilizer'].any((fert) => dataConvert.parseTimeStringForMilliSeconds(fert['Duration']) != dataConvert.parseTimeStringForMilliSeconds(fert['DurationCompleted'])))){
        for(var i in fertilizerCentral) {
          if (i['Fertilizer'].any((element) => element['Status'] != 0)){
            for(var channel in i['Fertilizer']){
              if(channel['Status'] != 0){
                int onDelay = dataConvert.parseTimeStringForMilliSeconds(channel['Duration']);
                if(channel['DurationCompleted'] == null){
                  channel['DurationCompleted'] = '00:00:00:000';
                }
                int onDelayCompleted = dataConvert.parseTimeStringForMilliSeconds(channel['DurationCompleted']);
                int leftDelay = onDelay - onDelayCompleted;
                channel['DurationLeft'] = dataConvert.formatTimeForMilliSeconds(leftDelay);
                if(leftDelay > 0){
                  onDelayCompleted += 100;
                  if(['1','2'].contains(channel['FertMethod'])){
                    if(channel['Status'] == 1){
                      channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                      if(channel['QtyLeft'] > 0.0){
                        channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                        channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                      }
                    }
                  }
                  else if(['3','4','5'].contains(channel['FertMethod'])){
                    if(channel['onOffMode'] == null){
                      channel['onOffMode'] = 1;
                      channel['onOffValue'] = 0;
                    }
                    if(channel['onOffMode'] == 1){
                      channel['onOffValue'] += 100;
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = channel['proportionalStatus'];
                      }
                      if(channel['proportionalStatus'] == 1){
                        channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                        if(channel['QtyLeft'] > 0.0){
                          channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                          channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                        }
                      }
                      if(channel['onOffValue'] == (double.parse(channel['OnTime']) * 1000)){
                        channel['onOffMode'] = 0;
                        channel['onOffValue'] = 0;
                      }
                    }else{
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = 4;
                      }
                      channel['onOffValue'] += 100;
                      if(channel['onOffValue'] == (double.parse(channel['OffTime']) * 1000)){
                        channel['onOffMode'] = 1;
                        channel['onOffValue'] = 0;
                      }
                    }
                  }
                }else{
                  channel['DurationCompleted'] = channel['Duration'];
                }
                notifyListeners();
              }
            }

          }
        }
      }
    });
  }

  void updateCentralFiltrationSite(){
    if(timerForCentralFiltration != null){
      timerForCentralFiltration!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForCentralFiltration = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in filtersCentral){
        if(i['Status'] != 0 && i['Program'] != ''){
          int onDelay = dataConvert.parseTimeString(i['Duration']);
          if(i['DurationCompleted'] == null){
            i['DurationCompleted'] = '00:00:00';
          }
          int onDelayCompleted = dataConvert.parseTimeString(i['DurationCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['DurationLeft'] = dataConvert.formatTime(leftDelay);
          // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => OnDelayLeft : ${i['DurationLeft']}');
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
            // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => DurationCompleted : ${i['DurationCompleted']}');
          }else{
            i['DurationCompleted'] = '00:00:00';
            timerForCentralFiltration!.cancel();
          }
        }
      }

    });
  }

  void updateLocalFiltrationSite(){
    if(timerForLocalFiltration != null){
      timerForLocalFiltration!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForLocalFiltration = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in filtersLocal){
        if(i['Status'] != 0 && i['Program'] != ''){
          int onDelay = dataConvert.parseTimeString(i['Duration']);
          if(i['DurationCompleted'] == null){
            i['DurationCompleted'] = '00:00:00';
          }
          int onDelayCompleted = dataConvert.parseTimeString(i['DurationCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['DurationLeft'] = dataConvert.formatTime(leftDelay);
          // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => OnDelayLeft : ${i['DurationLeft']}');
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
            // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => DurationCompleted : ${i['DurationCompleted']}');
          }else{
            i['DurationCompleted'] = '00:00:00';
            timerForLocalFiltration!.cancel();
          }
        }
      }

    });
  }

  void updateIrrigationPump(){
    if(timerForIrrigationPump != null){
      timerForIrrigationPump!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForIrrigationPump = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in irrigationPump){
        if(i['Status'] == 0 && i['Program'] != ''){
          if(i['OnDelay'] != i['OnDelayCompleted']){
            int onDelay = dataConvert.parseTimeString(i['OnDelay']);
            int onDelayCompleted = dataConvert.parseTimeString(i['OnDelayCompleted']);
            int leftDelay = onDelay - onDelayCompleted;
            i['OnDelayLeft'] = dataConvert.formatTime(leftDelay);
            // // // print('${i['Name']} => OnDelayLeft : ${i['OnDelayLeft']}');
            if(leftDelay > 0){
              onDelayCompleted += 1;
              i['OnDelayCompleted'] = dataConvert.formatTime(onDelayCompleted);
              // // // print('${i['Name']} => OnDelayCompleted : ${i['OnDelayCompleted']}');
            }else{
              i['OnDelayCompleted'] = '00:00:00';
            }
          }
        }
      }
      if(irrigationPump.every((element) => element['OnDelayCompleted'] == '00:00:00')){
        timerForIrrigationPump!.cancel();
      }
    });

  }

  void clearData() {
    listOfSite = [];
    listOfSharedUser = {};
    currentSchedule = [];
    PrsIn = [];
    PrsOut = [];
    nextSchedule = [];
    selectedLine = 0;
    selectedSite = 0;
    selectedMaster = 0;
    upcomingProgram = [];
    filtersCentral = [];
    filtersLocal = [];
    irrigationPump = [];
    sourcePump = [];
    fertilizerCentral = [];
    fertilizerLocal = [];
    flowMeter = [];
    alarmList = [];
    waterMeter = [];
    sensorInLines = [];
    lineData = [];
    loading = false;
    active = 1;
    if(timerForIrrigationPump != null){
      timerForIrrigationPump!.cancel();
      timerForSourcePump!.cancel();
      timerForCentralFiltration!.cancel();
      timerForLocalFiltration!.cancel();
      timerForCentralFertigation!.cancel();
      timerForLocalFertigation!.cancel();
      timerForCurrentSchedule!.cancel();
    }

    selectedCurrentSchedule = 0;
    selectedNextSchedule = 0;
    selectedProgram = 0;
    pumpControllerData = null;
    lastUpdate = DateTime.now();
    notifyListeners();
  }

  void updateSourcePump(){
    if(timerForSourcePump != null){
      timerForSourcePump!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForSourcePump = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in sourcePump){
        if(i['Status'] == 0 && i['Program'] != ''){
          int onDelay = dataConvert.parseTimeString(i['OnDelay']);
          int onDelayCompleted = dataConvert.parseTimeString(i['OnDelayCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['OnDelayLeft'] = dataConvert.formatTime(leftDelay);
          // // // print('${i['Name']} => OnDelayLeft : ${i['OnDelayLeft']}');
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['OnDelayCompleted'] = dataConvert.formatTime(onDelayCompleted);
            // // // print('${i['Name']} => OnDelayCompleted : ${i['OnDelayCompleted']}');
          }else{
            i['OnDelayCompleted'] = '00:00:00';
          }
        }
      }
      if(sourcePump.every((element) => element['OnDelayCompleted'] == '00:00:00')){
        timerForSourcePump!.cancel();
      }
    });

  }

  void updateReceivedPayload(String payload,bool dataFromHttp) async{
    // // print('payload comming....');
    // // print(dataFromHttp);
    // // print(isCommunicatable);
    if(!dataFromHttp) {
      isCommunicatable = true;
    } else {
      isCommunicatable = false;
    }
    try {
      // Todo : Dashboard payload start
      Map<String, dynamic> data = jsonDecode(payload);
      // // print('payload data = ${data}');
      if(data['liveSyncDate'] != null){
        String dateStr = data['liveSyncDate'];
        String timeStr = data['liveSyncTime'];
        // Parse date string
        List<String> dateParts = dateStr.split("-");
        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);

        // Parse time string
        List<String> timeParts = timeStr.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        int second = int.parse(timeParts[2]);
        lastUpdate = DateTime(year, month, day, hour, minute, second);
      }else{
        lastUpdate = DateTime.now();
      }
      if(data.containsKey('4200')){
        //conformation message form gem or gem+ to every customer action
        messageFromHw = data['4200'][0]['4201'];
      }
      if(data.containsKey('cM')){
        messageFromHw = data;
      }
      //Controller Log
      if(data.containsKey('6600')) {
        if (data['6600'].containsKey('6601')) {
          sheduleLog += "\n";
          sheduleLog += data['6600']['6601'];
        }
        if (data['6600'].containsKey('6602')) {
          uardLog += "\n";
          uardLog += data['6600']['6602'];
        }
        if (data['6600'].containsKey('6603')) {
          uard0Log += "\n";
          uard0Log += data['6600']['6603'];
        }
        if (data['6600'].containsKey('6604')) {
          uard4Log += "\n";
          uard4Log += data['6600']['6604'];
        }
      }

      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        dashBoardPayload = payload;
        if (data['2400'][0].containsKey('2401')) {
          nodeDetails = data['2400'][0]['2401'];
          for(var node in nodeDetails){
            if(dataFromHttp){
              for(var obj in node['RlyStatus']){
                obj['Status'] = 0;
              }
            }
          }
        }
        if(dataFromHttp == false){
          if (data['2400'][0].containsKey('2402')) {
            currentSchedule = data['2400'][0]['2402'];
            if(currentSchedule.length == 0){
              active = 1;
            }
            selectedCurrentSchedule = 0;
            if(currentSchedule.isNotEmpty && currentSchedule[0].containsKey('PrsIn')){
              PrsIn = currentSchedule[0]['PrsIn'];
              PrsOut = currentSchedule[0]['PrsOut'];
            }
          }
          if (data['2400'][0].containsKey('2403')) {
            nextSchedule = data['2400'][0]['2403'];
            selectedNextSchedule = 0;
            // // print('nextSchedule : $nextSchedule');
          }
        }
        if (data['2400'][0].containsKey('2404')) {
          upcomingProgram = data['2400'][0]['2404'];
          if(dataFromHttp){
            for(var program in upcomingProgram){
              program['ProgOnOff'] = 0;
              program['ProgPauseResume'] = 1;
            }
          }
          selectedProgram = 0;
          // // print('upcomingProgram : $upcomingProgram');
        }
        if (data['2400'][0].containsKey('2405')) {
          List<dynamic> filtersJson = data['2400'][0]['2405'];
          filtersCentral = [];
          filtersLocal = [];

          for (var filter in filtersJson) {
            if (filter['Type'] == 1) {
              filtersCentral.add(filter);
            } else if (filter['Type'] == 2) {
              filtersLocal.add(filter);
            }
          }

        }

        if (data['2400'][0].containsKey('2406')) {
          List<dynamic> fertilizerJson = data['2400'][0]['2406'];
          fertilizerCentral = [];
          fertilizerLocal = [];

          for (var fertilizer in fertilizerJson) {
            if (fertilizer['Type'] == 1) {
              for(var channel in fertilizer['Fertilizer']){
                channel['proportionalStatus'] = channel['Status'];
              }
              fertilizerCentral.add(fertilizer);
            } else if (fertilizer['Type'] == 2) {
              for(var channel in fertilizer['Fertilizer']){
                channel['proportionalStatus'] = channel['Status'];
              }
              fertilizerLocal.add(fertilizer);
            }
          }
        }

        if (data['2400'][0].containsKey('2407')) {
          List<dynamic> items = data['2400'][0]['2407'];
          irrigationPump = items.where((item) => item['Type'] == 2).toList();
          irrigationPump.sort((a,b) => a['S_No'].compareTo(b['S_No']));
          if(dataFromHttp){
            for(var pump in irrigationPump){
              pump['Status'] = 0;
              pump['Program'] = '';
            }
          }
          sourcePump = items.where((item) => item['Type'] == 1).toList();
          if(dataFromHttp){
            for(var pump in sourcePump){
              pump['Status'] = 0;
            }
          }
          sourcePump.sort((a,b) => a['S_No'].compareTo(b['S_No']));
        }

        if (data['2400'][0].containsKey('2408')) {
          List<dynamic> items = data['2400'][0]['2408'];
          sensorInLines = items;
          // print("sensorInLines ==> $sensorInLines");
          // print("lineData[0]['mode'] => ${lineData[0]['mode']}");
          if(sensorInLines.isNotEmpty && sensorInLines.every((element) => element['IrrigationPauseFlag'] == sensorInLines[0]['IrrigationPauseFlag'])){
            lineData[0]['mode'] = sensorInLines[0]['IrrigationPauseFlag'];
          }else{
            lineData[0]['mode']= 0;
          }
          for(var i in sensorInLines){
            for(var l = 1;l < lineData.length;l++){
              if(i['S_No'] == lineData[l]['sNo']){
                if(i['PrsIn'] != '-'){
                  for(var ps in lineData[l]['pressureSensor']){
                    // print('ps => $ps');
                    if(ps['hid'] == 'LI.${l}'){
                      ps['value'] = i['PrsIn'];
                    }
                    print('ps => $ps');
                  }
                }
                if(i['PrsOut'] != '-'){
                  for(var ps in lineData[l]['pressureSensor']){
                    if(ps['hid'] == 'LO.${l}'){
                      ps['value'] = i['PrsOut'];
                    }
                  }
                }
                // if(i['DpValue'] != '-'){
                //   lineData[l]['dpValve'][0]['value'] = i['DpValue'];
                // }
                if(i['Watermeter'] != '-'){
                  lineData[l]['waterMeter'][0]['value'] = i['Watermeter'];
                }
                lineData[l]['mode'] = i['IrrigationPauseFlag'];
                lineData[l].remove('pauseResumeCodeHomePage');
              }
            }
          }
          for(var line = 1;line < lineData.length;line++){
            for(var valve in lineData[line]['valve']){
              for(var node in nodeDetails){
                for(var object in node['RlyStatus']){
                  if(valve['sNo'] == object['S_No']){
                    valve['status'] = object['Status'];
                  }
                }
              }
            }
            for(var mainValve in lineData[line]['mainValve']){
              for(var node in nodeDetails){
                for(var object in node['RlyStatus']){
                  if(mainValve['sNo'] == object['S_No']){
                    mainValve['status'] = object['Status'];
                  }
                }
              }
            }
          }
          flowMeter.addAll(items.where((item) => item['Watermeter'] != '-').map((item) => item['Watermeter']));
          // print('flowMeter : $flowMeter');
        }

        if (data['2400'][0].containsKey('2409')) {
          alarmList = data['2400'][0]['2409'];
          // // print('alarmList ==> $alarmList');
        }
        if (data['2400'][0].containsKey('WifiStrength')) {
          wifiStrength = data['2400'][0]['WifiStrength'];
        }
        if (data['2400'][0].containsKey('Version')) {
          version = data['2400'][0]['Version'];
        }

        if (data['2400'][0].containsKey('PowerSupply')) {
          powerSupply = data['2400'][0]['PowerSupply'];
        }
        if (data['2400'][0].containsKey('2410')) {
          waterMeter = data['2400'][0]['2410'];
        }
        // Todo : Dashboard pauload stop

        if (data['2400'][0].containsKey('2401')) {
          final rawData = data['2400'][0]['2401'] as List;
          // print("rawData ==> $rawData");

          if (dataFromHttp) {
            nodeData = rawData.map((item) => NodeModel.fromJson(item)).toList();
          } else {
            nodeData = nodeData.map((node) {
              var updatedData = rawData.firstWhere(
                      (item) {
                    return item['SNo'] == node.serialNumber;
                  },
                  orElse: () => {
                    'Status': node.status,
                    'RlyStatus': node.rlyStatus.map((r) => r.toJson()).toList()
                  }
              );
              var updatedStatus = updatedData['Status'];
              var rawRlyStatus = updatedData['RlyStatus'] as List;
              List<RelayStatus> updatedRlyStatus = rawRlyStatus.map((r) => RelayStatus.fromJson(r)).toList();
              return node.updateStatusAndRlyStatus(updatedStatus, updatedRlyStatus);
            }).toList();

          }
        }

      }
      else if(data.containsKey('3600') && data['3600'] != null && data['3600'].isNotEmpty){
        mySchedule.dataFromMqttConversion(payload);
        schedulePayload = payload;
      }
      else if(data['mC'] != null && data['mC'].contains("SMS")) {
        preferencePayload = data;
      }
      else if(data['mC'] != null && data['mC'].contains("LD01")) {
        pumpControllerData = PumpControllerData.fromJson(data, "cM");
        // // print("pumpControllerData data from provider ==> ${pumpControllerData}");
      }
      else if(data['mC'] != null && data["mC"].contains("VIEW")) {
        if (!viewSettingsList.contains(jsonEncode(data['cM']))) {
          viewSettingsList.add(jsonEncode(data["cM"]));
          // // print(viewSettingsList);
        }
      }
      else if(data.containsKey('5100') && data['5100'] != null && data['5100'].isNotEmpty){
        weatherModelinstance = WeatherModel.fromJson(data);
      }

    } catch (e, stackTrace) {
      // print('Error parsing JSON: $e');
      // print('Stacktrace while parsing json : $stackTrace');
    }
    if(irrigationPump.isEmpty){
      loading = true;
    }else{
      loading = false;
    }
    tryingToGetPayload = 0;
    notifyListeners();

    for(var i in currentSchedule){
      for(var centralFilteration in filtersCentral){
        if(i['CentralFilterSite'] == centralFilteration['FilterSite']){
          centralFilteration['Program'] = i['ProgName'];
          for(var filter in centralFilteration['FilterStatus']){
            if(![1,2].contains(filter['Status'])){
              filter['Status'] = 0;
            }
          }
        }
      }
      for(var localFilteration in filtersLocal){
        if(i['LocalFilterSite'] == localFilteration['FilterSite']){
          localFilteration['Program'] = i['ProgName'];
          for(var filter in localFilteration['FilterStatus']){
            if(![1,2].contains(filter['Status'])){
              filter['Status'] = 0;
            }
          }
        }
      }
      for(var line in sensorInLines){
        if(i['ProgCategory'].split('_').contains(line['Line'])){
          line['Program'] = i['ProgName'];
        }
      }
    }
    updateSourcePump();
    updateIrrigationPump();
    updateLocalFertigationSite();
    updateCentralFertigationSite();
    updateCentralFiltrationSite();
    updateLocalFiltrationSite();
    updateCurrentSchedule();
    notifyListeners();
  }

  //Todo : Dashboard stop





  void editMySchedule(ScheduleViewProvider instance){
    mySchedule = instance;
    notifyListeners();
  }


  void updatehttpweather(Map<String, dynamic> payload)
  {
    weatherModelinstance = WeatherModel.fromJson(payload);
    notifyListeners();
  }

  Timer? _timerForPumpController;
  void updatePumpController(){
    if(_timerForPumpController != null){
      _timerForPumpController!.cancel();
    }
    _timerForPumpController = Timer.periodic(const Duration(seconds: 1), (Timer timer){
      // // print('seconds');
      for(var i in pumpControllerData!.pumps){
        // // print('pumps => ${i}');
        if(i.status == 0){
          if(i.onDelayComplete != '00:00:00' && i.onDelayLeft != '00:00:00'){

            int onDelay = DataConvert().parseTimeString(i.onDelayTimer);
            int onDelayCompleted = DataConvert().parseTimeString(i.onDelayComplete);
            int leftDelay = onDelay - onDelayCompleted;
            i.onDelayLeft = DataConvert().formatTime(leftDelay);
            if(leftDelay > 0){
              onDelayCompleted += 1;
              // // print("pump ${_dataModel!.pumps.indexOf(i)} ==> ${onDelayCompleted}");

              i.onDelayComplete = DataConvert().formatTime(onDelayCompleted);
            }else{
              i.onDelayComplete = '00:00:00';
            }
          }
        }
      }
      if(pumpControllerData!.pumps.every((element) => element.onDelayComplete == '00:00:00')){
        _timerForPumpController!.cancel();
      }

    });
  }


  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;



}