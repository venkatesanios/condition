import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../../../state_management/overall_use.dart';
import 'home_page.dart';
import 'mobile_dashboard_common_files.dart';

class DashboardPayloadHandler {
  late final MQTTManager manager;
  late final MqttPayloadProvider payloadProvider;
  late final OverAllUse overAllPvd;
  late final Function setState;
  late final BuildContext context;
  int? index;

  DashboardPayloadHandler({
    required MQTTManager manager,
    required MqttPayloadProvider payloadProvider,
    required OverAllUse overAllPvd,
    required Function setState,
    required BuildContext context,
    int? index,
  }){
    this.manager = manager;
    this.payloadProvider = payloadProvider;
    this.overAllPvd = overAllPvd;
    this.setState = setState;
    this.context = context;
    this.index = index;
  }

  void irrigationLinePauseResume()async{
    if(payloadProvider.lineData[payloadProvider.selectedLine]['pauseResumeCodeHomePage'] == null){
      var lineString = '';
      for(var i = 1;i < payloadProvider.lineData.length;i++){
        if(lineString.isNotEmpty){
          lineString += ';';
        }
        if(payloadProvider.selectedLine == 0){
          lineString += '${payloadProvider.lineData[i]['sNo']},${payloadProvider.lineData[1]['mode'] == 0 ? 1 : 0}';
        }else{
          lineString += '${payloadProvider.lineData[i]['sNo']},${i == payloadProvider.selectedLine ? (payloadProvider.lineData[i]['mode'] == 0 ? 1 : 0) : payloadProvider.lineData[i]['mode']}';
        }
      }
      var message = {
        "4900" : [
          {
            "4901" : lineString
          },
          {
            "4902" : '${overAllPvd.userId}'
          },
        ]
      };
      manager.publish(jsonEncode(message),'AppToFirmware/${overAllPvd.imeiNo}');
      try {
        var data = {
          "userId": overAllPvd.getUserId(),
          "controllerId": overAllPvd.controllerId,
          "hardware" : message,
          "messageStatus": "${payloadProvider.lineData[payloadProvider.selectedLine]['name']} ${payloadProvider.lineData[payloadProvider.selectedLine]['mode'] == 0 ? 'Resume' : 'Pause'}",
          "createUser": overAllPvd.getUserId()
        };
        final response = await HttpService().postRequest("createUserManualOperationInDashboard", data);
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
        }
      } catch (e) {
        print('Error: $e');
      }
      setState(() {
        payloadProvider.lineData[payloadProvider.selectedLine]['loading'] = true;
        payloadProvider.messageFromHw = {};
      });
      for(var seconds = 0;seconds < 8;seconds++){
        await Future.delayed(Duration(seconds: 1));
        if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
          if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '4900'){
            setState(() {
              payloadProvider.lineData[payloadProvider.selectedLine].remove('loading');
            });
            stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware received successfully');
            break;
          }
        }
        if(seconds == 7){
          setState(() {
            payloadProvider.lineData[payloadProvider.selectedLine].remove('loading');
          });
        }
      }
    }
  }

  void alarmReset() async{
    String payload =  '${payloadProvider.alarmList[index!]['S_No']}';
    String payLoadFinal = jsonEncode({
      "4100": [{"4101": payload}]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
    setState(() {
      payloadProvider.alarmList[index!]['loading'] = true;
      payloadProvider.messageFromHw = {};
    });
    for(var seconds = 0;seconds < 8;seconds++){
      await Future.delayed(Duration(seconds: 1));
      if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
        if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '4100'){
          setState(() {
            payloadProvider.alarmList[index!].remove('loading');
          });
          stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware received successfully');
          break;
        }
      }
      if(seconds == 7){
        setState(() {
          payloadProvider.alarmList[index!].remove('loading');
        });
      }
    }
  }

  void programStartStop()async{
    if(int.parse(payloadProvider.upcomingProgram[index!]['ProgOnOff']) >= 0){
      if(payloadProvider.upcomingProgram[index!]['startStopCode'] == null){
        var payload = {
          "2900": [{"2901": '${payloadProvider.upcomingProgram[index!]['SNo']},${payloadProvider.upcomingProgram[index!]['ProgOnOff']}'}]
        };
        manager.publish(jsonEncode(payload), 'AppToFirmware/${overAllPvd.imeiNo}');
        sentUserOperationToServer('${payloadProvider.upcomingProgram[index!]['ProgName']} ${programOnOff[payloadProvider.upcomingProgram[index!]['ProgOnOff']]}', payload,context);
        setState(() {
          payloadProvider.upcomingProgram[index!]['startStopCode'] = true;
          payloadProvider.messageFromHw = {};
        });
        for(var seconds = 0;seconds < 8;seconds++){
          await Future.delayed(Duration(seconds: 1));
          if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
            if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '2900'){
              setState(() {
                payloadProvider.alarmList[index!].remove('startStopCode');
              });
              stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware received successfully');
              break;
            }
          }
          if(seconds == 7){
            setState(() {
              payloadProvider.upcomingProgram[index!].remove('startStopCode');
            });
          }
        }
        Future.delayed(Duration(seconds: 8),(){
          setState(() {
            payloadProvider.upcomingProgram[index!].remove('startStopCode');
          });
        });
      }
    }
  }

  void programPauseResume()async{
    if(payloadProvider.upcomingProgram[index!]['pauseResumeCode'] == null){
      var payload = {
        "2900": [{"2901": '${payloadProvider.upcomingProgram[index!]['SNo']},${payloadProvider.upcomingProgram[index!]['ProgPauseResume']}'}]
      };
      manager.publish(jsonEncode(payload), 'AppToFirmware/${overAllPvd.imeiNo}');
      sentUserOperationToServer('${payloadProvider.upcomingProgram[index!]['ProgName']} ${payloadProvider.upcomingProgram[index!]['ProgPauseResume'] != '1' ? 'Pause' : 'Resume'} by Manual', payload,context);
    }

    setState(() {
      payloadProvider.upcomingProgram[index!]['pauseResumeCode'] = true;
      payloadProvider.messageFromHw = {};
    });

    for(var seconds = 0;seconds < 8;seconds++){
      await Future.delayed(Duration(seconds: 1));
      if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
        if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '2900'){
          setState(() {
            payloadProvider.alarmList[index!].remove('pauseResumeCode');
          });
          stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware received successfully');
          break;
        }
      }
      if(seconds == 7){
        setState(() {
          payloadProvider.upcomingProgram[index!].remove('pauseResumeCode');
        });
      }
    }
  }

  void scheduleSkip()async{
    if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['standaloneLoading'] == null){
      if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('Manual')){
        var payload = {
          "800": [{"801": '0,0,0,0'}]
        };
        MQTTManager().publish(jsonEncode(payload), 'AppToFirmware/${overAllPvd.imeiNo}');
        Map<String, dynamic> manualOperation = {
          "programName": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].split('StandAlone - ')[1],
          "programId": 0,
          "method": 1,
          "time": '00:00',
          "flow": '0',
          "selected": [],
          'fromDashboard' : true
        };
        try {
          final body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.controllerId, "manualOperation": manualOperation, "createUser": overAllPvd.userId,'hardware' : payload};
          final response = await HttpService().postRequest("createUserManualOperation", body);
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
          }
        } catch (e) {
          print('Error: $e');
        }
      }
      else if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone')){
        var programInfo = payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule];
        final programModePayload = {
          "3900": [
            {
              "3901":
              "${0},"
                  "${programInfo['ProgCategory']},"
                  "${programInfo['ProgramS_No']},"
                  "${programInfo['ZoneS_No']},"
                  ","
                  ","
                  ","
                  ","
                  ","
                  ","
                  ","
                  ","
                  "${0},"
                  ""
            },
            {
              "3902": "${overAllPvd.getUserId()}"
            }
          ]
        };
        MQTTManager().publish(jsonEncode(programModePayload), 'AppToFirmware/${overAllPvd.imeiNo}');
        Map<String, dynamic> manualOperation = {
          "programName": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].split('StandAlone - ')[1],
          "programId": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgramS_No'],
          "startFlag":0,
          "method": 1,
          "time": '00:00:00',
          "flow": '0',
          "selected": [],
          'fromDashboard' : true
        };
        try {
          final body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.controllerId, "manualOperation": manualOperation, "createUser": overAllPvd.userId,'hardware' : programModePayload};
          final response = await HttpService().postRequest("createUserManualOperation", body);
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
          }
        } catch (e) {
          print('Error: $e');
        }

      }
      else{
        var payload = {
          "3700": [{"3701": '${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ScheduleS_No']},0'},{
            "3702": "${overAllPvd.getUserId()}"
          }]
        };
        manager.publish(jsonEncode(payload), 'AppToFirmware/${overAllPvd.imeiNo}');
        try {
          var data = {
            "userId": overAllPvd.getUserId(),
            "controllerId": overAllPvd.controllerId,
            "hardware" : payload,
            "messageStatus": "${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ZoneName']} Skip",
            "createUser": overAllPvd.getUserId()
          };
          final response = await HttpService().postRequest("createUserManualOperationInDashboard", data);
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
          }
        } catch (e) {
          print('Error: $e');
        }
      }
      setState(() {
        payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['standaloneLoading'] = true;
        payloadProvider.messageFromHw = {};
      });
      for(var seconds = 0;seconds < 8;seconds++){
        await Future.delayed(Duration(seconds: 1));
        if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
          if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '2900'){
            setState(() {
              payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule].remove('standaloneLoading');
            });
            stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware received successfully');
            break;
          }
        }
        if(seconds == 7){
          setState(() {
            payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule].remove('standaloneLoading');
          });
        }
      }
    }
  }

}
