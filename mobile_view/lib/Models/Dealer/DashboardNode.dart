
class DashboardModel {
  final int userGroupId;
  final String groupName;
  final String active;
  List<MasterData> master;

  DashboardModel({
    required this.userGroupId,
    required this.groupName,
    required this.active,
    required this.master,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    var masterList = json['master'] as List;
    List<MasterData> master = masterList.isNotEmpty? masterList.map((master) => MasterData.fromJson(master)).toList() : [];

    return DashboardModel(
      userGroupId: json['userGroupId'],
      groupName: json['groupName'],
      active: json['active'],
      master: master,
    );
  }
}

class MasterData {
  List<LiveData> gemLive;
  List<CM> pumpLive;
  List<IrrigationLine> irrigationLine;
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  String liveSyncDate;
  String liveSyncTime;
  int conditionLibraryCount;

  MasterData({
    required this.gemLive,
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.liveSyncDate,
    required this.liveSyncTime,
    required this.irrigationLine,
    required this.pumpLive,
    required this.conditionLibraryCount,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    if(json['categoryId']==1 || json['categoryId']==2){
      //drip irrigation controller
      var liveData = json['2400'] as List;
      List<LiveData> liveList = liveData.isNotEmpty? liveData.map((live) => LiveData.fromJson(live)).toList() : [];

      var irrigationLine = json['irrigationLine'] as List;
      if(irrigationLine.isNotEmpty && irrigationLine.length>1){
        var allLine = {
          "sNo": 0,
          "id": "",
          "hid": "",
          "name": "All irrigation line",
          "location": "",
          "type": "",
          "mainValve": [],
          "valve": [],
          "moistureSensor": [],
          "levelSensor": [],
          "pressureSensor": [],
          "waterMeter": [],
          "fan": [],
          "fogger": [],
          "pressureSwitch": [],
          "powerSupply": []
        };
        irrigationLine.insert(0, allLine);
      }

      List<IrrigationLine> irgLine = irrigationLine.isNotEmpty? irrigationLine.map((irl) => IrrigationLine.fromJson(irl)).toList() : [];

      return MasterData(
        controllerId: json['controllerId'],
        deviceId: json['deviceId'],
        deviceName: json['deviceName'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        modelId: json['modelId'],
        modelName: json['modelName'],
        liveSyncDate: json['liveSyncDate'] ?? '',
        liveSyncTime: json['liveSyncTime'] ?? '',
        gemLive: liveList,
        irrigationLine: irgLine,
        pumpLive: [],
        conditionLibraryCount: json['conditionLibraryCount'] ?? 0,
      );
    }else{
      //pump controller
      //print(json['liveMessage']);
      var liveMessage = json['liveMessage'] != null ? json['liveMessage'] as List : [];
      List<CM> pumpLiveList = liveMessage.isNotEmpty? liveMessage.map((live) => CM.fromJson(live)).toList(): [];

      return MasterData(
        controllerId: json['controllerId'],
        deviceId: json['deviceId'],
        deviceName: json['deviceName'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        modelId: json['modelId'],
        modelName: json['modelName'],
        liveSyncDate: json['liveSyncDate'] ?? '',
        liveSyncTime: json['liveSyncTime'] ?? '',
        gemLive: [],
        irrigationLine: [],
        pumpLive: pumpLiveList,
        conditionLibraryCount: json['conditionLibraryCount'] ?? 0,
      );
    }
  }

}

class LiveData {
  List<NodeData> nodeList;
  List<PumpData> pumpList;
  List<Filter> filterList;
  List<FertilizerSite> fertilizerSiteList;
  List<ScheduledProgram> scheduledProgramList;
  List<ProgramQueue> queProgramList;
  List<CurrentScheduleModel> currentSchedule;
  // List<SensorData> sensorList;
  int WifiStrength;

  LiveData({
    required this.nodeList,
    required this.pumpList,
    required this.filterList,
    required this.fertilizerSiteList,
    required this.scheduledProgramList,
    required this.queProgramList,
    required this.currentSchedule,
    required this.WifiStrength,
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {

    var nodeData = json['2401'] as List;
    List<NodeData> nodeList = nodeData.isNotEmpty? nodeData.map((node) => NodeData.fromJson(node)).toList() : [];

    var rPrg = json['2402'] as List;
    List<CurrentScheduleModel> currentSchedule = rPrg.isNotEmpty? rPrg.map((cSch) => CurrentScheduleModel.fromJson(cSch)).toList() : [];

    var programData = json['2404'] as List;
    List<ScheduledProgram> programList = programData.isNotEmpty? programData.map((prg) => ScheduledProgram.fromJson(prg)).toList() : [];

    var pQ = json['2403'] as List;
    List<ProgramQueue> pInQ = pQ.isNotEmpty? pQ.map((quePrg) => ProgramQueue.fromJson(quePrg)).toList(): [];

    var filterData = json['2405'] as List;
    List<Filter> filterList = filterData.isNotEmpty? filterData.map((filter) => Filter.fromJson(filter)).toList(): [];

    var fertilizerData = json['2406'] as List;
    List<FertilizerSite> fertilizerSiteList = fertilizerData.isNotEmpty? fertilizerData.map((fertilizer) => FertilizerSite.fromJson(fertilizer)).toList(): [];

    var pumpData = json['2407'] as List;
    List<PumpData> pumpList = pumpData.isNotEmpty? pumpData.map((pmp) => PumpData.fromJson(pmp)).toList(): [];

    return LiveData(
      nodeList: nodeList,
      pumpList: pumpList,
      filterList: filterList,
      fertilizerSiteList: fertilizerSiteList,
      scheduledProgramList: programList,
      queProgramList: pInQ,
      currentSchedule: currentSchedule,
      WifiStrength: json['WifiStrength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '2401': nodeList.map((e) => e.toJson()).toList(),
      '2402': currentSchedule.map((e) => e.toJson()).toList(),
      '2403': queProgramList.map((e) => e.toJson()).toList(),
      '2404': scheduledProgramList.map((e) => e.toJson()).toList(),
      '2405': filterList.map((e) => e.toJson()).toList(),
      '2406': fertilizerSiteList.map((e) => e.toJson()).toList(),
      '2407': pumpList.map((e) => e.toJson()).toList(),
      //'2408': sensorList.map((e) => e.toJson()).toList(),
      'WifiStrength': WifiStrength,
    };
  }
}

class NodeData {
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  int serialNumber;
  int referenceNumber;
  double sVolt;
  double batVolt;
  List<RelayStatus> rlyStatus;
  List<SensorStatus> sensor;
  int status;
  String? lastFeedbackReceivedTime;

  NodeData({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.serialNumber,
    required this.referenceNumber,
    required this.sVolt,
    required this.batVolt,
    required this.rlyStatus,
    required this.sensor,
    required this.status,
    required this.lastFeedbackReceivedTime,
  });

  factory NodeData.fromJson(Map<String, dynamic> json) {

    var rlyStatusList = json['RlyStatus'] as List;
    List<RelayStatus> rlyStatus = rlyStatusList.isNotEmpty? rlyStatusList.map((node) => RelayStatus.fromJson(node)).toList() : [];

    var sensorList = json['Sensor'] as List;
    List<SensorStatus> sensor = sensorList.map((sensor) => SensorStatus.fromJson(sensor)).toList();

    bool lfKey = json.containsKey('LastFeedbackReceivedTime');

    return NodeData(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      serialNumber: json['serialNumber'],
      referenceNumber: json['referenceNumber'],
      sVolt: json['SVolt'],
      batVolt: json['BatVolt'],
      rlyStatus: rlyStatus,
      sensor: sensor,
      status: json['Status'],
      lastFeedbackReceivedTime: lfKey? json['LastFeedbackReceivedTime'] ?? '0': '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'DeviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'serialNumber': serialNumber,
      'referenceNumber': referenceNumber,
      'SVolt': sVolt,
      'BatVolt': batVolt,
      'RlyStatus': rlyStatus,
      'Sensor': sensor,
      'Status': status,
      'lastFeedbackReceivedTime': lastFeedbackReceivedTime,
    };
  }
}

class PumpData {
  int type;
  String name;
  String ? swName;
  String location;
  int status;
  String reason;
  List<dynamic> waterMeter;
  List<dynamic> pressure;
  List<dynamic> level;
  List<dynamic> float;
  String onDelay;
  String onDelayCompleted;
  String onDelayLeft;
  String program;

  PumpData({
    required this.type,
    required this.name,
    required this.swName,
    required this.location,
    required this.status,
    required this.reason,
    required this.waterMeter,
    required this.pressure,
    required this.level,
    required this.float,
    required this.onDelay,
    required this.onDelayCompleted,
    required this.onDelayLeft,
    required this.program,
  });

  factory PumpData.fromJson(Map<String, dynamic> json) {
    String onDelay = json['OnDelay'] ?? '00:00:00';
    int type = json['Type'] ?? 0;
    String location = json['Location'] ?? '-';
    bool hasOnOffReasonKey = json.containsKey('OnOffReason');
    return PumpData(
      type: type,
      name: json['Name'],
      swName: json['SW_Name'],
      location: location,
      status: json['Status'],
      reason: hasOnOffReasonKey? json['OnOffReason']:json['Reason'].toString(),
      waterMeter: json['Watermeter'],
      pressure: json['Pressure'],
      level: json['Level'],
      float: [],
      onDelay: onDelay,
      onDelayCompleted: json['OnDelayCompleted'],
      onDelayLeft: json['OnDelayLeft'],
      program: json['Program'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Name': name,
      'SW_Name': swName,
      'Location': location,
      'Status': status,
      'Reason': reason,
      'Watermeter': waterMeter,
      'Pressure': pressure,
      'Level': level,
      'Float': float,
      'OnDelay': onDelay,
      'OnDelayCompleted': onDelayCompleted,
      'OnDelayLeft': onDelayLeft,
      'Program': program,
    };
  }
}

class ScheduledProgram {
  final int sNo;
  final String progCategory;
  final String progName;
  final int totalZone;
  final String startDate;
  final String endDate;
  final String startTime;
  final int schedulingMethod;
  final String progOnOff;
  final String progPauseResume;
  final int startStopReason;
  final int programStatusPercentage;
  final Condition startCondition;
  final Condition stopCondition;
  final int pauseResumeReason;

  ScheduledProgram({
    required this.sNo,
    required this.progCategory,
    required this.progName,
    required this.totalZone,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.schedulingMethod,
    required this.progOnOff,
    required this.progPauseResume,
    required this.startStopReason,
    required this.programStatusPercentage,
    required this.startCondition,
    required this.stopCondition,
    required this.pauseResumeReason,
  });

  factory ScheduledProgram.fromJson(Map<String, dynamic> json) {
    //print(json);
    bool hasLoadingKey = json.containsKey('isLoading');
    return ScheduledProgram(
      sNo: json['SNo'],
      progCategory: json['ProgCategory'],
      progName: json['ProgName'],
      totalZone: json['TotalZone'],
      startDate: json['StartDate'],
      endDate: json['EndDate'],
      startTime: json['StartTime'],
      schedulingMethod: json['SchedulingMethod'],
      progOnOff: json['ProgOnOff'],
      progPauseResume: json['ProgPauseResume'],
      startStopReason: json['StartStopReason'],
      programStatusPercentage: json['ProgramStatusPercentage'],
      startCondition: json['StartCondition'] != null && (json['StartCondition'] as Map).isNotEmpty
          ? Condition.fromJson(json['StartCondition'])
          : Condition.empty(),
      stopCondition: json['StopCondition'] != null && (json['StopCondition'] as Map).isNotEmpty
          ? Condition.fromJson(json['StopCondition'])
          : Condition.empty(),
      pauseResumeReason: json['PauseResumeReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SNo': sNo,
      'ProgCategory': progCategory,
      'ProgName': progName,
      'TotalZone': totalZone,
      'StartDate': startDate,
      'EndDate': endDate,
      'StartTime': startTime,
      'SchedulingMethod': schedulingMethod,
      'ProgOnOff': progOnOff,
      'ProgPauseResume': progPauseResume,
      'StartStopReason': startStopReason,
      'ProgramStatusPercentage': programStatusPercentage,
      'StartCondition': startCondition.toJson(),
      'StopCondition': stopCondition.toJson(),
      'PauseResumeReason': pauseResumeReason,
    };
  }

  DateTime getDateTime() {
    if (startDate == "-" || startTime == "-") {
      return DateTime(9999);
    }
    return DateTime.parse('$startDate $startTime');
  }

}

class Condition {
  final String sNo;
  final int status;
  final String condition;
  final int set;
  final int? actual;
  final List<Condition> combined;

  Condition({
    required this.sNo,
    required this.status,
    required this.condition,
    required this.set,
    required this.actual,
    required this.combined,
  });

  factory Condition.fromJson(dynamic json) {
    if (json != null && json is Map<String, dynamic>) {
      return Condition(
        sNo: json['S_No'] ?? '',
        status: json['Status'] ?? 0,
        condition: json['Condition'] ?? '',
        set: json['Set'] ?? 0,
        actual: json['Actual'] ?? 0,
        combined: json['Combined'] != null && (json['Combined'] as List).isNotEmpty
            ? (json['Combined'] as List).map((e) => Condition.fromJson(e)).toList()
            : [],
      );
    } else {
      return Condition.empty();
    }
  }

  factory Condition.empty() {
    return Condition(
      sNo: '',
      status: 0,
      condition: '',
      set: 0,
      actual: 0,
      combined: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'S_No': sNo,
      'Status': status,
      'Condition': condition,
      'Set': set,
      'Actual': actual,
      'Combined': combined.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgramQueue {
  final String programName, programCategory,zoneName,startTime, totalDurORQty;
  final int programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone, schMethod;

  ProgramQueue({
    required this.programName,
    required this.programCategory,
    required this.zoneName,
    required this.programType,
    required this.totalRtc,
    required this.currentRtc,
    required this.totalCycle,
    required this.currentCycle,
    required this.totalZone,
    required this.currentZone,
    required this.startTime,
    required this.totalDurORQty,
    required this.schMethod,
  });

  factory ProgramQueue.fromJson(Map<String, dynamic> json) {
    return ProgramQueue(
      programName: json['ProgName'] ?? "",
      programCategory: json['ProgCategory'] ?? "",
      zoneName: json['ZoneName'] ?? "",
      programType: json['ProgType'] ?? 0,
      totalRtc: json['TotalRtc'] ?? 0,
      currentRtc: json['CurrentRtc'] ?? 0,
      totalCycle: json['TotalCycle'] ?? 0,
      currentCycle: json['CurrentCycle'] ?? 0,
      totalZone: json['TotalZone'] ?? 0,
      currentZone: json['CurrentZone'] ?? 0,
      startTime: json['StartTime'] ?? "",
      totalDurORQty: json['IrrigationDuration_Quantity'] ?? "",
      schMethod: json['SchedulingMethod'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProgName': programName,
      'ProgCategory': programCategory,
      'ZoneName': zoneName,
      'ProgType': programType,
      'TotalRtc': totalRtc,
      'CurrentRtc': currentRtc,
      'TotalCycle': totalCycle,
      'CurrentCycle': currentCycle,
      'TotalZone': totalZone,
      'CurrentZone': currentZone,
      'StartTime': startTime,
      'IrrigationDuration_Quantity': totalDurORQty,
      'SchedulingMethod': schMethod,
    };
  }

}

class CurrentScheduleModel {
  String programName, programCategory,zoneName,zoneSNo,startTime, duration_Qty, duration_QtyLeft;
  String message, avgFlwRt;
  final int programSno, programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone, srlNo, reasonCode, actualFlowRate;
  List<dynamic> mainValve;
  List<dynamic> valve;

  CurrentScheduleModel({
    required this.programSno,
    required this.programName,
    required this.programCategory,
    required this.zoneName,
    required this.zoneSNo,
    required this.programType,
    required this.totalRtc,
    required this.currentRtc,
    required this.totalCycle,
    required this.currentCycle,
    required this.totalZone,
    required this.currentZone,
    required this.startTime,
    required this.duration_Qty,
    required this.duration_QtyLeft,
    required this.valve,
    required this.mainValve,
    required this.message,
    required this.srlNo,
    required this.reasonCode,
    required this.avgFlwRt,
    required this.actualFlowRate,
  });

  factory CurrentScheduleModel.fromJson(Map<String, dynamic> json) {

    bool hasOnTimeKey = json.containsKey('MV');
    String durQty = '0', durQtyLeft = '0';

    if(json['Duration_Qty'].runtimeType==int) {
      durQty = json['Duration_Qty'].toString();
    }else{
      durQty = json['Duration_Qty'];
    }

    if(json['Duration_QtyLeft'].runtimeType==int) {
      durQtyLeft = json['Duration_QtyLeft'].toString();
    }else{
      durQtyLeft = json['Duration_QtyLeft'];
    }

    return CurrentScheduleModel(
      programSno: json['ProgramS_No'],
      programName: json['ProgName'] ?? '',
      programCategory: json['ProgCategory'] ?? '',
      zoneName: json['ZoneName'] ?? "",
      zoneSNo: json['ZoneS_No'] ?? "",
      programType: json['ProgType'] ?? 0,
      totalRtc: json['TotalRtc'] ?? 0,
      currentRtc: json['CurrentRtc'] ?? 0,
      totalCycle: json['TotalCycle'] ?? 0,
      currentCycle: json['CurrentCycle'] ?? 0,
      totalZone: json['TotalZone'] ?? 0,
      currentZone: json['CurrentZone'] ?? 0,
      startTime: json['StartTime'] ?? '',
      duration_Qty: durQty,
      duration_QtyLeft: durQtyLeft,
      valve: json['VL'] ?? [],
      mainValve: hasOnTimeKey? json['MV'] ?? []:[],
      message: json['Message'] ?? '',
      srlNo: json['ScheduleS_No'] ?? 0,
      reasonCode: json['ProgramStartStopReason'] ?? 0,
      avgFlwRt: json['AverageFlowRate'] ?? '0',
      actualFlowRate: json['actualFlowRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProgramS_No': programSno,
      'ProgName': programName,
      'ProgCategory': programCategory,
      'ZoneName': zoneName,
      'ZoneS_No': zoneSNo,
      'ProgType': programType,
      'TotalRtc': totalRtc,
      'CurrentRtc': currentRtc,
      'TotalCycle': totalCycle,
      'CurrentCycle': currentCycle,
      'TotalZone': totalZone,
      'CurrentZone': currentZone,
      'StartTime': startTime,
      'Duration_Qty': duration_Qty,
      'Duration_QtyLeft': duration_QtyLeft,
      'Valve': valve,
      'MainValve': mainValve,
      'Message': message,
      'ScheduleS_No': srlNo,
      'ProgramStartStopReason': reasonCode,
      'AverageFlowRate': avgFlwRt,
      'actualFlowRate': actualFlowRate,
    };
  }


}

class SensorData {
  int S_No;
  String Line;
  String PrsIn;
  String PrsOut;
  String DpValue;
  String Watermeter;
  int IrrigationPauseFlag;
  int DosingPauseFlag;

  SensorData({
    required this.S_No,
    required this.Line,
    required this.PrsIn,
    required this.PrsOut,
    required this.DpValue,
    required this.Watermeter,
    required this.IrrigationPauseFlag,
    required this.DosingPauseFlag,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      S_No: json['S_No'],
      Line: json['Line'],
      PrsIn: json['PrsIn'],
      PrsOut: json['PrsOut'],
      DpValue: json['DpValue'],
      Watermeter: json['Watermeter'],
      IrrigationPauseFlag: json['IrrigationPauseFlag'],
      DosingPauseFlag: json['DosingPauseFlag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'S_No': S_No,
      'Line': Line,
      'PrsIn': PrsIn,
      'PrsOut': PrsOut,
      'DpValue': DpValue,
      'Watermeter': Watermeter,
      'IrrigationPauseFlag': IrrigationPauseFlag,
      'DosingPauseFlag': DosingPauseFlag,
    };
  }
}

class IrrigationLine {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  List<MainValve> mainValve;
  List<Valve> valve;
  //List<PressureSensor> pressureSensor;

  IrrigationLine({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.mainValve,
    required this.valve,
    //required this.pressureSensor,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    print(json);
    var mainValve = json['mainValve'] as List;
    List<MainValve> mainValveList = mainValve.isNotEmpty? mainValve.map((mv) => MainValve.fromJson(mv)).toList() : [];

    var valveData = json['valve'] as List;
    List<Valve> valveDataList = valveData.isNotEmpty? valveData.map((vl) => Valve.fromJson(vl)).toList() : [];

    return IrrigationLine(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      mainValve: mainValveList,
      valve: valveDataList,
      //pressureSensor: (json['pressureSensor'] as List).map((i) => PressureSensor.fromJson(i)).toList(),
    );
  }

}

class MainValve {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  MainValve({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class Valve {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  Valve({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class PressureSensor {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  PressureSensor({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory PressureSensor.fromJson(Map<String, dynamic> json) {
    return PressureSensor(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class RelayStatus {
  final int? S_No;
  final String? name;
  final int? rlyNo;
  final int? Status;

  RelayStatus({
    required this.S_No,
    required this.name,
    required this.rlyNo,
    required this.Status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      S_No: json['S_No'],
      name: json['Name'],
      rlyNo: json['RlyNo'],
      Status: json['Status'],
    );
  }

/*Map<String, dynamic> toJson() {
    return {
      'S_No': S_No,
      'Name': name,
      'RlyNo': rlyNo,
      'Status': status,
    };
  }*/
}

class SensorStatus {
  int sNo;
  String name;
  String? swName;
  int? angIpNo;
  int? pulseIpNo;
  String value;
  String latLong;

  SensorStatus({
    required this.sNo,
    required this.name,
    this.swName,
    this.angIpNo,
    this.pulseIpNo,
    required this.value,
    required this.latLong,
  });

  factory SensorStatus.fromJson(Map<String, dynamic> json) {
    return SensorStatus(
      sNo: json['S_No'],
      name: json['Name'],
      swName: json['SW_Name'],
      angIpNo: json['AngIpNo'],
      pulseIpNo: json['PulseIpNo'],
      value: json['Value'],
      latLong: json['Lat_Long'],
    );
  }

}

/*class SensorStatus {
  final String? name;
  final String? value;

  SensorStatus({
    required this.name,
    required this.value,
  });

  factory SensorStatus.fromJson(Map<String, dynamic> json) {
    return SensorStatus(
      name: json['Name'],
      value: json['Value'],
    );
  }
}*/

class Filter {
  final int type;
  final String filterSite;
  final String location;
  final String program;
  final int status;
  final List<FilterStatus> filterStatus;
  final int method;
  final String duration;
  final String durationCompleted;
  final String durationLeft;
  final String prsIn;
  final String prsOut;
  final String dpValue;

  Filter({
    required this.type,
    required this.filterSite,
    required this.location,
    required this.program,
    required this.status,
    required this.filterStatus,
    required this.method,
    required this.duration,
    required this.durationCompleted,
    required this.durationLeft,
    required this.prsIn,
    required this.prsOut,
    required String dpValue,
  }) : dpValue = dpValue.toString();

  factory Filter.fromJson(Map<String, dynamic> json) {
    var filterStatusList = json['FilterStatus'] as List;
    List<FilterStatus> filterStatus = filterStatusList.isNotEmpty? filterStatusList.map((status) => FilterStatus.fromJson(status)).toList(): [];

    return Filter(
      type: json['Type'],
      filterSite: json['FilterSite'],
      location: json['Location'],
      program: json['Program'],
      status: json['Status'],
      filterStatus: filterStatus,
      method: json['Method'],
      duration: json['Duration'],
      durationCompleted: json['DurationCompleted'],
      durationLeft: json['DurationLeft'],
      prsIn: json['PrsIn'],
      prsOut: json['PrsOut'],
      dpValue: json['DpValue'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'FilterSite': filterSite,
      'Location': location,
      'Program': program,
      'Status': status,
      'FilterStatus': filterStatus.map((status) => status.toJson()).toList(),
      'Method': method,
      'Duration': duration,
      'DurationCompleted': durationCompleted,
      'DurationLeft': durationLeft,
      'PrsIn': prsIn,
      'PrsOut': prsOut,
      'DpValue': dpValue,
    };
  }
}

class FilterStatus {
  final int position;
  final String name;
  final int status;

  FilterStatus({
    required this.position,
    required this.name,
    required this.status,
  });

  factory FilterStatus.fromJson(Map<String, dynamic> json) {
    return FilterStatus(
      position: json['Position'],
      name: json['Name'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Position': position,
      'Name': name,
      'Status': status,
    };
  }
}

class FertilizerSite {
  final int type;
  final String fertilizerSite;
  final String location;
  final List<Agitator> agitator;
  final List<Booster> booster;
  final List<dynamic> ec;
  final List<dynamic> ph;
  final String program;
  final List<Fertilizer> fertilizer;
  final List<dynamic> fertilizerTankSelector;
  final String ecSet;
  final String phSet;

  FertilizerSite({
    required this.type,
    required this.fertilizerSite,
    required this.location,
    required this.agitator,
    required this.booster,
    required this.ec,
    required this.ph,
    required this.program,
    required this.fertilizer,
    required this.fertilizerTankSelector,
    required this.ecSet,
    required this.phSet,
  });

  factory FertilizerSite.fromJson(Map<String, dynamic> json) {
    var agitatorList = json['Agitator'] as List;
    var boosterList = json['Booster'] as List;
    var fertilizerList = json['Fertilizer'] as List;

    List<Agitator> agitator = agitatorList.isNotEmpty? agitatorList.map((a) => Agitator.fromJson(a)).toList(): [];
    List<Booster> booster = boosterList.isNotEmpty? boosterList.map((b) => Booster.fromJson(b)).toList(): [];
    List<Fertilizer> fertilizer = fertilizerList.isNotEmpty? fertilizerList.map((frtLs) => Fertilizer.fromJson(frtLs)).toList(): [];

    String ecSet = '0', phSet = '0';

    if(json['EcSet'].runtimeType==int) {
      ecSet = json['EcSet'].toString();
    }else{
      ecSet = json['EcSet'];
    }

    if(json['PhSet'].runtimeType==int) {
      phSet = json['PhSet'].toString();
    }else{
      phSet = json['PhSet'];
    }

    return FertilizerSite(
      type: json['Type'],
      fertilizerSite: json['FertilizerSite'],
      location: json['Location'],
      agitator: agitator,
      booster: booster,
      ec: json['Ec'],
      ph: json['Ph'],
      program: json['Program'],
      fertilizer: fertilizer,
      fertilizerTankSelector: json['FertilizerTankSelector'],
      ecSet: ecSet,
      phSet: phSet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'FertilizerSite': fertilizerSite,
      'Location': location,
      'Agitator': agitator.map((a) => a.toJson()).toList(),
      'Booster': booster.map((b) => b.toJson()).toList(),
      'Ec': ec,
      'Ph': ph,
      'Program': program,
      'Fertilizer': fertilizer.map((f) => f.toJson()).toList(),
      'FertilizerTankSelector': fertilizerTankSelector,
      'EcSet': ecSet,
      'PhSet': phSet,
    };
  }
}

class Fertilizer {
  final int fertNumber;
  final String name;
  final double flowRate;
  final int flowRateLpH;
  final int status;
  final int fertMethod;
  final int fertSelection;
  final String duration;
  final String durationCompleted;
  final String durationLeft;
  final String qty;
  final String qtyCompleted;
  final String qtyLeft;
  final String onTime;
  final String offTime;
  final List<dynamic> flowMeter;
  final List<dynamic> level;

  Fertilizer({
    required this.fertNumber,
    required this.name,
    required this.flowRate,
    required this.flowRateLpH,
    required this.status,
    required this.fertMethod,
    required this.fertSelection,
    required this.duration,
    required this.durationCompleted,
    required this.durationLeft,
    required this.qty,
    required this.qtyCompleted,
    required this.qtyLeft,
    required this.onTime,
    required this.offTime,
    required this.flowMeter,
    required this.level,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    String qty = '0',qtyCompleted = '0', qtyLeft = '0';
    int frtMethod = 0, frtSelection = 0;

    if(json['Qty'].runtimeType==int) {
      qty = json['Qty'].toString();
    }else{
      qty = json['Qty'];
    }

    if(json['QtyCompleted'].runtimeType==int) {
      qtyCompleted = json['QtyCompleted'].toString();
    }else{
      qtyCompleted = json['QtyCompleted'];
    }

    if(json['QtyLeft'].runtimeType==int) {
      qtyLeft = json['QtyLeft'].toString();
    }else{
      qtyLeft = json['QtyLeft'];
    }

    if(json['FertMethod'].runtimeType==String) {
      frtMethod = int.parse(json['FertMethod']);
    }else{
      frtMethod = json['FertMethod'];
    }

    if(json['FertSelection'].runtimeType==String) {
      frtSelection = int.parse(json['FertSelection']);
    }else{
      frtSelection = json['FertSelection'];
    }

    bool hasOnTimeKey = json.containsKey('OnTime');
    bool hasOffTimeKey = json.containsKey('OffTime');

    return Fertilizer(
      fertNumber: json['FertNumber'],
      name: json['Name'],
      flowRate: json['FlowRate'],
      flowRateLpH: json['FlowRate_LpH'],
      status: json['Status'],
      fertMethod: frtMethod,
      fertSelection: frtSelection,
      duration: json['Duration'],
      durationCompleted: json['DurationCompleted'],
      durationLeft: json['DurationLeft'],
      qty: qty,
      qtyCompleted: qtyCompleted,
      qtyLeft: qtyLeft,
      onTime: hasOnTimeKey? json['OnTime']:'0',
      offTime: hasOffTimeKey? json['OffTime']:'0',
      flowMeter: json['FlowMeter'].runtimeType==String?[]:json['FlowMeter'],
      level: json['Level'].runtimeType==String?[]:json['Level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FertNumber': fertNumber,
      'Name': name,
      'FlowRate': flowRate,
      'FlowRate_LpH': flowRateLpH,
      'Status': status,
      'FertMethod': fertMethod,
      'FertSelection': fertSelection,
      'Duration': duration,
      'DurationCompleted': durationCompleted,
      'DurationLeft': durationLeft,
      'Qty': qty,
      'QtyCompleted': qtyCompleted,
      'QtyLeft': qtyLeft,
      'OnTime': onTime,
      'OffTime': offTime,
      'FlowMeter': flowMeter,
      'Level': level,
    };
  }
}

class Agitator {
  final String name;
  final int status;

  Agitator({
    required this.name,
    required this.status,
  });

  factory Agitator.fromJson(Map<String, dynamic> json) {
    return Agitator(
      name: json['Name'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Status': status,
    };
  }
}

class Booster {
  final String name;
  final int status;

  Booster({
    required this.name,
    required this.status,
  });

  factory Booster.fromJson(Map<String, dynamic> json) {
    return Booster(
      name: json['Name'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Status': status,
    };
  }
}

/*class PumpCLive {
  List<CM> cM;

  PumpCLive({
    required this.cM,
  });

  factory PumpCLive.fromJson(Map<String, dynamic> json) {
    return PumpCLive(
      cM: List<CM>.from(json['cM'].map((x) => CM.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cM': List<dynamic>.from(cM.map((x) => x.toJson())),
    };
  }
}*/

abstract class CM {
  CM();
  factory CM.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('V')) {
      return CMType2.fromJson(json);
    } else {
      return CMType1.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class CMType1 extends CM {
  int? st;
  int? rn;
  double? at;
  double? se;
  int? ph;
  String? wm;
  String? cf;
  String? pr;
  String? lv;
  String? ft;
  String? od;
  String? odc;
  String? odl;

  CMType1({
    this.st,
    this.rn,
    this.at,
    this.se,
    this.ph,
    this.wm,
    this.cf,
    this.pr,
    this.lv,
    this.ft,
    this.od,
    this.odc,
    this.odl,
  });

  factory CMType1.fromJson(Map<String, dynamic> json) {
    return CMType1(
      st: json['ST'],
      rn: json['RN'],
      at: (json['AT'] ?? 0).toDouble(),
      se: (json['SE'] ?? 0).toDouble(),
      ph: json['PH'],
      wm: json['WM'],
      cf: json['CF'],
      pr: json['PR'],
      lv: json['LV'],
      ft: json['FT'],
      od: json['OD'],
      odc: json['ODC'],
      odl: json['ODL'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ST': st,
      'RN': rn,
      'AT': at,
      'SE': se,
      'PH': ph,
      'WM': wm,
      'CF': cf,
      'PR': pr,
      'LV': lv,
      'FT': ft,
      'OD': od,
      'ODC': odc,
      'ODL': odl,
    };
  }
}

class CMType2 extends CM {
  String? v;
  String? c;
  int? ss;
  int? b;
  String? vs;
  String? np;

  CMType2({
    this.v,
    this.c,
    this.ss,
    this.b,
    this.vs,
    this.np,
  });

  factory CMType2.fromJson(Map<String, dynamic> json) {
    return CMType2(
      v: json['V'],
      c: json['C'],
      ss: json['SS'],
      b: json['B'],
      vs: json['VS'],
      np: json['NP'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'V': v,
      'C': c,
      'SS': ss,
      'B': b,
      'VS': vs,
      'NP': np,
    };
  }
}