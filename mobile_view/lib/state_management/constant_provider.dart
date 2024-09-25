import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConstantProvider extends ChangeNotifier{
  List<String> myTabs = ['General','Pump','Lines','Main valve','Valve','Water meter','Fertilizers','EC/PH','Analog sensor','Moisture sensor','Level sensor','Normal Alarm','Critical Alarm','Global Alarm','Finish'];
  List<dynamic> myTabsUpdated = [];
  List<dynamic> generalUpdated = [
    {
      'name' : 'Reset Time',
      'value' : '00:00:00',
      'type' : 3
    },
    {
      'name' : 'Fertilizer Leakage Limit',
      'value' : '20',
      'type' : 1
    },
    {
      'name' : 'Run List Limit',
      'value' : '10',
      'type' : 1
    },
    {
      'name' : 'No Pressure Delay',
      'value' : '00:00:00',
      'type' : 3
    },
    {
      'name' : 'Water pulse before dosing',
      'value' : 'Yes',
      'type' : 2
    },
    {
      'name' : 'Common dosing coefficient',
      'value' : '100',
      'type' : 1
    },
    {
      'name' : 'Lora Key 1',
      'value' : '1',
      'type' : 1
    },
    {
      'name' : 'Lora Key 2',
      'value' : '2',
      'type' : 1
    },
  ];


  int selected = -1;
  int autoIncrement = 0;
  dynamic APIdata = {};
  dynamic APIpump = [];
  dynamic APIagitator = [];
  dynamic APIselector = [];
  dynamic APItankFloat = [];
  List<Map<String,dynamic>> irrigationLineUpdated = [];
  List<Map<String,dynamic>> pumpUpdated = [];
  List<Map<String,dynamic>> mainValveUpdated = [];
  List<Map<String,dynamic>> valveUpdated = [];
  List<Map<String,dynamic>> fertilizerUpdated = [];
  List<Map<String,dynamic>> ecPhUpdated = [];
  List<Map<String,dynamic>> waterMeterUpdated = [];
  List<Map<String,dynamic>> filterUpdated = [];
  List<Map<String,dynamic>> analogSensorUpdated = [];
  List<Map<String,dynamic>> moistureSensorUpdated = [];
  List<Map<String,dynamic>> levelSensorUpdated = [];
  List<dynamic> alarmUpdated = [];
  List<dynamic> criticalAlarmUpdated = [];
  List<dynamic> globalAlarmUpdated = [];
  List<dynamic> alarmType = [];
  Map<String,dynamic> setting = {};
  int wantToSendData = 0;
  String flag = '';
  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }

  String dropDownValue = 'Stop Irrigation';
  void editDropDownValue(String val){
    dropDownValue = val;
    notifyListeners();
  }

  String lineBehavior(String value){
    switch(value){
      case ('IGNORE'):{
        return '1';
      }
      case ('DO NEXT'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String mvMode(String value){
    switch(value){
      case ('NO DELAY'):{
        return '1';
      }
      case ('OPEN BEFORE'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String AStype(String value){
    switch(value){
      case ('Pressure IN'):{
        return '1';
      }
      case ('Pressure OUT'):{
        return '2';
      }
      case ('EC'):{
        return '3';
      }
      case ('PH'):{
        return '4';
      }
      case ('Level'):{
        return '5';
      }
      case ('Valve Pressure'):{
        return '6';
      }
      case ('Soil Moisture'):{
        return '7';
      }
      default :{
        return '8';
      }
    }
  }
  String AStUnit(String value){
    switch(value){
      case ('Bar'):{
        return '1';
      }
      case ('dS/m'):{
        return '2';
      }

      default :{
        return '3';
      }
    }
  }
  String ASDS(String value){
    switch(value){
      case ('Built- in Cloud'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }

  String ASbase(String value){
    switch(value){
      case ('current'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }
  void fetchSettings(dynamic data){
    generalUpdated = data['general'].isNotEmpty ? data['general'] : generalUpdated;
    flag = data['controllerReadStatus'];
    setting['line'] = {};
    for(var il in data['line']){
      setting['line']['${il['sNo']}'] = il;
    }
    setting['mainValve'] = {};
    for(var il in data['mainValve']){
      setting['mainValve']['${il['sNo']}'] = il;
    }
    setting['valve'] = {};
    for(var il in data['valve']){
      for(var vl in il['valve']){
        setting['valve']['${vl['sNo']}'] = vl;
      }
    }
    setting['waterMeter'] = {};
    for(var wm in data['waterMeter']){
      setting['waterMeter']['${wm['sNo']}'] = wm;
    }
    setting['fertilization'] = {};
    setting['inj'] = {};
    for(var fertSite in data['fertilization']){
      setting['fertilization']['${fertSite['sNo']}'] = fertSite;
      for(var fert in fertSite['fertilizer']){
        setting['inj']['${fert['sNo']}'] = fert;
      }
    }
    setting['filtration'] = {};
    for(var il in data['filtration']){
      setting['filtration']['${il['sNo']}'] = il;
    }
    setting['ecPh'] = {};
    for(var fertSite in data['ecPh']){
      for(var stg in fertSite['setting']){
        setting['ecPh']['${fertSite['sNo']}${stg['name']}'] = stg;
      }
    }
    setting['analogSensor'] = {};
    for(var il in data['analogSensor']){
      setting['analogSensor']['${il['sNo']}'] = il;
    }
    setting['pump'] = {};
    for(var il in data['pump']){
      setting['pump']['${il['sNo']}'] = il;
    }
    setting['moistureSensor'] = {};
    for(var il in data['moistureSensor']){
      setting['moistureSensor']['${il['sNo']}'] = il;
    }
    setting['levelSensor'] = {};
    for(var il in data['levelSensor']){
      setting['levelSensor']['${il['sNo']}'] = il;
    }
    setting['normalAlarm'] = {};
    for(var il in data['normalAlarm']){
      setting['normalAlarm']['${il['sNo']}'] = {};
      for(var st in il['alarm']){
        setting['normalAlarm']['${il['sNo']}']['${st['name']}'] = {};
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo'] = {};
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['sNo'] = st['sNo'] ?? editAutoIncrement();
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['scanTime'] = st['scanTime'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['alarmOnStatus'] = st['alarmOnStatus'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['resetAfterIrrigation'] = st['resetAfterIrrigation'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['autoResetDuration'] = st['autoResetDuration'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['threshold'] = st['threshold'];
      }
    }
    setting['criticalAlarm'] = {};
    for(var il in data['criticalAlarm']){
      setting['criticalAlarm']['${il['sNo']}'] = {};
      for(var st in il['alarm']){
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}'] = {};
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo'] = {};
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['sNo'] = st['sNo'] ?? editAutoIncrement();
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['scanTime'] = st['scanTime'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['alarmOnStatus'] = st['alarmOnStatus'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['resetAfterIrrigation'] = st['resetAfterIrrigation'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['autoResetDuration'] = st['autoResetDuration'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['sNo']['threshold'] = st['threshold'];
      }
    }
    setting['globalAlarm'] = {};
    for(var gm in data['globalAlarm']){
      setting['globalAlarm']['${gm['sNo']}'] = gm['value'];
    }
    notifyListeners();
  }
  void fetchAll(dynamic data){
    irrigationLineUpdated = [];
    pumpUpdated = [];
    mainValveUpdated = [];
    valveUpdated = [];
    waterMeterUpdated = [];
    fertilizerUpdated = [];
    ecPhUpdated = [];
    filterUpdated = [];
    analogSensorUpdated = [];
    moistureSensorUpdated = [];
    levelSensorUpdated = [];
    alarmUpdated = [];
    criticalAlarmUpdated = [];
    globalAlarmUpdated = [];
    alarmType = [];
    autoIncrement = 0;
    for(var i in data.entries){
      if(i.key == 'constant'){
        APIdata = i.value;
      }
      if(i.key == 'irrigationPump'){
        APIpump = [for(var i in i.value) i['id']];
      }
      if(i.key == 'agitator'){
        APIagitator = [for(var i in i.value) i['hid']];
      }
      if(i.key == 'selector'){
        APIselector = [for(var i in i.value) i['hid']];
      }
      if(i.key == 'tankFloat'){
        APItankFloat = [for(var i in i.value) i['hid']];
      }
      if(i.key == 'default'){
        for(var j in i.value.entries){

          if(j.key == 'alarm'){
            for(var at in j.value){
              alarmType.add(at);
            }
          }
          else if(j.key == 'line'){
            // if(j.value.length != 0){
            //   // myTabs.add('Lines');
            // }
            //TODO: generating line
            for(var line in j.value){
              for(var j in alarmType){
                autoIncrement += 1;
              }
            }
            for(var line in j.value){
              var type = [];
              var criticalType = [];

              for(var at in alarmType){
                int commonSerialNo = 0;
                if(setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['sNo'] == null){
                  commonSerialNo = editAutoIncrement();
                }
                type.add({
                  'name' : '${at['name']}',
                  'sNo' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['sNo'] ?? commonSerialNo,
                  'scanTime' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['scanTime'] ?? '00:00:00',
                  'alarmOnStatus' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['alarmOnStatus'] ?? 'Do Nothing',
                  'resetAfterIrrigation' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['resetAfterIrrigation'] ?? 'Yes',
                  'autoResetDuration' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['autoResetDuration'] ?? '00:00:00',
                  'threshold' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['threshold'] ?? '0',
                  'unit' : '${at['unit']}',
                });
                criticalType.add({
                  'name' : '${at['name']}',
                  'sNo' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['sNo'] ?? commonSerialNo,
                  'scanTime' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['scanTime'] ?? '00:00:00',
                  'alarmOnStatus' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['alarmOnStatus'] ?? 'Do Nothing',
                  'resetAfterIrrigation' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['resetAfterIrrigation'] ?? 'Yes',
                  'autoResetDuration' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['autoResetDuration'] ?? '00:00:00',
                  'threshold' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['sNo']?['threshold'] ?? '0',
                  'unit' : '${at['unit']}',
                });
              }
              alarmUpdated.add({
                'sNo' : line['sNo'],
                'id' : line['id'],
                'hid' : line['hid'],
                'name' : line['name'],
                'alarm' : type,
              });
              criticalAlarmUpdated.add({
                'sNo' : line['sNo'],
                'id' : line['id'],
                'hid' : line['hid'],
                'name' : line['name'],
                'alarm' : criticalType,
              });

              print('critical Completed');
              irrigationLineUpdated.add({
                'sNo' : line['sNo'],
                'id' : line['id'],
                'hid' : line['hid'],
                'name' : line['name'],
                'location' : line['location'],
                // 'pump' : setting['line']?['${line['sNo']}']?['irrigationPump'] ?? line['irrigationPump'][0]['id'],
                'lowFlowDelay' : setting['line']?['${line['sNo']}']?['lowFlowDelay'] ?? '00:00:00',
                'highFlowDelay' : setting['line']?['${line['sNo']}']?['highFlowDelay'] ?? '00:00:00',
                'lowFlowBehavior' : setting['line']?['${line['sNo']}']?['lowFlowBehavior'] ?? 'Ignore',
                'highFlowBehavior' : setting['line']?['${line['sNo']}']?['highFlowBehavior'] ?? 'Ignore',
                'leakageLimit' : setting['line']?['${line['sNo']}']?['leakageLimit'] ?? '0',
              });

              //TODO: generating mainValve
              for(var mv in line['mainValve']){
                mainValveUpdated.add({
                  'sNo' : mv['sNo'],
                  'name' : mv['name'],
                  'id' : mv['id'],
                  'hid' : mv['hid'],
                  'location' : line['id'],
                  'mode' : setting['mainValve']?['${mv['sNo']}']?['mode'] ?? 'No delay',
                  'delay' : setting['mainValve']?['${mv['sNo']}']?['delay'] ?? '00:00:00',
                });
              }
              print('main valve Completed');
              //TODO: generating moistureSensor
              for(var ms in line['moistureSensor']){
                moistureSensorUpdated.add({
                  'sNo' : ms['sNo'],
                  'name' : ms['name'],
                  'id' : ms['id'],
                  'hid' : ms['hid'],
                  'location' : line['id'],
                  'high/low' : setting['moistureSensor']?['${ms['sNo']}']?['high/low'] ?? '-',
                  'units' : setting['moistureSensor']?['${ms['sNo']}']?['units'] ?? 'bar',
                  'base' : setting['moistureSensor']?['${ms['sNo']}']?['base'] ?? 'Current',
                  'minimum' : setting['moistureSensor']?['${ms['sNo']}']?['minimum'] ?? '0.00',
                  'maximum' : setting['moistureSensor']?['${ms['sNo']}']?['maximum'] ?? '0.00',
                  'valve' : setting['moistureSensor']?['${ms['sNo']}']?['valve'] ?? '',
                });
              }
              print('moisture Completed');
              //TODO: generating levelSensor
              for(var ls in line['levelSensor']){
                levelSensorUpdated.add({
                  'sNo' : ls['sNo'],
                  'id' : ls['id'],
                  'hid' : ls['hid'],
                  'name' : ls['name'],
                  'location' : line['id'],
                  'high/low' : setting['levelSensor']?['${ls['sNo']}']?['high/low'] ?? '-',
                  'units' : setting['levelSensor']?['${ls['sNo']}']?['units'] ?? 'bar',
                  'base' : setting['levelSensor']?['${ls['sNo']}']?['base'] ?? 'Current',
                  'minimum' : setting['levelSensor']?['${ls['sNo']}']?['minimum'] ?? '0.00',
                  'maximum' : setting['levelSensor']?['${ls['sNo']}']?['maximum'] ?? '0.00',
                  'height' : setting['levelSensor']?['${ls['sNo']}']?['height'] ?? '0.00',
                });
              }
              print('level Completed');
              //TODO: generating valve
              var valve = [];
              for(var v in line['valve']){
                valve.add({
                  'sNo' : v['sNo'],
                  'name' : v['name'],
                  'id' : v['id'],
                  'hid' : v['hid'],
                  'location' : v['location'],
                  'defaultDosage' : setting['valve']?['${v['sNo']}']?['defaultDosage'] ?? 'Time',
                  'nominalFlow' : setting['valve']?['${v['sNo']}']?['nominalFlow'] ?? '100',
                  'minimumFlow' : setting['valve']?['${v['sNo']}']?['minimumFlow'] ?? '75',
                  'maximumFlow' : setting['valve']?['${v['sNo']}']?['maximumFlow'] ?? '125',
                  'fillUpDelay' : setting['valve']?['${v['sNo']}']?['fillUpDelay'] ?? '00:00:00',
                  'area' : setting['valve']?['${v['sNo']}']?['area'] ?? '0.00',
                  'cropFactor' : setting['valve']?['${v['sNo']}']?['cropFactor'] ?? '0',
                });
              }
              valveUpdated.add({
                'sNo' : line['sNo'],
                'id' : line['id'],
                'hid' : line['hid'],
                'name' : line['name'],
                'location' : line['location'],
                'valve' : valve,
              });
              print('valve Completed');

            }
          }
          else if(j.key == 'fertilization'){
            for(var fert in j.value){
              var fertilizer = [];
              var ecPhSetting = [];
              for(var inj in fert['fertilizer']){
                fertilizer.add({
                  'sNo' : inj['sNo'],
                  'id' : inj['id'],
                  'hid' : inj['hid'],
                  'name' : inj['name'],
                  'location' : inj['location'],
                  'fertilizerMeter' : inj['fertilizerMeter'].length != 0 ? 'yes' : 'no',
                  'ratio' : setting['inj']?['${inj['sNo']}']?['ratio'] ?? '100',
                  'shortestPulse' : setting['inj']?['${inj['sNo']}']?['shortestPulse'] ?? '1',
                  'nominalFlow' : setting['inj']?['${inj['sNo']}']?['nominalFlow'] ?? '100',
                  'injectorMode' : setting['inj']?['${inj['sNo']}']?['injectorMode'] ?? 'Regular',
                });
              }
              if(fert['ec'].length != 0){
                dynamic ecStg = {
                  'name' : 'ec',
                  'sensor' : [],
                  'active' : setting['ecPh']?['${fert['sNo']}ec']?['active'] ?? false,
                  'controlCycle' : setting['ecPh']?['${fert['sNo']}ec']?['controlCycle'] ?? '00:00:00',
                  'delta' : setting['ecPh']?['${fert['sNo']}ec']?['delta'] ?? '0.0',
                  'fineTunning' : setting['ecPh']?['${fert['sNo']}ec']?['fineTunning'] ?? '0',
                  'coarseTunning' : setting['ecPh']?['${fert['sNo']}ec']?['coarseTunning'] ?? '0.0',
                  'deadBand' : setting['ecPh']?['${fert['sNo']}ec']?['deadBand'] ?? '0.0',
                  'integ' : setting['ecPh']?['${fert['sNo']}ec']?['integ'] ?? '00:00:00',
                  'sensorList' : [],
                  'avgFilterList' : ['1','2','3','4','5','6','7','8','9','10'],
                  'senseOrAvg' : fert['ec'].length > 1 ? 'Average' : '${fert['ec'][0]['hid']}',
                  'avgFilterSpeed' : setting['ecPh']?['${fert['sNo']}ec']?['avgFilterSpeed'] ?? '1',
                  'percentage' : setting['ecPh']?['${fert['sNo']}ec']?['percentage'] ?? '100',
                  'location' : fert['location']
                };
                var sensorList = [];
                for(var ec in fert['ec']){
                  ecStg['sensor'].add(ec);
                  sensorList.add(ec['hid']);
                }
                if(fert['ec'].length > 1){
                  sensorList.add('Average');
                }
                ecStg['sensorList'] = sensorList;
                ecPhSetting.add(ecStg);
              }
              if(fert['ph'].length != 0){
                dynamic phStg = {
                  'name' : 'ph',
                  'sensor' : [],
                  'active' : setting['ecPh']?['${fert['sNo']}ph']?['active'] ?? false,
                  'controlCycle' : setting['ecPh']?['${fert['sNo']}ph']?['controlCycle'] ?? '00:00:00',
                  'delta' : setting['ecPh']?['${fert['sNo']}ph']?['delta'] ?? '0.0',
                  'fineTunning' : setting['ecPh']?['${fert['sNo']}ph']?['fineTunning'] ?? '0',
                  'coarseTunning' : setting['ecPh']?['${fert['sNo']}ph']?['coarseTunning'] ?? '0.0',
                  'deadBand' : setting['ecPh']?['${fert['sNo']}ph']?['deadBand'] ?? '0.0',
                  'integ' : setting['ecPh']?['${fert['sNo']}ph']?['integ'] ?? '00:00:00',
                  'sensorList' : [],
                  'avgFilterList' : ['1','2','3','4','5','6','7','8','9','10'],
                  'senseOrAvg' : fert['ph'].length > 1 ? 'Average' : '${fert['ph'][0]['hid']}',
                  'avgFilterSpeed' : setting['ecPh']?['${fert['sNo']}ph']?['avgFilterSpeed'] ?? '1',
                  'percentage' : setting['ecPh']?['${fert['sNo']}ph']?['percentage'] ?? '100',
                  'location' : fert['location']
                };
                var sensorList = [];

                for(var ph in fert['ph']){
                  phStg['sensor'].add(ph);
                  sensorList.add(ph['hid']);
                }
                if(fert['ph'].length > 1){
                  sensorList.add('Average');
                }
                phStg['sensorList'] = sensorList;
                ecPhSetting.add(phStg);
              }

              //TODO: generating injector
              print('phStg');
              fertilizerUpdated.add({
                'sNo' : fert['sNo'],
                'id' : fert['id'],
                'hid' : fert['hid'],
                'name' : fert['name'],
                'location' : fert['location'],
                'noFlowBehavior' : setting['fertilization']?['${fert['sNo']}']?['noFlowBehavior'] ?? 'Inform Only',
                'minimalOnTime' : setting['fertilization']?['${fert['sNo']}']?['minimalOnTime'] ?? '00:00:00',
                'minimalOffTime' : setting['fertilization']?['${fert['sNo']}']?['minimalOffTime'] ?? '00:00:00',
                'waterFlowStabilityTime' : setting['fertilization']?['${fert['sNo']}']?['waterFlowStabilityTime'] ?? '00:00:00',
                'boosterOffDelay' : setting['fertilization']?['${fert['sNo']}']?['boosterOffDelay'] ?? '00:00:00',
                'agitator' : setting['fertilization']?['${fert['sNo']}']?['agitator'] ?? (APIagitator.isEmpty ? '' : APIagitator[0]),
                'selector' : setting['fertilization']?['${fert['sNo']}']?['selector'] ?? (APIselector.isEmpty ? '' : APIselector[0]),
                'fertilizer' : fertilizer,
              });
              print('fertilizer completed');
              //TODO: generating ecPh
              if(ecPhSetting.isNotEmpty){
                ecPhUpdated.add({
                  'sNo' : fert['sNo'],
                  'id' : fert['id'],
                  'hid' : fert['hid'],
                  'name' : fert['name'],
                  'location' : fert['location'],
                  'setting' : ecPhSetting,
                });
              }
            }
            print('ecPhUpdated completed');
          }
          //TODO: generating waterMeter
          else if(j.key == 'waterMeter'){
            for(var wm in j.value){
              waterMeterUpdated.add({
                'sNo' : wm['sNo'],
                'id' : wm['id'],
                'hid' : wm['hid'],
                'name' : wm['name'],
                'location' : wm['location'],
                'ratio' : setting['waterMeter']?['${wm['sNo']}']?['ratio'] ?? '100',
                'maximumFlow' : setting['waterMeter']?['${wm['sNo']}']?['maximumFlow'] ?? '100',
              });
            }
            print('waterMeter completed');
          }
          //TODO: generating filtration
          else if(j.key == 'filtration'){
            for(var fl in j.value){
              filterUpdated.add({
                'sNo' : fl['sNo'],
                'id' : fl['id'],
                'hid' : fl['hid'],
                'name' : fl['name'],
                'location' : fl['location'],
                'dpDelay' : setting['filtration']?['${fl['sNo']}']?['dpDelay'] ?? '00:00:00',
                'loopingLimit' : setting['filtration']?['${fl['sNo']}']?['loopingLimit'] ?? '1',
                'whileFlushing' : setting['filtration']?['${fl['sNo']}']?['whileFlushing'] ?? 'Stop Irrigation',
              });
            }
            print('filtration completed');
          }
          //TODO: generating analogSensor
          else if(j.key == 'analogSensor'){
            for(var as in j.value){
              analogSensorUpdated.add({
                'sNo' : as['sNo'],
                'id' : as['id'],
                'hid' : as['hid'],
                'name' : as['name'],
                'location' : as['location'],
                'type' : setting['analogSensor']?['${as['sNo']}']?['type'] ?? 'Soil Temperature',
                'units' : setting['analogSensor']?['${as['sNo']}']?['units'] ?? 'bar',
                'base' : setting['analogSensor']?['${as['sNo']}']?['base'] ?? 'Current',
                'minimum' : setting['analogSensor']?['${as['sNo']}']?['minimum'] ?? '0.00',
                'maximum' : setting['analogSensor']?['${as['sNo']}']?['maximum'] ?? '0.00',
              });
            }
            print('analogSensor completed');
          }
          //TODO: generating pump
          else if(j.key == 'pump'){
            for(var p in j.value){
              pumpUpdated.add({
                'sNo' : p['sNo'],
                'id' : p['id'],
                'hid' : p['hid'],
                'name' : p['name'],
                'location' : p['location'],
                'range' : setting['pump']?['${p['sNo']}']?['range'] ?? '0',
                'pumpStation' : setting['pump']?['${p['sNo']}']?['pumpStation'] ?? false,
                'topTankFeet' : setting['pump']?['${p['sNo']}']?['topTankFeet'] ?? '0',
                'sumpTankLow' : setting['pump']?['${p['sNo']}']?['sumpTankLow'] ?? '-',
                'sumpTankHigh' : setting['pump']?['${p['sNo']}']?['sumpTankHigh'] ?? '-',
                'topTankLow' : setting['pump']?['${p['sNo']}']?['topTankLow'] ?? '-',
                'topTankHigh' : setting['pump']?['${p['sNo']}']?['topTankHigh'] ?? '-',
              });
            }
            print('pump completed');
          }
          else if(j.key == 'constantMenu'){
            myTabsUpdated = [];
            myTabsUpdated = j.value;
          }
        }
      }
    }
    for(var at in alarmType){
      globalAlarmUpdated.add({
        'sNo' : at['sNo'],
        'value' : setting['globalAlarm']['${at['sNo']}'] ?? at['value'],
        'name' : at['name'],
        'unit' : at['unit']
      });
    }
    print('globalAlarmUpdated completed');
    tabUpdating();
    notifyListeners();
  }

  void tabUpdating(){
    for(var tab = myTabsUpdated.length - 1;tab >= 0;tab--){
      switch(myTabsUpdated[tab]['dealerDefinitionId']){
        case(82):
          if(mayDelete(myTabsUpdated[tab],["not to delete"])){
            myTabsUpdated.removeAt(tab);
          }
        case(83):
          if(mayDelete(myTabsUpdated[tab],pumpUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(84):
          if(mayDelete(myTabsUpdated[tab],irrigationLineUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(85):
          if(mayDelete(myTabsUpdated[tab],mainValveUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(86):
          if(mayDelete(myTabsUpdated[tab],valveUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(87):
          if(mayDelete(myTabsUpdated[tab],waterMeterUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(88):
          if(mayDelete(myTabsUpdated[tab],fertilizerUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(89):
          if(mayDelete(myTabsUpdated[tab],ecPhUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(90):
          if(mayDelete(myTabsUpdated[tab],analogSensorUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(91):
          if(mayDelete(myTabsUpdated[tab],moistureSensorUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(92):
          if(mayDelete(myTabsUpdated[tab],levelSensorUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(93):
          myTabsUpdated.removeAt(tab);
        case(94):
          if(mayDelete(myTabsUpdated[tab],criticalAlarmUpdated)){
            myTabsUpdated.removeAt(tab);
          }
        case(95):
          if(mayDelete(myTabsUpdated[tab],globalAlarmUpdated)){
            myTabsUpdated.removeAt(tab);
          }
      }
    }
    myTabsUpdated.add({
      "dealerDefinitionId": 0,
      "parameter": "Finish",
      "value": "1"
    });
    notifyListeners();
  }


  bool mayDelete(data,myVariable){
    bool delete = false;
    if(myVariable.length == 0){
      delete = true;
    }
    if(data['value'] == '0'){
      delete = true;
    }
    return delete;
  }


  void generalUpdatedFunctionality(int index,String value){
    generalUpdated[index]['value'] = value;
    notifyListeners();
  }
  void globalAlarmFunctionality(int index){
    globalAlarmUpdated[index]['value'] = !globalAlarmUpdated[index]['value'];
    notifyListeners();
  }

  void irrigationLineFunctionality(dynamic list){
    irrigationLineUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }

  void mainValveFunctionality(dynamic list){
    mainValveUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }

  void valveFunctionality(dynamic list){
    valveUpdated[list[1]]['valve'][list[2]][list[0]] = list[3];
    notifyListeners();
  }
  void pumpFunctionality(dynamic list){
    pumpUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }

  void waterMeterFunctionality(dynamic list){
    waterMeterUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }

  void fertilizerFunctionality(dynamic list){
    if(list[0].contains('/')){
      var route = list[0].split('/');
      fertilizerUpdated[list[1]][route[0]][list[2]][route[1]] = list[3];
    }else{
      fertilizerUpdated[list[1]][list[0]] = list[3];
    }
    notifyListeners();
  }
  void ecPhFunctionality(dynamic list){
    ecPhUpdated[list[1]]['setting'][list[2]][list[0]] = list[3];
    notifyListeners();
  }

  void filterFunctionality(dynamic list){
    switch (list[0]){
      case ('filter_dp_delay'):{
        filterUpdated[list[1]]['dpDelay'] = list[2];
        break;
      }
      case ('filter_looping_limit'):{
        filterUpdated[list[1]]['loopingLimit'] = list[2];
        break;
      }
      case ('filter/flushing'):{
        filterUpdated[list[1]]['whileFlushing'] = list[2];
        break;
      }

    }
    notifyListeners();
  }

  void analogSensorFunctionality(dynamic list){
    analogSensorUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }
  void moistureSensorFunctionality(dynamic list){
    print('list : $list');
    moistureSensorUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }
  void levelSensorFunctionality(dynamic list){
    levelSensorUpdated[list[1]][list[0]] = list[2];
    notifyListeners();
  }
  void alarmFunctionality(dynamic list){
    alarmUpdated[list[1]]['alarm'][list[2]][list[0]] = list[3];
    if(list[0] == 'alarmOnStatus'){
      if(list[3] == 'Stop Irrigation'){
        alarmUpdated[list[1]]['alarm'][list[2]].remove('resetAfterIrrigation');
      }else if(list[3] == 'Skip Irrigation'){
        alarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'Yes';
      }else{
        alarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'No';
      }
    }
    notifyListeners();
  }
  void criticalAlarmFunctionality(dynamic list){
    criticalAlarmUpdated[list[1]]['alarm'][list[2]][list[0]] = list[3];
    if(list[0] == 'alarmOnStatus'){
      if(list[3] == 'Stop Irrigation'){
        criticalAlarmUpdated[list[1]]['alarm'][list[2]].remove('resetAfterIrrigation');
      }else if(list[3] == 'Skip Irrigation'){
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'Yes';
      }else{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'No';
      }
    }
    notifyListeners();
  }

  int returnMvMode(String name){
    if(name == 'No delay'){
      return 1;
    }else if(name == 'Open before'){
      return 2;
    }else{
      return 3;
    }
  }
  int noFlowBehavior(String name){
    if(name == 'Stop Faulty Fertilizer'){
      return 1;
    }else if(name == 'Stop Fertigation'){
      return 2;
    }else if(name == 'Stop Irrigation'){
      return 3;
    }else{
      return 4;
    }
  }
  int analogType(String name){
    if(name == 'Soil Temperature'){
      return 2;
    }else if(name == 'Soil Moisture'){
      return 1;
    }else if(name == 'Rainfall'){
      return 3;
    }else if(name == 'Windspeed'){
      return 4;
    }else if(name == 'Wind Direction'){
      return 5;
    }else if(name == 'Leaf Wetness'){
      return 6;
    }else if(name == 'Humidity'){
      return 7;
    }else if(name == 'Lux Sensor'){
      return 8;
    }else if(name == 'Co2 Sensor'){
      return 9;
    }else{
      return 10;
    }
  }

  int moistureType(String name){
    if(name == 'primary'){
      return 1;
    }else if(name == 'secondary'){
      return 2;
    }else{
      return 0;
    }
  }
  int levelType(String name){
    if(name == 'top'){
      return 1;
    }else if(name == 'middle'){
      return 2;
    }else if(name == 'bottom'){
      return 3;
    }else{
      return 0;
    }
  }

  int injectorMode(String name){
    if(name == 'Concentration'){
      return 1;
    }else if(name == 'Ec controlled'){
      return 2;
    }else if(name == 'Ph controlled'){
      return 3;
    }else if(name == 'Regular'){
      return 4;
    }else{
      return 0;
    }
  }
  int alarmBehavior(String name){
    if(name == 'Do Nothing'){
      return 1;
    }else if(name == 'Stop Irrigation'){
      return 2;
    }else if(name == 'Stop Fertigation'){
      return 3;
    }else if(name == 'Skip Irrigation'){
      return 4;
    }else{
      return 0;
    }
  }

  int alarmName(name){
    switch(name){
      case ('LOW FLOW'):{
        return 1;
      }
      case ('HIGH FLOW'):{
        return 2;
      }
      case ('NO FLOW'):{
        return 3;
      }
      case ('EC HIGH'):{
        return 4;
      }
      case ('PH LOW'):{
        return 5;
      }
      case ('PH HIGH'):{
        return 6;
      }
      case ('PRESSURE LOW'):{
        return 7;
      }
      case ('PRESSURE HIGH'):{
        return 8;
      }
      case ('NO POWER SUPPLY'):{
        return 9;
      }
      case ('NO COMMUNICATION'):{
        return 10;
      }
      case ('WRONG FEEDBACK'):{
        return 11;
      }
      case ('SUMP EMPTY'):{
        return 12;
      }
      case ('TANK FULL'):{
        return 13;
      }
      case ('LOW BATTERY'):{
        return 14;
      }
      case ('EC DIFFERENCE'):{
        return 15;
      }
      case ('PH DIFFERENCE'):{
        return 16;
      }
      default:{
        return 0;
      }

    }
  }


  //TODO: generating HW payload
  dynamic sendDataToHW(){
    var payload = {
      "300" : [
        {'301': '${1},,,,${['',null].contains(generalUpdated[6]['value']) ? 1 : int.parse(generalUpdated[6]['value'])},${['',null].contains(generalUpdated[7]['value']) ? 1 : int.parse(generalUpdated[7]['value'])}'},

      ]
    };
    var mv = '';
    for(var i in mainValveUpdated){
      mv += '${mv.isNotEmpty ? ';' : ''}${i['sNo']},${i['hid']},${returnMvMode(i['mode'])},${i['delay']}';
    }

    payload['300']?.add({'302' : mv});
    var line = '';
    for(var i in irrigationLineUpdated){
      line += '${line.isNotEmpty ? ';' : ''}${i['sNo']},${i['hid']},${0},${i['leakageLimit']}';
    }
    payload['300']?.add({'303' : line});

    var valve = '';
    for(var i in valveUpdated){
      for(var vl in i['valve']){
        valve += '${valve.isNotEmpty ? ';' : ''}${vl['sNo']},${vl['location']},${vl['hid']},${vl['defaultDosage'] == 'Time' ? 1 : 2},${double.parse(vl['nominalFlow'])},${double.parse(vl['minimumFlow'])},${double.parse(vl['maximumFlow'])},${vl['fillUpDelay']},${vl['area']},${vl['cropFactor']}';
      }
    }
    payload['300']?.add({'304' : valve});

    var wm = '';
    for(var i in waterMeterUpdated){
      wm += '${wm.isNotEmpty ? ';' : ''}${i['sNo']},'
          '${i['location']},'
          '${i['hid']},'
          '${int.parse(i['ratio'])},'
          '${int.parse(i['maximumFlow'])},'
          '${i['id'].contains('WMSP') ? 1 : i['id'].contains('WMIP') ? 2 : i['id'].contains('WMIL') ? 3 : 4}';
    }
    payload['300']?.add({'305' : wm});
    var fertilizer = '';
    for(var i in fertilizerUpdated){
      for(var fert in i['fertilizer']){
        fertilizer += '${fertilizer.isNotEmpty ? ';' : ''}'
            '${fert['sNo']},'
            '${i['hid']},'
            '${fert['hid'][fert['hid'].length - 1]},'
            '${noFlowBehavior(i['noFlowBehavior'])},'
            '${i['minimalOnTime']},'
            '${i['minimalOffTime']},'
            '${i['boosterOffDelay']},'
            '${i['agitator']},'
            '${i['waterFlowStabilityTime']},'
            '${fert['nominalFlow']},'
            '${injectorMode(fert['injectorMode'])},'
            '${fert['ratio']},'
            '${fert['shortestPulse']},'
            '${i['selector']}';
      }
    }
    payload['300']?.add({'306' : fertilizer});
    var ecPh = '';
    for(var i in ecPhUpdated){
      for(var j in i['setting']){
        ecPh += '${ecPh.isNotEmpty ? ';' : ''}'
            '${j['sensor'][0]['sNo']},'
            '${i['hid']},'
            '${j['name'] == 'ec' ? 1 : 2},'
            '${j['active'] == true ? 1 : 0},'
            '${j['controlCycle']},'
            '${double.parse(j['delta'])},'
            '${double.parse(j['fineTunning'])},'
            '${double.parse(j['coarseTunning'])},'
            '${double.parse(j['deadBand'])},'
            '${j['integ']},'
            '${j['senseOrAvg'] == 'Average' ? '${j['sensor'][0]['hid']}+${j['sensor'][1]['hid']}' : j['senseOrAvg']},'
            '${int.parse(j['avgFilterSpeed'])},'
            '${int.parse(j['percentage'])},'
            '${j['location'].split('&').join('_')}' ;
      }
    }
    payload['300']?.add({'307' : ecPh});
    var as = '';
    for(var i in analogSensorUpdated){
      as += '${as.isNotEmpty ? ';' : ''}${i['sNo']},${i['hid']},${analogType(i['type'])},${i['units'] == 'bar' ? 1 : 2},${i['base'] == 'Voltage' ? 1 : 0},${double.parse(i['minimum'])},${double.parse(i['maximum'])}';
    }
    payload['300']?.add({'308' : as});

    var ms = '';
    for(var i in moistureSensorUpdated){
      ms += '${ms.isNotEmpty ? ';' : ''}'
          '${i['sNo']},'
          '${i['hid']},'
          '${i['location']},'
          '${moistureType(i['high/low'])},'
          '${i['units'] == 'bar' ? 1 : 2},'
          '${i['base'] == 'Voltage' ? 1 : 0},'
          '${double.parse(i['minimum'])},'
          '${double.parse(i['maximum'])},'
          '${i['valve']}';
    }
    payload['300']?.add({'309' : ms});


    var ls = '';
    for(var i in levelSensorUpdated){
      ls += '${ls.isNotEmpty ? ';' : ''}'
          '${i['sNo']},'
          '${i['hid']},'
          '${i['location']},'
          '${levelType(i['high/low'])},'
          '${i['units'] == 'bar' ? 1 : 2},'
          '${i['base'] == 'Voltage' ? 1 : 0},'
          '${double.parse(i['minimum'])},'
          '${double.parse(i['maximum'])},'
          '${double.parse(i['height'])}';
    }
    payload['300']?.add({'310' : ls});

    var nAlarm = '';
    var cAlarm = '';
    var nTypeCount = 0;
    for(var i = 0;i < alarmUpdated.length;i++){
      var type = alarmUpdated[i]['alarm'];
      var typeC = criticalAlarmUpdated[i]['alarm'];
      for(var j = 0;j < type.length;j++){
        nTypeCount = nTypeCount + 1;
        nAlarm += '${nAlarm.isNotEmpty ? ';' : ''}'
            '${i+1}.${j+1},'
            '${alarmUpdated[i]['hid']},${j+1},'
            '${type[j]['scanTime']},${alarmBehavior(type[j]['alarmOnStatus'])},'
            '${type[j]['resetAfterIrrigation'] == 'Yes' ? (type[j]['alarmOnStatus'] == 'Stop Irrigation' ? 0 : 1) : 0},${type[j]['autoResetDuration']},${type[j]['threshold']}' ;

        cAlarm += '${cAlarm.isNotEmpty ? ';' : ''}'
            '${i+1}.${j+1},'
            '${criticalAlarmUpdated[i]['hid']},${j+1},'
            '${typeC[j]['scanTime']},${alarmBehavior(typeC[j]['alarmOnStatus'])},'
            '${typeC[j]['resetAfterIrrigation'] == 'Yes' ? (typeC[j]['alarmOnStatus'] == 'Stop Irrigation' ? 0 : 1) : 0},${typeC[j]['autoResetDuration']},${typeC[j]['threshold']}' ;
      }
    }
    payload['300']?.add({'311' : nAlarm});
    payload['300']?.add({'312' : cAlarm});

    var pump = '';
    for(var i in pumpUpdated){
      print('topTankHigh : ${i['topTankHigh']}');
      print('topTankLow : ${i['topTankLow']}');
      print('sumpTankHigh : ${i['sumpTankHigh']}');
      print('sumpTankLow : ${i['sumpTankLow']}');
      var useTopTankHigh = i['topTankHigh'] == '-' ? 0 : 1;
      var useTopTankLow = i['topTankLow'] == '-' ? 0 : 1;
      var useSumpTankHigh = i['sumpTankHigh'] == '-' ? 0 : 1;
      var useSumpTankLow = i['sumpTankLow'] == '-' ? 0 : 1;
      pump += '${pump.isNotEmpty ? ';' : ''}'
          '${i['sNo']},'
          '${i['hid'].contains('S') ? 1 : 2},'
          '${pumpUpdated.indexOf(i)},'
          '${i['hid']},'
          '${i['pumpStation'] == true ? 1 : 0},'
          '${i['range'] == '' ? 0 : int.parse(i['range'])},'
          '${i['topTankFeet'] == '' ? 0 : i['topTankFeet']},$useTopTankHigh,$useTopTankLow,$useSumpTankHigh,$useSumpTankLow,${i['topTankHigh']},${i['topTankLow']},${i['sumpTankHigh']},${i['sumpTankLow']}';
    }
    payload['300']?.add({'313' : pump});
    print("payload['300'] => ${payload['300']}");
    return payload;
  }

  int editAutoIncrement(){
    autoIncrement += 1;
    notifyListeners();
    return autoIncrement;
  }

}

