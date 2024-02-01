
import 'dart:convert';

import 'package:flutter/material.dart';

ConditionModel conditionModelFromJson(String str) =>
    ConditionModel.fromJson(json.decode(str));

String conditionModelToJson(ConditionModel data) => json.encode(data.toJson());

class ConditionModel {
  int? code;
  String? message;
  Data? data;

  ConditionModel({
    this.code,
    this.message,
    this.data,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) => ConditionModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<String>? dropdown;
  List<UserNames>? program;
  List<UserNames>? analogSensor;
  List<UserNames>? moistureSensor;
  List<UserNames>? levelSensor;
  List<UserNames>? waterMeter;
  List<UserNames>? contact;
  List<UserNames>? condition;
  // List<ConditionLibrary>? conditionLibrary;
  List<ConditionLibrary>? conditionProgram;
  List<ConditionLibrary>? conditionMoisture;
  List<ConditionLibrary>? conditionLevel;


  Data({
    this.dropdown,
    this.program,
    this.analogSensor,
    this.moistureSensor,
    this.levelSensor,
    this.waterMeter,
    this.contact,
    this.condition,
    // this.conditionLibrary,
    this.conditionProgram,
    this.conditionMoisture,
    this.conditionLevel,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    dropdown: json['default']["dropdown"] == null
        ? []
        : List<String>.from(json['default']["dropdown"]!.map((x) => x)),
    program: json['default']["program"] == null
        ? []
        : List<UserNames>.from(
        json['default']["program"]!.map((x) => UserNames.fromJson(x))),
    analogSensor: json['default']["analogSensor"] == null
        ? []
        : List<UserNames>.from(
        json['default']["analogSensor"]!.map((x) => UserNames.fromJson(x))),

    moistureSensor: json['default']["moistureSensor"] == null
        ? []
        : List<UserNames>.from(json['default']["moistureSensor"]!
        .map((x) => UserNames.fromJson(x))),

    levelSensor: json['default']["levelSensor"] == null
        ? []
        : List<UserNames>.from(json['default']["levelSensor"]!
        .map((x) => UserNames.fromJson(x))),
    waterMeter: json['default']["waterMeter"] == null
        ? []
        : List<UserNames>.from(
        json['default']["waterMeter"]!.map((x) => UserNames.fromJson(x))),
    contact: json['default']["contact"] == null
        ? []
        : List<UserNames>.from(
        json['default']["contact"]!.map((x) => UserNames.fromJson(x))),
    condition: json['default']["condition"] == null
        ? []
        : List<UserNames>.from(
        json['default']["condition"]!.map((x) => UserNames.fromJson(x))),

    // conditionLibrary: json["conditionLibrary"]["program"] == null
    //     ? []
    //     : List<ConditionLibrary>.from(json["conditionLibrary"]["program"]!
    //         .map((x) => ConditionLibrary.fromJson(x))),
    conditionProgram: json["conditionLibrary"]["program"] == null
        ? []
        : List<ConditionLibrary>.from(json["conditionLibrary"]["program"]!
        .map((x) => ConditionLibrary.fromJson(x))),
    conditionMoisture: json["conditionLibrary"]["moisture"] == null
        ? []
        : List<ConditionLibrary>.from(json["conditionLibrary"]["moisture"]!
        .map((x) => ConditionLibrary.fromJson(x))),
    conditionLevel: json["conditionLibrary"]["level"] == null
        ? []
        : List<ConditionLibrary>.from(json["conditionLibrary"]["level"]!
        .map((x) => ConditionLibrary.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "dropdown":
    dropdown == null ? [] : List<dynamic>.from(dropdown!.map((x) => x)),
    "program":
    program == null ? [] : List<dynamic>.from(program!.map((x) => x)),
    "analogSensor": analogSensor == null
        ? []
        : List<dynamic>.from(analogSensor!.map((x) => x)),

    "moistureSensor": moistureSensor == null
        ? []
        : List<dynamic>.from(moistureSensor!.map((x) => x)),

    "levelSensor": levelSensor == null
        ? []
        : List<dynamic>.from(levelSensor!.map((x) => x)),
    "waterMeter": waterMeter == null
        ? []
        : List<dynamic>.from(waterMeter!.map((x) => x)),
    "contact": contact == null
        ? []
        : List<dynamic>.from(contact!.map((x) => x.toJson())),
    "condition": condition == null
        ? []
        : List<dynamic>.from(condition!.map((x) => x.toJson())),
    // "conditionLibrary": conditionLibrary == null
    //     ? []
    //     : List<dynamic>.from(conditionLibrary!.map((x) => x.toJson())),
  };
}

class UserNames {
  dynamic sNo;
  String? id;
  String? location;
  String? name;

  UserNames({
    this.sNo,
    this.id,
    this.location,
    this.name,
  });

  factory UserNames.fromJson(Map<String, dynamic> json) => UserNames(
    sNo: json["sNo"],
    id: json["id"],
    location: json["location"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "location": location,
    "name": name,
  };
}

class ConditionLibrary {
  dynamic sNo;
  String? id;
  String? location;
  String? name;
  bool? enable;
  String? state;
  String? duration;
  String? conditionIsTrueWhen;
  String? fromTime;
  String? untilTime;
  bool? notification;
  String? usedByProgram;
  String? program;
  String? zone;
  String? dropdown1;
  String? dropdown2;
  String? dropdownValue;

  ConditionLibrary({
    this.sNo,
    this.id,
    this.location,
    this.name,
    this.enable,
    this.state,
    this.duration,
    this.conditionIsTrueWhen,
    this.fromTime,
    this.untilTime,
    this.notification,
    this.usedByProgram,
    this.program,
    this.zone,
    this.dropdown1,
    this.dropdown2,
    this.dropdownValue,
  });

  factory ConditionLibrary.fromJson(Map<String, dynamic> json) =>
      ConditionLibrary(
        sNo: json["sNo"],
        id: json["id"],
        location: json["location"],
        name: json["name"],
        enable: json["enable"],
        state: json["state"],
        duration: json["duration"],
        conditionIsTrueWhen: json["conditionIsTrueWhen"],
        fromTime: json["fromTime"],
        untilTime: json["untilTime"],
        notification: json["notification"],
        usedByProgram: json["usedByProgram"],
        program: json["program"],
        zone: json["zone"],
        dropdown1: json["dropdown1"],
        dropdown2: json["dropdown2"],
        dropdownValue: json["dropdownValue"],
      );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "location": location,
    "name": name,
    "enable": enable,
    "state": state,
    "duration": duration,
    "conditionIsTrueWhen": conditionIsTrueWhen,
    "fromTime": fromTime,
    "untilTime": untilTime,
    "notification": notification,
    "usedByProgram": usedByProgram,
    "program": usedByProgram,
    "zone": zone,
    "dropdown1": dropdown1,
    "dropdown2": dropdown2,
    "dropdownValue": dropdownValue,
  };

  String toMqttformat() {
    String enablevalue = enable! ? '1' : '0';
    String conditionIsTrueWhenvalue = '0,0,0,0';
    // bool conditiontrue = conditionIsTrueWhen!.contains('other');
    //  1 "Program is running",
    //  2 "Program not running",
    //  3 "Program is starting",
    //  4 "Program is ending",
    //  5 "Contact is opened",
    //  6 "Contact is closed",
    //  7 "Contact is opening",
    //  8 "Contact is closing",
    //  9 "Zone is low flow than",
    // 10 "Zone is high flow than",
    // 11  "Zone is no flow than",
    // 12  "Water meter flow is higher than",
    // 13  "Water meter flow is lower than",
    // 14  "Sensor reading is higher than",
    // 15  "Sensor reading is lower than",
    // 16  "Combined condition is true",
    // 17  "Combined condition is false"

    if (conditionIsTrueWhen!.contains('Program')) {
      if (conditionIsTrueWhen!.contains('Program is running')) {
        conditionIsTrueWhenvalue = "1,1,$program,0";
      } else if (conditionIsTrueWhen!.contains('Program not running')) {
        conditionIsTrueWhenvalue = "1,2,$program,0";
      } else if (conditionIsTrueWhen!.contains('Program is starting')) {
        conditionIsTrueWhenvalue = "1,3,$program,0";
      } else if (conditionIsTrueWhen!.contains('Program is ending')) {
        conditionIsTrueWhenvalue = "1,4,$program,0";
      } else {
        conditionIsTrueWhenvalue = "1,0,0,0";
      }
    } else if (conditionIsTrueWhen!.contains('Contact')) {
      if (conditionIsTrueWhen!.contains('Contact is opened')) {
        conditionIsTrueWhenvalue = "2,5,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!.contains('Contact is closed')) {
        conditionIsTrueWhenvalue = "2,6,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!.contains('Contact is opening')) {
        conditionIsTrueWhenvalue = "2,7,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!.contains('Contact is closing')) {
        conditionIsTrueWhenvalue = "2,8,$program,$dropdownValue";
      } else {
        conditionIsTrueWhenvalue = "2,0,0,0";
      }
    } else if (conditionIsTrueWhen!.contains('Zone')) {
      if (conditionIsTrueWhen!.contains('Zone is low flow than')) {
        conditionIsTrueWhenvalue = "6,9,0,0";
      } else if (conditionIsTrueWhen!.contains('Zone is high flow than')) {
        conditionIsTrueWhenvalue = "6,10,0,0";
      } else if (conditionIsTrueWhen!.contains('Zone is no flow than')) {
        conditionIsTrueWhenvalue = "6,11,0,0";
      } else {
        conditionIsTrueWhenvalue = "6,0,0,0";
      }
    } else if (conditionIsTrueWhen!.contains('Water')) {
      if (conditionIsTrueWhen!.contains('Water meter flow is higher than')) {
        conditionIsTrueWhenvalue = "4,12,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!
          .contains('Water meter flow is lower than')) {
        conditionIsTrueWhenvalue = "4,13,$program,$dropdownValue";
      } else {
        conditionIsTrueWhenvalue = "4,0,0,0";
      }
    } else if (conditionIsTrueWhen!.contains('Sensor')) {
      if (conditionIsTrueWhen!.contains('Sensor reading is higher than')) {
        conditionIsTrueWhenvalue = "3,14,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!
          .contains('Sensor reading is lower than')) {
        conditionIsTrueWhenvalue = "3,15,$program,$dropdownValue";
      } else {
        conditionIsTrueWhenvalue = "3,0,0,0";
      }
    } else if (conditionIsTrueWhen!.contains('Combined')) {
      if (conditionIsTrueWhen!.contains('Combined condition is true')) {
        conditionIsTrueWhenvalue = "5,16,$program,$dropdownValue";
      } else if (conditionIsTrueWhen!.contains('Combined condition is false')) {
        conditionIsTrueWhenvalue = "5,17,$program,$dropdownValue";
      } else {
        conditionIsTrueWhenvalue = "5,0,0,0";
      }
    } else {
      conditionIsTrueWhenvalue = "0,0,0,0";
    }

    return '$sNo,$name,$enablevalue,$duration,$conditionIsTrueWhenvalue,$fromTime,$untilTime,$notification;';
  }
}