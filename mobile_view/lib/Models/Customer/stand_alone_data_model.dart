class NameData {
  dynamic sNo;
  dynamic id;
  String hid;
  String location;
  String name;
  bool selected;

  NameData({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.location,
    required this.name,
    required this.selected,
  });

  factory NameData.fromJson(Map<String, dynamic> json) => NameData(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"] ?? "",
    location: json["location"],
    name: json["name"],
    selected: json["selected"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "location": location,
    "name": name,
    "selected": selected,
  };

  dynamic getSNoWhereSelectedIsTrue() {
    if (selected == true) {
      return sNo;
    }
    return null;
  }
}

class ManualOperationData {
  int method;
  int startFlag;
  String time;
  String flow;
  List<NameData> sourcePump;
  List<NameData> irrigationPump;
  List<NameData> mainValve;
  List<NameData> agitator;
  List<NameData> boosterPump;
  List<NameData> selector;
  List<SiteData> centralFertilizerSite;
  List<SiteData> localFertilizerSite;
  List<SiteData> centralFilterSite;
  List<SiteData> localFilterSite;
  List<NameData> fan;
  List<NameData> fogger;
  // List<LineOrSequence> lineOrSequence;

  ManualOperationData({
    required this.startFlag,
    required this.method,
    required this.time,
    required this.flow,
    required this.sourcePump,
    required this.irrigationPump,
    required this.mainValve,
    // required this.lineOrSequence,
    required this.agitator,
    required this.boosterPump,
    required this.selector,
    required this.centralFertilizerSite,
    required this.localFertilizerSite,
    required this.centralFilterSite,
    required this.localFilterSite,
    required this.fan,
    required this.fogger,
  });

  factory ManualOperationData.fromJson(Map<String, dynamic> json) {
    return ManualOperationData(
      startFlag: json["startFlag"] ?? 0,
      method: (json['method'] != "" && json['method'] != null) ? json['method'] : 0,
      flow: (json['flow'] == "0") ? "100" : json['flow'] ?? "0",
      time: (json['duration'] == "00:00" ? "00:00:00" : json['duration']) ?? "00:00:00",
      sourcePump: json['sourcePump'] == null ? [] : List<NameData>.from(json['sourcePump'].map((x) => NameData.fromJson(x))),
      irrigationPump: json['irrigationPump'] == null ? [] : List<NameData>.from(json['irrigationPump'].map((x) => NameData.fromJson(x))),
      mainValve: json['mainValve'] == null ? [] : List<NameData>.from(json['mainValve'].map((x) => NameData.fromJson(x))),
      agitator: json['agitator'] == null ? [] : List<NameData>.from(json['agitator'].map((x) => NameData.fromJson(x))),
      fan: json['fan'] == null ? [] : List<NameData>.from(json['fan'].map((x) => NameData.fromJson(x))),
      fogger: json['fogger'] == null ? [] : List<NameData>.from(json['fogger'].map((x) => NameData.fromJson(x))),
      boosterPump: json['boosterPump'] == null ? [] : List<NameData>.from(json['boosterPump'].map((x) => NameData.fromJson(x))),
      selector: json['selector'] == null ? [] : List<NameData>.from(json['selector'].map((x) => NameData.fromJson(x))),
      centralFertilizerSite: json['centralFertilizerSite'] == null
          ? []
          : List<SiteData>.from(json['centralFertilizerSite'].map((x) => SiteData.fromJson(x, "fertilizer"))),
      localFertilizerSite: json['localFertilizer'] == null
          ? []
          : List<SiteData>.from(json['localFertilizer'].map((x) => SiteData.fromJson(x, "fertilizer"))),
      centralFilterSite: json['centralFilterSite'] == null
          ? []
          : List<SiteData>.from(json['centralFilterSite'].map((x) => SiteData.fromJson(x, "filter"))),
      localFilterSite: json['localFilter'] == null
          ? []
          : List<SiteData>.from(json['localFilter'].map((x) => SiteData.fromJson(x, "filter"))),
      // lineOrSequence: json['lineOrSequence'] == null
      //     ? []
      //     : List<LineOrSequence>.from(json['lineOrSequence'].map((x) => LineOrSequence.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> finalList = [];
    void addToFinalList(List<dynamic> list) {
      if(list.isNotEmpty) {
        for (var element in list) {
          if (element.selected) {
            finalList.add(element.toJson());
          } else {
            finalList.remove(element.toJson());
          }
        }
      }
    }
    void addToFinalList2(List<SiteData> list) {
      if(list.isNotEmpty) {
        for (var element in list) {
          for (var element in element.itemData) {
            if (element.selected) {
              finalList.add(element.toJson());
            } else {
              finalList.remove(element.toJson());
            }
          }
        }
      }
    }
    addToFinalList(sourcePump);
    addToFinalList(irrigationPump);
    addToFinalList(mainValve);
    addToFinalList2(centralFilterSite);
    addToFinalList2(localFertilizerSite);
    addToFinalList2(centralFertilizerSite);
    addToFinalList2(localFilterSite);
    addToFinalList(agitator);
    addToFinalList(boosterPump);
    addToFinalList(selector);
    addToFinalList(fan);
    addToFinalList(fogger);

    // print('finalList : ${finalList}');
    return {
      "startFlag": startFlag,
      "method": method,
      "time": time,
      "flow": flow,
      "selected": [...finalList],
    };
  }
}

class SiteData {
  final NameData site;
  final List<NameData> itemData;

  SiteData({
    required this.site,
    required this.itemData,
  });

  factory SiteData.fromJson(Map<String, dynamic> json, item) {
    var fertilizerList = json[item] as List;
    List<NameData> fertilizer = fertilizerList.map((e) => NameData.fromJson(e)).toList();

    return SiteData(
      site: NameData.fromJson(json),
      itemData: fertilizer,
    );
  }
}

class LineOrSequence {
  final NameData lineOrSequence;
  final List<NameData> valves;

  LineOrSequence({
    required this.lineOrSequence,
    required this.valves,
  });

  factory LineOrSequence.fromJson(Map<String, dynamic> json) {
    var filterList = json['valve'] as List;
    List<NameData> filters = filterList.map((e) => NameData.fromJson(e)).toList();

    return LineOrSequence(
      lineOrSequence: NameData.fromJson(json),
      valves: filters,
    );
  }

  dynamic toJson() {
    return {
      valves.forEach((element) {
        if(element.selected ==true) {
          element.toJson();
        }
      })
    };
  }

  dynamic serialNumberList() {
    return {
      valves.forEach((element) {
        if(element.selected ==true) {
          element.sNo;
        }
      })
    };
  }
}

class ProgramData {
  final int programId;
  final int serialNumber;
  final String programName;
  final String defaultProgramName;
  final String programCategory;
  final String programType;

  ProgramData({
    required this.programId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.programCategory
  });

  factory ProgramData.fromJson(Map<String, dynamic> json) {
    return ProgramData(
      programId: json['programId'],
      serialNumber: json['serialNumber'],
      programName: json['programName'],
      defaultProgramName: json['defaultProgramName'],
      programType: json['programType'],
      programCategory: json['programCategory']
    );
  }

  Map<String, dynamic> toJson() => {
    "programId": programId,
    "serialNumber": serialNumber,
    "programName": programName,
    "defaultProgramName": defaultProgramName,
    "programType": programType,
    "programCategory": programCategory
  };
}



