import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../constants/http_service.dart';
import 'MapDeviceList_model.dart';


class MapLatlong extends ChangeNotifier {
    DeviceListMap siteData = DeviceListMap();
   // DeviceListMap? get deviceListMap => siteData;

    Future<void> fetchData( int userId, int controllerId,) async {
       Map<String, Object> body = {"userId": userId, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserGeography", body);
      try {
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          siteData = DeviceListMap.fromJson(jsonData);
        }
      } catch(error, stackTrace) {
        print("Error: $error");
        print("StackTrace: $stackTrace");
      }
    }

void editsite({required DeviceListMap deviceListMap})
{
  siteData = deviceListMap;
}
    void editSiteLocation({required controllerIndex,required String location})
  {
     siteData?.data![controllerIndex].geography!.latLong = location;
    notifyListeners();
  }

  void editNodeLocation({required controllerIndex,required nodeIndex,required String location}){
    siteData?.data![controllerIndex].nodeList![nodeIndex].geography!.latLong = location;
     notifyListeners();
  }

  void editObjectLocation({required controllerIndex,required nodeIndex,required objectIndex,required String location}){
    siteData?.data![controllerIndex].nodeList![nodeIndex].geography!.rlyStatus![objectIndex].latLong = location;
     notifyListeners();
  }

}
