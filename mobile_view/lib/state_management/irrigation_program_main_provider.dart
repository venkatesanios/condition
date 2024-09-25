import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../Models/IrrigationModel/sequence_model.dart';
import '../constants/MQTTManager.dart';
import '../constants/data_convertion.dart';
import '../constants/http_service.dart';

class IrrigationProgramMainProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    notifyListeners();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void updateBottomNavigation(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void clearDispose() {
    // // // print("invoked");
    irrigationLine?.sequence = [];
    currentIndex = 0;
    addNext = false;
    addNew = false;
    notifyListeners();
  }

  //TODO:SEQUENCE SCREEN PROVIDER
  final HttpService httpService = HttpService();

  SequenceModel? _irrigationLine;
  SequenceModel? get irrigationLine => _irrigationLine;

  Future<void> getUserProgramSequence({required int userId, required int controllerId, required int serialNumber}) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSequence = await httpService.postRequest('getUserProgramSequence', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        Future.delayed(Duration.zero,() {
          _irrigationLine = SequenceModel.fromJson(convertedJson);
        }).then((value) {
          if(irrigationLine!.sequence.isEmpty) {
            addNewSequence(serialNumber: serialNumber, zoneSno: 1);
          }
        });
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    // notifyListeners();
  }

  //TODO:New SEQUENCE SCREEN PROVIDER
  bool reorder = false;
  void updateReorder() {
    reorder = !reorder;
    notifyListeners();
  }

  bool addNext = false;
  bool addNew = false;
  void updateCheckBoxSelection({index, newValue}) {
    irrigationLine!.sequence[index]['selected'] = newValue;
    notifyListeners();
  }

  List<String> deleteSelection = ["Select", "Select all", "Unselect all"];
  String selectedOption = "Unselect all";

  void deleteFunction({indexToShow, serialNumber}) {
    Future.delayed(Duration.zero, () {
      irrigationLine!.sequence.removeWhere((element) => element['selected'] == true);
      if(irrigationLine!.sequence.isEmpty) {
        addNewSequence(serialNumber: serialNumber, zoneSno: 1);
      }
    }).then((value) {
      addNext = false;
      for(var i = 0; i < _irrigationLine!.sequence.length; i++) {
        if(_irrigationLine!.sequence[i]['name'].contains('Sequence')) {
          _irrigationLine!.sequence[i]['name'] = 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${i+1}';
        }
      }
      // for(var i = 0; i < _irrigationLine!.sequence.length; i++) {
      //   // _irrigationLine!.sequence[i]['sNo'] = "${serialNumber == 0 ? serialNumberCreation : serialNumber}.${i+1}";
      //   // _irrigationLine!.sequence[i]['id'] = "SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${i+1}";
      //   _irrigationLine!.sequence[i]['name'] = "Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${i+1}";
      // }
      if(selectedOption == deleteSelection[1] || _irrigationLine!.sequence.isEmpty) {
        assigningCurrentIndex(0);
      } else if(selectedOption == deleteSelection[0]) {
        assigningCurrentIndex(_irrigationLine!.sequence.length-1);
      }
      selectedOption = deleteSelection[2];
    });
    print("invoked");
    notifyListeners();
  }

  void updateDeleteSelection({newOption}) {
    selectedOption = newOption;
    if(selectedOption == deleteSelection[1]) {
      for(var i = 0; i < irrigationLine!.sequence.length; i++) {
        irrigationLine!.sequence[i]['selected'] = true;
      }
    } else if(selectedOption == deleteSelection[2]){
      for(var i = 0; i < irrigationLine!.sequence.length; i++) {
        irrigationLine!.sequence[i]['selected'] = false;
      }
    }
    notifyListeners();
  }

  void updateNextButton(indexToShow) {
    // // print("indexToShow in the update next button ==> $indexToShow");
    if(indexToShow == irrigationLine!.sequence.length) {
      addNew = true;
      addNext = false;
    } else {
      addNew = false;
      addNext = true;
    }
    notifyListeners();
  }

  void updateAddNext({serialNumber, indexToShow}) {
    addNextSequence(serialNumber: serialNumber, zoneSno: irrigationLine!.sequence.length+1, indexToInsert: indexToShow);
    assigningCurrentIndex(indexToShow);
    notifyListeners();
  }

  int currentIndex = 0;
  void assigningCurrentIndex(newIndex) {
    currentIndex = newIndex;
    notifyListeners();
  }

  //TODO: adding sequence function
  void addNewSequence({int? serialNumber, zoneSno}) {
    irrigationLine!.sequence.add({
      "sNo": "${serialNumber == 0 ? serialNumberCreation : serialNumber}.$zoneSno",
      "id": 'SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$zoneSno',
      "name": 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$zoneSno',
      "selected": false,
      "selectedGroup": [],
      "modified": false,
      "location": '',
      "valve": [],
      "mainValve": []
    });
    notifyListeners();
  }

  void addNextSequence({int? serialNumber, zoneSno, indexToInsert}) {
    _irrigationLine!.sequence.insert(
        indexToInsert+1,
        {
          "sNo": "${serialNumber == 0 ? serialNumberCreation : serialNumber}.${indexToInsert+2}",
          "id": 'SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${indexToInsert+2}',
          "name": 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${indexToInsert+2}',
          "selected": false,
          "selectedGroup": [],
          "modified": false,
          "location": '',
          "valve": [],
          "mainValve": [],
        });

    for(var i = 0; i < _irrigationLine!.sequence.length; i++) {
      // print(_irrigationLine!.sequence[i]['sNo']);
      dynamic temp;
      if(!_irrigationLine!.sequence[i]['sNo'].contains("${i+1}")) {
        temp = "${i+1}";
      }
      _irrigationLine!.sequence[indexToInsert+1]['sNo'] = "${serialNumber == 0 ? serialNumberCreation : serialNumber}.${temp != null ? temp : i+1}";
      _irrigationLine!.sequence[indexToInsert+1]['id'] = "SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${temp != null ? temp : i+1}";
    }
    for(var i = 0; i < _irrigationLine!.sequence.length; i++) {
      if(_irrigationLine!.sequence[i]['name'].contains('Sequence')) {
        _irrigationLine!.sequence[i]['name'] = 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.${i+1}';
      }
      // print(_irrigationLine!.sequence[i]);
      // print("\n");
    }
    notifyListeners();
  }

  bool checkValveContainment2({valves, sequenceIndex, i, isMainValve}) {
    if(isMainValve) {
      if(irrigationLine!.sequence[sequenceIndex]['mainValve'].any((mainValve) => mainValve['sNo']! == valves[i]["sNo"])) {
        return true;
      }
    } else {
      if(irrigationLine!.sequence[sequenceIndex]['valve'].any((valve) => valve['sNo']! == valves[i]["sNo"])) {
        return true;
      }
    }
    return false;
  }

  void addValvesInSequence({
    required valves,
    int? serialNumber,
    int? sNo,
    required int lineIndex,
    required int sequenceIndex,
    required bool isMainValve,
    bool isGroup = false,
    required String groupId,
  }) {
    List<Map<String, dynamic>> valvesToAdd = [];

    for (var i = 0; i < valves.length; i++) {
      bool valveExists = checkValveContainment2(
        valves: valves,
        sequenceIndex: sequenceIndex,
        i: i,
        isMainValve: isMainValve,
      );

      if (isGroup) {
        if (!valveExists) {
          valvesToAdd.add(valves[i]);
        }
      } else {
        if (valveExists) {
          if (isMainValve) {
            irrigationLine!.sequence[sequenceIndex]["mainValve"].removeWhere((e) => e["sNo"] == valves[i]['sNo']);
          } else {
            irrigationLine!.sequence[sequenceIndex]["valve"].removeWhere((e) => e["sNo"] == valves[i]['sNo']);
          }
        }

        if (!valveExists) {
          if (isMainValve) {
            irrigationLine!.sequence[sequenceIndex]['mainValve'].add(valves[i]);
          } else {
            irrigationLine!.sequence[sequenceIndex]['valve'].add(valves[i]);
          }
        }
      }
    }

    if (isGroup) {
      if(!(irrigationLine!.sequence[sequenceIndex]['selectedGroup'].contains(groupId))) {
        irrigationLine!.sequence[sequenceIndex]['selectedGroup'].add(groupId);
        for (var valve in valvesToAdd) {
          if (!isMainValve) {
            irrigationLine!.sequence[sequenceIndex]['valve'].add(valve);
          }
        }
      } else {
        irrigationLine!.sequence[sequenceIndex]['selectedGroup'].remove(groupId);
        for (var valve in valves) {
          if (!isMainValve) {
            irrigationLine!.sequence[sequenceIndex]['valve'].removeWhere((e) => e['sNo'] == valve['sNo']);
          }
        }
      }
    }

    print(irrigationLine!.sequence[sequenceIndex]['selectedGroup']);
    print(irrigationLine!.sequence[sequenceIndex]['valve']);
    notifyListeners();
  }

  void reorderSelectedValves(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    addNext = false;
    final valve = irrigationLine!.sequence[oldIndex];
    irrigationLine!.sequence.removeAt(oldIndex);
    irrigationLine!.sequence.insert(newIndex, valve);
    currentIndex = newIndex;
    notifyListeners();
  }

  //TODO: SCHEDULE SCREEN PROVIDERS
  SampleScheduleModel? _sampleScheduleModel;
  SampleScheduleModel? get sampleScheduleModel => _sampleScheduleModel;

  int _currentRtcIndex = 0;
  int get currentRtcIndex => _currentRtcIndex;

  void updateCurrentRtcIndex(newIndex) {
    _currentRtcIndex = newIndex;
    notifyListeners();
  }

  Future<void> scheduleData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSchedule = await httpService.postRequest('getUserProgramSchedule', userData);
      if(getUserProgramSchedule.statusCode == 200) {
        final responseJson = getUserProgramSchedule.body;
        final convertedJson = jsonDecode(responseJson);
        if(convertedJson['data']['schedule'].isEmpty) {
          convertedJson['data']['schedule'] = {
            "scheduleAsRunList" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00:00", "offTime": "00:00:00", "interval": "00:00:00", "noOfCycles": "1", "maxTime": "00:00:00", "condition": false, "stopMethod": "Continuous"},
              },
              "schedule": { "noOfDays": "1", "startDate": DateTime.now().toString(), "type" : ['DO WATERING'], "endDate": DateTime.now().toString(), "isForceToEndDate": false},
            },
            "scheduleByDays" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00:00", "offTime": "00:00:00", "interval": "00:00:00", "noOfCycles": "1", "maxTime": "00:00:00", "condition": false, "stopMethod": "Continuous"},
              },
              "schedule": { "startDate": DateTime.now().toString(), "runDays": "1", "skipDays": "0", "endDate": DateTime.now().toString(), "isForceToEndDate": false}
            },
            "dayCountSchedule" : {
              "schedule": { "onTime": "00:00:00", "interval": "00:00:00", "shouldLimitCycles": false, "noOfCycles": "1"}
            },
            "selected" : "NO SCHEDULE",
          };
        }
        _sampleScheduleModel = SampleScheduleModel.fromJson(convertedJson);
      }else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }

    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateRtcProperty(newTime, selectedRtc, property, scheduleType) {
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList){
      final selectedRtcKey = sampleScheduleModel!.scheduleAsRunList.rtc.keys.toList()[selectedRtc];
      sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey][property] = newTime;
    } else {
      final selectedRtcKey = sampleScheduleModel!.scheduleByDays.rtc.keys.toList()[selectedRtc];
      sampleScheduleModel!.scheduleByDays.rtc[selectedRtcKey][property] = newTime;
      // print(sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey]['maxTime']);
    }
    notifyListeners();
  }

  String startDate({required int serialNumber}) {
    if(selectedScheduleType == scheduleTypes[1]) {
      return serialNumber == 0
          ? sampleScheduleModel!.scheduleAsRunList.schedule['startDate'] = DateTime.now().toString()
          : sampleScheduleModel!.scheduleAsRunList.schedule['startDate'];
      // return DateTime.parse(sampleScheduleModel!.scheduleAsRunList.schedule['startDate']).isBefore(DateTime.now())
      //     ? sampleScheduleModel!.scheduleAsRunList.schedule['startDate'] = DateTime.now().toString()
      //     : sampleScheduleModel!.scheduleAsRunList.schedule['startDate'];
    } else {
      return serialNumber == 0
          ? sampleScheduleModel!.scheduleByDays.schedule['startDate'] = DateTime.now().toString()
          : sampleScheduleModel!.scheduleByDays.schedule['startDate'];
      // return DateTime.parse(sampleScheduleModel!.scheduleByDays.schedule['startDate']).isBefore(DateTime.now())
      //     ? sampleScheduleModel!.scheduleByDays.schedule['startDate'] = DateTime.now().toString()
      //     : sampleScheduleModel!.scheduleByDays.schedule['startDate'];
    }
  }

  void updateDate(newDate, dateType) {
    if(selectedScheduleType == scheduleTypes[1]) {
      sampleScheduleModel!.scheduleAsRunList.schedule[dateType] = newDate.toString();
      // print(sampleScheduleModel!.scheduleAsRunList.schedule[dateType]);
    } else if(selectedScheduleType == scheduleTypes[2]) {
      sampleScheduleModel!.scheduleByDays.schedule[dateType] = newDate.toString();
    }
    notifyListeners();
  }

  void updateForceToEndDate2({required newValue}){
    if(selectedScheduleType == scheduleTypes[1]) {
      sampleScheduleModel!.scheduleAsRunList.schedule['isForceToEndDate'] = newValue;
    } else if(selectedScheduleType == scheduleTypes[2]) {
      sampleScheduleModel!.scheduleByDays.schedule['isForceToEndDate'] = newValue;
    }
    notifyListeners();
  }

  void updateNumberOfDays(newNumberOfDays, daysType, scheduleType) {
    scheduleType.schedule[daysType] = newNumberOfDays;
    notifyListeners();
  }

  List<String> scheduleTypes = ['NO SCHEDULE', 'SCHEDULE BY DAYS', 'SCHEDULE AS RUN LIST', 'DAY COUNT SCHEDULE'];

  String get selectedScheduleType => sampleScheduleModel?.selected ?? scheduleTypes[0];

  void updateSelectedScheduleType(newValue) {
    sampleScheduleModel!.selected = newValue;
    if(selectedScheduleType == scheduleTypes[1]) {
      sampleScheduleModel!.scheduleAsRunList.schedule['startDate'] = DateTime.now().toString();
    } else if(selectedScheduleType == scheduleTypes[2]) {
      sampleScheduleModel!.scheduleByDays.schedule['startDate'] = DateTime.now().toString();
    }
    notifyListeners();
  }

  void updateDayCountSchedule({required String property, required dynamic newValue}){
    sampleScheduleModel!.dayCountSchedule.schedule[property] = newValue;
    notifyListeners();
  }

  List<String> stopMethods = ["Continuous", "Off time", "Max time"];

  List<String> scheduleOptions = ['DO NOTHING', 'DO ONE TIME', 'DO WATERING', 'DO FERTIGATION'];

  void initializeDropdownValues(numberOfDays, existingDays, type) {
    if (sampleScheduleModel!.scheduleAsRunList.schedule['type'].isEmpty || int.parse(existingDays) == 0) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'] = List.generate(int.parse(numberOfDays), (index) => scheduleOptions[2]);
    } else {
      if (int.parse(numberOfDays) != int.parse(existingDays)) {
        if (int.parse(numberOfDays) < int.parse(existingDays)) {
          for (var i = 0; i < int.parse(existingDays); i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = type[i];
          }
        } else {
          var newDays = int.parse(numberOfDays) - int.parse(existingDays);
          for (var i = 0; i < newDays; i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'].add(scheduleOptions[2]);
          }
        }
      }
    }
    // print(type);
    notifyListeners();
  }

  void updateDropdownValue(index, newValue) {
    setAllSame(-1);
    if (index >= 0 && index < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'][index] = newValue;
    } else {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'].add(newValue);
    }
    notifyListeners();
  }

  int selectedButtonIndex = -1;
  void setAllSame(index) {
    bool allSame = true;
    switch(index) {
      case 0:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[0];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[0]) {
            allSame = false;
          }
        }
        break;
      case 1:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[1];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[1]) {
            allSame = false;
          }
        }
        break;
      case 2:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[2];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[2]) {
            allSame = false;
          }
        }
        break;
      case 3:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[3];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[3]) {
            allSame = false;
          }
        }
        break;
    }
    if (allSame) {
      selectedButtonIndex = index;
    }
    notifyListeners();
  }

  String? errorText;

  void validateInputAndSetErrorText(input, runListLimit) {
    if (input.isEmpty) {
      errorText = 'Please enter a value';
    } else {
      int? parsedValue = int.tryParse(input);
      if (parsedValue == null) {
        errorText = 'Please enter a valid number';
      } else if (parsedValue > (runListLimit)) {
        errorText = 'Value should not exceed $runListLimit';
      } else {
        errorText = null;
      }
    }
    notifyListeners();
  }

  //TODO: CONDITIONS PROVIDER
  SampleConditions? _sampleConditions;
  SampleConditions? get sampleConditions => _sampleConditions;
  bool conditionsLibraryIsNotEmpty = false;

  Future<void> getUserProgramCondition(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramCondition = await httpService.postRequest('getUserProgramCondition', userData);
      if(getUserProgramCondition.statusCode == 200) {
        final responseJson = getUserProgramCondition.body;
        final convertedJson = jsonDecode(responseJson);
        _sampleConditions = SampleConditions.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateConditionType(newValue, conditionTypeIndex) {
    _sampleConditions!.condition[conditionTypeIndex].selected = newValue;
    notifyListeners();
  }

  void updateConditions(title, sNo, newValue, conditionTypeIndex) {
    // // print('$title, $sNo, $newValue, $conditionTypeIndex');
    _sampleConditions!.condition[conditionTypeIndex].value = {
      "sNo": sNo,
      "name" : newValue
    };
    notifyListeners();
  }

  //TODO: WATER AND FERT PROVIDER
  int sequenceSno = 0;
  List<dynamic> sequenceData = [];
  List<dynamic> serverDataWM = [];
  List<dynamic> channelData = [];
  int selectedGroup = 0;
  int selectedCentralSite = 0;
  int selectedLocalSite = 0;
  int selectedInjector = 0;
  String waterValueInTime = '';
  String waterValueInQuantity = '';
  List<dynamic> sequence = [];
  String radio = 'set individual';
  dynamic apiData = {};
  dynamic recipe = [];
  dynamic constantSetting = {};
  dynamic fertilizerSet = [];
  int segmentedControlGroupValue = 0;
  int segmentedControlCentralLocal = 0;
  TextEditingController waterQuantity = TextEditingController();
  TextEditingController preValue = TextEditingController();
  TextEditingController postValue = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController ph = TextEditingController();
  TextEditingController channel = TextEditingController();
  TextEditingController injectorValue = TextEditingController();
  TextEditingController injectorValue_0 = TextEditingController();
  TextEditingController injectorValue_1 = TextEditingController();
  TextEditingController injectorValue_2 = TextEditingController();
  TextEditingController injectorValue_3 = TextEditingController();
  TextEditingController injectorValue_4 = TextEditingController();
  TextEditingController injectorValue_5 = TextEditingController();
  TextEditingController injectorValue_6 = TextEditingController();
  TextEditingController injectorValue_7 = TextEditingController();
  ScrollController scrollControllerGroup = ScrollController();
  ScrollController scrollControllerSite = ScrollController();
  ScrollController scrollControllerInjector = ScrollController();

  Map<int, Widget> myTabs = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Water",style: TextStyle(color: Colors.black),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Fertilizer",style: TextStyle(color: Colors.black)),
    ),
  };
  Map<int, Widget> cOrL = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Central",style: TextStyle(color: Colors.black),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Local",style: TextStyle(color: Colors.black)),
    ),
  };

  void clearWaterFert(){
    sequenceSno = 0;
    sequenceData = [];
    serverDataWM = [];
    channelData = [];
    selectedGroup = 0;
    selectedCentralSite = 0;
    selectedLocalSite = 0;
    selectedInjector = 0;
    sequence = [];
    radio = 'set individual';
    apiData = {};
    recipe = [];
    constantSetting = {};
    fertilizerSet = [];
    segmentedControlGroupValue = 0;
    segmentedControlCentralLocal = 0;
    // waterQuantity = TextEditingController();
    // preValue = TextEditingController();
    // postValue = TextEditingController();
    // ec = TextEditingController();
    // ph = TextEditingController();
    // injectorValue = TextEditingController();
    // scrollControllerGroup = ScrollController();
    // scrollControllerSite = ScrollController();
    // scrollControllerInjector = ScrollController();
    notifyListeners();
  }

  editFertilizerSet(dynamic data){
    fertilizerSet = data;
    notifyListeners();
  }

  void editSegmentedControlGroupValue(int value){
    segmentedControlGroupValue = value;
    myTabs = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Water",style: TextStyle(color: segmentedControlGroupValue == 0 ? Colors.black : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Fertilizer",style: TextStyle(color: segmentedControlGroupValue == 1 ? Colors.black : Colors.black)),
      ),
    };
    notifyListeners();
  }

  TextEditingController getInjectorController(int index){
    if(index == 0){
      return injectorValue_0;
    }
    else if(index == 1){
      return injectorValue_1;
    }
    else if(index == 2){
      return injectorValue_2;
    }
    else if(index == 3){
      return injectorValue_3;
    }
    else if(index == 4){
      return injectorValue_4;
    }
    else if(index == 5){
      return injectorValue_5;
    }
    else if(index == 6){
      return injectorValue_6;
    }
    else{
      return injectorValue_7;
    }
  }
  void editSegmentedCentralLocal(int value){
    segmentedControlCentralLocal = value;
    selectedCentralSite = 0;
    selectedLocalSite = 0;
    selectedInjector = 0;
    // // print('first');
    if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0){
      ec.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['ecValue'].toString() ?? '';
      ph.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['phValue'].toString() ?? '';
      for(var index = 0;index < sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;index++){
        getInjectorController(index).text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['quantityValue'].toString() ?? '';
      }
    }
    cOrL = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Central",style: TextStyle(color: segmentedControlCentralLocal == 0 ? Colors.black : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Local",style: TextStyle(color: segmentedControlCentralLocal == 1 ? Colors.black : Colors.black)),
      ),
    };
    notifyListeners();
  }
  var waterAndFertData = [];

  // void selectingTheSite(){
  //   if(sequenceData.isNotEmpty){
  //     0 = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] == -1 ? 0 : sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'];
  //     editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] == -1 ? 0 : sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']);
  //   }
  //   notifyListeners();
  // }

  void editApiData(dynamic value){
    // // print('api data is : ${value}');
    apiData = value;
    notifyListeners();
  }
  void editSequenceData(dynamic value){
    sequenceData = value;
    notifyListeners();
  }
  void editRecipe(dynamic value){
    if(value != null){
      recipe = value;
    }
    notifyListeners();
  }
  void editConstantSetting(dynamic value){
    constantSetting = value;
    notifyListeners();
  }
  dynamic returnSequenceDataUpdate({required central,required local,required i,required sequence,required bool newSequence}){
    // print('sequence : ${sequence}');
    String prePostMethod = 'Time';
    String preValue = '00:00:00';
    String postValue = '00:00:00';
    bool applyFertilizerForCentral = false;
    bool applyFertilizerForLocal = false;
    String moistureCondition = '-';
    dynamic moistureSno = 0;
    if(newSequence == false){
      prePostMethod = sequence[0]['prePostMethod'];
      preValue = sequence[0]['preValue'];
      postValue = sequence[0]['postValue'];
      moistureCondition = sequence[0]['moistureCondition'];
      moistureSno = sequence[0]['moistureSno'];
    }
    var centralDuplicate = [];
    for(var i in central){
      print("central => $central");
      // // print(i.keys);
      var line = [];
      var fert = [];
      var ec = [];
      var ph = [];
      for(var l in i['irrigationLine']){
        line.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'hid' : l['hid'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      for(var l in i['fertilizer']){
        fert.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'hid' : l['hid'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      if(i['ecSensor'].isNotEmpty){
        for(var l in i['ecSensor']){
          ec.add({
            'sNo' : l['sNo'],
            'id' : l['id'],
            'hid' : l['hid'],
            'name' : l['name'],
            'location' : l['location'],
          });
        }
      }
      for(var l in i['phSensor']){
        ph.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'hid' : l['hid'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      centralDuplicate.add({
        'sNo' : i['sNo'],
        'id' : i['id'],
        'hid' : i['hid'],
        'name' : i['name'],
        'location' : i['location'],
        'irrigationLine' : line,
        'fertilizer' : fert,
        'ecSensor' : ec,
        'phSensor' : ph,
      });
    }
    var localDuplicate = [];
    for(var i in local){
      // // print(i.keys);
      var fert = [];
      var ec = [];
      var ph = [];

      for(var l in i['fertilizer']){
        fert.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'hid' : l['hid'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      if(i['ecSensor'].isNotEmpty){
        for(var l in i['ecSensor']){
          ec.add({
            'sNo' : l['sNo'],
            'id' : l['id'],
            'hid' : l['hid'],
            'name' : l['name'],
            'location' : l['location'],
          });
        }
      }
      for(var l in i['phSensor']){
        ph.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'hid' : l['hid'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      localDuplicate.add({
        'sNo' : i['sNo'],
        'id' : i['id'],
        'hid' : i['hid'],
        'name' : i['name'],
        'location' : i['location'],
        'fertilizer' : fert,
        'ecSensor' : ec,
        'phSensor' : ph,
      });
    }
    var generateNew = [];
    var myCentral = [];
    var myLocal = [];
    var valList = [];
    for(var vl in sequence[0]['valve']){
      if(!valList.contains(vl['location'])){
        valList.add(vl['location']);
      }
    }
    // this process is to find the central site for the sequence
    for(var cd in centralDuplicate){
      if(selectionModel!.data!.centralFertilizerSite!.isNotEmpty){
        int? selectionSno = selectionModel!.data!.centralFertilizerSite!.any((element) => element.selected == true) ?selectionModel!.data!.centralFertilizerSite!.firstWhere((element) => element.selected == true).sNo : null;
        // print('selectionSno : $selectionSno');
        if(selectionSno != null){
          if(selectionSno == cd['sNo']){
            int recipe = -1;
            bool applyRecipe = false;
            if(newSequence == false){
              if(sequence[0]['centralDosing'].isNotEmpty){
                if(sequence[0]['centralDosing'][0]['sNo'] == selectionSno){
                  // print("sequence[0]['centralDosing'][0] : ${sequence[0]['centralDosing'][0]}");
                  recipe = sequence[0]['centralDosing'][0]['recipe'];
                  applyRecipe = sequence[0]['centralDosing'][0]['applyRecipe'];
                  applyFertilizerForCentral = sequence[0]['applyFertilizerForCentral'];
                }
              }
            }
            var createSite = {
              'sNo' : cd['sNo'],
              'name' : cd['name'],
              'id' : cd['id'],
              'hid' : cd['hid'],
              'location' : cd['location'],
              'recipe' : recipe,
              'applyRecipe' : applyRecipe,
            };
            var fertilizer = [];
            for(var fert in cd['fertilizer']){
              String method = 'Time';
              String timeValue = '00:00:00';
              String quantityValue = '';
              bool onOff = false;
              if(newSequence == false){
                if(sequence[0]['centralDosing'].isNotEmpty){
                  for(var oldFert in sequence[0]['centralDosing'][0]['fertilizer']){
                    if(oldFert['sNo'] == fert['sNo']){
                      method = oldFert['method'];
                      timeValue = oldFert['timeValue'];
                      quantityValue = oldFert['quantityValue'];
                      onOff = oldFert['onOff'];
                      break;
                    }
                  }
                }

              }
              fert['method'] = method;
              fert['timeValue'] = timeValue;
              fert['quantityValue'] = quantityValue;
              fert['onOff'] = onOff;
              fertilizer.add(fert);
            }
            if(cd['ecSensor'].length != 0){
              String ecValue = '0';
              bool needEcValue = false;
              if(newSequence == false){
                if(sequence[0]['centralDosing'].isNotEmpty){
                  ecValue = (sequence[0]['centralDosing'][0]['ecValue'] ?? '').toString();
                  needEcValue = sequence[0]['centralDosing'][0]['needEcValue'] ?? false;
                }
              }
              createSite['ecValue'] = ecValue;
              createSite['needEcValue'] = needEcValue;
            }
            if(cd['phSensor'].length != 0){
              String phValue = '0';
              bool needPhValue = false;
              if(newSequence == false){
                if(sequence[0]['centralDosing'].isNotEmpty){
                  phValue = (sequence[0]['centralDosing'][0]['phValue'] ?? '').toString();
                  needPhValue = sequence[0]['centralDosing'][0]['needPhValue'] ?? false;
                }
              }
              createSite['phValue'] = phValue;
              createSite['needPhValue'] = needPhValue;
            }
            createSite['fertilizer'] = fertilizer;
            myCentral.add(createSite);
          }
        }
      }
      // for(var il in cd['irrigationLine']){
      //   if(valList.contains(il['id'])){
      //     if(selectionModel!.data!.centralFertilizerSite!.isNotEmpty){
      //       int? selectionSno = selectionModel!.data!.centralFertilizerSite!.any((element) => element.selected == true) ?selectionModel!.data!.centralFertilizerSite!.firstWhere((element) => element.selected == true).sNo : null;
      //       // print('selectionSno : $selectionSno');
      //       if(selectionSno != null){
      //         if(selectionSno == cd['sNo']){
      //           int recipe = -1;
      //           bool applyRecipe = false;
      //           if(newSequence == false){
      //             if(sequence[0]['centralDosing'].isNotEmpty){
      //               if(sequence[0]['centralDosing'][0]['sNo'] == selectionSno){
      //                 // print("sequence[0]['centralDosing'][0] : ${sequence[0]['centralDosing'][0]}");
      //                 recipe = sequence[0]['centralDosing'][0]['recipe'];
      //                 applyRecipe = sequence[0]['centralDosing'][0]['applyRecipe'];
      //                 applyFertilizerForCentral = sequence[0]['applyFertilizerForCentral'];
      //               }
      //             }
      //           }
      //           var createSite = {
      //             'sNo' : cd['sNo'],
      //             'name' : cd['name'],
      //             'id' : cd['id'],
      //             'hid' : cd['hid'],
      //             'location' : cd['location'],
      //             'recipe' : recipe,
      //             'applyRecipe' : applyRecipe,
      //           };
      //           var fertilizer = [];
      //           for(var fert in cd['fertilizer']){
      //             String method = 'Time';
      //             String timeValue = '00:00:00';
      //             String quantityValue = '';
      //             bool onOff = false;
      //             if(newSequence == false){
      //               if(sequence[0]['centralDosing'].isNotEmpty){
      //                 for(var oldFert in sequence[0]['centralDosing'][0]['fertilizer']){
      //                   if(oldFert['sNo'] == fert['sNo']){
      //                     method = oldFert['method'];
      //                     timeValue = oldFert['timeValue'];
      //                     quantityValue = oldFert['quantityValue'];
      //                     onOff = oldFert['onOff'];
      //                     break;
      //                   }
      //                 }
      //               }
      //
      //             }
      //             fert['method'] = method;
      //             fert['timeValue'] = timeValue;
      //             fert['quantityValue'] = quantityValue;
      //             fert['onOff'] = onOff;
      //             fertilizer.add(fert);
      //           }
      //           if(cd['ecSensor'].length != 0){
      //             String ecValue = '0';
      //             bool needEcValue = false;
      //             if(newSequence == false){
      //               if(sequence[0]['centralDosing'].isNotEmpty){
      //                 ecValue = sequence[0]['centralDosing'][0]['ecValue'].toString();
      //                 needEcValue = sequence[0]['centralDosing'][0]['needEcValue'];
      //               }
      //             }
      //             createSite['ecValue'] = ecValue;
      //             createSite['needEcValue'] = needEcValue;
      //           }
      //           if(cd['phSensor'].length != 0){
      //             String phValue = '0';
      //             bool needPhValue = false;
      //             if(newSequence == false){
      //               if(sequence[0]['centralDosing'].isNotEmpty){
      //                 phValue = sequence[0]['centralDosing'][0]['phValue'].toString();
      //                 needPhValue = sequence[0]['centralDosing'][0]['needPhValue'];
      //               }
      //             }
      //             createSite['phValue'] = phValue;
      //             createSite['needPhValue'] = needPhValue;
      //           }
      //           createSite['fertilizer'] = fertilizer;
      //           myCentral.add(createSite);
      //         }
      //       }
      //     }
      //   }
      // }
    }
    print("myCentral => $myCentral");
    // process end for central
    // this process is to find the Local site for the sequence
    for(var ld in localDuplicate){
      if(valList.contains(ld['id'])){
        if(selectionModel!.data!.localFertilizerSite!.isNotEmpty){
          int? selectionSno = selectionModel!.data!.localFertilizerSite!.any((element) => element.selected == true) ?selectionModel!.data!.localFertilizerSite!.firstWhere((element) => element.selected == true).sNo : null;
          if(selectionSno != null){
            if(selectionSno == ld['sNo']){
              int recipe = -1;
              bool applyRecipe = false;
              if(newSequence == false){
                if(sequence[0]['localDosing'].isNotEmpty){
                  if(sequence[0]['localDosing'][0]['sNo'] == selectionSno){
                    recipe = sequence[0]['localDosing'][0]['recipe'];
                    applyRecipe = sequence[0]['localDosing'][0]['applyRecipe'];
                    applyFertilizerForLocal = sequence[0]['applyFertilizerForLocal'];
                  }
                }

              }
              var createSite = {
                'sNo' : ld['sNo'],
                'name' : ld['name'],
                'id' : ld['id'],
                'hid' : ld['hid'],
                'location' : ld['location'],
                'recipe' : recipe,
                'applyRecipe' : applyRecipe,
              };
              var fertilizer = [];
              for(var fert in ld['fertilizer']){
                String method = 'Time';
                String timeValue = '00:00:00';
                String quantityValue = '';
                bool onOff = false;
                if(newSequence == false){
                  if(sequence[0]['localDosing'].isNotEmpty){
                    for(var oldFert in sequence[0]['localDosing'][0]['fertilizer']){
                      if(oldFert['sNo'] == fert['sNo']){
                        method = oldFert['method'];
                        timeValue = oldFert['timeValue'];
                        quantityValue = oldFert['quantityValue'];
                        onOff = oldFert['onOff'];
                        break;
                      }
                    }
                  }
                }
                fert['method'] = method;
                fert['timeValue'] = timeValue;
                fert['quantityValue'] = quantityValue;
                fert['onOff'] = onOff;
                fertilizer.add(fert);
              }
              if(ld['ecSensor'].length != 0){
                String ecValue = '0';
                bool needEcValue = false;
                if(newSequence == false){
                  if(sequence[0]['centralDosing'].isNotEmpty){
                    ecValue = (sequence[0]['centralDosing'][0]['ecValue']  ?? '').toString();
                    needEcValue = sequence[0]['centralDosing'][0]['needEcValue'] ?? false;
                  }
                }
                createSite['ecValue'] = ecValue;
                createSite['needEcValue'] = needEcValue;
              }
              if(ld['phSensor'].length != 0){
                String phValue = '0';
                bool needPhValue = false;
                if(newSequence == false){
                  if(sequence[0]['centralDosing'].isNotEmpty){
                    phValue = (sequence[0]['centralDosing'][0]['phValue'] ?? '').toString();
                    needPhValue = sequence[0]['centralDosing'][0]['needPhValue'] ?? false;
                  }
                }
                createSite['phValue'] = phValue;
                createSite['needPhValue'] = needPhValue;
              }
              createSite['fertilizer'] = fertilizer;
              myLocal.add(createSite);
            }
          }

        }
      }
    }
    // process end for local
    String method = 'Time';
    String timeValue = '00:00:00';
    String quantityValue = '0';
    if(newSequence == false){
      method = sequence[0]['method'];
      timeValue = sequence[0]['timeValue'];
      quantityValue = sequence[0]['quantityValue'];
    }

    generateNew.add({
      'sNo' : sequence[0]['sNo'],
      'valve' : sequence[0]['valve'],
      'mainValve' : sequence[0]['mainValve'],
      // 'name' : giveNameForSequence(sequence[0]),
      'seqName' : sequence[0]['seqName'],
      'moistureCondition' : moistureCondition,
      'moistureSno' : moistureSno,
      'levelCondition' : '-',
      'levelSno' : 0,
      'prePostMethod' : prePostMethod,
      'preValue' : preValue,
      'postValue' : postValue,
      'method' : method,
      'timeValue' : timeValue,
      'quantityValue' : quantityValue,
      'centralDosing' : myCentral,
      'localDosing' : myLocal,
      'applyFertilizerForCentral' : applyFertilizerForCentral,
      'applyFertilizerForLocal' : applyFertilizerForLocal,
      'selectedCentralSite' : 0,
      'selectedLocalSite' : 0,
    });
    // print('generateNew : $generateNew');
    return generateNew;
  }

  bool isSiteVisible(data,localOrCentral){
    var checkList = [];
    for(var i in data){
      checkList.add(i['sNo']);
    }
    bool CentralpgmMode = false;
    bool LocalpgmMode = false;
    bool visible = false;
    if(localOrCentral == 'central'){
      for(var pm in selectionModel!.data!.centralFertilizerSite!){
        if(pm.selected == true){
          CentralpgmMode = true;
        }
      }
    }
    if(localOrCentral == 'local'){
      for(var pm in selectionModel!.data!.localFertilizerSite!){
        if(pm.selected == true){
          LocalpgmMode = true;
        }
      }
    }
    if(localOrCentral == 'central'){
      if(CentralpgmMode == true){
        for(var slt in selectionModel!.data!.centralFertilizerSite!){
          // // print('slt.selected : ${slt.selected}');
          // // print('slt.sNo : ${slt.sNo}');
          if(slt.selected == true){
            if(checkList.contains(slt.sNo)){
              visible = true;
            }
          }
        }

      }
    }
    if(localOrCentral == 'local'){
      if(LocalpgmMode == true){
        for(var slt in selectionModel!.data!.localFertilizerSite!){
          if(slt.selected == true){
            if(checkList.contains(slt.sNo)){
              visible = true;
            }
          }
        }
      }
    }
    return ((localOrCentral == 'central' ? CentralpgmMode : LocalpgmMode) == true) ? visible : true;
  }

  dynamic deepCopy(dynamic originalList) {
    dynamic copiedList = [];
    if(originalList.isNotEmpty){
      for (var map in originalList) {
        copiedList.add(Map.from({
          "sNo": map['sNo'],
          "id": map['id'],
          "seqName": map['name'],
          "location": map['location'],
          "valve": List.from(map['valve']),
          "mainValve": List.from(map['mainValve']),
        }));
      }
    }

    return copiedList;
  }
  void waterAndFert(){
    final valSeqList = deepCopy(_irrigationLine!.sequence);
    var givenSeq = [];
    var myOldSeq = [];
    if(valSeqList.isNotEmpty){
      for(var i in valSeqList){
        givenSeq.add(i['sNo']);
      }
    }
    // print('givenSeq : $givenSeq');
    if(sequenceData.isNotEmpty){
      for(var i in sequenceData){
        myOldSeq.add(i['sNo']);
      }
    }
    var generateNew = [];
    var central = [];
    var local = [];
    for(var site in apiData['fertilization']){
      if(site['id'].contains('CFESI')){
        central.add(site);
      }else{
        local.add(site);
      }
    }
    for(var i = 0;i < valSeqList.length;i++){
      var seqList = [];
      bool newData = false;
      if(myOldSeq.isNotEmpty){
        add : for(var j = 0;j < myOldSeq.length;j++){
          if(myOldSeq.contains(valSeqList[i]['sNo'])){
            if(valSeqList[i]['sNo'] == myOldSeq[j]){
              if(valSeqList[i]['valve'].length == sequenceData[j]['valve'].length){
                for(var lst in sequenceData[j]['valve']){
                  seqList.add(lst['sNo']);
                }
                checkValve : for(var checkVal in valSeqList[i]['valve']){
                  if(!seqList.contains(checkVal['sNo'])){
                    newData = true;
                    break checkValve;
                  }else{
                    newData = false;
                  }
                }
                if(newData == true){
                  generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]],newSequence: true));
                  break add;
                }else{
                  sequenceData[j]['seqName'] = valSeqList[i]['seqName'];
                  generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [sequenceData[j]],newSequence: false));
                  break add;
                }
              }else{
                generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]],newSequence: true));
              }
            }
          }else{
            generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]],newSequence: true));
            break add;
          }
        }
      }else{
        generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]],newSequence: true));
      }
    }

    sequenceData = generateNew;
    // for(var i in sequenceData){
    //   for(var cd in i['centralDosing']){
    //     for(var slt in _selectionModel!.data!.centralFertilizerSite!){
    //       if(slt.selected == true){
    //         if(cd['sNo'] == slt.sNo){
    //           i['selectedCentralSite'] = i['centralDosing'].indexOf(cd);
    //         }
    //       }
    //     }
    //   }
    //   for(var ld in i['localDosing']){
    //     for(var slt in _selectionModel!.data!.localFertilizerSite!){
    //       if(slt.selected == true){
    //         if(ld['sNo'] == slt.sNo){
    //           i['selectedLocalSite'] = i['localDosing'].indexOf(ld);
    //         }
    //       }
    //     }
    //   }
    // }
    if(sequenceData.isNotEmpty){
      selectedGroup = 0;
      waterValueInTime = sequenceData[selectedGroup]['timeValue'];
      // print('waterValueInTime : ${waterValueInTime}');
      waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
      preValue.text = sequenceData[selectedGroup]['preValue'] ?? '';
      postValue.text = sequenceData[selectedGroup]['postValue'] ?? '';
      if(sequenceData[selectedGroup]['centralDosing'].isNotEmpty){
        ec.text = sequenceData[selectedGroup]['centralDosing']?[selectedCentralSite]?['ecValue'].toString() ?? '';
        ph.text = sequenceData[selectedGroup]['centralDosing']?[selectedCentralSite]?['phValue'].toString() ?? '';
      }
    }
    if(sequenceData[selectedGroup]['centralDosing'].isNotEmpty){
      segmentedControlCentralLocal = 0;
    }else if(sequenceData[selectedGroup]['localDosing'].isNotEmpty){
      segmentedControlCentralLocal = 1;
    }

    // print('after seq : ${sequenceData}');
    refreshTime();
    notifyListeners();
  }

  String fertMethodHw(String value){
    switch (value){
      case ('Time'):{
        return '1';
      }
      case ('Pro.time'):{
        return '3';
      }
      case ('Quantity'):{
        return '2';
      }
      case ('Pro.quantity'):{
        return '4';
      }
      case ('Pro.quant per 1000L'):{
        return '5';
      }
      default : {
        return '0';
      }
    }
  }

  dynamic hwPayloadForWF(serialNumber){
    var wf = '';
    editGroupSiteInjector('selectedGroup', 0);
    for(var sq in sequenceData){
      editGroupSiteInjector('selectedGroup', sequenceData.indexOf(sq));
      var valId = '';
      var mvId = '';
      for(var vl in sq['valve']){
        valId += '${valId.length != 0 ? '_' : ''}${vl['hid']}';
      }
      for(var vl in sq['mainValve']){
        mvId += '${mvId.length != 0 ? '_' : ''}${vl['hid']}';
      }
      var centralMethod = '';
      var centralTimeAndQuantity = '';
      var centralFertOnOff = '';
      var centralFertId = '';
      var centralEcActive = 0;
      var centralEcValue = '';
      var centralPhActive = 0;
      var centralPhValue = '';
      var localMethod = '';
      var localTimeAndQuantity = '';
      var localFertOnOff = '';
      var localFertId = '';
      var localEcActive = 0;
      var localEcValue = '';
      var localPhActive = 0;
      var localPhValue = '';
      var centralEC = '';
      var centralPH = '';
      var localEC = '';
      var localPH = '';
      // // print('c1 : ${isSiteVisible(sq['centralDosing'],'central')}');
      // // print('c2 : ${sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false}');
      // // print('c3 : ${sq['centralDosing'].isEmpty}');
      // // print('c4 : ${sq['selectedCentralSite'] == -1}');
      if(!isSiteVisible(sq['centralDosing'],'central') || sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false || sq['centralDosing'].isEmpty || sq['selectedCentralSite'] == -1){
        centralMethod = '0_0_0_0_0_0_0_0';
        centralTimeAndQuantity += '0_0_0_0_0_0_0_0';
        centralFertOnOff += '0_0_0_0_0_0_0_0';
        centralEcActive = 0;
        centralEcValue = '';
        centralPhActive = 0;
        centralPhValue = '';
      }else{
        var fertList = [];
        for(var ft in sq['centralDosing'][sq['selectedCentralSite']]['fertilizer']){
          centralMethod += '${centralMethod.isNotEmpty ? '_' : ''}${fertMethodHw(ft['method'])}';
          centralFertOnOff += '${centralFertOnOff.isNotEmpty ? '_' : ''}${ft['onOff'] == true ? 1 : 0}';
          centralFertId += '${centralFertId.isNotEmpty ? '_' : ''}${ft['hid']}';
          centralTimeAndQuantity += '${centralTimeAndQuantity.isNotEmpty ? '_' : ''}${ft['method'].contains('ime') ? ft['timeValue'] : ft['quantityValue']}';
          centralEcActive = sq['centralDosing'][sq['selectedCentralSite']]['needEcValue'] == null ? 0 : sq['centralDosing'][sq['selectedCentralSite']]['needEcValue'] == true ? 1 : 0;
          centralEcValue = '${sq['centralDosing'][sq['selectedCentralSite']]['ecValue'] ?? 0}';
          centralPhActive = sq['centralDosing'][sq['selectedCentralSite']]['needPhValue'] == null ? 0 : sq['centralDosing'][sq['selectedCentralSite']]['needPhValue'] == true ? 1 : 0;
          centralPhValue = '${sq['centralDosing'][sq['selectedCentralSite']]['phValue'] ?? 0}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          centralMethod += '${centralMethod.length != 0 ? '_' : ''}0';
          centralTimeAndQuantity += '${centralTimeAndQuantity.length != 0 ? '_' : ''}0';
          centralFertOnOff += '${centralFertOnOff.length != 0 ? '_' : ''}0';
        }
      }

      if(!isSiteVisible(sq['localDosing'],'local') || sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false || sq['localDosing'].isEmpty || sq['selectedLocalSite'] == -1){
        localMethod = '0_0_0_0_0_0_0_0';
        localTimeAndQuantity += '0_0_0_0_0_0_0_0';
        localFertOnOff += '0_0_0_0_0_0_0_0';
        localEcActive = 0;
        localEcValue = '';
        localPhActive = 0;
        localPhValue = '';
      }else{
        var fertList = [];
        for(var ft in sq['localDosing'][sq['selectedLocalSite']]['fertilizer']){
          localMethod += '${localMethod.isNotEmpty ? '_' : ''}${fertMethodHw(ft['method'])}';
          localFertOnOff += '${localFertOnOff.isNotEmpty ? '_' : ''}${ft['onOff'] == true ? 1 : 0}';
          localFertId += '${localFertId.isNotEmpty ? '_' : ''}${ft['hid']}';
          localTimeAndQuantity += '${localTimeAndQuantity.isNotEmpty ? '_' : ''}${ft['method'].contains('ime') ? ft['timeValue'] : ft['quantityValue']}';
          localEcActive = sq['localDosing'][sq['selectedLocalSite']]['needEcValue'] == null ? 0 : sq['localDosing'][sq['selectedLocalSite']]['needEcValue'] == true ? 1 : 0;
          localEcValue = '${sq['localDosing'][sq['selectedLocalSite']]['ecValue'] ?? 0}';
          localPhActive = sq['localDosing'][sq['selectedLocalSite']]['needPhValue'] == null ? 0 : sq['localDosing'][sq['selectedLocalSite']]['needPhValue'] == true ? 1 : 0;
          localPhValue = '${sq['localDosing'][sq['selectedLocalSite']]['phValue'] ?? 0}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          localMethod += '${localMethod.length != 0 ? '_' : ''}0';
          localTimeAndQuantity += '${localTimeAndQuantity.length != 0 ? '_' : ''}0';
          localFertOnOff += '${localFertOnOff.length != 0 ? '_' : ''}0';
        }
      }
      wf += '${wf.length != 0 ? ';' : ''}'
          '${sq['sNo']},'
          '${serialNumber},'
          '${sq['seqName']},'
          '${valId},'
          '${mvId},'
          ','
          '${getNominalFlow()},'
          '${sq['method'] == 'Time' ? 1 : 2},'
          '${sq['method'] == 'Time' ? sq['timeValue'] : sq['quantityValue']},'
          '${sq['applyFertilizerForCentral'] == false ? 0 : sq['selectedCentralSite'] == -1 ? 0 : 1},'
          '${sq['selectedCentralSite'] == -1 ? 0 : sq['centralDosing'].isEmpty ? 0 : sq['centralDosing'][sq['selectedCentralSite']]['hid']},'
          '${sq['applyFertilizerForLocal'] == false ? 0 : sq['selectedLocalSite'] == -1 ? 0 : 1},'
          '${sq['selectedLocalSite'] == -1 ? 0 : sq['localDosing'].isEmpty ? 0 : sq['localDosing'][sq['selectedLocalSite']]['hid']},'
          '${sq['prePostMethod'] == 'Time' ? 1 : 2},'
          '${sq['preValue']},'
          '${sq['postValue']},'
          '$centralMethod,'
          '$localMethod,'
          '$centralFertOnOff,'
          '$centralFertId,'
          '$localFertOnOff,'
          '$localFertId,'
          '${centralTimeAndQuantity},'
          '${localTimeAndQuantity},'
          '${centralEcActive},'
          '${centralEcValue == '' ? 0.0 : double.parse(centralEcValue)},'
          '${centralPhActive},'
          '${centralPhValue == '' ? 0.0 : double.parse(centralPhValue)},'
          '${localEcActive},'
          '${localEcValue == '' ? 0.0 : double.parse(localEcValue)},'
          '${localPhActive},'
          '${localPhValue == '' ? 0.0 : double.parse(localPhValue)},'
          '${sq['moistureSno']},'
          '${sq['levelSno']}';

    }
    // // print('water and fert : ${wf}');
    return wf;
    // for(var i in wf.split(';')){
    //   for(var j = 0;j < i.split(',').length;j++){
    // //     print('${wfPld(j)} =====  ${i.split(',')[j]}');
    //   }
    // //   // print('');
    // //   // print('');
    // }
  }

  String wfPld(int index){
    switch (index){
      case (0):{
        return 'S_No';
      }
      case (1):{
        return 'program sno';
      }
      case (2):{
        return 'seq name';
      }
      case (3):{
        return 'seq id';
      }
      case (4):{
        return 'pump';
      }
      case (5):{
        return 'valve flowrate';
      }
      case (6):{
        return 'irri method';
      }
      case (7):{
        return 'irr duration or quantity';
      }
      case (8):{
        return 'central fert on-off';
      }
      case (9):{
        return 'local fert on-off';
      }
      case (10):{
        return 'pre post method';
      }
      case (11):{
        return 'pre time or quantity';
      }
      case (12):{
        return 'post time or quantity';
      }
      case (13):{
        return 'central method';
      }
      case (14):{
        return 'local method';
      }
      case (15):{
        return 'central channel on off';
      }
      case (16):{
        return 'local channel on off';
      }
      case (17):{
        return 'central channel method';
      }
      case (18):{
        return 'local channel method';
      }
      case (19):{
        return 'central ec on-off';
      }
      case (20):{
        return 'central ec value';
      }
      case (20):{
        return 'local ec on-off';
      }
      case (22):{
        return 'local ec value';
      }
      case (23):{
        return 'central ph on-off';
      }
      case (24):{
        return 'central ph value';
      }
      case (25):{
        return 'local ph on-off';
      }
      case (26):{
        return 'local ph value';
      }
      case (27):{
        return 'condition';
      }
      case (28):{
        return 'immediate on-off';
      }
      default:{
        return 'nothing';
      }
    }
  }

  dynamic editWaterSetting(String title, String value){
    if(title == 'method'){
      var maxFertInSec = getMaxFertilizerValueForSelectedSequence();
      var diff = (postValueInSec() + preValueInSec() + maxFertInSec);
      var quantity = diff * flowRate();
      if(value == 'Time'){
        sequenceData[selectedGroup]['timeValue'] = formatTime(diff);
      }else{
        sequenceData[selectedGroup]['quantityValue'] = '${quantity.toInt() == 0 ? 0 : quantity.toInt() + 1}';
        waterQuantity.text = '${quantity.toInt() == 0 ? 0 : quantity.toInt() + 1}';
      }
      sequenceData[selectedGroup]['method'] = value;
      if(sequenceData[selectedGroup]['method'] == 'Time'){
        if(sequenceData[selectedGroup]['timeValue'] == '00:00:00'){
          waterValueInTime = '00:00:00';
          waterValueInQuantity = '0';

        }else{
          refreshTime();
        }
      }else{
        if(sequenceData[selectedGroup]['quantityValue'] == '0'){
          waterValueInQuantity = '0';
          waterValueInTime = '00:00:00';
        }else{
          refreshTime();
        }
      }
    }else if(title == 'timeValue'){
      sequenceData[selectedGroup]['timeValue'] = value;
      refreshTime();
    }else if(title == 'quantityValue'){
      var maxFertInSec = getMaxFertilizerValueForSelectedSequence();
      int currentWaterValueInSec = waterValueInSec();
      if(currentWaterValueInSec > (24*3600)){
        var oneDayQuantity = flowRate() * (24*3600);
        // print('one day == > $oneDayQuantity');
        sequenceData[selectedGroup]['quantityValue'] = '${oneDayQuantity.toInt()}';
        waterQuantity.text = '${oneDayQuantity.toInt()}';
        refreshTime();
        return {'message' : 'water value limit up to 24 hours'};
      }
      var diff = (postValueInSec() + preValueInSec() + maxFertInSec);
      var quantity = diff * flowRate();
      // print('quantity : ${quantity}');
      if(quantity != 0){
        if((value != '' ? int.parse(value) : 0) <= quantity.toInt()){
          sequenceData[selectedGroup]['quantityValue'] = '${quantity.toInt()}';
          waterQuantity.text = '${quantity.toInt() + 1}';
          refreshTime();
          return {'message' : 'water value limit up to ${waterQuantity.text} because of (pre + post + channels)value in liters'};
        }else{
          sequenceData[selectedGroup]['quantityValue'] = (value == '' ? '0' : value);
        }
      }else{
        sequenceData[selectedGroup]['quantityValue'] = (value == '' ? '0' : value);
      }
      refreshTime();
    }else{
      sequenceData[selectedGroup]['quantityValue'] = value;
    }
    notifyListeners();
  }
  int parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    int totalSeconds = ((int.parse(parts[0]) * 3600) + (int.parse(parts[1]) * 60) + (int.parse(parts[2])));
    return totalSeconds;
  }
  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void refreshTime(){
    if(sequenceData[selectedGroup]['method'] == 'Quantity'){
      // print('stoped it1');
      // print('flow : ${getNominalFlow()}');
      var hour = (sequenceData[selectedGroup]['quantityValue'] == '' ? 0 : int.parse(sequenceData[selectedGroup]['quantityValue']))/getNominalFlow();
      // print('hour : $hour');
      waterValueInTime = DataConvert().convertHoursToTime((sequenceData[selectedGroup]['quantityValue'] == '' ? 0 : int.parse(sequenceData[selectedGroup]['quantityValue']))/getNominalFlow());
      // print('stoped it1.1');
      waterValueInQuantity = sequenceData[selectedGroup]['quantityValue'];
    }else{
      // print('stoped it2');
      waterValueInQuantity = DataConvert().convertTimeToLiters(sequenceData[selectedGroup]['timeValue'],getNominalFlow()).toString();
      waterValueInTime = sequenceData[selectedGroup]['timeValue'];
    }
    // print('waterValueInTime : $waterValueInTime, waterValueInQuantity : $waterValueInQuantity');
    notifyListeners();
  }
  //TODO : edit ec ph in central and local
  dynamic editGroupSiteInjector(String title,dynamic value){
    switch(title){
      case ('applyFertilizer'):{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] = value;
        if(value == false){
          if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['needEcValue'] != null){
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['needEcValue'] = false;
          }
          // print('ecValue');
          if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['ecValue'] != null){
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['ecValue'] = 0;
          }
          // print('needPhValue');

          if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['needPhValue'] != null){
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['needPhValue'] = false;
          }
          // print('phValue');

          if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['phValue'] != null){
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['phValue'] = 0;
          }
          // print('fertilizer');
          for(var fert = 0;fert < sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['fertilizer'].length;fert++){
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['fertilizer'][fert]['method'] = 'Time';
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['fertilizer'][fert]['timeValue'] = '00:00:00';
            sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['fertilizer'][fert]['quantityValue'] = '0';
            getInjectorController(fert).text = '0';
          }
        }
        break;
      }
      case ('selectedGroup'):{
        // print('waterValueInTime : $waterValueInTime, waterValueInQuantity : $waterValueInQuantity');
        selectedGroup = value;
        waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
        preValue.text = sequenceData[selectedGroup]['preValue'];
        postValue.text = sequenceData[selectedGroup]['postValue'];
        refreshTime();
        break;
      }
      case ('selectedCentralSite'):{
        selectedCentralSite = value;
        if(sequenceData[selectedGroup]['centralDosing'].length != 0){
          sequenceData[selectedGroup]['selectedCentralSite'] = sequenceData[selectedGroup]['selectedCentralSite'] = value;
          ec.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          for(var index = 0;index < sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;index++){
            getInjectorController(index).text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['quantityValue'].toString() ?? '';
          }
        }
        // // print('--------------${jsonEncode(sequenceData[selectedGroup])}');
        break;
      }
      case ('selectedLocalSite'):{
        selectedLocalSite = value;
        if( sequenceData[selectedGroup]['localDosing'].length != 0){
          sequenceData[selectedGroup]['selectedLocalSite'] = sequenceData[selectedGroup]['selectedLocalSite'] =value;
          ec.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          for(var index = 0;index < sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;index++){
            getInjectorController(index).text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['quantityValue'].toString() ?? '';
          }
        }
        break;
      }
      case ('selectedInjector'):{
        selectedInjector = value;
        for(var index = 0;index < sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;index++){
          getInjectorController(index).text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['quantityValue'].toString() ?? '';
        }

        break;
      }
      case ('selectedRecipe') : {
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] = value;
        if(value != -1){
          for(var i in recipe){
            if(i['sNo'] == sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['sNo']){
              var apply = true;
              var lastSelectedChannel = selectedInjector;
              for(var inj = 0;inj < i['recipe'][value]['fertilizer'].length;inj++){
                if(i['recipe'][value]['fertilizer'][inj]['method'].contains('ime')){
                  int water = parseTimeString(formatTime(waterValueInSec()));
                  int pre = parseTimeString(formatTime(preValueInSec()));
                  int post = parseTimeString(formatTime(postValueInSec()));
                  int fertilizer = parseTimeString(i['recipe'][value]['fertilizer'][inj]['timeValue']);
                  var result = water - (pre + post);
                  if(fertilizer < result || fertilizer == result){

                  }else{
                    apply = false;
                    return {'message' : '${i['recipe'][value]['name']} setting is not match with your current setting'};
                  }
                }else{
                  var diff = waterValueInSec() - preValueInSec() - postValueInSec();
                  selectedInjector = value;
                  var flowRate = getFlowRate();
                  if((i['recipe'][value]['fertilizer'][inj]['quantityValue'] != '' ? int.parse(i['recipe'][value]['fertilizer'][inj]['quantityValue']) : 0)/flowRate > diff){
                    apply = false;
                    return {'message' : '${i['recipe'][value]['name']} setting is not match with your current setting'};
                  }
                }

              }
              if(apply == true){
                if(i['recipe'][value]['ecActive'] != null && i['recipe'][value]['Ec'] != null){
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] = i['recipe'][value]['ecActive'];
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['ecValue'] = i['recipe'][value]['Ec'];
                  ec.text = i['recipe'][value]['Ec'];
                }
                if(i['recipe'][value]['phActive'] != null && i['recipe'][value]['Ph'] != null){
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] = i['recipe'][value]['phActive'];
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['phValue'] = i['recipe'][value]['Ph'];
                  ph.text = i['recipe'][value]['Ph'];
                }
                for(var inj = 0;inj < i['recipe'][value]['fertilizer'].length;inj++){
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['onOff'] = i['recipe'][value]['fertilizer'][inj]['active'];
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['method'] = i['recipe'][value]['fertilizer'][inj]['method'];
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['timeValue'] = i['recipe'][value]['fertilizer'][inj]['timeValue'];
                  sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['quantityValue'] = i['recipe'][value]['fertilizer'][inj]['quantityValue'];
                  getInjectorController(inj).text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['quantityValue'].toString() ?? '';
                }
              }
            }
          }
        }

      }
      break;
      case ('applyRecipe') : {
        // // print('value : $value');
        if(value == false){
          for(var i in sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing']){
            i['recipe'] = -1;
          }
        }
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['applyRecipe'] = value;
      }
      break;
      case ('applyMoisture') : {
        sequenceData[selectedGroup]['moistureCondition'] = value['name'];
        sequenceData[selectedGroup]['moistureSno'] = value['sNo'];
      }
      break;
      case ('applyLevel') : {
        sequenceData[selectedGroup]['levelCondition'] = value['name'];
        sequenceData[selectedGroup]['levelSno'] = value['sNo'];
      }
    }
    notifyListeners();
  }
  void editNext(){
    if(segmentedControlGroupValue == 1){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length - 1 != selectedInjector){
        editGroupSiteInjector('selectedInjector',selectedInjector + 1);
      }
      // else if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length - 1 != (0)){
      //   editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(0) + 1);
      // }
      else if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
        // editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',0);
        editGroupSiteInjector('selectedInjector', 0);
      }
    }else{
      if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
      }
    }

    notifyListeners();
  }
  void editBack(){
    if(segmentedControlGroupValue == 1){
      if(selectedInjector != 0){
        editGroupSiteInjector('selectedInjector',selectedInjector - 1);
      }
      // else if((0) != 0){
      //   editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(0) - 1);
      // }
      else if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length -1);
        editGroupSiteInjector('selectedInjector', sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length -1);
      }
    }else{
      if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
      }
    }
    notifyListeners();
  }

  void editEcPhNeedOrNot(String title){
    if(title == 'ec'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] = true;
      }
    }else if(title == 'ph'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] = true;
      }    }
    notifyListeners();
  }
  void editEcPh(String title,String ecOrPh, String value){
    if(title == 'centralDosing'){
      sequenceData[selectedGroup]['centralDosing'][selectedCentralSite][ecOrPh] = value;
    }else if(title == 'localDosing'){
      // // print(value);
      sequenceData[selectedGroup]['localDosing'][selectedLocalSite][ecOrPh] = value;
    }
    notifyListeners();
  }

  int waterValueInSec(){
    int sec = 0;
    if(sequenceData[selectedGroup]['method'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['timeValue'].split(':');
      sec = (int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]));
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }

          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['quantityValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['quantityValue'] != '' ? int.parse(sequenceData[selectedGroup]['quantityValue']) : 0)/valveFlowRate).round();
      }
    }
    // // print('water finished');
    return sec;
  }

  int fertilizerValueInSec({dynamic fertilizerData}){
    int sec = 0;
    if(['Time','Pro.time'].contains(fertilizerData['method'])){
      var splitTime = fertilizerData['timeValue'].split(':');
      sec = (int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]));
    }else{
      var nominalFlowRate = 0;
      for(var site in constantSetting['fertilization']){
        for(var fert in site['fertilizer']){
          if(fert['sNo'] == fertilizerData['sNo']){
            nominalFlowRate = fert['nominalFlow'] == '' ? 0 : int.parse(fert['nominalFlow']);
          }
        }
      }
      var fertilizerFlowRate = nominalFlowRate * 0.00027778;
      if(fertilizerData['quantityValue'] == '0'){
        sec = 0;
      }else{
        sec = ((fertilizerData['quantityValue'] != '' ? double.parse(fertilizerData['quantityValue']) : 0)/fertilizerFlowRate).round();
      }
    }
    return sec;
  }

  int preValueInSec(){
    int sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['preValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]);
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }
      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      // // print('nominalFlowRate : $nominalFlowRate');
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['preValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['preValue'] != '' ? int.parse(sequenceData[selectedGroup]['preValue']) : 0)/valveFlowRate).toInt();
      }
    }
    // // print('pre in seconds : $sec');
    return sec;
  }

  int postValueInSec(){
    int sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['postValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]);
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['postValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['postValue'] != '' ? int.parse(sequenceData[selectedGroup]['postValue']) : 0)/valveFlowRate).toInt();
      }
    }
    return sec;
  }

  double flowRate(){
    var nominalFlowRate = [];
    var sno = [];
    for(var val in sequenceData[selectedGroup]['valve']){
      // // print('valve >>> ${val['sNo']}');
      for(var i = 0;i < constantSetting['valve'].length;i++){
        for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
          if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
            if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
              if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
              }
            }
          }
        }
      }

    }
    var totalFlowRate = 0;
    // // print('nominalFlowRate : ${nominalFlowRate}');
    for(var flwRate in nominalFlowRate){
      totalFlowRate = totalFlowRate + int.parse(flwRate);
    }
    // print('totalFlowRate : ${totalFlowRate}');
    var valveFlowRate = totalFlowRate * 0.00027778;
    return valveFlowRate;
  }

  int getNominalFlow(){
    var nominalFlowRate = [];
    var sno = [];
    for(var val in sequenceData[selectedGroup]['valve']){
      // // print('valve >>> ${val['sNo']}');
      for(var i = 0;i < constantSetting['valve'].length;i++){
        for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
          if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
            if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
              if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
              }
            }
          }
        }
      }

    }
    var totalFlowRate = 0;
    // // print('nominalFlowRate : ${nominalFlowRate}');
    for(var flwRate in nominalFlowRate){
      totalFlowRate = totalFlowRate + int.parse(flwRate);
    }
    // print('totalFlowRate : ${totalFlowRate}');
    return totalFlowRate;
  }

  double fertilizerFlowRate(){
    var nominalFlowRate = [];
    for(var channel in sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer']){
      for(var site in constantSetting['fertilization']){
        for(var fert in site['fertilizer']){
          if(fert['sNo'] == channel['sNo']){
            nominalFlowRate.add(fert['nominalFlow'] == '' ? 0 : int.parse(fert['nominalFlow']));
          }
        }
      }
    }
    var totalFlowRate = 0;
    for(var flwRate in nominalFlowRate){
      totalFlowRate = (totalFlowRate + flwRate).toInt();
    }
    var fertilizerFlowRate = totalFlowRate * 0.00027778;
    return fertilizerFlowRate;
  }

  int getMaxFertilizerValueForSelectedSequence(){
    int maxFertInSec = 0;
    if(sequenceData[selectedGroup]['centralDosing'].isNotEmpty){
      for(var i = 0;i < sequenceData[selectedGroup]['centralDosing'][0]['fertilizer'].length;i++){
        int fertInSec = fertilizerValueInSec(fertilizerData: sequenceData[selectedGroup]['centralDosing'][0]['fertilizer'][i]);
        // print('central fert ${i+1} => $fertInSec');
        if(fertInSec > maxFertInSec){
          maxFertInSec = fertInSec;
        }
      }
    }
    if(sequenceData[selectedGroup]['localDosing'].isNotEmpty){
      for(var i = 0;i < sequenceData[selectedGroup]['localDosing'][0]['fertilizer'].length;i++){
        int fertInSec = fertilizerValueInSec(fertilizerData: sequenceData[selectedGroup]['localDosing'][0]['fertilizer'][i]);
        if(fertInSec > maxFertInSec){
          maxFertInSec = fertInSec;
        }
      }
    }
    return maxFertInSec;
  }

  //TODO : edit pre post in fert segment
  dynamic editPrePostMethod(String title,int index,String value){
    switch (title){
      case 'prePostMethod' :{
        if(sequenceData[index]['prePostMethod'] != value){
          if(value == 'Time'){
            sequenceData[index]['preValue'] = '00:00:00';
            sequenceData[index]['postValue'] = '00:00:00';
          }else{
            sequenceData[index]['preValue'] = '0';
            sequenceData[index]['postValue'] = '0';
            preValue.text = '0';
            postValue.text = '0';
          }
          sequenceData[index]['prePostMethod'] = value;
        }
        break;
      }
      case 'preValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          var maxFertInSec = getMaxFertilizerValueForSelectedSequence();
          // print('preValue maxFertInSec :${maxFertInSec}');
          var diff = waterValueInSec() - (postValueInSec() + maxFertInSec);
          var quantity = diff * flowRate();
          // print('quantity : ${quantity}');
          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['preValue'] = '${quantity.toInt()}';
            preValue.text = '${quantity.toInt()}';
            return {'message' : 'pre value limit up to ${preValue.text} because of (water - pre + post + channels)value in liters'};
          }else{
            sequenceData[index]['preValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['preValue'] = value;
        }
        break;
      }
      case 'postValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          var maxFertInSec = getMaxFertilizerValueForSelectedSequence();
          var diff = waterValueInSec() - (preValueInSec() + maxFertInSec);
          var quantity = diff * flowRate();
          // // print('post diff : ${quantity}');
          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['postValue'] = '${quantity.toInt()}';
            postValue.text = '${quantity.toInt()}';
            return {'message' : 'post value limit up to ${postValue.text} because of (water - pre + post)value in liters'};
          }else{
            sequenceData[index]['postValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['postValue'] = value;
        }
        break;
      }

    }
    notifyListeners();
  }
  // void editSelectedSite(String centralOrLocal,dynamic value){
  //   if(centralOrLocal == 'centralDosing'){
  //     sequenceData[selectedGroup]['selectedCentralSite'] = sequenceData[selectedGroup]['selectedCentralSite'] == value ? -1 : value;
  //   }else{
  //     sequenceData[selectedGroup]['selectedLocalSite'] = sequenceData[selectedGroup]['selectedLocalSite'] == value ? -1 : value;
  //   }
  //   notifyListeners();
  // }

  void editOnOffInInjector(String centralOrLocal,int index,bool value){
    // // print('sequenceData check1 : ${jsonEncode(sequenceData)}');
    sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index]['onOff'] = value;
    // // print('sequenceData check2 : ${jsonEncode(sequenceData)}');
    notifyListeners();
  }

  double getFlowRate(){
    var nominalFlowRate = 0;
    for(var site in constantSetting['fertilization']){
      for(var fert in site['fertilizer']){
        if(fert['sNo'] == sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][selectedInjector]['sNo']){
          nominalFlowRate = fert['nominalFlow'] == '' ? 0 : int.parse(fert['nominalFlow']);
        }
      }
    }
    return nominalFlowRate * 0.0002778;
  }

  dynamic editParticularChannelDetails(String title,String centralOrLocal,dynamic value,[int? index]){
    // print('index is give : $index');
    switch(title){
      case ('method') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index ?? selectedInjector]['method'] = value;
        break;
      }
      case ('quantityValue') : {
        var editingSelectedFertilizer = sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index ?? selectedInjector];
        var diff = waterValueInSec() - preValueInSec() - postValueInSec();
        var waterFlowRate = getNominalFlow();
        var literForOneSeconds = waterFlowRate/3600;
        var fertilizerGapInLiters = literForOneSeconds * diff;
        var userInput = value != '' ? double.parse(value) : 0;
        var howMany1000In_fertilizerGapInLiters = fertilizerGapInLiters/1000;
        var injectorPer1000L = howMany1000In_fertilizerGapInLiters * userInput;
        var flowRate = getFlowRate();
        var maxFertilizerLimitInLiters = (diff * flowRate).toInt();
        // print('howMany1000In_fertilizerGapInLiters=> ${howMany1000In_fertilizerGapInLiters}  fertilizerGapInLiters => ${fertilizerGapInLiters} injectorPer1000L => ${injectorPer1000L}  maxFertilizerLimitInLiters => ${maxFertilizerLimitInLiters}');
        if(editingSelectedFertilizer['method'] == 'Pro.quant per 1000L'){
          if(injectorPer1000L > maxFertilizerLimitInLiters){
            editingSelectedFertilizer['quantityValue'] = '${(maxFertilizerLimitInLiters~/howMany1000In_fertilizerGapInLiters)}';
            getInjectorController(index ?? selectedInjector).text = editingSelectedFertilizer['quantityValue'].toString() ?? '';
            return {'message' : 'fertilizer value limit up to ${getInjectorController(index ?? selectedInjector).text}'};
          }else{
            editingSelectedFertilizer['quantityValue'] = (value == '' ? '0' : value);
          }
        }else{
          if(userInput/flowRate > diff){
            editingSelectedFertilizer['quantityValue'] = '${(diff * flowRate).toInt()}';
            getInjectorController(index ?? selectedInjector).text = editingSelectedFertilizer['quantityValue'].toString() ?? '';
            return {'message' : 'fertilizer value limit up to ${getInjectorController(index ?? selectedInjector).text} because of (water - pre + post + current channels)value in liters'};
          }else{
            editingSelectedFertilizer['quantityValue'] = (value == '' ? '0' : value);
          }
        }
        break;
      }
      case ('timeValue') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index ?? selectedInjector]['timeValue'] = value;
        break;
      }
    }
    notifyListeners();
  }

  String giveNameForSequence(dynamic data){
    var name = '';
    for(var i in data['selected']){
      name += '${name.length != 0 ? '&' : ''}$i';
    }
    return name;
  }


  void dataToWF() {
    serverDataWM = sequenceData;
    notifyListeners();
  }
  //TODO: SELECTION PROVIDER
  SelectionModel? _selectionModel;
  SelectionModel? get selectionModel => _selectionModel;
  List<String> filtrationModes = ['TIME', 'DP', 'BOTH'];
  String get selectedCentralFiltrationMode => _selectionModel?.data.additionalData?.centralFiltrationOperationMode ?? "TIME";
  String get selectedLocalFiltrationMode => _selectionModel?.data.additionalData?.localFiltrationOperationMode ?? "TIME";

  List valveFlowRate = [];
  int totalValveFlowRate = 0;
  int pumpStationValveFlowRate = 0;
  List pumpStationFlowRate = [];
  bool pumpStationCanEnable = false;

  void updateFiltrationMode(newValue, bool isCentral) {
    if(isCentral) {
      _selectionModel?.data.additionalData?.centralFiltrationOperationMode = newValue;
    } else {
      _selectionModel?.data.additionalData?.localFiltrationOperationMode = newValue;
    }
    notifyListeners();
  }

  bool get isPumpStationMode => _selectionModel?.data.additionalData?.pumpStationMode ?? false;
  bool get isChangeOverMode => _selectionModel?.data.additionalData?.changeOverMode ?? false;
  bool get isProgramBasedSet => _selectionModel?.data.additionalData?.programBasedSet ?? false;
  bool get isProgramBasedInjector => _selectionModel?.data.additionalData?.programBasedInjector ?? false;
  void updatePumpStationMode(newValue, title) {
    switch(title) {
      case 0: _selectionModel?.data.additionalData?.pumpStationMode = newValue;
      break;
      case 1: _selectionModel?.data.additionalData?.changeOverMode = newValue;
      break;
      case "Program based set selection": _selectionModel!.data.additionalData?.programBasedSet = newValue;
      break;
      case "Program based Injector selection": _selectionModel?.data.additionalData?.programBasedInjector = newValue;
      break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  bool get centralFiltBegin => _selectionModel?.data.additionalData?.centralFiltrationBeginningOnly ?? false;
  bool get localFiltBegin => _selectionModel?.data.additionalData?.localFiltrationBeginningOnly ?? false;
  void updateFiltBegin(newValue, isCentral) {
    if(isCentral) {
      _selectionModel!.data.additionalData?.centralFiltrationBeginningOnly = newValue;
    } else {
      _selectionModel!.data.additionalData?.localFiltrationBeginningOnly = newValue;
    }
    notifyListeners();
  }

  void calculateTotalFlowRate() {
    valveFlowRate = [];
    totalValveFlowRate = 0;
    pumpStationValveFlowRate = 0;
    pumpStationFlowRate = [];

    for (var index = 0; index < irrigationLine!.sequence.length; index++) {
      for (var val in irrigationLine!.sequence[index]['valve']) {
        for (var i = 0; i < constantSetting['valve'].length; i++) {
          for (var j = 0; j < constantSetting['valve'][i]['valve'].length; j++) {
            if ('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}') {
              if (constantSetting['valve'][i]['valve'][j]['nominalFlow'] != '') {
                valveFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
              }
            }
          }
        }
      }
    }

    if (constantSetting['pump'].any((element) => element['pumpStation'] == true)) {
      pumpStationCanEnable = true;
    }

    for (var index = 0; index < constantSetting['pump'].length; index++) {
      var selectedHeadUnits = selectionModel!.data.headUnits!.where((element) => element.selected == true).toList().map((e) => e.id).toList().join('_');
      if (constantSetting['pump'][index]['location'].toString().contains(selectedHeadUnits)) {
        print('Matching pump location: ${constantSetting['pump'][index]['location']} with selectedHeadUnits: $selectedHeadUnits');
        if (constantSetting['pump'][index]['pumpStation'] == true) {
          print("Adding pump station range: ${constantSetting['pump'][index]['range']}");
          pumpStationFlowRate.add(constantSetting['pump'][index]['range']);
        }
      }
    }

    totalValveFlowRate = valveFlowRate.map((flowRate) => int.parse(flowRate)).reduce((a, b) => a + b);
    if (pumpStationFlowRate.isNotEmpty) {
      pumpStationValveFlowRate = pumpStationFlowRate.map((flowRate) => int.parse(flowRate)).reduce((a, b) => a + b);
    }

    print('Total valve flow rate: $totalValveFlowRate');
    print('Total pump station valve flow rate: $pumpStationValveFlowRate');

    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  Future<void> getUserProgramSelection(int userId, int controllerId, int serialNumber) async {
    var userData = {
      "userId": userId,
      "controllerId": controllerId,
      "serialNumber": serialNumber
    };
    try {
      final response = await HttpService().postRequest("getUserProgramSelection", userData);
      final jsonData = json.decode(response.body);
      if (jsonData['data']['additionalData'] != null) {
        _selectionModel = SelectionModel.fromJson(jsonData);
        // // print(_selectionModel!.data!.centralFertilizerSet!.centralFertilizerSet.map((e) => e.name));
        // // print(_selectionModel!.data!.localFertilizerSet!.centralFertilizerSet.map((e) => e.name));
      } else {
        jsonData['data']['additionalData'] = {
          "centralFiltrationOperationMode": "TIME",
          "localFiltrationOperationMode": "TIME",
          "centralFiltrationBeginningOnly": false,
          "localFiltrationBeginningOnly": false,
          "pumpStationMode": false,
          "programBasedSet": false
        };
        _selectionModel = SelectionModel.fromJson(jsonData);
      }
    } catch (e) {
      log('Error: $e');
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  //TODO: ALARM SCREEN PROVIDER
  NewAlarmList? _newAlarmList;
  NewAlarmList? get newAlarmList => _newAlarmList;
  Future<void> getUserProgramAlarm(userId, controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramAlarm = await httpService.postRequest('getUserProgramAlarm', userData);
      if(getUserProgramAlarm.statusCode == 200) {
        final responseJson = getUserProgramAlarm.body;
        final convertedJson = jsonDecode(responseJson);
        _newAlarmList = NewAlarmList.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  //TODO: DONE SCREEN PROVIDER
  List<dynamic> programList = [];
  int programCount = 0;
  String programName = '';
  String defaultProgramName = '';
  String priority = '';
  List<String> priorityList = ["High", "Low"];
  bool isCompletionEnabled = false;
  List<String> programTypes = [];
  String selectedProgramType = '';
  int serialNumberCreation = 0;
  bool irrigationProgramType = false;

  List<int> serialNumberList = [];
  ProgramDetails? _programDetails;
  ProgramDetails? get programDetails => _programDetails;
  String get delayBetweenZones => _programDetails!.delayBetweenZones;
  String get adjustPercentage => _programDetails!.adjustPercentage;
  Future<void> doneData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramDetails', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programDetails = ProgramDetails.fromJson(convertedJson);
        if(_programLibrary != null) {
          programCount = _programLibrary!.program.isEmpty ? 1 : _programLibrary!.program.length + 1;
          serialNumberCreation = _programLibrary!.program.length + 1;
        }
        priority = _programDetails!.priority != "" ? _programDetails!.priority : "None";
        // if(_programDetails != null) {
        programName = serialNumber == 0
            ? "Program $programCount"
            : _programDetails!.programName.isEmpty
            ? _programDetails!.defaultProgramName
            : _programDetails!.programName;
        // } else {
        //   programName = _programDetails!.defaultProgramName;
        // }
        selectedProgramType = _programDetails!.programType == '' ? selectedProgramType : _programDetails!.programType;
        defaultProgramName = (_programDetails!.defaultProgramName == '' || _programDetails!.defaultProgramName.isEmpty) ?  "Program $programCount" : _programDetails!.defaultProgramName;
        isCompletionEnabled = _programDetails!.completionOption;
        Future.delayed(Duration.zero, () {
          notifyListeners();
        });
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: PROGRAM LIBRARY
  bool get getProgramType => _programDetails?.programType == "Irrigation Program" ? true : false;
  ProgramLibrary? _programLibrary;
  ProgramLibrary? get programLibrary => _programLibrary;
  final List<String> filterList = ["Active programs", "Inactive programs"];
  bool agitatorCountIsNotZero = false;
  int _selectedFilterType = 0;
  int get selectedFilterType => _selectedFilterType;

  void updateSelectedFilterType(int newIndex) {
    _selectedFilterType = newIndex;
    notifyListeners();
  }

  Future<String> programLibraryData(int userId, int controllerId) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramLibrary', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programLibrary = ProgramLibrary.fromJson(convertedJson);
        // print("program library data => ${convertedJson['data']['program'].length}");
        priority = _programDetails?.priority != "" ? _programDetails?.priority ?? "None" : "None";
        agitatorCountIsNotZero = convertedJson['data']['agitatorCount'] != 0 ? true : false;
        conditionsLibraryIsNotEmpty = convertedJson['data']['conditionLibraryCount'] != 0 ? true : false;
        // irrigationProgramType = _programLibrary?.program[serialNumber].programType == "Irrigation Program" ? true : false;
        notifyListeners();
        return convertedJson['message'];
      } else {
        log("HTTP Request failed or received an unexpected response.");
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
      // return getUserProgramName.statusCode;
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: PROGRAM RESET
  Future<String> userProgramReset(int userId, int controllerId, int programId, deviceId, serialNumber, String defaultProgramName, String programName) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "createUser": userId,
        "programId": programId,
        "defaultProgramName": defaultProgramName,
        "serialNumber": serialNumber,
        "programName": programName
      };

      var getUserProgramName = await httpService.putRequest('resetUserProgram', userData);
      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        log("HTTP Request failed or received an unexpected response.");
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }
  void updatePriority(newValue, index) {
    _programLibrary?.program[index].priority = newValue;
    notifyListeners();
  }

  void updateProgramName(dynamic newValue, String type) {
    switch (type) {
      case 'programName':programName = newValue != '' ? newValue : programName;
      break;
      case 'priority':priority = newValue;
      break;
      case 'completion':isCompletionEnabled = newValue as bool;
      break;
      case 'programType':selectedProgramType = newValue as String;
      break;
      case"delayBetweenZones": _programDetails!.delayBetweenZones = newValue;
      break;
      case"adjustPercentage": _programDetails!.adjustPercentage = newValue;
      break;
      default:
        log("Not found");
    }
    notifyListeners();
  }

  bool isIrrigationProgram = false;
  bool isAgitatorProgram = false;
  bool showIrrigationPrograms = false;
  bool showAgitatorPrograms = false;
  bool showAllPrograms = true;
  bool isActive = true;

  void updateActiveProgram() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateShowPrograms(all, irrigation, agitator, active) {
    showAllPrograms = all;
    showIrrigationPrograms = irrigation;
    showAgitatorPrograms = agitator;
    notifyListeners();
  }
  void updateIsIrrigationProgram() {
    isIrrigationProgram = true;
    isAgitatorProgram = false;
    notifyListeners();
  }

  void updateIsAgitatorProgram() {
    isAgitatorProgram = true;
    isIrrigationProgram = false;
    notifyListeners();
  }

  List<String> commonLabels = [
    'Sequence',
    'Schedule',
    'Conditions',
    'Selection',
    'Water & Fert',
    'Alarm',
    'Additional',
    'Preview'
  ];
  List<IconData> commonIcons = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.checklist,
    Icons.local_florist_rounded,
    Icons.alarm_rounded,
    Icons.done_rounded,
    Icons.preview,
  ];

  Tuple<List<String>, List<IconData>> getLabelAndIcon({required int sno, String? programType, bool? conditionLibrary}) {
    List<String> labels = [];
    List<IconData> icons = [];

    final irrigationProgram = sno == 0
        ? selectedProgramType == "Irrigation Program"
        : programType == "Irrigation Program";
    // // print(irrigationProgram);
    if (irrigationProgram) {
      commonLabels = commonLabels.map((label) => label == "Agitator" ? "Water & Fert" : label).toList();
      commonIcons = commonIcons.map((icon) => icon == Icons.air ? Icons.local_florist_rounded : icon).toList();
      labels = (conditionLibrary ?? false)
          ? commonLabels
          : commonLabels.where((element) => !["Conditions"].contains(element)).toList();
      icons = (conditionLibrary ?? false)
          ? commonIcons
          : commonIcons.where((element) => ![Icons.fact_check].contains(element)).toList();
    } else {
      commonLabels = commonLabels.map((label) => label == "Water & Fert" ? "Agitator" : label).toList();
      commonIcons = commonIcons.map((icon) => icon == Icons.local_florist_rounded ? Icons.air : icon).toList();
      labels = commonLabels.where((element) => !["Conditions", "Selection", "Preview"].contains(element)).toList();
      icons = commonIcons.where((element) => ![Icons.fact_check, Icons.checklist, Icons.preview].contains(element)).toList();
    }
    return Tuple(labels, icons);
  }

  //TODO: UPDATE PROGRAM DETAILS
  Future<String> updateUserProgramDetails(
      int userId, int controllerId, int serialNumber, int programId, String programName, String priority, defaultProgramName, String controllerReadStatus, hardwareData) async {
    try {
      Map<String, dynamic> userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber,
        "createUser": userId,
        "programId": programId,
        "programName": programName,
        "priority": priority,
        "defaultProgramName": defaultProgramName,
        "controllerReadStatus": controllerReadStatus,
        "hardware": hardwareData
      };

      var updateUserProgramDetails = await httpService.putRequest('updateUserProgramDetails', userData);

      if (updateUserProgramDetails.statusCode == 200) {
        final responseJson = updateUserProgramDetails.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: CREATE COPY OF PROGRAM
  Future<String> userProgramCopy(int userId, int controllerId, int oldSerialNumber, int serialNumber, String programName, String defaultProgramName, String programType) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "createUser": userId,
        "serialNumber": serialNumber,
        "oldSerialNumber": oldSerialNumber,
        "defaultProgramName": defaultProgramName,
        "programName": programName,
        "programType": programType,
        // "programId": programId
      };

      var getUserProgramName = await httpService.postRequest('createUserProgramFromCopy', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        log("HTTP Request failed or received an unexpected response.");
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: Program Payload conversion for hardware
  DateTime get scheduleAsRunListStartDate => DateTime.parse(_sampleScheduleModel!.scheduleAsRunList.schedule['startDate']);
  DateTime get scheduleByDayStartDate => DateTime.parse(_sampleScheduleModel!.scheduleByDays.schedule['startDate']);
  DateTime get scheduleAsRunListEndDate => DateTime.parse(_sampleScheduleModel!.scheduleAsRunList.schedule['endDate']);
  DateTime get scheduleByDayEndDate => DateTime.parse(_sampleScheduleModel!.scheduleByDays.schedule['endDate']);

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String get formattedScheduleAsRunListStartDate => formatter.format(scheduleAsRunListStartDate);
  String get formattedScheduleByDayStartDate => formatter.format(scheduleByDayStartDate);
  String get formattedScheduleAsRunListEndDate => formatter.format(scheduleAsRunListEndDate);
  String get formattedScheduleByDayEndDate => formatter.format(scheduleByDayEndDate);

  dynamic getDaySelectionMode() {
    List typeData = _sampleScheduleModel!.scheduleAsRunList.schedule['type'];
    var selectionModeList = [];
    for(var i = 0; i < typeData.length; i++) {
      switch(typeData[i]) {
        case "DO NOTHING":
          selectionModeList.add(0);
          break;
        case "DO WATERING":
          selectionModeList.add(1);
          break;
        case "DO ONE TIME":
          selectionModeList.add(3);
          break;
        case "DO FERTIGATION":
          selectionModeList.add(2);
          break;
      }
    }
    return selectionModeList.isNotEmpty ? selectionModeList.join('_') : "1";
  }

  List<String> generateRtcTimeList(Map<String, dynamic> rtcData, String key) {
    return List.generate(6, (index) {
      final rtcKey = 'rtc${index + 1}';
      String rtcValue;

      switch(key) {
        case "noOfCycles":
          rtcValue = rtcValue = index < rtcData.length ? rtcData[rtcKey]['noOfCycles'].toString() : '0';
          break;
        case "stopMethod":
          rtcValue = rtcValue = index < rtcData.length ? rtcData[rtcKey]['stopMethod'] == stopMethods[2] ? "3" : rtcData[rtcKey]['stopMethod'] == stopMethods[1] ? "2" : "1" : "0";
        default:
          rtcValue = index < rtcData.length
              ? '${rtcData[rtcKey][key]}'.length == 5
              ? '${rtcData[rtcKey][key]}:00'
              : '${rtcData[rtcKey][key]}'
              : "00:00:00";
      // return rtcValue;
      }
      return rtcValue;
    });
  }

  List<String> generateRtcTimeByUser(Map<String, dynamic> rtcData) {
    return List.generate(6, (index) {
      final rtcKey = 'rtc${index + 1}';
      String rtcValue;

      rtcValue = index < rtcData.length
          ? (rtcData[rtcKey]['stopMethod'] == stopMethods[2])
          ? '${rtcData[rtcKey]['maxTime']}'
          : (rtcData[rtcKey]['stopMethod'] == stopMethods[1])
          ? '${rtcData[rtcKey]['offTime']}'
          : '${rtcData[rtcKey]['onTime']}'
          : "00:00:00";
      return rtcValue;
    });
  }

  String generateRtcTimeString(String key) {
    var rtcTimeList = generateRtcTimeList(selectedScheduleType == scheduleTypes[1] ? sampleScheduleModel!.scheduleAsRunList.rtc : sampleScheduleModel!.scheduleByDays.rtc, key);
    return rtcTimeList.join('_');
  }

  String generateRtcTimeStringByUser() {
    var rtcTimeList = generateRtcTimeByUser(selectedScheduleType == scheduleTypes[1] ? sampleScheduleModel!.scheduleAsRunList.rtc : sampleScheduleModel!.scheduleByDays.rtc);
    return rtcTimeList.join('_');
  }

  String get rtcOnTime => generateRtcTimeString('onTime');
  String get rtcStopMethod => generateRtcTimeString('stopMethod');
  String get rtcMaxTime => generateRtcTimeString('maxTime');
  String get rtcOffTime => generateRtcTimeString('offTime');
  String get rtcNoOfCycles => generateRtcTimeString('noOfCycles');
  String get rtcInterval => generateRtcTimeString('interval');

  String generateFertilizerString({dataList, requiredType}) {
    var selectedItems = '';
    switch(requiredType) {
      case "name":
        selectedItems = dataList?.where((element) => element.selected == true).map((element) => element.name ?? "").toList().join('_') ?? [].join('_');
        break;
      case "id":
        selectedItems = dataList?.where((element) => element.selected == true).map((element) => element.hid ?? "").toList().join('_') ?? [].join('_');
        break;
      case "sNo":
        selectedItems = dataList?.where((element) => element.selected == true).map((element) => element.sNo ?? "").toList().join('_') ?? [].join('_');
        break;
      default:
        selectedItems = dataList?.where((element) => element.selected == true).map((element) => "1").toList().join('_') ?? "0";
        break;
    }
    return selectedItems;
  }

  String getProgramStopMethod(method) {
    return List.generate(6, (index) => method).join('_');
  }

  String generateFertilizerLocationString(List<NameData>? dataList, String locationField) {
    final selectedLocations = dataList?.where((element) => element.selected == true).map((element) => element.location ?? "").toList() ?? [];
    return selectedLocations.join('_');
  }

  List<String?> get conditionList => _sampleConditions?.condition
      .map((e) => e.selected ? e.value['sNo']?.toString() : "0")
      .toList() ?? List.generate(4, (index) => '0');

  dynamic dataToMqtt(serialNumber, programType) {
    final scheduleType = selectedScheduleType;
    final schedule = scheduleType == scheduleTypes[1]
        ? sampleScheduleModel!.scheduleAsRunList.schedule
        : sampleScheduleModel!.scheduleByDays.schedule;

    var endDate = DateTime.parse(schedule['endDate']).isBefore(DateTime.parse(startDate(serialNumber: serialNumber)))
        ? DateTime.now().toString() :(schedule['endDate'] ?? DateTime.now().toString());
    final isForceToEndDate = schedule['isForceToEndDate'] ?? false;
    var noOfDays = ((schedule['noOfDays'] == "" || schedule['noOfDays'] == "0") ? "1": schedule['noOfDays']) ?? '1';
    final runDays = ((schedule['runDays'] == "" || schedule['runDays'] == "0") ? "1": schedule['runDays']) ?? '1';
    final runListLimit = sampleScheduleModel?.defaultModel.runListLimit ?? 0;
    final skipDays = schedule['skipDays'] ?? '0';
    final dateRange = (DateTime.parse(endDate).difference(DateTime.parse(startDate(serialNumber: serialNumber)))).inDays;
    final firstDate = DateTime.parse(startDate(serialNumber: serialNumber)).add(Duration(days: (scheduleType == scheduleTypes[1] ? int.parse(noOfDays) : 0)
        + int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0") - (selectedScheduleType == scheduleTypes[1] ? 2 : 1)));
    endDate = dateRange < (scheduleType == scheduleTypes[1] ? int.parse(noOfDays) : 0)
        + int.parse(runDays != '' ? runDays : "1") + int.parse(skipDays != '' ? skipDays : "0")
        ? firstDate
        : DateTime.parse(endDate);
    return {
      "2500": [
        {
          "2501": "${hwPayloadForWF(serialNumber)};"
        },
        {
          "2502": "${[
            '$serialNumber',
            '${programType == "Irrigation Program"
                ? _selectionModel!.data.headUnits?.where((element) => element.selected == true).map((e) => e.id).toList().join("_")
                : _irrigationLine?.sequence.map((e) {
              List valveSerialNumbers = e['valve'].map((valve) => valve['hid']).toList();
              return valveSerialNumbers.join('_');
            }).toList().join("+")}',
            '${programType == "Irrigation Program"
                ? _selectionModel!.data.headUnits?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")
                : _irrigationLine?.sequence.map((e) {
              List valveSerialNumbers = e['valve'].map((valve) => valve['name']).toList();
              return valveSerialNumbers.join('_');
            }).toList().join("+")}',
            programName,
            '${_irrigationLine?.sequence.map((e) {
              List valveSerialNumbers = e['valve'].map((valve) => valve['hid']).toList();
              return valveSerialNumbers.join('_');
            }).toList().join("+")}',
            '${isPumpStationMode ? 1 : 0}',
            '${_selectionModel!.data.irrigationPump?.where((element) => element.selected == true).map((e) => e.hid).toList().join("_")}',
            '${_selectionModel!.data.irrigationPump?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")}',
            '${_selectionModel!.data.mainValve?.where((element) => element.selected == true).map((e) => e.hid).toList().join("_")}',
            '${_selectionModel!.data.mainValve?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")}',
            '${priority == priorityList[0] ? 1 : 2}',
            delayBetweenZones.length == 5 ? "$delayBetweenZones:00" : delayBetweenZones,
            adjustPercentage != "0" ? adjustPercentage : "100",
            '${selectedScheduleType == scheduleTypes[0]
                ? 1 : selectedScheduleType == scheduleTypes[1] ? 2 : selectedScheduleType == scheduleTypes[2] ? 3 : 4}',
            formatter.format(DateTime.parse(startDate(serialNumber: serialNumber))),
            // (selectedScheduleType == scheduleTypes[1] ? formattedScheduleAsRunListStartDate : formattedScheduleByDayStartDate),
            selectedScheduleType == scheduleTypes[1] ? noOfDays : "${int.parse(runDays) + int.parse(skipDays)}",
            '${selectedScheduleType == scheduleTypes[3]
                ? _sampleScheduleModel!.dayCountSchedule.schedule["shouldLimitCycles"] == true ? "1" : "0"
                : selectedScheduleType == scheduleTypes[1]
                ? getDaySelectionMode()
                : [runDays, skipDays].join("_")}',
            isForceToEndDate ? (endDate.runtimeType == String ? formatter.format(DateTime.parse(endDate)) : formatter.format(DateTime.parse(endDate.toString()))) : "0001-01-01",
            // (selectedScheduleType == scheduleTypes[1] ? formattedScheduleAsRunListEndDate : formattedScheduleByDayEndDate),
            (selectedScheduleType == scheduleTypes[3]
                ? _sampleScheduleModel!.dayCountSchedule.schedule["onTime"]
                : rtcOnTime),
            _sampleScheduleModel!.defaultModel.allowStopMethod
                ? rtcStopMethod
                : (_sampleScheduleModel!.defaultModel.rtcMaxTime
                ? getProgramStopMethod(3)
                : _sampleScheduleModel!.defaultModel.rtcOffTime
                ? getProgramStopMethod(2)
                : getProgramStopMethod(1)),
            (_sampleScheduleModel!.defaultModel.rtcMaxTime
                ? rtcMaxTime
                : _sampleScheduleModel!.defaultModel.rtcOffTime
                ? rtcOffTime
                : _sampleScheduleModel!.defaultModel.allowStopMethod
                ? generateRtcTimeStringByUser() : rtcOnTime),
            selectedScheduleType == scheduleTypes[3] ? _sampleScheduleModel!.dayCountSchedule.schedule["noOfCycles"] : rtcNoOfCycles,
            selectedScheduleType == scheduleTypes[3] ? _sampleScheduleModel!.dayCountSchedule.schedule["interval"] : rtcInterval,
            '${_selectionModel!.data.centralFertilizerSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.centralFertilizerSite?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${_selectionModel!.data.centralFertilizerSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.centralFertilizerSite?.firstWhere((element) => element.selected == true).name
                : ""}',
            '${_selectionModel!.data.localFertilizerSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.localFertilizerSite?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${_selectionModel!.data.localFertilizerSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.localFertilizerSite?.firstWhere((element) => element.selected == true).name
                : ""}',
            '${_selectionModel!.data.selectorForCentral!.any((element) => element.selected == true)
                ? _selectionModel!.data.selectorForCentral?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${_selectionModel!.data.selectorForLocal!.any((element) => element.selected == true)
                ? _selectionModel!.data.selectorForLocal?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${selectionModel!.data.centralFilterSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.centralFilterSite?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${selectionModel!.data.centralFilterSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.centralFilterSite?.firstWhere((element) => element.selected == true).name
                : ""}',
            '${selectionModel!.data.localFilterSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.localFilterSite?.firstWhere((element) => element.selected == true).hid
                : ""}',
            '${selectionModel!.data.localFilterSite!.any((element) => element.selected == true)
                ? _selectionModel!.data.localFilterSite?.firstWhere((element) => element.selected == true).name
                : ""}',
            '${selectedCentralFiltrationMode == "TIME"
                ? 1 : selectedCentralFiltrationMode == "DP"
                ? 2
                : 3}',
            '${selectedLocalFiltrationMode == "TIME"
                ? 1 : selectedLocalFiltrationMode == "DP"
                ? 2
                : 3}',
            selectionModel!.data.centralFilterSite!.any((element) => element.selected == true)
                ? (generateFertilizerString(dataList: _selectionModel!.data.centralFilter, requiredType: "onOff"))
                : "",
            selectionModel!.data.centralFilterSite!.any((element) => element.selected == true)
                ? (generateFertilizerString(dataList: _selectionModel!.data.centralFilter, requiredType: "name"))
                : "",
            selectionModel!.data.localFilterSite!.any((element) => element.selected == true)
                ? (generateFertilizerString(dataList: _selectionModel!.data.localFilter, requiredType: "onOff"))
                : "",
            selectionModel!.data.localFilterSite!.any((element) => element.selected == true)
                ? (generateFertilizerString(dataList: _selectionModel!.data.localFilter, requiredType: "name"))
                : "",
            // "centralInj": '${generateFertilizerString(_selectionModel!.data!.centralFertilizerInjector, 'id')}',
            // "localInj": '${generateFertilizerString(_selectionModel!.data!.localFertilizerInjector, 'id')}',
            '${centralFiltBegin ? 1 : 0}',
            '${localFiltBegin ? 1 : 0}',
            '${_sampleConditions?.condition != null
                ? _sampleConditions!.condition.any((element) => element.selected == true)
                ? 1
                : 0
                : 0}',
            (conditionList.map((value) => value ?? '0').toList().join("_")),
            newAlarmList!.alarmList.map((e) => e.value == true ? 1 : 0).toList().join('_'),
            '${isChangeOverMode ? 1 : 0}',
            // ([..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList(), ..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList()].join("_")),
          ].join(',')};",
        },
      ]
    };
  }

// dynamic dataToMqtt(serialNumber, programType) {
//   return {
//     "2500": [
//       {
//         "2501": "${hwPayloadForWF(serialNumber)};"
//       },
//       {
//         "2502": "${[
//           '$serialNumber',
//           '${programType == "Irrigation Program"
//               ? _selectionModel!.data?.headUnits?.where((element) => element.selected == true).map((e) => e.id).toList().join("_")
//               : _irrigationLine?.sequence.map((e) {
//             List valveSerialNumbers = e['valve'].map((valve) => valve['hid']).toList();
//             return valveSerialNumbers.join('_');
//           }).toList().join("+")}',
//           '${programType == "Irrigation Program"
//               ? _selectionModel!.data?.headUnits?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")
//               : _irrigationLine?.sequence.map((e) {
//             List valveSerialNumbers = e['valve'].map((valve) => valve['name']).toList();
//             return valveSerialNumbers.join('_');
//           }).toList().join("+")}',
//           programName,
//           '${_irrigationLine?.sequence.map((e) {
//             List valveSerialNumbers = e['valve'].map((valve) => valve['hid']).toList();
//             return valveSerialNumbers.join('_');
//           }).toList().join("+")}',
//           '${isPumpStationMode ? 1 : 0}',
//           '${_selectionModel!.data?.irrigationPump?.where((element) => element.selected == true).map((e) => e.hid).toList().join("_")}',
//           '${_selectionModel!.data?.irrigationPump?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")}',
//           '${_selectionModel!.data?.mainValve?.where((element) => element.selected == true).map((e) => e.hid).toList().join("_")}',
//           '${_selectionModel!.data?.mainValve?.where((element) => element.selected == true).map((e) => e.name).toList().join("_")}',
//           '${priority == priorityList[0] ? 1 : 2}',
//           delayBetweenZones.length == 5 ? "$delayBetweenZones:00" : delayBetweenZones,
//           adjustPercentage,
//           '${_sampleScheduleModel!.selected == scheduleTypes[0] ? 1 : _sampleScheduleModel!.selected == scheduleTypes[1] ? 2 : _sampleScheduleModel!.selected == scheduleTypes[2] ? 3 : 4}',
//           (_sampleScheduleModel!.selected == scheduleTypes[1] ? formattedScheduleAsRunListStartDate : formattedScheduleByDayStartDate),
//           _sampleScheduleModel!.selected == scheduleTypes[1]
//               ? '${int.parse(_sampleScheduleModel!.scheduleAsRunList.schedule['noOfDays'])}'
//               : "${int.parse(_sampleScheduleModel!.scheduleByDays.schedule['skipDays']) + int.parse(_sampleScheduleModel!.scheduleByDays.schedule['runDays'])}",
//           '${_sampleScheduleModel!.selected == scheduleTypes[1]
//               ? getDaySelectionMode()
//               : [_sampleScheduleModel!.scheduleByDays.schedule['runDays'] ?? '0', _sampleScheduleModel!.scheduleByDays.schedule['skipDays'] ?? '0'].join("_")}',
//           (_sampleScheduleModel!.selected == scheduleTypes[1] ? formattedScheduleAsRunListEndDate : formattedScheduleByDayEndDate),
//           (_sampleScheduleModel!.selected == scheduleTypes[1]
//               ? sBRrtcOnTimeString
//               : sBDrtcOnTimeString),
//           // sampleScheduleModel!.defaultModel.allowStopMethod
//           //     ?
//           //     :
//           (_sampleScheduleModel!.defaultModel.rtcMaxTime
//               ? getProgramStopMethod(3)
//               : _sampleScheduleModel!.defaultModel.rtcOffTime
//               ? getProgramStopMethod(2)
//               : getProgramStopMethod(1)),
//           (_sampleScheduleModel!.defaultModel.rtcMaxTime
//               ? _sampleScheduleModel!.selected == scheduleTypes[1]
//               ? sBRrtcMaxTimeString
//               : sBDrtcMaxTimeString
//               : _sampleScheduleModel!.selected == scheduleTypes[1]
//               ? sBRrtcOffTimeString
//               : sBDrtcOffTimeString),
//           (_sampleScheduleModel!.selected == scheduleTypes[1]
//               ? sBRrtcNoOfCyclesString
//               : sBDrtcNoOfCyclesString),
//           (_sampleScheduleModel!.selected == scheduleTypes[1]
//               ? sBRrtcIntervalString
//               : sBDrtcIntervalString),
//           '${_selectionModel!.data!.centralFertilizerSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.centralFertilizerSite?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${_selectionModel!.data!.centralFertilizerSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.centralFertilizerSite?.firstWhere((element) => element.selected == true).name
//               : ""}',
//           '${_selectionModel!.data!.localFertilizerSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.localFertilizerSite?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${_selectionModel!.data!.localFertilizerSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.localFertilizerSite?.firstWhere((element) => element.selected == true).name
//               : ""}',
//           '${(_selectionModel!.data!.centralFertilizerSite!.any((element) => element.selected == true) && (_selectionModel!.data!.selectorForCentral!.isNotEmpty ? _selectionModel!.data!.selectorForCentral!.any((element) => element.selected == true) : false))
//               ? _selectionModel!.data!.selectorForCentral?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${(_selectionModel!.data!.localFertilizerSite!.any((element) => element.selected == true)  && (_selectionModel!.data!.selectorForLocal!.isNotEmpty ? _selectionModel!.data!.selectorForLocal!.any((element) => element.selected == true) : false))
//               ? _selectionModel!.data!.selectorForLocal?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${selectionModel!.data!.centralFilterSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.centralFilterSite?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${selectionModel!.data!.centralFilterSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.centralFilterSite?.firstWhere((element) => element.selected == true).name
//               : ""}',
//           '${selectionModel!.data!.localFilterSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.localFilterSite?.firstWhere((element) => element.selected == true).hid
//               : ""}',
//           '${selectionModel!.data!.localFilterSite!.any((element) => element.selected == true)
//               ? _selectionModel!.data!.localFilterSite?.firstWhere((element) => element.selected == true).name
//               : ""}',
//           '${selectedCentralFiltrationMode == "TIME"
//               ? 1 : selectedCentralFiltrationMode == "DP"
//               ? 2
//               : 3}',
//           '${selectedLocalFiltrationMode == "TIME"
//               ? 1 : selectedLocalFiltrationMode == "DP"
//               ? 2
//               : 3}',
//           (generateFertilizerString(dataList: _selectionModel!.data!.centralFilter, requiredType: "onOff")),
//           (generateFertilizerString(dataList: _selectionModel!.data!.centralFilter, requiredType: "name")),
//           (generateFertilizerString(dataList: _selectionModel!.data!.localFilter, requiredType: "onOff")),
//           (generateFertilizerString(dataList: _selectionModel!.data!.localFilter, requiredType: "name")),
//           // "centralInj": '${generateFertilizerString(_selectionModel!.data!.centralFertilizerInjector, 'id')}',
//           // "localInj": '${generateFertilizerString(_selectionModel!.data!.localFertilizerInjector, 'id')}',
//           '${centralFiltBegin ? 1 : 0}',
//           '${localFiltBegin ? 1 : 0}',
//           '${_sampleConditions?.condition != null
//               ? _sampleConditions!.condition.any((element) => element.selected == true)
//               ? 1
//               : 0
//               : 0}',
//           (conditionList.map((value) => value ?? '0').toList().join("_")),
//           newAlarmList!.alarmList.map((e) => e.value == true ? 1 : 0).toList().join('_')
//           // ([..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList(), ..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList()].join("_")),
//         ].join(',')};",
//       },
//     ]
//   };
// }
}
class Tuple<Labels, Icons> {
  final Labels labels;
  final Icons icons;

  Tuple(this.labels, this.icons);
}