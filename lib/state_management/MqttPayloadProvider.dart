import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  int _wifiStrength = 0;
  List<dynamic> _list2401 = [];

  StreamController<String> _payloadStreamController = StreamController<String>();


  void updateReceivedPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      print(payload);

      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        if (data['2400'][0].containsKey('WifiStrength')) {
          _wifiStrength = data['2400'][0]['WifiStrength'];
        }
        if (data['2400'][0].containsKey('2401')) {
          _list2401 = data['2400'][0]['2401'];
        }
      } else {
        print('Error: Key "2400" not found or its value is null or empty.');
      }

      _payloadStreamController.add(payload); // Emit the updated payload to listeners
    } catch (e) {
      print('Error parsing JSON: $e');
    }

    notifyListeners();
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }


  Stream<String> get payloadStream => _payloadStreamController.stream;
  int get receivedWifiStrength => _wifiStrength;
  List<dynamic> get receivedNodeList => _list2401;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

  @override
  void dispose() {
    _payloadStreamController.close();
    super.dispose();
  }
}