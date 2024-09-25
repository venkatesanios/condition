import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogProvider extends ChangeNotifier{
  Map<String,dynamic> showByLine = {
    'fullView' : {
      'single':[],
      'multiple' : [],
    },
    'graphView' : []
  };

  Map<String,dynamic> showByValve = {};

  String needToDisplay = 'line';

  dynamic showData(){
    switch (needToDisplay){
      case ('line'):{
        return showByLine;
      }
    }
  }

  Map<String,bool> checkListForLine = {};
  Map<String,bool> checkListForValve = {};
  List<String> filterListNameForLine = [];
  List<String> filterListNameForValve = [];

  void editCheckListForLine(Map<String,bool> check){
    checkListForLine = check;
    notifyListeners();
  }
  void editCheckListForValve(Map<String,bool> check){
    checkListForValve = check;
    notifyListeners();
  }

  String getLineName(list){
    var name = '';
    for(var i in list){
      name += '${name.length == 0 ? '' : ','}$i';
    }
    return name;
  }


    List<int> removeDuplicates(List<int> list) {
      Set<int> set = Set<int>.from(list); // Convert list to a set
      return set.toList(); // Convert set back to list (removes duplicates)
    }
    dynamic getStatus(code){
      String statusString = '';
      Color innerCircleColor = Colors.grey;
      switch (code.toString()) {
        case "0":
          innerCircleColor = Colors.grey;
          statusString = "Pending";
          break;
        case "1":
          innerCircleColor = Colors.orange;
          statusString = "Running";
          break;
        case "2":
          innerCircleColor = Colors.green;
          statusString = "Completed";
          break;
        case "3":
          innerCircleColor = Colors.yellow;
          statusString = "Skipped by user";
          break;
        case "4":
          innerCircleColor = Colors.orangeAccent;
          statusString = "Day schedule pending";
          break;
        case "5":
          innerCircleColor = const Color(0xFF0D5D9A);
          statusString = "Day schedule running";
          break;
        case "6":
          innerCircleColor = Colors.yellowAccent;
          statusString = "Day schedule completed";
          break;
        case "7":
          innerCircleColor = Colors.red;
          statusString = "Day schedule skipped";
          break;
        case "8":
          innerCircleColor = Colors.redAccent;
          statusString = "Postponed partially to tomorrow";
          break;
        case "9":
          innerCircleColor = Colors.green;
          statusString = "Postponed fully to tomorrow";
          break;
        case "10":
          innerCircleColor = Colors.amberAccent;
          statusString = "RTC off time reached";
          break;
        case "11":
          innerCircleColor = Colors.amber;
          statusString = "RTC max time reached";
          break;
        default:
          throw Exception("Unsupported status code: $code");
      }
      return {'status' : statusString,'color':innerCircleColor};
    }
    void getDataByLine(dynamic data){
      var filterList = [];
      var lineData = {
        'single':[],
        'multiple' : [],
      };
      List<String> listOfValvePresent = [];
      for(var i in data['data']){
        //TODO: line loop and taking valve list
        for(var seq in i['irrigation']){
          listOfValvePresent.addAll(seq['SequenceData'].contains('+') ? seq['SequenceData'].split('+') : seq['SequenceData']);
          List<int> currentList = [];
          for(var plus in seq['SequenceData'].split('+')){
            currentList.add(int.parse(plus.split('.')[1]));
          }
          currentList = removeDuplicates(currentList);
          if(!filterList.contains(currentList.toString())){
            filterList = [...filterList,currentList.toString()];
          }
          if(currentList.length == 1){
            lineData['single']?.add({
              'line' : getLineName(currentList),
              'controllerDate' : i['controllerDate'],
              'SequenceData' : seq['SequenceData'],
              'ZoneName' : seq['ZoneName'],
              'Pump' : seq['Pump'],
              'IrrigationMethod' : seq['IrrigationMethod'] == 1 ? 'Time' : 'Quantity',
              'IrrigationDuration_Quantity' : seq['IrrigationDuration_Quantity'],
              'IrrigationDurationCompleted' : seq['IrrigationDurationCompleted'],
              'Status' : getStatus(seq['Status'])['status'],
              'colorCode' : getStatus(seq['Status'])['color'],
              'CentralFertilizerSite' : seq['CentralFertilizerSite'],
            });
          }else{
            lineData['multiple']?.add({
              'line' : getLineName(currentList),
              'controllerDate' : i['controllerDate'],
              'SequenceData' : seq['SequenceData'],
              'ZoneName' : seq['ZoneName'],
              'Pump' : seq['Pump'],
              'IrrigationMethod' : seq['IrrigationMethod'] == 1 ? 'Time' : 'Quantity',
              'IrrigationDuration_Quantity' : seq['IrrigationDuration_Quantity'],
              'IrrigationDurationCompleted' : seq['IrrigationDurationCompleted'],
              'Status' : getStatus(seq['Status'])['status'],
              'colorCode' : getStatus(seq['Status'])['color'],
              'CentralFertilizerSite' : seq['CentralFertilizerSite'],
            });
          }
        }
      }
      lineData['single']?.sort((a, b) => a['line'][0].compareTo(b['line'][0]));
      showByLine['fullView']['single'] = lineData['single'];
      showByLine['fullView']['multiple'] = lineData['multiple'];
      for(var i = 0;i < showByLine['fullView']['single'].length;i++){
        if(!filterListNameForLine.contains(showByLine['fullView']['single'][i]['line'])){
          showByLine['graphView'].add({
            'name' : showByLine['fullView']['single'][i]['line'],
            'data' : []
          });
          filterListNameForLine.add(showByLine['fullView']['single'][i]['line']);
          checkListForLine[showByLine['fullView']['single'][i]['line']] = true;
        }
        for(var gv in showByLine['graphView']){
          if(gv['name'] == showByLine['fullView']['single'][i]['line']){
            gv['data'].add(showByLine['fullView']['single'][i]);
          }
        }
      }
      for(var i = 0;i < showByLine['fullView']['multiple'].length;i++){
        if(!filterListNameForLine.contains(showByLine['fullView']['multiple'][i]['line'])){
          showByLine['graphView'].add({
            'name' : showByLine['fullView']['multiple'][i]['line'],
            'data' : []
          });
          filterListNameForLine.add('multiple');
          checkListForLine['multiple'] = true;
        }
        for(var gv in showByLine['graphView']){
          if(gv['name'] == showByLine['fullView']['single'][i]['line']){
            gv['data'].add(showByLine['fullView']['single'][i]);
          }
        }
      }
      listOfValvePresent = listOfValvePresent.toSet().toList();
      filterListNameForValve = listOfValvePresent;
      for(var vl in listOfValvePresent){
        checkListForValve['$vl'] = true;
        showByValve['$vl'] = [];
      }
      //TODO: valve loop
      for(var valve = 0;valve < listOfValvePresent.length;valve++){
        var count = 0;
        for(var i in data['data']){
          for(var seq in i['irrigation']){
            if(seq['SequenceData'].contains(listOfValvePresent[valve])){
              count += 1;
              showByValve['${listOfValvePresent[valve]}'].add(
                {
                  'count' : '$count',
                  'valve' : listOfValvePresent[valve],
                  'controllerDate' : i['controllerDate'],
                  'SequenceData' : seq['SequenceData'],
                  'ZoneName' : seq['ZoneName'],
                  'Pump' : seq['Pump'],
                  'IrrigationMethod' : seq['IrrigationMethod'] == 1 ? 'Time' : 'Quantity',
                  'IrrigationDuration_Quantity' : seq['IrrigationDuration_Quantity'],
                  'IrrigationDurationCompleted' : seq['IrrigationDurationCompleted'],
                  'Status' : getStatus(seq['Status'])['status'],
                  'colorCode' : getStatus(seq['Status'])['color'],
                  'CentralFertilizerSite' : seq['CentralFertilizerSite'],
                }
              );
            }
          }
        }
      }

      print(showByValve);
      notifyListeners();
    }
  }