class IrrigationLineSystemData {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  EnergySaveSettings systemDefinition;
  PowerOffRecoveryModel powerOffRecovery;

  IrrigationLineSystemData({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.systemDefinition,
    required this.powerOffRecovery,
  });

  factory IrrigationLineSystemData.fromJson(Map<String, dynamic> json) {
    return IrrigationLineSystemData(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      systemDefinition: EnergySaveSettings.fromJson(json['systemDefinition']),
      powerOffRecovery: PowerOffRecoveryModel.fromJson(json['powerOffRecovery']),
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
      'systemDefinition': systemDefinition.toJson(),
      'powerOffRecovery': powerOffRecovery.toJson(),
    };
  }

  String toMqtt() {
    return "$sNo,$hid,${systemDefinition.toMqtt()},${systemDefinition.irrigationLineOn ? 1 : 0}";
  }
}

class EnergySaveSettings {
  bool status;
  String startDayTime;
  String stopDayTime;
  bool pauseMainLine;
  bool irrigationLineOn;
  DayTimeRange sunday;
  DayTimeRange monday;
  DayTimeRange tuesday;
  DayTimeRange wednesday;
  DayTimeRange thursday;
  DayTimeRange friday;
  DayTimeRange saturday;

  EnergySaveSettings({
    required this.status,
    required this.startDayTime,
    required this.stopDayTime,
    required this.pauseMainLine,
    required this.irrigationLineOn,
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory EnergySaveSettings.fromJson(Map<String, dynamic> json) {
    return EnergySaveSettings(
      status: json['status'],
      startDayTime: json['startDayTime'],
      stopDayTime: json['stopDayTime'],
      pauseMainLine: json['pauseMainLine'],
      irrigationLineOn: json['irrigationLineOn'] ?? false,
      sunday: DayTimeRange.fromJson(json['sunday']),
      monday: DayTimeRange.fromJson(json['monday']),
      tuesday: DayTimeRange.fromJson(json['tuesday']),
      wednesday: DayTimeRange.fromJson(json['wednesday']),
      thursday: DayTimeRange.fromJson(json['thursday']),
      friday: DayTimeRange.fromJson(json['friday']),
      saturday: DayTimeRange.fromJson(json['saturday']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'startDayTime': startDayTime,
      'stopDayTime': stopDayTime,
      'pauseMainLine': pauseMainLine,
      'irrigationLineOn': irrigationLineOn,
      'sunday': sunday.toJson(),
      'monday': monday.toJson(),
      'tuesday': tuesday.toJson(),
      'wednesday': wednesday.toJson(),
      'thursday': thursday.toJson(),
      'friday': friday.toJson(),
      'saturday': saturday.toJson(),
    };
  }

  String toMqtt() {
    return '${status ? 1 : 0},'
        '${startDayTime != "00:00" ? startDayTime : "00:00:00"},'
        '${stopDayTime != "00:00" ? stopDayTime : "00:00:00"},'
        '${pauseMainLine ? 1 : 0},'
        '${sunday.toMqtt()},'
        '${monday.toMqtt()},'
        '${tuesday.toMqtt()},'
        '${wednesday.toMqtt()},'
        '${thursday.toMqtt()},'
        '${friday.toMqtt()},'
        '${saturday.toMqtt()}';
  }

}

class DayTimeRange {
  String from;
  String to;
  bool selected;

  DayTimeRange({
    required this.from,
    required this.to,
    required this.selected,
  });

  factory DayTimeRange.fromJson(Map<String, dynamic> json) {
    return DayTimeRange(
      from: json['from'],
      to: json['to'],
      selected: json['selected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'selected': selected,
    };
  }

  String toMqtt() {
    return '${selected ? 1 : 0},'
        '${from != "00:00" ? from : "00:00:00"},'
        '${to != "00:00" ? to : "00:00:00"}';
  }
}

class PowerOffRecoveryModel {
  String duration;
  List<String> selectedOption;

  PowerOffRecoveryModel({
    required this.duration,
    required this.selectedOption,
  });

  factory PowerOffRecoveryModel.fromJson(Map<String, dynamic> json) {
    return PowerOffRecoveryModel(
      duration: json['duration'],
      selectedOption: List<String>.from(json['selectedOption']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'selectedOption': selectedOption,
    };
  }

  String getOptionCode(option) {
    if (option.contains("Reset") && option.contains("Queue") && option.contains("Irrigation")) {
      return "${1},${1},${1}";
    } else if (option.contains("Reset") && option.contains("Queue")) {
      return "${1},${1},${0}";
    } else if (option.contains("Reset") && option.contains("Irrigation")) {
      return "${1},${0},${1}";
    } else if (option.contains("Queue") && option.contains("Irrigation")) {
      return "${0},${1},${1}";
    } else if (option.contains("Reset")) {
      return "${1},${0},${0}";
    } else if (option.contains("Queue")) {
      return "${0},${1},${0}";
    } else if (option.contains("Irrigation")) {
      return "${0},${0},${1}";
    } else {
      return "${0},${0},${0}";
    }
  }

  String toMqtt() {
    return '${duration != "00:00" ? "$duration:00" : "00:00:00"},'
        '${getOptionCode(selectedOption)}';
  }
}