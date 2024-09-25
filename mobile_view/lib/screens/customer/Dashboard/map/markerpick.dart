import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
 import 'package:provider/provider.dart';

import 'maplatlong_provider.dart';

class MarkerPick extends StatefulWidget {
  MarkerPick({
    super.key,
    this.ctrlindex,
    this.name,
    required this.latlog,
    this.nodeindex,
    this.valveindex,
    this.type,
  });

  final nodeindex, ctrlindex, name, valveindex, type;
  dynamic latlog;

  @override
  _MarkerPickState createState() => _MarkerPickState();
}

class _MarkerPickState extends State<MarkerPick> with ChangeNotifier {
  GoogleMapController? _controller;
  LatLng _initialCameraPosition = LatLng(11.138572, 76.9761143);
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylineSet = {};
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    print('init ${widget.latlog}');
    if (widget.latlog == null) {
      print('null if init ${widget.latlog}');
      widget.latlog = '20.5937-78.9629';
    }


    if (widget.latlog != null && widget.latlog != '') {
      if (widget.latlog == "-" )
      {
        widget.latlog  = '20.5937-78.9629';
      }
      List<String> coordinates = widget.latlog.split('-');

      double latitude = double.parse(coordinates[0]);
      double longitude = double.parse(coordinates[1]);
      LatLng latLng = LatLng(latitude, longitude);
      _initialCameraPosition = latLng;
      _addMarker(latLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    var mapPvd = Provider.of<MapLatlong>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: widget.latlog == '20.5937-78.9629' ? 7 : 15,
            ),
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });
            },
            myLocationEnabled: true,
            markers: _markers,
            polylines: Set<Polyline>.of(polylineSet),
            onTap: (LatLng latLng) {
              _markers.clear();
              _addMarker(latLng);
            },
          ),
          if (_isBottomSheetOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addMarker(LatLng latLng) {
    print('call marker');
    var mapPvd = Provider.of<MapLatlong>(context, listen: false);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.name),
          position: latLng,
          consumeTapEvents: false,
          onTap: () {
            setState(() {
              _isBottomSheetOpen = true;
            });
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'LAT:${latLng.latitude}',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'LONG:${latLng.longitude}',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    print('marker set lat long');
                                    print('${widget.type}');
                                    if (widget.type == "valvestatus") {
                                      mapPvd.editObjectLocation(
                                        controllerIndex: widget.ctrlindex,
                                        nodeIndex: widget.nodeindex,
                                        objectIndex: widget.valveindex,
                                        location: '${latLng.latitude}-${latLng.longitude}',
                                      );
                                    } else if (widget.type == "nodeStatus") {
                                      mapPvd.editNodeLocation(
                                        controllerIndex: widget.ctrlindex,
                                        nodeIndex: widget.nodeindex,
                                        location: '${latLng.latitude}-${latLng.longitude}',
                                      );
                                    } else {
                                      mapPvd.editSiteLocation(
                                        controllerIndex: widget.ctrlindex,
                                        location: '${latLng.latitude}-${latLng.longitude}',
                                      );
                                    }
                                  });
                                  Navigator.pop(context);
                                  setState(() {
                                    _isBottomSheetOpen = false;
                                  });
                                },
                                child: Text("SET Lat Long"),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _isBottomSheetOpen = false;
                                });
                              },
                              child: Text("Cancel"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ).whenComplete(() {
              setState(() {
                _isBottomSheetOpen = false;
              });
            });
            print('Marker tapped! Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');
          },
        ),
      );
    });
  }
}
