class PumpControllerData {
  List<IndividualPumpData> pumps;
  dynamic voltage;
  dynamic current;
  dynamic signalStrength;
  dynamic batteryStrength;
  dynamic version;
  String numberOfPumps;

  PumpControllerData({required this.pumps, required this.voltage, required this.current, required this.batteryStrength, required this.signalStrength, required this.numberOfPumps, required this.version});

  factory PumpControllerData.fromJson(Map<String, dynamic> json, String key) {
    print(json[key]);
    List<dynamic> pumpsJson = json[key] ?? [];
    dynamic lastElement = {};
    if(pumpsJson.isNotEmpty) {
      lastElement = pumpsJson.last;
      pumpsJson.removeLast();
    }

    return PumpControllerData(
      pumps: List<IndividualPumpData>.from(pumpsJson.map((x) => IndividualPumpData.fromJson(x))),
      voltage: lastElement['V'] ?? "",
      current: lastElement['C'] ?? "",
      version: lastElement['VS'] ?? "",
      signalStrength: lastElement['SS'] ?? "",
      batteryStrength: lastElement['B'] ?? "",
      numberOfPumps: lastElement['NP'] ?? "0",
    );
  }
}

class IndividualPumpData {
  int status;
  String reason;
  int reasonCode;
  String waterMeter;
  String cumulativeFlow;
  dynamic pressure;
  dynamic actual;
  dynamic set;
  String level;
  dynamic phase;
  String float;
  String onDelayTimer;
  String onDelayComplete;
  String onDelayLeft;
  String cyclicOffDelay;
  String cyclicOnDelay;
  String maximumRunTimeRemaining;

  IndividualPumpData({
    required this.status,
    required this.reason,
    required this.reasonCode,
    required this.waterMeter,
    required this.cumulativeFlow,
    required this.pressure,
    required this.actual,
    required this.set,
    required this.level,
    required this.phase,
    required this.float,
    required this.onDelayTimer,
    required this.onDelayComplete,
    required this.onDelayLeft,
    required this.cyclicOffDelay,
    required this.cyclicOnDelay,
    required this.maximumRunTimeRemaining,
  });

  factory IndividualPumpData.fromJson(Map<String, dynamic> json) {
    final value = json["CF"];
    // print(value);
    int firstIndex = 0;
    if(value != "-") {
      for (int i = 0; i < value.length; i++) {
        if (int.parse(value[i]) > 0) {
          // print(i);
          firstIndex = i;
          break;
        }
      }
    }
    final reason = json["RN"];
    final status = json["ST"];
    const String motorOff = "Motor off due to";
    const String motorOn = "Motor on due to";
    return IndividualPumpData(
      reasonCode: json["RN"] ?? 0,
      status: status ?? 0,
      reason: reason == 1
          ? "$motorOff sump empty"
          : reason == 2
          ? "$motorOff upper tank full"
          : reason == 3
          ? "$motorOff low voltage"
          : reason == 4
          ? "$motorOff high voltage"
          : reason == 5
          ? "$motorOff voltage SPP"
          : reason == 6
          ? "$motorOff reverse phase"
          : reason == 7
          ? "$motorOff starter trip"
          : reason == 8
          ? "$motorOff dry run"
          : reason == 9
          ? "$motorOff overload"
          : reason == 10
          ? "$motorOff current SPP"
          : reason == 11
          ? "$motorOff cyclic trip"
          : reason == 12
          ? "$motorOff maximum run time"
          : reason == 13
          ? "$motorOff sump empty"
          : reason == 14
          ? "$motorOff upper tank full"
          : reason == 15
          ? "$motorOff RTC 1"
          : reason == 16
          ? "$motorOff RTC 2"
          : reason == 17
          ? "$motorOff RTC 3"
          : reason == 18
          ? "$motorOff RTC 4"
          : reason == 19
          ? "$motorOff RTC 5"
          : reason == 20
          ? "$motorOff RTC 6"
          : reason == 21
          ? "$motorOff auto mobile key off"
          : reason == 22
          ? "$motorOn cyclic time"
          : reason == 23
          ? "$motorOn RTC 1"
          : reason == 24
          ? "$motorOn RTC 2"
          : reason == 25
          ? "$motorOn RTC 3"
          : reason == 26
          ? "$motorOn RTC 4"
          : reason == 27
          ? "$motorOn RTC 5"
          : reason == 28
          ? "$motorOn RTC 6"
          : reason == 29
          ? "$motorOn auto mobile key on"
          : reason == 30
          ? "Power off"
          : reason == 31
          ? "Power on"
          : "Unknown",
      waterMeter: json["WM"],
      cumulativeFlow: value.substring(firstIndex),
      phase: json['PH'],
      pressure: json["PR"],
      actual: json["AT"],
      set: json["SE"],
      level: json["LV"],
      float: json["FT"],
      onDelayTimer: json["OD"],
      onDelayComplete: json["ODC"],
      onDelayLeft: json["ODL"],
      cyclicOffDelay: json["CFDL"],
      cyclicOnDelay: json["CNDL"],
      maximumRunTimeRemaining: json["MR"] ?? "",
    );
  }
}