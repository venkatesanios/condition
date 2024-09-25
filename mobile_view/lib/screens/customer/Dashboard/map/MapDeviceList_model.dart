// To parse this JSON data, do
//
//     final deviceListMap = deviceListMapFromJson(jsonString);

import 'dart:convert';

DeviceListMap deviceListMapFromJson(String str) => DeviceListMap.fromJson(json.decode(str));

String deviceListMapToJson(DeviceListMap data) => json.encode(data.toJson());

class DeviceListMap {
  int? code;
  String? message;
  List<Datum>? data;

  DeviceListMap({
    this.code,
    this.message,
    this.data,
  });

  factory DeviceListMap.fromJson(Map<String, dynamic> json) => DeviceListMap(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? controllerId;
  String? deviceId;
  String? deviceName;
  String? siteName;
  String? categoryName;
  String? modelName;
  Geography? geography;
  List<NodeList>? nodeList;

  Datum({
    this.controllerId,
    this.deviceId,
    this.deviceName,
    this.siteName,
    this.categoryName,
    this.modelName,
    this.geography,
    this.nodeList,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      controllerId: json["controllerId"],
      deviceId: json["deviceId"],
      deviceName: json["deviceName"],
      siteName: json["siteName"],
      categoryName: json["categoryName"],
      modelName: json["modelName"],
      geography: json["geography"] == null ? null : Geography.fromJson(json["geography"]),
      nodeList: json["nodeList"] == null ? [] : List<NodeList>.from(json["nodeList"]!.map((x) => NodeList.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "controllerId": controllerId,
    "deviceId": deviceId,
    "deviceName": deviceName,
    "siteName": siteName,
    "categoryName": categoryName,
    "modelName": modelName,
    "geography": geography?.toJson(),
    "nodeList": nodeList == null ? [] : List<dynamic>.from(nodeList!.map((x) => x.toJson())),
  };
}

class Geography {
  int? wifiStrength;
  String? latLong;
  int? sNo;
  dynamic sVolt;
  dynamic batVolt;
  int? refNo;
  String? deviceId;
  String? deviceTypeNumber;
  List<RlyStatus>? rlyStatus;
  List<Sensor>? sensor;
  int? status;

  Geography({
    this.wifiStrength,
    this.latLong,
    this.sNo,
    this.sVolt,
    this.batVolt,
    this.refNo,
    this.deviceId,
    this.deviceTypeNumber,
    this.rlyStatus,
    this.sensor,
    this.status,
  });

  factory Geography.fromJson(Map<String, dynamic> json) {

    return  Geography(
      wifiStrength: json["WifiStrength"],
      latLong: json["Lat_Long"],
      sNo: json["SNo"],
      sVolt: json["SVolt"] ?? 0,
      batVolt: json["BatVolt"] ?? 0,
      refNo: json["RefNo"],
      deviceId: json["DeviceId"],
      deviceTypeNumber: json["DeviceTypeNumber"],
      rlyStatus: json["RlyStatus"] == null ? [] : List<RlyStatus>.from(json["RlyStatus"]!.map((x) => RlyStatus.fromJson(x))),
      sensor: json["Sensor"] == null ? [] : List<Sensor>.from(json["Sensor"]!.map((x) => Sensor.fromJson(x))),
      status: json["Status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "WifiStrength": wifiStrength,
    "Lat_Long": latLong,
    "SNo": sNo,
    "SVolt": sVolt,
    "BatVolt": batVolt,
    "RefNo": refNo,
    "DeviceId": deviceId,
    "DeviceTypeNumber": deviceTypeNumber,
    "RlyStatus": rlyStatus == null ? [] : List<dynamic>.from(rlyStatus!.map((x) => x.toJson())),
    "Sensor": sensor == null ? [] : List<dynamic>.from(sensor!.map((x) => x.toJson())),
    "Status": status,
  };
}

class RlyStatus {
  String? name;
  int? rlyNo;
  int? sNo;
  int? status;
  String? latLong;

  RlyStatus({
    this.name,
    this.rlyNo,
    this.sNo,
    this.status,
    this.latLong,
  });

  factory RlyStatus.fromJson(Map<String, dynamic> json) => RlyStatus(
    name: json["Name"],
    rlyNo: json["RlyNo"],
    sNo: json["S_No"],
    status: json["Status"],
    latLong: json["Lat_Long"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "RlyNo": rlyNo,
    "sNo": sNo,
    "Status": status,
    "Lat_Long": latLong,
  };
}

class Sensor {
  int? sNo;
  String? name;
  int? digIpNo;
  String? value;
  String? latLong;
  int? angIpNo;
  int? pulseIpNo;

  Sensor({
    this.sNo,
    this.name,
    this.digIpNo,
    this.value,
    this.latLong,
    this.angIpNo,
    this.pulseIpNo,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    sNo: json["S_No"],
    name: json["Name"],
    digIpNo: json["DigIpNo"],
    value: json["Value"],
    latLong: json["Lat_Long"],
    angIpNo: json["AngIpNo"],
    pulseIpNo: json["PulseIpNo"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "Name": name,
    "DigIpNo": digIpNo,
    "Value": value,
    "Lat_Long": latLong,
    "AngIpNo": angIpNo,
    "PulseIpNo": pulseIpNo,
  };
}

class NodeList {
  int? controllerId;
  String? modelName;
  String? categoryName;
  String? deviceId;
  String? deviceName;
  int? referenceNumber;
  int? serialNumber;
  Geography? geography;

  NodeList({
    this.controllerId,
    this.modelName,
    this.categoryName,
    this.deviceId,
    this.deviceName,
    this.referenceNumber,
    this.serialNumber,
    this.geography,
  });

  factory NodeList.fromJson(Map<String, dynamic> json) => NodeList(
    controllerId: json["controllerId"],
    modelName: json["modelName"],
    categoryName: json["categoryName"],
    deviceId: json["deviceId"],
    deviceName: json["deviceName"],
    referenceNumber: json["referenceNumber"],
    serialNumber: json["serialNumber"],
    geography: json["geography"] == null ? null : Geography.fromJson(json["geography"]),
  );

  Map<String, dynamic> toJson() => {
    "controllerId": controllerId,
    "modelName": modelName,
    "categoryName": categoryName,
    "deviceId": deviceId,
    "deviceName": deviceName,
    "referenceNumber": referenceNumber,
    "serialNumber": serialNumber,
    "geography": geography?.toJson(),
  };
}


















