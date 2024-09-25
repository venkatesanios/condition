import 'dart:async';
import 'package:flutter/material.dart';

class ConditionProvider extends ChangeNotifier {
    String _sensorDetails = '';
  // Stream<String> get stream => _streamController.stream;
    String get SensorDetails => _sensorDetails;

  void updateSensorData(String newData) {
    _sensorDetails = newData;
    notifyListeners();
  }

  @override
  void dispose() {
    // _sensorDetails
    //.close();
    super.dispose();
  }
}