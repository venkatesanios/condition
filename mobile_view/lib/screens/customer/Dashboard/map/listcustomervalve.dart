
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../constants/snack_bar.dart';
import 'MapDeviceList_model.dart';
import 'maplatlong_provider.dart';
import 'markerpick.dart';


class CustomerDeviceListMap extends StatefulWidget {
  const CustomerDeviceListMap(
      {Key? key,
        required this.userId,
        required this.controllerId, required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  State<CustomerDeviceListMap> createState() => _CustomerDeviceListMapState();
}

class _CustomerDeviceListMapState extends State<CustomerDeviceListMap> {
  String LatLongstr = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MapLatlong mapPvd = Provider.of<MapLatlong>(context, listen: false);
    // if(mounted)
    //   {
    //     setState(() {
    // mapPvd.fetchData(53, 584);
    //     });
    //   }
    // setState(() {
    Permissionlocation();
    requestmap();
    fetchData();
    // });
  }
  Permissionlocation()
  async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    else if (status.isPermanentlyDenied)
    {
      openAppSettings();
    }
    else{
      print('status $status');
    }
  }
  // Future<void> fetchData() async {
  //   mapPvd = Provider.of<mapLatlong>(context, listen: false);
  //      if(mounted) {
  //       setState(() {
  //         mapPvd.fetchData(53, 584);
  //       });
  //     }
  //   }
  Future<void> fetchData() async {
    MapLatlong mapPvd = Provider.of<MapLatlong>(context, listen: false);

    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    print('body geography $body');
    final response =
    await HttpService().postRequest("getUserGeography", body);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if(mounted) {
        setState(() {
          mapPvd.editsite(deviceListMap: DeviceListMap.fromJson(jsonData)) ;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    MapLatlong mapPvd = Provider.of<MapLatlong>(context, listen: true);
    return mapPvd.siteData?.data?.isNotEmpty == true ?
    Scaffold(
      appBar: AppBar(
        title: Text(mapPvd.siteData?.data![0].siteName ?? ""),
      ),
      body: SingleChildScrollView( // Wrap the entire body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: ListTile(
                  title: Text('${mapPvd.siteData?.data?[0].siteName}'),
                  subtitle:
                  Text('${mapPvd.siteData?.data?[0].geography?.latLong}'),
                  trailing: Container(
                    height: 50,
                    width: 120,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              String lat = await getLocation();
                              setState(() {
                                mapPvd.siteData?.data?[0].geography?.latLong = lat;
                              });
                            },
                            icon: Icon(Icons.my_location)),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MarkerPick(
                                            name: '${mapPvd.siteData?.data?[0].siteName}',
                                            latlog: '${mapPvd.siteData?.data?[0].geography?.latLong}' ?? 'LatLng(11.0759837-76.8776559)',
                                            ctrlindex: 0,
                                            nodeindex: 0,
                                            valveindex: 0,
                                            type: "controller",
                                          )));
                            },
                            icon: Icon(Icons.map_outlined)),
                        IconButton(
                            onPressed: () async {
                              String lat = await getLocation();
                              setState(() {
                                mapPvd.siteData?.data?[0].geography?.latLong = '';
                              });
                            },
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: mapPvd.siteData?.data?[0].nodeList!.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    expandedAlignment: Alignment.center,
                    controlAffinity: ListTileControlAffinity.leading,
                    trailing: IntrinsicWidth(
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                String lat = await getLocation();
                                setState(() {
                                  mapPvd.siteData?.data?[0].nodeList![index]
                                      .geography!.latLong =
                                      lat;
                                });
                              },
                              icon: Icon(Icons.my_location)),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MarkerPick(
                                              name: "${mapPvd.siteData?.data?[0].nodeList![index].deviceName}",
                                              latlog: "${mapPvd.siteData?.data?[0].nodeList![index].geography!.latLong}" ?? 'LatLng(11.0759837-76.8776559)',
                                              ctrlindex: 0,
                                              nodeindex: index,
                                              valveindex: 0,
                                              type: "nodeStatus",
                                            )));
                              },
                              icon: Icon(Icons.map_outlined)),
                          IconButton(
                              onPressed: () async {
                                String lat = await getLocation();
                                setState(() {
                                  mapPvd.siteData?.data?[0].nodeList![index]
                                      .geography!.latLong =
                                  '';
                                });
                              },
                              icon: Icon(Icons.delete)),
                        ],
                      ),
                    ),
                    title: Text(
                        "${mapPvd.siteData?.data?[0].nodeList![index].deviceName}"),
                    subtitle: Text(
                        "${mapPvd.siteData?.data?[0].nodeList![index].geography!.latLong}"),
                    children: [
                      Container(
                        height: (((mapPvd.siteData?.data?[0].nodeList![index]
                            .geography!.rlyStatus!.length ??
                            0) *
                            90) + ((mapPvd.siteData?.data?[0].nodeList![index]
                            .geography!.sensor!.length ??
                            0) *
                            50))
                            .toDouble(),
                        width: double.infinity,
                        child: Column(
                          children: [
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: mapPvd.siteData
                                    ?.data?[0]
                                    .nodeList![index]
                                    .geography!
                                    .rlyStatus!
                                    .length,
                                itemBuilder: (context, nodeindex) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: ListTile(
                                      title: Text(
                                          "${mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].name}"),
                                      subtitle: Text(
                                          "${mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].latLong}"),
                                      trailing: ("${mapPvd.siteData?.data![0].nodeList![index].geography!.rlyStatus![nodeindex].name}"
                                          .contains("."))
                                          ? Container(
                                        height: 50,
                                        width: 120,
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  String lat = await getLocation();
                                                  setState(() {
                                                    mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].latLong =
                                                        lat;
                                                  });
                                                },
                                                icon: Icon(Icons.my_location)),
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MarkerPick(
                                                                name: "${mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].name}",
                                                                latlog: "${mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].latLong}" ?? 'LatLng(11.0759837-76.8776559)',
                                                                ctrlindex: 0,
                                                                nodeindex: index,
                                                                valveindex: nodeindex,
                                                                type: "valvestatus",
                                                              )));
                                                },
                                                icon: Icon(Icons.map_outlined)),
                                            IconButton(
                                                onPressed: () async {
                                                  String lat = await getLocation();
                                                  setState(() {
                                                    mapPvd.siteData?.data?[0].nodeList![index].geography!.rlyStatus![nodeindex].latLong =
                                                    '';
                                                  });
                                                },
                                                icon: Icon(Icons.delete)),
                                          ],
                                        ),
                                      )
                                          : const SizedBox(
                                        height: 50,
                                        width: 100,
                                      ),
                                    ),
                                  );
                                }),
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: mapPvd.siteData
                                    ?.data?[0]
                                    .nodeList![index]
                                    .geography!
                                    .sensor!
                                    .length,
                                itemBuilder: (context, nodeindex) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: ListTile(
                                      title: Text(
                                          "${mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].name}"),
                                      subtitle: Text(
                                          "${mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].latLong}"),
                                      trailing: ("${mapPvd.siteData?.data![0].nodeList![index].geography!.sensor![nodeindex].name}"
                                          .contains("."))
                                          ? Container(
                                        height: 50,
                                        width: 120,
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  String lat = await getLocation();
                                                  setState(() {
                                                    mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].latLong =
                                                        lat;
                                                  });
                                                },
                                                icon: Icon(Icons.my_location)),
                                            //Valve
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MarkerPick(
                                                                name: "${mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].name}",
                                                                latlog: "${mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].latLong}" ??  'LatLng(11.0759837-76.8776559)',
                                                                ctrlindex: 0,
                                                                nodeindex: index,
                                                                valveindex: nodeindex,
                                                                type: "valvestatus",
                                                              )));
                                                },
                                                icon: Icon(Icons.map_outlined)),
                                            IconButton(
                                                onPressed: () async {
                                                  String lat = await getLocation();
                                                  setState(() {
                                                    mapPvd.siteData?.data?[0].nodeList![index].geography!.sensor![nodeindex].latLong = '';
                                                  });
                                                },
                                                icon: Icon(Icons.delete)),
                                          ],
                                        ),
                                      )
                                          : const SizedBox(
                                        height: 50,
                                        width: 100,
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            updategeography();
          });
        },
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ),
    ) : Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Future<String> getLocation() async {
    Geolocator.checkPermission();
    Geolocator.requestPermission();
    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    String result = '${_position.latitude}-${_position.longitude}';
    return result;
  }
  requestmap() async {
    String payLoadFinal = jsonEncode({
      "4700": [
        {"4701": ""},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');//
  }
  updategeography() async {
    //B48C9D80DA3D
    String payLoadFinal = jsonEncode({
      "5500": [
        {"5501": toMqttformatdevice()},
        {"5502": toMqttobject()},
        // {"5503": '${widget.userId}'},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
    GlobalSnackBar.show(
        context, 'Location updated', 200);
    requestmap();
  }
  String toMqttformatdevice() {
    String devicestr = '';
    MapLatlong mapPvd = Provider.of<MapLatlong>(context, listen: false);
    // print('Json ----> ${ mapPvd.siteData.toJson()}');
    devicestr += '${mapPvd.siteData?.data?[0].geography!.sNo},${mapPvd.siteData?.data?[0].geography!.latLong};';
    for (var i = 0; i < mapPvd.siteData.data![0].nodeList!.length; i++)
    {
      devicestr += '${mapPvd.siteData?.data?[0].nodeList![i].geography!.sNo},${mapPvd.siteData?.data?[0].nodeList![i].geography!.latLong ?? ''};';
    }
    return devicestr;
  }
  String toMqttobject() {
    String device = '';
    MapLatlong mapPvd = Provider.of<MapLatlong>(context, listen: false);
    for (var i = 0; i < mapPvd.siteData.data![0].nodeList!.length; i++)
    {
      for (var j = 0; j <
          mapPvd.siteData.data![0].nodeList![i].geography!.rlyStatus!
              .length; j++) {
        device +=
        '${mapPvd.siteData?.data?[0].nodeList![i].geography!.rlyStatus![j].sNo},${mapPvd
            .siteData?.data?[0].nodeList![i].geography!.rlyStatus![j].latLong};';
      }
      for (var k = 0; k <
          mapPvd.siteData.data![0].nodeList![i].geography!.sensor!
              .length; k++) {
        device +=
        '${mapPvd.siteData.data![0].nodeList![i].geography!.sensor![k].sNo},${ mapPvd
            .siteData?.data?[0].nodeList![i].geography!.sensor![k].latLong};';
      }
    }
    print('deveice--------->$device');
    return device;
  }
}
