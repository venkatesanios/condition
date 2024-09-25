class GeneralData {
  String userName;
  String categoryName;
  String controllerName;
  String deviceId;
  int controllerId;
  int categoryId;
  int modelId;

  GeneralData({
    required this.userName,
    required this.categoryName,
    required this.controllerName,
    required this.deviceId,
    required this.controllerId,
    required this.categoryId,
    required this.modelId
  });

  factory GeneralData.fromJson(Map<String, dynamic> json) {
    return GeneralData(
        userName: json['userName'] ?? '',
        categoryName: json['categoryName'] ?? '',
        controllerName: json['controllerName'] ?? '',
        deviceId: json['deviceId'] ?? "0",
        controllerId: json['controllerId'] ?? 0,
        categoryId: json['categoryId'] ?? 0,
        modelId: json['modelId'] ?? 0
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'categoryName': categoryName,
      'controllerName': controllerName,
      'deviceId': deviceId,
      'controllerId': controllerId,
      "categoryId": categoryId,
      "modelId": modelId,
    };
  }
}

class NotificationsData {
  int notificationTypeId;
  String notification;
  String notificationDescription;
  String iconCodePoint;
  String? iconFontFamily;
  bool? value;

  NotificationsData({
    required this.notificationTypeId,
    required this.notification,
    required this.notificationDescription,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.value
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
        notificationTypeId: json['notificationTypeId'],
        notification: json['notification'],
        notificationDescription: json['notificationDescription'],
        iconCodePoint: json['iconCodePoint'],
        iconFontFamily: json['iconFontFamily'],
        value: json['value'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationTypeId': notificationTypeId,
      'value': value,
    };
  }
}

class RtcTimeSetting {
  int rtc;
  String onTime;
  String offTime;

  RtcTimeSetting({
    required this.rtc,
    required this.onTime,
    required this.offTime,
  });

  factory RtcTimeSetting.fromJson(Map<String, dynamic> json) {
    return RtcTimeSetting(
      rtc: json['rtc'] ?? 0,
      onTime: json['onTime'] == "" ? "00:00:00" : json['onTime'],
      offTime: json['offTime'] == "" ? "00:00:00" : json['offTime'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'onTime': onTime,
      'offTime': offTime,
    };
  }
}

class WidgetSetting {
  String title;
  int serialNumber;
  int widgetTypeId;
  String iconCodePoint;
  String iconFontFamily;
  dynamic value;
  List<RtcTimeSetting>? rtcSettings;
  bool hidden;

  WidgetSetting({
    required this.title,
    required this.widgetTypeId,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.value,
    this.rtcSettings,
    required this.hidden,
    required this.serialNumber
  });

  factory WidgetSetting.fromJson(Map<String, dynamic> json) {
    final rtcData = json['value'];
    List<RtcTimeSetting>? rtcSettings;
    if (rtcData is List<dynamic>) {
      rtcSettings = rtcData.map((rtcItem) {
        return RtcTimeSetting.fromJson(rtcItem);
      }).toList();
    }

    return WidgetSetting(
      title: json['title'],
      serialNumber: json['sNo'] ?? 0,
      widgetTypeId: json['widgetTypeId'],
      iconCodePoint: json['iconCodePoint'],
      iconFontFamily: json['iconFontFamily'],
      value: json['widgetTypeId'] != 2
          ? json['value']
          : (json['value'] is bool)
          ? json['value']
          : false,
      rtcSettings: rtcSettings,
      hidden: json['hidden'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'sNo': serialNumber,
      'hidden': hidden,
      'value': value,
    };

    if (title == 'RTC TIMER') {
      json['value'] = (rtcSettings?.map((item) => item.toJson()).toList())!;
    } else {
      json['value'] = value;
    }

    return json;
  }
}

class SettingList {
  int type;
  String name;
  bool changed;
  String controllerReadStatus;
  List<WidgetSetting> setting;

  SettingList({
    required this.type,
    required this.changed,
    required this.controllerReadStatus,
    required this.name,
    required this.setting,
  });

  factory SettingList.fromJson(Map<String, dynamic> json) {
    final settingsData = json['setting'] as List;

    final settings = settingsData.map((setting) {
      return WidgetSetting.fromJson(setting);
    }).toList();

    return SettingList(
      type: json['type'] is String ? int.parse(json['type']) : json['type'],
      changed: (json['changed'] ?? "0") == "1" ? true : false,
      controllerReadStatus: json['controllerReadStatus'] ?? "0",
      name: json['name'] ?? "no name",
      setting: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      "changed": "0",
      "controllerReadStatus": controllerReadStatus,
      "setting": setting.map((item) => item.toJson()).toList(),
    };
  }

  dynamic toGem() {
    if(type == 22) {
      return "${setting.firstWhere((element) => element.serialNumber == 1).value}";
    }
  }
}

class IndividualPumpSetting {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  dynamic deviceId;
  List<SettingList> settingList;

  IndividualPumpSetting({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.deviceId,
    required this.settingList
  });

  factory IndividualPumpSetting.fromJson(Map<String, dynamic> json) {
    final settingsDats = json['settingList'] as List<dynamic>;
    final settingsList = settingsDats.map((element) => SettingList.fromJson(element)).toList();
    return IndividualPumpSetting(
        sNo: json["sNo"],
        id: json["id"],
        hid: json["hid"],
        name: json["name"],
        location: json["location"],
        type: json["type"],
        deviceId: json["deviceId"],
        settingList: settingsList
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "name": name,
      "location": location,
      "type": type,
      "deviceId": deviceId,
      "settingList": settingList.map((e) => e.toJson()).toList(),
    };
  }

  String toGem() {
    return "$sNo,${id.contains("SP") ? 1 : 2},$id";
  }

  String oDt() {
    var onDelayTimer = [];
    // var
    settingList.forEach((element) {
      if(element.toGem() != null) {
        onDelayTimer.add(element.toGem());
      }
    });
    print(onDelayTimer);
    return onDelayTimer.join(',');
  }
}

class CommonPumpSetting {
  int controllerId;
  int categoryId;
  String deviceName;
  String deviceId;
  int serialNumber;
  int referenceNumber;
  int interfaceTypeId;
  List<SettingList> settingList;

  CommonPumpSetting({
    required this.controllerId,
    required this.categoryId,
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
    required this.referenceNumber,
    required this.interfaceTypeId,
    required this.settingList
  });

  factory CommonPumpSetting.fromJson(Map<String, dynamic> json) {
    // print("json in the common settings ==> $json");
    final settingsDats = json['settingList'] as List<dynamic>;
    final settingsList = settingsDats.map((element) => SettingList.fromJson(element)).toList();
    return CommonPumpSetting(
        controllerId: json["controllerId"],
        categoryId: json["categoryId"] ?? 0,
        deviceId: json["deviceId"],
        deviceName: json["deviceName"],
        serialNumber: json['serialNumber'],
        referenceNumber: json['referenceNumber'] ?? 0,
        interfaceTypeId: json['interfaceTypeId'] ?? 0,
        settingList: settingsList
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "controllerId": controllerId,
      "deviceId": deviceId,
      "deviceName": deviceName,
      "serialNumber": serialNumber,
      "referenceNumber": referenceNumber,
      "interfaceTypeId": interfaceTypeId,
      "settingList": settingList.map((e) => e.toJson()).toList(),
    };
  }
}