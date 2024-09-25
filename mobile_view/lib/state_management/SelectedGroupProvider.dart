import 'package:flutter/material.dart';

import '../Models/Customer/GroupsModel.dart';
import '../Models/IrrigationModel/sequence_model.dart';

class SelectedGroupProvider with ChangeNotifier {
  String selectedGroup = '';
  int selectedGroupsrno = 0;
  String selectedGroupid = '';
  List<String> selectedvalve = [];

  Line? selectedLine;

  void updateSelectedGroup(String groupName) {
    selectedGroup = groupName;
    notifyListeners();
    // print('selectedGroup $selectedGroup');
  }

  void updateselectedvalve(List<String> valveList) {
    selectedvalve = valveList;
    selectedvalve.sort();
    notifyListeners();
  }

  void updateSelectedGroupsrno(int groupNamesrno) {
    selectedGroupsrno = groupNamesrno == 0 ? 0 : groupNamesrno - 1;
    notifyListeners();
    // print('selectedGroup $selectedGroup');
  }

  void updateSelectedGroupid(String Groupid) {
    selectedGroupid = Groupid;
    notifyListeners();
    // print('selectedGroup $selectedGroup');
  }

  void updateSelectedLine(Line line) {
    selectedLine = line;
    notifyListeners();
  }

  List<Group>? selectedValveIndices = [];


  void clearSelectedValves() {
    selectedValveIndices = [];
    notifyListeners();
  }

  Map<String, List<int>> selectedValvesMap = {};

  void SelectedValve(String lineId, String selectvalveid, Group group,
      Group selectvalve) {
    if (group.location == lineId) {
      for (var i = 0; i < group.valve!.length; i++) {
        if (selectvalveid == group.valve![i].id) {
          group.valve!.removeAt(i);
        } else {
          // group.valve!.add(selectvalve);
        }
      }
    } else {
      group.valve = [];
    }
    print('group.valve:${group.valve}');
    notifyListeners();
  }

  // Method to toggle selected valve for a particular line
  void toggleSelectedValveIndex(String lineId, int index) {
    if (!selectedValvesMap.containsKey(lineId)) {
      selectedValvesMap[lineId] = [];
    }

    if (selectedValvesMap[lineId]!.contains(index)) {
      selectedValvesMap[lineId]!.remove(index);
    } else {
      selectedValvesMap[lineId]!.add(index);
    }
    notifyListeners();
  }

  void clearSelectedValvesForLine(String lineId) {
    selectedValvesMap.remove(lineId);
    notifyListeners();
  }

  void clearAllSelectedValves() {
    selectedValvesMap.clear();
    notifyListeners();
  }

  clearvalues()
  {
    selectedGroup = '';
    selectedGroupsrno = 0;
    selectedGroupid = '';
    selectedvalve = [];
    selectedLine;
    notifyListeners();
  }
}