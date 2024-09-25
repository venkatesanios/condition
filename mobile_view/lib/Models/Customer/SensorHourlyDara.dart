
class AllMySensor {
  final String name;
  final Map<String, List<SensorHourlyData>> data;

  AllMySensor({required this.name, required this.data});

  factory AllMySensor.fromJson(Map<String, dynamic> json) {
    Map<String, List<SensorHourlyData>> dataMap = {};
    json['data'].forEach((key, value) {
      dataMap[key] = (value as List).map((item) => SensorHourlyData.fromJson(item)).toList();
    });

    return AllMySensor(
      name: json['name'],
      data: dataMap,
    );
  }
}


class SensorHourlyData {
  final String? name; // Add this to store the sensor name
  final String id;
  final double value;
  final String hour; // Add this to store the hour key

  SensorHourlyData({required this.id, required this.value, required this.hour, this.name});

  factory SensorHourlyData.fromJson(Map<String, dynamic> json) {
    return SensorHourlyData(
      name: json['Name'], // Parse the sensor name
      id: json['Id'],
      value: double.tryParse(json['Value']) ?? 0.0,
      hour: json['hour'], // Make sure to include hour
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Id': id,
      'Value': value,
      'hour': hour, // Include hour in the JSON representation
    };
  }
}
