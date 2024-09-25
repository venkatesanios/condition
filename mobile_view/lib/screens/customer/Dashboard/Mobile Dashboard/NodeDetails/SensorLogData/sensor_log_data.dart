import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../../Models/Customer/SensorHourlyDara.dart';
import '../../../../../../constants/http_service.dart';

class SensorHourlyLogs extends StatefulWidget {
  const SensorHourlyLogs({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId, controllerId;

  @override
  State<SensorHourlyLogs> createState() => _SensorHourlyLogsState();
}

class _SensorHourlyLogsState extends State<SensorHourlyLogs> {
  DateTime selectedDate = DateTime.now();
  List<AllMySensor> sensors = [];

  @override
  void initState() {
    super.initState();
    getSensorHourlyLogs(widget.userId, widget.controllerId, selectedDate);
  }


  Future<void> getSensorHourlyLogs(userId, controllerId, selectedDate) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    Map<String, Object> body = {
      "userId": userId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date
    };

    final response = await HttpService().postRequest("getUserSensorHourlyLog", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        try {
          sensors = (data['data'] as List)
              .map((item) {
            final Map<String, List<SensorHourlyData>> sensorData = {};
            item['data'].forEach((hour, values) {
              sensorData[hour] = (values as List)
                  .map((sensorItem) => SensorHourlyData.fromJson({
                ...sensorItem,
                'hour': hour, // Add the hour to each item
              }))
                  .toList();
            });
            return AllMySensor(name: item['name'], data: sensorData);
          })
              .toList();

          setState(() {
          });
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        getSensorHourlyLogs(widget.userId, widget.controllerId, selectedDate);
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: DefaultTabController(
        length: sensors.length,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              isScrollable: true,
              tabs: sensors.map((sensor) => Tab(text: sensor.name)).toList(),
            ),
            title: const Text('Sensor Data Charts'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: sensors.map((sensor) {
              return buildLineChart(sensor.data);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Row buildLineChart(Map<String, List<SensorHourlyData>> sensorData) {
    final Set<String> allHours = {};
    sensorData.values.expand((hourlyData) => hourlyData).forEach((data) {
      allHours.add(data.hour);
    });

    final List<String> sortedHours = allHours.toList()..sort();
    final Map<String, List<SensorHourlyData>> groupedByName = {};

    sensorData.values.expand((hourlyData) => hourlyData).forEach((data) {
      final sensorName = data.name ?? "Unnamed Sensor";
      groupedByName.putIfAbsent(sensorName, () => []).add(data);
    });

    final List<Color> sensorColors = [Colors.blue, Colors.red, Colors.green, Colors.orange]; // Example colors

    final List<LineSeries<SensorHourlyData, String>> series = [];
    int colorIndex = 0;

    groupedByName.forEach((sensorName, sensorValues) {
      final color = sensorColors[colorIndex % sensorColors.length];
      colorIndex++;

      final dataPoints = sortedHours.map((hour) {
        final data = sensorValues.firstWhere(
              (d) => d.hour == hour,
          orElse: () => SensorHourlyData(id: '', value: 0.0, hour: hour, name: sensorName),
        );
        return data;
      }).toList();

      series.add(LineSeries<SensorHourlyData, String>(
        name: sensorName,
        dataSource: dataPoints,
        xValueMapper: (SensorHourlyData data, _) => data.hour,
        yValueMapper: (SensorHourlyData data, _) => data.value,
        color: color,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        markerSettings: const MarkerSettings(isVisible: true),
        dashArray: [4, 4],
        width: 1.5,
        emptyPointSettings: EmptyPointSettings(
          mode: EmptyPointMode.gap,
        ),
      ));
    });

    // Include the 'Hour' column
    final List<DataRow> rows = sortedHours.map((hour) {
      int sensorIndex = 0;
      return DataRow(cells: [
        DataCell(Text(hour, style: const TextStyle(fontSize: 13, color: Colors.black54),)), // Hour column
        ...groupedByName.entries.map((sensorEntry) {
          final data = sensorEntry.value.firstWhere(
                (d) => d.hour == hour,
            orElse: () => SensorHourlyData(id: '', value: 0.0, hour: hour),
          );
          final sensorColor = sensorColors[sensorIndex % sensorColors.length];
          sensorIndex++;
          return DataCell(Text(data.value.toString(), style: TextStyle(color: sensorColor)));
        }).toList(),
      ]);
    }).toList();

    return Row(
      children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: 'Hours'),
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Sensor Values'),
            ),
            title: ChartTitle(text: 'Line chart'),
            legend: const Legend(isVisible: true, position: LegendPosition.right),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: series,
          ),
        ),
        /*const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: VerticalDivider(width: 0,),
        ),
        SizedBox(
          width: groupedByName.length*50+60,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('In Table'),
              ),
              Expanded(
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 500,
                  dataRowHeight: 45.0,
                  headingRowHeight: 0.0,
                  headingRowColor: WidgetStateProperty.all<Color>(Colors.transparent),
                  columns: [
                    const DataColumn2(label: Text('Hour',),fixedWidth: 60), // Hour header
                    ...groupedByName.keys.map((_) => const DataColumn2(label: Text(''), fixedWidth: 50)), // Empty sensor headers
                  ],
                  rows: rows,
                ),
              ),
            ],
          ),
        ),*/
      ],
    );
  }

}
