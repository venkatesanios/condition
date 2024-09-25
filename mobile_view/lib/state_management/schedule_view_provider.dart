import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../screens/customer/ScheduleView.dart';
import 'MqttPayloadProvider.dart';

class ScheduleViewProvider extends ChangeNotifier {
  late MQTTManager manager;
  HttpService httpService = HttpService();
  late MqttPayloadProvider payloadProvider;
  String changeToValue = '';
  String selectedRtc = '';
  String selectedCycle = '';
  String selectedZone = '';
  String messageFromHttp = '';
  late dynamic data;
  Map<String, dynamic> scheduleList = {};
  DateTime date = DateTime.now();
  bool scheduleGotFromMqtt = false;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  bool isFetchingCompleted = false;
  int _selectedProgramCategory = 0;
  int get selectedProgramCategory => _selectedProgramCategory;

  void updateSelectedProgramCategory(int newIndex) {
    _selectedProgramCategory = newIndex;
    notifyListeners();
  }

  void reorderSchedule(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    for (var scheduleKey in scheduleList.keys) {
      final List<dynamic> oldList = scheduleList[scheduleKey];
      final dynamic item = oldList[oldIndex];

      oldList.removeAt(oldIndex);
      oldList.insert(newIndex, item);
    }
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Constructor
  ScheduleViewProvider() {
    manager= MQTTManager();
  }

  void updateChannel(index, itemIndex) {
    scheduleList["CentralFertChannelSelection"][index].split("_")[itemIndex] == "1" ? "0" : "1";
    notifyListeners();
  }

  List<String> statusListFetched = [];
  List<dynamic> statusList = [];
  List<String> selectedStatusList = [];
  List<dynamic> programList = [];
  List<dynamic> selectedProgramList = [];

  StatusInfo getStatusInfo(code) {
    Color innerCircleColor;
    String statusString;
    IconData iconData;
    String statusCode;
    bool selectedStatus;
    String reason;

    switch (code) {
      case "0":
        innerCircleColor = Colors.grey;
        statusString = "Pending";
        reason = "Unknown";
        iconData = Icons.pending;
        statusCode = "0";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[0]);
        break;
      case "1":
        innerCircleColor = Colors.orange;
        statusString = "Running";
        reason = "Running As Per Schedule";
        iconData = Icons.run_circle;
        statusCode = "1";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[1]);
        break;
      case "2":
        innerCircleColor = Colors.green;
        statusString = "Completed";
        reason = "Turned On Manually";
        iconData = Icons.done;
        statusCode = "2";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[2]);
        break;
      case "3":
        innerCircleColor = Colors.yellow;
        statusString = "Skipped by user";
        reason = "Started By Condition";
        iconData = Icons.skip_next;
        statusCode = "3";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[3]);
        break;
      case "4":
        innerCircleColor = Colors.orangeAccent;
        statusString = "Day schedule pending";
        reason = "Turned Off Manually";
        iconData = Icons.pending_actions;
        statusCode = "4";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[0]);
        break;
      case "5":
        innerCircleColor = const Color(0xFF0D5D9A);
        statusString = "Day schedule running";
        reason = "Program Turned Off";
        iconData = Icons.run_circle_outlined;
        statusCode = "1";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[1]);
        break;
      case "6":
        innerCircleColor = Colors.yellowAccent;
        statusString = "Day schedule completed";
        reason = "Zone Turned Off";
        iconData = Icons.done_all_outlined;
        statusCode = "2";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[2]);
        break;
      case "7":
        innerCircleColor = Colors.red;
        statusString = "Day schedule skipped";
        reason = "Stopped By Condition";
        iconData = Icons.incomplete_circle;
        statusCode = "7";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "8":
        innerCircleColor = Colors.redAccent;
        statusString = "Postponed partially to tomorrow";
        iconData = Icons.repartition;
        reason = "Disabled By Condition";
        statusCode = "8";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[0]);
        break;
      case "9":
        innerCircleColor = Colors.green;
        statusString = "Postponed fully to tomorrow";
        reason = "Stand Alone Program Started";
        iconData = Icons.add_alert_outlined;
        statusCode = "9";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[0]);
        break;
      case "10":
        innerCircleColor = Colors.amberAccent;
        statusString = "RTC off time reached";
        reason = "Stand Alone Program Stopped";
        iconData = Icons.timer_outlined;
        statusCode = "10";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "11":
        innerCircleColor = Colors.amber;
        statusString = "RTC max time reached";
        reason = "Stand Alone Program Stopped After Set Value";
        iconData = Icons.share_arrival_time_rounded;
        statusCode = "11";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "12":
        innerCircleColor = Colors.amber;
        statusString = "Skipped By High Flow";
        reason = "Stand Alone Manual Started";
        iconData = Icons.speed_outlined;
        statusCode = "12";
        selectedStatus = selectedStatusList.contains(statusString);
    // selectedStatus = selectedStatusList.contains(statusList[4]);
      case "13":
        innerCircleColor = Colors.amber;
        statusString = "Skipped By Low Flow";
        reason = "Stand Alone Manual Stopped";
        iconData = Icons.speed_outlined;
        statusCode = "13";
        selectedStatus = selectedStatusList.contains(statusString);
    // selectedStatus = selectedStatusList.contains(statusList[4]);
      case "14":
        innerCircleColor = Colors.amber;
        statusString = "Skipped By No Flow";
        reason = "Stand Alone Manual Stopped After Set Value";
        iconData = Icons.water_drop_outlined;
        statusCode = "14";
        selectedStatus = selectedStatusList.contains(statusString);
    // selectedStatus = selectedStatusList.contains(statusList[4]);
      case "15":
        innerCircleColor = Colors.amber;
        statusString = "Skipped By Global limit";
        reason = "StartedByDayCountRtc";
        iconData = Icons.production_quantity_limits;
        statusCode = "15";
        selectedStatus = selectedStatusList.contains(statusString);
    // selectedStatus = selectedStatusList.contains(statusList[4]);
      case "16":
        innerCircleColor = Colors.amber;
        statusString = "Stopped manually";
        reason = "Paused By User";
        iconData = Icons.touch_app_outlined;
        statusCode = "16";
        selectedStatus = selectedStatusList.contains(statusString);
    // selectedStatus = selectedStatusList.contains(statusList[3]);
      case "17":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Manually Started Paused By User";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "18":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Program Deleted";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "19":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Program Ready";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "20":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Program Completed";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "21":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Resumed By User";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "22":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Paused By Condition";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "23":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Program Ready And Run By Condition";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "24":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Running As Per Schedule And Condition";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      case "25":
        innerCircleColor = Colors.amber;
        statusString = "Unknown status";
        reason = "Started By Condition Paused By User";
        iconData = Icons.device_unknown;
        statusCode = "17";
        selectedStatus = selectedStatusList.contains(statusString);
        // selectedStatus = selectedStatusList.contains(statusList[4]);
        break;
      default:
        throw Exception("Unsupported status code: $code");
    }
    return StatusInfo(innerCircleColor, statusString, iconData, statusCode, selectedStatus, reason);
  }

  Future<void> requestScheduleData(deviceId) async {
    // manager.subscribeToTopic("FirmwareToApp/$deviceId");
    data = {
      "2600": [
        {"2601": "${DateFormat('yyyy-MM-dd').format(date)},${DateFormat('yyyy-MM-dd').format(date)}"}
      ]
    };
    manager.publish(jsonEncode(data), "AppToFirmware/$deviceId");
  }

  Future<void> getUserSequencePriority(userId, controllerId, message) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "fromDate": DateFormat('yyyy-MM-dd').format(date),
        "toDate": DateFormat('yyyy-MM-dd').format(date),
      };
      var getUserProgramQueue = await httpService.postRequest("getUserSequencePriority", userData);
      if (getUserProgramQueue.statusCode == 200) {
        final responseJson = getUserProgramQueue.body;
        final convertedJson = jsonDecode(responseJson);
        dataConversion(convertedJson);
      }
    } catch (e) {
      log('Error: $e');
    }
    notifyListeners();
  }

  List<dynamic> programCategories = [];
  Map<String, int> scheduleCount = {};
  List scheduleCountList = [];

  void fetchData(deviceId, userId, controllerId, context) async {
    isLoading = true;
    isFetchingCompleted = false;
    scheduleList = {};
    statusListFetched = [];
    selectedStatusList = [];
    programCategories = [];
    scheduleCount = {};
    scheduleCountList = [];
    selectedProgramList = [];
    statusList = [];
    programList = [];

    await requestScheduleData(deviceId);
    await Future.delayed(const Duration(seconds: 8));

    if (!scheduleGotFromMqtt) {
      await getUserSequencePriority(userId, controllerId, messageFromHttp);
    }

    isLoading = false;
    isFetchingCompleted = true;

    if(scheduleList.isNotEmpty) {
      for (var status in scheduleList['Status']) {
        statusListFetched.add(getStatusInfo(status.toString()).statusString);
      }

      statusList = Set.from(statusListFetched).toList();
      programCategories = Set.from(scheduleList['ProgramCategory']).toList();
      programList = Set.from(scheduleList['ProgramName']).toList();

      scheduleCount = getProgramCategoryCounts(scheduleList['ProgramCategory']);
      scheduleCount.forEach((_, count) => scheduleCountList.add(count));
    }

    notifyListeners();
  }

  Map<String, int> getProgramCategoryCounts(List<dynamic> programCategories) {
    Map<String, int> categoryCounts = {};
    for (String category in programCategories) {
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    return categoryCounts;
  }

  int _selectedSegment = 0;

  int get selectedSegment => _selectedSegment;

  void updateSelectedSegment(int newIndex) {
    _selectedSegment = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void dataFromMqttConversion(payload) {
    if(payload.isNotEmpty) {
      scheduleGotFromMqtt = true;
    }
    dataConversion(jsonDecode(payload));
    notifyListeners();
  }
  var convertedList = [];

  void dataConversion(payload) {
    convertedList = [];
    if(scheduleGotFromMqtt) {
      scheduleList = payload["3600"][0]['3601'];
      dataFromMqttConversion2(scheduleList);
    } else {
      if (payload["code"] == 200) {
        scheduleList = payload["data"][0]["sequence"];
        dataFromMqttConversion2(scheduleList);
      } else {
        scheduleList = {};
        programCategories = [];
        scheduleCount = {};
        scheduleCountList =[];
        statusList = [];
        messageFromHttp = payload["message"];
      }
    }
    notifyListeners();
  }

  void dataFromMqttConversion2(Map<String, dynamic> payload) {
    List<Map<String, dynamic>> convertedListInside = [];

    for (int i = 0; i < payload["S_No"].length; i++) {
      Map<String, dynamic> resultDict = {};

      payload.forEach((key, value) {
        resultDict[key] = value[i];
      });

      convertedListInside.add(resultDict);
    }

    convertedList = convertedListInside;
    notifyListeners();
    // print(convertedListInside);
  }

}
