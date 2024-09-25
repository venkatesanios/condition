import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../constants/http_service.dart';

class ReportPage extends StatefulWidget {
  final String initialReportType;

  ReportPage({required this.initialReportType});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isLoading = false;
  List<dynamic> hourlyData = [];
  String errorMessage = '';
  String selectedReportType = " ";

  final List<String> reportTypes = [
    'SoilMoisture1',
    'SoilMoisture2',
    'SoilMoisture3',
    'SoilMoisture4',
    'SoilTemperature',
    'Humidity',
    'WindDirection',
    'WindSpeed',
    'temperature',
    'AtmosphericPressure',
    'LeafWetness',
    'Rainfall',
    'CO2',
    'LDR',
    'Lux'
  ];

  @override
  void initState() {
    super.initState();
    selectedReportType = widget.initialReportType;
    if (!reportTypes.contains(selectedReportType)) {
      selectedReportType = reportTypes.first;
    }
    fetchHourlyData(selectedDate, selectedReportType);
  }

  Future<void> fetchHourlyData(String date, String reportType) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    Map<String, Object> body = {
      "userId": 18,
      "controllerId": 54,
      "fromDate": date,
      "toDate": date,
    };

    final response =
    await HttpService().postRequest("getUserWeatherReport", body);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        print("---hourly data----$jsonData");
        Map<String, dynamic> data = jsonData;

        List<Map<String, dynamic>> logs = [];
        data['data'][0].forEach((key, value) {
          if (key.startsWith('hour')) {
            logs.addAll(List<Map<String, dynamic>>.from(value));
          }
        });

        List<Map<String, dynamic>> hourlyDataList = [];
        print("-----DATE---$date---");

        for (var log in logs) {
          Map<String, dynamic> hourlyLog = {};
          String time = log['time'];
          hourlyLog['time'] = time;
          String key = _getReportTypeKey(reportType);
          hourlyLog[reportType] = log[key];
          hourlyDataList.add(hourlyLog);
          print("time${time}----${key}---${hourlyLog[reportType]}");
        }

        hourlyData = hourlyDataList;
        isLoading = false;
      });
    } else {
      print("THERE is NO DATA________IN the DATE----");
      setState(() {
        errorMessage =
        'Failed to fetch data from the server. Status code: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  String _getReportTypeKey(String reportType) {
    switch (reportType) {
      case 'SoilMoisture1':
        return '1- Value';
      case 'SoilMoisture2':
        return '2- Value';
      case 'SoilMoisture3':
        return '3- Value';
      case 'SoilMoisture4':
        return '4- Value';
      case 'SoilTemperature':
        return '5- Value';
      case 'Humidity':
        return '6- Value';
      case 'WindDirection':
        return '12- Value';
      case 'WindSpeed':
        return '13- Value';
      case 'temperature':
        return '7- Value';
      case 'AtmosphericPressure':
        return '8- Value';
      case 'LeafWetness':
        return '15- Value';
      case 'Rainfall':
        return '14- Value';
      case 'CO2':
        return '9- Value';
      case 'LDR':
        return '10- Value';
      case 'Lux':
        return '11- Value';
      default:
        return 'no data';
    }
  }

  NumericAxis _getYAxisSettings() {
    switch (selectedReportType) {
      case 'SoilMoisture1':
      case 'SoilMoisture2':
      case 'SoilMoisture3':
      case 'SoilMoisture4':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 220,
          interval: 20,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'SoilTemperature':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 100,
          maximum: 0,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'Humidity':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 100.0,
          interval: 6.0,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'temperature':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 90.0,
          interval: 5.0,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'AtmosphericPressure':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 2.0,
          interval: 0.2,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'CO2':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 900.0,
          interval: 50.0,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'WindSpeed':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 10.0,
          interval: 0.5,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
      case 'LDR':
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          minimum: 0,
          maximum: 10.0,
          interval: 0.5,
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
        );
      default:
        return NumericAxis(
          autoScrollingMode: AutoScrollingMode.end,
          title: AxisTitle(
            text: selectedReportType,
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          labelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.teal),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String yaxixname = ('Hours');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${widget.initialReportType} Report',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(00.0),
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color:
                colorScheme.surface, // Background color for the container
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Row(
                children: [
                  Center(
                      child: Text(
                        'Select Date :',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          selectedDate = formattedDate;
                        });
                        fetchHourlyData(selectedDate, selectedReportType);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.surface,
                        backgroundColor: colorScheme.primary
                      // Change the text color of the button
                    ),
                    child: Text(
                      selectedDate,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
                child: Text(
                  "NO DATA RECORDS IN SELECTED DATE ! ! !",
                  style: TextStyle(
                      color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                ))
          else if (errorMessage.isNotEmpty)
            Center(child: Text(errorMessage))
          else ...[
              SizedBox(height: 00),
              Expanded(
                child: SfCartesianChart(
                  backgroundColor: colorScheme.surface,
                  enableSideBySideSeriesPlacement: true,
                  borderWidth: 1.8,
                  plotAreaBorderColor: Colors.grey[900],
                  plotAreaBorderWidth: 0.6,
                  primaryXAxis: CategoryAxis(
                    title: AxisTitle(
                        text: yaxixname,
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    interval: 2,
                    minimum: 0,
                    maximum: 23, // Set interval to 1 to show every hour
                    labelRotation: 0, // Rotate labels for better readability
                    majorGridLines: MajorGridLines(width: 1),
                    autoScrollingMode: AutoScrollingMode.start,
                    labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  primaryYAxis: _getYAxisSettings(),
                  title: ChartTitle(
                      text: '$selectedReportType Data',
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                      )),
                  legend: Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(
                      enable: false,
                      header: selectedReportType,
                      duration: 0.2,
                      color: Colors.blue),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                    zoomMode: ZoomMode.xy,
                  ),
                  series: <CartesianSeries>[
                    LineSeries<ChartData, String>(
                      dataSource: _getChartData(),
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: selectedReportType,
                      color: Colors.blueGrey, // Set the line color here
                      width: 1.0, // Set the line width here
                      dashArray: [0], // Set the line style (dashed) here
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: Colors.white,
                        height: 3,
                        width: 3,
                        shape: DataMarkerType.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  List<ChartData> _getChartData() {
    return hourlyData.map((data) {
      return ChartData(
        hour: _formatHour(data['time']),
        value:
        double.tryParse(data[selectedReportType]?.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  String _formatHour(String time) {
    try {
      final hour = int.parse(time.split(':')[0]); // Extract hour part
      return '$hour'; // Format as "1", "2", etc.
    } catch (e) {
      return 'Unknown';
    }
  }
}

class ChartData {
  final String hour;
  final double value;

  ChartData({required this.hour, required this.value});
}
