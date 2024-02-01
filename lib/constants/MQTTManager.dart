import 'dart:async';

import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';
import '../state_management/MqttPayloadProvider.dart';

class MQTTManager {
  static MQTTManager? _instance;
  //MqttPayloadProvider? providerState;
  MqttBrowserClient? _client;

  factory MQTTManager() {
    _instance ??= MQTTManager._internal();
    return _instance!;
  }

  MQTTManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  StreamController<String> payloadStreamController = StreamController<String>();
  Stream<String> get payloadStream => payloadStreamController.stream;

  void initializeMQTTClient({MqttPayloadProvider? state}) {

    String uniqueId = const Uuid().v4();
    print('Unique ID: $uniqueId');

    if (_client == null) {
      //providerState = state;
      _client = MqttBrowserClient('ws://192.168.1.141', uniqueId);
      _client!.port = 9001;
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);

      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;
    }
  }

  void connect() async {
    assert(_client != null);
    if (!isConnected) {
      try {
        print('Mosquitto start client connecting....');
        //providerState?.setAppConnectionState(MQTTConnectionState.connecting);
        await _client!.connect();
      } on Exception catch (e, stackTrace) {
        print('Client exception - $e');
        print('StackTrace: $stackTrace');
        disconnect();
      }
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
    payloadStreamController.close();
  }

  void subscribeToTopic(String topic) {

    _client!.subscribe(topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //providerState?.updateReceivedPayload(pt);
      payloadStreamController.add(pt);

     // print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      //print('');

    });

  }


  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    //providerState?.setAppConnectionState(MQTTConnectionState.disconnected);

    // Attempt reconnection after a delay
    Future.delayed(const Duration(seconds: 03), () {
      //_client!.disconnect();
      //connect();
    });
  }

  void onConnected() {
    assert(isConnected);
    //providerState?.setAppConnectionState(MQTTConnectionState.connected);
    print('Mosquitto client connected....');
  }
}
