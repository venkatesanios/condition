import 'dart:convert';

List<NamesModel> namesModelFromJson(String str) => List<NamesModel>.from(json.decode(str).map((x) => NamesModel.fromJson(x)));

String namesModelToJson(List<NamesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NamesModel {
  int? nameTypeId;
  String? nameDescription;
  List<UserName>? userName;

  NamesModel({
    this.nameTypeId,
    this.nameDescription,
    this.userName,
  });

  factory NamesModel.fromJson(Map<String, dynamic> json) => NamesModel(
    nameTypeId: json["nameTypeId"],
    nameDescription: json["nameDescription"],
    userName: json["userName"] == null ? [] : List<UserName>.from(json["userName"]!.map((x) => UserName.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "nameTypeId": nameTypeId,
    "nameDescription": nameDescription,
    "userName": userName == null ? [] : List<dynamic>.from(userName!.map((x) => x.toJson())),
  };
}

class UserName {
  dynamic sNo;
  String? id;
  String? hid;
  String? name;
  String? location;
  String? type;
  String? deviceId;

  UserName({
    this.sNo,
    this.id,
    this.hid,
    this.name,
    this.location,
    this.type,
    this.deviceId,
  });

  factory UserName.fromJson(Map<String, dynamic> json) => UserName(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    name: json["name"],
    location: json["location"],
    type: json["type"],
    deviceId: json["deviceId"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "name": name,
    "location": location,
    "type": type,
    "deviceId": deviceId,
  };
}
