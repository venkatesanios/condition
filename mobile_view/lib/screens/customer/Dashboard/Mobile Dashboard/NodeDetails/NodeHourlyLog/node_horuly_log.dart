import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../../constants/http_service.dart';

class NodeHrsLog extends StatefulWidget {
  const NodeHrsLog({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId, controllerId;

  @override
  State<NodeHrsLog> createState() => _NodeHrsLogState();
}

class _NodeHrsLogState extends State<NodeHrsLog> {

  Map<String, List<ChartData>> nodeDataMap = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    getNodeLogs(widget.userId, widget.controllerId, selectedDate);
  }

  Future<void> getNodeLogs(userId, controllerId, date) async
  {
    date = DateFormat('yyyy-MM-dd').format(selectedDate);

    Map<String, Object> body = {
      "userId": userId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date
    };
    final response = await HttpService().postRequest("getUserNodeStatusHourlyLog", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(response.body);
      if (data["code"] == 200) {
        final jsonData = data["data"] as List;
        try {
          nodeDataMap.clear();
          List<dynamic> hourlyData = jsonData[0].entries.toList();

          for (var hourEntry in hourlyData){
            String hour = hourEntry.key;
            if (hour.startsWith('hour')){
              List<dynamic> nodeList = hourEntry.value;
              if (nodeList.isNotEmpty){
                nodeList.removeAt(0);
              }
              for (var nodeData in nodeList) {
                String nodeId = nodeData['NodeId'];
                if (!nodeDataMap.containsKey(nodeId)) {
                  nodeDataMap[nodeId] = [];
                }
                nodeDataMap[nodeId]!.add(ChartData(
                  hour,
                  nodeData['BatteryVoltage'].toDouble(),
                  nodeData['SolarVoltage'].toDouble(),
                ));
              }
            }
          }

          setState(() {});

        } catch (e) {
          print('Error: $e');
          // indicatorViewHide();
        }
      }
    }
    else {
      //_showSnackBar(response.body);
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
        getNodeLogs(widget.userId, widget.controllerId, selectedDate);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node hourly logs'),
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
      body: nodeDataMap.isNotEmpty?SingleChildScrollView(
        child: Column(
          children: nodeDataMap.entries.map((entry) {
            String nodeId = entry.key;
            List<ChartData> chartData = entry.value;
            return SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'Node ID: $nodeId'),
              legend: const Legend(isVisible: true),
              //tooltipBehavior: TooltipBehavior(enable: true),
              series: <LineSeries<ChartData, String>>[
                LineSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.hour,
                  yValueMapper: (ChartData data, _) => data.batteryVoltage,
                  name: 'Battery Voltage',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
                LineSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.hour,
                  yValueMapper: (ChartData data, _) => data.solarVoltage,
                  name: 'Solar Voltage',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            );
          }).toList(),
        ),
      ):
      const Center(child: Text('Node hourly log not found')),
    );
  }
}

class ChartData {
  final String hour;
  final double batteryVoltage;
  final double solarVoltage;

  ChartData(this.hour, this.batteryVoltage, this.solarVoltage);
}
