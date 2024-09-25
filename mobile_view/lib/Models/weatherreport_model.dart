// To parse this JSON data, do
//
//     final weatherModelReport = weatherModelReportFromJson(jsonString);

import 'dart:convert';

List<WeatherModelReport> weatherModelReportFromJson(String str) => List<WeatherModelReport>.from(json.decode(str).map((x) => WeatherModelReport.fromJson(x)));

String weatherModelReportToJson(List<WeatherModelReport> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WeatherModelReport {
  DateTime? date;
  List<Hour>? hour1;
  List<Hour>? hour2;
  List<Hour>? hour3;
  List<Hour>? hour4;
  List<Hour>? hour5;
  List<Hour>? hour6;
  List<Hour>? hour7;
  List<Hour>? hour8;
  List<Hour>? hour9;
  List<Hour>? hour10;
  List<Hour>? hour11;
  List<Hour>? hour12;
  List<Hour>? hour13;
  List<Hour>? hour14;
  List<Hour>? hour15;
  List<Hour>? hour16;
  List<Hour>? hour17;
  List<Hour>? hour18;
  List<Hour>? hour19;
  List<Hour>? hour20;
  List<Hour>? hour21;
  List<Hour>? hour22;
  List<Hour>? hour23;
  List<Hour>? hour24;

  WeatherModelReport({
    this.date,
    this.hour1,
    this.hour2,
    this.hour3,
    this.hour4,
    this.hour5,
    this.hour6,
    this.hour7,
    this.hour8,
    this.hour9,
    this.hour10,
    this.hour11,
    this.hour12,
    this.hour13,
    this.hour14,
    this.hour15,
    this.hour16,
    this.hour17,
    this.hour18,
    this.hour19,
    this.hour20,
    this.hour21,
    this.hour22,
    this.hour23,
    this.hour24,
  });

  factory WeatherModelReport.fromJson(Map<String, dynamic> json) => WeatherModelReport(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    hour1: json["hour1"] == null ? [] : List<Hour>.from(json["hour1"]!.map((x) => Hour.fromJson(x))),
    hour2: json["hour2"] == null ? [] : List<Hour>.from(json["hour2"]!.map((x) => Hour.fromJson(x))),
    hour3: json["hour3"] == null ? [] : List<Hour>.from(json["hour3"]!.map((x) => Hour.fromJson(x))),
    hour4: json["hour4"] == null ? [] : List<Hour>.from(json["hour4"]!.map((x) => Hour.fromJson(x))),
    hour5: json["hour5"] == null ? [] : List<Hour>.from(json["hour5"]!.map((x) => Hour.fromJson(x))),
    hour6: json["hour6"] == null ? [] : List<Hour>.from(json["hour6"]!.map((x) => Hour.fromJson(x))),
    hour7: json["hour7"] == null ? [] : List<Hour>.from(json["hour7"]!.map((x) => Hour.fromJson(x))),
    hour8: json["hour8"] == null ? [] : List<Hour>.from(json["hour8"]!.map((x) => Hour.fromJson(x))),
    hour9: json["hour9"] == null ? [] : List<Hour>.from(json["hour9"]!.map((x) => Hour.fromJson(x))),
    hour10: json["hour10"] == null ? [] : List<Hour>.from(json["hour10"]!.map((x) => Hour.fromJson(x))),
    hour11: json["hour11"] == null ? [] : List<Hour>.from(json["hour11"]!.map((x) => Hour.fromJson(x))),
    hour12: json["hour12"] == null ? [] : List<Hour>.from(json["hour12"]!.map((x) => Hour.fromJson(x))),
    hour13: json["hour13"] == null ? [] : List<Hour>.from(json["hour13"]!.map((x) => Hour.fromJson(x))),
    hour14: json["hour14"] == null ? [] : List<Hour>.from(json["hour14"]!.map((x) => Hour.fromJson(x))),
    hour15: json["hour15"] == null ? [] : List<Hour>.from(json["hour15"]!.map((x) => Hour.fromJson(x))),
    hour16: json["hour16"] == null ? [] : List<Hour>.from(json["hour16"]!.map((x) => Hour.fromJson(x))),
    hour17: json["hour17"] == null ? [] : List<Hour>.from(json["hour17"]!.map((x) => Hour.fromJson(x))),
    hour18: json["hour18"] == null ? [] : List<Hour>.from(json["hour18"]!.map((x) => Hour.fromJson(x))),
    hour19: json["hour19"] == null ? [] : List<Hour>.from(json["hour19"]!.map((x) => Hour.fromJson(x))),
    hour20: json["hour20"] == null ? [] : List<Hour>.from(json["hour20"]!.map((x) => Hour.fromJson(x))),
    hour21: json["hour21"] == null ? [] : List<Hour>.from(json["hour21"]!.map((x) => Hour.fromJson(x))),
    hour22: json["hour22"] == null ? [] : List<Hour>.from(json["hour22"]!.map((x) => Hour.fromJson(x))),
    hour23: json["hour23"] == null ? [] : List<Hour>.from(json["hour23"]!.map((x) => Hour.fromJson(x))),
    hour24: json["hour24"] == null ? [] : List<Hour>.from(json["hour24"]!.map((x) => Hour.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "hour1": hour1 == null ? [] : List<dynamic>.from(hour1!.map((x) => x.toJson())),
    "hour2": hour2 == null ? [] : List<dynamic>.from(hour2!.map((x) => x.toJson())),
    "hour3": hour3 == null ? [] : List<dynamic>.from(hour3!.map((x) => x.toJson())),
    "hour4": hour4 == null ? [] : List<dynamic>.from(hour4!.map((x) => x.toJson())),
    "hour5": hour5 == null ? [] : List<dynamic>.from(hour5!.map((x) => x.toJson())),
    "hour6": hour6 == null ? [] : List<dynamic>.from(hour6!.map((x) => x.toJson())),
    "hour7": hour7 == null ? [] : List<dynamic>.from(hour7!.map((x) => x.toJson())),
    "hour8": hour8 == null ? [] : List<dynamic>.from(hour8!.map((x) => x.toJson())),
    "hour9": hour9 == null ? [] : List<dynamic>.from(hour9!.map((x) => x.toJson())),
    "hour10": hour10 == null ? [] : List<dynamic>.from(hour10!.map((x) => x.toJson())),
    "hour11": hour11 == null ? [] : List<dynamic>.from(hour11!.map((x) => x.toJson())),
    "hour12": hour12 == null ? [] : List<dynamic>.from(hour12!.map((x) => x.toJson())),
    "hour13": hour13 == null ? [] : List<dynamic>.from(hour13!.map((x) => x.toJson())),
    "hour14": hour14 == null ? [] : List<dynamic>.from(hour14!.map((x) => x.toJson())),
    "hour15": hour15 == null ? [] : List<dynamic>.from(hour15!.map((x) => x.toJson())),
    "hour16": hour16 == null ? [] : List<dynamic>.from(hour16!.map((x) => x.toJson())),
    "hour17": hour17 == null ? [] : List<dynamic>.from(hour17!.map((x) => x.toJson())),
    "hour18": hour18 == null ? [] : List<dynamic>.from(hour18!.map((x) => x.toJson())),
    "hour19": hour19 == null ? [] : List<dynamic>.from(hour19!.map((x) => x.toJson())),
    "hour20": hour20 == null ? [] : List<dynamic>.from(hour20!.map((x) => x.toJson())),
    "hour21": hour21 == null ? [] : List<dynamic>.from(hour21!.map((x) => x.toJson())),
    "hour22": hour22 == null ? [] : List<dynamic>.from(hour22!.map((x) => x.toJson())),
    "hour23": hour23 == null ? [] : List<dynamic>.from(hour23!.map((x) => x.toJson())),
    "hour24": hour24 == null ? [] : List<dynamic>.from(hour24!.map((x) => x.toJson())),
  };
}

class Hour {
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
   Hour({
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
   });

  factory Hour.fromJson(Map<String, dynamic> json) => Hour(
    sNo: json["sNo"],
    date: json["date"],
    time: json["time"],
    soilMoisture1: '${json["1- Value"]} CB',
    soilMoisture2: '${json["2- Value"]} CB',
    soilMoisture3: '${json["3- Value"]} CB',
    soilMoisture4: '${json["4- Value"]} CB',
    soilTemperature: '${json["5- Value"]} °C',
    humidity: '${json["6- Value"]} %',
    temperature: '${json["7- Value"]} °C',
    atmospherePressure: '${json["8- Value"]} bar',
    co2: '${json["9- Value"]} ppm',
    ldr: '${json["10- Value"]} Lum',
    lux: '${json["11- Value"]} Lum',
    windDirection: '${json["12- Value"]}',
    windSpeed: '${json["13- Value"]} kmh',
    rainfall: '${json["14- Value"]} mm',
    leafWetness: '${json["15- Value"]} wet',
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
  };

}
