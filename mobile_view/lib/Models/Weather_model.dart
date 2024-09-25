import 'dart:convert';

WeatherModel weatherModelFromJson(String str) =>
    WeatherModel.fromJson(json.decode(str));

String weatherModelToJson(WeatherModel data) => json.encode(data.toJson());

class WeatherModel {
  List<Datum>? data;

  WeatherModel({
    this.data,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    data: json["5100"] == null
        ? []
        : List<Datum>.from(json["5100"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "5100": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  List<Weatherdata>? WeatherSensorlist;

  Datum({
    this.WeatherSensorlist,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    WeatherSensorlist: json["5101"] == null
        ? []
        : List<Weatherdata>.from(
        json["5101"]!.map((x) => Weatherdata.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "5101": WeatherSensorlist == null
        ? []
        : List<dynamic>.from(WeatherSensorlist!.map((x) => x.toJson())),
  };
}

class Weatherdata {
  int? sNo;
  String? date;
  String? time;
  String? soilMoisture1;
  String? soilMoisture2;
  String? soilMoisture3;
  String? soilMoisture4;
  String? soilTemperature;
  String? humidity;
  String? temperature;
  String? atmospherePressure;
  String? co2;
  String? ldr;
  String? lux;
  String? windDirection;
  String? windSpeed;
  String? rainfall;
  String? leafWetness;
  String? soilMoisture1Err;
  String? soilMoisture2Err;
  String? soilMoisture3Err;
  String? soilMoisture4Err;
  String? soilTemperatureErr;
  String? humidityErr;
  String? temperatureErr;
  String? atmospherePressureErr;
  String? co2Err;
  String? ldrErr;
  String? luxErr;
  String? windDirectionErr;
  String? windSpeedErr;
  String? rainfallErr;
  String? leafWetnessErr;
  String? soilMoisture1Min;
  String? soilMoisture2Min;
  String? soilMoisture3Min;
  String? soilMoisture4Min;
  String? soilTemperatureMin;
  String? humidityMin;
  String? temperatureMin;
  String? atmospherePressureMin;
  String? co2Min;
  String? ldrMin;
  String? luxMin;
  String? windDirectionMin;
  String? windSpeedMin;
  String? rainfallMin;
  String? leafWetnessMin;
  String? soilMoisture1Max;
  String? soilMoisture2Max;
  String? soilMoisture3Max;
  String? soilMoisture4Max;
  String? soilTemperatureMax;
  String? humidityMax;
  String? temperatureMax;
  String? atmospherePressureMax;
  String? co2Max;
  String? ldrMax;
  String? luxMax;
  String? windDirectionMax;
  String? windSpeedMax;
  String? rainfallMax;
  String? leafWetnessMax;
  String? soilMoisture1MinTime;
  String? soilMoisture2MinTime;
  String? soilMoisture3MinTime;
  String? soilMoisture4MinTime;
  String? soilTemperatureMinTime;
  String? humidityMinTime;
  String? temperatureMinTime;
  String? atmospherePressureMinTime;
  String? co2MinTime;
  String? ldrMinTime;
  String? luxMinTime;
  String? windDirectionMinTime;
  String? windSpeedMinTime;
  String? rainfallMinTime;
  String? leafWetnessMinTime;
  String? soilMoisture1MaxTime;
  String? soilMoisture2MaxTime;
  String? soilMoisture3MaxTime;
  String? soilMoisture4MaxTime;
  String? soilTemperatureMaxTime;
  String? humidityMaxTime;
  String? temperatureMaxTime;
  String? atmospherePressureMaxTime;
  String? co2MaxTime;
  String? ldrMaxTime;
  String? luxMaxTime;
  String? windDirectionMaxTime;
  String? windSpeedMaxTime;
  String? rainfallMaxTime;
  String? leafWetnessMaxTime;

  List<String> sensorlist;
  List<String> sensorlisthw;

  Weatherdata({
    this.sNo,
    this.date,
    this.time,
    this.soilMoisture1,
    this.soilMoisture2,
    this.soilMoisture3,
    this.soilMoisture4,
    this.soilTemperature,
    this.humidity,
    this.temperature,
    this.atmospherePressure,
    this.co2,
    this.ldr,
    this.lux,
    this.windDirection,
    this.windSpeed,
    this.rainfall,
    this.leafWetness,
    this.soilMoisture1Err,
    this.soilMoisture2Err,
    this.soilMoisture3Err,
    this.soilMoisture4Err,
    this.soilTemperatureErr,
    this.humidityErr,
    this.temperatureErr,
    this.atmospherePressureErr,
    this.co2Err,
    this.ldrErr,
    this.luxErr,
    this.windDirectionErr,
    this.windSpeedErr,
    this.rainfallErr,
    this.leafWetnessErr,
    this.soilMoisture1Min,
    this.soilMoisture2Min,
    this.soilMoisture3Min,
    this.soilMoisture4Min,
    this.soilTemperatureMin,
    this.humidityMin,
    this.temperatureMin,
    this.atmospherePressureMin,
    this.co2Min,
    this.ldrMin,
    this.luxMin,
    this.windDirectionMin,
    this.windSpeedMin,
    this.rainfallMin,
    this.leafWetnessMin,
    this.soilMoisture1Max,
    this.soilMoisture2Max,
    this.soilMoisture3Max,
    this.soilMoisture4Max,
    this.soilTemperatureMax,
    this.humidityMax,
    this.temperatureMax,
    this.atmospherePressureMax,
    this.co2Max,
    this.ldrMax,
    this.luxMax,
    this.windDirectionMax,
    this.windSpeedMax,
    this.rainfallMax,
    this.leafWetnessMax,
    this.soilMoisture1MinTime,
    this.soilMoisture2MinTime,
    this.soilMoisture3MinTime,
    this.soilMoisture4MinTime,
    this.soilTemperatureMinTime,
    this.humidityMinTime,
    this.temperatureMinTime,
    this.atmospherePressureMinTime,
    this.co2MinTime,
    this.ldrMinTime,
    this.luxMinTime,
    this.windDirectionMinTime,
    this.windSpeedMinTime,
    this.rainfallMinTime,
    this.leafWetnessMinTime,
    this.soilMoisture1MaxTime,
    this.soilMoisture2MaxTime,
    this.soilMoisture3MaxTime,
    this.soilMoisture4MaxTime,
    this.soilTemperatureMaxTime,
    this.humidityMaxTime,
    this.temperatureMaxTime,
    this.atmospherePressureMaxTime,
    this.co2MaxTime,
    this.ldrMaxTime,
    this.luxMaxTime,
    this.windDirectionMaxTime,
    this.windSpeedMaxTime,
    this.rainfallMaxTime,
    this.leafWetnessMaxTime,
    required this.sensorlist,
    required this.sensorlisthw,
  });

  factory Weatherdata.fromJson(Map<String, dynamic> json) => Weatherdata(
    sNo: json["sNo"],
    date: json["date"],
    time: json["time"],
    soilMoisture1: '${json["1- Value"]}',
    soilMoisture2: '${json["2- Value"]}',
    soilMoisture3: '${json["3- Value"]}',
    soilMoisture4: '${json["4- Value"]}',
    soilTemperature: double.parse(json["5- Value"]) > 60
        ? '60 °C'
        : '${json["5- Value"]}',
    humidity: '${json["6- Value"]}',
    temperature: double.parse(json["7- Value"]) > 60
        ? '60 °C'
        : '${json["7- Value"]}',
    atmospherePressure: '${json["8- Value"]}',
    co2: '${json["9- Value"]}',
    ldr: '${json["10- Value"]}',
    lux: '${json["11- Value"]}',
    windDirection: '${json["12- Value"]}',
    windSpeed: '${json["13- Value"]}',
    rainfall: '${json["14- Value"]}',
    leafWetness: '${json["15- Value"]}',
    soilMoisture1Err: json["1- Errorstatus"],
    soilMoisture2Err: json["2- Errorstatus"],
    soilMoisture3Err: json["3- Errorstatus"],
    soilMoisture4Err: json["4- Errorstatus"],
    soilTemperatureErr: json["5- Errorstatus"],
    humidityErr: json["6- Errorstatus"],
    temperatureErr: json["7- Errorstatus"],
    atmospherePressureErr: json["8- Errorstatus"],
    co2Err: json["9- Errorstatus"],
    ldrErr: json["10- Errorstatus"],
    luxErr: json["11- Errorstatus"],
    windDirectionErr: json["12- Errorstatus"],
    windSpeedErr: json["13- Errorstatus"],
    rainfallErr: json["14- Errorstatus"],
    leafWetnessErr: json["15- Errorstatus"],
    soilMoisture1Min: json["1- Min"],
    soilMoisture2Min: json["2- Min"],
    soilMoisture3Min: json["3- Min"],
    soilMoisture4Min: json["4- Min"],
    soilTemperatureMin: json["5- Min"],
    humidityMin: json["6- Min"],
    temperatureMin: json["7- Min"],
    atmospherePressureMin: json["8- Min"],
    co2Min: json["9- Min"],
    ldrMin: json["10- Min"],
    luxMin: json["11- Min"],
    windDirectionMin: json["12- Min"],
    windSpeedMin: json["13- Min"],
    rainfallMin: json["14- Min"],
    leafWetnessMin: json["15- Min"],
    soilMoisture1Max: json["1- Max"],
    soilMoisture2Max: json["2- Max"],
    soilMoisture3Max: json["3- Max"],
    soilMoisture4Max: json["4- Max"],
    soilTemperatureMax: json["5- Max"],
    humidityMax: json["6- Max"],
    temperatureMax: json["7- Max"],
    atmospherePressureMax: json["8- Max"],
    co2Max: json["9- Max"],
    ldrMax: json["10- Max"],
    luxMax: json["11- Max"],
    windDirectionMax: json["12- Max"],
    windSpeedMax: json["13- Max"],
    rainfallMax: json["14- Max"],
    leafWetnessMax: json["15- Max"],
    soilMoisture1MinTime: json["1- MinTime"],
    soilMoisture2MinTime: json["2- MinTime"],
    soilMoisture3MinTime: json["3- MinTime"],
    soilMoisture4MinTime: json["4- MinTime"],
    soilTemperatureMinTime: json["5- MinTime"],
    humidityMinTime: json["6- MinTime"],
    temperatureMinTime: json["7- MinTime"],
    atmospherePressureMinTime: json["8- MinTime"],
    co2MinTime: json["9- MinTime"],
    ldrMinTime: json["10- MinTime"],
    luxMinTime: json["11- MinTime"],
    windDirectionMinTime: json["12- MinTime"],
    windSpeedMinTime: json["13- MinTime"],
    rainfallMinTime: json["14- MinTime"],
    leafWetnessMinTime: json["15- MinTime"],
    soilMoisture1MaxTime: json["1- MaxTime"],
    soilMoisture2MaxTime: json["2- MaxTime"],
    soilMoisture3MaxTime: json["3- MaxTime"],
    soilMoisture4MaxTime: json["4- MaxTime"],
    soilTemperatureMaxTime: json["5- MaxTime"],
    humidityMaxTime: json["6- MaxTime"],
    temperatureMaxTime: json["7- MaxTime"],
    atmospherePressureMaxTime: json["8- MaxTime"],
    co2MaxTime: json["9- MaxTime"],
    ldrMaxTime: json["10- MaxTime"],
    luxMaxTime: json["11- MaxTime"],
    windDirectionMaxTime: json["12- MaxTime"],
    windSpeedMaxTime: json["13- MaxTime"],
    rainfallMaxTime: json["14- MaxTime"],
    leafWetnessMaxTime: json["15- MaxTime"],
    sensorlist: _buildsensorlist(json),
    sensorlisthw: _buildsensorhwlist(json),
  );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "date": date,
    "time": time,
    "SoilMoisture1": soilMoisture1,
    "SoilMoisture2": soilMoisture2,
    "SoilMoisture3": soilMoisture3,
    "SoilMoisture4": soilMoisture4,
    "SoilTemperature": soilTemperature,
    "Humidity": humidity,
    "Temperature": temperature,
    "AtmospherePressure": atmospherePressure,
    "Co2": co2,
    "LDR": ldr,
    "Lux": lux,
    "WindDirection": windDirection,
    "WindSpeed": windSpeed,
    "Rainfall": rainfall,
    "LeafWetness": leafWetness,
    "SoilMoisture1Err": soilMoisture1Err,
    "SoilMoisture2Err": soilMoisture2Err,
    "SoilMoisture3Err": soilMoisture3Err,
    "SoilMoisture4Err": soilMoisture4Err,
    "SoilTemperatureErr": soilTemperatureErr,
    "HumidityErr": humidityErr,
    "TemperatureErr": temperatureErr,
    "AtmospherePressureErr": atmospherePressureErr,
    "Co2Err": co2Err,
    "LDRErr": ldrErr,
    "LuxErr": luxErr,
    "WindDirectionErr": windDirectionErr,
    "WindSpeedErr": windSpeedErr,
    "RainfallErr": rainfallErr,
    "LeafWetnessErr": leafWetnessErr,
    "soilMoisture1Min": soilMoisture1Min,
    "soilMoisture3Min": soilMoisture3Min,
    "soilMoisture4Min": soilMoisture4Min,
    "soilTemperatureMin": soilTemperatureMin,
    "humidityMin": humidityMin,
    "temperatureMin": temperatureMin,
    "atmospherePressureMin": atmospherePressureMin,
    "co2Min": co2Min,
    "ldrMin": ldrMin,
    "luxMin": luxMin,
    "windDirectionMin": windDirectionMin,
    "windSpeedMin": windSpeedMin,
    "rainfallMin": rainfallMin,
    "leafWetnessMin": leafWetnessMin,
    "soilMoisture1Max": soilMoisture1Max,
    "soilMoisture2Max": soilMoisture2Max,
    "soilMoisture3Max": soilMoisture3Max,
    "soilMoisture4Max": soilMoisture4Max,
    "soilTemperatureMax": soilTemperatureMax,
    "humidityMax": humidityMax,
    "temperatureMax": temperatureMax,
    "atmospherePressureMax": atmospherePressureMax,
    "co2Max": co2Max,
    "ldrMax": ldrMax,
    "luxMax": luxMax,
    "windDirectionMax": windDirectionMax,
    "windSpeedMax": windSpeedMax,
    "rainfallMax": rainfallMax,
    "leafWetnessMax": leafWetnessMax,
    "soilMoisture1MinTime": soilMoisture1MinTime,
    "soilMoisture2MinTime": soilMoisture2MinTime,
    "soilMoisture3MinTime": soilMoisture3MinTime,
    "soilMoisture4MinTime": soilMoisture4MinTime,
    "soilTemperatureMinTime": soilTemperatureMinTime,
    "humidityMinTime": humidityMinTime,
    "temperatureMinTime": temperatureMinTime,
    "atmospherePressureMinTime": atmospherePressureMinTime,
    "co2MinTime": co2MinTime,
    "ldrMinTime": ldrMinTime,
    "luxMinTime": luxMinTime,
    "windDirectionMinTime": windDirectionMinTime,
    "windSpeedMinTime": windSpeedMinTime,
    "rainfallMinTime": rainfallMinTime,
    "leafWetnessMinTime": leafWetnessMinTime,
    "soilMoisture1MaxTime": soilMoisture1MaxTime,
    "soilMoisture2MaxTime": soilMoisture2MaxTime,
    "soilMoisture3MaxTime": soilMoisture3MaxTime,
    "soilMoisture4MaxTime": soilMoisture4MaxTime,
    "soilTemperatureMaxTime": soilTemperatureMaxTime,
    "humidityMaxTime": humidityMaxTime,
    "temperatureMaxTime": temperatureMaxTime,
    "atmospherePressureMaxTime": atmospherePressureMaxTime,
    "co2MaxTime": co2MaxTime,
    "ldrMaxTime": ldrMaxTime,
    "luxMaxTime": luxMaxTime,
    "windDirectionMaxTime": windDirectionMaxTime,
    "windSpeedMaxTime": windSpeedMaxTime,
    "rainfallMaxTime": rainfallMaxTime,
    "leafWetnessMaxTime": leafWetnessMaxTime,
  };

  static List<String> _buildsensorlist(Map<String, dynamic> json) {
    print('_buildsensorlist');
    List<String> sensorlist = [];

    if (json["1- Value"] != '-') {
      sensorlist.add('SoilMoisture1');
    }
    if (json["2- Value"] != '-') {
      sensorlist.add('SoilMoisture2');
    }
    if (json["3- Value"] != '-') {
      sensorlist.add('SoilMoisture3');
    }
    if (json["4- Value"] != '-') {
      sensorlist.add('SoilMoisture4');
    }
    if (json["5- Value"] != '-') {
      sensorlist.add('SoilTemperature');
    }
    if (json["6- Value"] != '-') {
      sensorlist.add('Humidity');
    }
    if (json["7- Value"] != '-') {
      sensorlist.add('Temperature');
    }
    if (json["8- Value"] != '-') {
      sensorlist.add('AtmospherePressure');
    }
    if (json["9- Value"] != '-') {
      sensorlist.add('Co2');
    }
    if (json["10- Value"] != '-') {
      sensorlist.add('LDR');
    }
    if (json["11- Value"] != '-') {
      sensorlist.add('Lux');
    }
    if (json["12- Value"] != '-') {
      sensorlist.add('WindDirection');
    }
    if (json["13- Value"] != '-') {
      sensorlist.add('WindSpeed');
    }
    if (json["14- Value"] != '-') {
      sensorlist.add('Rainfall');
    }
    if (json["15- Value"] != '-') {
      sensorlist.add('LeafWetness');
    }
    return sensorlist;
  }

  static List<String> _buildsensorhwlist(Map<String, dynamic> json) {
    print('_buildsensorlist');
    List<String> sensorlist = [];

    if (json["1- Value"] != '-') {
      sensorlist.add('1- Value');
    }
    if (json["2- Value"] != '-') {
      sensorlist.add('2- Value');
    }
    if (json["3- Value"] != '-') {
      sensorlist.add('3- Value');
    }
    if (json["4- Value"] != '-') {
      sensorlist.add('4- Value');
    }
    if (json["5- Value"] != '-') {
      sensorlist.add('5- Value');
    }
    if (json["6- Value"] != '-') {
      sensorlist.add('6- Value');
    }
    if (json["7- Value"] != '-') {
      sensorlist.add('7- Value');
    }
    if (json["8- Value"] != '-') {
      sensorlist.add('8- Value');
    }
    if (json["9- Value"] != '-') {
      sensorlist.add('9- Value');
    }
    if (json["10- Value"] != '-') {
      sensorlist.add('10- Value');
    }
    if (json["11- Value"] != '-') {
      sensorlist.add('11- Value');
    }
    if (json["12- Value"] != '-') {
      sensorlist.add('12- Value');
    }
    if (json["13- Value"] != '-') {
      sensorlist.add('13- Value');
    }
    if (json["14- Value"] != '-') {
      sensorlist.add('14- Value');
    }
    if (json["15- Value"] != '-') {
      sensorlist.add('15- Value');
    }
    return sensorlist;
  }

  static String degreeToDirection(String degreestr) {
    String cleanedString = degreestr.replaceAll('º', '').trim();
    double degree = double.parse(cleanedString);
    if ((degree >= 337.5 && degree <= 360) ||
        (degree >= 0.1 && degree < 22.5)) {
      return 'North';
    } else if (degree >= 22.5 && degree < 67.5) {
      return 'NorthEast';
    } else if (degree >= 67.5 && degree < 112.5) {
      return 'East';
    } else if (degree >= 112.5 && degree < 157.5) {
      return 'SouthEast';
    } else if (degree >= 157.5 && degree < 202.5) {
      return 'South';
    } else if (degree >= 202.5 && degree < 247.5) {
      return 'SouthWest';
    } else if (degree >= 247.5 && degree < 292.5) {
      return 'West';
    } else if (degree >= 292.5 && degree < 337.5) {
      return 'NorthWest';
    } else {
      return degreestr;
    }
  }
}
