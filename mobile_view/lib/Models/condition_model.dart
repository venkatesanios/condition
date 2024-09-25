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
  List<UserNames>? digitalSensor;
  List<UserNames>? moistureSensor;
  List<UserNames>? levelSensor;
  List<UserNames>? waterMeter;
  List<UserNames>? contact;
  List<UserNames>? condition;
  List<UserNames>? sequence;
  // List<UserNames>? pressureSensor;
  List<UserNames>? pressureSwitch;
  List<UserNames>? float;
  List<UserNames>? sumpFloathigh;
  List<UserNames>? topFloathigh;
  List<UserNames>? sumpFloatlow;
  List<UserNames>? topFloatlow;
  List<UserNames>? manualButton;

  // List<ConditionLibrary>? conditionLibrary;
  List<ConditionLibrary>? conditionProgram;
  List<ConditionLibrary>? conditionMoisture;
  List<ConditionLibrary>? conditionLevel;

  Data({
    this.dropdown,
    this.program,
    this.analogSensor,
    this.digitalSensor,
    this.moistureSensor,
    this.levelSensor,
    this.waterMeter,
    this.contact,
    this.condition,
    this.sequence,
    this.float,
    this.sumpFloathigh,
    this.topFloathigh,
    this.sumpFloatlow,
    this.topFloatlow,
    this.manualButton,
    // this.pressureSensor,
    this.pressureSwitch,
    // this.conditionLibrary,
    this.conditionProgram,
    this.conditionMoisture,
    this.conditionLevel,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    json['default']["analogSensor"] = json['default']["analogSensor"];
    return Data(
      // dropdown: json['default']["dropdown"] == null
      //     ? []
      //     : List<String>.from(json['default']["dropdown"]!.map((x) => x)),

      // "Analog Sensor reading is higher than",
      //                 "Analog Sensor reading is lower than",

      dropdown: _buildDropdown(json),

      program: json['default']["program"] == null
          ? []
          : List<UserNames>.from(
          json['default']["program"]!.map((x) => UserNames.fromJson(x))),

      analogSensor: json['default']["analogSensor"] == null
          ? []
          : List<UserNames>.from(json['default']["analogSensor"]!
          .map((x) => UserNames.fromJson(x))),
      digitalSensor: json['default']["digitalSensor"] == null
          ? []
          : List<UserNames>.from(json['default']["digitalSensor"]!
          .map((x) => UserNames.fromJson(x))),

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
      sequence: json['default']["sequence"] == null
          ? []
          : List<UserNames>.from(
          json['default']["sequence"]!.map((x) => UserNames.fromJson(x))),
      // pressureSensor: json['default']["pressureSensor"] == null
      //     ? []
      //     : List<UserNames>.from(json['default']["pressureSensor"]!
      //     .map((x) => UserNames.fromJson(x))),
      // pressureSwitch: json['default']["pressureSwitch"] == null
      //     ? []
      //     : List<UserNames>.from(json['default']["pressureSwitch"]!
      //     .map((x) => UserNames.fromJson(x))),

      sumpFloathigh: _floatsumphigh(List<UserNames>.from(
          json['default']["float"]!.map((x) => UserNames.fromJson(x)))),
      topFloathigh: _floattophigh(List<UserNames>.from(
          json['default']["float"]!.map((x) => UserNames.fromJson(x)))),
      sumpFloatlow: _floatsumplow(List<UserNames>.from(
          json['default']["float"]!.map((x) => UserNames.fromJson(x)))),
      topFloatlow: _floattoplow(List<UserNames>.from(
          json['default']["float"]!.map((x) => UserNames.fromJson(x)))),

      float: json['default']["float"] == null
          ? []
          : List<UserNames>.from(
          json['default']["float"]!.map((x) => UserNames.fromJson(x))),

      manualButton: json['default']["manualButton"] == null
          ? []
          : List<UserNames>.from(json['default']["manualButton"]!
          .map((x) => UserNames.fromJson(x))),

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
  }

  static List<String> _buildDropdown(Map<String, dynamic> json) {
    List<String> dropdown = json['default']["dropdown"] == null
        ? []
        : List<String>.from(json['default']["dropdown"]!.map((x) => x));

    if (json['default']["program"] == null ||
        json['default']["program"].isEmpty) {
      dropdown.remove("Program is running");
      dropdown.remove("Program is not running");
      dropdown.remove("Program is starting");
      dropdown.remove("Program is ending");
    }
    if (json['default']["contact"] == null ||
        json['default']["contact"].isEmpty) {
      dropdown.remove("Contact is opened");
      dropdown.remove("Contact is closed");
      dropdown.remove("Contact is opening");
      dropdown.remove("Contact is closing");
    }
    // if (json['default']["waterMeter"] == null ||
    //     json['default']["waterMeter"].isEmpty) {
    //   dropdown.remove("Water meter flow is higher than");
    //   dropdown.remove("Water meter flow is lower than");
    // }
    if (json['default']["analogSensor"] == null ||
        json['default']["analogSensor"].isEmpty) {
      dropdown.remove("Analog Sensor reading is higher than");
      dropdown.remove("Analog Sensor reading is lower than");
    }
    if (json['default']["digitalSensor"] == null ||
        json['default']["digitalSensor"].isEmpty) {
      dropdown.remove("Digital Sensor reading is higher than");
      dropdown.remove("Digital Sensor reading is lower than");
    }
    if (json['default']["moistureSensor"] == null ||
        json['default']["moistureSensor"].isEmpty) {
      dropdown.remove("Moisture Sensor reading is higher than");
      dropdown.remove("Moisture Sensor reading is lower than");
    }
    if (json['default']["levelSensor"] == null ||
        json['default']["levelSensor"].isEmpty) {
      dropdown.remove("Level Sensor reading is higher than");
      dropdown.remove("Level Sensor reading is lower than");
    }
    if (json['default']["manualButton"] == null ||
        json['default']["manualButton"].isEmpty) {
      dropdown.remove("Manual Button");
    }
    // print('dropdowm:$dropdown');
    // if (json['default']["pressureSensor"] == null ||
    //     json['default']["pressureSensor"].isEmpty) {
    //   dropdown.remove("Analog Sensor reading is higher than");
    //   dropdown.remove("Analog Sensor reading is lower than");
    //
    // }
    if (json['default']["pressureSwitch"] == null ||
        json['default']["pressureSwitch"].isEmpty) {
      dropdown.remove(["Pressure Switch is High", "Pressure Switch is Low"]);
      dropdown.remove("Pressure Switch is Low");
      dropdown.remove("Pressure Switch is High");
    }
    // print('dropdowm:$dropdown');
    if (json['default']["condition"] == null ||
        json['default']["condition"].isEmpty) {
      dropdown.remove("Combined condition is true");
      dropdown.remove("Combined condition is false");
    }
    // if (json['default']["float"] == null ||
    //     json['default']["float"].isEmpty) {
    List<UserNames> topfloathigh = _floattophigh(List<UserNames>.from(
        json['default']["float"]!.map((x) => UserNames.fromJson(x))));

    List<UserNames> sumpfloathigh = _floatsumphigh(List<UserNames>.from(
        json['default']["float"]!.map((x) => UserNames.fromJson(x))));

    List<UserNames> topfloatlow = _floattoplow(List<UserNames>.from(
        json['default']["float"]!.map((x) => UserNames.fromJson(x))));

    List<UserNames> sumpfloatlow = _floatsumplow(List<UserNames>.from(
        json['default']["float"]!.map((x) => UserNames.fromJson(x))));

    if (topfloathigh.isEmpty) {
      dropdown.remove("Top Tank is High");
    }
    if (sumpfloathigh.isEmpty) {
      dropdown.remove("Sump Tank is High");
    }
    if (topfloatlow.isEmpty) {
      dropdown.remove("Top Tank is Low");
    }
    if (sumpfloatlow.isEmpty) {
      dropdown.remove("Sump Tank is Low");
    }
    // }
    // print('dropdowm:$dropdown');
    return dropdown;
  }

//Low 1 high 2 3->position
  static List<UserNames> _floatsumphigh(List<UserNames> json) {
    List<UserNames> floatsump = [];
    for (var floatval in json) {
      List<String> components = floatval.hid!.split('.');
      if (components[2] == '2') {
        if (components[3] == '2') {
          floatsump.add(floatval);
        }
      }
    }
    return floatsump;
  }

  static List<UserNames> _floatsumplow(List<UserNames> json) {
    List<UserNames> floatsump = [];
    for (var floatval in json) {
      List<String> components = floatval.hid!.split('.');
      if (components[2] == '2') {
        if (components[3] == '1') {
          floatsump.add(floatval);
        }
      }
    }
    return floatsump;
  }

  static List<UserNames> _floattophigh(List<UserNames> json) {
    List<UserNames> floatsump = [];
    for (var floatval in json) {
      List<String> components = floatval.hid!.split('.');
      if (components[2] == '1') {
        if (components[3] == '2') {
          floatsump.add(floatval);
        }
      }
    }
    return floatsump;
  }

  static List<UserNames> _floattoplow(List<UserNames> json) {
    List<UserNames> floatsump = [];
    for (var floatval in json) {
      List<String> components = floatval.hid!.split('.');
      if (components[2] == '1') {
        if (components[3] == '1') {
          floatsump.add(floatval);
        }
      }
    }
    return floatsump;
  }

  Map<String, dynamic> toJson() => {
    "dropdown":
    dropdown == null ? [] : List<dynamic>.from(dropdown!.map((x) => x)),
    "program":
    program == null ? [] : List<dynamic>.from(program!.map((x) => x)),
    "analogSensor": analogSensor == null
        ? []
        : List<dynamic>.from(analogSensor!.map((x) => x)),
    "digitalSensor": digitalSensor == null
        ? []
        : List<dynamic>.from(digitalSensor!.map((x) => x)),

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
    "sequence": sequence == null
        ? []
        : List<dynamic>.from(sequence!.map((x) => x.toJson())),
    "pressureSwitch": pressureSwitch == null
        ? []
        : List<dynamic>.from(pressureSwitch!.map((x) => x.toJson())),
    "float": float == null
        ? []
        : List<dynamic>.from(float!.map((x) => x.toJson())),
    // "conditionLibrary": conditionLibrary == null
    //     ? []
    //     : List<dynamic>.from(conditionLibrary!.map((x) => x.toJson())),
  };
}

class UserNames {
  dynamic sNo;
  String? id;
  String? hid;
  String? location;
  String? name;
  String? conditionIsTrueWhen;
  String? locationName;
  List<dynamic>? irrigationLine;

  UserNames({
    this.sNo,
    this.id,
    this.hid,
    this.location,
    this.name,
    this.conditionIsTrueWhen,
    this.locationName,
    this.irrigationLine,
  });

  factory UserNames.fromJson(Map<String, dynamic> json) => UserNames(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    location: json["location"],
    name: json["name"],
    conditionIsTrueWhen: json["conditionIsTrueWhen"],
    locationName: json["locationName"],
    irrigationLine: json["irrigationLine"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "location": location,
    "name": name,
    "locationName": locationName,
    "conditionIsTrueWhen": conditionIsTrueWhen,
    "irrigationLine": irrigationLine,
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
  bool? conditionBypass;
  String? usedByProgram;
  String? program;
  String? zone;
  String? dropdown1;
  String? dropdown2;
  String? dropdown3;
  String? dropdownValue;
  String? afterTime;
  String? beforeTime;
  String? afterProgram;
  String? beforeProgram;

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
    this.conditionBypass,
    this.usedByProgram,
    this.program,
    this.zone,
    this.dropdown1,
    this.dropdown2,
    this.dropdown3,
    this.dropdownValue,
    this.afterTime,
    this.beforeTime,
    this.afterProgram,
    this.beforeProgram,
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
        conditionBypass: json["conditionBypass"] ?? false,
        usedByProgram: json["usedByProgram"],
        program: json["program"],
        zone: json["zone"],
        dropdown1: json["dropdown1"],
        dropdown2: json["dropdown2"],
        dropdown3: json["dropdown3"],
        dropdownValue: json["dropdownValue"],
        afterTime: json["afterTime"],
        beforeTime: json["beforeTime"],
        afterProgram: json["afterProgram"],
        beforeProgram: json["beforeProgram"],
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
    "conditionBypass": conditionBypass,
    "usedByProgram": usedByProgram,
    "program": usedByProgram,
    "zone": zone,
    "dropdown1": dropdown1,
    "dropdown2": dropdown2,
    "dropdown3": dropdown3,
    "dropdownValue": dropdownValue,
    "afterTime": afterTime,
    "beforeTime": beforeTime,
    "afterProgram": afterProgram,
    "beforeProgram": beforeProgram,
  };
}
