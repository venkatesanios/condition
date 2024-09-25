import 'dart:convert';

Groupedname groupednameFromJson(String str) =>
    Groupedname.fromJson(json.decode(str));

String groupednameToJson(Groupedname data) => json.encode(data.toJson());

class Groupedname {
  int? code;
  String? message;
  Data? data;

  Groupedname({
    this.code,
    this.message,
    this.data,
  });

  factory Groupedname.fromJson(Map<dynamic, dynamic> json) => Groupedname(
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
  List<Group>? line;
  List<Group>? group;

  Data({
    this.line,
    this.group,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    line: json["line"] == null
        ? []
        : List<Group>.from(json["line"]!.map((x) => Group.fromJson(x))),
    group: json["group"] == null
        ? []
        : List<Group>.from(json["group"]!.map((x) => Group.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "line": line == null
        ? []
        : List<dynamic>.from(line!.map((x) => x.toJson())),
    "group": group == null
        ? []
        : List<dynamic>.from(group!.map((x) => x.toJson())),
  };
}

class Group {
  int? sNo;
  String? id;
  String? hid;
  String? location;
  String? name;
  List<Valveselect>? valve;

  Group({
    this.sNo,
    this.id,
    this.hid,
    this.location,
    this.name,
    this.valve,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    location: json["location"],
    name: json["name"],
    valve: json["valve"] == null
        ? []
        : List<Valveselect>.from(json["valve"]!.map((x) => Valveselect.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "location": location,
    "name": name,
    "valve": valve == null
        ? []
        : List<dynamic>.from(valve!.map((x) => x.toJson())),
  };
}



class Valveselect {
  int? sNo;
  String? id;
  String? hid;
  String? location;
  String? name;

  Valveselect({
    this.sNo,
    this.id,
    this.hid,
    this.location,
    this.name,
  });

  factory Valveselect.fromJson(Map<String, dynamic> json) => Valveselect(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    location: json["location"],
    name: json["name"],

  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "location": location,
    "name": name,

  };
}