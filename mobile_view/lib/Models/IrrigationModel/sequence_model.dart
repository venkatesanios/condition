class SequenceModel {
  List<dynamic> sequence;
  Default defaultData;

  SequenceModel({required this.sequence, required this.defaultData});

  factory SequenceModel.fromJson(Map<String, dynamic> json) {
    return SequenceModel(
      sequence: json['data']['sequence'] ?? [],
      defaultData: Default.fromJson(json['data']['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {"sequence": sequence, "defaultData": defaultData.toJson()};
  }

  dynamic toMqtt() {
    return sequence;
  }
}

class Default {
  bool startTogether;
  bool longSequence;
  bool reuseValve;
  bool namedGroup;
  List<Line> line;
  List<Line> group;
  List<Valve> agitator;

  Default(
      {required this.startTogether,
        required this.line,
        required this.group,
        required this.longSequence,
        required this.reuseValve,
        required this.namedGroup,
        required this.agitator});

  factory Default.fromJson(Map<String, dynamic> json) {
    List<Line> lineList =
    List<Line>.from(json['line'].map((x) => Line.fromJson(x)));
    List<Line> groupList =
    List<Line>.from(json['group'].map((x) => Line.fromJson(x)));
    List<Valve> agitatorList =
    List<Valve>.from(json['agitator'].map((x) => Valve.fromJson(x)));

    return Default(
      startTogether: json['startTogether'],
      longSequence: json['longSequence'],
      reuseValve: json['reuseValve'],
      namedGroup: json['namedGroup'] ?? false,
      line: lineList,
      group: groupList,
      agitator: agitatorList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "startTogether": startTogether,
      "longSequence": longSequence,
      "reuseValve": reuseValve,
      "namedGroup": namedGroup,
      "line": line.map((e) => e.toJson()).toList(),
      "group": group.map((e) => e.toJson()).toList(),
      "agitator": agitator.map((e) => e.toJson()).toList(),
    };
  }
}

class Line {
  int sNo;
  String id;
  String hid;
  String location;
  String name;
  bool? selected;
  List<Valve> valve;

  Line(
      {required this.sNo,
        required this.id,
        required this.hid,
        required this.location,
        required this.name,
        this.selected,
        required this.valve});

  factory Line.fromJson(Map<String, dynamic> json) {
    var valveList = json['valve'] as List<dynamic>?;

    List<Valve> valves = valveList != null
        ? valveList
        .map((e) => Valve.fromJson(e as Map<String, dynamic>))
        .toList()
        : [];

    return Line(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'] ?? "",
      location: json['location'],
      name: json['name'],
      selected: json['selected'] ?? false,
      valve: valves,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "location": location,
      "name": name,
      "selected": selected ?? false,
      "valve": valve.map((e) => e.toJson()).toList(),
    };
  }
}

class Valve {
  int sNo;
  String id;
  String hid;
  String location;
  String name;

  Valve(
      {required this.sNo,
        required this.id,
        required this.hid,
        required this.location,
        required this.name});

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'] ?? "",
      location: json['location'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "location": location,
      "name": name,
    };
  }
}

class SampleScheduleModel {
  ScheduleAsRunListModel scheduleAsRunList;
  ScheduleByDaysModel scheduleByDays;
  DayCountSchedule dayCountSchedule;
  String selected;
  DefaultModel defaultModel;

  SampleScheduleModel({
    required this.scheduleAsRunList,
    required this.scheduleByDays,
    required this.dayCountSchedule,
    required this.selected,
    required this.defaultModel,
  });

  factory SampleScheduleModel.fromJson(Map<String, dynamic> json) {
    return SampleScheduleModel(
      scheduleAsRunList: ScheduleAsRunListModel.fromJson(
          json['data']['schedule']['scheduleAsRunList']
      ),
      scheduleByDays: ScheduleByDaysModel.fromJson(
          json['data']['schedule']['scheduleByDays']
      ),
      dayCountSchedule: DayCountSchedule.fromJson(
        json['data']['schedule']['dayCountSchedule'] ??
            {
              "schedule": { "onTime": "00:00:00", "interval": "00:00:00", "shouldLimitCycles": false, "noOfCycles": "1"}
            },
      ),
      selected: json['data']['schedule']['selected'],
      defaultModel: DefaultModel.fromJson(json['data']['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleAsRunList': scheduleAsRunList.toJson(),
      'scheduleByDays': scheduleByDays.toJson(),
      'dayCountSchedule': dayCountSchedule.toJson(),
      'selected': selected,
    };
  }
}

class ScheduleAsRunListModel {
  Map<String, dynamic> rtc;
  Map<String, dynamic> schedule;

  ScheduleAsRunListModel({
    required this.rtc,
    required this.schedule,
  });

  factory ScheduleAsRunListModel.fromJson(Map<String, dynamic> json) {
    return ScheduleAsRunListModel(
      rtc: json['rtc'] ?? {
        "rtc1": {"onTime": "00:00:00", "offTime": "00:00:00", "interval": "00:00:00", "noOfCycles": "1", "maxTime": "00:00:00", "condition": false, "stopMethod": "Continuous"},
      },
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'schedule': schedule,
    };
  }
}

class ScheduleByDaysModel {
  Map<String, dynamic> rtc;
  Map<String, dynamic> schedule;

  ScheduleByDaysModel({
    required this.rtc,
    required this.schedule,
  });

  factory ScheduleByDaysModel.fromJson(Map<String, dynamic> json) {
    return ScheduleByDaysModel(
      rtc: json['rtc'],
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'schedule': schedule,
    };
  }
}

class DayCountSchedule {
  Map<String, dynamic> schedule;

  DayCountSchedule({
    required this.schedule,
  });

  factory DayCountSchedule.fromJson(Map<String, dynamic> json) {
    return DayCountSchedule(
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule,
    };
  }
}

class DefaultModel {
  int runListLimit;
  bool rtcOffTime;
  bool rtcMaxTime;
  bool allowStopMethod;

  DefaultModel({
    required this.runListLimit,
    required this.rtcOffTime,
    required this.rtcMaxTime,
    required this.allowStopMethod
  });

  factory DefaultModel.fromJson(Map<String, dynamic> json) {
    return DefaultModel(
        runListLimit: json['runListLimit'],
        rtcOffTime: json['rtcOffTime'],
        rtcMaxTime: json['rtcMaxTime'],
        allowStopMethod: json['allowStopMethod'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runListLimit': runListLimit,
      'rtcOffTime': rtcOffTime,
      'rtcMaxTime': rtcMaxTime,
      'allowStopMethod': allowStopMethod
    };
  }
}

class SampleConditions {
  List<Condition> condition;
  DefaultData defaultData;

  SampleConditions({required this.condition, required this.defaultData});

  factory SampleConditions.fromJson(Map<String, dynamic> json) {
    var conditionList = json['data']['condition'] as List;
    List<Condition> conditions =
    conditionList.map((e) => Condition.fromJson(e)).toList();

    return SampleConditions(
      condition: conditions,
      defaultData: DefaultData.fromJson(json['data']['default']),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return condition.map((e) => e.toJson()).toList();
  }
}

class Condition {
  int sNo;
  String title;
  int widgetTypeId;
  String iconCodePoint;
  String iconFontFamily;
  dynamic value;
  bool hidden;
  bool selected;

  Condition({
    required this.sNo,
    required this.title,
    required this.widgetTypeId,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.value,
    required this.hidden,
    required this.selected,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      sNo: json['sNo'],
      title: json['title'],
      widgetTypeId: json['widgetTypeId'],
      iconCodePoint: json['iconCodePoint'],
      iconFontFamily: json['iconFontFamily'],
      value: json['value'],
      hidden: json['hidden'],
      selected: json['selected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'title': title,
      'value': value,
      'selected': selected,
    };
  }
}

class DefaultData {
  List<ConditionLibraryItem> conditionLibrary;

  DefaultData({required this.conditionLibrary});

  factory DefaultData.fromJson(Map<String, dynamic> json) {
    var conditionLibraryList = json['conditionLibrary'] as List;
    List<ConditionLibraryItem> conditionLibraryItems = conditionLibraryList
        .map((e) => ConditionLibraryItem.fromJson(e))
        .toList();

    return DefaultData(conditionLibrary: conditionLibraryItems);
  }
}

class ConditionLibraryItem {
  dynamic sNo;
  String id;
  String hid;
  String location;
  String name;
  bool enable;
  String state;
  String duration;
  String conditionIsTrueWhen;
  String fromTime;
  String untilTime;
  bool notification;
  String usedByProgram;
  String program;
  String zone;
  String dropdown1;
  String dropdown2;
  String dropdown3;
  String dropdownValue;

  ConditionLibraryItem({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.location,
    required this.name,
    required this.enable,
    required this.state,
    required this.duration,
    required this.conditionIsTrueWhen,
    required this.fromTime,
    required this.untilTime,
    required this.notification,
    required this.usedByProgram,
    required this.program,
    required this.zone,
    required this.dropdown1,
    required this.dropdown2,
    required this.dropdown3,
    required this.dropdownValue,
  });

  factory ConditionLibraryItem.fromJson(Map<String, dynamic> json) {
    return ConditionLibraryItem(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      enable: json['enable'],
      state: json['state'],
      duration: json['duration'],
      conditionIsTrueWhen: json['conditionIsTrueWhen'],
      fromTime: json['fromTime'],
      untilTime: json['untilTime'],
      notification: json['notification'],
      usedByProgram: json['usedByProgram'],
      program: json['program'],
      zone: json['zone'],
      dropdown1: json['dropdown1'],
      dropdown2: json['dropdown2'],
      dropdown3: json['dropdown3'],
      dropdownValue: json['dropdownValue'],
      hid: json['hid'] ?? "",
    );
  }
}

class SelectionModel {
  int code;
  String message;
  SelectionData data;

  SelectionModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SelectionModel.fromJson(Map<String, dynamic> json) => SelectionModel(
    code: json["code"],
    message: json["message"],
    data: SelectionData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class SelectionData {
  List<NameData>? irrigationPump;
  List<NameData>? mainValve;
  List<NameData>? centralFertilizerSite;
  List<NameData>? centralFertilizerInjector;
  List<NameData>? localFertilizerSite;
  List<NameData>? localFertilizerInjector;
  List<NameData>? centralFilterSite;
  List<NameData>? centralFilter;
  List<NameData>? localFilterSite;
  List<NameData>? localFilter;
  AdditionalData? additionalData;
  List<FertilizerSet>? centralFertilizerSet;
  List<FertilizerSet>? localFertilizerSet;
  List<NameData>? ecSensor;
  List<NameData>? phSensor;
  List<NameData>? selectorForCentral;
  List<NameData>? selectorForLocal;
  List<NameData>? headUnits;

  SelectionData(
      {this.irrigationPump,
        this.mainValve,
        this.centralFertilizerSite,
        this.centralFertilizerInjector,
        this.localFertilizerSite,
        this.localFertilizerInjector,
        this.centralFilterSite,
        this.centralFilter,
        this.localFilterSite,
        this.localFilter,
        this.additionalData,
        this.centralFertilizerSet,
        this.localFertilizerSet,
        this.ecSensor,
        this.phSensor,
        this.selectorForCentral,
        this.selectorForLocal,
        this.headUnits});

  factory SelectionData.fromJson(Map<String, dynamic> json) {
    return SelectionData(
      irrigationPump: json["irrigationPump"] == null ? [] : List<NameData>.from(json["irrigationPump"]!.map((x) => NameData.fromJson(x))),
      mainValve: json["mainValve"] == null ? [] : List<NameData>.from(json["mainValve"]!.map((x) => NameData.fromJson(x))),
      centralFertilizerSite: json["centralFertilizerSite"] == null ? [] : List<NameData>.from(json["centralFertilizerSite"]!.map((x) => NameData.fromJson(x))),
      centralFertilizerInjector: json["centralFertilizerSite"] == null ? [] : List<NameData>.from(json["centralFertilizer"]!.map((x) => NameData.fromJson(x))),
      localFertilizerSite: json["localFertilizerSite"] == null ? [] : List<NameData>.from(json["localFertilizerSite"]!.map((x) => NameData.fromJson(x))),
      localFertilizerInjector: json["localFertilizer"] == null ? [] : List<NameData>.from(json["localFertilizer"]!.map((x) => NameData.fromJson(x))),
      centralFilterSite: json["centralFilterSite"] == null ? [] : List<NameData>.from(json["centralFilterSite"]!.map((x) => NameData.fromJson(x))),
      centralFilter: json["centralFilter"] == null ? [] : List<NameData>.from(json["centralFilter"]!.map((x) => NameData.fromJson(x))),
      localFilterSite: json["localFilterSite"] == null ? [] : List<NameData>.from(json["localFilterSite"]!.map((x) => NameData.fromJson(x))),
      localFilter: json["localFilter"] == null ? [] : List<NameData>.from(json["localFilter"]!.map((x) => NameData.fromJson(x))),
      additionalData: AdditionalData.fromJson(json['additionalData']),
      centralFertilizerSet: json["centralFertilizerSet"] == null ? [] : List<FertilizerSet>.from(json["centralFertilizerSet"].map((x) => FertilizerSet.fromJson(x))),
      localFertilizerSet: json["localFertilizerSet"] == null ? [] : List<FertilizerSet>.from(json["localFertilizerSet"].map((x) => FertilizerSet.fromJson(x))),
      ecSensor: json["ecSensor"] == null ? [] : List<NameData>.from(json["ecSensor"]!.map((x) => NameData.fromJson(x))),
      phSensor: json["phSensor"] == null ? [] : List<NameData>.from(json["phSensor"]!.map((x) => NameData.fromJson(x))),
      selectorForCentral: json["centralSelector"] == null ? [] : List<NameData>.from(json["centralSelector"]!.map((x) => NameData.fromJson(x))),
      selectorForLocal: json["localSelector"] == null ? [] : List<NameData>.from(json["localSelector"]!.map((x) => NameData.fromJson(x))),
      headUnits: json["headUnits"] == null ? [] : List<NameData>.from(json["headUnits"]!.map((x) => NameData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    var centralSet = [];
    var localSet = [];
    var centralFilters = [];
    var localFilters = [];
    for(var i = 0; i < centralFertilizerSet!.length; i++) {
      for(var j = 0; j < centralFertilizerSet![i].recipe.length; j++) {
        // centralFertilizerSet![i].recipe[j].toJson();
        centralSet.add(centralFertilizerSet![i].recipe[j].toJson());
      }
    }
    for(var i = 0; i < localFertilizerSet!.length; i++) {
      for(var j = 0; j < localFertilizerSet![i].recipe.length; j++) {
        // centralFertilizerSet![i].recipe[j].toJson();
        localSet.add(localFertilizerSet![i].recipe[j].toJson());
      }
    }
    for(var i = 0; i < centralFilter!.length; i++) {
      for(var j = 0; j < centralFilterSite!.length; j++) {
        if(centralFilterSite![j].selected == false) {
          if(centralFilterSite![j].id == centralFilter![i].location) {
            centralFilter![i].selected = false;
          }
        }
      }
      centralFilters.add(centralFilter![i].toJson());
    }
    for(var i = 0; i < localFilter!.length; i++) {
      for(var j = 0; j < localFilterSite!.length; j++) {
        if(localFilterSite![j].selected == false) {
          if(localFilterSite![j].id == localFilter![i].location) {
            localFilter![i].selected = false;
          }
        }
      }
      localFilters.add(localFilter![i].toJson());
    }
    return {
      "irrigationPump": irrigationPump == null ? [] : List<dynamic>.from(irrigationPump!.map((x) => x.toJson())),
      "mainValve": mainValve == null ? [] : List<dynamic>.from(mainValve!.map((x) => x.toJson())),
      "centralFertilizerSite": centralFertilizerSite == null ? [] : List<dynamic>.from(centralFertilizerSite!.map((x) => x.toJson())),
      "centralFertilizer": centralFertilizerSite == null ? [] : List<dynamic>.from(centralFertilizerInjector!.map((x) => x.toJson())),
      "localFertilizerSite": localFertilizerSite == null ? [] : List<dynamic>.from(localFertilizerSite!.map((e) => e.toJson())),
      "localFertilizer": localFertilizerInjector == null ? [] : List<dynamic>.from(localFertilizerInjector!.map((x) => x.toJson())),
      "centralFilterSite": centralFilterSite == null ? [] : List<dynamic>.from(centralFilterSite!.map((x) => x.toJson())),
      "centralFilter": centralFilter == null ? [] : centralFilters,
      // "centralFilter": centralFilter == null ? [] : List<dynamic>.from(centralFilter!.map((x) => x.toJson())),
      "localFilterSite": localFilterSite == null ? [] : List<dynamic>.from(localFilterSite!.map((x) => x.toJson())),
      "localFilter": localFilter == null ? [] : localFilters,
      "additionalData": additionalData,
      // "centralFertilizerSet": centralFertilizerSet == null ? [] : List<dynamic>.from(centralFertilizerSet!.map((e) => e.toJson())),
      // "localFertilizerSet": localFertilizerSet == null ? [] : List<dynamic>.from(localFertilizerSet!.map((e) => e.toJson())),
      "centralFertilizerSet": centralSet,
      "localFertilizerSet": localSet,
      "ecSensor": ecSensor == null ? [] : List<dynamic>.from(ecSensor!.map((x) => x.toJson())),
      "phSensor": phSensor == null ? [] : List<dynamic>.from(phSensor!.map((x) => x.toJson())),
      "centralSelector": selectorForCentral == null ? [] : List<dynamic>.from(selectorForCentral!.map((x) => x.toJson())),
      "localSelector": selectorForLocal == null ? [] : List<dynamic>.from(selectorForLocal!.map((x) => x.toJson())),
      "headUnits": headUnits == null ? [] : List<dynamic>.from(headUnits!.map((e) => e.toJson()))
    };
  }
}

class NameData {
  int? sNo;
  String? id;
  String? hid;
  String? location;
  String? name;
  bool? selected;

  NameData({
    this.sNo,
    this.id,
    this.hid,
    this.location,
    this.name,
    this.selected,
  });

  factory NameData.fromJson(Map<String, dynamic> json) => NameData(
    sNo: json["sNo"],
    id: json["id"],
    hid: json["hid"] ?? "",
    location: json["location"],
    name: json["name"],
    selected: json["selected"],
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "id": id,
    "hid": hid,
    "location": location,
    "name": name,
    "selected": selected,
  };
}

class AdditionalData {
  String centralFiltrationOperationMode;
  String localFiltrationOperationMode;
  bool centralFiltrationBeginningOnly;
  bool localFiltrationBeginningOnly;
  bool pumpStationMode;
  bool changeOverMode;
  bool programBasedSet;
  bool programBasedInjector;

  AdditionalData(
      {required this.centralFiltrationOperationMode,
        required this.localFiltrationOperationMode,
        required this.centralFiltrationBeginningOnly,
        required this.localFiltrationBeginningOnly,
        required this.pumpStationMode,
        required this.changeOverMode,
        required this.programBasedSet,
        required this.programBasedInjector});

  factory AdditionalData.fromJson(Map<String, dynamic> json) => AdditionalData(
    centralFiltrationOperationMode: json['centralFiltrationOperationMode'] ?? "TIME",
    localFiltrationOperationMode: json['localFiltrationOperationMode'] ?? "TIME",
    centralFiltrationBeginningOnly: json['centralFiltrationBeginningOnly'] ?? false,
    localFiltrationBeginningOnly: json['localFiltrationBeginningOnly'] ?? false,
    pumpStationMode: json['pumpStationMode'] ?? false,
    changeOverMode: json['changeOverMode'] ?? false,
    programBasedSet: json['programBasedSet'] ?? false,
    programBasedInjector: json['programBasedInjector'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "centralFiltrationOperationMode": centralFiltrationOperationMode,
    "localFiltrationOperationMode": localFiltrationOperationMode,
    "centralFiltrationBeginningOnly": centralFiltrationBeginningOnly,
    "localFiltrationBeginningOnly": localFiltrationBeginningOnly,
    "pumpStationMode": pumpStationMode,
    "changeOverMode": changeOverMode,
    "programBasedSet": programBasedSet,
    "programBasedInjector": programBasedInjector
  };
}

class FertilizerSet {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  List<Recipe> recipe;

  FertilizerSet({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.recipe,
  });

  factory FertilizerSet.fromJson(Map<String, dynamic> json) {
    List<Recipe> recipes = (json['recipe'] as List)
        .map((recipeJson) => Recipe.fromJson(recipeJson))
        .toList();

    return FertilizerSet(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'] ?? "",
      name: json['name'],
      location: json['location'],
      recipe: recipes,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> recipeList =
    recipe.map((recipe) => recipe.toJson()).toList();

    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "name": name,
      "location": location,
      "recipe": recipeList,
    };
  }
}

class Recipe {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  bool selected;
  bool select;
  String ec;
  String ph;
  List<Fertilizer> fertilizer;

  Recipe({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.selected,
    required this.ec,
    required this.ph,
    required this.fertilizer,
    required this.select
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Fertilizer> fertilizers = (json['fertilizer'] as List)
        .map((fertilizerJson) => Fertilizer.fromJson(fertilizerJson))
        .toList();

    return Recipe(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'] ?? "",
      name: json['name'],
      location: json['location'],
      selected: json['selected'] ?? false,
      select: json['select'] ?? false,
      ec: json['Ec'] ?? "",
      ph: json['Ph'] ?? "",
      fertilizer: fertilizers,
    );
  }
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fertilizerList =
    fertilizer.map((fertilizer) => fertilizer.toJson()).toList();

    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "name": name,
      "location": location,
      "select": select,
      "selected": selected,
      "ec": ec,
      "ph": ph,
      "fertilizer": fertilizerList,
    };
  }
}

class Fertilizer {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  List<NameData> fertilizerMeter;
  bool active;
  String method;
  String timeValue;
  String quantityValue;
  bool dmControl;

  Fertilizer({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.fertilizerMeter,
    required this.active,
    required this.method,
    required this.timeValue,
    required this.quantityValue,
    required this.dmControl,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    List<NameData> meterList = (json['fertilizerMeter'] as List)
        .map((meterJson) => NameData.fromJson(meterJson))
        .toList();

    return Fertilizer(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'] ?? "",
      name: json['name'],
      location: json['location'],
      fertilizerMeter: meterList,
      active: json['active'],
      method: json['method'],
      timeValue: json['timeValue'],
      quantityValue: json['quantityValue'],
      dmControl: json['dmControl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "hid": hid,
      "name": name,
      "location": location,
      "fertilizerMeter": fertilizerMeter,
      "active": active,
      "method": method,
      "timeValue": timeValue,
      "quantityValue": quantityValue,
      "dmControl": dmControl
    };
  }
}

class Selector{
  int sNo;
  String rtu;
  String rfNo;
  String output;
  String outputType;
  bool selected;

  Selector({required this.sNo, required this.rtu, required this.rfNo, required this.output, required this.outputType, required this.selected});

  factory Selector.fromJson(Map<String, dynamic> json) {
    return Selector(
        sNo: json["sNo"],
        rtu: json["rtu"],
        rfNo: json["rfNo"],
        output: json["output"],
        outputType: json["output_type"],
        selected: json["selected"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "rtu": rtu,
      "rfNo": rfNo,
      "output": output,
      "output_type": outputType,
      "selected": selected
    };
  }
}

class AlarmType {
  int notificationTypeId;
  String notification;
  String notificationDescription;
  String iconCodePoint;
  String iconFontFamily;
  bool selected;

  AlarmType({
    required this.notificationTypeId,
    required this.notification,
    required this.notificationDescription,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.selected,
  });

  factory AlarmType.fromJson(Map<String, dynamic> json) {
    return AlarmType(
      notificationTypeId: json['notificationTypeId'],
      notification: json['notification'],
      notificationDescription: json['notificationDescription'],
      iconCodePoint: json['iconCodePoint'],
      iconFontFamily: json['iconFontFamily'],
      selected: json['selected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "notificationTypeId": notificationTypeId,
      "notification": notification,
      "notificationDescription": notificationDescription,
      "iconCodePoint": iconCodePoint,
      "iconFontFamily": iconFontFamily,
      "selected": selected,
    };
  }
}

class AlarmData {
  List<AlarmType> general;
  List<AlarmType> ecPh;

  AlarmData({
    required this.general,
    required this.ecPh,
  });

  factory AlarmData.fromJson(Map<String, dynamic> json) {
    List<AlarmType> generalList = (json['data']['general'] as List)
        .map((item) => AlarmType.fromJson(item))
        .toList();

    List<AlarmType> ecPhList = (json['data']['ecPh'] as List)
        .map((item) => AlarmType.fromJson(item))
        .toList();

    return AlarmData(
      general: generalList,
      ecPh: ecPhList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "general": general.map((e) => e.toJson()).toList(),
      "ecPh": ecPh.map((e) => e.toJson()).toList()
    };
  }
}

class NewAlarmData{
  String name;
  String unit;
  bool value;

  NewAlarmData({required this.name, required this.unit, required this.value});

  factory NewAlarmData.fromJson(Map<String, dynamic> json) {
    return NewAlarmData(
        name: json['name'],
        unit: json['unit'],
        value: json['value'] ?? false
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "name": name,
      "unti": unit,
      "value": value
    };
  }
}

class NewAlarmList {
  List<NewAlarmData> alarmList;
  List<NewAlarmData> defaultAlarm;

  NewAlarmList({required this.alarmList, required this.defaultAlarm});

  factory NewAlarmList.fromJson(Map<String, dynamic> json) {
    List<dynamic> alarmJsonList = json['data']['alarm'];
    List<dynamic> defaultJsonList = json['data']['default']['globalAlarm'];
    List<NewAlarmData> alarmList = alarmJsonList
        .map((item) => NewAlarmData.fromJson(item))
        .toList();
    List<NewAlarmData> defaultAlarmList = defaultJsonList
        .map((item) => NewAlarmData.fromJson(item))
        .toList();

    return NewAlarmList(alarmList: alarmList, defaultAlarm: defaultAlarmList);
  }

  List<Map<String, dynamic>> toJson() {
    return alarmList.map((e) => e.toJson()).toList();
  }
}

class ProgramLibrary {
  List<String> programType;
  List<Program> program;
  int programLimit;
  int agitatorCount;

  ProgramLibrary(
      {required this.programType,
        required this.program,
        required this.programLimit,
        required this.agitatorCount});

  factory ProgramLibrary.fromJson(Map<String, dynamic> json) {
    return ProgramLibrary(
      programType: List<String>.from(json['data']['programType'] ?? []),
      programLimit: json['data']['programLimit'],
      agitatorCount: json['data']['agitatorCount'],
      program: List<Program>.from(
          (json['data']['program'] as List<dynamic>? ?? [])
              .map((program) => Program.fromJson(program))),
    );
  }
}

class Program {
  int programId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  String priority;
  dynamic sequence;
  Map<String, dynamic> schedule;
  Map<String, dynamic> hardwareData;
  String controllerReadStatus;

  Program(
      {required this.programId,
        required this.serialNumber,
        required this.programName,
        required this.defaultProgramName,
        required this.programType,
        required this.priority,
        required this.sequence,
        required this.schedule,
        required this.hardwareData,
        required this.controllerReadStatus
      });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
        programId: json['programId'],
        serialNumber: json['serialNumber'],
        programName: json['programName'],
        defaultProgramName: json['defaultProgramName'],
        programType: json['programType'],
        priority: json['priority'],
        sequence: json['sequence'],
        schedule: json['schedule'],
        hardwareData: json['hardware'],
        controllerReadStatus: json['controllerReadStatus']
    );
  }
}

class ProgramDetails {
  // int programId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  String priority;
  bool completionOption;
  String controllerReadStatus;
  String delayBetweenZones;
  String adjustPercentage;

  ProgramDetails(
      {
        // required this.programId,
        required this.serialNumber,
        required this.programName,
        required this.defaultProgramName,
        required this.programType,
        required this.priority,
        required this.completionOption,
        required this.delayBetweenZones,
        required this.controllerReadStatus,
        required this.adjustPercentage});

  factory ProgramDetails.fromJson(Map<String, dynamic> json) {
    return ProgramDetails(
      // programId: json['data']['programId'],
        serialNumber: json['data']['serialNumber'] ?? 0,
        programName: json['data']['programName'],
        defaultProgramName: json['data']['defaultProgramName'],
        programType: json['data']['programType'],
        priority: json['data']['priority'],
        completionOption: json['data']['incompleteRestart'] == "1" ? true : false,
        delayBetweenZones: json["data"]["delayBetweenZones"],
        adjustPercentage: json["data"]["adjustPercentage"],
        controllerReadStatus: json['data']['controllerReadStatus'] ?? "0"
    );
  }
}

class ChartData {
  String? sequenceName;
  String valves;
  int preValueLow;
  int preValueHigh;
  int postValueLow;
  int postValueHigh;
  dynamic constantSetting;
  dynamic waterValueLow;
  dynamic waterValueHigh;

  ChartData({
    this.sequenceName,
    required this.valves,
    required this.preValueLow,
    required this.preValueHigh,
    required this.postValueLow,
    required this.postValueHigh,
    required this.constantSetting,
    required this.waterValueLow,
    required this.waterValueHigh,
  });

  factory ChartData.fromJson(Map<String, dynamic> json, dynamic constantSetting, List<dynamic> valves) {
    int timeToSeconds(String time) {
      var splitTime = time.split(':');
      return int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]);
    }

    int calculateValueInSec(String value, List<dynamic> valves, dynamic constantSetting, String method) {
      print(value);

      if (method == 'Time') {
        int seconds = timeToSeconds(value);

        var nominalFlowRate = <String>[];
        var sno = <String>[];
        for (var val in valves) {
          for (var i = 0; i < constantSetting['valve'].length; i++) {
            for (var j = 0; j < constantSetting['valve'][i]['valve'].length; j++) {
              if (!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])) {
                if ('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}') {
                  if (constantSetting['valve'][i]['valve'][j]['nominalFlow'] != '') {
                    sno.add(constantSetting['valve'][i]['valve'][j]['sNo'].toString());
                    nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                  }
                }
              }
            }
          }
        }
        var totalFlowRate = nominalFlowRate.map(int.parse).reduce((a, b) => a + b);
        var valveFlowRate = totalFlowRate * 0.00027778;

        var flowRateInTimePeriod = valveFlowRate * seconds;
        // print('Flow rate for $seconds seconds: $flowRateInTimePeriod');

        return flowRateInTimePeriod.round();
      } else {
        var nominalFlowRate = <String>[];
        var sno = <String>[];
        for (var val in valves) {
          for (var i = 0; i < constantSetting['valve'].length; i++) {
            for (var j = 0; j < constantSetting['valve'][i]['valve'].length; j++) {
              if (!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])) {
                if ('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}') {
                  if (constantSetting['valve'][i]['valve'][j]['nominalFlow'] != '') {
                    sno.add(constantSetting['valve'][i]['valve'][j]['sNo'].toString());
                    nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                  }
                }
              }
            }
          }
        }
        var totalFlowRate = nominalFlowRate.map(int.parse).reduce((a, b) => a + b);
        var valveFlowRate = totalFlowRate * 0.00027778;
        print(valveFlowRate);
        return value == '0' ? 0 : (value.isNotEmpty ? int.parse(value) : 0);
      }
    }

    int preValue = calculateValueInSec(json['preValue'], valves, constantSetting,json['prePostMethod']);
    int postValue = calculateValueInSec(json['postValue'], valves, constantSetting,json['prePostMethod']);
    int preLow = 0;
    int preHigh = preValue;

    int waterLow = preHigh;
    int waterHigh = waterLow + (calculateValueInSec(json['method'] == 'Time' ? json['timeValue'] : json['quantityValue'], valves, constantSetting,json['method']) - preValue - postValue);
    int postLow = waterHigh;
    int postHigh = postLow + postValue;
    // print("waterHigh ==> $waterHigh");
    return ChartData(
      sequenceName: json['seqName'] ?? "No name",
      valves: json['valve'].map((e) => e['name']).toList().join('\t\n'),
      preValueLow: preLow,
      preValueHigh: preHigh,
      constantSetting: constantSetting,
      waterValueLow: waterLow,
      waterValueHigh: waterHigh,
      postValueLow: postLow,
      postValueHigh: postHigh,
    );
  }
}
