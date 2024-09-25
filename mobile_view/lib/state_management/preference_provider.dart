import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants/http_service.dart';
import '../models/PreferenceModel/preference_data_model.dart';

const actionForGeneral = "getUserPreferenceGeneral";
const actionForNotification = "getUserPreferenceNotification";
const actionForSetting = "getUserPreferenceSetting";
const actionForUserPassword = "checkUserUsingUserIdAndPassword";
const actionForCalibration = "getUserPreferenceCalibration";

class PreferenceProvider extends ChangeNotifier {
  final HttpService httpService = HttpService();

  bool notReceivingAck = false;
  bool sending = false;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  List<String> label = ["Settings"];
  // List<String> label = ["General", "Settings", "Notifications"];
  List<IconData> icons = [Icons.settings];
  // List<IconData> icons = [Icons.manage_accounts, Icons.settings, Icons.notifications];

  GeneralData? generalData;
  GeneralData? get generalDataResult => generalData;

  List<NotificationsData>? alarmNotificationData;
  List<NotificationsData>? get alarmNotificationDataResult => alarmNotificationData;

  List<NotificationsData>? eventNotificationData;
  List<NotificationsData>? get eventNotificationDataResult => eventNotificationData;

  List<IndividualPumpSetting>? individualPumpSetting;
  List<IndividualPumpSetting>? get individualPumpSettingData => individualPumpSetting;

  List<CommonPumpSetting>? commonPumpSettings;
  List<CommonPumpSetting>? get commonPumpSettingsData => commonPumpSettings;

  List<CommonPumpSetting>? calibrationSetting;
  List<CommonPumpSetting>? get calibrationSettingsData => calibrationSetting;

  List<SettingList>? defaultSetting;
  List<SettingList>? get defaultSettingData => defaultSetting;

  List<SettingList>? defaultCalibration;
  List<SettingList>? get defaultCalibrationData => defaultCalibration;

  int passwordValidationCode = 0;

  void updateValidationCode() {
    passwordValidationCode = 0;
    notifyListeners();
  }

  Future<void> getUserPreference({required int userId, required int controllerId}) async {
    final userData = {
      "userId": userId,
      "controllerId": controllerId
    };
    print("userData ==> $userData");
    try {
      final response = await httpService.postRequest(actionForGeneral, userData);
      print("response.try ${response.body}");
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          generalData = GeneralData.fromJson(result['data'][0]);
        } catch(error) {
          print(error);
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing general data: $error");
      print("Stack trace general data: $stackTrace");
    }
    try {
      final response = await httpService.postRequest(actionForNotification, userData);
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          alarmNotificationData = List.from(result['data']['alarm'].map((json) => NotificationsData.fromJson(json)));
          eventNotificationData = List.from(result['data']['event'].map((json) => NotificationsData.fromJson(json)));
        } catch(error) {
          print(error);
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing notifications data: $error");
      print("Stack trace notifications data: $stackTrace");
    }
    try {
      final response = await httpService.postRequest(actionForSetting, userData);
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          individualPumpSetting = List.from(result['data']['individualPumpSetting'].map((json) => IndividualPumpSetting.fromJson(json)));
          commonPumpSettings = List.from(result['data']['commonPumpSetting'].map((json) => CommonPumpSetting.fromJson(json)));
          // defaultSetting = List.from(result['data']['default']['settingList'].map((json) => SettingList.fromJson(json)));
        } catch(error, stackTrace) {
          print(error);
          print("stackTrace ==> $stackTrace");
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    try {
      final response = await httpService.postRequest(actionForCalibration, userData);
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          calibrationSetting = List.from(result['data'].map((json) => CommonPumpSetting.fromJson(json)));
          // defaultCalibration = List.from(result['data']['default']['settingList'].map((json) => SettingList.fromJson(json)));
        } catch(error) {
          print(error);
        }
      } else {
        print("response.body ${response.body}");
      }
      // print(calibrationSetting!.map((e) => e.toJson()));
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    notifyListeners();
  }

  Future<void> checkPassword({required int userId, required String password}) async{
    try {
      final userData = {
        'userId': userId,
        "password": password
      };
      final response = await httpService.postRequest(actionForUserPassword, userData);
      print(userData);
      final result = jsonDecode(response.body);
      passwordValidationCode = result['code'];
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    notifyListeners();
  }

  void updateControllerReaStatus({required String key, required int oroPumpIndex}) {
    if(key.contains("100")) commonPumpSettings![oroPumpIndex].settingList[0].controllerReadStatus = "1";
    if(key.contains("200")) commonPumpSettings![oroPumpIndex].settingList[1].controllerReadStatus = "1";
    int pumpIndex = 0;
    for (var individualPump in individualPumpSetting ?? []) {
      if (commonPumpSettings![oroPumpIndex].deviceId == individualPump.deviceId) {
        pumpIndex++;
        for (var individualPumpSetting in individualPump.settingList) {
          switch (individualPumpSetting.type) {
            case 23:
              if(key.contains("400-$pumpIndex")) individualPumpSetting.controllerReadStatus= "1";
              break;
            case 22:
              if(key.contains("300-$pumpIndex") || key.contains("500-$pumpIndex")) individualPumpSetting.controllerReadStatus = "1";
              break;
            case 25:
              if(key.contains("600-$pumpIndex")) individualPumpSetting.controllerReadStatus = "1";
              break;
          }
        }
      }
    }
    if(passwordValidationCode == 200 && calibrationSetting!.isNotEmpty) {
      if(key.contains("900")) calibrationSetting![oroPumpIndex].settingList[1].controllerReadStatus = "1";
    }
    notifyListeners();
  }

  void clearData() {
    notReceivingAck = false;
    sending = false;
    _selectedTabIndex = 0;
    generalData = null;
    alarmNotificationData = null;
    eventNotificationData = null;
    individualPumpSetting = null;
    commonPumpSettings = null;
    calibrationSetting = null;
    passwordValidationCode = 0;
  }
}