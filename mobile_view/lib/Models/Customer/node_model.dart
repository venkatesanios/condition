class NodeModel {
  final dynamic controllerId, serialNumber;
  final String modelName;
  final String categoryName;
  final dynamic deviceId;
  final String deviceName;
  final dynamic referenceNumber;
  dynamic slrVolt;
  dynamic batVolt;
  List<RelayStatus> rlyStatus;
  List<Sensor> sensor;
  dynamic status;
  String? lastFeedbackReceivedTime;

  NodeModel({
    required this.controllerId,
    required this.serialNumber,
    required this.modelName,
    required this.categoryName,
    required this.deviceId,
    required this.deviceName,
    required this.referenceNumber,
    required this.slrVolt,
    required this.batVolt,
    required this.rlyStatus,
    required this.sensor,
    required this.status,
    required this.lastFeedbackReceivedTime,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    var rlyStatusList = json['RlyStatus'] as List;
    List<RelayStatus> rlyStatus = rlyStatusList.map((rlyStatus) => RelayStatus.fromJson(rlyStatus)).toList();
    bool lfKey = json.containsKey('LastFeedbackReceivedTime');
    var sensorList = json['Sensor'] as List;
    List<Sensor> sensor = sensorList.map((sensor) => Sensor.fromJson(sensor)).toList();
    return NodeModel(
      controllerId: json['controllerId'],
      serialNumber: json['serialNumber'],
      modelName: json['modelName'],
      categoryName: json['categoryName'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      referenceNumber: json['referenceNumber'],
      slrVolt: json['SVolt'] ?? 0.0,
      batVolt: json['BatVolt'] ?? 0.0,
      rlyStatus: rlyStatus,
      sensor: sensor,
      status: json['Status'] ?? 0,
      lastFeedbackReceivedTime: lfKey? json['LastFeedbackReceivedTime'] ?? '0': '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "controllerId": controllerId,
      "serialNumber": serialNumber,
      "modelName": modelName,
      "categoryName": categoryName,
      "deviceId": deviceId,
      "deviceName": deviceName,
      "referenceNumber": referenceNumber,
      "slrVolt": slrVolt,
      "batVolt": batVolt,
      "rlyStatus": rlyStatus.map((e) => e.toJson()).toList(),
      "sensor": sensor.map((e) => e.toJson()).toList(),
      "status": status,
    };
  }

  NodeModel updateStatusAndRlyStatus(dynamic newStatus, dynamic newRlyStatus) {
    return NodeModel(
      controllerId: this.controllerId,
      serialNumber: this.serialNumber,
      modelName: this.modelName,
      categoryName: this.categoryName,
      deviceId: this.deviceId,
      deviceName: this.deviceName,
      referenceNumber: this.referenceNumber,
      slrVolt: this.slrVolt,
      batVolt: this.batVolt,
      rlyStatus: newRlyStatus,
      sensor: this.sensor,
      status: newStatus,
      lastFeedbackReceivedTime: this.lastFeedbackReceivedTime
    );
  }
}

class Sensor {
  int sNo;
  String name;
  String? swName;
  int? angIpNo;
  int? pulseIpNo;
  String value;
  String latLong;

  Sensor({
    required this.sNo,
    required this.name,
    required this.swName,
    required this.angIpNo,
    required this.pulseIpNo,
    required this.value,
    required this.latLong,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sNo: json['S_No'],
      name: json['Name'],
      swName: json['SW_Name'],
      angIpNo: json['AngIpNo'],
      pulseIpNo: json['PulseIpNo'],
      value: json['Value'],
      latLong: json['Lat_Long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "name": name,
      "swName": swName,
      "angIpNo": angIpNo,
      "pulseIpNo": pulseIpNo,
      "value": value,
      "latLong": latLong,
    };
  }
}

class RelayStatus {
  final String? name;
  final dynamic rlyNo;
  final dynamic status;

  RelayStatus({
    required this.name,
    required this.rlyNo,
    required this.status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      name: json['Name'],
      rlyNo: json['RlyNo'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "rlyNo": rlyNo,
      "status": status
    };
  }
}