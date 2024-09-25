import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_view/screens/customer/Dashboard/map/MapDeviceList_model.dart';
import 'package:mobile_view/screens/customer/Dashboard/map/maplatlong_provider.dart';
import 'package:provider/provider.dart';

import '../../../../constants/http_service.dart';
import '../../../../state_management/overall_use.dart';

class CustomMarkerPage extends StatefulWidget {
  const CustomMarkerPage(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  _CustomMarkerPageState createState() => _CustomMarkerPageState();
}

class _CustomMarkerPageState extends State<CustomMarkerPage> {
// created controller for displaying Google Maps
  Completer<GoogleMapController> _controller = Completer();

// given camera position
  CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 10,
  );

  Uint8List? marketimages;
  List<String> images = [
    'assets/weather/markerred.png',
    'assets/weather/oro_gem.png',
    'assets/images/oro_rtu.png',
    'assets/weather/markerred.png',
    'assets/weather/markerorange.png',
    'assets/weather/markergreen.png',
    'assets/weather/markeryellow.png',
    'assets/weather/markergray.png',
  ];

// created empty list of markers
  final List<Marker> _markers = <Marker>[];

// created list of coordinates of various locations
  List<LatLng> latLen = [];
  List<int> type = [];
  List<String> name = [];
  List<String> model = [];
  List<String> status = [];
  List<String> value = [];
  List<String> svolt = [];
  List<String> bvolt = [];

  late MapLatlong mapPvd;

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }



  @override
  void initState() {
    // TODO: implement initState
    mapPvd = Provider.of<MapLatlong>(context, listen: false);
    super.initState();
    fetchData();
    fetchDataload3();
  }

  Future<void> fetchData() async {
    mapPvd = Provider.of<MapLatlong>(context, listen: false);
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    // var jsonData = jsonDecode(jsondatastr);
    // mapPvd.editsite(deviceListMap: DeviceListMap.fromJson(jsonData)) ;
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response = await HttpService().postRequest("getUserGeography", body);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('jsonData---$jsonData');
      setState(() {
        mapPvd.editsite(deviceListMap: DeviceListMap.fromJson(jsonData));
      });
    }
  }

  Future<void> fetchDataload3() async {
    latLen.clear();
    name.clear();
    type.clear();
    model.clear();
    status.clear();
    value.clear();
    svolt.clear();
    bvolt.clear();
    mapPvd = Provider.of<MapLatlong>(context, listen: false);
    final Uint8List markIconsCtrl = await getImages(images[1], 50);
    final Uint8List markIconsNode = await getImages(images[2], 50);
    Uint8List markIconsValve ;
    if(mapPvd.siteData.data![0].geography!.status == 0)
    {
      markIconsValve = await getImages(images[7], 50);
    }
    else if(mapPvd.siteData.data![0].geography!.status == 1)
    {
      markIconsValve = await getImages(images[5], 50);
    }
    else if(mapPvd.siteData.data![0].geography!.status == 2)
    {
      markIconsValve = await getImages(images[5], 50);
    }   else if(mapPvd.siteData.data![0].geography!.status == 3)
    {
      markIconsValve = await getImages(images[3], 50);
    }
    else
    {
      markIconsValve = await getImages(images[7], 50);
    }  // if(mounted) {
    setState(() async{
      for (int i = 0; i < mapPvd.siteData.data!.length; i++) {
        String coordinatestr = mapPvd.siteData.data![0].geography!.latLong!;
        // coordinatestr = "11.1385415-76.9861059";
        List<String> coordinates =
        coordinatestr.contains('-') ? coordinatestr.split('-') : ['0', '0'];
        double ctrllatitude =
        coordinates.isNotEmpty ? double.parse(coordinates[0] ?? '0') : 0;
        double ctrllongitude =
        coordinates.isNotEmpty ? double.parse(coordinates[1] ?? '0') : 0;
        LatLng ctrllatLng = LatLng(ctrllatitude, ctrllongitude);
        latLen.add(ctrllatLng);
        name.add('${mapPvd.siteData.data![0].deviceName}');
        type.add(1);
        model.add('${mapPvd.siteData.data![0].modelName}');
        status.add('${mapPvd.siteData.data![0].geography!.status}');
        value.add('0');
        svolt.add('${mapPvd.siteData.data![0].geography!.sVolt}');
        bvolt.add('${mapPvd.siteData.data![0].geography!.batVolt}');
        for (int nodeindex = 0;
        nodeindex < mapPvd.siteData.data![0].nodeList!.length;
        nodeindex++) {
          String nodecoordinatestr =
          mapPvd.siteData.data![0].nodeList![nodeindex].geography!.latLong!;
          if(nodecoordinatestr == '-')
          {
            nodecoordinatestr = "";
          }
          List<String> nodecoordinates = nodecoordinatestr.contains('-')
              ? nodecoordinatestr.split('-')
              : ['0', '0'];
          double nodelatitude =
          nodecoordinates.isNotEmpty ? double.parse(nodecoordinates[0]) : 0;
          double nodelongitude =
          nodecoordinates.isNotEmpty ? double.parse(nodecoordinates[1]) : 0;
          LatLng nodelatLng = LatLng(nodelatitude, nodelongitude);

          name.add(
              '${mapPvd.siteData.data![0].nodeList![nodeindex].deviceName}');
          type.add(2);
          model.add(
              '${mapPvd.siteData.data![0].nodeList![nodeindex].modelName}');
          status.add(
              '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.status}');
          value.add('0');
          svolt.add(
              '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.sVolt}');
          bvolt.add(
              '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.batVolt}');
          latLen.add(nodelatLng);
          for (int valveindex = 0;
          valveindex <
              mapPvd.siteData.data![0].nodeList![nodeindex].geography!
                  .rlyStatus!.length;
          valveindex++) {
            String valvecoordinatestr = mapPvd
                .siteData
                .data![0]
                .nodeList![nodeindex]
                .geography!
                .rlyStatus![valveindex]
                .latLong!;
            if(valvecoordinatestr == '-')
            {
              valvecoordinatestr = "";
            }
            List<String> valvecoordinates = valvecoordinatestr.contains('-') ? valvecoordinatestr.split('-')
                : ['0', '0'];
            print('valvecoordinates--$valvecoordinates');
            double valvelatitude = valvecoordinates.isNotEmpty
                ? double.parse(valvecoordinates[0])
                : 0;
            double valvelongitude = valvecoordinates.isNotEmpty
                ? double.parse(valvecoordinates[1])
                : 0;
            LatLng valvelatLng = LatLng(valvelatitude, valvelongitude);

            latLen.add(valvelatLng);
            name.add(
                '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.rlyStatus![valveindex].name}');
            type.add(3);
            model.add('Valve');
            status.add(
                '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.rlyStatus![valveindex].status}');
            value.add('0');
            svolt.add('0');
            bvolt.add('0');
          }
          for (int valveindex = 0;
          valveindex <
              mapPvd.siteData.data![0].nodeList![nodeindex].geography!
                  .sensor!.length;
          valveindex++) {
            String valvecoordinatestr = mapPvd.siteData.data![0]
                .nodeList![nodeindex].geography!.sensor![valveindex].latLong!;
            if(valvecoordinatestr == '-')
            {
              valvecoordinatestr = "";
            }

            List<String> valvecoordinates = valvecoordinatestr.contains('-')
                ? valvecoordinatestr.split('-')
                : ['0', '0'];
            double valvelatitude = valvecoordinates.isNotEmpty
                ? double.parse(valvecoordinates[0])
                : 0;
            double valvelongitude = valvecoordinates.isNotEmpty
                ? double.parse(valvecoordinates[1])
                : 0;
            LatLng sensorlatLng = LatLng(valvelatitude, valvelongitude);

            latLen.add(sensorlatLng);
            name.add(
                '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.sensor![valveindex].name}');
            type.add(4);
            model.add('sensors');
            status.add('0');
            value.add(
                '${mapPvd.siteData.data![0].nodeList![nodeindex].geography!.sensor![valveindex].value}');
            svolt.add('0');
            bvolt.add('0');
          }
        }
      }
      _markers.clear();
      for (int i = 0; i < latLen.length; i++) {
        int typestr = type[i];
        if (latLen[i] != LatLng(0.0, 0.0)) {
          _markers.add(Marker(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: double.infinity,
                    height: 200,
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(getbottomimages(
                                      type[i], status[i], model[i])),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  '${name[i]} \n ${model[i]}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                if (typestr == 1)
                                  Text(
                                    'BAT Volt :${bvolt[i]} \t \t Solar Volt : ${svolt[i]}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (typestr == 2)
                                  Text(
                                    'BAT Volt :${bvolt[i]} \t \t Solar Volt : ${svolt[i]}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (typestr == 3)
                                    Text(
                                      'Status : \t${status[i]}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Value : \t${value[i]}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("ok"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        )),
                  );
                },
              );
            },
            markerId: MarkerId(i.toString()),
            icon: type[i] == 1
                ? BitmapDescriptor.fromBytes(markIconsCtrl)
                : type[i] == 2
                ? BitmapDescriptor.fromBytes(markIconsNode)
                :  BitmapDescriptor.fromBytes(await getImages(getmarkerimages(status[i]), 50)) ,
            position: latLen[i],
            infoWindow: InfoWindow(
              title: '${name[i]}',
            ),
          ));
        }
      }
    });
    setState(() {
      _kGoogle = CameraPosition(
        target: latLen.length >= 1 ? latLen[0] : LatLng(11.0759837, 76.8776559),
        zoom: 17,
      );
    });
  }

  String getmarkerimages(String status)  {
    if (status == "0") {
      return 'assets/weather/markerred.png';
    } else if (status == "1") {
      return 'assets/weather/markergreen.png';
    } else if (status == "2") {
      return 'assets/weather/markergreen.png';
    } else if (status == "3") {
      return 'assets/weather/markergray.png';
    } else {
      return 'assets/weather/markergray.png';
    }
  }

  String getbottomimages(int type, String status, String model) {
    if (type == 1) {
      if (status == "0") {
        return 'assets/weather/oro_gem.png';
      } else if (status == "1") {
        return 'assets/weather/oro_gem.png';
      } else if (status == "2") {
        return 'assets/weather/oro_gem.png';
      } else if (status == "3") {
        return 'assets/weather/oro_gem.png';
      } else {
        return 'assets/weather/oro_gem.png';
      }
    } else if (type == 2) {
      if (status == "0") {
        return 'assets/images/oro_rtu.png';
      } else if (status == "1") {
        return 'assets/images/oro_rtu.png';
      } else if (status == "2") {
        return 'assets/images/oro_rtu.png';
      } else if (status == "3") {
        return 'assets/images/oro_rtu.png';
      } else {
        return 'assets/images/oro_rtu.png';
      }
    } else if (type == 3) {
      if (status == "0") {
        return 'assets/images/valve_red.png';
      } else if (status == "1") {
        return 'assets/images/valve_green.png';
      } else if (status == "2") {
        return 'assets/images/valve_orange.png';
      } else if (status == "3") {
        return 'assets/images/valve_gray.png';
      } else {
        return 'assets/images/valve_gray.png';
      }
    } else if (type == 4) {
      if (status == "0") {
        return 'assets/weather/soilmoisture-1.png';
      } else if (status == "1") {
        return 'assets/weather/soilmoisture-1.png';
      } else if (status == "2") {
        return 'assets/weather/soilmoisture-1.png';
      } else if (status == "3") {
        return 'assets/weather/soilmoisture-1.png';
      } else {
        return 'assets/weather/soilmoisture-1.png';
      }
    } else {
      return 'assets/weather/soilmoisture-1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    mapPvd = Provider.of<MapLatlong>(context, listen: true);
    if (mapPvd.siteData?.data?.isNotEmpty == true) {
      String coordinatestr = mapPvd.siteData.data![0].geography!.latLong ?? "-";
      if (coordinatestr == "-") {
        coordinatestr = '20.5937-78.9629';
      }
      List<String> coordinates = coordinatestr.contains('-')
          ? coordinatestr.split('-')
          : ['20.5937', '78.9629'];
      double lat =
      coordinates.isNotEmpty ? double.parse(coordinates[0]) : 20.5937;
      double long =
      coordinates.isNotEmpty ? double.parse(coordinates[1]) : 78.9629;
      LatLng ctrllatLng = LatLng(lat, long);
      return Scaffold(
        // appBar: AppBar(
        //  backgroundColor: Theme.of(context).primaryColor,
        //  // on below line we have given title of app
        //  title: const Text("Geography"),
        // ),
        body: Container(
          child: SafeArea(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: mapPvd.siteData.data![0].geography!.latLong != ''
                    ? mapPvd.siteData.data![0].geography!.latLong != '-'
                    ? ctrllatLng
                    : LatLng(20.5937, 78.9629)
                    : LatLng(20.5937, 78.9629),
                zoom: mapPvd.siteData.data![0].geography!.latLong != ''
                    ? mapPvd.siteData.data![0].geography!.latLong != '-'
                    ? 17
                    : 4
                    : 4,
              ),
              markers: Set<Marker>.of(_markers),
              mapType: MapType.hybrid,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}