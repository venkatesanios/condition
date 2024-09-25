import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../Models/Customer/system_definition_model.dart';
import '../constants/http_service.dart';

class SystemDefinitionProvider extends ChangeNotifier{
  final HttpService httpService = HttpService();
  int _selectedSegment = 0;
  bool enableAll = false;

  int get selectedSegment => _selectedSegment;

  void updateSelectedSegment(int newIndex) {
    _selectedSegment = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  List<IrrigationLineSystemData>? _irrigationLineSystemData;
  List<IrrigationLineSystemData>? get irrigationLineSystemData => _irrigationLineSystemData;
  int _selectedIrrigationLine = 0;
  int get selectedIrrigationLine => _selectedIrrigationLine;

  void updateSelectedProgramCategory(int newIndex) {
    _selectedIrrigationLine = newIndex;
    notifyListeners();
  }

  Future<void> getUserPlanningSystemDefinition(userId, controllerId) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };
      var getUserPlanningSystemDefinition = await httpService.postRequest('getUserPlanningSystemDefinition', userData);
      if(getUserPlanningSystemDefinition.statusCode == 200) {
        final responseJson = getUserPlanningSystemDefinition.body;
        final convertedJson = jsonDecode(responseJson);
        List<dynamic> result = convertedJson['data'];
        _irrigationLineSystemData = result.map((e) => IrrigationLineSystemData.fromJson(e)).toList();
        if(_irrigationLineSystemData != null && _irrigationLineSystemData!.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            if(_irrigationLineSystemData!.every((element) => element.systemDefinition.irrigationLineOn == true)){
              enableAll = true;
            }
          });
        }
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e, stackTrace) {
      log('Error: $e');
      log('stackTrace: $stackTrace');
      rethrow;
    }
    Future.delayed(Duration.zero, (){
      notifyListeners();
    });
  }

  List<String> options = ["Reset", "Queue", "Irrigation"];

  void updateCheckBoxesForOption(newValue, selectedOption, index, lineIndex) {
    if (newValue) {
      _irrigationLineSystemData![lineIndex].powerOffRecovery.selectedOption.add(selectedOption);
    } else {
      _irrigationLineSystemData![lineIndex].powerOffRecovery.selectedOption.remove(selectedOption);
    }
    notifyListeners();
  }

  void updateDayTimeRange(DayTimeRange dayTimeRange, String newFrom, String newTo) {
    dayTimeRange.from = newFrom;
    dayTimeRange.to = newTo;
    notifyListeners();
  }

  List<String> days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
  List daysFromAndToTimes({required int lineIndex}) {
    return [
      irrigationLineSystemData![lineIndex].systemDefinition.sunday,
      irrigationLineSystemData![lineIndex].systemDefinition.monday,
      irrigationLineSystemData![lineIndex].systemDefinition.tuesday,
      irrigationLineSystemData![lineIndex].systemDefinition.wednesday,
      irrigationLineSystemData![lineIndex].systemDefinition.thursday,
      irrigationLineSystemData![lineIndex].systemDefinition.friday,
      irrigationLineSystemData![lineIndex].systemDefinition.saturday,
    ];
  }
  List<String> values = ["1", "2", "3", "4", "5", "6", "7"];
  List<bool> isSelectedList({required int lineIndex}) {
    return [
      irrigationLineSystemData![lineIndex].systemDefinition.sunday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.monday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.tuesday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.wednesday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.thursday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.friday.selected,
      irrigationLineSystemData![lineIndex].systemDefinition.saturday.selected,
    ];
  }

  bool sunday = false;
  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;

  void updateCheckBoxes(day, newValue, lineIndex) {
    switch(day) {
      case "1": irrigationLineSystemData![lineIndex].systemDefinition.sunday.selected =  newValue;
      break;
      case "2": irrigationLineSystemData![lineIndex].systemDefinition.monday.selected = newValue;
      break;
      case "3": irrigationLineSystemData![lineIndex].systemDefinition.tuesday.selected = newValue;
      break;
      case "4": irrigationLineSystemData![lineIndex].systemDefinition.wednesday.selected = newValue;
      break;
      case "5": irrigationLineSystemData![lineIndex].systemDefinition.thursday.selected = newValue;
      break;
      case "6": irrigationLineSystemData![lineIndex].systemDefinition.friday.selected = newValue;
      break;
      case "7": irrigationLineSystemData![lineIndex].systemDefinition.saturday.selected = newValue;
      break;
    }
    notifyListeners();
  }

// dynamic dataToMqtt() {
//   String convertTo24HourFormat(String time12Hour) {
//     List<String> components = time12Hour.split(' ');
//     String timePart = components[0];
//     String period = components[1];
//
//     List<String> timeComponents = timePart.split(':');
//     int hour = int.parse(timeComponents[0]);
//     int minute = int.parse(timeComponents[1]);
//
//     if (period == 'PM' && hour < 12) {
//       hour += 12;
//     } else if (period == 'AM' && hour == 12) {
//       hour = 0;
//     }
//
//     String formattedHour = hour.toString().padLeft(2, '0');
//     String formattedMinute = minute.toString().padLeft(2, '0');
//
//     return '$formattedHour:$formattedMinute:00';
//   }
//   return [
//     _energySaveSettings!.energySaveFunction ? 1 : 0,
//     _energySaveSettings!.startDayTime != "00:00" ? convertTo24HourFormat(_energySaveSettings!.startDayTime) : "00:00:00",
//     _energySaveSettings!.stopDayTime != "00:00" ? convertTo24HourFormat(_energySaveSettings!.stopDayTime) : "00:00:00",
//     _energySaveSettings!.pauseMainLine ? 1 : 0,
//     _energySaveSettings!.sunday.selected ? 1 : 0,
//     _energySaveSettings!.sunday.from != "00:00" ? convertTo24HourFormat(_energySaveSettings!.sunday.from) : "00:00:00",
//     _energySaveSettings!.sunday.to != "00:00" ? convertTo24HourFormat(_energySaveSettings!.sunday.to) : "00:00:00",
//   ];
// }
}