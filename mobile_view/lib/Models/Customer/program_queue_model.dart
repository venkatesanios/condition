class ProgramQueueModel {
  int code;
  String message;
  ProgramQueueData data;

  ProgramQueueModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProgramQueueModel.fromJson(Map<String, dynamic> json) {
    return ProgramQueueModel(
      code: json['code'],
      message: json['message'],
      data: ProgramQueueData.fromJson(json['data']),
    );
  }
}

class ProgramQueueData {
  List<ProgramQueue> low;
  List<ProgramQueue> high;

  ProgramQueueData({
    required this.low,
    required this.high,
  });

  factory ProgramQueueData.fromJson(Map<String, dynamic> json) {
    return ProgramQueueData(
      low: (json['Low'] != null)
          ? List<ProgramQueue>.from(json['Low'].map((x) => ProgramQueue.fromJson(x)))
          : [],
      high: (json['High'] != null)
          ? List<ProgramQueue>.from(json['High'].map((x) => ProgramQueue.fromJson(x)))
          : [],
    );
  }

  dynamic toJson() {
    Map<dynamic, dynamic> combinedMap = {};
    List<Map<String, dynamic>> programQueue = [];

    high.forEach((e) => programQueue.add(e.toJson()));
    low.forEach((e) => programQueue.add(e.toJson()));

    return programQueue;
  }

  String toHardware() {
    var list = [];
    high.forEach((element) => list.add(element.toHardware()));
    low.forEach((element) => list.add(element.toHardware()));
    return "${list.join(";").toString()};";
  }
}

class ProgramQueue {
  int programQueueId;
  int userId;
  int controllerId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  String priority;
  String startTime;

  ProgramQueue({
    required this.programQueueId,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.priority,
    required this.startTime,
  });

  factory ProgramQueue.fromJson(Map<String, dynamic> json) {
    return ProgramQueue(
      programQueueId: json['programQueueId'],
      userId: json['userId'],
      controllerId: json['controllerId'],
      serialNumber: json['serialNumber'],
      programName: json['programName'],
      defaultProgramName: json['defaultProgramName'],
      programType: json['programType'],
      priority: json['priority'],
      startTime: json['startTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "programQueueId": programQueueId,
      "userId": userId,
      "controllerId": controllerId,
      "serialNumber": serialNumber,
      "programName": programName,
      "defaultProgramName": defaultProgramName,
      "programType": programType,
      "priority": priority,
      "startTime": startTime
    };
  }

  String toHardware() {
    return "$serialNumber,${priority == "High" ?1:0}";
  }
}
