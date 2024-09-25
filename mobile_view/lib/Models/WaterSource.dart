
import 'dart:convert';

Watersource watersourceFromJson(String str) =>
    Watersource.fromJson(json.decode(str));

String watersourceToJson(Watersource data) => json.encode(data.toJson());

class Watersource {
  int? code;
  String? message;
  List<Datum>? data;

  Watersource({
    this.code,
    this.message,
    this.data,
  });

  factory Watersource.fromJson(Map<String, dynamic> json) => Watersource(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
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
  List<Source>? source;

  Datum({
    this.sNo,
    this.id,
    this.hid,
    this.name,
    this.location,
    this.source,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"],
    name: json["name"],
    location: json["location"],
    source: json["setting"] == null
        ? []
        : List<Source>.from(json["setting"]!.map((x) => Source.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "name": name,
    "location": location,
    "setting": source == null
        ? []
        : List<dynamic>.from(source!.map((x) => x.toJson())),
  };
}

class Source {
  int? sNo;
  String? title;
  int? widgetTypeId;
  String? iconCodePoint;
  String? iconFontFamily;
  String? value;
  bool? hidden;
  List<String>? dropdown;

  Source({
    this.sNo,
    this.title,
    this.widgetTypeId,
    this.iconCodePoint,
    this.iconFontFamily,
    this.value,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
    sNo: json["sNo"],
    title: json["title"],
    widgetTypeId: json["widgetTypeId"],
    iconCodePoint: json["iconCodePoint"],
    iconFontFamily: json["iconFontFamily"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "title": title,
    "widgetTypeId": widgetTypeId,
    "iconCodePoint": iconCodePoint,
    "iconFontFamily": iconFontFamily,
    "value": value,

  };
}
