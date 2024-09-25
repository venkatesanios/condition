

import 'dart:convert';

RqadiationSet rqadiationSetFromJson(String str) =>
    RqadiationSet.fromJson(json.decode(str));

String rqadiationSetToJson(RqadiationSet data) => json.encode(data.toJson());

class RqadiationSet {
  List<Datum>? data;

  RqadiationSet({
    this.data,
  });

  factory RqadiationSet.fromJson(Map<String, dynamic> json) => RqadiationSet(
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? sNo;
  String? id;
  String? hid;
  String? name;
  String? location;
  String? accumulated1;
  String? accumulated2;
  String? accumulated3;
  String? maxInterval1;
  String? maxInterval2;
  String? maxInterval3;
  String? minInterval1;
  String? minInterval2;
  String? minInterval3;
  String? coefficient;
  String? usedByProgram;

  Datum({
    this.sNo,
    this.id,
    this.hid,
    this.name,
    this.location,
    this.accumulated1,
    this.accumulated2,
    this.accumulated3,
    this.maxInterval1,
    this.maxInterval2,
    this.maxInterval3,
    this.minInterval1,
    this.minInterval2,
    this.minInterval3,
    this.coefficient,
    this.usedByProgram,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    name: json["name"],
    location: json["location"],
    accumulated1: json["accumulated1"],
    accumulated2: json["accumulated2"],
    accumulated3: json["accumulated3"],
    maxInterval1: json["maxInterval1"],
    maxInterval2: json["maxInterval2"],
    maxInterval3: json["maxInterval3"],
    minInterval1: json["minInterval1"],
    minInterval2: json["minInterval2"],
    minInterval3: json["minInterval3"],
    coefficient: json["coefficient"],
    usedByProgram: json["usedByProgram"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "name": name,
    "location": location,
    "accumulated1": accumulated1,
    "accumulated2": accumulated2,
    "accumulated3": accumulated3,
    "maxInterval1": maxInterval1,
    "maxInterval2": maxInterval2,
    "maxInterval3": maxInterval3,
    "minInterval1": minInterval1,
    "minInterval2": minInterval2,
    "minInterval3": minInterval3,
    "coefficient": coefficient,
    "usedByProgram": usedByProgram,
  };
}
