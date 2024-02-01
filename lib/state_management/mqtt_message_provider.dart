import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  String _message = '';
  String get message => _message;

  bool _hasFetchedData = false;
  bool get hasFetchedData => _hasFetchedData;

  void setMessage(String message) {
    _message = message;
    _hasFetchedData = true;
    notifyListeners();
  }

  void setHasFetchedData() {
    _hasFetchedData = false;
  }
}