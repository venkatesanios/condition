import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/MQTTManager.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'SCustomWidgets/custom_snack_bar.dart';

Future<void> validatePayloadSent({
  required BuildContext dialogContext,
  required BuildContext context,
  required MqttPayloadProvider mqttPayloadProvider,
  required void Function() acknowledgedFunction,
  required Map<String, dynamic> payload,
  required String payloadCode,
  required String deviceId
}) async {
  try {
    await MQTTManager().publish(jsonEncode(payload), "AppToFirmware/$deviceId");

    bool isAcknowledged = false;
    int maxWaitTime = 30;
    int elapsedTime = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Please wait..."),
              ],
            ),
          ),
        );
      },
    );

    while (elapsedTime < maxWaitTime) {
      await Future.delayed(const Duration(seconds: 1));
      elapsedTime++;

      if (mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['PayloadCode'] == payloadCode) {
        isAcknowledged = true;
        break;
      }
    }

    Navigator.of(context).pop();

    if (isAcknowledged) {
      if (mqttPayloadProvider.messageFromHw['Code'] == "200") {
        acknowledgedFunction();
      } else {
        showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']}", context: context);
      }
    } else {
      showAlertDialog(message: "Controller is not responding", context: context);
    }
  } catch (error, stackTrace) {
    Navigator.of(context).pop();
    showAlertDialog(message: error.toString(), context: context);
  }
}

void showAlertDialog({required String message, Widget? child, required BuildContext context}) {
  showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: child ?? Text(message),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("OK")
            )
          ],
        );
      }
  );
}

void showSnackBar({required String message, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
}