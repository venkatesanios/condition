import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NameListProvider with ChangeNotifier {
  List<String> _names = [];

  List<String> get names => _names;

  void addName(String name) {
    _names.add(name);
    names.sort();
    notifyListeners();
  }

  void removeName(String name) {
    _names.remove(name);
    names.sort();
    notifyListeners();
  }

  void removeAll() {
    _names = [];
    notifyListeners();
  }

  void updateName(String oldName, String newName) {
    final index = _names.indexOf(oldName);
    _names[index] = newName;
    names.sort();
    notifyListeners();
  }

  List<dynamic> selectedValuesList = [];

  void updateSelectedValues(List<dynamic> updatedList) {
    selectedValuesList = updatedList;
    // print('Provider selectedValuesList $selectedValuesList');
    notifyListeners();
  }
  void AddSelectedValues(List<dynamic> updatedList) {
    selectedValuesList.add(updatedList);
    notifyListeners();
  }
  void removeSelectedValues(List<dynamic> updatedList) {

    selectedValuesList.add(updatedList);
    notifyListeners();
  }
}
