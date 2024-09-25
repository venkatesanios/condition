

import 'dart:convert';

HiddenMenu hiddenMenuFromJson(String str) => HiddenMenu.fromJson(json.decode(str));

String hiddenMenuToJson(HiddenMenu data) => json.encode(data.toJson());

class HiddenMenu {
  int? code;
  String? message;
  List<Datum>? data;

  HiddenMenu({
    this.code,
    this.message,
    this.data,
  });

  factory HiddenMenu.fromJson(Map<String, dynamic> json) => HiddenMenu(
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
  int? dealerDefinitionId;
  String? parameter;
  String? value;

  Datum({
    this.dealerDefinitionId,
    this.parameter,
    this.value,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    dealerDefinitionId: json["dealerDefinitionId"],
    parameter: json["parameter"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "dealerDefinitionId": dealerDefinitionId,
    "parameter": parameter,
    "value": value,
  };
}
